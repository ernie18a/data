# LTL

- url: https://www.tradingview.com/script/sUrQMqVf-LTL/
- type: indicator
- pine_id: PUB;e2a963bccee245ea92d61d6a59aa0a76
- version: 1.0

## Description

This script will determine where on the chart a price level was last hit.   It will display the time and date of the last hit by price in the upper right hand corner of your chart

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mdmiles125

//@version=5
indicator("Accurate Last Touch Detector", overlay=true)

// =====================================
// USER INPUT
// =====================================
level = input.float(5800.00, "Price Level")

// =====================================
// TOUCH DETECTION
// =====================================
touched = low <= level and high >= level

// Store exact last touch bar
var int lastTouchBar = na

if touched
    lastTouchBar := bar_index

// =====================================
// TRUE BARS AGO
// =====================================
barsAgo = na(lastTouchBar)
     ? na
     : bar_index - lastTouchBar

// =====================================
// PLOT LEVEL
// =====================================
plot(
     level,
     title="Tracked Level",
     color=color.yellow,
     linewidth=2)

// =====================================
// TOUCH LABEL
// =====================================
var label touchLbl = na

if touched
    label.delete(touchLbl)

    touchLbl := label.new(
         bar_index,
         level,
         "TOUCH",
         style=label.style_circle,
         color=color.red,
         textcolor=color.white,
         size=size.normal)

// =====================================
// INFO LABEL
// =====================================
var label infoLbl = na

if barstate.islast

    label.delete(infoLbl)

    infoText = na(barsAgo)
         ? "Never Touched"
         : "Last Touch: " + str.tostring(barsAgo) + " Bars Ago"

    infoLbl := label.new(
         bar_index,
         level,
         infoText,
         style=label.style_label_right,
         color=color.black,
         textcolor=color.yellow,
         size=size.large)

// =====================================
// DATE/TIME TABLE
// =====================================
var table t = table.new(position.top_right, 1, 1, border_width=2)

if barstate.islast

    if not na(lastTouchBar)

        // Dynamic bars ago
        offset = bar_index - lastTouchBar

        // Accurate timestamp
        dateText = str.format(
             "{0,date,MM/dd/yyyy HH:mm}",
             time[offset])

        // Display table
        table.cell(
             t,
             0,
             0,
             "LAST TOUCH\n\n" +
             str.tostring(offset) + " Bars Ago\n\n" +
             dateText,
             text_size=size.large,
             text_color=color.yellow,
             bgcolor=color.black)

    else

        table.cell(
             t,
             0,
             0,
             "PRICE NEVER TOUCHED",
             text_size=size.large,
             text_color=color.red,
             bgcolor=color.black)
````
