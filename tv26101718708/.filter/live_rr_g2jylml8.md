# Live R:R 

- url: https://www.tradingview.com/script/g2jYlML8-Live-R-R/
- type: indicator
- pine_id: PUB;73809ad2926e4058af9d8b0c7c7e8992
- version: 1.0

## Description

passa dig ludmilla för här kommer TPn, aja baja ludmilla annars kommer SL. Elller så blir det ingenting. Oavsett vad kan du se live RR från din kassa position blå ****


Please let me fkn publish man i cant do it anymore

## Source Code

````pine
//@version=6
indicator(
     title            = "Live R:R Dashboard",
     shorttitle       = "R:R",
     overlay          = true,
     max_lines_count  = 0,
     max_labels_count = 0
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1 · DASHBOARD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dashPos = input.string(
     defval  = "Top Right",
     title   = "Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
     group   = "Dashboard"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2 · TRADE INPUTS  (10 slots)
//
//   Direction auto-detected: Long when TP > Entry, Short when TP < Entry.
//   Slot is hidden when Enable = false OR Entry / SL / TP = 0.
//
//   To add an 11th trade: duplicate a block, add a security() call,
//   append to each array.from(), and change int N to 11.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── Trade 01 ──────────────────────────────────────────────────────────────
t01_en  = input.bool(false,      "Enable",      group = "Trade 01")
t01_sym = input.symbol("EURUSD", "Symbol",      group = "Trade 01")
t01_ent = input.float(0.0,       "Entry",       group = "Trade 01", minval = 0, step = 0.00001)
t01_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 01", minval = 0, step = 0.00001)
t01_tp  = input.float(0.0,       "Take Profit", group = "Trade 01", minval = 0, step = 0.00001)

// ── Trade 02 ──────────────────────────────────────────────────────────────
t02_en  = input.bool(false,      "Enable",      group = "Trade 02")
t02_sym = input.symbol("GBPUSD", "Symbol",      group = "Trade 02")
t02_ent = input.float(0.0,       "Entry",       group = "Trade 02", minval = 0, step = 0.00001)
t02_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 02", minval = 0, step = 0.00001)
t02_tp  = input.float(0.0,       "Take Profit", group = "Trade 02", minval = 0, step = 0.00001)

// ── Trade 03 ──────────────────────────────────────────────────────────────
t03_en  = input.bool(false,      "Enable",      group = "Trade 03")
t03_sym = input.symbol("USDJPY", "Symbol",      group = "Trade 03")
t03_ent = input.float(0.0,       "Entry",       group = "Trade 03", minval = 0, step = 0.00001)
t03_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 03", minval = 0, step = 0.00001)
t03_tp  = input.float(0.0,       "Take Profit", group = "Trade 03", minval = 0, step = 0.00001)

// ── Trade 04 ──────────────────────────────────────────────────────────────
t04_en  = input.bool(false,      "Enable",      group = "Trade 04")
t04_sym = input.symbol("XAUUSD", "Symbol",      group = "Trade 04")
t04_ent = input.float(0.0,       "Entry",       group = "Trade 04", minval = 0, step = 0.00001)
t04_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 04", minval = 0, step = 0.00001)
t04_tp  = input.float(0.0,       "Take Profit", group = "Trade 04", minval = 0, step = 0.00001)

// ── Trade 05 ──────────────────────────────────────────────────────────────
t05_en  = input.bool(false,      "Enable",      group = "Trade 05")
t05_sym = input.symbol("AUDUSD", "Symbol",      group = "Trade 05")
t05_ent = input.float(0.0,       "Entry",       group = "Trade 05", minval = 0, step = 0.00001)
t05_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 05", minval = 0, step = 0.00001)
t05_tp  = input.float(0.0,       "Take Profit", group = "Trade 05", minval = 0, step = 0.00001)

// ── Trade 06 ──────────────────────────────────────────────────────────────
t06_en  = input.bool(false,      "Enable",      group = "Trade 06")
t06_sym = input.symbol("USDCAD", "Symbol",      group = "Trade 06")
t06_ent = input.float(0.0,       "Entry",       group = "Trade 06", minval = 0, step = 0.00001)
t06_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 06", minval = 0, step = 0.00001)
t06_tp  = input.float(0.0,       "Take Profit", group = "Trade 06", minval = 0, step = 0.00001)

// ── Trade 07 ──────────────────────────────────────────────────────────────
t07_en  = input.bool(false,      "Enable",      group = "Trade 07")
t07_sym = input.symbol("GBPJPY", "Symbol",      group = "Trade 07")
t07_ent = input.float(0.0,       "Entry",       group = "Trade 07", minval = 0, step = 0.00001)
t07_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 07", minval = 0, step = 0.00001)
t07_tp  = input.float(0.0,       "Take Profit", group = "Trade 07", minval = 0, step = 0.00001)

// ── Trade 08 ──────────────────────────────────────────────────────────────
t08_en  = input.bool(false,      "Enable",      group = "Trade 08")
t08_sym = input.symbol("NZDUSD", "Symbol",      group = "Trade 08")
t08_ent = input.float(0.0,       "Entry",       group = "Trade 08", minval = 0, step = 0.00001)
t08_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 08", minval = 0, step = 0.00001)
t08_tp  = input.float(0.0,       "Take Profit", group = "Trade 08", minval = 0, step = 0.00001)

// ── Trade 09 ──────────────────────────────────────────────────────────────
t09_en  = input.bool(false,      "Enable",      group = "Trade 09")
t09_sym = input.symbol("EURGBP", "Symbol",      group = "Trade 09")
t09_ent = input.float(0.0,       "Entry",       group = "Trade 09", minval = 0, step = 0.00001)
t09_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 09", minval = 0, step = 0.00001)
t09_tp  = input.float(0.0,       "Take Profit", group = "Trade 09", minval = 0, step = 0.00001)

// ── Trade 10 ──────────────────────────────────────────────────────────────
t10_en  = input.bool(false,      "Enable",      group = "Trade 10")
t10_sym = input.symbol("EURJPY", "Symbol",      group = "Trade 10")
t10_ent = input.float(0.0,       "Entry",       group = "Trade 10", minval = 0, step = 0.00001)
t10_sl  = input.float(0.0,       "Stop Loss",   group = "Trade 10", minval = 0, step = 0.00001)
t10_tp  = input.float(0.0,       "Take Profit", group = "Trade 10", minval = 0, step = 0.00001)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3 · LIVE PRICE FETCH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

t01_price = request.security(t01_sym, timeframe.period, close)
t02_price = request.security(t02_sym, timeframe.period, close)
t03_price = request.security(t03_sym, timeframe.period, close)
t04_price = request.security(t04_sym, timeframe.period, close)
t05_price = request.security(t05_sym, timeframe.period, close)
t06_price = request.security(t06_sym, timeframe.period, close)
t07_price = request.security(t07_sym, timeframe.period, close)
t08_price = request.security(t08_sym, timeframe.period, close)
t09_price = request.security(t09_sym, timeframe.period, close)
t10_price = request.security(t10_sym, timeframe.period, close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4 · CONSOLIDATE INTO ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int N = 10

bool[]   a_en    = array.from(
     t01_en,    t02_en,    t03_en,    t04_en,    t05_en,
     t06_en,    t07_en,    t08_en,    t09_en,    t10_en)

string[] a_sym   = array.from(
     t01_sym,   t02_sym,   t03_sym,   t04_sym,   t05_sym,
     t06_sym,   t07_sym,   t08_sym,   t09_sym,   t10_sym)

float[]  a_ent   = array.from(
     t01_ent,   t02_ent,   t03_ent,   t04_ent,   t05_ent,
     t06_ent,   t07_ent,   t08_ent,   t09_ent,   t10_ent)

float[]  a_sl    = array.from(
     t01_sl,    t02_sl,    t03_sl,    t04_sl,    t05_sl,
     t06_sl,    t07_sl,    t08_sl,    t09_sl,    t10_sl)

float[]  a_tp    = array.from(
     t01_tp,    t02_tp,    t03_tp,    t04_tp,    t05_tp,
     t06_tp,    t07_tp,    t08_tp,    t09_tp,    t10_tp)

float[]  a_price = array.from(
     t01_price, t02_price, t03_price, t04_price, t05_price,
     t06_price, t07_price, t08_price, t09_price, t10_price)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5 · HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Strip exchange prefix: "FX_IDC:EURUSD" → "EURUSD"
f_ticker(string fullSym) =>
    parts = str.split(fullSym, ":")
    array.size(parts) > 1 ? array.get(parts, array.size(parts) - 1) : fullSym

// Format R value: 1.42 → "+1.42R" | -0.34 → "-0.34R" | 0.0 → "0.00R"
f_rStr(float r) =>
    (r > 0.0 ? "+" : "") + str.tostring(r, "0.00") + "R"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6 · BUILD ACTIVE TRADE DISPLAY LISTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string[] labelList  = array.new_string(0)
string[] rList      = array.new_string(0)

string[] seenTicker = array.new_string(0)
int[]    seenCount  = array.new_int(0)

for i = 0 to N - 1
    en    = array.get(a_en,    i)
    ent   = array.get(a_ent,   i)
    sl    = array.get(a_sl,    i)
    tp    = array.get(a_tp,    i)
    price = array.get(a_price, i)
    sym   = array.get(a_sym,   i)

    if not en or ent == 0.0 or sl == 0.0 or tp == 0.0 or tp == ent or na(price)
        continue

    isLong      = tp > ent
    risk        = math.abs(ent - sl)
    currentMove = isLong ? price - ent : ent - price
    currentR    = risk > 0.0 ? currentMove / risk : 0.0
    ticker      = f_ticker(sym)

    tickerIdx = -1
    for j = 0 to array.size(seenTicker) - 1
        if array.get(seenTicker, j) == ticker
            tickerIdx := j
            break

    num = 0
    if tickerIdx == -1
        array.push(seenTicker, ticker)
        array.push(seenCount,  1)
        num := 1
    else
        prev = array.get(seenCount, tickerIdx)
        num  := prev + 1
        array.set(seenCount, tickerIdx, num)

    array.push(labelList, ticker + " #" + str.tostring(num))
    array.push(rList,     f_rStr(currentR))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7 · RENDER DASHBOARD TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

activeCount = array.size(labelList)

tablePos =
     dashPos == "Top Left"    ? position.top_left    :
     dashPos == "Top Right"   ? position.top_right   :
     dashPos == "Bottom Left" ? position.bottom_left :
                                 position.bottom_right

dataRows  = math.max(activeCount, 1)
totalRows = 1 + dataRows

C_TEXT   = color.white
C_HEAD   = color.new(color.gray,  25)
C_DATA   = color.new(color.black, 45)
C_BORDER = color.new(color.gray,  65)
C_MUTED  = color.new(color.white, 60)

dash = table.new(
     position     = tablePos,
     columns      = 2,
     rows         = totalRows,
     border_width = 1,
     border_color = C_BORDER,
     frame_width  = 1,
     frame_color  = C_BORDER
)

table.cell(dash, 0, 0,
     text        = "LIVE R:R",
     text_color  = C_TEXT,
     bgcolor     = C_HEAD,
     text_size   = size.small,
     text_halign = text.align_left)
table.cell(dash, 1, 0,
     text    = "",
     bgcolor = C_HEAD)

if activeCount == 0
    table.cell(dash, 0, 1,
         text        = "No active trades",
         text_color  = C_MUTED,
         bgcolor     = C_DATA,
         text_size   = size.tiny,
         text_halign = text.align_left)
    table.cell(dash, 1, 1,
         text    = "",
         bgcolor = C_DATA)
else
    for r = 0 to activeCount - 1
        table.cell(dash, 0, r + 1,
             text        = array.get(labelList, r),
             text_color  = C_TEXT,
             bgcolor     = C_DATA,
             text_size   = size.small,
             text_halign = text.align_left)
        table.cell(dash, 1, r + 1,
             text        = array.get(rList, r),
             text_color  = C_TEXT,
             bgcolor     = C_DATA,
             text_size   = size.small,
             text_halign = text.align_right)
````
