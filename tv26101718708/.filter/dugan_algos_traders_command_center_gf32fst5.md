# [Dugan Algos] Trader's Command Center

- url: https://www.tradingview.com/script/Gf32fSt5-Dugan-Algos-Trader-s-Command-Center/
- type: indicator
- pine_id: PUB;1aae2844467c47b1b69d204d9008361b
- version: 2.0

## Description

[b]Overview[/b]

Trader's Command Center consolidates the routine an active intraday trader repeats on every chart — marking the levels that matter, checking whether the trend actually agrees with itself, confirming that volume is present, and judging whether the move still has fuel — into a single overlay with one readable verdict.
The problem it addresses is fragmentation. Most traders end up running five or six separate scripts: one for previous-day levels, another for premarket, a VWAP, a moving-average package, something for relative volume, and a momentum oscillator in a lower pane. Each is fine alone, but reading them together means your eyes travel across the screen and you assemble the context manually, in real time, under pressure. That assembly step is where hesitation and inconsistency creep in.

TCC performs the assembly for you. Every component feeds one checklist table that resolves to a plain-language state — A+ LONG, A+ SHORT, LONG (low vol), SHORT (fading), or MIXED — so the question shifts from "what do all these indicators say?" to "does this setup meet my standard, yes or no?"

It works on stocks, options underlyings, and futures, and includes dedicated Asia and London session levels for overnight futures traders.

---

[b]Why these components are combined[/b]

The individual calculations here are standard and well documented — that is deliberate. The originality is in the scoring architecture, not in inventing a new formula.
Three specific pieces of integration logic do work that no combination of separate scripts performs:

1. Trend agreement is scored, not eyeballed. Six independent context checks (VWAP, EMA alignment, two SMAs, prior-day close, market breadth) are reduced to a single 0–6 score. Five or six agreeing is treated as directional conviction; anything less is explicitly labelled MIXED rather than left for you to interpret. The point is a consistent, repeatable threshold instead of a judgment call that shifts with your mood.

2. Volume and momentum act as gates on that score, not as more rows to weigh. Direction is necessary but not sufficient. A trend everyone agrees on but nobody is trading is a trap, and so is a trend that's already exhausted. Relative volume and momentum acceleration are therefore structurally separate from the directional score — they can only downgrade a verdict, never create one. This is why the header degrades in a defined order: `A+ LONG` → `LONG (low vol)` → `LONG (fading)`. Each tells you something different about why the setup is second-rate.

3. Momentum is measured relative to the prevailing bias. Every momentum reading in the script is sign-flipped to match the direction the checklist is pointing. On a short setup, a falling MACD histogram is momentum building, not fading. Bolting a standard MACD onto your chart requires you to perform that inversion mentally on every short — a small thing that produces real errors when you're managing a position quickly.

---

[b]Features[/b]

[i]Automatic key levels[/i]

Drawn without any manual charting, and updated as each period completes:
[list]
[*]Previous day high, low, and close
[*]Premarket high and low, accumulated live through the pre-session
[*]Opening range high and low, with a configurable duration (default 15 minutes)
[*]Prior week high and low
[*]Prior month high and low
[/list]

Each level carries a compact right-edge tag (PDH, PDL, PDC, PM-H, ORB-L, PWH, PMoH and so on) so you can identify a line at a glance without opening the settings panel. Labels can be switched off if you prefer a cleaner chart.

Higher-timeframe values are requested with a one-period offset, meaning the script only ever reads completed periods. These levels do not repaint.

[b]Futures session levels[/b]

For overnight and globex traders, optional Asia and London session highs and lows, alongside the standard prior-day and opening-range levels. Both session windows and the reference time zone are user-configurable — the defaults are New York time (Asia 18:00–03:00, London 03:00–09:30), which suit ES, NQ, CL and GC, but the fields accept any session string for other products or time zones.

[b]A+ Trade Checklist[/b]

The centrepiece. A compact table scoring six directional checks:

Check	Bullish when
Price vs VWAP	Price above session VWAP
EMA alignment	Fast EMA above slow EMA (default 9/21)
SMA 1	Price above the intermediate SMA (default 50)
SMA 2	Price above the long SMA (default 200)
Prior-day close	Price above yesterday's close
Market breadth	Advance-decline reading above zero

Five or six bullish gives a long bias; five or six bearish gives a short bias; anything in between reads MIXED. Two quality gates then qualify that bias — day RVOL and momentum — followed by two informational rows (bar RVOL and buy-volume percentage) that assist entry timing without affecting the verdict.

The header cell always states the conclusion outright, so you never need to count rows.

Momentum: accelerating or fading

A dedicated row answering the question most checklists ignore: is this move gaining or losing steam?

The measurement is the slope of the MACD histogram, normalised by ATR. The histogram is already the spread between fast and slow momentum, so its rate of change is effectively acceleration — an expanding histogram means the move is gaining separation, a contracting one means it's decaying even while price still drifts your way.

Dividing by ATR is what makes the reading portable. Raw histogram slope is expressed in price units, so a threshold tuned on SPY would be meaningless on ES or a four-dollar stock. Expressed as a percentage of average true range, a single threshold behaves consistently across every instrument.

The row displays one of three states — `▲ ACCEL`, `■ FLAT`, `▼ FADING` — with the normalised magnitude, plus a small `·adx↑` marker when ADX is simultaneously rising. A configurable flat zone prevents the state from flickering on trivial changes.
A dropdown controls how strictly momentum gates the verdict: Off (display only), Block if fading (default), or Require accelerating (strictest, suited to breakout entries).
Trending Stocks screener

Ranks up to eight watchlist symbols by daily relative volume, showing percent change alongside, sorted live so the most unusually active name sits at the top. Useful for deciding which chart deserves your attention before you commit to one.

Symbols are fully user-defined; the defaults are common large-cap names and index ETFs.

[b]Volume analysis[/b]

[i]Day RVOL [/i]— cumulative session volume against the 20-day average, the standard measure of whether a name is "in play"
[i]Bar RVOL[/i] — current bar volume against its recent average, for spotting individual bursts
[i]Buy/sell volume estimate[/i] — volume apportioned by where the bar closes within its range, giving a rough pressure read on each candle

[b]Trade planner[/b]

Enter an intended entry, stop, and target in the settings; the script draws all three on the chart with an automatic risk-to-reward calculation, absolute risk, and absolute reward. A fast way to sanity-check a trade's geometry before committing, or to review one afterwards.

[b]Alerts[/b]

Thirteen conditions covering breakouts, cross events, volume anomalies, and setup formation:
[list]
[*]Break above previous day high / below previous day low
[*]Break above premarket high / below premarket low
[*]Opening range breakout, up and down
[*]VWAP cross, up and down
[*]Relative volume spike
[*]A+ Long setup formed (bias + volume + momentum all confirmed)
[*]A+ Short setup formed
[*]Momentum fading — fires only while a directional bias is live, making it a genuine position-management trigger rather than background noise
[*]Momentum accelerating
[/list]

[b]Setup instructions[/b]

1. Add the indicator to your chart.
2. Enable extended trading hours. Right-click the chart → Settings → Symbol tab → tick Extended trading hours. Premarket high and low cannot be calculated without pre-session data, and the row will stay blank until this is enabled.
3. Use an intraday timeframe. The level suite, opening range, and session VWAP are built for intraday charts — 1 to 60 minutes. On daily and higher, intraday-specific levels are intentionally suppressed.
4. Confirm the breadth symbol. The checklist defaults to `USI:ADD` (NYSE advance-decline). If that row shows "n/a", your data plan may not include it — substitute any breadth symbol you do have access to, or a broad index proxy. The row will read n/a and score as bearish if the symbol is unavailable, so it's worth resolving rather than ignoring.
5. Set your session times if trading futures. Enable the futures group and adjust the Asia and London windows to match your product and time zone.
6. Create alerts. Add alert → Condition → select Trader's Command Center → choose the event from the dropdown. Set Once Per Bar Close if you want confirmed signals only; leaving it on Once Per Bar will fire intrabar and can trigger on moves that reverse before the candle closes.

---

[b]How to read it during a session[/b]

A workflow that suits most intraday traders:

Before the open, glance at the screener to see which of your names are running unusual volume. Note where premarket high and low sit relative to the previous day's range — a premarket high above yesterday's high with real volume is a materially different setup from one inside the prior range.

Through the opening drive, let the opening range establish, then watch for a break of ORB high or low. The checklist header tells you whether that break has context behind it. An ORB breakout with an A+ LONG verdict is a fundamentally different proposition from the same breakout printing MIXED.

In a position, the momentum row is your management tool. Direction rows staying green while momentum turns to FADING is the classic signal that a move is maturing — a reasonable trigger to tighten a stop or take partial profit, well before the directional rows themselves flip.
When the verdict reads MIXED, that is information. The context checks disagree, which usually means chop. Most consistent traders lose more money forcing trades in this state than they make from the ones that work.

---

[b]Tuning guidance[/b]

Slope lookback (default 3 bars) governs momentum responsiveness. Drop to 2 on a 1-minute chart if the reading feels slow; raise to 5 or more on 15-minute and above.
Flat zone (default ±3% of ATR) controls how much movement is required before the momentum state changes. If the row flickers between states more than you find useful, raise it to 5 or 6. This is the first knob to reach for — if the momentum gate is talking you out of trades that later work, the flat zone is usually too tight rather than the concept being wrong.
Day RVOL threshold (default 1.5x) sets the participation bar. Lower it to 1.2 for large-cap index products where 1.5x is genuinely rare; raise it to 2.0 or beyond if you only want names that are decisively in play.

Opening range duration (default 15 minutes) is a matter of style. Five minutes gives earlier, noisier signals; thirty produces fewer, cleaner breaks.
Momentum requirement should match your entry style. Breakout traders want Require accelerating. Pullback and mean-reversion traders often prefer Off, since entering as momentum decelerates is the entire premise of that approach.

---

[b]Limitations and honest notes[/b]

Pine cannot scan the whole market. The screener ranks only the symbols you enter. This is a platform constraint on all Pine scripts, not a design shortcut — TradingView limits the number of external symbol requests a script may make, and eight leaves headroom for the rest of the indicator's higher-timeframe calls.

Momentum measurement lags. MACD-derived acceleration is built on moving averages and inherits their delay. In a range, the histogram slope will whipsaw regardless of tuning. The momentum row is most reliable when the directional rows are already lopsided — it is a quality filter on an existing trend, not a standalone signal.

Buy/sell volume is an estimate. Without tick-level or order-flow data, the split is inferred from where each bar closes within its range. It is a reasonable proxy for pressure, not a substitute for a true delta feed.

Breadth is US-equity oriented. The default advance-decline symbol is meaningful for US stocks and index products. Trading FX, crypto, or non-US equities, the row should be repointed at something relevant or its influence on the score understood as noise.

The score is not a strategy. It describes context, not edge. It contains no backtest, makes no claim of profitability, and will happily print A+ LONG into a reversal. Entry, exit, position sizing, and risk management remain entirely yours.

Repainting: higher-timeframe levels read completed periods only and do not repaint. Live intraday values — the current bar's RVOL, momentum state, and checklist verdict — naturally update while the bar is forming and settle on close, as with any real-time indicator. Use Once Per Bar Close on alerts if you need confirmed-only behaviour.

---

Settings reference

Group	Contains
① Key Levels	Toggles for previous day, premarket, weekly, monthly levels and labels
② Opening Range	ORB on/off and duration in minutes
③ Futures Sessions	Asia and London session windows, reference time zone
④ Moving Averages / VWAP	VWAP toggle, two EMA lengths, two SMA lengths
⑤ Volume / RVOL	Averaging length, day-RVOL threshold, bar-spike multiple
⑥ Momentum	MACD lengths, slope lookback, ATR length, flat zone, A+ gate strictness
⑦ A+ Trade Checklist	Table on/off, breadth symbol, table position
⑧ Trending Stocks Screener	Table on/off, eight symbol slots
⑨ Trade Planner	Entry, stop, target prices

---

Disclaimer

This indicator is provided for educational and informational purposes only. It is not financial advice, not a recommendation to buy or sell any security or contract, and not a solicitation of any kind. It contains no strategy, no backtest, and makes no representation about past or future performance.
Trading stocks, options, and futures involves substantial risk of loss and is not suitable for every investor. Levels, scores, and alerts produced by this script describe market context; they do not predict outcomes. All trading decisions, position sizing, and risk management are your own responsibility. Test any tool thoroughly on a simulated account before risking capital.
---
Comments and suggestions are welcome. If you find a calculation that behaves unexpectedly on a particular instrument or session, please describe the symbol, timeframe, and settings so it can be reproduced.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────────────────
//  TRADER'S COMMAND CENTER  —  Complete workflow for stock / options / futures
//  Pine Script v6
// ─────────────────────────────────────────────────────────────────────────────
//  • Auto-drawn levels: Prev Day H/L/C, Premarket H/L, Opening Range,
//    Prior Week H/L, Prior Month H/L
//  • Futures session levels: Asia H/L, London H/L (plus ORB & prior day)
//  • A+ Trade Checklist (bull/bear context score) with market breadth
//  • Momentum row: is the move ACCELERATING, FLAT, or FADING (bias-relative)
//  • Trending Stocks screener (rank up to 8 watchlist symbols by RVOL)
//  • Buy/Sell volume estimate, bar RVOL, day RVOL
//  • SMA / EMA / VWAP context  +  Trade Planner (entry/stop/target, R:R)
//  • Alert conditions: PDH/PDL breaks, ORB breakout, VWAP cross, RVOL spike,
//    A+ setups, and momentum fading (trade-management warning)
//
//  SETUP NOTES
//  1) For Premarket levels: enable "Extended Trading Hours" on the chart
//     (right-click chart → Settings → Symbol → Extended hours), and use an
//     intraday timeframe.
//  2) Levels & ORB are designed for intraday charts (1m–60m).
//  3) Futures sessions default to New York time: Asia 18:00–03:00,
//     London 03:00–09:30. Adjust in settings if needed.
//  4) To create alerts: Add alert → Condition: this indicator → pick the event.
//
//  HOW THE MOMENTUM ROW WORKS
//  Measures the SLOPE of the MACD histogram (the spread between fast and slow
//  momentum) over N bars, divided by ATR so the reading is comparable across
//  any symbol or price. The sign is flipped to match the checklist bias, so a
//  falling histogram on a short setup reads as ACCELERATING. Readings inside
//  the flat zone are treated as neutral rather than forced into a direction.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Trader's Command Center", "TCC", overlay = true,
     max_lines_count = 500, max_labels_count = 500)

// ═════════════════════════════════ INPUTS ════════════════════════════════════
gLV  = "① Key Levels"
showPD   = input.bool(true,  "Previous Day High / Low / Close", group = gLV)
showPM   = input.bool(true,  "Premarket High / Low (needs ETH)", group = gLV)
showWK   = input.bool(true,  "Prior Week High / Low",           group = gLV)
showMO   = input.bool(true,  "Prior Month High / Low",          group = gLV)
showLbls = input.bool(true,  "Show level labels",               group = gLV)

gOR  = "② Opening Range"
showORB  = input.bool(true, "Opening Range High / Low", group = gOR)
orbMin   = input.int(15, "Opening Range minutes", minval = 1, maxval = 120, group = gOR)

gFU  = "③ Futures Sessions"
showFut  = input.bool(false, "Show Asia / London session levels", group = gFU)
asiaSess   = input.session("1800-0300", "Asia session (NY time)",   group = gFU)
londonSess = input.session("0300-0930", "London session (NY time)", group = gFU)
sessTZ     = input.string("America/New_York", "Session time zone",  group = gFU)

gMA  = "④ Moving Averages / VWAP"
showVWAP = input.bool(true, "VWAP (session)", group = gMA)
showEMAs = input.bool(true, "EMAs",           group = gMA)
emaFastL = input.int(9,   "Fast EMA",  minval = 1, group = gMA)
emaSlowL = input.int(21,  "Slow EMA",  minval = 1, group = gMA)
showSMAs = input.bool(true, "SMAs",           group = gMA)
sma1L    = input.int(50,  "SMA 1",     minval = 1, group = gMA)
sma2L    = input.int(200, "SMA 2",     minval = 1, group = gMA)

gRV  = "⑤ Volume / RVOL"
rvolLen    = input.int(20,   "RVOL average length (bars / days)", minval = 2, group = gRV)
rvolThresh = input.float(1.5,"Day-RVOL threshold for checklist",  minval = 0.1, step = 0.1, group = gRV)
spikeMult  = input.float(3.0,"Bar-RVOL spike multiple (alert)",   minval = 1.0, step = 0.5, group = gRV)

gMM  = "⑥ Momentum (accelerating vs fading)"
macdFastL = input.int(12, "MACD fast length",  minval = 1, group = gMM)
macdSlowL = input.int(26, "MACD slow length",  minval = 2, group = gMM)
macdSigL  = input.int(9,  "MACD signal length",minval = 1, group = gMM)
momLook   = input.int(3,  "Slope lookback (bars)", minval = 1, maxval = 50, group = gMM,
     tooltip = "How many bars back to measure the histogram slope. Lower = faster and noisier.")
atrLen    = input.int(14, "ATR length (normalizer)", minval = 1, group = gMM)
momDead   = input.float(3.0, "Flat zone (± % of ATR)", minval = 0.0, step = 0.5, group = gMM,
     tooltip = "Readings inside this band are called FLAT instead of ACCEL/FADING. Raise it to cut noise.")
momGate   = input.string("Block if fading", "A+ momentum requirement",
     options = ["Off", "Block if fading", "Require accelerating"], group = gMM,
     tooltip = "Off = momentum is display-only. Block if fading = A+ needs momentum not decaying. Require accelerating = strictest.")

gCK  = "⑦ A+ Trade Checklist"
showCheck  = input.bool(true, "Show checklist table", group = gCK)
breadthSym = input.symbol("USI:ADD", "Market breadth symbol (NYSE Adv-Dec)", group = gCK)
checkPos   = input.string("Top Right", "Checklist position",
     options = ["Top Right", "Middle Right", "Bottom Right", "Top Left"], group = gCK)

gSC  = "⑧ Trending Stocks Screener"
showScan = input.bool(false, "Show screener table (ranks by day RVOL)", group = gSC)
scan1 = input.symbol("NASDAQ:AAPL", "Symbol 1", group = gSC)
scan2 = input.symbol("NASDAQ:NVDA", "Symbol 2", group = gSC)
scan3 = input.symbol("NASDAQ:TSLA", "Symbol 3", group = gSC)
scan4 = input.symbol("NASDAQ:AMD",  "Symbol 4", group = gSC)
scan5 = input.symbol("NASDAQ:META", "Symbol 5", group = gSC)
scan6 = input.symbol("NASDAQ:MSFT", "Symbol 6", group = gSC)
scan7 = input.symbol("AMEX:SPY" ,   "Symbol 7", group = gSC)
scan8 = input.symbol("NASDAQ:QQQ",  "Symbol 8", group = gSC)

gTP  = "⑨ Trade Planner (review on chart)"
tpOn     = input.bool(false, "Show trade plan lines",   group = gTP)
tpEntry  = input.price(0.0,  "Entry price",             group = gTP)
tpStop   = input.price(0.0,  "Stop price",              group = gTP)
tpTarget = input.price(0.0,  "Target price",            group = gTP)

// ══════════════════ FUNCTION DECLARATIONS (must be global scope) ═════════════
// Rolling high/low for a custom session window
f_sessionHL(_sess, _tz) =>
    inS = not na(time(timeframe.period, _sess, _tz))
    var float h = na
    var float l = na
    if inS
        if not inS[1]
            h := high
            l := low
        else
            h := math.max(h, high)
            l := math.min(l, low)
    [h, l]

// Right-edge price tag; each call site keeps its own label instance
f_tag(_show, _price, _txt, _col) =>
    var label lb = na
    if barstate.islast and _show and showLbls and not na(_price)
        if na(lb)
            lb := label.new(bar_index, _price, _txt, style = label.style_label_left,
                 color = color.new(color.black, 80), textcolor = _col, size = size.small)
        label.set_xy(lb, bar_index + 3, _price)
        label.set_text(lb, _txt)

// Two-state checklist row (green = pass, red = fail)
f_row(_t, _r, _name, _ok, _val) =>
    table.cell(_t, 0, _r, _name, text_color = color.white, text_size = size.small,
         text_halign = text.align_left)
    table.cell(_t, 1, _r, _val, text_color = _ok ? color.lime : color.red,
         text_size = size.small)

// Multi-state checklist row (caller supplies the colour)
f_row3(_t, _r, _name, _col, _val) =>
    table.cell(_t, 0, _r, _name, text_color = color.white, text_size = size.small,
         text_halign = text.align_left)
    table.cell(_t, 1, _r, _val, text_color = _col, text_size = size.small)

// Screener header cell
f_head(_t, _c, _txt) =>
    table.cell(_t, _c, 0, _txt, text_color = color.white, text_size = size.small,
         bgcolor = color.new(color.blue, 60))

// Daily % change and day-RVOL for a screener symbol
f_scan(_sym, _len) =>
    [c, c1, v, av] = request.security(_sym, "D",
         [close, close[1], volume, ta.sma(volume, _len)[1]],
         ignore_invalid_symbol = true)
    chg = not na(c) and not na(c1) and c1 != 0 ? 100 * (c - c1) / c1 : na
    rv  = not na(v) and not na(av) and av > 0 ? v / av : na
    [chg, rv]

// Strip the exchange prefix off "EXCHANGE:TICKER"
f_name(_sym) =>
    parts = str.split(_sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : _sym

// Map the position dropdown to a position constant
f_pos(_s) =>
    _s == "Top Right"    ? position.top_right    :
     _s == "Middle Right" ? position.middle_right :
     _s == "Bottom Right" ? position.bottom_right : position.top_left

// ═══════════════════════════ HIGHER-TF LEVELS ════════════════════════════════
intraday = timeframe.isintraday

[pdH, pdL, pdC] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[pwH, pwL] = request.security(syminfo.tickerid, "W",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmoH, pmoL] = request.security(syminfo.tickerid, "M",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)
avgDayVol = request.security(syminfo.tickerid, "D",
     ta.sma(volume, rvolLen)[1], lookahead = barmerge.lookahead_on)

// ─── Premarket high / low (requires extended-hours data) ─────────────────────
var float pmHi = na
var float pmLo = na
if intraday and session.ispremarket
    if not session.ispremarket[1]
        pmHi := high
        pmLo := low
    else
        pmHi := math.max(pmHi, high)
        pmLo := math.min(pmLo, low)

// ─── Opening range ───────────────────────────────────────────────────────────
var float orbHi   = na
var float orbLo   = na
var int   rthOpen = na
if intraday and session.isfirstbar_regular
    rthOpen := time
    orbHi   := high
    orbLo   := low
else if intraday and session.ismarket and not na(rthOpen) and time < rthOpen + orbMin * 60000
    orbHi := math.max(orbHi, high)
    orbLo := math.min(orbLo, low)
orbDone = intraday and session.ismarket and not na(rthOpen) and time >= rthOpen + orbMin * 60000

// ─── Futures sessions (Asia / London) ────────────────────────────────────────
[asiaH, asiaL]     = f_sessionHL(asiaSess, sessTZ)
[londonH, londonL] = f_sessionHL(londonSess, sessTZ)

// ═══════════════════════════ MAs / VWAP / VOLUME ═════════════════════════════
emaFast = ta.ema(close, emaFastL)
emaSlow = ta.ema(close, emaSlowL)
sma1    = ta.sma(close, sma1L)
sma2    = ta.sma(close, sma2L)
vwapVal = ta.vwap(hlc3)

// Buy/Sell volume estimate (close position within the bar's range)
rng     = high - low
buyVol  = rng > 0 ? volume * (close - low) / rng : volume / 2
sellVol = volume - buyVol

// RVOL: per-bar and cumulative-day
avgBarVol = ta.sma(volume, rvolLen)
barRvol   = avgBarVol > 0 ? volume / avgBarVol : na
var float dayVol = na
newDay  = ta.change(time("D")) != 0
dayVol := newDay ? volume : nz(dayVol) + volume
dayRvol = not na(avgDayVol) and avgDayVol > 0 ? dayVol / avgDayVol : na

// Market breadth (NYSE advancers-decliners by default)
breadth = request.security(breadthSym, "D", close, ignore_invalid_symbol = true)

// ═════════════════════════ MOMENTUM ACCELERATION ═════════════════════════════
// MACD histogram = spread between fast and slow momentum. Its SLOPE tells us
// whether that spread is widening (move gaining steam) or narrowing (decaying).
[macdLine, sigLine, histLine] = ta.macd(close, macdFastL, macdSlowL, macdSigL)
atrVal    = ta.atr(atrLen)
histDelta = histLine - histLine[momLook]

// Normalise by ATR so one threshold works on a $4 stock, SPY, or ES.
momPct = not na(atrVal) and atrVal > 0 ? 100 * histDelta / atrVal : na

// ADX as a secondary strength marker (shown, not used as the trigger)
[diPlus, diMinus, adxVal] = ta.dmi(14, 14)
adxRising = not na(adxVal) and adxVal > nz(adxVal[momLook], adxVal)

// ═══════════════════════════ A+ TRADE CHECKLIST ══════════════════════════════
bullVWAP    = close > vwapVal
bullEMA     = emaFast > emaSlow
bullSMA1    = close > sma1
bullSMA2    = close > sma2
bullPDC     = not na(pdC) and close > pdC
bullBreadth = not na(breadth) and breadth > 0
rvolOK      = not na(dayRvol) and dayRvol >= rvolThresh

bullScore = (bullVWAP ? 1 : 0) + (bullEMA ? 1 : 0) + (bullSMA1 ? 1 : 0) +
     (bullSMA2 ? 1 : 0) + (bullPDC ? 1 : 0) + (bullBreadth ? 1 : 0)
bearScore = 6 - bullScore

// Flip the momentum sign to match the prevailing bias: on a short setup a
// FALLING histogram is momentum building, not fading.
dirUp      = bullScore >= bearScore
momAligned = na(momPct) ? na : (dirUp ? momPct : -momPct)

momAccel  = not na(momAligned) and momAligned >  momDead
momFading = not na(momAligned) and momAligned < -momDead
momFlat   = not na(momAligned) and not momAccel and not momFading

momCol = momAccel ? color.lime : momFading ? color.red : color.gray
momTxt = na(momAligned) ? "n/a" :
     (momAccel ? "▲ ACCEL " : momFading ? "▼ FADING " : "■ FLAT ") +
     str.tostring(momAligned, "#") + "%" + (adxRising ? " ·adx↑" : "")

momPass = momGate == "Off" ? true :
     momGate == "Require accelerating" ? momAccel : not momFading

// Header verdict: bias, then the two quality gates (volume, then momentum)
qualTxt = not rvolOK ? " (low vol)" : not momPass ? " (fading)" : ""
biasTxt = bullScore >= 5 ? (qualTxt == "" ? "A+ LONG"  : "LONG"  + qualTxt) :
     bearScore >= 5 ? (qualTxt == "" ? "A+ SHORT" : "SHORT" + qualTxt) : "MIXED"
biasCol = bullScore >= 5 ? color.green : bearScore >= 5 ? color.red : color.gray

buyPct = volume > 0 ? 100 * buyVol / volume : 50.0

var table ck = na
if showCheck and barstate.islast
    if na(ck)
        ck := table.new(f_pos(checkPos), 2, 11, border_width = 1,
             bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 60))
    table.cell(ck, 0, 0, "A+ CHECKLIST", text_color = color.white,
         text_size = size.small, bgcolor = color.new(color.blue, 60))
    table.cell(ck, 1, 0, biasTxt, text_color = color.white,
         text_size = size.small, bgcolor = color.new(biasCol, 30))
    f_row(ck, 1, "Price > VWAP", bullVWAP, bullVWAP ? "YES" : "NO")
    f_row(ck, 2, "EMA " + str.tostring(emaFastL) + " > " + str.tostring(emaSlowL),
         bullEMA, bullEMA ? "YES" : "NO")
    f_row(ck, 3, "Price > SMA " + str.tostring(sma1L), bullSMA1, bullSMA1 ? "YES" : "NO")
    f_row(ck, 4, "Price > SMA " + str.tostring(sma2L), bullSMA2, bullSMA2 ? "YES" : "NO")
    f_row(ck, 5, "Above PD Close", bullPDC, bullPDC ? "YES" : "NO")
    f_row(ck, 6, "Breadth (ADD>0)", bullBreadth,
         na(breadth) ? "n/a" : str.tostring(breadth, "#"))
    f_row(ck, 7, "Day RVOL ≥ " + str.tostring(rvolThresh, "#.#"), rvolOK,
         na(dayRvol) ? "n/a" : str.tostring(dayRvol, "#.##") + "x")
    f_row3(ck, 8, "Momentum", momCol, momTxt)
    f_row(ck, 9, "Bar RVOL", not na(barRvol) and barRvol >= 1,
         na(barRvol) ? "n/a" : str.tostring(barRvol, "#.##") + "x")
    f_row(ck, 10, "Buy vol %", buyPct >= 50, str.tostring(buyPct, "#") + "%")

// ═══════════════════════════════ PLOT LEVELS ═════════════════════════════════
cPDH = color.new(color.red,    0)
cPDL = color.new(color.green,  0)
cPDC = color.new(color.gray,  20)
cPM  = color.new(color.orange, 0)
cORB = color.new(color.aqua,   0)
cWK  = color.new(color.purple, 0)
cMO  = color.new(color.fuchsia,0)
cAS  = color.new(color.yellow,20)
cLN  = color.new(color.teal,  20)

plot(showPD and intraday ? pdH  : na, "Prev Day High",  cPDH, 2, plot.style_linebr)
plot(showPD and intraday ? pdL  : na, "Prev Day Low",   cPDL, 2, plot.style_linebr)
plot(showPD and intraday ? pdC  : na, "Prev Day Close", cPDC, 1, plot.style_linebr)
plot(showPM and intraday ? pmHi : na, "Premarket High", cPM,  1, plot.style_linebr)
plot(showPM and intraday ? pmLo : na, "Premarket Low",  cPM,  1, plot.style_linebr)
plot(showORB and orbDone ? orbHi : na, "ORB High", cORB, 2, plot.style_linebr)
plot(showORB and orbDone ? orbLo : na, "ORB Low",  cORB, 2, plot.style_linebr)
plot(showWK and intraday ? pwH  : na, "Prior Week High",  cWK, 1, plot.style_linebr)
plot(showWK and intraday ? pwL  : na, "Prior Week Low",   cWK, 1, plot.style_linebr)
plot(showMO and intraday ? pmoH : na, "Prior Month High", cMO, 1, plot.style_linebr)
plot(showMO and intraday ? pmoL : na, "Prior Month Low",  cMO, 1, plot.style_linebr)
plot(showFut and intraday ? asiaH   : na, "Asia High",   cAS, 1, plot.style_linebr)
plot(showFut and intraday ? asiaL   : na, "Asia Low",    cAS, 1, plot.style_linebr)
plot(showFut and intraday ? londonH : na, "London High", cLN, 1, plot.style_linebr)
plot(showFut and intraday ? londonL : na, "London Low",  cLN, 1, plot.style_linebr)

plot(showVWAP and intraday ? vwapVal : na, "VWAP", color.new(color.blue, 0), 2)
plot(showEMAs ? emaFast : na, "EMA Fast", color.new(color.lime,   0), 1)
plot(showEMAs ? emaSlow : na, "EMA Slow", color.new(color.orange, 0), 1)
plot(showSMAs ? sma1    : na, "SMA 1",    color.new(color.silver, 0), 1)
plot(showSMAs ? sma2    : na, "SMA 2",    color.new(color.white,  0), 2)

// ─── Level labels at right edge ──────────────────────────────────────────────
f_tag(showPD and intraday,  pdH,   "PDH",    cPDH)
f_tag(showPD and intraday,  pdL,   "PDL",    cPDL)
f_tag(showPD and intraday,  pdC,   "PDC",    cPDC)
f_tag(showPM and intraday,  pmHi,  "PM-H",   cPM)
f_tag(showPM and intraday,  pmLo,  "PM-L",   cPM)
f_tag(showORB and orbDone,  orbHi, "ORB-H",  cORB)
f_tag(showORB and orbDone,  orbLo, "ORB-L",  cORB)
f_tag(showWK and intraday,  pwH,   "PWH",    cWK)
f_tag(showWK and intraday,  pwL,   "PWL",    cWK)
f_tag(showMO and intraday,  pmoH,  "PMoH",   cMO)
f_tag(showMO and intraday,  pmoL,  "PMoL",   cMO)
f_tag(showFut and intraday, asiaH,   "Asia-H", cAS)
f_tag(showFut and intraday, asiaL,   "Asia-L", cAS)
f_tag(showFut and intraday, londonH, "Ldn-H",  cLN)
f_tag(showFut and intraday, londonL, "Ldn-L",  cLN)

// ═══════════════════════ TRENDING STOCKS SCREENER ════════════════════════════
[chg1, rv1] = f_scan(scan1, rvolLen)
[chg2, rv2] = f_scan(scan2, rvolLen)
[chg3, rv3] = f_scan(scan3, rvolLen)
[chg4, rv4] = f_scan(scan4, rvolLen)
[chg5, rv5] = f_scan(scan5, rvolLen)
[chg6, rv6] = f_scan(scan6, rvolLen)
[chg7, rv7] = f_scan(scan7, rvolLen)
[chg8, rv8] = f_scan(scan8, rvolLen)

var table sc = na
if showScan and barstate.islast
    names = array.from(f_name(scan1), f_name(scan2), f_name(scan3), f_name(scan4),
         f_name(scan5), f_name(scan6), f_name(scan7), f_name(scan8))
    chgs = array.from(chg1, chg2, chg3, chg4, chg5, chg6, chg7, chg8)
    rvs  = array.from(rv1, rv2, rv3, rv4, rv5, rv6, rv7, rv8)
    idx  = array.from(0, 1, 2, 3, 4, 5, 6, 7)
    // sort indices by RVOL, descending (missing data sinks to the bottom)
    for i = 0 to 6
        for j = 0 to 6 - i
            a  = array.get(idx, j)
            b  = array.get(idx, j + 1)
            ra = nz(array.get(rvs, a), -1.0)
            rb = nz(array.get(rvs, b), -1.0)
            if rb > ra
                array.set(idx, j, b)
                array.set(idx, j + 1, a)
    if na(sc)
        sc := table.new(position.bottom_left, 4, 9, border_width = 1,
             bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 60))
    f_head(sc, 0, "#")
    f_head(sc, 1, "Ticker")
    f_head(sc, 2, "Chg %")
    f_head(sc, 3, "RVOL")
    for r = 0 to 7
        k    = array.get(idx, r)
        chgV = array.get(chgs, k)
        rvV  = array.get(rvs, k)
        cCol = na(chgV) ? color.gray : chgV >= 0 ? color.lime : color.red
        table.cell(sc, 0, r + 1, str.tostring(r + 1), text_color = color.white, text_size = size.small)
        table.cell(sc, 1, r + 1, array.get(names, k), text_color = color.white, text_size = size.small)
        table.cell(sc, 2, r + 1, na(chgV) ? "n/a" : str.tostring(chgV, "#.##") + "%",
             text_color = cCol, text_size = size.small)
        table.cell(sc, 3, r + 1, na(rvV) ? "n/a" : str.tostring(rvV, "#.##") + "x",
             text_color = color.aqua, text_size = size.small)

// ═══════════════════════════ TRADE PLANNER ═══════════════════════════════════
var line  tpE = na
var line  tpS = na
var line  tpT = na
var label tpL = na
if tpOn and barstate.islast and tpEntry > 0 and tpStop > 0 and tpTarget > 0
    x1 = bar_index - 20
    x2 = bar_index + 10
    if na(tpE)
        tpE := line.new(x1, tpEntry,  x2, tpEntry,  color = color.white, width = 2)
        tpS := line.new(x1, tpStop,   x2, tpStop,   color = color.red,   width = 2)
        tpT := line.new(x1, tpTarget, x2, tpTarget, color = color.green, width = 2)
        tpL := label.new(x2, tpTarget, "", style = label.style_label_left,
             color = color.new(color.black, 60), textcolor = color.white, size = size.small)
    line.set_xy1(tpE, x1, tpEntry)
    line.set_xy2(tpE, x2, tpEntry)
    line.set_xy1(tpS, x1, tpStop)
    line.set_xy2(tpS, x2, tpStop)
    line.set_xy1(tpT, x1, tpTarget)
    line.set_xy2(tpT, x2, tpTarget)
    risk   = math.abs(tpEntry - tpStop)
    reward = math.abs(tpTarget - tpEntry)
    rr     = risk > 0 ? reward / risk : na
    label.set_xy(tpL, x2, tpTarget)
    label.set_text(tpL, "R:R  " + (na(rr) ? "n/a" : str.tostring(rr, "#.##")) +
         "\nRisk " + str.tostring(risk, format.mintick) +
         "  Reward " + str.tostring(reward, format.mintick))

// ═══════════════════════════════ ALERTS ══════════════════════════════════════
// NOTE: v6 short-circuits `and` / `or`, so every ta.* call is evaluated
// unconditionally first and only then combined with its guard condition.
xPDHup = ta.crossover(close, pdH)
xPDLdn = ta.crossunder(close, pdL)
xPMHup = ta.crossover(close, pmHi)
xPMLdn = ta.crossunder(close, pmLo)
xORBup = ta.crossover(close, orbHi)
xORBdn = ta.crossunder(close, orbLo)
xVWup  = ta.crossover(close, vwapVal)
xVWdn  = ta.crossunder(close, vwapVal)

crossPDHup = not na(pdH)  and xPDHup
crossPDLdn = not na(pdL)  and xPDLdn
crossPMHup = not na(pmHi) and xPMHup
crossPMLdn = not na(pmLo) and xPMLdn
orbBreakUp = orbDone and xORBup
orbBreakDn = orbDone and xORBdn
rvolSpike  = not na(barRvol) and barRvol >= spikeMult and nz(barRvol[1], 0) < spikeMult

aPlusLongNow  = bullScore >= 5 and rvolOK and momPass
aPlusShortNow = bearScore >= 5 and rvolOK and momPass
aPlusLong     = aPlusLongNow  and not aPlusLongNow[1]
aPlusShort    = aPlusShortNow and not aPlusShortNow[1]

// Trade-management warning: momentum rolls over while a directional bias is live
momJustFaded  = momFading and not momFading[1] and (bullScore >= 5 or bearScore >= 5)
momJustAccel  = momAccel  and not momAccel[1]

alertcondition(crossPDHup, "Break above Prev Day High", "Price broke above the previous day high")
alertcondition(crossPDLdn, "Break below Prev Day Low",  "Price broke below the previous day low")
alertcondition(crossPMHup, "Break above Premarket High","Price broke above the premarket high")
alertcondition(crossPMLdn, "Break below Premarket Low", "Price broke below the premarket low")
alertcondition(orbBreakUp, "ORB Breakout Up",   "Price broke above the opening range high")
alertcondition(orbBreakDn, "ORB Breakout Down", "Price broke below the opening range low")
alertcondition(xVWup,      "VWAP Cross Up",     "Price crossed above VWAP")
alertcondition(xVWdn,      "VWAP Cross Down",   "Price crossed below VWAP")
alertcondition(rvolSpike,  "RVOL Spike",        "Bar relative volume spiked above the spike multiple")
alertcondition(aPlusLong,  "A+ Long Setup",     "Checklist flipped to A+ LONG with volume and momentum confirmation")
alertcondition(aPlusShort, "A+ Short Setup",    "Checklist flipped to A+ SHORT with volume and momentum confirmation")
alertcondition(momJustFaded, "Momentum Fading", "Momentum turned against the active bias — consider tightening or trimming")
alertcondition(momJustAccel, "Momentum Accelerating", "Momentum started expanding in the direction of the bias")
````
