# Asset Class Correlation Matrix

- url: https://www.tradingview.com/script/0sUOoJZN-Asset-Class-Correlation-Matrix/
- type: indicator
- pine_id: PUB;9d16ffd9ddfa45bfa7409049706662f2
- version: 2.0

## Description

Asset Class Correlation Matrix

█ OVERVIEW

This indicator displays a Pearson correlation matrix for instruments in the asset class of the symbol you are currently viewing. Open a EUR pair and you see the forex matrix. Open gold and you see the metals matrix. Open Bitcoin and you see the crypto matrix. The relevant basket loads automatically, so there is nothing to configure for the common cases.

Each cell shows the rolling correlation between two instruments over a lookback period you control. The goal is to make cross-instrument relationships inside an asset class visible at a glance, rather than checking pairs one at a time, or relying on visual comparison.

[image]https://www.tradingview.com/x/WgsiXjAM/[/image]

█ AUTOMATIC ASSET CLASS DETECTION

The current symbol is matched to a category in three stages:

1. Exact ticker match against the built-in lists below.
2. Name-fragment match for common broker and CFD names. For example XAU and GOLD map to Metals, US500, SP500, NAS100, US100, US30 and DJ30 map to US Indices, DAX, FTSE and NIKKEI map to Global Indices, and WTI, BRENT and NATGAS map to Energy.
3. Asset type fallback using the instrument type, covering crypto, forex, and stocks.

If the current symbol is not already part of a built-in list, it is added as the first row and column of the matrix, so the instrument you are on is always included. If no category can be determined, the table shows a short prompt to use the custom symbol list instead of rendering empty.

█ BUILT-IN CATEGORIES

Forex: 28 majors and crosses across USD, EUR, GBP, JPY, AUD, CAD, CHF and NZD.
US Indices: ES, NQ, YM, EMD, RTY.
Global Indices: DAX, Euro Stoxx 50, Nikkei, FTSE, ASX 200, Hang Seng.
Metals: Gold, Silver, Copper, Platinum, Palladium.
Energy: WTI Crude, Natural Gas, Heating Oil, RBOB Gasoline.
Agricultural: Corn, Soybeans, Wheat, Soybean Oil, Soybean Meal, Cocoa, Coffee, Sugar, Cotton, Orange Juice.
Livestock: Live Cattle, Lean Hogs, Feeder Cattle.
Interest Rates: 2Y, 10Y, 30Y US notes, Euro Bund, Euro Buxl.
Crypto: BTC, ETH, BCH, LTC.
Stocks: SPX, QQQ, AAPL, MSFT, NVDA, AMZN, GOOGL, META, TSLA, AMD.

█ READING THE MATRIX

Pearson correlation ranges from -1 to +1.

Values near +1 mean the two instruments move strongly together. Values near -1 mean they move strongly opposite to each other, which is still a strong relationship, just inverted. Values near 0 mean little to no linear relationship.

The strength of a relationship is the distance from zero, in either direction. A reading of -0.9 is just as tight as +0.9.

█ COLORS

Positive correlation is shown in green, with a stronger shade above the high threshold and a lighter shade above the moderate threshold. Inverse correlation is shown in purple, using the same two strength levels. Everything between the negative and positive moderate threshold is shown as low. All five colors and both thresholds are adjustable in the settings. The thresholds apply symmetrically to positive and inverse values.

█ CUSTOM SYMBOL LIST

You can override the auto-detected basket with your own comma-separated list of symbols. Spaces are ignored. The custom list is applied only when the current chart symbol is one of the symbols in the list, which keeps the chart instrument anchored in the matrix.

You can include an exchange or broker prefix, for example OANDA:EURUSD. A bare ticker such as GBPJPY inherits the current chart prefix. Bare futures contracts such as ES1! resolve on their native exchange.

█ SETTINGS

Period: lookback in bars for the correlation calculation. Shorter reacts faster and is noisier. Longer is more stable and slower to update.
High and Moderate Correlation Thresholds: the cutoffs for the color bands.
Colors: the five correlation colors.
Symbol List: the optional custom basket.
Table Size: text size of the matrix.

█ HOW TO USE IT

Add the indicator to any chart in a supported asset class. Use it to find pairs that move together or opposite each other, to check diversification across a basket, to spot when a normally correlated pair is diverging, or to choose hedges and pairs-trade candidates. The left column shows the full applied symbol for each row, so you can confirm exactly which feed each value comes from.

█ NOTES AND LIMITATIONS

Correlation is period-dependent. For tightly linked instruments, a long lookback pushes most values toward the extremes, while a short lookback spreads them out and reacts faster. Choose the period to match the question you are asking.

Correlation measures linear co-movement of closing prices on the chart timeframe. It does not imply causation and does not capture non-linear relationships.

Broker naming for CFDs varies widely, so some instruments may not auto-detect. When that happens, use the custom symbol list.

A maximum of 28 instruments can be loaded in one matrix.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nilstrades_

//@version=6
indicator("Asset Class Correlation Matrix", shorttitle="Corr", overlay=true)

// ── Inputs ────────────────────────────────────────────────────────────────
g_set     = "Settings"
i_period  = input.int(200, "Period", minval=2, group=g_set, tooltip="Number of bars used to calculate the rolling Pearson correlation. A shorter period reacts faster to recent changes but is noisier. A longer period is more stable but slower to update.")
i_tblSize = input.string(size.tiny, "Table Size", [size.tiny, size.small, size.normal], group=g_set, display=display.none, tooltip="Text size of the correlation matrix table.")
i_hiThr   = input.float(0.7, "High Correlation Threshold", minval=0.0, maxval=1.0, step=0.05, group=g_set, tooltip="Correlations at or above this value are colored as high. The same value applies to inverse correlations at or below its negative.")
i_modThr  = input.float(0.3, "Moderate Correlation Threshold", minval=0.0, maxval=1.0, step=0.05, group=g_set, tooltip="Correlations between this value and the high threshold are colored as moderate, applied symmetrically to inverse correlations. Everything between the negative and positive moderate threshold is colored as low.")

g_col      = "Colors"
i_cHigh    = input.color(color.new(#2fa88f, 10),      "High Correlation",             group=g_col, tooltip="Applied when correlation is at or above the high threshold.")
i_cMod     = input.color(color.new(#2fa88f, 40),      "Moderate Correlation",         group=g_col)
i_cHighInv = input.color(color.new(#8a6be2, 10),      "High Inverse Correlation",     group=g_col, tooltip="Applied when correlation is at or below the negative high threshold.")
i_cModInv  = input.color(color.new(#8a6be2, 40),      "Moderate Inverse Correlation", group=g_col)
i_cLow     = input.color(color.new(#c24a43,70),       "Low Correlation",              group=g_col)

g_custom = "Custom Symbol List"
i_custom = input.text_area("", "Symbol List", group=g_custom, tooltip="Optional. A comma-separated list of symbols or ticker IDs, spaces are ignored. The custom list is only applied when the current chart symbol is one of the listed tickers. Otherwise the auto-detected category is used. You can include a broker or exchange prefix, for example OANDA:EURUSD. A bare ticker such as GBPJPY uses the current chart prefix.")

// ── Base Symbol ───────────────────────────────────────────────────────────
baseTicker = syminfo.ticker
baseId     = syminfo.tickerid
pfx        = syminfo.prefix

// ── Category Lists ────────────────────────────────────────────────────────
FOREX  = array.from("AUDUSD","EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY","AUDCAD","AUDCHF","AUDJPY","AUDNZD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","NZDCAD","NZDCHF","NZDJPY")
US_IDX = array.from("ES1!","NQ1!","YM1!","EMD1!","RTY1!")
GL_IDX = array.from("FDAX1!","FESX1!","NKD1!","Z1!","AP1!","HSI1!")
METALS = array.from("GC1!","SI1!","HG1!","PL1!","PA1!")
ENERGY = array.from("CL1!","NG1!","HO1!","RB1!")
AGRI   = array.from("ZC1!","ZS1!","ZW1!","ZL1!","ZM1!","CC1!","KC1!","SB1!","CT1!","OJ1!")
LIVSTK = array.from("LE1!","HE1!","GF1!")
RATES  = array.from("ZT1!","ZN1!","ZB1!","FGBL1!","FGBX1!")
CRYPTO = array.from("BTCUSD","ETHUSD","BCHUSD","LTCUSD")
STOCKS = array.from("SPX","QQQ","AAPL","MSFT","NVDA","AMZN","GOOGL","META","TSLA","AMD")

f_inCat(arr) =>
    found = false
    for i = 0 to array.size(arr) - 1
        if array.get(arr, i) == baseTicker
            found := true
    found

// ── Helpers ───────────────────────────────────────────────────────────────
f_bare(s) =>
    p = str.pos(s, ":")
    na(p) ? s : str.substring(s, p + 1)

f_withCurrent(baseList) =>
    a = array.copy(baseList)
    array.unshift(a, baseId)
    while array.size(a) > 28
        array.pop(a)
    a

// Token router: maps a symbol to a category by common name fragments
f_tokenLabel(t) =>
    u = str.upper(t)
    isMetal = str.contains(u,"XAU") or str.contains(u,"GOLD") or str.contains(u,"XAG") or str.contains(u,"SILVER") or str.contains(u,"COPPER") or str.contains(u,"XPT") or str.contains(u,"PLATINUM") or str.contains(u,"XPD") or str.contains(u,"PALLAD")
    isEnergy = str.contains(u,"WTI") or str.contains(u,"USOIL") or str.contains(u,"UKOIL") or str.contains(u,"BRENT") or str.contains(u,"CRUDE") or str.contains(u,"NATGAS") or str.contains(u,"NGAS")
    isUsIdx = str.contains(u,"SPX") or str.contains(u,"SP500") or str.contains(u,"US500") or str.contains(u,"NAS100") or str.contains(u,"US100") or str.contains(u,"USTEC") or str.contains(u,"NDX") or str.contains(u,"DJ30") or str.contains(u,"US30") or str.contains(u,"DJI") or str.contains(u,"US2000") or str.contains(u,"RUSSELL") or str.contains(u,"RUT")
    isGlIdx = str.contains(u,"GER40") or str.contains(u,"GER30") or str.contains(u,"DE40") or str.contains(u,"DAX") or str.contains(u,"UK100") or str.contains(u,"FTSE") or str.contains(u,"JP225") or str.contains(u,"JPN225") or str.contains(u,"NIKKEI") or str.contains(u,"NKY") or str.contains(u,"STOXX") or str.contains(u,"HK50") or str.contains(u,"HSI") or str.contains(u,"AUS200") or str.contains(u,"ASX")
    isMetal ? "Metals" : isEnergy ? "Energy" : isUsIdx ? "US Indices" : isGlIdx ? "Global Indices" : "Unknown"

// ── Custom List Parsing ───────────────────────────────────────────────────
f_parseCustom(raw) =>
    result = array.new_string()
    if str.length(str.trim(raw)) > 0
        lines = str.split(raw, ",")
        for i = 0 to array.size(lines) - 1
            t = str.trim(array.get(lines, i))
            if str.length(t) > 0
                array.push(result, str.upper(t))
    result

f_chartInCustom(arr) =>
    found = false
    for i = 0 to array.size(arr) - 1
        if f_bare(array.get(arr, i)) == str.upper(baseTicker)
            found := true
    found

customAssets = f_parseCustom(i_custom)
useCustom    = array.size(customAssets) > 0 and f_chartInCustom(customAssets)

// ── Category Resolution ───────────────────────────────────────────────────
f_listFor(lbl) =>
    lbl == "Forex"          ? FOREX  :
     lbl == "US Indices"    ? US_IDX :
     lbl == "Global Indices"? GL_IDX :
     lbl == "Metals"        ? METALS :
     lbl == "Energy"        ? ENERGY :
     lbl == "Agricultural"  ? AGRI   :
     lbl == "Livestock"     ? LIVSTK :
     lbl == "Interest Rates"? RATES  :
     lbl == "Crypto"        ? CRYPTO :
     lbl == "Stocks"        ? STOCKS :
     array.from(baseTicker)

// 1) exact ticker match
exactLabel = f_inCat(FOREX)  ? "Forex" :
     f_inCat(US_IDX) ? "US Indices" :
     f_inCat(GL_IDX) ? "Global Indices" :
     f_inCat(METALS) ? "Metals" :
     f_inCat(ENERGY) ? "Energy" :
     f_inCat(AGRI)   ? "Agricultural" :
     f_inCat(LIVSTK) ? "Livestock" :
     f_inCat(RATES)  ? "Interest Rates" :
     f_inCat(CRYPTO) ? "Crypto" :
     f_inCat(STOCKS) ? "Stocks" :
     "Unknown"

// 2) name-fragment token match
tokenLabel = f_tokenLabel(baseTicker)

// 3) asset-type fallback
st = syminfo.type
typeLabel = st == "crypto"                              ? "Crypto" :
     st == "forex"                                      ? "Forex" :
     (st == "stock" or st == "fund" or st == "dr")      ? "Stocks" :
     "Unknown"

catLabel = exactLabel != "Unknown" ? exactLabel :
     tokenLabel != "Unknown" ? tokenLabel :
     typeLabel

addedCur   = exactLabel == "Unknown" and catLabel != "Unknown"
autoAssets = addedCur ? f_withCurrent(f_listFor(catLabel)) : f_listFor(exactLabel)

catAssets    = useCustom ? customAssets : autoAssets
displayLabel = useCustom ? "Custom" : catLabel
n            = array.size(catAssets)
isFxOrCrypto = catLabel == "Forex" or catLabel == "Crypto"

// ── Symbol Resolution ─────────────────────────────────────────────────────
f_resolve(t) =>
    hasPrefix = not na(str.pos(t, ":"))
    isFut     = str.endswith(t, "!")
    hasPrefix ? t :
     useCustom ? (isFut ? t : (pfx != "" ? pfx + ":" + t : t)) :
     isFxOrCrypto ? (pfx != "" ? pfx + ":" + t : t) : t

f_req(sym) =>
    request.security(sym, timeframe.period, close / close[1] - 1.0)

sym00 = f_resolve(array.size(catAssets) > 0  ? array.get(catAssets, 0)  : baseTicker)
sym01 = f_resolve(array.size(catAssets) > 1  ? array.get(catAssets, 1)  : baseTicker)
sym02 = f_resolve(array.size(catAssets) > 2  ? array.get(catAssets, 2)  : baseTicker)
sym03 = f_resolve(array.size(catAssets) > 3  ? array.get(catAssets, 3)  : baseTicker)
sym04 = f_resolve(array.size(catAssets) > 4  ? array.get(catAssets, 4)  : baseTicker)
sym05 = f_resolve(array.size(catAssets) > 5  ? array.get(catAssets, 5)  : baseTicker)
sym06 = f_resolve(array.size(catAssets) > 6  ? array.get(catAssets, 6)  : baseTicker)
sym07 = f_resolve(array.size(catAssets) > 7  ? array.get(catAssets, 7)  : baseTicker)
sym08 = f_resolve(array.size(catAssets) > 8  ? array.get(catAssets, 8)  : baseTicker)
sym09 = f_resolve(array.size(catAssets) > 9  ? array.get(catAssets, 9)  : baseTicker)
sym10 = f_resolve(array.size(catAssets) > 10 ? array.get(catAssets, 10) : baseTicker)
sym11 = f_resolve(array.size(catAssets) > 11 ? array.get(catAssets, 11) : baseTicker)
sym12 = f_resolve(array.size(catAssets) > 12 ? array.get(catAssets, 12) : baseTicker)
sym13 = f_resolve(array.size(catAssets) > 13 ? array.get(catAssets, 13) : baseTicker)
sym14 = f_resolve(array.size(catAssets) > 14 ? array.get(catAssets, 14) : baseTicker)
sym15 = f_resolve(array.size(catAssets) > 15 ? array.get(catAssets, 15) : baseTicker)
sym16 = f_resolve(array.size(catAssets) > 16 ? array.get(catAssets, 16) : baseTicker)
sym17 = f_resolve(array.size(catAssets) > 17 ? array.get(catAssets, 17) : baseTicker)
sym18 = f_resolve(array.size(catAssets) > 18 ? array.get(catAssets, 18) : baseTicker)
sym19 = f_resolve(array.size(catAssets) > 19 ? array.get(catAssets, 19) : baseTicker)
sym20 = f_resolve(array.size(catAssets) > 20 ? array.get(catAssets, 20) : baseTicker)
sym21 = f_resolve(array.size(catAssets) > 21 ? array.get(catAssets, 21) : baseTicker)
sym22 = f_resolve(array.size(catAssets) > 22 ? array.get(catAssets, 22) : baseTicker)
sym23 = f_resolve(array.size(catAssets) > 23 ? array.get(catAssets, 23) : baseTicker)
sym24 = f_resolve(array.size(catAssets) > 24 ? array.get(catAssets, 24) : baseTicker)
sym25 = f_resolve(array.size(catAssets) > 25 ? array.get(catAssets, 25) : baseTicker)
sym26 = f_resolve(array.size(catAssets) > 26 ? array.get(catAssets, 26) : baseTicker)
sym27 = f_resolve(array.size(catAssets) > 27 ? array.get(catAssets, 27) : baseTicker)

v00 = f_req(sym00)
v01 = f_req(sym01)
v02 = f_req(sym02)
v03 = f_req(sym03)
v04 = f_req(sym04)
v05 = f_req(sym05)
v06 = f_req(sym06)
v07 = f_req(sym07)
v08 = f_req(sym08)
v09 = f_req(sym09)
v10 = f_req(sym10)
v11 = f_req(sym11)
v12 = f_req(sym12)
v13 = f_req(sym13)
v14 = f_req(sym14)
v15 = f_req(sym15)
v16 = f_req(sym16)
v17 = f_req(sym17)
v18 = f_req(sym18)
v19 = f_req(sym19)
v20 = f_req(sym20)
v21 = f_req(sym21)
v22 = f_req(sym22)
v23 = f_req(sym23)
v24 = f_req(sym24)
v25 = f_req(sym25)
v26 = f_req(sym26)
v27 = f_req(sym27)

matVals = array.from(v00,v01,v02,v03,v04,v05,v06,v07,v08,v09,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27)

// ── Manual Pearson Correlation ────────────────────────────────────────────
f_pearson(a, b, len) =>
    sumA  = 0.0
    sumB  = 0.0
    sumAB = 0.0
    sumA2 = 0.0
    sumB2 = 0.0
    for k = 0 to len - 1
        av = array.get(a, k)
        bv = array.get(b, k)
        sumA  += av
        sumB  += bv
        sumAB += av * bv
        sumA2 += av * av
        sumB2 += bv * bv
    meanA = sumA / len
    meanB = sumB / len
    num   = sumAB - len * meanA * meanB
    denA  = math.sqrt(math.max(sumA2 - len * meanA * meanA, 0.0))
    denB  = math.sqrt(math.max(sumB2 - len * meanB * meanB, 0.0))
    den   = denA * denB
    den == 0.0 ? na : num / den

// ── Colors ────────────────────────────────────────────────────────────────
bgClr  = chart.bg_color
fgClr  = chart.fg_color
txtClr = chart.fg_color
transp = color.new(color.blue,100)

f_rColor(r) =>
    na(r)           ? color.new(color.gray, 70) :
     r >=  i_hiThr  ? i_cHigh :
     r >=  i_modThr ? i_cMod :
     r <= -i_hiThr  ? i_cHighInv :
     r <= -i_modThr ? i_cModInv :
                      i_cLow

// ── Rolling History Matrix (runs every bar) ───────────────────────────────
var histMatrix = matrix.new<float>(28, i_period, na)

for i = 0 to n - 1
    for k = i_period - 1 to 1
        matrix.set(histMatrix, i, k, matrix.get(histMatrix, i, k - 1))
    matrix.set(histMatrix, i, 0, array.get(matVals, i))

// ── Matrix Table ──────────────────────────────────────────────────────────
var tbl = table.new(position.middle_right, 29, 30, border_width=1, border_color=transp)

if barstate.islast
    table.clear(tbl, 0, 0, 28, 29)
    showMatrix = displayLabel != "Unknown" or useCustom

    if i_modThr > i_hiThr
        table.cell(tbl, 0, 0, "Error: Moderate Correlation Threshold must be at or below the High Correlation Threshold.", text_color=color.white, text_size=i_tblSize, bgcolor=color.new(color.red, 0), text_halign=text.align_left)
    else if not showMatrix
        table.cell(tbl, 0, 0, "Symbol not in any category. Add it through the Custom Symbol List input.", text_color=color.white, text_size=i_tblSize, bgcolor=color.new(color.gray, 10), text_halign=text.align_left)
    else
        table.cell(tbl, 0, 0, displayLabel, text_color=bgClr, text_size=i_tblSize, bgcolor=fgClr, text_formatting=text.format_bold, text_halign=text.align_center)

        for i = 0 to n - 1
            entry    = array.get(catAssets, i)
            shortLbl = f_bare(entry)
            shortLbl := str.length(shortLbl) > 6 ? str.substring(shortLbl, 0, 6) : shortLbl
            fullLbl  = f_resolve(entry)
            table.cell(tbl, i + 1, 0, shortLbl, text_color=bgClr, text_size=i_tblSize, bgcolor=fgClr, text_formatting=text.format_bold, text_halign=text.align_center)
            table.cell(tbl, 0, i + 1, fullLbl, text_color=bgClr, text_size=i_tblSize, bgcolor=fgClr, text_formatting=text.format_bold, text_halign=text.align_right)

        for row = 0 to n - 1
            rowVec = matrix.row(histMatrix, row)
            for col = 0 to n - 1
                if row == col
                    table.cell(tbl, col + 1, row + 1, "—", text_color=color.new(fgClr, 60), text_size=i_tblSize, bgcolor=color.new(fgClr, 92), text_halign=text.align_center)
                else
                    colVec = matrix.row(histMatrix, col)
                    r      = f_pearson(rowVec, colVec, i_period)
                    table.cell(tbl, col + 1, row + 1, str.tostring(math.round(r, 2)), text_color=txtClr, text_size=i_tblSize, bgcolor=f_rColor(r), text_halign=text.align_center, text_font_family=font.family_monospace)
````
