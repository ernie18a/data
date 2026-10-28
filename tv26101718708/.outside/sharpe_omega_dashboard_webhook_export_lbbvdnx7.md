# Sharpe + Omega Dashboard + Webhook Export

- url: https://www.tradingview.com/script/LBbVDNX7-Sharpe-Omega-Dashboard-Webhook-Export/
- type: indicator
- pine_id: PUB;6851c2dc48034c08bcc541e8695d8561
- version: 1.0

## Description

This is my script You have:

the correct indicator selected
Any alert() function call
1m interval for testing
notifications include Webhook

So this is the correct setup for a live test.

Two quick things to verify before you click Create
1. Webhook URL is really there

Open the Notifications section once more and confirm:

Webhook is toggled on
the full /exec URL is in the field
2. Message can stay as-is

Since you are using alert(payload, ...) in Pine, the alert will use the script-generated payload. That is fine.

After you click Create

Do this in order:

wait for the next 1-minute candle to close
go to the sheet
check R3
compare one coin, like BNB, between:
TradingView table
R3
the sheet row
What “good” looks like

For BNB, all three should line up:

TradingView Omega values
JSON in R3
cells B:F on the BNB row

## Source Code

````pine
//@version=5
indicator("Sharpe + Omega Dashboard + Webhook Export", overlay=true)

// ===== INPUTS =====
riskFreeAnnual = input.float(0.02, "Risk-Free Rate (Annual)")
marDaily       = input.float(0.0, "Omega Min Return (Daily)")
rfDaily        = riskFreeAnnual / 365.0

// ===== SYMBOLS =====
sym1  = input.symbol("BINANCE:POLUSDT",  "MATIC feed")
sym2  = input.symbol("BINANCE:BNBUSDT",  "BNB")
sym3  = input.symbol("BINANCE:DOGEUSDT", "DOGE")
sym4  = input.symbol("BINANCE:XRPUSDT",  "XRP")
sym5  = input.symbol("BINANCE:ETHUSDT",  "ETH")
sym6  = input.symbol("BINANCE:SOLUSDT",  "SOL")
sym7  = input.symbol("KRAKEN:XMRUSD",    "XMR")
sym8  = input.symbol("BINANCE:BTCUSDT",  "BTC")
sym9  = input.symbol("BINANCE:ADAUSDT",  "ADA")
sym10 = input.symbol("BINANCE:ZECUSDT",  "ZEC")
sym11 = input.symbol("BINANCE:LTCUSDT",  "LTC")
sym12 = input.symbol("BINANCE:ICXUSDT",  "ICX")
sym13 = input.symbol("BINANCE:DOTUSDT",  "DOT")
sym14 = input.symbol("BINANCE:AVAXUSDT", "AVAX")

// ===== HELPERS =====
getR(s) =>
    c = request.security(s, "D", close)
    math.log(c / c[1])

sharpe(r, len) =>
    m  = ta.sma(r - rfDaily, len)
    sd = ta.stdev(r, len)
    sd == 0 or na(sd) ? na : (m / sd) * math.sqrt(365)

omega(r, len) =>
    float g = 0.0
    float l = 0.0
    for i = 0 to len - 1
        v = r[i] - marDaily
        g += math.max(v, 0)
        l += math.max(-v, 0)
    l == 0 ? na : g / l

fmt(x) =>
    na(x) ? "N/A" : str.tostring(x, "#.###")

jsonNum(x) =>
    na(x) ? "null" : str.tostring(x)

// ===== RETURNS =====
r1  = getR(sym1)
r2  = getR(sym2)
r3  = getR(sym3)
r4  = getR(sym4)
r5  = getR(sym5)
r6  = getR(sym6)
r7  = getR(sym7)
r8  = getR(sym8)
r9  = getR(sym9)
r10 = getR(sym10)
r11 = getR(sym11)
r12 = getR(sym12)
r13 = getR(sym13)
r14 = getR(sym14)

// ===== TABLES =====
var table sharpeTbl = table.new(position.middle_left, 6, 15, border_width=1)
var table omegaTbl  = table.new(position.middle_right, 6, 15, border_width=1)

header(tbl, title) =>
    table.cell(tbl, 0, 0, title)
    table.cell(tbl, 1, 0, "360")
    table.cell(tbl, 2, 0, "180")
    table.cell(tbl, 3, 0, "90")
    table.cell(tbl, 4, 0, "60")
    table.cell(tbl, 5, 0, "30")

rowSharpe(tbl, i, name, r) =>
    table.cell(tbl, 0, i, name)
    table.cell(tbl, 1, i, fmt(sharpe(r, 360)))
    table.cell(tbl, 2, i, fmt(sharpe(r, 180)))
    table.cell(tbl, 3, i, fmt(sharpe(r, 90)))
    table.cell(tbl, 4, i, fmt(sharpe(r, 60)))
    table.cell(tbl, 5, i, fmt(sharpe(r, 30)))

rowOmega(tbl, i, name, r) =>
    table.cell(tbl, 0, i, name)
    table.cell(tbl, 1, i, fmt(omega(r, 360)))
    table.cell(tbl, 2, i, fmt(omega(r, 180)))
    table.cell(tbl, 3, i, fmt(omega(r, 90)))
    table.cell(tbl, 4, i, fmt(omega(r, 60)))
    table.cell(tbl, 5, i, fmt(omega(r, 30)))

// ===== DRAW TABLES =====
if bar_index > 10
    header(sharpeTbl, "SHARPE")
    header(omegaTbl, "OMEGA")

    rowSharpe(sharpeTbl, 1,  "MATIC", r1)
    rowSharpe(sharpeTbl, 2,  "BNB",   r2)
    rowSharpe(sharpeTbl, 3,  "DOGE",  r3)
    rowSharpe(sharpeTbl, 4,  "XRP",   r4)
    rowSharpe(sharpeTbl, 5,  "ETH",   r5)
    rowSharpe(sharpeTbl, 6,  "SOL",   r6)
    rowSharpe(sharpeTbl, 7,  "XMR",   r7)
    rowSharpe(sharpeTbl, 8,  "BTC",   r8)
    rowSharpe(sharpeTbl, 9,  "ADA",   r9)
    rowSharpe(sharpeTbl, 10, "ZEC",   r10)
    rowSharpe(sharpeTbl, 11, "LTC",   r11)
    rowSharpe(sharpeTbl, 12, "ICX",   r12)
    rowSharpe(sharpeTbl, 13, "DOT",   r13)
    rowSharpe(sharpeTbl, 14, "AVAX",  r14)

    rowOmega(omegaTbl, 1,  "MATIC", r1)
    rowOmega(omegaTbl, 2,  "BNB",   r2)
    rowOmega(omegaTbl, 3,  "DOGE",  r3)
    rowOmega(omegaTbl, 4,  "XRP",   r4)
    rowOmega(omegaTbl, 5,  "ETH",   r5)
    rowOmega(omegaTbl, 6,  "SOL",   r6)
    rowOmega(omegaTbl, 7,  "XMR",   r7)
    rowOmega(omegaTbl, 8,  "BTC",   r8)
    rowOmega(omegaTbl, 9,  "ADA",   r9)
    rowOmega(omegaTbl, 10, "ZEC",   r10)
    rowOmega(omegaTbl, 11, "LTC",   r11)
    rowOmega(omegaTbl, 12, "ICX",   r12)
    rowOmega(omegaTbl, 13, "DOT",   r13)
    rowOmega(omegaTbl, 14, "AVAX",  r14)

// ===== JSON BLOCKS =====
maticBlock = "\"MATIC_sharpe\":{\"360\":" + jsonNum(sharpe(r1, 360)) + ",\"180\":" + jsonNum(sharpe(r1, 180)) + ",\"90\":" + jsonNum(sharpe(r1, 90)) + ",\"60\":" + jsonNum(sharpe(r1, 60)) + ",\"30\":" + jsonNum(sharpe(r1, 30)) + "},\"MATIC_omega\":{\"360\":" + jsonNum(omega(r1, 360)) + ",\"180\":" + jsonNum(omega(r1, 180)) + ",\"90\":" + jsonNum(omega(r1, 90)) + ",\"60\":" + jsonNum(omega(r1, 60)) + ",\"30\":" + jsonNum(omega(r1, 30)) + "}"
bnbBlock   = "\"BNB_sharpe\":{\"360\":"   + jsonNum(sharpe(r2, 360)) + ",\"180\":" + jsonNum(sharpe(r2, 180)) + ",\"90\":" + jsonNum(sharpe(r2, 90)) + ",\"60\":" + jsonNum(sharpe(r2, 60)) + ",\"30\":" + jsonNum(sharpe(r2, 30)) + "},\"BNB_omega\":{\"360\":"   + jsonNum(omega(r2, 360)) + ",\"180\":" + jsonNum(omega(r2, 180)) + ",\"90\":" + jsonNum(omega(r2, 90)) + ",\"60\":" + jsonNum(omega(r2, 60)) + ",\"30\":" + jsonNum(omega(r2, 30)) + "}"
dogeBlock  = "\"DOGE_sharpe\":{\"360\":"  + jsonNum(sharpe(r3, 360)) + ",\"180\":" + jsonNum(sharpe(r3, 180)) + ",\"90\":" + jsonNum(sharpe(r3, 90)) + ",\"60\":" + jsonNum(sharpe(r3, 60)) + ",\"30\":" + jsonNum(sharpe(r3, 30)) + "},\"DOGE_omega\":{\"360\":"  + jsonNum(omega(r3, 360)) + ",\"180\":" + jsonNum(omega(r3, 180)) + ",\"90\":" + jsonNum(omega(r3, 90)) + ",\"60\":" + jsonNum(omega(r3, 60)) + ",\"30\":" + jsonNum(omega(r3, 30)) + "}"
xrpBlock   = "\"XRP_sharpe\":{\"360\":"   + jsonNum(sharpe(r4, 360)) + ",\"180\":" + jsonNum(sharpe(r4, 180)) + ",\"90\":" + jsonNum(sharpe(r4, 90)) + ",\"60\":" + jsonNum(sharpe(r4, 60)) + ",\"30\":" + jsonNum(sharpe(r4, 30)) + "},\"XRP_omega\":{\"360\":"   + jsonNum(omega(r4, 360)) + ",\"180\":" + jsonNum(omega(r4, 180)) + ",\"90\":" + jsonNum(omega(r4, 90)) + ",\"60\":" + jsonNum(omega(r4, 60)) + ",\"30\":" + jsonNum(omega(r4, 30)) + "}"
ethBlock   = "\"ETH_sharpe\":{\"360\":"   + jsonNum(sharpe(r5, 360)) + ",\"180\":" + jsonNum(sharpe(r5, 180)) + ",\"90\":" + jsonNum(sharpe(r5, 90)) + ",\"60\":" + jsonNum(sharpe(r5, 60)) + ",\"30\":" + jsonNum(sharpe(r5, 30)) + "},\"ETH_omega\":{\"360\":"   + jsonNum(omega(r5, 360)) + ",\"180\":" + jsonNum(omega(r5, 180)) + ",\"90\":" + jsonNum(omega(r5, 90)) + ",\"60\":" + jsonNum(omega(r5, 60)) + ",\"30\":" + jsonNum(omega(r5, 30)) + "}"
solBlock   = "\"SOL_sharpe\":{\"360\":"   + jsonNum(sharpe(r6, 360)) + ",\"180\":" + jsonNum(sharpe(r6, 180)) + ",\"90\":" + jsonNum(sharpe(r6, 90)) + ",\"60\":" + jsonNum(sharpe(r6, 60)) + ",\"30\":" + jsonNum(sharpe(r6, 30)) + "},\"SOL_omega\":{\"360\":"   + jsonNum(omega(r6, 360)) + ",\"180\":" + jsonNum(omega(r6, 180)) + ",\"90\":" + jsonNum(omega(r6, 90)) + ",\"60\":" + jsonNum(omega(r6, 60)) + ",\"30\":" + jsonNum(omega(r6, 30)) + "}"
xmrBlock   = "\"XMR_sharpe\":{\"360\":"   + jsonNum(sharpe(r7, 360)) + ",\"180\":" + jsonNum(sharpe(r7, 180)) + ",\"90\":" + jsonNum(sharpe(r7, 90)) + ",\"60\":" + jsonNum(sharpe(r7, 60)) + ",\"30\":" + jsonNum(sharpe(r7, 30)) + "},\"XMR_omega\":{\"360\":"   + jsonNum(omega(r7, 360)) + ",\"180\":" + jsonNum(omega(r7, 180)) + ",\"90\":" + jsonNum(omega(r7, 90)) + ",\"60\":" + jsonNum(omega(r7, 60)) + ",\"30\":" + jsonNum(omega(r7, 30)) + "}"
btcBlock   = "\"BTC_sharpe\":{\"360\":"   + jsonNum(sharpe(r8, 360)) + ",\"180\":" + jsonNum(sharpe(r8, 180)) + ",\"90\":" + jsonNum(sharpe(r8, 90)) + ",\"60\":" + jsonNum(sharpe(r8, 60)) + ",\"30\":" + jsonNum(sharpe(r8, 30)) + "},\"BTC_omega\":{\"360\":"   + jsonNum(omega(r8, 360)) + ",\"180\":" + jsonNum(omega(r8, 180)) + ",\"90\":" + jsonNum(omega(r8, 90)) + ",\"60\":" + jsonNum(omega(r8, 60)) + ",\"30\":" + jsonNum(omega(r8, 30)) + "}"
adaBlock   = "\"ADA_sharpe\":{\"360\":"   + jsonNum(sharpe(r9, 360)) + ",\"180\":" + jsonNum(sharpe(r9, 180)) + ",\"90\":" + jsonNum(sharpe(r9, 90)) + ",\"60\":" + jsonNum(sharpe(r9, 60)) + ",\"30\":" + jsonNum(sharpe(r9, 30)) + "},\"ADA_omega\":{\"360\":"   + jsonNum(omega(r9, 360)) + ",\"180\":" + jsonNum(omega(r9, 180)) + ",\"90\":" + jsonNum(omega(r9, 90)) + ",\"60\":" + jsonNum(omega(r9, 60)) + ",\"30\":" + jsonNum(omega(r9, 30)) + "}"
zecBlock   = "\"ZEC_sharpe\":{\"360\":"   + jsonNum(sharpe(r10, 360)) + ",\"180\":" + jsonNum(sharpe(r10, 180)) + ",\"90\":" + jsonNum(sharpe(r10, 90)) + ",\"60\":" + jsonNum(sharpe(r10, 60)) + ",\"30\":" + jsonNum(sharpe(r10, 30)) + "},\"ZEC_omega\":{\"360\":"   + jsonNum(omega(r10, 360)) + ",\"180\":" + jsonNum(omega(r10, 180)) + ",\"90\":" + jsonNum(omega(r10, 90)) + ",\"60\":" + jsonNum(omega(r10, 60)) + ",\"30\":" + jsonNum(omega(r10, 30)) + "}"
ltcBlock   = "\"LTC_sharpe\":{\"360\":"   + jsonNum(sharpe(r11, 360)) + ",\"180\":" + jsonNum(sharpe(r11, 180)) + ",\"90\":" + jsonNum(sharpe(r11, 90)) + ",\"60\":" + jsonNum(sharpe(r11, 60)) + ",\"30\":" + jsonNum(sharpe(r11, 30)) + "},\"LTC_omega\":{\"360\":"   + jsonNum(omega(r11, 360)) + ",\"180\":" + jsonNum(omega(r11, 180)) + ",\"90\":" + jsonNum(omega(r11, 90)) + ",\"60\":" + jsonNum(omega(r11, 60)) + ",\"30\":" + jsonNum(omega(r11, 30)) + "}"
icxBlock   = "\"ICX_sharpe\":{\"360\":"   + jsonNum(sharpe(r12, 360)) + ",\"180\":" + jsonNum(sharpe(r12, 180)) + ",\"90\":" + jsonNum(sharpe(r12, 90)) + ",\"60\":" + jsonNum(sharpe(r12, 60)) + ",\"30\":" + jsonNum(sharpe(r12, 30)) + "},\"ICX_omega\":{\"360\":"   + jsonNum(omega(r12, 360)) + ",\"180\":" + jsonNum(omega(r12, 180)) + ",\"90\":" + jsonNum(omega(r12, 90)) + ",\"60\":" + jsonNum(omega(r12, 60)) + ",\"30\":" + jsonNum(omega(r12, 30)) + "}"
dotBlock   = "\"DOT_sharpe\":{\"360\":"   + jsonNum(sharpe(r13, 360)) + ",\"180\":" + jsonNum(sharpe(r13, 180)) + ",\"90\":" + jsonNum(sharpe(r13, 90)) + ",\"60\":" + jsonNum(sharpe(r13, 60)) + ",\"30\":" + jsonNum(sharpe(r13, 30)) + "},\"DOT_omega\":{\"360\":"   + jsonNum(omega(r13, 360)) + ",\"180\":" + jsonNum(omega(r13, 180)) + ",\"90\":" + jsonNum(omega(r13, 90)) + ",\"60\":" + jsonNum(omega(r13, 60)) + ",\"30\":" + jsonNum(omega(r13, 30)) + "}"
avaxBlock  = "\"AVAX_sharpe\":{\"360\":"  + jsonNum(sharpe(r14, 360)) + ",\"180\":" + jsonNum(sharpe(r14, 180)) + ",\"90\":" + jsonNum(sharpe(r14, 90)) + ",\"60\":" + jsonNum(sharpe(r14, 60)) + ",\"30\":" + jsonNum(sharpe(r14, 30)) + "},\"AVAX_omega\":{\"360\":"  + jsonNum(omega(r14, 360)) + ",\"180\":" + jsonNum(omega(r14, 180)) + ",\"90\":" + jsonNum(omega(r14, 90)) + ",\"60\":" + jsonNum(omega(r14, 60)) + ",\"30\":" + jsonNum(omega(r14, 30)) + "}"

// ===== FINAL PAYLOAD =====
payload = "{" + maticBlock + "," + bnbBlock + "," + dogeBlock + "," + xrpBlock + "," + ethBlock + "," + solBlock + "," + xmrBlock + "," + btcBlock + "," + adaBlock + "," + zecBlock + "," + ltcBlock + "," + icxBlock + "," + dotBlock + "," + avaxBlock + "}"

// ===== ALERT =====
if barstate.isconfirmed
    alert(payload, alert.freq_once_per_bar_close)
````
