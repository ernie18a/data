# Saptx - Trade Checkliste

- url: https://www.tradingview.com/script/F64YaUuN/
- type: indicator
- pine_id: PUB;ed243fae46df416188da8c2182c42764
- version: 2.0

## Description

[b]Saptx - Trade Checkliste[/b]

[i]Eine minimalistische Trading Checkliste direkt im Chart.[/i]

[b]Features:[/b]

[list]
[*]Frei anpassbare Bestätigungen
[*]Checkboxen zum schnellen Abhaken
[*]Dynamische Fortschrittsanzeige (rot → grün)
[*]Anpassbare Größe & Position
[*]Dezente Reminder-Box für besseren Fokus
[*]Cleanes UI ohne unnötigen Chart-Clutter
[/list]


[i]Perfekt um FOMO, Overtrading und impulsive Entries zu reduzieren.[/i]

## Source Code

````pine
//@version=6
indicator("Saptx - Trade Checklist", overlay = true)

// =====================================================
// LANGUAGE
// =====================================================
language = input.string(
     "English",
     "Language",
     options = ["English", "Deutsch"],
     group = "General"
)

isEnglish = language == "English"

// =====================================================
// LAYOUT
// =====================================================
posInput = input.string(
     "Top Right",
     "Position",
     options = [
         "Top Right",
         "Middle Right",
         "Bottom Right",
         "Top Left",
         "Middle Left",
         "Bottom Left",
         "Top Center",
         "Middle Center",
         "Bottom Center"
     ],
     group = "General"
)

layoutSize = input.string(
     "Medium",
     "Size",
     options = ["Small", "Medium", "Large"],
     group = "General"
)

tableOpacity = input.int(
     85,
     "Table Opacity %",
     minval = 0,
     maxval = 100,
     group = "General"
)

showOnlyActive = input.bool(
     true,
     "Only show filled checklist items",
     group = "General"
)

// =====================================================
// CHECKLIST
// =====================================================
gText = "Checklist"

c1Text = input.string(
     "Trend confirmed",
     "Item 1",
     group = gText,
     inline = "c1"
)
c1Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c1"
)

c2Text = input.string(
     "Relevant liquidity identified",
     "Item 2",
     group = gText,
     inline = "c2"
)
c2Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c2"
)

c3Text = input.string(
     "M5 reaction confirmed",
     "Item 3",
     group = gText,
     inline = "c3"
)
c3Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c3"
)

c4Text = input.string(
     "Risk/Reward fits the plan",
     "Item 4",
     group = gText,
     inline = "c4"
)
c4Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c4"
)

c5Text = input.string(
     "Stop Loss is correctly placed",
     "Item 5",
     group = gText,
     inline = "c5"
)
c5Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c5"
)

c6Text = input.string(
     "",
     "Item 6",
     group = gText,
     inline = "c6"
)
c6Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c6"
)

c7Text = input.string(
     "",
     "Item 7",
     group = gText,
     inline = "c7"
)
c7Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c7"
)

c8Text = input.string(
     "",
     "Item 8",
     group = gText,
     inline = "c8"
)
c8Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c8"
)

c9Text = input.string(
     "",
     "Item 9",
     group = gText,
     inline = "c9"
)
c9Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c9"
)

c10Text = input.string(
     "",
     "Item 10",
     group = gText,
     inline = "c10"
)
c10Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c10"
)

c11Text = input.string(
     "",
     "Item 11",
     group = gText,
     inline = "c11"
)
c11Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c11"
)

c12Text = input.string(
     "",
     "Item 12",
     group = gText,
     inline = "c12"
)
c12Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c12"
)

c13Text = input.string(
     "",
     "Item 13",
     group = gText,
     inline = "c13"
)
c13Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c13"
)

c14Text = input.string(
     "",
     "Item 14",
     group = gText,
     inline = "c14"
)
c14Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c14"
)

c15Text = input.string(
     "",
     "Item 15",
     group = gText,
     inline = "c15"
)
c15Check = input.bool(
     false,
     "✓",
     group = gText,
     inline = "c15"
)

// =====================================================
// TRANSPARENCY
// =====================================================
transp = 100 - tableOpacity

// =====================================================
// POSITION
// =====================================================
f_pos() =>
    posInput == "Top Right" ? position.top_right :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Bottom Right" ? position.bottom_right :
     posInput == "Top Left" ? position.top_left :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Middle Center" ? position.middle_center :
     position.bottom_center

// =====================================================
// SIZE
// =====================================================
f_size() =>
    layoutSize == "Small" ? size.small :
     layoutSize == "Large" ? size.large :
     size.normal

txtSize = f_size()

// =====================================================
// RESULT COLOR
// =====================================================
f_result_color(_done, _total, _transp) =>
    ratio = _total > 0 ? _done / _total : 0.0

    ratio <= 0.20 ? color.new(color.red, _transp) :
     ratio <= 0.40 ? color.new(color.orange, _transp) :
     ratio <= 0.65 ? color.new(color.yellow, _transp) :
     ratio < 1.00 ? color.new(color.lime, _transp) :
     color.new(color.green, _transp)

// =====================================================
// COLORS
// =====================================================
bgBody = color.new(color.black, transp)
bgHeader = color.new(color.gray, transp)

txtColor = color.white
infoColor = color.silver

// =====================================================
// CHECKLIST ARRAYS
// =====================================================
texts = array.from(
     c1Text,
     c2Text,
     c3Text,
     c4Text,
     c5Text,
     c6Text,
     c7Text,
     c8Text,
     c9Text,
     c10Text,
     c11Text,
     c12Text,
     c13Text,
     c14Text,
     c15Text
)

checks = array.from(
     c1Check,
     c2Check,
     c3Check,
     c4Check,
     c5Check,
     c6Check,
     c7Check,
     c8Check,
     c9Check,
     c10Check,
     c11Check,
     c12Check,
     c13Check,
     c14Check,
     c15Check
)

// =====================================================
// TABLE
// =====================================================
var table checklist = table.new(
     position.top_right,
     1,
     50,
     border_width = 1
)

// =====================================================
// DRAW
// =====================================================
if barstate.islast

    table.set_position(checklist, f_pos())
    table.clear(checklist, 0, 0)

    total = 0
    done = 0
    row = 0

    // =================================================
    // PRE-TRADE ANALYSIS
    // =================================================
    preTradeHeader = isEnglish ? "PRE-TRADE ANALYSIS" : "VOR-TRADE-ANALYSE"

    table.cell(
         checklist,
         0,
         row,
         preTradeHeader,
         text_size = txtSize,
         text_color = txtColor,
         bgcolor = bgHeader
    )

    row += 1

    // Trend
    trendText = isEnglish ?
         "Trend HTF / LTF direction" :
         "Trend HTF / LTF Richtung"

    table.cell(
         checklist,
         0,
         row,
         trendText,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // Structure
    structureText = isEnglish ?
         "Impulse vs. Correction" :
         "Impuls vs. Korrektur"

    table.cell(
         checklist,
         0,
         row,
         structureText,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // Roadmap
    roadmapText = isEnglish ?
         "Tradeaways & Targets" :
         "Tradeaways & Targets"

    table.cell(
         checklist,
         0,
         row,
         roadmapText,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // Liquidity
    liquidityText = isEnglish ?
         "Where is the liquidity?" :
         "Wo liegt die Liqudität?"

    table.cell(
         checklist,
         0,
         row,
         liquidityText,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // M5
    m5Text = isEnglish ?
         "M5 Tradeaway + Reaction?" :
         "M5 Tradeaway + Reaktion?"

    table.cell(
         checklist,
         0,
         row,
         m5Text,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // Entry
    entrySearchText = isEnglish ?
         "Find entry" :
         "Entry suchen"

    table.cell(
         checklist,
         0,
         row,
         entrySearchText,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // Look left
    lookLeftText = isEnglish ?
         "Look left - what is the market reacting to?" :
         "Nach links schauen — woran reagiert der Markt?"

    table.cell(
         checklist,
         0,
         row,
         lookLeftText,
         text_size = txtSize,
         text_color = infoColor,
         bgcolor = bgBody
    )

    row += 1

    // =================================================
    // TRADE CHECKLIST HEADER
    // =================================================
    checklistHeader = "TRADE CHECKLIST"

    table.cell(
         checklist,
         0,
         row,
         checklistHeader,
         text_size = txtSize,
         text_color = txtColor,
         bgcolor = bgHeader
    )

    row += 1

    // =================================================
    // CHECKLIST ITEMS
    // =================================================
    for i = 0 to array.size(texts) - 1

        txt = array.get(texts, i)
        checked = array.get(checks, i)

        active = str.length(txt) > 0

        if active
            total += 1

            if checked
                done += 1

        if active or not showOnlyActive

            symbol = checked ? "☑ " : "☐ "
            symbolColor = checked ? color.lime : color.white

            table.cell(
                 checklist,
                 0,
                 row,
                 symbol + txt,
                 text_size = txtSize,
                 text_color = symbolColor,
                 bgcolor = bgBody
            )

            row += 1

    // =================================================
    // RESULT
    // =================================================
    resultText = str.tostring(done) + "/"
         + str.tostring(total)
         + (isEnglish ? " Trades" : " Trades")

    resultBg = f_result_color(done, total, transp)

    table.cell(
         checklist,
         0,
         row,
         resultText,
         text_size = txtSize,
         text_color = txtColor,
         bgcolor = resultBg
    )
````
