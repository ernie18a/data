# Market Monitor by ASHISH

- url: https://www.tradingview.com/script/Kt2ofNrW-Market-Monitor-by-ASHISH/
- type: indicator
- pine_id: PUB;1610d824664c4d2b82d571c3a093e054
- version: 1.0

## Description

**Market Monitor — Sectoral Returns Dashboard**

A clean, customizable table-based dashboard that displays **live CMP (Current Market Price)** and **percentage returns** for up to 20 indices or symbols — all in one glance.

**Key Features:**
- 📊 **Multi-Timeframe Returns** — View 1D, 1W, 1M, 3M, 6M, and 12M returns simultaneously with combo display modes
- 💹 **Live CMP** — Real-time current price for each index alongside returns
- 🔃 **Smart Sorting** — Sort by best/worst performers or alphabetically
- 🎨 **Dual Themes** — Light (Blue/Green) and Dark mode support
- ⚙️ **Fully Customizable** — Toggle any of the 20 symbol slots, rename labels, adjust table size, position, and offset

Perfect for traders who want a **quick sectoral overview** without switching charts.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © finallynitin | Enhanced by Jignesh — v4: CMP column added

//@version=6
indicator("Market Monitor by ASHISH", overlay=true)

// ══════════════════════════════════════════════════════════════
// CUSTOM COLORS
// ══════════════════════════════════════════════════════════════
string GRP_COLORS  = "════════ Custom Colors ════════"
toggleDarkColors   = input.bool(false, title="Dark Mode", group=GRP_COLORS)
string themeOption = input.string("Blue", title="Light Mode Theme", options=["Blue","Green"], group=GRP_COLORS)

FrameCol       = toggleDarkColors ? color.new(#999999, 50)      : color.rgb(241, 241, 241)
BorderCol      = toggleDarkColors ? color.new(#999999, 50)      : color.rgb(241, 241, 241)
TextColor      = toggleDarkColors ? color.new(color.white, 0)   : color.new(color.black, 0)
BGColor        = toggleDarkColors ? color.new(color.white, 100) : color.new(color.black, 100)
HeadColor      = toggleDarkColors ? color.new(color.white, 100) : color.new(color.black, 100)
BodyColor      = toggleDarkColors ? color.new(color.white, 100) : color.new(color.black, 100)
UpColor        = toggleDarkColors ? color.new(color.lime, 0)    : (themeOption == "Blue" ? color.new(color.rgb(31, 12, 239, 16), 0) : color.new(color.green, 0))
DownColor      = toggleDarkColors ? color.new(color.red, 0)     : (themeOption == "Blue" ? color.new(color.rgb(213, 27, 182), 10) : color.new(color.red, 0))
UnchangedColor = toggleDarkColors ? color.new(color.yellow, 0)  : color.new(color.orange, 30)

// ══════════════════════════════════════════════════════════════
// TABLE OPTIONS
// ══════════════════════════════════════════════════════════════
string GRP3      = "════════ Table Options ═════════"
string tablesize = input.string("small",  "Size", inline="21", group=GRP3, options=["tiny","small","normal","large","huge","auto"])
string tableposY = input.string("middle", "↕",    inline="21", group=GRP3, options=["top","middle","bottom"])
string tableposX = input.string("right",  "↔",    inline="21", group=GRP3, options=["left","center","right"])

string displayMode = input.string("Single", title="Display Mode",
     options=["Single","1W+1D","1M+1W","1M+1W+1D","3M+1M+1W","3M+1M+1W+1D","12M+6M+3M+1M+1W"],
     tooltip="Single = one chosen TF. Combo = multiple TF columns side by side.",
     group=GRP3)

string selected_period = input.string("1M", title="Single Timeframe",
     options=["1D","1W","1M","3M","6M","12M"], group=GRP3)

string sort_option = input.string("Descending", title="Sort Table",
     options=["Descending","Ascending","Alphabetically"], group=GRP3)

int horizontalOffset = input.int(0, title="Horizontal Offset",
     minval=0, step=1,
     tooltip="Shift table left by adding invisible spacer columns.",
     group=GRP3)

string table_header = input.string("Indices", title="Table Header Text", group=GRP3)

// ══════════════════════════════════════════════════════════════
// SYMBOL SELECTION (20 slots)
// ══════════════════════════════════════════════════════════════
string GRP0 = "════════ Symbol Selection & Titles ════════"

bool showone       = input.bool(true, "01", inline="line 1",  group=GRP0)
string indexone    = input.symbol("NSE:CNXAUTO",            "", inline="line 1",  group=GRP0)
string titleone    = input.string("Auto",                   "", inline="line 1",  group=GRP0)

bool showtwo       = input.bool(true, "02", inline="line 2",  group=GRP0)
string indextwo    = input.symbol("NSE:CNXCOMMODITIES",     "", inline="line 2",  group=GRP0)
string titletwo    = input.string("Commodities",            "", inline="line 2",  group=GRP0)

bool showthree     = input.bool(true, "03", inline="line 3",  group=GRP0)
string indexthree  = input.symbol("NSE:NIFTY_CONSR_DURBL", "", inline="line 3",  group=GRP0)
string titlethree  = input.string("Consumer Durables",      "", inline="line 3",  group=GRP0)

bool showfour      = input.bool(true, "04", inline="line 4",  group=GRP0)
string indexfour   = input.symbol("NSE:CNXCONSUMPTION",    "", inline="line 4",  group=GRP0)
string titlefour   = input.string("Consumption",            "", inline="line 4",  group=GRP0)

bool showfive      = input.bool(true, "05", inline="line 5",  group=GRP0)
string indexfive   = input.symbol("NSE:CNXENERGY",          "", inline="line 5",  group=GRP0)
string titlefive   = input.string("Energy",                 "", inline="line 5",  group=GRP0)

bool showsix       = input.bool(true, "06", inline="line 6",  group=GRP0)
string indexsix    = input.symbol("NSE:CNXFMCG",            "", inline="line 6",  group=GRP0)
string titlesix    = input.string("FMCG",                   "", inline="line 6",  group=GRP0)

bool showseven     = input.bool(true, "07", inline="line 7",  group=GRP0)
string indexseven  = input.symbol("NSE:NIFTY_HEALTHCARE",  "", inline="line 7",  group=GRP0)
string titleseven  = input.string("Healthcare",             "", inline="line 7",  group=GRP0)

bool showeight     = input.bool(true, "08", inline="line 8",  group=GRP0)
string indexeight  = input.symbol("NSE:CNXINFRA",           "", inline="line 8",  group=GRP0)
string titleeight  = input.string("Infra",                  "", inline="line 8",  group=GRP0)

bool shownine      = input.bool(true, "09", inline="line 9",  group=GRP0)
string indexnine   = input.symbol("NSE:CNXIT",              "", inline="line 9",  group=GRP0)
string titlenine   = input.string("IT",                     "", inline="line 9",  group=GRP0)

bool showten       = input.bool(true, "10", inline="line 10", group=GRP0)
string indexten    = input.symbol("NSE:CNXMEDIA",           "", inline="line 10", group=GRP0)
string titleten    = input.string("Media",                  "", inline="line 10", group=GRP0)

bool showeleven    = input.bool(true, "11", inline="line 11", group=GRP0)
string indexeleven = input.symbol("NSE:CNXMETAL",           "", inline="line 11", group=GRP0)
string titleeleven = input.string("Metal",                  "", inline="line 11", group=GRP0)

bool showtwelve    = input.bool(true, "12", inline="line 12", group=GRP0)
string indextwelve = input.symbol("NSE:NIFTY_IND_DEFENCE", "", inline="line 12", group=GRP0)
string titletwelve = input.string("Defence",                "", inline="line 12", group=GRP0)

bool showthirteen     = input.bool(true, "13", inline="line 13", group=GRP0)
string indexthirteen  = input.symbol("BSE:OILGAS",          "", inline="line 13", group=GRP0)
string titlethirteen  = input.string("OilGas",              "", inline="line 13", group=GRP0)

bool showfourteen     = input.bool(true, "14", inline="line 14", group=GRP0)
string indexfourteen  = input.symbol("NSE:CNXPHARMA",       "", inline="line 14", group=GRP0)
string titlefourteen  = input.string("Pharma",              "", inline="line 14", group=GRP0)

bool showfifteen      = input.bool(true, "15", inline="line 15", group=GRP0)
string indexfifteen   = input.symbol("BSE:POWER",           "", inline="line 15", group=GRP0)
string titlefifteen   = input.string("Power",               "", inline="line 15", group=GRP0)

bool showsixteen      = input.bool(true, "16", inline="line 16", group=GRP0)
string indexsixteen   = input.symbol("NSE:CNXPSE",          "", inline="line 16", group=GRP0)
string titlesixteen   = input.string("PSE",                 "", inline="line 16", group=GRP0)

bool showseventeen    = input.bool(true, "17", inline="line 17", group=GRP0)
string indexseventeen = input.symbol("NSE:CNXPSUBANK",      "", inline="line 17", group=GRP0)
string titleseventeen = input.string("PSUBank",             "", inline="line 17", group=GRP0)

bool showeighteen     = input.bool(true, "18", inline="line 18", group=GRP0)
string indexeighteen  = input.symbol("NSE:NIFTYPVTBANK",   "", inline="line 18", group=GRP0)
string titleeighteen  = input.string("PVTBank",             "", inline="line 18", group=GRP0)

bool shownineteen     = input.bool(true, "19", inline="line 19", group=GRP0)
string indexnineteen  = input.symbol("NSE:CNXREALTY",       "", inline="line 19", group=GRP0)
string titlenineteen  = input.string("Realty",              "", inline="line 19", group=GRP0)

bool showtwenty       = input.bool(true, "20", inline="line 20", group=GRP0)
string indextwenty    = input.symbol("NSE:CNXSERVICE",      "", inline="line 20", group=GRP0)
string titletwenty    = input.string("Service",             "", inline="line 20", group=GRP0)

// ══════════════════════════════════════════════════════════════
// FETCH — 1 request.security per symbol (tuple), returns
// CMP (live daily close) + all 6 period returns
// Total = 20 calls, well within the 40-call limit
// ══════════════════════════════════════════════════════════════
f_rets(simple string sym) =>
    [c0, c1, c5, c21, c63, c126, c252] =
         request.security(sym, "D",
             [close, close[1], close[5], close[21], close[63], close[126], close[252]])
    float cmp  = c0
    float r1d  = c1   > 0 ? (c0 - c1)   / c1   * 100 : na
    float r1w  = c5   > 0 ? (c0 - c5)   / c5   * 100 : na
    float r1m  = c21  > 0 ? (c0 - c21)  / c21  * 100 : na
    float r3m  = c63  > 0 ? (c0 - c63)  / c63  * 100 : na
    float r6m  = c126 > 0 ? (c0 - c126) / c126 * 100 : na
    float r12m = c252 > 0 ? (c0 - c252) / c252 * 100 : na
    [cmp, r1d, r1w, r1m, r3m, r6m, r12m]

// ── Fetch all 20 symbols ──────────────────────────────────────
[cmp_01, r1d_01, r1w_01, r1m_01, r3m_01, r6m_01, r12m_01] = f_rets(indexone)
[cmp_02, r1d_02, r1w_02, r1m_02, r3m_02, r6m_02, r12m_02] = f_rets(indextwo)
[cmp_03, r1d_03, r1w_03, r1m_03, r3m_03, r6m_03, r12m_03] = f_rets(indexthree)
[cmp_04, r1d_04, r1w_04, r1m_04, r3m_04, r6m_04, r12m_04] = f_rets(indexfour)
[cmp_05, r1d_05, r1w_05, r1m_05, r3m_05, r6m_05, r12m_05] = f_rets(indexfive)
[cmp_06, r1d_06, r1w_06, r1m_06, r3m_06, r6m_06, r12m_06] = f_rets(indexsix)
[cmp_07, r1d_07, r1w_07, r1m_07, r3m_07, r6m_07, r12m_07] = f_rets(indexseven)
[cmp_08, r1d_08, r1w_08, r1m_08, r3m_08, r6m_08, r12m_08] = f_rets(indexeight)
[cmp_09, r1d_09, r1w_09, r1m_09, r3m_09, r6m_09, r12m_09] = f_rets(indexnine)
[cmp_10, r1d_10, r1w_10, r1m_10, r3m_10, r6m_10, r12m_10] = f_rets(indexten)
[cmp_11, r1d_11, r1w_11, r1m_11, r3m_11, r6m_11, r12m_11] = f_rets(indexeleven)
[cmp_12, r1d_12, r1w_12, r1m_12, r3m_12, r6m_12, r12m_12] = f_rets(indextwelve)
[cmp_13, r1d_13, r1w_13, r1m_13, r3m_13, r6m_13, r12m_13] = f_rets(indexthirteen)
[cmp_14, r1d_14, r1w_14, r1m_14, r3m_14, r6m_14, r12m_14] = f_rets(indexfourteen)
[cmp_15, r1d_15, r1w_15, r1m_15, r3m_15, r6m_15, r12m_15] = f_rets(indexfifteen)
[cmp_16, r1d_16, r1w_16, r1m_16, r3m_16, r6m_16, r12m_16] = f_rets(indexsixteen)
[cmp_17, r1d_17, r1w_17, r1m_17, r3m_17, r6m_17, r12m_17] = f_rets(indexseventeen)
[cmp_18, r1d_18, r1w_18, r1m_18, r3m_18, r6m_18, r12m_18] = f_rets(indexeighteen)
[cmp_19, r1d_19, r1w_19, r1m_19, r3m_19, r6m_19, r12m_19] = f_rets(indexnineteen)
[cmp_20, r1d_20, r1w_20, r1m_20, r3m_20, r6m_20, r12m_20] = f_rets(indextwenty)

// ══════════════════════════════════════════════════════════════
// BUILD ARRAYS
// ══════════════════════════════════════════════════════════════
string[] symbols  = array.new_string(0)
string[] titles   = array.new_string(0)
float[]  arr_cmp  = array.new_float(0)
float[]  arr_1d   = array.new_float(0)
float[]  arr_1w   = array.new_float(0)
float[]  arr_1m   = array.new_float(0)
float[]  arr_3m   = array.new_float(0)
float[]  arr_6m   = array.new_float(0)
float[]  arr_12m  = array.new_float(0)

f_push(bool show, string sym, string ttl, string raw,
       float cmp, float d, float w, float m, float q, float h, float y) =>
    if show
        array.push(symbols,  sym)
        array.push(titles,   ttl == "" ? str.replace(raw, "NSE:", "") : ttl)
        array.push(arr_cmp,  cmp)
        array.push(arr_1d,   d)
        array.push(arr_1w,   w)
        array.push(arr_1m,   m)
        array.push(arr_3m,   q)
        array.push(arr_6m,   h)
        array.push(arr_12m,  y)

f_push(showone,       indexone,       titleone,       indexone,       cmp_01, r1d_01, r1w_01, r1m_01, r3m_01, r6m_01, r12m_01)
f_push(showtwo,       indextwo,       titletwo,       indextwo,       cmp_02, r1d_02, r1w_02, r1m_02, r3m_02, r6m_02, r12m_02)
f_push(showthree,     indexthree,     titlethree,     indexthree,     cmp_03, r1d_03, r1w_03, r1m_03, r3m_03, r6m_03, r12m_03)
f_push(showfour,      indexfour,      titlefour,      indexfour,      cmp_04, r1d_04, r1w_04, r1m_04, r3m_04, r6m_04, r12m_04)
f_push(showfive,      indexfive,      titlefive,      indexfive,      cmp_05, r1d_05, r1w_05, r1m_05, r3m_05, r6m_05, r12m_05)
f_push(showsix,       indexsix,       titlesix,       indexsix,       cmp_06, r1d_06, r1w_06, r1m_06, r3m_06, r6m_06, r12m_06)
f_push(showseven,     indexseven,     titleseven,     indexseven,     cmp_07, r1d_07, r1w_07, r1m_07, r3m_07, r6m_07, r12m_07)
f_push(showeight,     indexeight,     titleeight,     indexeight,     cmp_08, r1d_08, r1w_08, r1m_08, r3m_08, r6m_08, r12m_08)
f_push(shownine,      indexnine,      titlenine,      indexnine,      cmp_09, r1d_09, r1w_09, r1m_09, r3m_09, r6m_09, r12m_09)
f_push(showten,       indexten,       titleten,       indexten,       cmp_10, r1d_10, r1w_10, r1m_10, r3m_10, r6m_10, r12m_10)
f_push(showeleven,    indexeleven,    titleeleven,    indexeleven,    cmp_11, r1d_11, r1w_11, r1m_11, r3m_11, r6m_11, r12m_11)
f_push(showtwelve,    indextwelve,    titletwelve,    indextwelve,    cmp_12, r1d_12, r1w_12, r1m_12, r3m_12, r6m_12, r12m_12)
f_push(showthirteen,  indexthirteen,  titlethirteen,  indexthirteen,  cmp_13, r1d_13, r1w_13, r1m_13, r3m_13, r6m_13, r12m_13)
f_push(showfourteen,  indexfourteen,  titlefourteen,  indexfourteen,  cmp_14, r1d_14, r1w_14, r1m_14, r3m_14, r6m_14, r12m_14)
f_push(showfifteen,   indexfifteen,   titlefifteen,   indexfifteen,   cmp_15, r1d_15, r1w_15, r1m_15, r3m_15, r6m_15, r12m_15)
f_push(showsixteen,   indexsixteen,   titlesixteen,   indexsixteen,   cmp_16, r1d_16, r1w_16, r1m_16, r3m_16, r6m_16, r12m_16)
f_push(showseventeen, indexseventeen, titleseventeen, indexseventeen, cmp_17, r1d_17, r1w_17, r1m_17, r3m_17, r6m_17, r12m_17)
f_push(showeighteen,  indexeighteen,  titleeighteen,  indexeighteen,  cmp_18, r1d_18, r1w_18, r1m_18, r3m_18, r6m_18, r12m_18)
f_push(shownineteen,  indexnineteen,  titlenineteen,  indexnineteen,  cmp_19, r1d_19, r1w_19, r1m_19, r3m_19, r6m_19, r12m_19)
f_push(showtwenty,    indextwenty,    titletwenty,    indextwenty,    cmp_20, r1d_20, r1w_20, r1m_20, r3m_20, r6m_20, r12m_20)

// ══════════════════════════════════════════════════════════════
// DISPLAY MODE → TF column list & labels
// ══════════════════════════════════════════════════════════════
string[] tf_keys   = array.new_string(0)
string[] tf_labels = array.new_string(0)

if displayMode == "Single"
    array.push(tf_keys,   selected_period)
    string lbl = selected_period == "1D"  ? "Today"    :
                 selected_period == "1W"  ? "1 Week"   :
                 selected_period == "1M"  ? "1 Month"  :
                 selected_period == "3M"  ? "3 Months" :
                 selected_period == "6M"  ? "6 Months" : "12 Months"
    array.push(tf_labels, lbl)

else if displayMode == "1W+1D"
    array.push(tf_keys,   "1W") , array.push(tf_labels, "1W")
    array.push(tf_keys,   "1D") , array.push(tf_labels, "1D")

else if displayMode == "1M+1W"
    array.push(tf_keys,   "1M") , array.push(tf_labels, "1M")
    array.push(tf_keys,   "1W") , array.push(tf_labels, "1W")

else if displayMode == "1M+1W+1D"
    array.push(tf_keys,   "1M") , array.push(tf_labels, "1M")
    array.push(tf_keys,   "1W") , array.push(tf_labels, "1W")
    array.push(tf_keys,   "1D") , array.push(tf_labels, "1D")

else if displayMode == "3M+1M+1W"
    array.push(tf_keys,   "3M") , array.push(tf_labels, "3M")
    array.push(tf_keys,   "1M") , array.push(tf_labels, "1M")
    array.push(tf_keys,   "1W") , array.push(tf_labels, "1W")

else if displayMode == "3M+1M+1W+1D"
    array.push(tf_keys,   "3M") , array.push(tf_labels, "3M")
    array.push(tf_keys,   "1M") , array.push(tf_labels, "1M")
    array.push(tf_keys,   "1W") , array.push(tf_labels, "1W")
    array.push(tf_keys,   "1D") , array.push(tf_labels, "1D")

else if displayMode == "12M+6M+3M+1M+1W"
    array.push(tf_keys,   "12M"), array.push(tf_labels, "12M")
    array.push(tf_keys,   "6M") , array.push(tf_labels, "6M")
    array.push(tf_keys,   "3M") , array.push(tf_labels, "3M")
    array.push(tf_keys,   "1M") , array.push(tf_labels, "1M")
    array.push(tf_keys,   "1W") , array.push(tf_labels, "1W")

int numTF  = array.size(tf_keys)
int numSym = array.size(symbols)

// ══════════════════════════════════════════════════════════════
// HELPER: get return value by TF key and row index
// ══════════════════════════════════════════════════════════════
f_getVal(int idx, string key) =>
    float v = na
    if key == "1D"
        v := array.get(arr_1d,  idx)
    else if key == "1W"
        v := array.get(arr_1w,  idx)
    else if key == "1M"
        v := array.get(arr_1m,  idx)
    else if key == "3M"
        v := array.get(arr_3m,  idx)
    else if key == "6M"
        v := array.get(arr_6m,  idx)
    else if key == "12M"
        v := array.get(arr_12m, idx)
    v

// ══════════════════════════════════════════════════════════════
// SORT — keyed on first TF in the list
// ══════════════════════════════════════════════════════════════
string sortKey  = array.get(tf_keys, 0)
float[] sort_vals = array.new_float(numSym, na)
for i = 0 to numSym - 1
    array.set(sort_vals, i, f_getVal(i, sortKey))

f_swap(int a, int b) =>
    string ts = array.get(symbols, a)
    array.set(symbols, a, array.get(symbols, b))
    array.set(symbols, b, ts)
    string tt = array.get(titles, a)
    array.set(titles, a, array.get(titles, b))
    array.set(titles, b, tt)
    float tv = array.get(sort_vals, a)
    array.set(sort_vals, a, array.get(sort_vals, b))
    array.set(sort_vals, b, tv)
    // CMP
    float tc = array.get(arr_cmp, a)
    array.set(arr_cmp, a, array.get(arr_cmp, b))
    array.set(arr_cmp, b, tc)
    // all TF arrays
    float t1d = array.get(arr_1d, a)
    array.set(arr_1d, a, array.get(arr_1d, b))
    array.set(arr_1d, b, t1d)
    float t1w = array.get(arr_1w, a)
    array.set(arr_1w, a, array.get(arr_1w, b))
    array.set(arr_1w, b, t1w)
    float t1m = array.get(arr_1m, a)
    array.set(arr_1m, a, array.get(arr_1m, b))
    array.set(arr_1m, b, t1m)
    float t3m = array.get(arr_3m, a)
    array.set(arr_3m, a, array.get(arr_3m, b))
    array.set(arr_3m, b, t3m)
    float t6m = array.get(arr_6m, a)
    array.set(arr_6m, a, array.get(arr_6m, b))
    array.set(arr_6m, b, t6m)
    float t12m = array.get(arr_12m, a)
    array.set(arr_12m, a, array.get(arr_12m, b))
    array.set(arr_12m, b, t12m)

bool custom_titles_used = false
for i = 0 to numSym - 1
    if array.get(titles, i) != array.get(symbols, i)
        custom_titles_used := true
        break

if sort_option == "Descending"
    for i = 0 to numSym - 2
        for j = i + 1 to numSym - 1
            if array.get(sort_vals, i) < array.get(sort_vals, j)
                f_swap(i, j)

else if sort_option == "Ascending"
    for i = 0 to numSym - 2
        for j = i + 1 to numSym - 1
            if array.get(sort_vals, i) > array.get(sort_vals, j)
                f_swap(i, j)

else if sort_option == "Alphabetically" and not custom_titles_used
    for i = 0 to numSym - 2
        for j = i + 1 to numSym - 1
            float ti = str.tonumber(str.tostring(array.get(titles, i)))
            float tj = str.tonumber(str.tostring(array.get(titles, j)))
            if ti > tj
                f_swap(i, j)

// ══════════════════════════════════════════════════════════════
// CLEAN SYMBOL NAME
// ══════════════════════════════════════════════════════════════
f_clean(string raw) =>
    string s = raw
    s := str.replace(s, "BSE_DLY:", "")
    s := str.replace(s, "NSE:", "")
    s := str.replace(s, "BSE:", "")
    s := str.replace(s, "CNX", "")
    s := str.replace(s, "NIFTY_", "")
    s := str.replace(s, "IND_", "")
    s := str.replace(s, "NIFTYPVTBANK", "PVTBANK")
    s := str.replace(s, "CONSR_DURBL", "CONS DURABLES")
    s

// ══════════════════════════════════════════════════════════════
// TABLE
// Columns: [offset spacers] | Name | CMP | TF1 | TF2 | ...
// ══════════════════════════════════════════════════════════════
int totalCols = horizontalOffset + 2 + numTF   // +2 = Name + CMP

table t = table.new(
     position     = tableposY + "_" + tableposX,
     columns      = totalCols,
     rows         = numSym + 1,
     bgcolor      = BGColor,
     frame_color  = FrameCol,
     frame_width  = 1,
     border_color = BorderCol,
     border_width = 1)

// ── Header row ───────────────────────────────────────────────
if horizontalOffset > 0
    for k = 0 to horizontalOffset - 1
        table.cell(t, k, 0, "",
             bgcolor    = color.new(color.white, 100),
             text_color = color.new(color.white, 100),
             text_size  = tablesize)

// Name header
table.cell(t, horizontalOffset, 0, table_header,
     text_color      = TextColor,
     bgcolor         = HeadColor,
     text_formatting = text.format_bold,
     text_halign     = text.align_left,
     text_size       = tablesize)

// CMP header
table.cell(t, horizontalOffset + 1, 0, "CMP",
     text_color      = TextColor,
     bgcolor         = HeadColor,
     text_formatting = text.format_bold,
     text_size       = tablesize)

// Return period headers
for tc = 0 to numTF - 1
    table.cell(t, horizontalOffset + 2 + tc, 0,
         array.get(tf_labels, tc),
         text_color      = TextColor,
         bgcolor         = HeadColor,
         text_formatting = text.format_bold,
         text_size       = tablesize)

// ── Data rows ────────────────────────────────────────────────
for i = 0 to numSym - 1
    string raw   = array.get(titles, i)
    string label = f_clean(raw == "" ? array.get(symbols, i) : raw)
    float  cmp   = array.get(arr_cmp, i)

    if horizontalOffset > 0
        for k = 0 to horizontalOffset - 1
            table.cell(t, k, i + 1, "",
                 bgcolor   = BGColor,
                 text_size = tablesize)

    // Name cell
    table.cell(t, horizontalOffset, i + 1, label,
         text_color  = TextColor,
         bgcolor     = HeadColor,
         text_halign = text.align_left,
         text_size   = tablesize)

    // CMP cell — neutral color, 2 decimal places
    string cmp_txt = na(cmp) ? "N/A" : str.tostring(cmp, "#.##")
    table.cell(t, horizontalOffset + 1, i + 1, cmp_txt,
         text_color = TextColor,
         bgcolor    = BodyColor,
         text_size  = tablesize)

    // Return % cells
    for tc = 0 to numTF - 1
        float  rv  = f_getVal(i, array.get(tf_keys, tc))
        color  col = na(rv) ? UnchangedColor : (rv > 0 ? UpColor : (rv < 0 ? DownColor : UnchangedColor))
        string txt = na(rv) ? "N/A" : str.tostring(rv, "#.#") + "%"
        table.cell(t, horizontalOffset + 2 + tc, i + 1, txt,
             text_color = col,
             bgcolor    = BodyColor,
             text_size  = tablesize)
````
