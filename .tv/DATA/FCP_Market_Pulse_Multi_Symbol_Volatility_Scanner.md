<!-- tradingview-pine-id: PUB;63325c1fca0a4354b872d71fb812a31c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FCP | Market Pulse | Multi Symbol Volatility Scanner

Source: https://www.tradingview.com/script/DPvrBqMm-FCP-Market-Pulse-Multi-Symbol-Volatility-Scanner/

## Description

Market Pulse ranks up to 40 symbols by how violent their current candle is relative to their own recent behaviour.

THE METRIC

For every symbol on a fixed scan timeframe:

ratio = (high − low) / ATR(14)

The ATR is read from the previous bar, so an explosive candle cannot inflate its own baseline and cancel itself out. Because the range is divided by that symbol's own ATR, the number is unitless — a 2.5 on EURUSD and a 2.5 on BTCUSDT mean the same thing. One threshold works for FX, indices, metals and crypto at once, which a pip- or percent-based filter cannot do.

A symbol is listed when its ratio reaches the trigger multiple. Anything below it is ignored, so the panel stays empty most of the time and only fills up when something is actually happening.

READING THE PANEL

SYMBOL — the live scan period, sorted by ratio, strongest first
PREVIOUS — the same list for the last closed period, so a chart opened mid-period still shows what just moved
xATR — how many times its own average range the candle has covered
CHG% — direction and size of the move, (close − open) / open
▲ ▼ — green for an up candle, red for a down candle

"quiet" means nothing crossed the threshold. That is the normal state.

Nothing is stored between periods. A symbol drops off by itself as soon as it cools down, and markets that are closed are excluded so a frozen quote is never reported as a live burst.

SETTINGS

Scan timeframe — every symbol is measured on this timeframe regardless of the chart. Keep the chart at the same timeframe or lower.
ATR length — default 14.
Trigger at N x ATR — 2.0 to 2.5 catches ordinary bursts, 5 catches only major shocks.
Symbols — 40 slots, each a checkbox plus a symbol picker. Untick a slot to drop it from the panel and the alert. Retarget any slot to your own data provider.

ALERTS

Create the alert with "Any alert() function call". One alert fires per closed scan bar and lists every symbol over the threshold, in the same order the panel shows them.

The Telegram JSON option formats the message as a ready-to-post sendMessage payload. Enter your own chat id, then point the alert webhook at the Telegram sendMessage API endpoint for your bot.

Webhooks require a paid TradingView plan with two-factor authentication enabled. Your bot token lives only in the webhook URL — it is never part of this script. Never share it or screenshot the alert dialog; if it leaks, revoke it in BotFather.

Turn the option off if you route alerts through your own relay server instead.

LIMITS

40 symbols is a hard ceiling — Pine allows no more than 40 data requests per script.

---

## Source Code

````pine
//@version=6
indicator("FCP | Market Pulse | Multi Symbol Volatility Scanner", overlay = true)

// ─────────────────────────────  inputs  ─────────────────────────────────────
grpScan  = "Scan"
grpPanel = "Panel"
grpTg    = "Alert"
grpSyms  = "Symbols"

tfScan   = input.timeframe("30", "Scan timeframe", group = grpScan, tooltip = "Every symbol is measured on this timeframe regardless of the chart timeframe. Keep the chart on the same timeframe or lower, otherwise the historical panel values will be misleading.", display = display.none)
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 200, group = grpScan, display = display.none)
mult     = input.float(2.0, "Trigger at N x ATR", minval = 0.5, step = 0.1, group = grpScan, tooltip = "A candle qualifies when its range is at least this many times the average range. 2.0-2.5 catches ordinary bursts, 5 catches only major news shocks.", display = display.none)

pnlShow  = input.bool(true, "Show panel", group = grpPanel, display = display.none)
pnlPos   = input.string("Top right", "Corner", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpPanel, display = display.none)
pnlPrev  = input.bool(true, "Show previous period", group = grpPanel, tooltip = "Adds a second block beside the live one holding the last closed period's result, so someone opening the chart mid-period can still see what just moved.", display = display.none)

COL_UP = #26A69A
COL_DN = #EF5350

tgJson   = input.bool(true, "Wrap alert as Telegram JSON", group = grpTg, tooltip = "On = the alert body is a ready-to-post sendMessage payload. Point the webhook at https://api.telegram.org/bot<TOKEN>/sendMessage and create the alert with 'Any alert() function call'. Turn off once a relay server sits in between.", display = display.none)
tgChat   = input.string("", "Telegram chat id", group = grpTg, display = display.none)

// ─────────────────────────────  symbols  ────────────────────────────────────
use01 = input.bool(true,  "", inline = "01", group = grpSyms, display = display.none)
sym01 = input.symbol("TVC:DXY",           "01", inline = "01", group = grpSyms, display = display.none)
use02 = input.bool(true,  "", inline = "02", group = grpSyms, display = display.none)
sym02 = input.symbol("TVC:VIX",           "02", inline = "02", group = grpSyms, display = display.none)
use03 = input.bool(true,  "", inline = "03", group = grpSyms, display = display.none)
sym03 = input.symbol("TVC:US10Y",         "03", inline = "03", group = grpSyms, display = display.none)
use04 = input.bool(true,  "", inline = "04", group = grpSyms, display = display.none)
sym04 = input.symbol("OANDA:US30USD",     "04", inline = "04", group = grpSyms, display = display.none)
use05 = input.bool(true,  "", inline = "05", group = grpSyms, display = display.none)
sym05 = input.symbol("OANDA:NAS100USD",   "05", inline = "05", group = grpSyms, display = display.none)
use06 = input.bool(true,  "", inline = "06", group = grpSyms, display = display.none)
sym06 = input.symbol("OANDA:SPX500USD",   "06", inline = "06", group = grpSyms, display = display.none)
use07 = input.bool(true,  "", inline = "07", group = grpSyms, display = display.none)
sym07 = input.symbol("OANDA:DE30EUR",     "07", inline = "07", group = grpSyms, display = display.none)
use08 = input.bool(true,  "", inline = "08", group = grpSyms, display = display.none)
sym08 = input.symbol("OANDA:UK100GBP",    "08", inline = "08", group = grpSyms, display = display.none)
use09 = input.bool(true,  "", inline = "09", group = grpSyms, display = display.none)
sym09 = input.symbol("OANDA:JP225USD",    "09", inline = "09", group = grpSyms, display = display.none)
use10 = input.bool(true,  "", inline = "10", group = grpSyms, display = display.none)
sym10 = input.symbol("OANDA:XAUUSD",      "10", inline = "10", group = grpSyms, display = display.none)
use11 = input.bool(true,  "", inline = "11", group = grpSyms, display = display.none)
sym11 = input.symbol("OANDA:XAGUSD",      "11", inline = "11", group = grpSyms, display = display.none)
use12 = input.bool(true,  "", inline = "12", group = grpSyms, display = display.none)
sym12 = input.symbol("OANDA:XCUUSD",      "12", inline = "12", group = grpSyms, display = display.none)
use13 = input.bool(true,  "", inline = "13", group = grpSyms, display = display.none)
sym13 = input.symbol("OANDA:WTICOUSD",    "13", inline = "13", group = grpSyms, display = display.none)
use14 = input.bool(true,  "", inline = "14", group = grpSyms, display = display.none)
sym14 = input.symbol("OANDA:BCOUSD",      "14", inline = "14", group = grpSyms, display = display.none)
use15 = input.bool(true,  "", inline = "15", group = grpSyms, display = display.none)
sym15 = input.symbol("OANDA:NATGASUSD",   "15", inline = "15", group = grpSyms, display = display.none)
use16 = input.bool(true,  "", inline = "16", group = grpSyms, display = display.none)
sym16 = input.symbol("OANDA:EURUSD",      "16", inline = "16", group = grpSyms, display = display.none)
use17 = input.bool(true,  "", inline = "17", group = grpSyms, display = display.none)
sym17 = input.symbol("OANDA:GBPUSD",      "17", inline = "17", group = grpSyms, display = display.none)
use18 = input.bool(true,  "", inline = "18", group = grpSyms, display = display.none)
sym18 = input.symbol("OANDA:USDJPY",      "18", inline = "18", group = grpSyms, display = display.none)
use19 = input.bool(true,  "", inline = "19", group = grpSyms, display = display.none)
sym19 = input.symbol("OANDA:USDCHF",      "19", inline = "19", group = grpSyms, display = display.none)
use20 = input.bool(true,  "", inline = "20", group = grpSyms, display = display.none)
sym20 = input.symbol("OANDA:USDCAD",      "20", inline = "20", group = grpSyms, display = display.none)
use21 = input.bool(true,  "", inline = "21", group = grpSyms, display = display.none)
sym21 = input.symbol("OANDA:AUDUSD",      "21", inline = "21", group = grpSyms, display = display.none)
use22 = input.bool(true,  "", inline = "22", group = grpSyms, display = display.none)
sym22 = input.symbol("OANDA:NZDUSD",      "22", inline = "22", group = grpSyms, display = display.none)
use23 = input.bool(true,  "", inline = "23", group = grpSyms, display = display.none)
sym23 = input.symbol("OANDA:GBPJPY",      "23", inline = "23", group = grpSyms, display = display.none)
use24 = input.bool(true,  "", inline = "24", group = grpSyms, display = display.none)
sym24 = input.symbol("OANDA:EURJPY",      "24", inline = "24", group = grpSyms, display = display.none)
use25 = input.bool(true,  "", inline = "25", group = grpSyms, display = display.none)
sym25 = input.symbol("BINANCE:BTCUSDT",   "25", inline = "25", group = grpSyms, display = display.none)
use26 = input.bool(true,  "", inline = "26", group = grpSyms, display = display.none)
sym26 = input.symbol("BINANCE:ETHUSDT",   "26", inline = "26", group = grpSyms, display = display.none)
use27 = input.bool(true,  "", inline = "27", group = grpSyms, display = display.none)
sym27 = input.symbol("BINANCE:SOLUSDT",   "27", inline = "27", group = grpSyms, display = display.none)
use28 = input.bool(true,  "", inline = "28", group = grpSyms, display = display.none)
sym28 = input.symbol("BINANCE:LTCUSDT",   "28", inline = "28", group = grpSyms, display = display.none)
use29 = input.bool(true,  "", inline = "29", group = grpSyms, display = display.none)
sym29 = input.symbol("BINANCE:BNBUSDT",   "29", inline = "29", group = grpSyms, display = display.none)
use30 = input.bool(true,  "", inline = "30", group = grpSyms, display = display.none)
sym30 = input.symbol("BINANCE:XRPUSDT",   "30", inline = "30", group = grpSyms, display = display.none)
use31 = input.bool(true,  "", inline = "31", group = grpSyms, display = display.none)
sym31 = input.symbol("CRYPTOCAP:TOTAL",   "31", inline = "31", group = grpSyms, display = display.none)
use32 = input.bool(true,  "", inline = "32", group = grpSyms, display = display.none)
sym32 = input.symbol("KUCOIN:HYPEUSDT",   "32", inline = "32", group = grpSyms, display = display.none)
use33 = input.bool(true,  "", inline = "33", group = grpSyms, display = display.none)
sym33 = input.symbol("BINANCE:NEARUSDT",  "33", inline = "33", group = grpSyms, display = display.none)
use34 = input.bool(true,  "", inline = "34", group = grpSyms, display = display.none)
sym34 = input.symbol("BINANCE:DOGEUSDT",  "34", inline = "34", group = grpSyms, display = display.none)
use35 = input.bool(true,  "", inline = "35", group = grpSyms, display = display.none)
sym35 = input.symbol("BINANCE:AVAXUSDT",  "35", inline = "35", group = grpSyms, display = display.none)
use36 = input.bool(true,  "", inline = "36", group = grpSyms, display = display.none)
sym36 = input.symbol("BINANCE:LINKUSDT",  "36", inline = "36", group = grpSyms, display = display.none)
use37 = input.bool(true,  "", inline = "37", group = grpSyms, display = display.none)
sym37 = input.symbol("BINANCE:TRXUSDT",   "37", inline = "37", group = grpSyms, display = display.none)
use38 = input.bool(false, "", inline = "38", group = grpSyms, display = display.none)
sym38 = input.symbol("", "38", inline = "38", group = grpSyms, display = display.none)
use39 = input.bool(false, "", inline = "39", group = grpSyms, display = display.none)
sym39 = input.symbol("", "39", inline = "39", group = grpSyms, display = display.none)
use40 = input.bool(false, "", inline = "40", group = grpSyms, display = display.none)
sym40 = input.symbol("", "40", inline = "40", group = grpSyms, display = display.none)

// ─────────────────────────────  probe  ──────────────────────────────────────
probe() =>
    a = ta.atr(atrLen)[1]
    r = na(a) or a <= 0 ? 0.0 : (high - low) / a
    c = open == 0 ? 0.0 : (close - open) / open * 100.0
    [r, c, time]

scan(simple string sym) =>
    request.security(sym == "" ? syminfo.tickerid : sym, tfScan, probe(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true, calc_bars_count = 1500)

[r01, c01, t01] = scan(sym01)
[r02, c02, t02] = scan(sym02)
[r03, c03, t03] = scan(sym03)
[r04, c04, t04] = scan(sym04)
[r05, c05, t05] = scan(sym05)
[r06, c06, t06] = scan(sym06)
[r07, c07, t07] = scan(sym07)
[r08, c08, t08] = scan(sym08)
[r09, c09, t09] = scan(sym09)
[r10, c10, t10] = scan(sym10)
[r11, c11, t11] = scan(sym11)
[r12, c12, t12] = scan(sym12)
[r13, c13, t13] = scan(sym13)
[r14, c14, t14] = scan(sym14)
[r15, c15, t15] = scan(sym15)
[r16, c16, t16] = scan(sym16)
[r17, c17, t17] = scan(sym17)
[r18, c18, t18] = scan(sym18)
[r19, c19, t19] = scan(sym19)
[r20, c20, t20] = scan(sym20)
[r21, c21, t21] = scan(sym21)
[r22, c22, t22] = scan(sym22)
[r23, c23, t23] = scan(sym23)
[r24, c24, t24] = scan(sym24)
[r25, c25, t25] = scan(sym25)
[r26, c26, t26] = scan(sym26)
[r27, c27, t27] = scan(sym27)
[r28, c28, t28] = scan(sym28)
[r29, c29, t29] = scan(sym29)
[r30, c30, t30] = scan(sym30)
[r31, c31, t31] = scan(sym31)
[r32, c32, t32] = scan(sym32)
[r33, c33, t33] = scan(sym33)
[r34, c34, t34] = scan(sym34)
[r35, c35, t35] = scan(sym35)
[r36, c36, t36] = scan(sym36)
[r37, c37, t37] = scan(sym37)
[r38, c38, t38] = scan(sym38)
[r39, c39, t39] = scan(sym39)
[r40, c40, t40] = scan(sym40)

useArr = array.from(use01, use02, use03, use04, use05, use06, use07, use08, use09, use10, use11, use12, use13, use14, use15, use16, use17, use18, use19, use20, use21, use22, use23, use24, use25, use26, use27, use28, use29, use30, use31, use32, use33, use34, use35, use36, use37, use38, use39, use40)
symArr = array.from(sym01, sym02, sym03, sym04, sym05, sym06, sym07, sym08, sym09, sym10, sym11, sym12, sym13, sym14, sym15, sym16, sym17, sym18, sym19, sym20, sym21, sym22, sym23, sym24, sym25, sym26, sym27, sym28, sym29, sym30, sym31, sym32, sym33, sym34, sym35, sym36, sym37, sym38, sym39, sym40)
ratArr = array.from(r01, r02, r03, r04, r05, r06, r07, r08, r09, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40)
chgArr = array.from(c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, c31, c32, c33, c34, c35, c36, c37, c38, c39, c40)
timArr = array.from(t01, t02, t03, t04, t05, t06, t07, t08, t09, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23, t24, t25, t26, t27, t28, t29, t30, t31, t32, t33, t34, t35, t36, t37, t38, t39, t40)

SLOTS   = 40
staleMs = 3 * timeframe.in_seconds(tfScan) * 1000

shortName(string s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

// ─────────────────────────────  evaluate  ───────────────────────────────────
hitSym = array.new<string>()
hitRat = array.new<float>()
hitChg = array.new<float>()

for i = 0 to SLOTS - 1
    u = array.get(useArr, i)
    s = array.get(symArr, i)
    r = array.get(ratArr, i)
    c = array.get(chgArr, i)
    t = array.get(timArr, i)

    stale = na(t) or (time - t) > staleMs
    ok    = u and s != "" and not na(r) and not stale and r >= mult

    if ok
        array.push(hitSym, s)
        array.push(hitRat, r)
        array.push(hitChg, c)

hitN   = array.size(hitRat)
hitOrd = array.sort_indices(hitRat, order.descending)

// ──────────────────────  last closed period snapshot  ───────────────────────
var array<string> prvSym = array.new<string>()
var array<float>  prvRat = array.new<float>()
var array<float>  prvChg = array.new<float>()

if barstate.isconfirmed
    prvSym := array.copy(hitSym)
    prvRat := array.copy(hitRat)
    prvChg := array.copy(hitChg)

// ─────────────────────────────  panel  ──────────────────────────────────────
COL_NAVY  = #22345F
COL_CREAM = #F4F2EC
COL_ACC   = #39FF55

tblPos  = pnlPos == "Top right" ? position.top_right : pnlPos == "Top left" ? position.top_left : pnlPos == "Bottom right" ? position.bottom_right : position.bottom_left
tblSize = size.normal

var table pnl = table.new(tblPos, 9, 43, bgcolor = color.new(COL_NAVY, 80), frame_color = color.new(COL_NAVY, 25), frame_width = 1, border_width = 0)

GAP_W   = 1.0
HDR_ROW = 2

tfSecs  = timeframe.in_seconds(tfScan)
tfLabel = tfSecs < 3600 ? "M" + str.tostring(tfSecs / 60) : tfSecs < 86400 ? "H" + str.tostring(tfSecs / 3600) : "D" + str.tostring(tfSecs / 86400)

titleBar(table t, int lastCol) =>
    for c = 0 to lastCol
        table.cell(t, c, 0, "", bgcolor = COL_NAVY)
        table.cell(t, c, 1, "", bgcolor = COL_ACC, text_size = size.tiny, height = 0.4)
    table.cell(t, 0, 0, "FCP", text_color = COL_ACC, bgcolor = COL_NAVY, text_size = tblSize, text_halign = text.align_left)
    if lastCol >= 5
        table.cell(t, 1, 0, "MARKET PULSE", text_color = COL_CREAM, bgcolor = COL_NAVY, text_size = tblSize, text_halign = text.align_left)
        table.cell(t, lastCol, 0, tfLabel, text_color = color.new(COL_CREAM, 45), bgcolor = COL_NAVY, text_size = tblSize, text_halign = text.align_right)
        table.merge_cells(t, 1, 0, lastCol - 1, 0)
    else
        table.cell(t, 1, 0, "MARKET PULSE  " + tfLabel, text_color = COL_CREAM, bgcolor = COL_NAVY, text_size = tblSize, text_halign = text.align_left)
        table.merge_cells(t, 1, 0, lastCol, 0)
    table.merge_cells(t, 0, 1, lastCol, 1)

block(table t, int c0, string ttl, array<string> aS, array<float> aR, array<float> aC) =>
    hdrCol = color.new(chart.fg_color, 45)
    hdrBg  = color.new(COL_NAVY, 55)
    table.cell(t, c0,     HDR_ROW, "",     bgcolor = hdrBg)
    table.cell(t, c0 + 1, HDR_ROW, ttl,    text_color = hdrCol, bgcolor = hdrBg, text_size = tblSize, text_halign = text.align_left)
    table.cell(t, c0 + 2, HDR_ROW, "xATR", text_color = hdrCol, bgcolor = hdrBg, text_size = tblSize, text_halign = text.align_right)
    table.cell(t, c0 + 3, HDR_ROW, "CHG%", text_color = hdrCol, bgcolor = hdrBg, text_size = tblSize, text_halign = text.align_right)

    n = array.size(aR)
    if n == 0
        table.cell(t, c0 + 1, HDR_ROW + 1, "quiet", text_color = color.new(chart.fg_color, 55), text_size = tblSize, text_halign = text.align_left)
        table.cell(t, c0 + 2, HDR_ROW + 1, "-",     text_color = color.new(chart.fg_color, 55), text_size = tblSize, text_halign = text.align_right)
    else
        ord = array.sort_indices(aR, order.descending)
        for j = 0 to n - 1
            i   = array.get(ord, j)
            c   = array.get(aC, i)
            col = c >= 0 ? COL_UP : COL_DN
            bg  = color.new(col, 88)
            row = HDR_ROW + 1 + j
            table.cell(t, c0,     row, c >= 0 ? "▲" : "▼", text_color = col, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)
            table.cell(t, c0 + 1, row, shortName(array.get(aS, i)), text_color = col, bgcolor = bg, text_size = tblSize, text_halign = text.align_left)
            table.cell(t, c0 + 2, row, str.tostring(array.get(aR, i), "0.0"), text_color = col, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)
            table.cell(t, c0 + 3, row, str.tostring(c, "0.00"),               text_color = col, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)

var bool titleDone = false

if pnlShow and barstate.islast
    if not titleDone
        titleBar(pnl, pnlPrev ? 8 : 3)
        titleDone := true
    table.clear(pnl, 0, HDR_ROW, 8, 42)
    if pnlPrev
        block(pnl, 0, "PREVIOUS", prvSym, prvRat, prvChg)
        table.cell(pnl, 4, HDR_ROW, "", width = GAP_W)
        block(pnl, 5, "SYMBOL", hitSym, hitRat, hitChg)
    else
        block(pnl, 0, "SYMBOL", hitSym, hitRat, hitChg)

// ─────────────────────────────  alert  ──────────────────────────────────────
if barstate.isconfirmed and hitN > 0
    nl   = tgJson ? "\\n" : "\n"
    body = ""
    for j = 0 to hitN - 1
        i = array.get(hitOrd, j)
        body += (j > 0 ? nl : "") + str.format("{0}  {1} x ATR  {2}%", shortName(array.get(hitSym, i)), str.tostring(array.get(hitRat, i), "0.0"), str.tostring(array.get(hitChg, i), "0.00"))
    txt = "FCP Market Pulse - " + tfScan + nl + body
    alert(tgJson ? '{"chat_id":"' + tgChat + '","text":"' + txt + '"}' : txt, alert.freq_once_per_bar_close)
````
