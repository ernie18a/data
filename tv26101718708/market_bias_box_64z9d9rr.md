# Market Bias Box

- url: https://www.tradingview.com/script/64z9D9RR/
- type: indicator
- pine_id: PUB;c3c3548a6e61490b8fbb0ec217f1e709
- version: 1.0

## Description

This tool is designed to help day traders better understand current daily market events by providing them with comprehensive insights into various aspects of the market, thereby enabling them to gain a better understanding of the interrelationships within the ICT trading approach and market developments. 

[b]Meanings of Settings[/b]

[b]Weekly Profile :[/b]
The following “ICT Weekly Profiles” are conceptual models that describe typical patterns of potential price movements during a trading week.

CEP Long/Short = Classic Expansion Week
MWR Long/Short = Midweek Reversal
CTR Long/Short = Consolidation Thursday Reversal
TGIF Long/Short = Thank God its Friday
S&D Long/Short = Seek & Destroy

[b]Quarterly Week: [/b]
Here, you select the value estimated on a weekly basis

A = Accumulation
M = Manipulation
D = Distribution
X = Continuation/Reversal

[b]Day Quarterly:[/b]

AMDX = Accumulation/ Manipulation/ Distribution/ Continuation/Reversal
XAMD = Continuation/Reversal/ Accumulation/ Manipulation/ Distribution

[b]Day Profile :[/b]
Day Profile (also called Intraday Profile) is a recurring, algorithmic price pattern within a trading day.

LDR Long/Short = London Reversal
JS Long/Short = Judas Swing
NYR Long/Short = NY Reversal
Mani&Exp. Long/Short = Manipulation & Expansion
S&D = Seek & Destroy



This is an information board that allows traders to keep a close eye on market activity at all times.

Happy trading!

## Source Code

````pine
//@version=6
indicator("Market Bias Box Compact", overlay=true)

// Inputs
weeklyProfile       = input.string("-", "aktuelles Weekly Profile", options=["-", "CEP Long", "CEP Short", "MWR Long", "MWR Short", "CTR Long", "CTR Short", "TGIF Long", "TGIF Short", "S&D Long", "S&D Short"])
quarterlyWeek       = input.string("M", "Quarterly Theory Week", options=["-", "A", "M", "D", "X"])
dayQuarterlyProfile = input.string("-", "Day Quarterly Profile", options=["-", "AMDX", "XAMD"])
dayProfile          = input.string("-", "Day Profile", options=["-", "LDR Long", "LDR Short", "JS Long", "JD Short", "NYR Long", "NYR Short", "Mani&Exp. Long", "Mani&Exp. Short", "S&D"])
biasDistribution    = input.string("-", "Bias Distribution", options=["-", "long", "short"])
lastDayBias         = input.string("short", "last Day BIAS", options=["short", "long", "neutral", "-"])
actualDailyBias     = input.string("-", "actual daily BIAS", options=["short", "long", "neutral", "-"])

tablePosInput = input.string("oben rechts", "Platzierung", options=["oben links", "oben rechts", "unten links", "unten rechts"])
fontSizeInput = input.string("small", "Schriftgrösse", options=["tiny", "small", "normal", "large", "huge"])

// Design Inputs
headerBg     = input.color(color.rgb(35, 35, 40), "Header Hintergrund")
leftBg       = input.color(color.rgb(28, 28, 32), "Linke Spalte Hintergrund")
rightBg      = input.color(color.rgb(18, 18, 22), "Rechte Spalte Hintergrund")
textCol      = input.color(color.white, "Textfarbe")
mutedTextCol = input.color(color.rgb(190, 190, 200), "Label Farbe")
frameCol     = input.color(color.rgb(70, 70, 80), "Randfarbe")

// Funktionen
getTablePos(pos) =>
    result = position.top_right
    if pos == "oben links"
        result := position.top_left
    else if pos == "oben rechts"
        result := position.top_right
    else if pos == "unten links"
        result := position.bottom_left
    else
        result := position.bottom_right
    result

getTextSize(sz) =>
    result = size.small
    if sz == "tiny"
        result := size.tiny
    else if sz == "small"
        result := size.small
    else if sz == "normal"
        result := size.normal
    else if sz == "large"
        result := size.large
    else
        result := size.huge
    result

biasColor(v) =>
    result = textCol
    if v == "long"
        result := color.rgb(80, 200, 120)
    else if v == "short"
        result := color.rgb(255, 90, 90)
    else if v == "neutral"
        result := color.rgb(255, 185, 70)
    result

profileColor(v) =>
    result = textCol
    if str.contains(v, "Long")
        result := color.rgb(80, 200, 120)
    else if str.contains(v, "Short")
        result := color.rgb(255, 90, 90)
    result

quarterlyWeekColor(v) =>
    result = textCol
    if v == "A"
        result := color.rgb(210, 210, 210)
    else if v == "M"
        result := color.rgb(255, 105, 180)
    else if v == "D"
        result := color.rgb(80, 200, 120)
    else if v == "X"
        result := color.rgb(120, 190, 255)
    result

quarterlyWeekBg(v) =>
    result = rightBg
    if v == "A"
        result := color.rgb(55, 55, 60)
    else if v == "M"
        result := color.rgb(70, 35, 60)
    else if v == "D"
        result := color.rgb(25, 60, 35)
    else if v == "X"
        result := color.rgb(30, 50, 75)
    result

letterColor(v) =>
    result = textCol
    if v == "A"
        result := color.rgb(210, 210, 210)
    else if v == "M"
        result := color.rgb(255, 105, 180)
    else if v == "D"
        result := color.rgb(80, 200, 120)
    else if v == "X"
        result := color.rgb(120, 190, 255)
    result

letterBg(v) =>
    result = rightBg
    if v == "A"
        result := color.rgb(55, 55, 60)
    else if v == "M"
        result := color.rgb(70, 35, 60)
    else if v == "D"
        result := color.rgb(25, 60, 35)
    else if v == "X"
        result := color.rgb(30, 50, 75)
    result

// Buchstaben für Day Quarterly Profile extrahieren
dq1 = str.length(dayQuarterlyProfile) == 4 ? str.substring(dayQuarterlyProfile, 0, 1) : ""
dq2 = str.length(dayQuarterlyProfile) == 4 ? str.substring(dayQuarterlyProfile, 1, 2) : ""
dq3 = str.length(dayQuarterlyProfile) == 4 ? str.substring(dayQuarterlyProfile, 2, 3) : ""
dq4 = str.length(dayQuarterlyProfile) == 4 ? str.substring(dayQuarterlyProfile, 3, 4) : ""

// Tabelle
var table t = na
var string lastPos = ""

if na(t)
    t := table.new(getTablePos(tablePosInput), 5, 8, border_width=1, border_color=frameCol)
    lastPos := tablePosInput

if lastPos != tablePosInput
    table.delete(t)
    t := table.new(getTablePos(tablePosInput), 5, 8, border_width=1, border_color=frameCol)
    lastPos := tablePosInput

// Anzeige
if barstate.islast
    txtSize = getTextSize(fontSizeInput)

    // Header
    table.cell(t, 0, 0, "MARKET BIAS BOX", text_color=color.white, text_size=txtSize, bgcolor=headerBg)
    table.cell(t, 1, 0, "", text_color=color.white, text_size=txtSize, bgcolor=headerBg)
    table.cell(t, 2, 0, "", text_color=color.white, text_size=txtSize, bgcolor=headerBg)
    table.cell(t, 3, 0, "", text_color=color.white, text_size=txtSize, bgcolor=headerBg)
    table.cell(t, 4, 0, "", text_color=color.white, text_size=txtSize, bgcolor=headerBg)
    table.merge_cells(t, 0, 0, 4, 0)

    // Weekly Profile
    table.cell(t, 0, 1, "Weekly Profile", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)
    table.cell(t, 1, 1, weeklyProfile, text_color=profileColor(weeklyProfile), text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 2, 1, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 3, 1, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 4, 1, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.merge_cells(t, 1, 1, 4, 1)

    // Quarterly Week
    table.cell(t, 0, 2, "Quarterly Week", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)
    table.cell(t, 1, 2, quarterlyWeek, text_color=quarterlyWeekColor(quarterlyWeek), text_size=txtSize, bgcolor=quarterlyWeekBg(quarterlyWeek))
    table.cell(t, 2, 2, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 3, 2, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 4, 2, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.merge_cells(t, 1, 2, 4, 2)

    // Day Quarterly Profile
    table.cell(t, 0, 3, "Day Quarterly", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)

    if dayQuarterlyProfile == "AMDX" or dayQuarterlyProfile == "XAMD"
        table.cell(t, 1, 3, dq1, text_color=letterColor(dq1), text_size=txtSize, bgcolor=letterBg(dq1))
        table.cell(t, 2, 3, dq2, text_color=letterColor(dq2), text_size=txtSize, bgcolor=letterBg(dq2))
        table.cell(t, 3, 3, dq3, text_color=letterColor(dq3), text_size=txtSize, bgcolor=letterBg(dq3))
        table.cell(t, 4, 3, dq4, text_color=letterColor(dq4), text_size=txtSize, bgcolor=letterBg(dq4))
    else
        table.cell(t, 1, 3, dayQuarterlyProfile, text_color=textCol, text_size=txtSize, bgcolor=rightBg)
        table.cell(t, 2, 3, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
        table.cell(t, 3, 3, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
        table.cell(t, 4, 3, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
        table.merge_cells(t, 1, 3, 4, 3)

    // Day Profile
    table.cell(t, 0, 4, "Day Profile", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)
    table.cell(t, 1, 4, dayProfile, text_color=profileColor(dayProfile), text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 2, 4, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 3, 4, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 4, 4, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.merge_cells(t, 1, 4, 4, 4)

    // Bias Distribution
    table.cell(t, 0, 5, "Bias Distribution", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)
    table.cell(t, 1, 5, biasDistribution, text_color=biasColor(biasDistribution), text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 2, 5, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 3, 5, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 4, 5, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.merge_cells(t, 1, 5, 4, 5)

    // Last Day Bias
    table.cell(t, 0, 6, "Last Day Bias", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)
    table.cell(t, 1, 6, lastDayBias, text_color=biasColor(lastDayBias), text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 2, 6, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 3, 6, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 4, 6, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.merge_cells(t, 1, 6, 4, 6)

    // Actual Daily Bias
    table.cell(t, 0, 7, "Actual Daily Bias", text_color=mutedTextCol, text_size=txtSize, bgcolor=leftBg)
    table.cell(t, 1, 7, actualDailyBias, text_color=biasColor(actualDailyBias), text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 2, 7, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 3, 7, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.cell(t, 4, 7, "", text_color=textCol, text_size=txtSize, bgcolor=rightBg)
    table.merge_cells(t, 1, 7, 4, 7)
````
