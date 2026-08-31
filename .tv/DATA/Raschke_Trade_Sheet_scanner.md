<!-- tradingview-pine-id: PUB;fe45f024eb5f44ef8fa5a6a8a9bde09e -->
<!-- tradingviewscripts-format: 1 -->
# Raschke Trade Sheet (scanner)

Source: https://www.tradingview.com/script/8MVLfKu4-Raschke-Trade-Sheet-scanner/

## Description

Recreates Linda Raschke's nightly "trade sheet" as a live scanner: one table showing momentum bias, volatility compression, range expansion, extended-run exhaustion, momentum thrusts, and 20-day channel tests for ten futures markets at once.

OVERVIEW

Linda Bradford Raschke has said for decades that her edge starts with homework: every evening she hand-writes indicator readings and closing prices for the two dozen futures markets she tracks, because writing them down keeps her in tune with the tape in a way a screen full of charts cannot. Her firm still publishes these nightly trade sheets.

This script rebuilds that routine as a live scanner. It runs her checklist across a configurable ten-symbol futures watchlist (or just the current chart) and displays the results in one table, so the evening-homework snapshot she compiles by hand is on your chart continuously. It is a preparation tool: it tells you which markets deserve attention tomorrow and in which direction, not when to click buy.

WHY THIS IS DIFFERENT

Every column of this table exists somewhere on TradingView as a standalone script - there are NR7/WR bar markers, 2-period ROC plots, and Donchian channels. What does not exist is the sheet: the specific combination Raschke actually checks nightly, computed per symbol across a watchlist and read as one row per market. That combination is the point. Her workflow is not "watch one indicator"; it is "scan many markets for a short checklist of conditions, then trade the two or three markets where conditions line up." A row where bias, compression, and a channel test agree is a candidate; a lone flag is just information. This is a mashup with a documented reason to exist - it reproduces a professional's published daily process, and to my knowledge no other script on TradingView does it.

THE COLUMNS

Bias - three momentum readings sloping the same way: the 3/10 oscillator fast line (SMA 3 minus SMA 10), its 16-period slow line, and the 2-period rate of change. All three rising = up bias (green), all three falling = down bias (red), mixed = neutral. The 2-period ROC is a Raschke staple: it highlights the two-to-three-day swing cycle she traces back to George Douglass Taylor's buy day / sell day rhythm, and the 3/10 pair is her signature momentum gauge. When all three agree, the swing, the momentum trend, and the short cycle point the same way.

3bar - a three-bar triangle: the latest bar's high is below the prior two highs AND its low is above the prior two lows. Compression inside compression - the market is winding up, and the subsequent break of the little triangle often starts the next directional move.

WR7 - wide-range-7: the current bar's range is the widest of the last seven. This is Toby Crabel's range-expansion concept, which Raschke absorbed into her own work: volatility cycles from contraction to expansion, and a WR7 bar tells you expansion has arrived. Early in a move it marks initiation; after an extended run it can mark climax. Read it together with the Bias column.

Coil - three consecutive bars still share overlapping price territory (the lowest high of the three sits above the highest low). A market trading in balance with a short travel path - the flip side of WR7. Crabel's and Raschke's shared premise: low-volatility balance precedes the tradeable breakout, so coiled markets go on tomorrow's watch list.

ExtSig - extended-run exhaustion around the 5-period SMA. After at least seven consecutive closes on one side of the 5-SMA - an unusually persistent run - the FIRST close back on the other side prints B (buy) or S (sell). This is a classic Raschke tell: short-term runs stretch only so far from the mean, and the first close across the short average after a long one-sided streak flags the run's end for a mean-reversion trade or an exit signal for trend riders.

2ROC - the 2-period ROC has just made a new 30-bar momentum high or low. Momentum precedes price: a fresh momentum extreme typically gets a pullback and then a retest of the price extreme, so this column flags markets where a thrust just happened and the swing playbook (buy the first pullback) applies.

20D - price is making a new 20-day high (20H) or 20-day low (20L). The 20-day channel is the classic intermediate breakout reference; Raschke watches tests of these levels because they are where trend players, breakout systems, and stops all congregate. Combined with Bias, this separates a confirmed breakout from a suspect poke.

HOW TO USE IT

The nightly routine. After the close (or before the open), read the table row by row on the daily lock:

- Rows where Bias, 2ROC, and 20D agree are trending candidates - the playbook is buying pullbacks in the bias direction, not fading.
- Rows showing 3bar or Coil with a flat bias are tomorrow's breakout watch - set alerts on the compression range and let the break pick the direction.
- An ExtSig flag warns that an extended run may be done: tighten stops if you are with the run, or stalk the reversion if that is your style.
- WR7 plus a fresh 20D break in the bias direction is initiation; WR7 after many one-sided closes alongside an ExtSig flag reads as climax.

The goal, in Raschke's spirit, is selection: out of ten markets, two or three rows will line up. Those get your attention tomorrow; the rest get ignored.

Toggles. Scan mode switches between the ten-symbol watchlist and the current chart only. Timeframe mode either locks the sheet to daily data - so you can monitor the daily homework while sitting on a 5-minute execution chart - or follows the chart's timeframe, which turns the same checklist into an intraday sheet.

Watchlist. Defaults cover the major futures groups - stock indices, metals, energies, rates, currencies, grains - and every slot is a symbol input, so the sheet works for any markets you trade.

LIMITATIONS

- This is a preparation scanner, not a signal generator. No column is an entry by itself, and the columns are deliberately simple binary flags - the judgment of combining them is yours, as it is on Raschke's own sheets.
- The table shows current conditions only; it does not keep history. Bar-by-bar flags repaint intrabar until the bar closes, so read the sheet after the session (its intended use) or treat live flags as provisional.
- Watchlist size is fixed at ten symbols to stay within Pine's data-request limits.
- Raschke's full sheets include readings this script does not compute. It covers the price-based checklist; it is not a substitute for her published materials.

THANKS

Credit to Linda Bradford Raschke (LBRGroup, Street Smarts) for the trade-sheet workflow, the 3/10 oscillator, and the 2-period ROC swing framework; to Toby Crabel for the range contraction/expansion concepts behind the WR7 and Coil columns; and to George Douglass Taylor, whose buy day / sell day cycle underlies the 2-period ROC's usefulness. Educational tool, not financial advice.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Raschke Trade Sheet — scanner
// Columns (per symbol, on the chosen timeframe):
//   Bias  = PF3  (3/10 fast + 3/10 slow + 2-period ROC all sloping the same way)
//   3bar  = B    (3-bar triangle: last bar inside the prior two)
//   WR7   = wide-range-7 (today's range is the widest of the last 7)
//   Coil  = low-TP proxy (3 bars of price overlap / balance)
//   ExtSig= 5-SMA extended run (>=7 closes one side) then first opposite close
//   2ROC  = 2-period rate-of-change at a new 30-bar momentum high/low
//   20D   = at a new 20-day high (20H) or low (20L)
//
// TOGGLES:
//   Scan      : "Watchlist" (10 symbols) or "Current chart only" (follows chart)
//   Timeframe : "Daily (lock)" forces daily even on a 5-min chart;
//               "Chart" uses whatever timeframe the chart is on.
//
// Pinball and divergence "magics" are not here (pinball needs 120/240-min data;
// divergence is the unpublished eye-aid — use the dedicated 3/10 indicator).
// =============================================================================
indicator("Raschke Trade Sheet (scanner)", "LBR Trade Sheet", overlay=true)

symMode = input.string("Watchlist", "Scan", options=["Watchlist", "Current chart only"])
tfMode  = input.string("Daily (lock)", "Timeframe", options=["Daily (lock)", "Chart"])
tf = tfMode == "Daily (lock)" ? "D" : timeframe.period

s1  = input.symbol("CME_MINI:ES1!", "Symbol 1",  group="Watchlist")
s2  = input.symbol("CME_MINI:NQ1!", "Symbol 2",  group="Watchlist")
s3  = input.symbol("COMEX:GC1!",    "Symbol 3",  group="Watchlist")
s4  = input.symbol("COMEX:SI1!",    "Symbol 4",  group="Watchlist")
s5  = input.symbol("NYMEX:CL1!",    "Symbol 5",  group="Watchlist")
s6  = input.symbol("NYMEX:NG1!",    "Symbol 6",  group="Watchlist")
s7  = input.symbol("CBOT:ZB1!",     "Symbol 7",  group="Watchlist")
s8  = input.symbol("CME:6E1!",      "Symbol 8",  group="Watchlist")
s9  = input.symbol("CME:6A1!",      "Symbol 9",  group="Watchlist")
s10 = input.symbol("CBOT:ZC1!",     "Symbol 10", group="Watchlist")

// short display name from a symbol string ("COMEX:GC1!" -> "GC1!")
f_name(s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

// ---- per-symbol calculation (returns a tuple of int flags) ----
f_row() =>
    rng  = high - low
    wr7  = rng >= ta.highest(rng, 7) ? 1 : 0
    tri  = (high < high[1] and high < high[2] and low > low[1] and low > low[2]) ? 1 : 0
    ovHi = math.min(math.min(high, high[1]), high[2])
    ovLo = math.max(math.max(low,  low[1]),  low[2])
    coil = ovHi > ovLo ? 1 : 0
    fast = ta.sma(close, 3) - ta.sma(close, 10)
    slow = ta.sma(fast, 16)
    roc2 = close - close[2]
    pf3  = (fast > fast[1] and slow > slow[1] and roc2 > roc2[1]) ? 1 : (fast < fast[1] and slow < slow[1] and roc2 < roc2[1]) ? -1 : 0
    sma5 = ta.sma(close, 5)
    bAbove = ta.barssince(close < sma5)
    bBelow = ta.barssince(close > sma5)
    sig5 = (bAbove[1] >= 7 and close < sma5) ? -1 : (bBelow[1] >= 7 and close > sma5) ? 1 : 0
    mom  = roc2 >= ta.highest(roc2, 30) ? 1 : roc2 <= ta.lowest(roc2, 30) ? -1 : 0
    nh   = high >= ta.highest(high, 20) ? 1 : 0
    nl   = low  <= ta.lowest(low, 20)  ? 1 : 0
    [wr7, tri, coil, pf3, sig5, mom, nh, nl]

// ---- requests: current chart + watchlist ----
[wrC,trC,coC,pfC,sgC,moC,nhC,nlC]  = request.security(syminfo.tickerid, tf, f_row())
[wr1,tr1,co1,pf1,sg1,mo1,nh1,nl1]  = request.security(s1,  tf, f_row())
[wr2,tr2,co2,pf2,sg2,mo2,nh2,nl2]  = request.security(s2,  tf, f_row())
[wr3,tr3,co3,pf3v,sg3,mo3,nh3,nl3] = request.security(s3,  tf, f_row())
[wr4,tr4,co4,pf4,sg4,mo4,nh4,nl4]  = request.security(s4,  tf, f_row())
[wr5,tr5,co5,pf5,sg5,mo5,nh5,nl5]  = request.security(s5,  tf, f_row())
[wr6,tr6,co6,pf6,sg6,mo6,nh6,nl6]  = request.security(s6,  tf, f_row())
[wr7v,tr7,co7,pf7,sg7,mo7,nh7,nl7] = request.security(s7,  tf, f_row())
[wr8,tr8,co8,pf8,sg8,mo8,nh8,nl8]  = request.security(s8,  tf, f_row())
[wr9,tr9,co9,pf9,sg9,mo9,nh9,nl9]  = request.security(s9,  tf, f_row())
[wr10,tr10,co10,pf10,sg10,mo10,nh10,nl10] = request.security(s10, tf, f_row())

// ---- table ----
transp = color.new(color.gray, 100)
var table t = table.new(position.top_right, 8, 12, border_width=1, frame_width=1, frame_color=color.gray)

f_hdr(c, txt) => table.cell(t, c, 0, txt, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))

setRow(r, nm, wr, tr, co, pf, sg, mo, nh, nl) =>
    table.cell(t, 0, r, nm, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(t, 1, r, pf == 1 ? "▲" : pf == -1 ? "▼" : "·", text_color=color.white, text_size=size.small, bgcolor = pf == 1 ? color.new(color.green,25) : pf == -1 ? color.new(color.red,25) : color.new(color.gray,70))
    table.cell(t, 2, r, tr == 1 ? "B" : "",   text_color=color.white, text_size=size.small, bgcolor = tr == 1 ? color.new(color.orange,15) : transp)
    table.cell(t, 3, r, wr == 1 ? "WR7" : "", text_color=color.white, text_size=size.small, bgcolor = wr == 1 ? color.new(color.blue,45)   : transp)
    table.cell(t, 4, r, co == 1 ? "coil" : "",text_color=color.white, text_size=size.small, bgcolor = co == 1 ? color.new(color.purple,45) : transp)
    table.cell(t, 5, r, sg == 1 ? "B" : sg == -1 ? "S" : "", text_color=color.white, text_size=size.small, bgcolor = sg == 1 ? color.new(color.green,20) : sg == -1 ? color.new(color.red,20) : transp)
    table.cell(t, 6, r, mo == 1 ? "▲" : mo == -1 ? "▼" : "", text_color=color.white, text_size=size.small, bgcolor = mo == 1 ? color.new(color.teal,45) : mo == -1 ? color.new(color.maroon,45) : transp)
    table.cell(t, 7, r, nh == 1 ? "20H" : nl == 1 ? "20L" : "", text_color=color.white, text_size=size.small, bgcolor = nh == 1 ? color.new(color.green,45) : nl == 1 ? color.new(color.red,45) : transp)

if barstate.islast
    table.clear(t, 0, 0, 7, 11)
    f_hdr(0, "Sym " + (tfMode == "Daily (lock)" ? "D" : timeframe.period))
    f_hdr(1, "Bias")
    f_hdr(2, "3bar")
    f_hdr(3, "WR7")
    f_hdr(4, "Coil")
    f_hdr(5, "ExtSig")
    f_hdr(6, "2ROC")
    f_hdr(7, "20D")
    if symMode == "Current chart only"
        setRow(1, syminfo.ticker, wrC, trC, coC, pfC, sgC, moC, nhC, nlC)
    else
        setRow(1,  f_name(s1),  wr1, tr1, co1, pf1,  sg1, mo1, nh1, nl1)
        setRow(2,  f_name(s2),  wr2, tr2, co2, pf2,  sg2, mo2, nh2, nl2)
        setRow(3,  f_name(s3),  wr3, tr3, co3, pf3v, sg3, mo3, nh3, nl3)
        setRow(4,  f_name(s4),  wr4, tr4, co4, pf4,  sg4, mo4, nh4, nl4)
        setRow(5,  f_name(s5),  wr5, tr5, co5, pf5,  sg5, mo5, nh5, nl5)
        setRow(6,  f_name(s6),  wr6, tr6, co6, pf6,  sg6, mo6, nh6, nl6)
        setRow(7,  f_name(s7),  wr7v,tr7, co7, pf7,  sg7, mo7, nh7, nl7)
        setRow(8,  f_name(s8),  wr8, tr8, co8, pf8,  sg8, mo8, nh8, nl8)
        setRow(9,  f_name(s9),  wr9, tr9, co9, pf9,  sg9, mo9, nh9, nl9)
        setRow(10, f_name(s10), wr10,tr10,co10,pf10, sg10,mo10,nh10,nl10)
````
