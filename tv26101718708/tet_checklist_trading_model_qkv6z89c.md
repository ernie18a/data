# TET Checklist Trading Model

- url: https://www.tradingview.com/script/QKV6z89c-TET-Checklist-Trading-Model/
- type: indicator
- pine_id: PUB;f32ecc5b01ed4e6b879973eceb32dc0b
- version: 1.0

## Description

# TET Checklist — Trading Execution Checklist

TET Checklist is a simple, clean trading checklist designed to help traders confirm their setup before taking a trade.

The checklist contains 6 key conditions:

1. DAILY BIAS
2. 7H CONFIRMATION
3. 1H KEY LEVEL
4. PURGE TIME
5. SMT / PSP / 2SSMT
6. MODEL 1

Each condition can be manually checked directly from the indicator panel. The indicator also provides an automatic setup rating based on the selected checklist conditions.

### Features

• Clean and minimal checklist design
• Manual condition tracking
• A+, A-, A, B+, B-, and C setup ratings
• Light and Dark Mode
• Adjustable checklist size
• Adjustable table position
• Designed for discretionary ICT-style trading workflows
• No traditional indicators required

This tool is intended to help traders maintain discipline and avoid taking trades before their required conditions are confirmed.

Always perform your own analysis and risk management. This indicator does not provide financial advice or guarantee profitable trades.

---

**Publisher:** Abdiqani  Gaahnug

## Source Code

````pine
//@version=6
indicator(title = "TET Checklist Trading Model", overlay = true)

var string GP_LIST = "Checklist"
var string Settings_LIST = "Settings"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHECKLIST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

checktb1 = input.bool(false, "DAILY BIAS", inline = "c01", group = GP_LIST)
checktb2 = input.bool(false, "7H CONFIRMATION", inline = "c02", group = GP_LIST)
checktb3 = input.bool(false, "1H KEY LEVEL", inline = "c03", group = GP_LIST)
checktb4 = input.bool(false, "PURGE TIME", inline = "c04", group = GP_LIST)
checktb5 = input.bool(false, "SMT / PSP / 2SSMT", inline = "c05", group = GP_LIST)
checktb6 = input.bool(false, "MODEL 1", inline = "c06", group = GP_LIST)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

lightMode = input.bool(true, "Light Mode", inline = "theme", group = Settings_LIST)

sizeOpt = input.string(
     "Normal",
     "Checklist Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = Settings_LIST,
     inline = "sz")

posOpt = input.string(
     "Middle Right",
     "Position",
     options = [
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group = Settings_LIST,
     inline = "pos")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIZE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sizeHdr = sizeOpt == "Tiny"   ? size.small :
          sizeOpt == "Small"  ? size.normal :
          sizeOpt == "Normal" ? size.large :
          sizeOpt == "Large"  ? size.huge :
          size.huge

sizeRow = sizeOpt == "Tiny"   ? size.tiny :
          sizeOpt == "Small"  ? size.small :
          sizeOpt == "Normal" ? size.large :
          sizeOpt == "Large"  ? size.huge :
          size.huge

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

posEnum = posOpt == "Top Left"      ? position.top_left :
          posOpt == "Top Center"    ? position.top_center :
          posOpt == "Top Right"     ? position.top_right :
          posOpt == "Middle Left"   ? position.middle_left :
          posOpt == "Middle Center" ? position.middle_center :
          posOpt == "Middle Right"  ? position.middle_right :
          posOpt == "Bottom Left"   ? position.bottom_left :
          posOpt == "Bottom Center" ? position.bottom_center :
          position.bottom_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS / THEME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

banner = "𝗧𝗘𝗧 𝗖𝗵𝗲𝗰𝗸𝗹𝗶𝘀𝘁"

btextcolor = lightMode ? color.black : color.white

baseBg = lightMode
     ? color.new(#F7F9FC, 0)
     : color.new(#14161A, 0)

altBg = lightMode
     ? color.new(#EDF2F7, 0)
     : color.new(#1A1D22, 0)

headerBg = lightMode
     ? color.new(#E2E8F0, 0)
     : color.new(#0E1013, 0)

cardBorder = lightMode
     ? color.new(#CBD5E1, 0)
     : color.new(#2A2F36, 0)

textColor = lightMode
     ? color.new(#1A202C, 0)
     : color.new(#DFE3EA, 0)

iconOn = lightMode
     ? color.new(#2F855A, 0)
     : color.new(#3DDC84, 0)

iconOff = lightMode
     ? color.new(#A0AEC0, 0)
     : color.new(#6C7483, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

visibleRows = 6

var int totalRows = 1 + visibleRows + 1

var table myTable = table.new(
     position = position.middle_right,
     columns = 2,
     rows = totalRows,
     border_width = 2,
     border_color = cardBorder,
     frame_width = 2,
     frame_color = cardBorder)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHECKLIST STATES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool c1 = checktb1
bool c2 = checktb2
bool c3 = checktb3
bool c4 = checktb4
bool c5 = checktb5
bool c6 = checktb6

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RATING LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int countWithoutHTF =
     (c1 ? 1 : 0) +
     (c2 ? 1 : 0) +
     (c3 ? 1 : 0) +
     (c4 ? 1 : 0) +
     (c6 ? 1 : 0)

bool isAPlus =
     c1 and c2 and c3 and c4 and c5 and c6

bool isAMinus =
     c1 and c2 and c4 and c5 and c6

bool isBPlus =
     c4 and c5 and c6

bool isBMinus =
     c4 and c5

bool isC =
     c4

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RATING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string rating =
     isAPlus ? "A+" :
     isAMinus ? "A-" :
     (not c5 and countWithoutHTF == 5) ? "A" :
     (c1 and c2 and c3 and c4 and not c5 and not c6) ? "B-" :
     (not c5 and countWithoutHTF == 4) ? "B+" :
     isBPlus ? "B+" :
     isBMinus ? "B-" :
     isC ? "C" :
     "N/A"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RATING COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color ratingBg =
     rating == "A+" ? color.new(#15803D, 0) :
     rating == "A-" ? color.new(#22C55E, 0) :
     rating == "A"  ? color.new(#22C55E, 0) :
     rating == "B+" ? color.new(#D4B800, 0) :
     rating == "B-" ? color.new(#E88C00, 0) :
     rating == "C"  ? color.new(#CC2F2F, 0) :
     color.new(#6B7280, 0)

color ratingText =
     lightMode ? color.new(#FFFFFF, 0) : color.white

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast

    table.set_position(myTable, posEnum)

    table.clear(myTable, 0, 0, 1, totalRows - 1)

    // HEADER
    string headerTxt = "  " + banner + "  "

    table.cell(
         myTable,
         0,
         0,
         text = headerTxt,
         text_size = sizeHdr,
         text_color = btextcolor,
         bgcolor = headerBg)

    table.merge_cells(myTable, 0, 0, 1, 0)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ROWS
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    for i = 1 to visibleRows

        bool checked = switch i
            1 => checktb1
            2 => checktb2
            3 => checktb3
            4 => checktb4
            5 => checktb5
            6 => checktb6

        string rowText = switch i
            1 => "DAILY BIAS"
            2 => "7H CONFIRMATION"
            3 => "1H KEY LEVEL"
            4 => "PURGE TIME"
            5 => "SMT / PSP / 2SSMT"
            6 => "MODEL 1"

        color rowBg =
             (i % 2 == 1)
             ? baseBg
             : altBg

        color iconColor =
             checked
             ? iconOn
             : iconOff

        string icon =
             checked
             ? "✔"
             : "○"

        table.cell(
             myTable,
             0,
             i,
             text = icon,
             text_size = sizeRow,
             text_color = iconColor,
             bgcolor = rowBg)

        table.cell(
             myTable,
             1,
             i,
             text = "  " + rowText,
             text_size = sizeRow,
             text_color = textColor,
             bgcolor = rowBg)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // RATING
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    int rRow = visibleRows + 1

    string rText =
         "  Rating: " + rating + "  "

    table.cell(
         myTable,
         0,
         rRow,
         text = rText,
         text_size = rating == "N/A" ? sizeRow : sizeHdr,
         text_color = ratingText,
         bgcolor = ratingBg)

    table.merge_cells(
         myTable,
         0,
         rRow,
         1,
         rRow)
````
