# Liquidity Sweep Breadth [Zen]

- url: https://www.tradingview.com/script/2GoE0V92-Liquidity-Sweep-Breadth-Zen/
- type: indicator
- pine_id: PUB;bd49ab30ba7346be8f1b09c0666a4b54
- version: 2.0

## Description

Liquidity Sweep Breadth [Zen] is built for USDT perpetual futures. On every closed candle it counts how many coins in a basket swept their own liquidity pool - the highest high or the lowest low of their previous N candles (20 by default). The share of the basket is drawn in the lower pane: up for highs, down for lows. When many coins sweep the same side on one candle, the price chart gets a MARKET SWEEP label (one label per wave). When the chart coin sweeps a pool while almost no other coin does, it gets an ALONE label.

WHAT IS ORIGINAL
Breadth indicators usually count how many coins are above a moving average or at new highs. This one counts liquidity sweeps:
- Every coin is checked against its own pool, built from its own previous candles on the same exchange and timeframe. Coins trade at different prices; what is compared is whether each coin took its own level on that candle.
- The result is a share of the coins that have data on that candle, not a fixed count, so a coin that was listed later or is missing on the exchange does not distort it.
- A market-wide sweep (many coins swept the same side on the same candle) and a sweep made alone (the chart coin swept while almost no other coin did) are marked on the price chart, not only in the lower pane.
- A heatmap table shows every coin over the last 12 closed candles: which coin swept which side and when.
Relation to my other scripts: Cross-Exchange Sweep [Zen] and Sweep OI Flush [Zen] use the same sweep rule on one coin: the first checks it on four exchanges, the second classifies it by open interest. This script uses no open interest and checks many coins on one exchange on the same candle. Untouched Levels [Zen] shows a table of levels that have not been touched yet; this table shows the sweeps that already happened, candle by candle. None of them has the basket share, the market-wide threshold or the sweep heatmap, so this is a separate script, not an update of any of them.

HOW IT CALCULATES
- Pool of a coin: the highest high and the lowest low of its previous N closed candles (Pool length, 20 by default).
- High sweep: the candle's high goes above the pool high and the candle closes below it. Low sweep: the low goes below the pool low and the candle closes above it. One candle can sweep both sides; such a coin counts for both.
- Each coin of the basket is requested as EXCHANGE:COINUSDT.P on the chart's timeframe. Only the coin's candle with the same open time as the chart candle is used. A coin has no data on a candle when it has no candle with that open time, when the ticker does not exist on the exchange, or when fewer than N of its earlier candles are loaded.
- Share of highs = coins that swept their high / coins with data. The same for lows.
- A candle is used only when at least half of the basket and at least 5 coins have data (a basket of fewer than 5 coins needs all of them). Otherwise the candle gets no column, label, alert or count; the table still shows each coin's own result on it.
- Market-wide sweep: the share of one side is at or above the threshold (40% by default).
- Swept alone: the candle has enough data, the chart coin swept a side by the same rule on its own chart, the candle is not market-wide on that side, and at most 10% (by default) of the other coins with data swept the same side. If the chart coin is in the basket (same coin name), it is left out of the other coins.

ON THE CHART
- Lower pane: orange columns up = share of coins that swept their high, blue columns down = share that swept their low, in percent. Dashed lines at plus and minus the threshold. Columns of market-wide candles are bright, the others are pale. The open candle has no column.
- Price chart, label MARKET SWEEP with two numbers, for example "MARKET SWEEP 12/20": 12 of the 20 coins with data swept that side. Orange above the candle for highs, blue below the candle for lows.
- One label per wave: when the previous closed candle was already market-wide on the same side, the new candle's column is still bright but no second label is drawn, so labels on neighbouring candles do not overlap. Alerts and table counts still include every market-wide candle.
- Label ALONE, for example "ALONE 1/19": the chart coin swept alone; 1 of the 19 other coins with data swept the same side.
- Up to the 200 latest labels are kept on the chart.

TABLE (on the price chart, middle left by default)
- Header: script name, timeframe and exchange.
- "Market-wide since": the date (UTC) of the first candle with enough data, and the number of market-wide candles for highs and for lows since then. Every market-wide candle is counted, including the next candles of a wave.
- One row per coin; the chart coin is highlighted. 12 columns = the last 12 closed candles, the oldest on the left. Up triangle = high swept, down triangle = low swept, diamond = both, dash = no data, empty = no sweep.
- Right column: candles since that coin's last sweep on either side, counted from the open candle (1 = the last closed candle). A dash means no sweep in the loaded history.
- Last row: how many coins swept highs and lows on the last closed candle, out of the coins with data, and a legend.

ALERTS
All alerts fire at candle close.
- "Any alert() function call": one plain-text message per candle with everything that happened on it, for example "BTCUSDT.P 1m: high swept alone, other coins 0/19." A market-wide message also lists the coins that swept: "TICKER TF: market-wide low sweep 12/20 (coin list)."
- Three alert conditions: "Market-wide high sweep", "Market-wide low sweep" and "Chart coin swept alone". Their messages include the exchange, ticker and timeframe.
- When you create the alert, TradingView shows a warning that the indicator can repaint. What can differ between a live result and the reloaded chart is explained in the realtime section below.

HOW TO USE
- Exchange = Chart (the default) uses the chart's exchange. The other options are BITGET, BINANCE, BYBIT and OKX. If the chart's exchange has no COINUSDT.P tickers, choose one of these; otherwise every coin shows a dash and nothing is calculated. A coin that is not listed on the selected exchange shows a dash. The default basket was checked on Bitget and Bybit.
- When your coin sweeps a pool, look at the lower pane on that candle. A bright column means that many coins swept the same side at the same time; the first candle of such a wave also gets a MARKET SWEEP label. ALONE means your coin did it while almost no other coin did.
- The heatmap shows which coins swept recently; the right column shows how long ago.
- The basket can be edited: up to 20 coins, comma separated (only the first 20 are used); letter case and spaces do not matter.
- It is context for your own analysis, not an entry signal.

INPUTS (defaults)
- Coins: BTC, ETH, SOL, XRP, BNB, DOGE, ADA, TRX, AVAX, LINK, DOT, LTC, BCH, SUI, NEAR, APT, ARB, OP, UNI, ATOM
- Exchange: Chart (also BITGET, BINANCE, BYBIT, OKX)
- Pool length (bars): 20 (5 to 200)
- Market-wide threshold %: 40 (10 to 100)
- Swept alone: others at most %: 10 (0 to 50)
- Show chart markers: on
- Show table: on
- Table position: middle left
The defaults were chosen on the 4H chart.

REALTIME BEHAVIOUR AND LIMITS
- Everything is calculated on closed candles only; the open candle has no column, label or alert.
- On a live candle, each coin's values are the latest received when the chart candle closes. If a coin has already opened its next candle, its just-closed candle is used. If a coin's final prices for that candle arrive later, a label or alert produced live can differ from what the chart shows after a reload, because the history then uses the final data.
- Results depend on the exchange: wicks differ between exchanges, so the same candle can be market-wide on one exchange and not on another.
- The counts in the table cover the loaded history only, so they depend on how much history the chart loads; the start date is shown.
- A coin listed under a different name on the exchange (for example with a 1000 prefix) shows a dash until you type its name exactly as the exchange lists it before USDT.P. While it shows a dash, it is left out of the share but still counts in the basket size for the half-of-the-basket rule.
- When the chart is zoomed far out, labels can overlap. Zoom in or turn off Show chart markers.
- Use standard candles. On Heikin Ashi, Renko and other synthetic chart types the chart coin's own sweep is based on synthetic prices.
- Colours follow the chart theme (light or dark) automatically.

Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
//@version=6
indicator("Liquidity Sweep Breadth [Zen]", overlay = false, max_labels_count = 200, precision = 0)

// Liquidity Sweep Breadth [Zen]
// On every closed candle: how many coins of a basket swept their own liquidity pool
// (wick beyond the high / low of their previous N closed candles, close back inside).
// The share of the basket is shown as a histogram, market-wide sweeps and "swept alone" are marked on the chart,
// and a heatmap table shows every coin over the last 12 closed candles.

// ---------- inputs ----------
gB = "Basket"
basketIn = input.string("BTC,ETH,SOL,XRP,BNB,DOGE,ADA,TRX,AVAX,LINK,DOT,LTC,BCH,SUI,NEAR,APT,ARB,OP,UNI,ATOM", "Coins", group = gB, display = display.none, tooltip = "Up to 20 coins, comma separated. Each one is requested as EXCHANGE:COINUSDT.P. A coin that is not found on the exchange shows a dash and is left out of the share.")
exIn     = input.string("Chart", "Exchange", options = ["Chart", "BITGET", "BINANCE", "BYBIT", "OKX"], group = gB, display = display.none, tooltip = "Chart = the exchange of the chart symbol.")
gS = "Sweep"
poolLen  = input.int(20, "Pool length (bars)", minval = 5, maxval = 200, group = gS, display = display.none, tooltip = "Pool = highest high / lowest low of the previous N closed bars, computed on every coin separately.")
thrPc    = input.float(40.0, "Market-wide threshold %", minval = 10.0, maxval = 100.0, step = 5.0, group = gS, display = display.none, tooltip = "A candle is a market-wide sweep when at least this share of the coins with data swept the same side.")
alonePc  = input.float(10.0, "Swept alone: others at most %", minval = 0.0, maxval = 50.0, step = 5.0, group = gS, display = display.none, tooltip = "The chart coin swept a side while at most this share of the other coins swept the same side.")
gD = "Display"
showMk   = input.bool(true, "Show chart markers", group = gD, display = display.none)
showTbl  = input.bool(true, "Show table", group = gD, display = display.none)
tblPosIn = input.string("Middle left", "Table position", options = ["Middle left", "Bottom right", "Top right", "Bottom left", "Top left"], group = gD, display = display.none)

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI     = isLight ? #AD4A12 : #D9703A
color cLO     = isLight ? #1B46B4 : #6F88EE
color cMUTED  = isLight ? #505C69 : #9AA3B2
color cINK    = isLight ? #1F2937 : #D1D4DC
color cPANEL  = isLight ? #F4F5F7 : #1E222D
color cHEAD   = #2A2E39
color cHEADTX = isLight ? #FFFFFF : #D1D4DC
color cBORDER = isLight ? #C4C8CE : #363A45
color cSOLID  = isLight ? #FFFFFF : #131722

// ---------- basket ----------
string ex = exIn == "Chart" ? syminfo.prefix : exIn
array<string> coins = str.split(str.upper(str.replace_all(basketIn, " ", "")), ",")
int nC = math.min(array.size(coins), 20)
// a candle is counted only when at least half of the basket (min 5 coins, or the whole basket if it is smaller) has data on it
int minData = math.min(nC, math.max(5, int(math.ceil(nC * 0.5))))

// sweep code of one coin on its own candle: -1 no data, 0 none, 1 high, 2 low, 3 both
// on a live bar the coin may already have opened its next candle, so the current and the previous candle
// are both requested and the one whose time equals the chart candle's time is used
f_code() =>
    float ph = ta.highest(high, poolLen)[1]
    float pl = ta.lowest(low, poolLen)[1]
    int c = bar_index < poolLen ? -1 : (high > ph and close < ph ? 1 : 0) + (low < pl and close > pl ? 2 : 0)
    [c, time, c[1], time[1]]

array<int> cur = array.new<int>(20, -1)
for i = 0 to nC - 1
    string tkr = ex + ":" + array.get(coins, i) + "USDT.P"
    [cA, tA, cB, tB] = request.security(tkr, timeframe.period, f_code(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    int c = tA == time ? cA : tB == time ? cB : na
    array.set(cur, i, na(c) ? -1 : c)

// ---------- breadth on this candle ----------
int nData = 0
int nHi = 0
int nLo = 0
int oData = 0
int oHi = 0
int oLo = 0
for i = 0 to nC - 1
    int c = array.get(cur, i)
    bool mine = array.get(coins, i) == syminfo.basecurrency
    if c >= 0
        nData += 1
        nHi += c == 1 or c == 3 ? 1 : 0
        nLo += c == 2 or c == 3 ? 1 : 0
        if not mine
            oData += 1
            oHi += c == 1 or c == 3 ? 1 : 0
            oLo += c == 2 or c == 3 ? 1 : 0
bool enough = nData >= minData
float fHi = enough ? 100.0 * nHi / nData : na
float fLo = enough ? 100.0 * nLo / nData : na
float oHiPc = enough and oData > 0 ? 100.0 * oHi / oData : na
float oLoPc = enough and oData > 0 ? 100.0 * oLo / oData : na

// the chart coin's own sweep (same rule)
float myPh = ta.highest(high, poolLen)[1]
float myPl = ta.lowest(low, poolLen)[1]
bool meHi = bar_index >= poolLen and high > myPh and close < myPh
bool meLo = bar_index >= poolLen and low < myPl and close > myPl

bool done = barstate.isconfirmed
bool mktHi = done and fHi >= thrPc
bool mktLo = done and fLo >= thrPc
bool aloneHi = done and meHi and oHiPc <= alonePc and not mktHi
bool aloneLo = done and meLo and oLoPc <= alonePc and not mktLo

f_tf() => timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.period

// ---------- panel: share of the basket that swept highs (up) / lows (down) ----------
plot(done ? fHi : na, "Highs swept %", color = mktHi ? cHI : color.new(cHI, 65), style = plot.style_columns)
plot(done ? -fLo : na, "Lows swept %", color = mktLo ? cLO : color.new(cLO, 65), style = plot.style_columns)
hline(thrPc, "Market-wide (highs)", color = cMUTED, linestyle = hline.style_dashed)
hline(-thrPc, "Market-wide (lows)", color = cMUTED, linestyle = hline.style_dashed)
hline(0, "Zero", color = cBORDER, linestyle = hline.style_solid)

// ---------- markers on the main chart ----------
// one label per wave: when the previous closed candle was already market-wide on the same side,
// the column stays bright but no second label is drawn, so labels on neighbouring candles do not overlap
bool newHi = mktHi and not mktHi[1]
bool newLo = mktLo and not mktLo[1]
if showMk and newHi
    label.new(bar_index, high, "MARKET SWEEP " + str.tostring(nHi) + "/" + str.tostring(nData), style = label.style_label_down, color = cHI, textcolor = cSOLID, size = size.small, force_overlay = true)
if showMk and newLo
    label.new(bar_index, low, "MARKET SWEEP " + str.tostring(nLo) + "/" + str.tostring(nData), style = label.style_label_up, color = cLO, textcolor = cSOLID, size = size.small, force_overlay = true)
if showMk and aloneHi
    label.new(bar_index, high, "ALONE " + str.tostring(oHi) + "/" + str.tostring(oData), style = label.style_label_down, color = cPANEL, textcolor = cHI, size = size.small, force_overlay = true)
if showMk and aloneLo
    label.new(bar_index, low, "ALONE " + str.tostring(oLo) + "/" + str.tostring(oData), style = label.style_label_up, color = cPANEL, textcolor = cLO, size = size.small, force_overlay = true)

// ---------- history ----------
int HM = 12
var matrix<int> hm = matrix.new<int>(20, HM, -2)
var array<int> lastBar = array.new<int>(20, na)
var int cntHi = 0
var int cntLo = 0
var int firstT = na
if done
    matrix.remove_col(hm, 0)
    matrix.add_col(hm, HM - 1, cur)
    for i = 0 to nC - 1
        if array.get(cur, i) > 0
            array.set(lastBar, i, bar_index)
    cntHi += mktHi ? 1 : 0
    cntLo += mktLo ? 1 : 0
    if enough and na(firstT)
        firstT := time

// ---------- heatmap table: coins x last 12 closed candles (on the main chart) ----------
tblPos = switch tblPosIn
    "Middle left"  => position.middle_left
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_left

var table tb = table.new(tblPos, HM + 2, 23, bgcolor = cPANEL, frame_color = cBORDER, frame_width = 1, border_width = 1, border_color = cPANEL, force_overlay = true)
if barstate.isfirst and showTbl
    table.merge_cells(tb, 0, 0, HM + 1, 0)
    table.merge_cells(tb, 0, 1, HM + 1, 1)
    table.merge_cells(tb, 0, nC + 2, HM + 1, nC + 2)

if barstate.islast and showTbl
    table.cell(tb, 0, 0, "Liquidity Sweep Breadth [Zen] · " + f_tf() + " · " + ex, text_color = cHEADTX, bgcolor = cHEAD, text_size = size.small)
    // no candle with enough basket data in the whole history (usually a chart exchange without USDT.P perpetuals): say how to fix it
    string infoTxt = na(firstT) ? "Not enough COINUSDT.P data on " + ex + ".\nSettings > Exchange: BITGET, BINANCE, BYBIT or OKX." : "Market-wide since " + str.format_time(firstT, "yyyy-MM-dd", "UTC") + "\nhighs " + str.tostring(cntHi) + " · lows " + str.tostring(cntLo)
    table.cell(tb, 0, 1, infoTxt, text_color = na(firstT) ? cHI : cMUTED, text_size = size.tiny, text_halign = text.align_left)
    int sHi = 0
    int sLo = 0
    int sData = 0
    for i = 0 to nC - 1
        string nm = array.get(coins, i)
        bool mine = nm == syminfo.basecurrency
        table.cell(tb, 0, i + 2, nm, text_color = mine ? cINK : cMUTED, bgcolor = mine ? color.new(cMUTED, 80) : cPANEL, text_size = size.tiny, text_halign = text.align_left)
        for k = 0 to HM - 1
            int c = matrix.get(hm, i, k)
            string t = c == 1 ? "▲" : c == 2 ? "▼" : c == 3 ? "◆" : c == -1 ? "–" : ""
            color bg = c == 1 ? color.new(cHI, 70) : c == 2 ? color.new(cLO, 70) : c == 3 ? color.new(cMUTED, 60) : cPANEL
            color tx = c == 1 ? cHI : c == 2 ? cLO : c == -1 ? cMUTED : cINK
            table.cell(tb, k + 1, i + 2, t, text_color = tx, bgcolor = bg, text_size = size.tiny)
        int lb = array.get(lastBar, i)
        table.cell(tb, HM + 1, i + 2, na(lb) ? "—" : str.tostring(bar_index - lb), text_color = cMUTED, text_size = size.tiny, text_halign = text.align_right)
        int cl = matrix.get(hm, i, HM - 1)
        if cl >= 0
            sData += 1
            sHi += cl == 1 or cl == 3 ? 1 : 0
            sLo += cl == 2 or cl == 3 ? 1 : 0
    table.cell(tb, 0, nC + 2, "Last closed: highs " + str.tostring(sHi) + "/" + str.tostring(sData) + " · lows " + str.tostring(sLo) + "/" + str.tostring(sData) + "\n▲ high  ▼ low  ◆ both  · right: bars since sweep", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)

// ---------- alerts (closed candle) ----------
f_list(int side) =>
    string out = ""
    for i = 0 to nC - 1
        int c = array.get(cur, i)
        if c == 3 or c == side
            out += (out == "" ? "" : ", ") + array.get(coins, i)
    out
string pre = syminfo.ticker + " " + f_tf() + ": "
string amsg = ""
if mktHi
    amsg += pre + "market-wide high sweep " + str.tostring(nHi) + "/" + str.tostring(nData) + " (" + f_list(1) + "). "
if mktLo
    amsg += pre + "market-wide low sweep " + str.tostring(nLo) + "/" + str.tostring(nData) + " (" + f_list(2) + "). "
if aloneHi
    amsg += pre + "high swept alone, other coins " + str.tostring(oHi) + "/" + str.tostring(oData) + ". "
if aloneLo
    amsg += pre + "low swept alone, other coins " + str.tostring(oLo) + "/" + str.tostring(oData) + ". "
if amsg != ""
    alert(amsg, alert.freq_once_per_bar_close)
alertcondition(mktHi, "Market-wide high sweep", "{{exchange}}:{{ticker}} {{interval}} Liquidity Sweep Breadth: market-wide high sweep")
alertcondition(mktLo, "Market-wide low sweep", "{{exchange}}:{{ticker}} {{interval}} Liquidity Sweep Breadth: market-wide low sweep")
alertcondition(aloneHi or aloneLo, "Chart coin swept alone", "{{exchange}}:{{ticker}} {{interval}} Liquidity Sweep Breadth: chart coin swept alone")
````
