# Sector Strength Dashboard - Public

- url: https://www.tradingview.com/script/kPrnSVQm-Sector-Strength-Dashboard-Public/
- type: indicator
- pine_id: PUB;9562d30e1c7d420fac95b66822abbdbd
- version: 2.0

## Description

Track Intraday Sectors 

Uses Relative Strength to find action in sectors

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TEJAS_PATIL_

//@version=6
indicator("Sector Strength Dashboard", overlay=true)

data_tf = input.string("1",title = "Sector Analysis Timeframe", options = ["1","3","5"])
darkMode = input.bool(true, "Dark Mode")
bars1h =data_tf == "1" ? 60 :data_tf == "3" ? 20 :12
bars15m =data_tf == "1" ? 15 :data_tf == "3" ? 5 :3
newDay = ta.change(time("D")) != 0
sortBy = input.string("1H RS","Sort By",options = ["Day RS", "1H RS", "15m RS"])


//--------------------------------------------------
// Benchmark
//--------------------------------------------------
niftyClose        = request.security("NIFTY", data_tf, close)
nifty1h  = (niftyClose / niftyClose[bars1h] - 1) * 100
nifty15m = (niftyClose / niftyClose[bars15m] - 1) * 100


//--------------------------------------------------
// Sector .
//--------------------------------------------------

pvtbankClose      = request.security("NIFTYPVTBANK", data_tf, close)
psubankClose      = request.security("CNXPSUBANK", data_tf, close)
financeClose      = request.security("CNXFINANCE", data_tf, close)
capmktClose       = request.security("NIFTY_CAPITAL_MKT", data_tf, close)
itClose           = request.security("CNXIT", data_tf, close)
fmcgClose         = request.security("CNXFMCG", data_tf, close)
pharmaClose       = request.security("CNXPHARMA", data_tf, close)
metalClose        = request.security("CNXMETAL", data_tf, close)
energyClose       = request.security("CNXENERGY", data_tf, close)
oilgasClose       = request.security("NIFTY_OIL_AND_GAS", data_tf, close)
realtyClose       = request.security("CNXREALTY", data_tf, close)
autoClose         = request.security("CNXAUTO", data_tf, close)
defenceClose      = request.security("NIFTY_IND_DEFENCE", data_tf, close)
chemClose         = request.security("NIFTY_CHEMICALS", data_tf, close)
capitalGoodsClose = request.security("CG", data_tf, close)
consumerClose     = request.security("NIFTY_CONSR_DURBL", data_tf, close)
railwayClose      = request.security("NIFTY_RAILWAYSPSU", data_tf, close)
cementClose       = request.security("NIFTY_CEMENT", data_tf, close)
hospitalClose     = request.security("BSHOSP", data_tf, close)

//--------------------------------------------------
// Sector 1D
//--------------------------------------------------
// DAILY OPEN VALUES

niftyDayOpen      = request.security("NIFTY", "D", open)

pvtbankDayOpen      = request.security("NIFTYPVTBANK", "D", open)
psubankDayOpen      = request.security("CNXPSUBANK", "D", open)
financeDayOpen      = request.security("CNXFINANCE", "D", open)
capmktDayOpen       = request.security("NIFTY_CAPITAL_MKT", "D", open)
itDayOpen           = request.security("CNXIT", "D", open)
fmcgDayOpen         = request.security("CNXFMCG", "D", open)
pharmaDayOpen       = request.security("CNXPHARMA", "D", open)
metalDayOpen        = request.security("CNXMETAL", "D", open)
energyDayOpen       = request.security("CNXENERGY", "D", open)
oilgasDayOpen       = request.security("NIFTY_OIL_AND_GAS", "D", open)
realtyDayOpen       = request.security("CNXREALTY", "D", open)
autoDayOpen         = request.security("CNXAUTO", "D", open)
defenceDayOpen      = request.security("NIFTY_IND_DEFENCE", "D", open)
chemDayOpen         = request.security("NIFTY_CHEMICALS", "D", open)
capitalGoodsDayOpen = request.security("CG", "D", open)
consumerDayOpen     = request.security("NIFTY_CONSR_DURBL", "D", open)
railwayDayOpen      = request.security("NIFTY_RAILWAYSPSU", "D", open)
cementDayOpen       = request.security("NIFTY_CEMENT", "D", open)
hospitalDayOpen     = request.security("BSHOSP", "D", open)

//RETURNS OF ALL SECTORS
niftyRet = ((niftyClose / niftyDayOpen) - 1) * 100

pvtbankRet      = ((pvtbankClose      / pvtbankDayOpen)      - 1) * 100
psubankRet      = ((psubankClose      / psubankDayOpen)      - 1) * 100
financeRet      = ((financeClose      / financeDayOpen)      - 1) * 100
capmktRet       = ((capmktClose       / capmktDayOpen)       - 1) * 100
itRet           = ((itClose           / itDayOpen)           - 1) * 100
fmcgRet         = ((fmcgClose         / fmcgDayOpen)         - 1) * 100
pharmaRet       = ((pharmaClose       / pharmaDayOpen)       - 1) * 100
metalRet        = ((metalClose        / metalDayOpen)        - 1) * 100
energyRet       = ((energyClose       / energyDayOpen)       - 1) * 100
oilgasRet       = ((oilgasClose       / oilgasDayOpen)       - 1) * 100
realtyRet       = ((realtyClose       / realtyDayOpen)       - 1) * 100
autoRet         = ((autoClose         / autoDayOpen)         - 1) * 100
defenceRet      = ((defenceClose      / defenceDayOpen)      - 1) * 100
chemRet         = ((chemClose         / chemDayOpen)         - 1) * 100
capitalGoodsRet = ((capitalGoodsClose / capitalGoodsDayOpen) - 1) * 100
consumerRet     = ((consumerClose     / consumerDayOpen)     - 1) * 100
railwayRet      = ((railwayClose      / railwayDayOpen)      - 1) * 100
cementRet       = ((cementClose       / cementDayOpen)       - 1) * 100
hospitalRet     = ((hospitalClose     / hospitalDayOpen)     - 1) * 100

// RS OF ALL SECTORS
pvtbankDayRS      = pvtbankRet      - niftyRet
psubankDayRS      = psubankRet      - niftyRet
financeDayRS      = financeRet      - niftyRet
capmktDayRS       = capmktRet       - niftyRet
itDayRS           = itRet           - niftyRet
fmcgDayRS         = fmcgRet         - niftyRet
pharmaDayRS       = pharmaRet       - niftyRet
metalDayRS        = metalRet        - niftyRet
energyDayRS       = energyRet       - niftyRet
oilgasDayRS       = oilgasRet       - niftyRet
realtyDayRS       = realtyRet       - niftyRet
autoDayRS         = autoRet         - niftyRet
defenceDayRS      = defenceRet      - niftyRet
chemDayRS         = chemRet         - niftyRet
capitalGoodsDayRS = capitalGoodsRet - niftyRet
consumerDayRS     = consumerRet     - niftyRet
railwayDayRS      = railwayRet      - niftyRet
cementDayRS       = cementRet       - niftyRet
hospitalDayRS     = hospitalRet     - niftyRet

//--------------------------------------------------
// Sector 1HR
//--------------------------------------------------
pvtbank1h      = (pvtbankClose      / pvtbankClose[bars1h]      - 1) * 100
psubank1h      = (psubankClose      / psubankClose[bars1h]      - 1) * 100
finance1h      = (financeClose      / financeClose[bars1h]      - 1) * 100
capmkt1h       = (capmktClose       / capmktClose[bars1h]       - 1) * 100
it1h           = (itClose           / itClose[bars1h]           - 1) * 100
fmcg1h         = (fmcgClose         / fmcgClose[bars1h]         - 1) * 100
pharma1h       = (pharmaClose       / pharmaClose[bars1h]       - 1) * 100
metal1h        = (metalClose        / metalClose[bars1h]        - 1) * 100
energy1h       = (energyClose       / energyClose[bars1h]       - 1) * 100
oilgas1h       = (oilgasClose       / oilgasClose[bars1h]       - 1) * 100
realty1h       = (realtyClose       / realtyClose[bars1h]       - 1) * 100
auto1h         = (autoClose         / autoClose[bars1h]         - 1) * 100
defence1h      = (defenceClose      / defenceClose[bars1h]      - 1) * 100
chem1h         = (chemClose         / chemClose[bars1h]         - 1) * 100
capitalGoods1h = (capitalGoodsClose / capitalGoodsClose[bars1h] - 1) * 100
consumer1h     = (consumerClose     / consumerClose[bars1h]     - 1) * 100
railway1h      = (railwayClose      / railwayClose[bars1h]      - 1) * 100
cement1h       = (cementClose       / cementClose[bars1h]       - 1) * 100
hospital1h     = (hospitalClose     / hospitalClose[bars1h]     - 1) * 100

//1HR RS
pvtbankRS1h      = pvtbank1h      - nifty1h
psubankRS1h      = psubank1h      - nifty1h
financeRS1h      = finance1h      - nifty1h
capmktRS1h       = capmkt1h       - nifty1h
itRS1h           = it1h           - nifty1h
fmcgRS1h         = fmcg1h         - nifty1h
pharmaRS1h       = pharma1h       - nifty1h
metalRS1h        = metal1h        - nifty1h
energyRS1h       = energy1h       - nifty1h
oilgasRS1h       = oilgas1h       - nifty1h
realtyRS1h       = realty1h       - nifty1h
autoRS1h         = auto1h         - nifty1h
defenceRS1h      = defence1h      - nifty1h
chemRS1h         = chem1h         - nifty1h
capitalGoodsRS1h = capitalGoods1h - nifty1h
consumerRS1h     = consumer1h     - nifty1h
railwayRS1h      = railway1h      - nifty1h
cementRS1h       = cement1h       - nifty1h
hospitalRS1h     = hospital1h     - nifty1h

//--------------------------------------------------
// Sector 15m
//--------------------------------------------------
pvtbank15m      = (pvtbankClose      / pvtbankClose[bars15m]      - 1) * 100
psubank15m      = (psubankClose      / psubankClose[bars15m]      - 1) * 100
finance15m      = (financeClose      / financeClose[bars15m]      - 1) * 100
capmkt15m       = (capmktClose       / capmktClose[bars15m]       - 1) * 100
it15m           = (itClose           / itClose[bars15m]           - 1) * 100
fmcg15m         = (fmcgClose         / fmcgClose[bars15m]         - 1) * 100
pharma15m       = (pharmaClose       / pharmaClose[bars15m]       - 1) * 100
metal15m        = (metalClose        / metalClose[bars15m]        - 1) * 100
energy15m       = (energyClose       / energyClose[bars15m]       - 1) * 100
oilgas15m       = (oilgasClose       / oilgasClose[bars15m]       - 1) * 100
realty15m       = (realtyClose       / realtyClose[bars15m]       - 1) * 100
auto15m         = (autoClose         / autoClose[bars15m]         - 1) * 100
defence15m      = (defenceClose      / defenceClose[bars15m]      - 1) * 100
chem15m         = (chemClose         / chemClose[bars15m]         - 1) * 100
capitalGoods15m = (capitalGoodsClose / capitalGoodsClose[bars15m] - 1) * 100
consumer15m     = (consumerClose     / consumerClose[bars15m]     - 1) * 100
railway15m      = (railwayClose      / railwayClose[bars15m]      - 1) * 100
cement15m       = (cementClose       / cementClose[bars15m]       - 1) * 100
hospital15m     = (hospitalClose     / hospitalClose[bars15m]     - 1) * 100

//15M RS
pvtbankRS15m      = pvtbank15m      - nifty15m
psubankRS15m      = psubank15m      - nifty15m
financeRS15m      = finance15m      - nifty15m
capmktRS15m       = capmkt15m       - nifty15m
itRS15m           = it15m           - nifty15m
fmcgRS15m         = fmcg15m         - nifty15m
pharmaRS15m       = pharma15m       - nifty15m
metalRS15m        = metal15m        - nifty15m
energyRS15m       = energy15m       - nifty15m
oilgasRS15m       = oilgas15m       - nifty15m
realtyRS15m       = realty15m       - nifty15m
autoRS15m         = auto15m         - nifty15m
defenceRS15m      = defence15m      - nifty15m
chemRS15m         = chem15m         - nifty15m
capitalGoodsRS15m = capitalGoods15m - nifty15m
consumerRS15m     = consumer15m     - nifty15m
railwayRS15m      = railway15m      - nifty15m
cementRS15m       = cement15m       - nifty15m
hospitalRS15m     = hospital15m     - nifty15m

//--------------------------------------------------
// array pushing
//--------------------------------------------------
var names = array.new_string()

var dayRS = array.new_float()
var rs1h = array.new_float()
var rs15m = array.new_float()

array.clear(names)

array.clear(dayRS)
array.clear(rs1h)
array.clear(rs15m)

array.push(names, "Pvt Bank")
array.push(dayRS, pvtbankDayRS)
array.push(rs1h, pvtbankRS1h)
array.push(rs15m, pvtbankRS15m)

array.push(names, "PSU Bank")
array.push(dayRS, psubankDayRS)
array.push(rs1h, psubankRS1h)
array.push(rs15m, psubankRS15m)

array.push(names, "Finance")
array.push(dayRS, financeDayRS)
array.push(rs1h, financeRS1h)
array.push(rs15m, financeRS15m)

array.push(names, "Capital Mkt")
array.push(dayRS, capmktDayRS)
array.push(rs1h, capmktRS1h)
array.push(rs15m, capmktRS15m)

array.push(names, "IT")
array.push(dayRS, itDayRS)
array.push(rs1h, itRS1h)
array.push(rs15m, itRS15m)

array.push(names, "FMCG")
array.push(dayRS, fmcgDayRS)
array.push(rs1h, fmcgRS1h)
array.push(rs15m, fmcgRS15m)

array.push(names, "Pharma")
array.push(dayRS, pharmaDayRS)
array.push(rs1h, pharmaRS1h)
array.push(rs15m, pharmaRS15m)

array.push(names, "Metal")
array.push(dayRS, metalDayRS)
array.push(rs1h, metalRS1h)
array.push(rs15m, metalRS15m)

array.push(names, "Energy")
array.push(dayRS, energyDayRS)
array.push(rs1h, energyRS1h)
array.push(rs15m, energyRS15m)

array.push(names, "Oil & Gas")
array.push(dayRS, oilgasDayRS)
array.push(rs1h, oilgasRS1h)
array.push(rs15m, oilgasRS15m)

array.push(names, "Realty")
array.push(dayRS, realtyDayRS)
array.push(rs1h, realtyRS1h)
array.push(rs15m, realtyRS15m)

array.push(names, "Auto")
array.push(dayRS, autoDayRS)
array.push(rs1h, autoRS1h)
array.push(rs15m, autoRS15m)

array.push(names, "Defence")
array.push(dayRS, defenceDayRS)
array.push(rs1h, defenceRS1h)
array.push(rs15m, defenceRS15m)

array.push(names, "Chemical")
array.push(dayRS, chemDayRS)
array.push(rs1h, chemRS1h)
array.push(rs15m, chemRS15m)

array.push(names, "Capital Goods")
array.push(dayRS, capitalGoodsDayRS)
array.push(rs1h, capitalGoodsRS1h)
array.push(rs15m, capitalGoodsRS15m)

array.push(names, "Consumer")
array.push(dayRS, consumerDayRS)
array.push(rs1h, consumerRS1h)
array.push(rs15m, consumerRS15m)

array.push(names, "Railways")
array.push(dayRS, railwayDayRS)
array.push(rs1h, railwayRS1h)
array.push(rs15m, railwayRS15m)

array.push(names, "Cement")
array.push(dayRS, cementDayRS)
array.push(rs1h, cementRS1h)
array.push(rs15m, cementRS15m)

array.push(names, "Hospitals")
array.push(dayRS, hospitalDayRS)
array.push(rs1h, hospitalRS1h)
array.push(rs15m, hospitalRS15m)

//--------------------------------------------------
// sorting
//--------------------------------------------------
for i = 0 to array.size(names) - 2

    for j = i + 1 to array.size(names) - 1

        valI =
             sortBy == "Day RS" ? array.get(dayRS, i) :
             sortBy == "1H RS"  ? array.get(rs1h, i) :
                                  array.get(rs15m, i)

        valJ =
             sortBy == "Day RS" ? array.get(dayRS, j) :
             sortBy == "1H RS"  ? array.get(rs1h, j) :
                                  array.get(rs15m, j)

        if valJ > valI

            // Day RS
            tmpDayRS = array.get(dayRS, i)
            array.set(dayRS, i, array.get(dayRS, j))
            array.set(dayRS, j, tmpDayRS)

            // 1H RS
            tmpRS1H = array.get(rs1h, i)
            array.set(rs1h, i, array.get(rs1h, j))
            array.set(rs1h, j, tmpRS1H)

            // 15m RS
            tmpRS15M = array.get(rs15m, i)
            array.set(rs15m, i, array.get(rs15m, j))
            array.set(rs15m, j, tmpRS15M)

            // Sector Name
            tmpName = array.get(names, i)
            array.set(names, i, array.get(names, j))
            array.set(names, j, tmpName)
//--------------------------------------------------
// table
//--------------------------------------------------

bullColor = color.rgb(55, 115, 63)
bearColor = color.rgb(153, 41, 55)
neutral   = color.rgb(35, 35, 35)
text_color = darkMode ? color.white : neutral
var table sectorTable = table.new(position.bottom_right,5,array.size(names) + 1,border_width = 1  , frame_color = color.gray , frame_width = 1 )

f_color(v) =>
    v > 0 ? bullColor :v < 0 ? bearColor:color.gray

if barstate.islast

    table.cell(sectorTable, 0, 0, "Rank", text_color = text_color)
    table.cell(sectorTable, 1, 0, "Sector", text_color = text_color)
    table.cell(sectorTable, 2, 0, "Day RS", text_color = text_color)
    table.cell(sectorTable, 3, 0, "1H RS", text_color = text_color)
    table.cell(sectorTable, 4, 0, "15m RS", text_color = text_color)

    for i = 0 to array.size(names) - 1

        sectorName = array.get(names, i)

        d = array.get(dayRS, i)
        h = array.get(rs1h, i)
        m = array.get(rs15m, i)

        table.cell(sectorTable,0,i + 1,str.tostring(i + 1), text_color = text_color)

        table.cell(sectorTable,1,i + 1,sectorName , text_color = text_color)

        table.cell(sectorTable,2,i + 1,str.tostring(d, "#.##"),bgcolor = f_color(d) , text_color = color.rgb(250, 252, 250))

        table.cell(sectorTable,3,i + 1,str.tostring(h, "#.##"),bgcolor = f_color(h), text_color = color.rgb(250, 252, 250))

        table.cell(sectorTable,4,i + 1,str.tostring(m, "#.##"),bgcolor = f_color(m), text_color = color.rgb(250, 252, 250))
````
