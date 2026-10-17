# Watermark

- url: https://www.tradingview.com/script/fbPDuIZq-Watermark/
- type: indicator
- pine_id: PUB;6c3e0c791d8e4e74aac7a37f5c8abb63
- version: 1.0

## Description

a script that allows you to add a watermark, so people can see its actually your chart displaying your name timeframe and date

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tresenior4

//@version=6
indicator("Watermark", overlay=true)

// === TIMEFRAME CLEAN FORMAT ===
tf_raw = timeframe.period

tf =
     tf_raw == "1"   ? "1m"  :
     tf_raw == "3"   ? "3m"  :
     tf_raw == "5"   ? "5m"  :
     tf_raw == "15"  ? "15m" :
     tf_raw == "30"  ? "30m" :
     tf_raw == "60"  ? "1H"  :
     tf_raw == "120" ? "2H"  :
     tf_raw == "240" ? "4H"  :
     tf_raw == "D"   ? "1D"  :
     tf_raw == "W"   ? "1W"  :
     tf_raw == "M"   ? "1M"  :
     tf_raw

// === DATE (MM/DD/YY) ===
month_ = str.tostring(month, "00")
day_   = str.tostring(dayofmonth, "00")
year_  = str.tostring(year % 100, "00")

dateText = month_ + "/" + day_ + "/" + year_
bottomText = "TF: " + tf + " | " + dateText

// === TABLES ===
var table topTable = table.new(position.top_center, 1, 6)
var table bottomTable = table.new(position.bottom_center, 1, 4)

// === UPDATE ===
if barstate.islast
    // TOP TABLE (push text LOWER by using row 3)
    table.cell(topTable, 0, 0, "")
    table.cell(topTable, 0, 1, "")
    table.cell(topTable, 0, 2, "")
    table.cell(topTable, 0, 3, "TRETRADES",
        text_color=color.white,
        text_size=size.large)
    table.cell(topTable, 0, 4, "")
    table.cell(topTable, 0, 5, "")

    // BOTTOM TABLE (unchanged)
    table.cell(bottomTable, 0, 0, "")
    table.cell(bottomTable, 0, 1, bottomText,
        text_color=color.white,
        text_size=size.normal)
    table.cell(bottomTable, 0, 2, "")
````
