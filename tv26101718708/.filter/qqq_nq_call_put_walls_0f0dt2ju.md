# QQQ -> NQ Call / Put Walls

- url: https://www.tradingview.com/script/0F0dT2JU-QQQ-NQ-Call-Put-Walls/
- type: indicator
- pine_id: PUB;c74d8ddbce1f485ca78a8ec033654d29
- version: 1.0

## Description

### QQQ → NQ Call & Put Wall Converter

This indicator converts **QQQ options call and put wall levels into equivalent NQ levels** using the previous day's closing prices of QQQ and NQ.

Enter a QQQ wall price, select whether it is a **Call Wall or Put Wall**, and choose the wall strength. The indicator automatically converts the QQQ level to NQ and plots the corresponding wall zone directly on your NQ chart.

### Features

* **Automatic QQQ → NQ conversion**

  * Uses the previous day's QQQ and NQ closes.
  * Conversion is calculated dynamically from the relative prices of QQQ and NQ.

* **Call & Put Walls**

  * Enter any QQQ options wall level.
  * Select **Call Wall** or **Put Wall**.
  * Call and put walls are visually distinguished on the chart.

* **Wall Strength**

  * **Normal:** 10–15 NQ points
  * **Strong:** 15–20 NQ points
  * **Big:** 20–30 NQ points

* **Multiple Walls**

  * Supports multiple call and put wall levels simultaneously.
  * Each wall displays its original QQQ level and converted NQ level.

* **Automatic Previous-Day Conversion**

  * The conversion ratio updates automatically using the previous trading day's closing prices.

### Example

If QQQ has

## Source Code

````pine
//@version=6
indicator("QQQ → NQ Call / Put Walls", overlay=true, max_boxes_count=50, max_labels_count=50)

//────────────────────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────────────────────

groupWall1 = "Wall 1"

enableWall1 = input.bool(true, "Enable Wall 1", group=groupWall1)

qqqWall1 = input.float(730.0, "QQQ Wall Price", step=0.01, group=groupWall1)

wallType1 = input.string(
     "Call",
     "Wall Type",
     options=["Call", "Put"],
     group=groupWall1)

strength1 = input.string(
     "Normal",
     "Wall Strength",
     options=["Normal", "Strong", "Big"],
     group=groupWall1)

groupWall2 = "Wall 2"

enableWall2 = input.bool(false, "Enable Wall 2", group=groupWall2)

qqqWall2 = input.float(730.0, "QQQ Wall Price", step=0.01, group=groupWall2)

wallType2 = input.string(
     "Put",
     "Wall Type",
     options=["Call", "Put"],
     group=groupWall2)

strength2 = input.string(
     "Normal",
     "Wall Strength",
     options=["Normal", "Strong", "Big"],
     group=groupWall2)

groupWall3 = "Wall 3"

enableWall3 = input.bool(false, "Enable Wall 3", group=groupWall3)

qqqWall3 = input.float(730.0, "QQQ Wall Price", step=0.01, group=groupWall3)

wallType3 = input.string(
     "Call",
     "Wall Type",
     options=["Call", "Put"],
     group=groupWall3)

strength3 = input.string(
     "Normal",
     "Wall Strength",
     options=["Normal", "Strong", "Big"],
     group=groupWall3)


//────────────────────────────────────────────────────────────
// PREVIOUS DAY CLOSES
//────────────────────────────────────────────────────────────

// QQQ previous daily close
qqqPrevClose = request.security(
     "NASDAQ:QQQ",
     "D",
     close[1],
     lookahead=barmerge.lookahead_on)

// NQ previous daily close
nqPrevClose = request.security(
     "CME_MINI:NQ1!",
     "D",
     close[1],
     lookahead=barmerge.lookahead_on)


//────────────────────────────────────────────────────────────
// QQQ → NQ CONVERSION
//────────────────────────────────────────────────────────────

conversionRatio = nqPrevClose / qqqPrevClose

qqqToNQ(qqqPrice) =>
    qqqPrice * conversionRatio


//────────────────────────────────────────────────────────────
// WALL RANGE
//────────────────────────────────────────────────────────────

// Returns the maximum distance from the wall level.
// Example:
// Normal = 15
// Strong = 20
// Big = 30
wallDistance(strength) =>
    strength == "Normal" ? 15.0 :
     strength == "Strong" ? 20.0 :
     30.0


//────────────────────────────────────────────────────────────
// WALL LEVELS
//────────────────────────────────────────────────────────────

nqWall1 = qqqToNQ(qqqWall1)
nqWall2 = qqqToNQ(qqqWall2)
nqWall3 = qqqToNQ(qqqWall3)


//────────────────────────────────────────────────────────────
// DRAW WALL FUNCTION
//────────────────────────────────────────────────────────────

drawWall(enabled, nqLevel, qqqLevel, wallType, strength) =>

    if enabled and barstate.islast

        distance = wallDistance(strength)

        upper = nqLevel + distance
        lower = nqLevel - distance

        // Call / Put colors
        wallColor = wallType == "Call" ? color.green : color.red

        // Zone
        box.new(
             left=bar_index - 100,
             top=upper,
             right=bar_index + 20,
             bottom=lower,
             bgcolor=color.new(wallColor, 88),
             border_color=color.new(wallColor, 35))

        // Center line
        line.new(
             x1=bar_index - 100,
             y1=nqLevel,
             x2=bar_index + 20,
             y2=nqLevel,
             color=wallColor,
             width=2,
             style=line.style_dashed)

        // Label
        labelText =
             wallType + " WALL\n" +
             "QQQ: " + str.tostring(qqqLevel, "#.##") + "\n" +
             "NQ: " + str.tostring(nqLevel, "#.##") + "\n" +
             strength + " (" + str.tostring(distance) + " pts)"

        label.new(
             x=bar_index + 2,
             y=nqLevel,
             text=labelText,
             style=label.style_label_left,
             color=wallColor,
             textcolor=color.white,
             size=size.small)


//────────────────────────────────────────────────────────────
// DRAW
//────────────────────────────────────────────────────────────

if barstate.islast

    drawWall(
         enableWall1,
         nqWall1,
         qqqWall1,
         wallType1,
         strength1)

    drawWall(
         enableWall2,
         nqWall2,
         qqqWall2,
         wallType2,
         strength2)

    drawWall(
         enableWall3,
         nqWall3,
         qqqWall3,
         wallType3,
         strength3)


//────────────────────────────────────────────────────────────
// CONVERSION INFO
//────────────────────────────────────────────────────────────

var table infoTable = table.new(
     position.top_right,
     2,
     4,
     border_width=1)

if barstate.islast

    table.cell(
         infoTable,
         0,
         0,
         "QQQ → NQ",
         bgcolor=color.gray,
         text_color=color.white)

    table.cell(
         infoTable,
         1,
         0,
         "Value",
         bgcolor=color.gray,
         text_color=color.white)

    table.cell(
         infoTable,
         0,
         1,
         "QQQ Prev Close",
         text_color=color.white)

    table.cell(
         infoTable,
         1,
         1,
         str.tostring(qqqPrevClose, "#.##"),
         text_color=color.white)

    table.cell(
         infoTable,
         0,
         2,
         "NQ Prev Close",
         text_color=color.white)

    table.cell(
         infoTable,
         1,
         2,
         str.tostring(nqPrevClose, "#.##"),
         text_color=color.white)

    table.cell(
         infoTable,
         0,
         3,
         "Conversion Ratio",
         text_color=color.white)

    table.cell(
         infoTable,
         1,
         3,
         str.tostring(conversionRatio, "#.####"),
         text_color=color.white)
````
