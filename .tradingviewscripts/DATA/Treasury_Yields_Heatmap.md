<!-- tradingview-pine-id: PUB;e97de1097baa400aa6770ff5c3a7d168 -->
<!-- tradingviewscripts-format: 1 -->
# Treasury Yields Heatmap

Source: https://www.tradingview.com/script/Y6x4NEm5-Treasury-Yields-Heatmap-By-MUQWISHI/

## Description

▋ INTRODUCTION :
The “Treasury Yields Heatmap” generates a dynamic heat map table, showing treasury yield bond values corresponding with dates. In the last column, it presents the status of the yield curve, discerning whether it’s in a normal, flat, or inverted configuration, which determined by using Pearson's linear regression coefficient. This tool is built to offer traders essential insights for effectively tracking bond values and monitoring yield curve status, featuring the flexibility to input a starting period, timeframe, and select from a range of major countries' bond data.

_______________________
▋ OVERVIEW:
[image]https://www.tradingview.com/x/M8W0xcfu/[/image]

______________________
▋ YIELD CURVE:
It is determined through Pearson's linear regression coefficient and considered…

[*]R ≥ 0.7 → Normal
[*]0.7 > R ≥ 0.35  → Slight Normal
[*]0.35 > R > -0.35  → Flat
[*]-0.35 ≥ R > -0.7  → Slight Inverted
[*]-0.7 ≥ R → Inverted

_______________________
▋ INDICATOR SETTINGS:
#Section One: Table Setting
[image]https://www.tradingview.com/x/AOVPNGSl/[/image]

#Section Two: Technical Setting
[image]https://www.tradingview.com/x/WfgFga3t/[/image]
(1) Country: Select country’s treasury yields data
(2) Timeframe: Time interval.
(3) Fetch By:
 (3A) Date: Retrieve data by beginning of date.
 (3B) Period: Retrieve data by specifying the number of time series back.

Enjoy. Please let me know if you have any questions.
Thank you.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MUQWISHI

//@version=6
indicator("Treasury Yields Heatmap", overlay = true)
import MUQWISHI/colorLab/2 as cl 

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                   INPUT                                    |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// +++++++++++++++ Table Settings
var G1 = "Table Settings"
// Location 
tblPos = input.string("Middle Right", "Location ", 
             ["Top Right" , "Middle Right"  , "Bottom Right" , 
              "Top Center", "Middle Center" , "Bottom Center", 
              "Top Left"  , "Middle Left"   , "Bottom Left" ], inline = "1", group = G1, display = display.none)

// Size
tblSiz = input.int(10, " Size", 0, inline = "1", group = G1, display = display.none)

// Table Color
tBgCol = input.color(#696969, "Title ",  group = G1, inline = "3", display = display.none)

upCol  = input.color(#006400, "     Cell ",   group = G1, inline = "3", display = display.none)
mdCol  = input.color(#FFEF00, "",       group = G1, inline = "3", display = display.none)
dnCol  = input.color(#882336, "",       group = G1, inline = "3", display = display.none)

// +++++++++++++++ Technical Setting
var G2 = "Technical Settings"
contry = input.string("United States", "Country", ["Australia", "Brazil", "Canada", "China", "Euro", "France", "Germany",
 "India", "Indonesia", "Italy", "Japan", "Russia", "South Africa", "South Korea", "United Kingdom", "United States"], group = G2, display = display.none)
 
timFrm = input.string("Quarterly", "Timeframe", ["Yearly", "Quarterly", "Monthly", "Weekly", "Daily"],                group = G2, display = display.none)
calMod = input.string("Period", "Fetch By", ["Date", "Period"],                                                       group = G2, display = display.none)
sDate  = input.time(timestamp("01 Jan 2019 00:00"), " ‣ Date", active = calMod == "Date",                             group = G2, display = display.none)
sPerd  = input.int(25, " ‣ Period", 1, 200, active = calMod == "Period",                                              group = G2, display = display.none)

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                 CALCULATION                                |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
type BondState 
    array<string>   TITLE
    array<int>      DATE    // Date 
    matrix<float>   VALUES  
    array<float>    YIELD 

var tf = switch timFrm 
    "Yearly"         => "12M"
    "Quarterly"      => "3M" 
    "Monthly"        => "1M" 
    "Weekly"         => "1W"
    => "1D"

var countryCode = switch contry 
    "United States"  => "US" 
    "Euro"           => "EU"
    "United Kingdom" => "GB"
    "Germany"        => "DE" 
    "France"         => "FR"
    "Italy"          => "IT"
    "Canada"         => "CA"
    "Japan"          => "JP"
    "India"          => "IN"
    "China"          => "CN"
    "Indonesia"      => "ID"
    "Australia"      => "AU"
    "Brazil"         => "BR"
    "Russia"         => "RU"
    "South Korea"    => "KR"
    "South Africa"   => "ZA"
    "Turkey"         => "TR"


method pearson(BondState this) =>
    VALUES = this.VALUES 
    YIELD  = this.YIELD

    for element in VALUES 

        n = 0, ySum = 0.0
        for v in element
            if not na(v)
                ySum += v
                n    += 1

        if n < 4
            YIELD.push(float(na))

        else
            xMean = (n - 1) * 0.5
            yMean = ySum / n

            xy = 0.0, xx = 0.0, yy = 0.0

            idx = 0
            for v in element
                if not na(v)
                    dx = idx - xMean,   dy  = v - yMean
                    xy += dx * dy,      xx += dx * dx,      yy += dy * dy
                    idx += 1

            YIELD.push(xy / math.sqrt(xx * yy))


main() =>
    var cls = array.new<float>(na)
    var tim = array.new<int>(na)
    
    if calMod == "Date" ? time >= sDate : true
        cls.unshift(math.round_to_mintick(close)) 
        tim.unshift(time_close)

    if calMod == "Date" ? cls.size() > 200 : cls.size() > sPerd
        cls.pop(), tim.pop()
   
    [cls, tim]


np(array<int> a)=> 
    na(a) ? 0 : a.size()


evaluateArray(array<int> a, array<int> maxArr, int minPrd) =>
    array<int> nextMax = maxArr
    int nextMinPrd     = minPrd
    
    if not na(a)
        int prd = int(math.abs(a.get(0) - a.get(-1))) // Avoid using negative index -1 if you meant the second element
        
        if  (np(a) > np(nextMax)) or na(nextMax)
            nextMax    := a
            nextMinPrd := prd

        else if np(a) == np(nextMax)
            if prd < minPrd
                nextMax    := a
                nextMinPrd := prd

    [nextMax, nextMinPrd]


maxDateArray(array<int> a1, array<int> a2, array<int> a3,
             array<int> a4, array<int> a5, array<int> a6,
             array<int> a7, array<int> a8, array<int> a9) =>

    maxArr = array.new<int>(na)
    minPrd = 0

    [_maxArr1, _minPrd1] = evaluateArray(a1, maxArr, minPrd), maxArr := _maxArr1, minPrd := _minPrd1
    [_maxArr2, _minPrd2] = evaluateArray(a2, maxArr, minPrd), maxArr := _maxArr2, minPrd := _minPrd2
    [_maxArr3, _minPrd3] = evaluateArray(a3, maxArr, minPrd), maxArr := _maxArr3, minPrd := _minPrd3
    [_maxArr4, _minPrd4] = evaluateArray(a4, maxArr, minPrd), maxArr := _maxArr4, minPrd := _minPrd4
    [_maxArr5, _minPrd5] = evaluateArray(a5, maxArr, minPrd), maxArr := _maxArr5, minPrd := _minPrd5
    [_maxArr6, _minPrd6] = evaluateArray(a6, maxArr, minPrd), maxArr := _maxArr6, minPrd := _minPrd6
    [_maxArr7, _minPrd7] = evaluateArray(a7, maxArr, minPrd), maxArr := _maxArr7, minPrd := _minPrd7
    [_maxArr8, _minPrd8] = evaluateArray(a8, maxArr, minPrd), maxArr := _maxArr8, minPrd := _minPrd8
    [_maxArr9, _minPrd9] = evaluateArray(a9, maxArr, minPrd), maxArr := _maxArr9, minPrd := _minPrd9

    maxArr


method addClm(BondState this, array<float> src, array<int> tim, string label) =>
    TITLE = this.TITLE
    DATE  = this.DATE

    if not na(src)
        newCol = array.new<float>(na)
        TITLE.unshift(label)
        for element in DATE 
            indx = tim.indexof(element)
            if indx >= 0
                newCol.push(src.get(indx))
            else 
                newCol.push(float(na))

        if newCol.size() > 0 
            this.VALUES.add_col(0, newCol)

// Security Function
[mn01, tmn01]  = request.security(countryCode + "01MY", tf, main(), ignore_invalid_symbol = true)
[mn03, tmn03]  = request.security(countryCode + "03MY", tf, main(), ignore_invalid_symbol = true)
[mn06, tmn06]  = request.security(countryCode + "06MY", tf, main(), ignore_invalid_symbol = true)
[yr01, tyr01]  = request.security(countryCode +  "01Y", tf, main(), ignore_invalid_symbol = true)
[yr03, tyr03]  = request.security(countryCode +  "03Y", tf, main(), ignore_invalid_symbol = true)
[yr05, tyr05]  = request.security(countryCode +  "05Y", tf, main(), ignore_invalid_symbol = true)
[yr07, tyr07]  = request.security(countryCode +  "07Y", tf, main(), ignore_invalid_symbol = true)
[yr10, tyr10]  = request.security(countryCode +  "10Y", tf, main(), ignore_invalid_symbol = true)
[yr30, tyr30]  = request.security(countryCode +  "30Y", tf, main(), ignore_invalid_symbol = true)

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                   TABLE                                    |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// Get Tbale Location
var position = str.replace_all(str.lower(tblPos), " ", "_")

// Create tbl 
var table tbl = na 

// Get Yield Rate
rateYield(x) =>
    x  >=  0.7 ? "Normal"   : x <  0.7 and x >=  0.35 ? "Slight Normal"   :
     x <= -0.7 ? "Inverted" : x > -0.7 and x <= -0.35 ? "Slight Inverted" : "Flat"

// Get Time Format
timeFormat(x) =>
    t = int(x)
    if timFrm == "Yearly"
        str.format_time(t, "yyyy")
    else if timFrm == "Quarterly" or timFrm == "Monthly"
        str.format_time(t, "MMM-yyyy")
    else 
        str.format_time(t, "dd-MMM-yyyy")

// Build a Cell
cell(col, row, txt, color, tip = "") => 
    tbl.cell(col, row, txt, 0, 0, cl.textColor(color), bgcolor = color, text_size = tblSiz, tooltip = tip)


if barstate.islast
    // +++++++ Clean & Prepare Output
    // Find Date Column
    maxArr   = maxDateArray(tmn01, tmn03, tmn06, tyr01, tyr03, tyr05, tyr07, tyr10, tyr30)

    // Define Treasure 
    treasure = BondState.new(array.new<string>(na), array.new<int>(na), matrix.new<float>(na, na, na), array.new<float>(na))

    // Fill Treasure
    if not na(maxArr)
        treasure.DATE := maxArr
        DATE = treasure.DATE
        
        treasure.addClm(yr30, tyr30, "30Yr"), treasure.addClm(yr10, tyr10, "10Yr"), treasure.addClm(yr07, tyr07,  "7Yr"), 
        treasure.addClm(yr05, tyr05,  "5Yr"), treasure.addClm(yr03, tyr03,  "3Yr"), treasure.addClm(yr01, tyr01,  "1Yr"),
        treasure.addClm(mn06, tmn06,  "6Mo"), treasure.addClm(mn03, tmn03,  "3Mo"), treasure.addClm(mn01, tmn01,  "1Mo"),

        treasure.pearson()
        treasure.TITLE.unshift("Date")
        treasure.TITLE.push("Yield Curve")

        
    // +++++++ Build a Table
    if treasure.VALUES.rows() > 0 
        DATE   = treasure.DATE
        TITLE  = treasure.TITLE
        VALUES = treasure.VALUES
        YIELD  = treasure.YIELD

        clms   = TITLE.size()
        tbl.delete()
        tbl := table.new(position, clms, VALUES.rows() + 3, 
                         frame_width  = 1, frame_color  = #000000, 
                         border_width = 1, border_color = #000000)
        
        // Timeframe NOTE
        r = 0
        if timeframe.period != tf
            cell(0, r, '⚠️ Recommended: Set the chart timeframe to «' + tf + '» for best results.', color.red)
            tbl.merge_cells(0, r, clms - 1, r)
            r += 1

        // Title 
        cell(0, r, (str.contains(contry, " ") ? "The ": "") + contry + " Treasury Yields " + timFrm 
                 + " Intervals: " + timeFormat(DATE.get(-1)) +" To "+ timeFormat(DATE.get(0)), tBgCol)
        tbl.merge_cells(0, r, clms - 1, r), r += 1

        // HEADER
        for i = 0 to TITLE.size() - 1
            cell(i, r, TITLE.get(i), tBgCol)
        r += 1

        // VALUES 
        maxVALUE = VALUES.max()
        minVALUE = VALUES.min()
        avgVALUE = VALUES.avg()

        dateINDX = TITLE.indexof("Date")
        curvINDX = TITLE.indexof("Yield Curve")

        for [i, val] in DATE
            // Date 
            cell(dateINDX, r, timeFormat(val), tBgCol)

            // Values
            c = 1
            for j = 0 to VALUES.columns() - 1
                VALUE = VALUES.get(i, j)
                VALUE_COL = na(VALUE) ? tBgCol : cl.heatmap(VALUE, minVALUE, avgVALUE, maxVALUE, dnCol, mdCol, upCol)
                cell(c , r, na(VALUE) ? "" : str.tostring(VALUES.get(i, j), "0.000") + "%", VALUE_COL)
                c += 1

            // Yield Curve 
            YIELD_VAL = YIELD.get(i)
            YIELD_COL = na(YIELD_VAL) ? tBgCol : cl.heatmap(YIELD_VAL, -1, 0, 1, dnCol, mdCol, upCol)
            cell(curvINDX, r, rateYield(YIELD_VAL), YIELD_COL)
            
            r += 1
````
