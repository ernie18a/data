# VWAP MTF Adaptive Levels

- url: https://www.tradingview.com/script/DvAlSsjj/
- type: indicator
- pine_id: PUB;c080216fb14f4d0aa46d71c2e4e71fa6
- version: 1.0

## Description

VWAP MTF Adaptive Levels 

DESCRIPTION

VWAP MTF Adaptive Levels is a multi-timeframe VWAP indicator designed to provide clear volume-weighted reference levels without covering the candles.

Instead of plotting complete VWAP curves across historical price action, the indicator displays the current levels as short horizontal lines positioned to the right of the latest candle. This keeps the chart clean while preserving the most important VWAP information.

MAIN FEATURES

• Adaptive main VWAP based on the active chart timeframe
• Daily, Weekly and Monthly VWAP reference levels
• Optional ±1, ±2 and ±3 standard-deviation levels
• Short horizontal lines displayed only on the right side
• Exact price displayed next to every level
• BULL/BEAR dashboard
• Fully customizable colors, line width, line length and text size
• Adjustable distance from the latest candle
• Built-in crossover alerts
• America/New_York timezone with automatic daylight-saving adjustment

AUTO ANCHOR MODE

When “Auto” is selected, the VWAP anchor changes automatically:

• Intraday charts → Daily VWAP
• Daily chart → Monthly VWAP
• Weekly chart → Quarterly VWAP
• Monthly chart → Yearly VWAP

BULL/BEAR DASHBOARD

The dashboard provides a simple directional context:

• BULL: price is above the main VWAP
• BEAR: price is below the main VWAP

The dashboard also displays the active chart timeframe, current VWAP anchor and main VWAP price.

The BULL/BEAR status is a market-bias filter and should not be considered a standalone entry signal.

CUSTOMIZATION

Users can independently configure:

• Visible VWAP levels
• Standard-deviation multipliers
• Distance from the latest candle
• Horizontal-line length and thickness
• Solid, dashed or dotted line style
• Price-label size
• Dashboard position and size
• BULL and BEAR colors
• Individual colors for every VWAP level

NOTES

The script does not use request.security() lookahead logic. VWAP values on the open candle update in real time as price and volume change; confirmed historical values remain stable after the candle closes.

VWAP requires volume information. On Forex and CFD symbols, results can vary between brokers because these markets may use tick volume instead of centralized exchange volume.

This indicator was created primarily for XAUUSD analysis, but it can be used on other instruments and timeframes that provide volume data.

Suggested workflow:

• H4/H1 for directional context
• M15/M5 for execution analysis
• Combine VWAP with market structure, liquidity sweeps, PDH/PDL, PWH/PWL, FVG and confirmed break/retest setups

DISCLAIMER

This indicator is intended for educational and analytical purposes only. It does not constitute financial advice or guarantee future results. Always apply independent analysis and appropriate risk management.

TAGS

VWAP, Multi-Timeframe, MTF, Volume, Standard Deviation, XAUUSD, Gold, Intraday, Dashboard, Support and Resistance

## Source Code

````pine
//@version=6
indicator("VWAP MTF – Livelli a destra", shorttitle = "VWAP MTF Right", overlay = true, max_lines_count = 50, max_labels_count = 50)

//=============================================================================
// INPUT
//=============================================================================

string GRP_MAIN   = "1. Calcolo VWAP"
string GRP_LEVELS = "2. Livelli visibili"
string GRP_RIGHT  = "3. Linee orizzontali a destra"
string GRP_COLORS = "4. Colori"
string GRP_PANEL  = "5. Pannello BULL / BEAR"

float sourceInput = input.source(hlc3, "Sorgente", group = GRP_MAIN)

string anchorInput = input.string(
     "Auto", "Ancoraggio principale",
     options = ["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly"],
     group = GRP_MAIN,
     tooltip = "AUTO: Intraday = Daily, Daily = Monthly, Weekly = Quarterly, Monthly = Yearly.")

string timezoneInput = input.string(
     "America/New_York", "Fuso orario reset", group = GRP_MAIN,
     tooltip = "Segue automaticamente l'ora solare e l'ora legale di New York.")

bool showMain = input.bool(true, "VWAP principale", group = GRP_LEVELS)
bool showDaily = input.bool(true, "Daily VWAP", group = GRP_LEVELS)
bool showWeekly = input.bool(true, "Weekly VWAP", group = GRP_LEVELS)
bool showMonthly = input.bool(true, "Monthly VWAP", group = GRP_LEVELS)

bool showBand1 = input.bool(
     true, "Livelli ±1", inline = "B1", group = GRP_LEVELS)

float mult1 = input.float(
     1.0, "Moltiplicatore", minval = 0.1, step = 0.1,
     inline = "B1", group = GRP_LEVELS)

bool showBand2 = input.bool(
     true, "Livelli ±2", inline = "B2", group = GRP_LEVELS)

float mult2 = input.float(
     2.0, "Moltiplicatore", minval = 0.1, step = 0.1,
     inline = "B2", group = GRP_LEVELS)

bool showBand3 = input.bool(
     false, "Livelli ±3", inline = "B3", group = GRP_LEVELS)

float mult3 = input.float(
     3.0, "Moltiplicatore", minval = 0.1, step = 0.1,
     inline = "B3", group = GRP_LEVELS)

int rightOffset = input.int(
     5, "Distanza dall'ultima candela",
     minval = 1, maxval = 200,
     group = GRP_RIGHT,
     tooltip = "Aumenta questo valore per spostare i livelli più a destra.")

int lineLength = input.int(
     25, "Lunghezza linee",
     minval = 2, maxval = 250,
     group = GRP_RIGHT)

int lineWidth = input.int(
     2, "Spessore linee",
     minval = 1, maxval = 5,
     group = GRP_RIGHT)

string lineStyleInput = input.string(
     "Solida", "Stile linee",
     options = ["Solida", "Tratteggiata", "Puntinata"],
     group = GRP_RIGHT)

string textSizeInput = input.string(
     "Normale", "Grandezza prezzo",
     options = ["Minima", "Piccola", "Normale", "Grande", "Molto grande"],
     group = GRP_RIGHT)

bool showLevelName = input.bool(
     true, "Mostra nome insieme al prezzo",
     group = GRP_RIGHT)

color dailyColor = input.color(
     color.rgb(0, 190, 255), "Daily", group = GRP_COLORS)

color weeklyColor = input.color(
     color.rgb(255, 145, 0), "Weekly", group = GRP_COLORS)

color monthlyColor = input.color(
     color.rgb(170, 80, 255), "Monthly", group = GRP_COLORS)

color quarterlyColor = input.color(
     color.rgb(40, 120, 255), "Quarterly", group = GRP_COLORS)

color yearlyColor = input.color(
     color.rgb(235, 70, 100), "Yearly", group = GRP_COLORS)

color band1Color = input.color(
     color.rgb(0, 200, 140), "Livelli ±1", group = GRP_COLORS)

color band2Color = input.color(
     color.rgb(255, 170, 0), "Livelli ±2", group = GRP_COLORS)

color band3Color = input.color(
     color.rgb(240, 70, 70), "Livelli ±3", group = GRP_COLORS)

// Pannello BULL/BEAR
bool showPanel = input.bool(
     true, "Mostra pannello",
     group = GRP_PANEL)

string panelPositionInput = input.string(
     "Alto destra", "Posizione",
     options = [
         "Alto destra",
         "Alto centro",
         "Alto sinistra",
         "Basso destra",
         "Basso centro",
         "Basso sinistra"
     ],
     group = GRP_PANEL)

string panelSizeInput = input.string(
     "Normale", "Grandezza pannello",
     options = ["Piccola", "Normale", "Grande", "Molto grande"],
     group = GRP_PANEL)

color bullColor = input.color(
     color.rgb(0, 190, 120), "Colore BULL",
     group = GRP_PANEL)

color bearColor = input.color(
     color.rgb(230, 70, 70), "Colore BEAR",
     group = GRP_PANEL)

//=============================================================================
// FUNZIONI
//=============================================================================

f_autoAnchor() =>
    string result = "Daily"

    if timeframe.isintraday
        result := "Daily"
    else if timeframe.isdaily
        result := "Monthly"
    else if timeframe.isweekly
        result := "Quarterly"
    else
        result := "Yearly"

    result

f_periodKey(string periodName) =>
    int currentYear = year(time, timezoneInput)
    int currentMonth = month(time, timezoneInput)
    int currentDay = dayofmonth(time, timezoneInput)
    int currentWeek = weekofyear(time, timezoneInput)
    int quarterNumber = int(math.floor((currentMonth - 1) / 3)) + 1

    int key = switch periodName
        "Daily"     => currentYear * 10000 + currentMonth * 100 + currentDay
        "Weekly"    => currentYear * 100 + currentWeek
        "Monthly"   => currentYear * 100 + currentMonth
        "Quarterly" => currentYear * 10 + quarterNumber
        => currentYear

    key

f_isNewPeriod(string periodName) =>
    int currentKey = f_periodKey(periodName)
    barstate.isfirst or currentKey != currentKey[1]

f_anchorColor(string periodName) =>
    color result = switch periodName
        "Daily"     => dailyColor
        "Weekly"    => weeklyColor
        "Monthly"   => monthlyColor
        "Quarterly" => quarterlyColor
        => yearlyColor

    result

f_lineStyle() =>
    switch lineStyleInput
        "Tratteggiata" => line.style_dashed
        "Puntinata"    => line.style_dotted
        => line.style_solid

f_textSize() =>
    switch textSizeInput
        "Minima"       => size.tiny
        "Piccola"      => size.small
        "Grande"       => size.large
        "Molto grande" => size.huge
        => size.normal

f_panelPosition() =>
    switch panelPositionInput
        "Alto centro"    => position.top_center
        "Alto sinistra"  => position.top_left
        "Basso destra"   => position.bottom_right
        "Basso centro"   => position.bottom_center
        "Basso sinistra" => position.bottom_left
        => position.top_right

f_panelTextSize() =>
    switch panelSizeInput
        "Piccola"      => size.small
        "Grande"       => size.large
        "Molto grande" => size.huge
        => size.normal

f_levelText(string levelName, float price) =>
    string priceText = str.tostring(price, format.mintick)

    showLevelName ?
         levelName + "  " + priceText :
         priceText

f_updateLevel(
     line oldLine,
     label oldLabel,
     float price,
     string levelName,
     color levelColor,
     bool visible) =>

    line resultLine = oldLine
    label resultLabel = oldLabel

    int xStart = bar_index + rightOffset
    int xEnd = xStart + lineLength

    if visible and not na(price)
        if na(resultLine)
            resultLine := line.new(
                 xStart,
                 price,
                 xEnd,
                 price,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = levelColor,
                 width = lineWidth,
                 style = f_lineStyle())
        else
            line.set_xy1(resultLine, xStart, price)
            line.set_xy2(resultLine, xEnd, price)
            line.set_color(resultLine, levelColor)
            line.set_width(resultLine, lineWidth)
            line.set_style(resultLine, f_lineStyle())

        if na(resultLabel)
            resultLabel := label.new(
                 xEnd + 1,
                 price,
                 f_levelText(levelName, price),
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = levelColor,
                 textcolor = color.white,
                 size = f_textSize())
        else
            label.set_xy(resultLabel, xEnd + 1, price)
            label.set_text(
                 resultLabel,
                 f_levelText(levelName, price))
            label.set_color(resultLabel, levelColor)
            label.set_textcolor(resultLabel, color.white)
            label.set_size(resultLabel, f_textSize())

    else
        if not na(resultLine)
            line.delete(resultLine)
            resultLine := na

        if not na(resultLabel)
            label.delete(resultLabel)
            resultLabel := na

    [resultLine, resultLabel]

//=============================================================================
// CALCOLO VWAP
//=============================================================================

string activeAnchor = anchorInput == "Auto" ?
     f_autoAnchor() : anchorInput

bool resetMain = f_isNewPeriod(activeAnchor)

[mainVwap, upper1, lower1] =
     ta.vwap(sourceInput, resetMain, mult1)

[_, upper2, lower2] =
     ta.vwap(sourceInput, resetMain, mult2)

[_, upper3, lower3] =
     ta.vwap(sourceInput, resetMain, mult3)

float dailyVwap = ta.vwap(
     sourceInput, f_isNewPeriod("Daily"))

float weeklyVwap = ta.vwap(
     sourceInput, f_isNewPeriod("Weekly"))

float monthlyVwap = ta.vwap(
     sourceInput, f_isNewPeriod("Monthly"))

color mainColor = f_anchorColor(activeAnchor)

//=============================================================================
// LINEE ORIZZONTALI A DESTRA
//=============================================================================

var line mainLine = na
var label mainLabel = na

var line dailyLine = na
var label dailyLabel = na

var line weeklyLine = na
var label weeklyLabel = na

var line monthlyLine = na
var label monthlyLabel = na

var line upper1Line = na
var label upper1Label = na

var line lower1Line = na
var label lower1Label = na

var line upper2Line = na
var label upper2Label = na

var line lower2Line = na
var label lower2Label = na

var line upper3Line = na
var label upper3Label = na

var line lower3Line = na
var label lower3Label = na

if barstate.islast
    [newMainLine, newMainLabel] = f_updateLevel(
         mainLine,
         mainLabel,
         mainVwap,
         "VWAP " + activeAnchor,
         mainColor,
         showMain)

    mainLine := newMainLine
    mainLabel := newMainLabel

    [newDailyLine, newDailyLabel] = f_updateLevel(
         dailyLine,
         dailyLabel,
         dailyVwap,
         "D-VWAP",
         dailyColor,
         showDaily and activeAnchor != "Daily")

    dailyLine := newDailyLine
    dailyLabel := newDailyLabel

    [newWeeklyLine, newWeeklyLabel] = f_updateLevel(
         weeklyLine,
         weeklyLabel,
         weeklyVwap,
         "W-VWAP",
         weeklyColor,
         showWeekly and activeAnchor != "Weekly")

    weeklyLine := newWeeklyLine
    weeklyLabel := newWeeklyLabel

    [newMonthlyLine, newMonthlyLabel] = f_updateLevel(
         monthlyLine,
         monthlyLabel,
         monthlyVwap,
         "M-VWAP",
         monthlyColor,
         showMonthly and activeAnchor != "Monthly")

    monthlyLine := newMonthlyLine
    monthlyLabel := newMonthlyLabel

    [newUpper1Line, newUpper1Label] = f_updateLevel(
         upper1Line,
         upper1Label,
         upper1,
         "+" + str.tostring(mult1),
         band1Color,
         showBand1)

    upper1Line := newUpper1Line
    upper1Label := newUpper1Label

    [newLower1Line, newLower1Label] = f_updateLevel(
         lower1Line,
         lower1Label,
         lower1,
         "-" + str.tostring(mult1),
         band1Color,
         showBand1)

    lower1Line := newLower1Line
    lower1Label := newLower1Label

    [newUpper2Line, newUpper2Label] = f_updateLevel(
         upper2Line,
         upper2Label,
         upper2,
         "+" + str.tostring(mult2),
         band2Color,
         showBand2)

    upper2Line := newUpper2Line
    upper2Label := newUpper2Label

    [newLower2Line, newLower2Label] = f_updateLevel(
         lower2Line,
         lower2Label,
         lower2,
         "-" + str.tostring(mult2),
         band2Color,
         showBand2)

    lower2Line := newLower2Line
    lower2Label := newLower2Label

    [newUpper3Line, newUpper3Label] = f_updateLevel(
         upper3Line,
         upper3Label,
         upper3,
         "+" + str.tostring(mult3),
         band3Color,
         showBand3)

    upper3Line := newUpper3Line
    upper3Label := newUpper3Label

    [newLower3Line, newLower3Label] = f_updateLevel(
         lower3Line,
         lower3Label,
         lower3,
         "-" + str.tostring(mult3),
         band3Color,
         showBand3)

    lower3Line := newLower3Line
    lower3Label := newLower3Label

//=============================================================================
// PANNELLO SUPERIORE BULL / BEAR
//=============================================================================

bool bullishBias =
     not na(mainVwap) and close >= mainVwap

string biasText =
     bullishBias ? "BULL" : "BEAR"

color biasColor =
     bullishBias ? bullColor : bearColor

string pricePositionText =
     bullishBias ?
     "PREZZO SOPRA VWAP" :
     "PREZZO SOTTO VWAP"

var table biasPanel = table.new(
     f_panelPosition(),
     3,
     2,
     bgcolor = color.new(color.black, 10),
     frame_color = color.new(color.white, 55),
     frame_width = 1,
     border_color = color.new(color.white, 80))

if barstate.islast
    if showPanel
        table.cell(
             biasPanel,
             0,
             0,
             "VWAP MTF",
             text_color = color.white,
             bgcolor = color.new(mainColor, 20),
             text_size = f_panelTextSize())

        table.cell(
             biasPanel,
             1,
             0,
             "TF " + timeframe.period,
             text_color = color.white,
             bgcolor = color.new(mainColor, 20),
             text_size = f_panelTextSize())

        table.cell(
             biasPanel,
             2,
             0,
             activeAnchor,
             text_color = color.white,
             bgcolor = color.new(mainColor, 20),
             text_size = f_panelTextSize())

        table.cell(
             biasPanel,
             0,
             1,
             biasText,
             text_color = color.white,
             bgcolor = biasColor,
             text_size = f_panelTextSize())

        table.cell(
             biasPanel,
             1,
             1,
             pricePositionText,
             text_color = biasColor,
             bgcolor = color.new(color.black, 5),
             text_size = f_panelTextSize())

        table.cell(
             biasPanel,
             2,
             1,
             str.tostring(mainVwap, format.mintick),
             text_color = color.white,
             bgcolor = color.new(color.black, 5),
             text_size = f_panelTextSize())

    else
        table.clear(
             biasPanel,
             0,
             0,
             2,
             1)

//=============================================================================
// ALERT
//=============================================================================

alertcondition(
     ta.crossover(close, mainVwap),
     "Prezzo sopra VWAP",
     "Il prezzo ha incrociato il VWAP principale verso l'alto.")

alertcondition(
     ta.crossunder(close, mainVwap),
     "Prezzo sotto VWAP",
     "Il prezzo ha incrociato il VWAP principale verso il basso.")

alertcondition(
     ta.crossover(close, upper1),
     "Break VWAP +1",
     "Il prezzo ha superato il livello VWAP +1.")

alertcondition(
     ta.crossunder(close, lower1),
     "Break VWAP -1",
     "Il prezzo è sceso sotto il livello VWAP -1.")
````
