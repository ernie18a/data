<!-- tradingview-pine-id: PUB;3008883f54b84891b374c4679e5df267 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Cap Screener by SPPATLE

Source: https://www.tradingview.com/script/SYCacD08-Multi-Cap-Screener-by-SPPATLE/

## Description

custom watchlist scanner by SPPSTLE to scan momentum in selected stocks

---

## Source Code

````pine

// @author SPPATLE
//@version=6
indicator('Multi-Cap Screener by SPPATLE', overlay = true)

// ==========================================
// 1. SETTINGS & INPUTS
// ==========================================
tblPosition = input.string('Top Right', 'Table Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Top Center'], group = 'Table Appearance')

// Column Toggles
showMOM = input.bool(true, 'Show MOM Column', group = 'Columns Toggle')
showVol = input.bool(true, 'Show Volume Column', group = 'Columns Toggle')

// Criteria Thresholds
minRVol = input.float(1.0, 'Min Relative Volume for Green', group = 'Criteria')
minVol = input.int(100000, 'Min Volume (1 Lakh)', group = 'Criteria')

// ==========================================
// 2. UPDATED 23 STOCKS LIST
// ==========================================
sym01 = input.symbol('NSE:NETWEB', 'Stock 01', group = 'Future Small-Caps')
sym02 = input.symbol('NSE:DATAPATTNS', 'Stock 02', group = 'Future Small-Caps')
sym03 = input.symbol('NSE:MTARTECH', 'Stock 03', group = 'Future Small-Caps')
sym04 = input.symbol('NSE:MOSCHIP', 'Stock 04', group = 'Future Small-Caps')
sym05 = input.symbol('NSE:PARAS', 'Stock 05', group = 'Future Small-Caps')
sym06 = input.symbol('NSE:KAYNES', 'Stock 06', group = 'Future Small-Caps')
sym07 = input.symbol('NSE:MAPMYINDIA', 'Stock 07', group = 'Future Small-Caps')
sym08 = input.symbol('NSE:CYIENTDLM', 'Stock 08', group = 'Future Small-Caps')
sym09 = input.symbol('NSE:HAPPSTMNDS', 'Stock 09', group = 'Future Small-Caps')
sym10 = input.symbol('NSE:SUMICHEM', 'Stock 10 (Replaced TEJASNET)', group = 'Future Small-Caps')
sym11 = input.symbol('NSE:SONACOMS', 'Stock 11', group = 'Future Small-Caps')
sym12 = input.symbol('NSE:SYRMA', 'Stock 12', group = 'Future Small-Caps')
sym13 = input.symbol('NSE:PATELENG', 'Stock 13 (Replaced CENTUM)', group = 'Future Small-Caps')
sym14 = input.symbol('NSE:POLYMED', 'Stock 14 (Replaced IDEAFORGE)', group = 'Future Small-Caps')
sym15 = input.symbol('NSE:GENUSPOWER', 'Stock 15', group = 'Future Small-Caps')
sym16 = input.symbol('NSE:ECLERX', 'Stock 16', group = 'Future Small-Caps')
sym17 = input.symbol('NSE:CDSL', 'Stock 17', group = 'Future Small-Caps')
sym18 = input.symbol('NSE:SRF', 'Stock 18 (Replaced CAMS)', group = 'Future Small-Caps')
sym19 = input.symbol('NSE:BHARATGEAR', 'Stock 19 (Replaced PGEL)', group = 'Future Small-Caps')
sym20 = input.symbol('NSE:BCLIND', 'Stock 20 (Replaced PRAJIND)', group = 'Future Small-Caps')
sym21 = input.symbol('NSE:KIRLOSENG', 'Stock 21', group = 'Future Small-Caps')
sym22 = input.symbol('NSE:ZENSARTECH', 'Stock 22', group = 'Future Small-Caps')
sym23 = input.symbol('NSE:CYIENT', 'Stock 23', group = 'Future Small-Caps')

// ==========================================
// 3. HELPER FUNCTIONS & CALCULATIONS
// ==========================================
getPosition(pos) =>
    switch pos
        'Top Right' => position.top_right
        'Top Left' => position.top_left
        'Bottom Right' => position.bottom_right
        'Bottom Left' => position.bottom_left
        => position.top_center

f_calcCriteria() =>
    volVal = volume
    volMA = ta.sma(volume, 20)

    rvolVal = not na(volMA) and volMA > 0 ? volVal / volMA : 0.0
    rvolSafe = na(rvolVal) ? 0.0 : rvolVal

    curClose = close
    prevClose = close[1]
    chgPct = prevClose > 0 ? (curClose - prevClose) / prevClose * 100 : 0.0
    isBullish = curClose > prevClose

    isPassed = volVal >= minVol and rvolSafe > minRVol and isBullish
    [isPassed, rvolSafe, volVal, isBullish, chgPct]

// Fetch Data for All 23 Stocks
[p01, rvol01, vol01, bull01, pct01] = request.security(sym01, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p02, rvol02, vol02, bull02, pct02] = request.security(sym02, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p03, rvol03, vol03, bull03, pct03] = request.security(sym03, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p04, rvol04, vol04, bull04, pct04] = request.security(sym04, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p05, rvol05, vol05, bull05, pct05] = request.security(sym05, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p06, rvol06, vol06, bull06, pct06] = request.security(sym06, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p07, rvol07, vol07, bull07, pct07] = request.security(sym07, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p08, rvol08, vol08, bull08, pct08] = request.security(sym08, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p09, rvol09, vol09, bull09, pct09] = request.security(sym09, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p10, rvol10, vol10, bull10, pct10] = request.security(sym10, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p11, rvol11, vol11, bull11, pct11] = request.security(sym11, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p12, rvol12, vol12, bull12, pct12] = request.security(sym12, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p13, rvol13, vol13, bull13, pct13] = request.security(sym13, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p14, rvol14, vol14, bull14, pct14] = request.security(sym14, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p15, rvol15, vol15, bull15, pct15] = request.security(sym15, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p16, rvol16, vol16, bull16, pct16] = request.security(sym16, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p17, rvol17, vol17, bull17, pct17] = request.security(sym17, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p18, rvol18, vol18, bull18, pct18] = request.security(sym18, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p19, rvol19, vol19, bull19, pct19] = request.security(sym19, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p20, rvol20, vol20, bull20, pct20] = request.security(sym20, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p21, rvol21, vol21, bull21, pct21] = request.security(sym21, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p22, rvol22, vol22, bull22, pct22] = request.security(sym22, 'D', f_calcCriteria(), ignore_invalid_symbol = true)
[p23, rvol23, vol23, bull23, pct23] = request.security(sym23, 'D', f_calcCriteria(), ignore_invalid_symbol = true)

// ==========================================
// 4. SORTING FUNCTION (PASSED FIRST + HIGH MOM)
// ==========================================
f_sortAll(syms, passes, rvols, vols, bulls, pcts) =>
    for i = 0 to 21 by 1
        for j = i + 1 to 22 by 1
            bool passI = array.get(passes, i)
            bool passJ = array.get(passes, j)
            float rvolI = array.get(rvols, i)
            float rvolJ = array.get(rvols, j)

            bool swapNeeded = false
            if not passI and passJ
                swapNeeded := true
                swapNeeded
            else if passI == passJ and rvolI < rvolJ
                swapNeeded := true
                swapNeeded

            if swapNeeded
                tmpSym = array.get(syms, i)
                array.set(syms, i, array.get(syms, j))
                array.set(syms, j, tmpSym)
                tmpPass = array.get(passes, i)
                array.set(passes, i, array.get(passes, j))
                array.set(passes, j, tmpPass)
                tmpRvol = array.get(rvols, i)
                array.set(rvols, i, array.get(rvols, j))
                array.set(rvols, j, tmpRvol)
                tmpVol = array.get(vols, i)
                array.set(vols, i, array.get(vols, j))
                array.set(vols, j, tmpVol)
                tmpBull = array.get(bulls, i)
                array.set(bulls, i, array.get(bulls, j))
                array.set(bulls, j, tmpBull)
                tmpPct = array.get(pcts, i)
                array.set(pcts, i, array.get(pcts, j))
                array.set(pcts, j, tmpPct)

// ==========================================
// 5. DRAW DASHBOARD
// ==========================================
var table mainTable = table.new(position = getPosition(tblPosition), columns = 3, rows = 25, bgcolor = color.black, border_width = 0)

if barstate.islast
    table.set_position(mainTable, getPosition(tblPosition))

    syms = array.new_string(23)
    passes = array.new_bool(23)
    rvols = array.new_float(23)
    vols = array.new_float(23)
    bulls = array.new_bool(23)
    pcts = array.new_float(23)

    array.set(syms, 0, sym01)
    array.set(passes, 0, p01)
    array.set(rvols, 0, rvol01)
    array.set(vols, 0, vol01)
    array.set(bulls, 0, bull01)
    array.set(pcts, 0, pct01)
    array.set(syms, 1, sym02)
    array.set(passes, 1, p02)
    array.set(rvols, 1, rvol02)
    array.set(vols, 1, vol02)
    array.set(bulls, 1, bull02)
    array.set(pcts, 1, pct02)
    array.set(syms, 2, sym03)
    array.set(passes, 2, p03)
    array.set(rvols, 2, rvol03)
    array.set(vols, 2, vol03)
    array.set(bulls, 2, bull03)
    array.set(pcts, 2, pct03)
    array.set(syms, 3, sym04)
    array.set(passes, 3, p04)
    array.set(rvols, 3, rvol04)
    array.set(vols, 3, vol04)
    array.set(bulls, 3, bull04)
    array.set(pcts, 3, pct04)
    array.set(syms, 4, sym05)
    array.set(passes, 4, p05)
    array.set(rvols, 4, rvol05)
    array.set(vols, 4, vol05)
    array.set(bulls, 4, bull05)
    array.set(pcts, 4, pct05)
    array.set(syms, 5, sym06)
    array.set(passes, 5, p06)
    array.set(rvols, 5, rvol06)
    array.set(vols, 5, vol06)
    array.set(bulls, 5, bull06)
    array.set(pcts, 5, pct06)

    array.set(syms, 6, sym07)
    array.set(passes, 6, p07)
    array.set(rvols, 6, rvol07)
    array.set(vols, 6, vol07)
    array.set(bulls, 6, bull07)
    array.set(pcts, 6, pct07)
    array.set(syms, 7, sym08)
    array.set(passes, 7, p08)
    array.set(rvols, 7, rvol08)
    array.set(vols, 7, vol08)
    array.set(bulls, 7, bull08)
    array.set(pcts, 7, pct08)
    array.set(syms, 8, sym09)
    array.set(passes, 8, p09)
    array.set(rvols, 8, rvol09)
    array.set(vols, 8, vol09)
    array.set(bulls, 8, bull09)
    array.set(pcts, 8, pct09)
    array.set(syms, 9, sym10)
    array.set(passes, 9, p10)
    array.set(rvols, 9, rvol10)
    array.set(vols, 9, vol10)
    array.set(bulls, 9, bull10)
    array.set(pcts, 9, pct10)
    array.set(syms, 10, sym11)
    array.set(passes, 10, p11)
    array.set(rvols, 10, rvol11)
    array.set(vols, 10, vol11)
    array.set(bulls, 10, bull11)
    array.set(pcts, 10, pct11)
    array.set(syms, 11, sym12)
    array.set(passes, 11, p12)
    array.set(rvols, 11, rvol12)
    array.set(vols, 11, vol12)
    array.set(bulls, 11, bull12)
    array.set(pcts, 11, pct12)

    array.set(syms, 12, sym13)
    array.set(passes, 12, p13)
    array.set(rvols, 12, rvol13)
    array.set(vols, 12, vol13)
    array.set(bulls, 12, bull13)
    array.set(pcts, 12, pct13)
    array.set(syms, 13, sym14)
    array.set(passes, 13, p14)
    array.set(rvols, 13, rvol14)
    array.set(vols, 13, vol14)
    array.set(bulls, 13, bull14)
    array.set(pcts, 13, pct14)
    array.set(syms, 14, sym15)
    array.set(passes, 14, p15)
    array.set(rvols, 14, rvol15)
    array.set(vols, 14, vol15)
    array.set(bulls, 14, bull15)
    array.set(pcts, 14, pct15)
    array.set(syms, 15, sym16)
    array.set(passes, 15, p16)
    array.set(rvols, 15, rvol16)
    array.set(vols, 15, vol16)
    array.set(bulls, 15, bull16)
    array.set(pcts, 15, pct16)
    array.set(syms, 16, sym17)
    array.set(passes, 16, p17)
    array.set(rvols, 16, rvol17)
    array.set(vols, 16, vol17)
    array.set(bulls, 16, bull17)
    array.set(pcts, 16, pct17)
    array.set(syms, 17, sym18)
    array.set(passes, 17, p18)
    array.set(rvols, 17, rvol18)
    array.set(vols, 17, vol18)
    array.set(bulls, 17, bull18)
    array.set(pcts, 17, pct18)

    array.set(syms, 18, sym19)
    array.set(passes, 18, p19)
    array.set(rvols, 18, rvol19)
    array.set(vols, 18, vol19)
    array.set(bulls, 18, bull19)
    array.set(pcts, 18, pct19)
    array.set(syms, 19, sym20)
    array.set(passes, 19, p20)
    array.set(rvols, 19, rvol20)
    array.set(vols, 19, vol20)
    array.set(bulls, 19, bull20)
    array.set(pcts, 19, pct20)
    array.set(syms, 20, sym21)
    array.set(passes, 20, p21)
    array.set(rvols, 20, rvol21)
    array.set(vols, 20, vol21)
    array.set(bulls, 20, bull21)
    array.set(pcts, 20, pct21)
    array.set(syms, 21, sym22)
    array.set(passes, 21, p22)
    array.set(rvols, 21, rvol22)
    array.set(vols, 21, vol22)
    array.set(bulls, 21, bull22)
    array.set(pcts, 21, pct22)
    array.set(syms, 22, sym23)
    array.set(passes, 22, p23)
    array.set(rvols, 22, rvol23)
    array.set(vols, 22, vol23)
    array.set(bulls, 22, bull23)
    array.set(pcts, 22, pct23)

    // Sort All 23 Stocks
    f_sortAll(syms, passes, rvols, vols, bulls, pcts)

    // Row 0: Table Header
    table.cell(mainTable, 0, 0, 'Symbol (% Chg)', bgcolor = color.navy, text_color = color.white, text_size = size.normal)
    c = 0
    if showMOM
        c := c + 1
        table.cell(mainTable, c, 0, 'MOM', bgcolor = color.navy, text_color = color.white, text_size = size.normal)
    if showVol
        c := c + 1
        table.cell(mainTable, c, 0, 'Vol (L)', bgcolor = color.navy, text_color = color.white, text_size = size.normal)

    // Rows 1 to 23: All 23 Stocks
    for i = 0 to 22 by 1
        sym = array.get(syms, i)
        passed = array.get(passes, i)
        rvol = array.get(rvols, i)
        vol = array.get(vols, i)
        pct = array.get(pcts, i)

        colIdx = 0
        pctStr = (pct >= 0 ? '+' : '') + str.tostring(pct, '#.#') + '%'
        displaySym = str.replace(sym, 'NSE:', '') + ' (' + pctStr + ')'

        // GREEN ONLY WHEN PASSED (Positive Price Change + MOM > 1.0)
        symBgColor = passed ? color.green : color.red
        table.cell(mainTable, colIdx, i + 1, displaySym, bgcolor = symBgColor, text_color = color.white, text_size = size.normal)

        if showMOM
            colIdx := colIdx + 1
            table.cell(mainTable, colIdx, i + 1, str.tostring(rvol, '#.#'), bgcolor = color.gray, text_color = color.white, text_size = size.normal)
        if showVol
            colIdx := colIdx + 1
            table.cell(mainTable, colIdx, i + 1, str.tostring(vol / 100000, '#.#') + 'L', bgcolor = color.gray, text_color = color.white, text_size = size.normal)
````
