<!-- tradingview-pine-id: PUB;e826e9431a304a47a3e3f590453027ff -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Altcoin Strength Ranker - BTC Dominance

Source: https://www.tradingview.com/script/iObLvoek/

## Description

ALTCOIN STRENGTH RANKER - BTC DOMINANCE

This indicator ranks a list of cryptocurrencies by how strongly each one is moving
relative to Bitcoin, and uses BTC.D (Bitcoin Dominance) as a regime filter to indicate when that
ranking is actually worth acting on.
Instead of checking one chart at a time, it reads up to 18 symbols (divided into groups) in a single pass and presents them as a sorted table: strongest against Bitcoin at the top, weakest
at the bottom.

HOW IT WORKS

1) Normalized momentum

For every coin, the script takes the logarithmic return over N bars and divides it by the standard deviation of one-bar log returns over the same window, scaled by the square root of N.

In plain words: rather than asking "how much did it move?", it asks "how big was the move compared with this coin's own everyday noise?" The result is a t-statistic — a number expressing the move in units of typical volatility. Around +2 means an unusually strong advance; around -2 is the mirror image; near 0 means the move is indistinguishable from ordinary fluctuation.

The point of normalizing is comparability. A raw 15% weekly move means something very different for a large cap than for a low-liquidity newcomer. After normalization, every coin sits on the same scale and the ranking is meaningful.

2) Two readings per coin

z/BTC — momentum of the synthetic ratio ALT/BTC, built as ALTUSDT / BTCUSDT. This is relative strength: the coin measured against Bitcoin. Building it as a spread means the indicator works for any coin that has a USDT pair, even when no direct BTC pair is listed on the exchange.

z/USD — momentum of the coin against the quote currency (USDT by default). This is absolute direction: whether the coin is going up or down in dollar terms.

The distinction matters because the two frequently disagree, and the disagreement is the interesting part. A coin can be rising in dollars while still losing ground to Bitcoin — capital is flowing in, but less than it is flowing into BTC.

3) Composite score

score = w × (z/BTC) + (1 − w) × (z/USD)

The weight w (0.6 by default) sets how much the ranking cares about beating Bitcoin versus simply going up. Set w = 1 for pure relative strength; set w = 0 to rank by absolute momentum alone.

4) Dominance regime filter

The same normalization is applied to BTC.D and shown as the histogram in the lower
panel, with the background shaded accordingly:

- z_D above the threshold: dominance is rising, capital is rotating toward Bitcoin, altcoins tend to underperform.
- z_D below the negative threshold: dominance is falling, altcoins tend to outperform.
- In between: neutral, no directional signal is issued.

This is what keeps the ranking from being read out of context. The same table means something different depending on where the whole market's capital is heading.

READING THE COLORS

In the dominance plot, teal means Bitcoin is gaining ground on the rest of the market, red means it is losing ground:

- Dominance rising  -> teal histogram bar, teal background -> capital concentrating
  in Bitcoin -> Bitcoin strong, altcoins weak.
- Dominance falling -> red histogram bar, red background   -> capital dispersing into
  the rest of the market -> Bitcoin weak, altcoins strong.

The table uses the opposite convention, because it describes altcoins rather than Bitcoin: a negative z-score is red, a positive one is teal, and the score column runs on a gradient between them. 

One qualification is important here. Dominance is a ratio, not a price. Rising dominance tells you Bitcoin is outperforming the market — it does not tell you Bitcoin is going up in dollar terms, and the two frequently part ways. In a market-wide sell-off, altcoins normally fall harder than Bitcoin, so dominance rises while Bitcoin itself declines. The reverse also happens: in the later stage of an advance, capital rotates outward and dominance falls while Bitcoin keeps making new highs. So read the panel as a statement about relative flow between Bitcoin and the rest of the market, and pair it with the Bitcoin chart itself before drawing any conclusion about direction.

READING THE TABLE

Coin     — the ticker, without the quote currency
z/BTC  — normalized momentum of the ALT/BTC ratio (relative strength)
z/USD  — normalized momentum against the quote currency (absolute direction)
RSI/B   — RSI (Relative Strength Index, a 0–100 oscillator measuring a series against its own recent history) computed on the ALT/BTC ratio
RSI/U   — RSI computed on the coin against the quote currency
Score   — the composite above, colored on a gradient from weak to strong
Signal  — see below

The top line reports the group being evaluated, the current dominance regime, and
the value of z_D.

THE SIGNAL COLUMN

No signal: either the regime is neutral or z/BTC has not cleared the significance threshold.

▼ or ▲   direction consistent with the regime, and relative strength beyond the
     threshold. ▼ = weak against Bitcoin during rising dominance; ▲ = strong against
     Bitcoin during falling dominance.

★    divergence between the two readings: the coin is still moving up in dollar
     terms while losing ground against Bitcoin (or the reverse). This is the
     configuration where relative-strength setups typically live, because the crowd
     watching the dollar chart sees strength while the capital flow says otherwise.

★★   the same divergence, plus timing from the RSI of the ratio: above 55 on the
     weak side, below 45 on the strong side — meaning the ratio is stretched in the
     direction that is about to be given up.

An alert fires on bar close listing every coin currently showing ★ or ★★.

SETTINGS

Analysis timeframe   —  leave empty to follow the chart, or fix it (e.g. 1D) to keep one reading regardless of the chart you are on
Momentum length    —  lookback window for the normalized momentum
RSI length                  —  lookback for both RSI columns
Exchange / Quote     —  how symbols are assembled (BINANCE + USDT by default)
Display                       —  strongest, weakest, or both lists
Top N per list             —  how many rows per list
Weight w                    —  relative strength versus absolute direction in the score
Significance |z|          —  how large z/BTC must be before a signal is issued
BTC.D momentum    —  lookback for the dominance regime
Regime |z_D|             —  how decisive dominance must be before the regime is called
Groups 1–4               —  four editable comma-separated symbol lists (large caps, mid caps and DeFi, memes and new listings, plus a free slot)

⚠️ NOTES AND LIMITATIONS

- The table is drawn on the last bar only; it is a live cross-section, not a
  historical record.
- Symbols that do not resolve on the chosen exchange are silently skipped, which is
  why a group may show fewer rows than it lists.
- The ranking is relative and descriptive, not a forecast. In a broad market decline
  the "strongest" coin can still be falling — it is simply falling less.
- The dominance regime is a context filter, not an entry trigger. Position sizing,
  invalidation levels and exits are outside the scope of this tool.

For research and educational purposes. Nothing here is financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoStochTV

//@version=6
indicator("Altcoin Strength Ranker - BTC Dominance", "BTC.D", overlay=false, dynamic_requests=true)

// ─────────────────── INPUTS ───────────────────
tfIn     = input.timeframe("",        "Analysis timeframe")
lenMom   = input.int(20,              "Momentum length (bars)", minval=5)
rsiLen   = input.int(14,              "RSI length", minval=2)
exch     = input.string("BINANCE",    "Exchange")
qUsd     = input.string("USDT",       "Quote fiat/stable")
mode     = input.string("Both",       "Display", options=["Strongest", "Weakest", "Both"])
topN     = input.int(5,               "Top N per list", minval=1, maxval=15)
wBtc     = input.float(0.6,           "Weight of strength vs BTC (w)", minval=0, maxval=1, step=0.05)
sigThr   = input.float(1.0,           "Significance threshold |z|", step=0.1)
domLen   = input.int(20,              "BTC.D momentum length")
domThr   = input.float(0.5,           "Regime threshold |z_D|", step=0.1)

// Table
tblPos   = input.string("top_right",  "Table position", options=["top_right", "middle_right", "bottom_right", "top_left", "middle_left", "bottom_left"], group="Table")
tblSize  = input.string("normal",      "Text size", options=["tiny", "small", "normal", "large"], group="Table")
szTxt    = tblSize == "tiny" ? size.tiny : tblSize == "small" ? size.small : tblSize == "normal" ? size.normal : size.large

// ─────────────────── COIN GROUPS ───────────────────
grpSel = input.string("Group 1", "Group to evaluate", options=["Group 1", "Group 2", "Group 3", "Group 4"], group="Groups")
g1 = input.text_area("ETH,SOL,BNB,XRP,ADA,DOGE,AVAX,LINK,DOT,LTC,ATOM,NEAR,UNI,APT,ARB,OP,FIL,INJ",
                     "Group 1 — Large caps", group="Groups")
g2 = input.text_area("TIA,SEI,SUI,RUNE,FTM,GALA,SAND,MANA,AXS,IMX,GRT,LDO,AAVE,MKR,SNX,CRV,COMP,ALGO",
                     "Group 2 — Mid caps / DeFi", group="Groups")
g3 = input.text_area("PEPE,SHIB,BONK,WIF,FLOKI,JUP,PYTH,ENA,W,STRK,DYM,ALT,MANTA,ONDO,JTO,BLUR,MEME,ORDI",
                     "Group 3 — Memes / new listings", group="Groups")
g4 = input.text_area("", "Group 4 — Custom", group="Groups")

coinsStr = grpSel == "Group 1" ? g1 : grpSel == "Group 2" ? g2 : grpSel == "Group 3" ? g3 : g4

// ─────────────────── MODEL ───────────────────
// z-momentum (t-stat) + RSI in a tuple: 1 request.security per series
f_zmom(_len) =>
    r = math.log(close / close[_len])
    s = ta.stdev(math.log(close / close[1]), _len) * math.sqrt(_len)
    s > 0 ? r / s : na

f_metrics(_lenM, _lenR) =>
    [f_zmom(_lenM), ta.rsi(close, _lenR)]

zDom  = request.security("CRYPTOCAP:BTC.D", tfIn, f_zmom(domLen))
zBtcU = request.security(exch + ":BTC" + qUsd, tfIn, f_zmom(lenMom))

regimeAltWeak   = zDom >=  domThr   // dominance rising → alts weak
regimeAltStrong = zDom <= -domThr   // dominance falling → alts strong

// ─────────────────── DATA COLLECTION ───────────────────
rawCoins = str.split(coinsStr, ",")
names  = array.new_string()
arrZB  = array.new_float()
arrZU  = array.new_float()
arrRB  = array.new_float()
arrRU  = array.new_float()
arrSc  = array.new_float()

for c in rawCoins
    sym = str.replace_all(str.replace_all(c, " ", ""), "\n", "")
    if str.length(sym) > 0 and array.size(names) < 18
        // Synthetic BTC pair (spread): ALTUSDT/BTCUSDT — works for any coin with a USDT pair
        [zB, rsB] = request.security(exch + ":" + sym + qUsd + "/" + exch + ":BTC" + qUsd, tfIn, f_metrics(lenMom, rsiLen), ignore_invalid_symbol=true)
        [zU, rsU] = request.security(exch + ":" + sym + qUsd, tfIn, f_metrics(lenMom, rsiLen), ignore_invalid_symbol=true)
        if not na(zB) and not na(zU)
            array.push(names, sym)
            array.push(arrZB, zB)
            array.push(arrZU, zU)
            array.push(arrRB, rsB)
            array.push(arrRU, rsU)
            array.push(arrSc, wBtc * zB + (1 - wBtc) * zU)

// ─────────────────── SIGNALS ───────────────────
// ▼/▲ = direction | ★ = ideal setup (USD vs BTC divergence) | ★★ = ideal + timing from the ratio's RSI
f_signal(_zB, _zU, _rB) =>
    s = "·"
    if regimeAltWeak and _zB < -sigThr
        s := _zU > 0 and _rB > 55 ? "▼★★" : _zU > 0 ? "▼★" : "▼"
    else if regimeAltStrong and _zB > sigThr
        s := _zU > 0 and _rB < 45 ? "▲★★" : _zU > 0 ? "▲★" : "▲"
    s

// ─────────────────── RANKING ───────────────────
f_sortedIdx() =>
    n   = array.size(arrSc)
    idx = array.new_int()
    for i = 0 to n > 0 ? n - 1 : na
        array.push(idx, i)
    if n > 1
        for i = 0 to n - 2
            best = i
            for j = i + 1 to n - 1
                if array.get(arrSc, array.get(idx, j)) > array.get(arrSc, array.get(idx, best))
                    best := j
            if best != i
                tmp = array.get(idx, i)
                array.set(idx, i, array.get(idx, best))
                array.set(idx, best, tmp)
    idx

// ─────────────────── TABLE ───────────────────
var table tb = na
colUp = color.new(#26a69a, 0)
colDn = color.new(#ef5350, 0)
colBg = color.new(#131722, 10)

f_pos(_p) =>
    _p == "top_right" ? position.top_right : _p == "middle_right" ? position.middle_right : _p == "bottom_right" ? position.bottom_right : _p == "top_left" ? position.top_left : _p == "middle_left" ? position.middle_left : position.bottom_left

f_rsiCol(_r) =>
    _r >= 70 ? colUp : _r >= 60 ? color.new(#26a69a, 30) : _r <= 30 ? colDn : _r <= 40 ? color.new(#ef5350, 30) : color.gray

f_row(_t, _r, _i) =>
    zB = array.get(arrZB, _i), zU = array.get(arrZU, _i)
    rB = array.get(arrRB, _i), rU = array.get(arrRU, _i)
    sc = array.get(arrSc, _i)
    cSc = color.from_gradient(sc, -2, 2, colDn, colUp)
    sig = f_signal(zB, zU, rB)
    cSg = str.contains(sig, "▼") ? colDn : str.contains(sig, "▲") ? colUp : color.gray
    table.cell(_t, 0, _r, array.get(names, _i),     text_color=color.white, bgcolor=colBg, text_size=szTxt)
    table.cell(_t, 1, _r, str.tostring(zB, "0.00"), text_color=zB > 0 ? colUp : colDn, bgcolor=colBg, text_size=szTxt)
    table.cell(_t, 2, _r, str.tostring(zU, "0.00"), text_color=zU > 0 ? colUp : colDn, bgcolor=colBg, text_size=szTxt)
    table.cell(_t, 3, _r, str.tostring(rB, "0"),    text_color=f_rsiCol(rB), bgcolor=colBg, text_size=szTxt)
    table.cell(_t, 4, _r, str.tostring(rU, "0"),    text_color=f_rsiCol(rU), bgcolor=colBg, text_size=szTxt)
    table.cell(_t, 5, _r, str.tostring(sc, "0.00"), text_color=cSc, bgcolor=colBg, text_size=szTxt)
    table.cell(_t, 6, _r, sig,                      text_color=cSg, bgcolor=colBg, text_size=szTxt)

if barstate.islast
    idx = f_sortedIdx()
    n   = array.size(idx)
    k   = math.min(topN, n)
    rows = 2 + (mode == "Both" ? 2 * k + 2 : k + 1)
    tb := table.new(f_pos(tblPos), 7, rows + 3, border_width=1, border_color=color.new(color.gray, 85), force_overlay=true)

    // Regime line
    regTxt = regimeAltWeak ? "BTC.D ↑ alts weak" : regimeAltStrong ? "BTC.D ↓ alts strong" : "BTC.D neutral"
    regCol = regimeAltWeak ? colDn : regimeAltStrong ? colUp : color.gray
    table.merge_cells(tb, 0, 0, 6, 0)
    table.cell(tb, 0, 0, grpSel + " | " + regTxt + " | zD=" + str.tostring(zDom, "0.00"), text_color=regCol, bgcolor=colBg, text_size=szTxt)

    // Header
    hdr = array.from("Coin", "z/BTC", "z/USD", "RSI/B", "RSI/U", "Score", "Signal")
    for h = 0 to 6
        table.cell(tb, h, 1, array.get(hdr, h), text_color=color.orange, bgcolor=colBg, text_size=szTxt)

    r = 2
    if n == 0
        table.merge_cells(tb, 0, r, 6, r)
        table.cell(tb, 0, r, "No valid pair in this group/exchange", text_color=color.orange, bgcolor=colBg, text_size=szTxt)
    if mode != "Weakest" and k > 0
        table.merge_cells(tb, 0, r, 6, r)
        table.cell(tb, 0, r, "▲ Strong vs BTC", text_color=colUp, bgcolor=colBg, text_size=szTxt)
        r += 1
        for i = 0 to k - 1
            f_row(tb, r, array.get(idx, i))
            r += 1
    if mode != "Strongest" and k > 0
        table.merge_cells(tb, 0, r, 6, r)
        table.cell(tb, 0, r, "▼ Weak vs BTC", text_color=colDn, bgcolor=colBg, text_size=szTxt)
        r += 1
        for i = 0 to k - 1
            f_row(tb, r, array.get(idx, n - 1 - i))
            r += 1

// ─────────────────── PANEL: dominance regime ───────────────────
plot(zDom, "z(BTC.D)", style=plot.style_columns, color=zDom > 0 ? color.new(colUp, 40) : color.new(colDn, 40))
hline(0)
hline( 1, color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(-1, color=color.new(color.gray, 60), linestyle=hline.style_dotted)
bgcolor(regimeAltWeak ? color.new(colUp, 92) : regimeAltStrong ? color.new(colDn, 92) : na)

// ─────────────────── ALERTS ───────────────────
if barstate.isconfirmed
    msg = ""
    if array.size(names) > 0
        for i = 0 to array.size(names) - 1
            sig = f_signal(array.get(arrZB, i), array.get(arrZU, i), array.get(arrRB, i))
            if str.contains(sig, "★")
                msg += array.get(names, i) + " " + sig + " | "
    if str.length(msg) > 0
        alert("[" + grpSel + "] Setups: " + msg, alert.freq_once_per_bar_close)
````
