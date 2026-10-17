# MarketMind Lite by MarcOne_Dj 

- url: https://www.tradingview.com/script/nZtDbCJI/
- type: indicator
- pine_id: PUB;c33b1aff76fa49619dad8e5ae5ea402d
- version: 2.0

## Description

A script that allows you to display the values ​​entered into an input variable on the graph.
The input structure must be as follows:

ES
7474.25 CALL
7469.25 PUT 
7459.25 PUT 
7444.25 PUT
7424.00 CALL 
7419.00 PUT 
7399.00 CALL
7394.00 FLIP
7323.75 CALL

NQ
29808.75 PUT 
29685.00 PUT 
29478.75 PUT
29313.75 CALL
29231.00 CALL 
28901.00 CALL 
28694.75 FLIP

## Source Code

````pine
//@version=6
indicator("MarketMind Lite by MarcOne_Dj ", overlay = true, max_lines_count = 500, max_labels_count = 500)

//====================================================
// INPUT TESTO UNICO
//=================================================

txt = input.text_area("",title = "Paste ES / NQ Levels")

//====================================================
// RICONOSCIMENTO MERCATO
//====================================================

symbol = str.upper(syminfo.root)

isES =
     str.contains(symbol, "ES") or
     str.contains(symbol, "MES")

isNQ =
     str.contains(symbol, "NQ") or
     str.contains(symbol, "MNQ")

//====================================================
// ORARI
//====================================================

startTime = timestamp(year, month, dayofmonth, 00, 00)
endTime   = timestamp(year, month, dayofmonth, 23, 00)

//====================================================
// FUNZIONE DISEGNO
//====================================================

drawLevel(price, levelType) =>

    col =
         levelType == "CALL" ? color.lime :
         levelType == "PUT"  ? color.red :
         levelType == "FLIP" ? color.blue :
         color.gray

    line.new(
         x1 = startTime,
         y1 = price,
         x2 = endTime,
         y2 = price,
         xloc = xloc.bar_time,
         extend = extend.none,
         color = col,
         width = 2
     )

    label.new(
         x = endTime,
         y = price,
         text = levelType + " " + str.tostring(price),
         xloc = xloc.bar_time,
         style = label.style_label_left,
         color = col,
         textcolor = color.white,
         size = size.small
     )

//====================================================
// PARSE TESTO
//====================================================

rows = str.split(txt, "\n")

currentSection = ""

if barstate.islast

    for i = 0 to array.size(rows) - 1

        row = str.trim(array.get(rows, i))
        rowUpper = str.upper(row)

        // Detect section
        if rowUpper == "ES"
            currentSection := "ES"

        else if rowUpper == "NQ"
            currentSection := "NQ"

        else

            useRow =
                 (isES and currentSection == "ES") or
                 (isNQ and currentSection == "NQ")

            if useRow and str.length(row) > 0

                parts = str.split(row, " ")

                if array.size(parts) >= 2

                    priceStr = array.get(parts, 0)
                    typeStr  = str.upper(array.get(parts, 1))

                    price = str.tonumber(priceStr)

                    if not na(price)
                        drawLevel(price, typeStr)
````
