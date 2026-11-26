# Chandelier Verdict Lab: Chandelier Exit Test [forexobroker]

- url: https://www.tradingview.com/script/sApE5fH1-Chandelier-Verdict-Lab-Chandelier-Exit-Test-forexobroker/
- type: indicator
- pine_id: PUB;e429e4b767294f39beaac7365675bf37
- version: 1.0

## Description

Chandelier Verdict Lab: Chandelier Exit Test [forexobroker]

🔶 OVERVIEW

Chandelier Verdict Lab puts the viral Chandelier Exit + ZLSMA strategies on trial on your own chart. It computes the Chandelier Exit by everget and the ZLSMA (Zero Lag LSMA) by veryfid with their own formulas, runs six versions of the strategy side by side, and logs every trade of each in R: the versions sold as "80 % accuracy", "92 % win rate", "300 % profit", "60 winners out of 100" and "100x tested", plus the Chandelier Exit alone as the control. A table compares the six, a pane races them trade by trade, and a matrix shows one version on four markets and four timeframes at once.

Credit: the Chandelier Exit is the open-source script by everget (GPL-3.0) and the ZLSMA is the open-source script by veryfid (MPL 2.0). This script is published under the GPL-3.0.

🔶 THE INDICATORS

- Chandelier Exit: a trailing line set a multiple of the ATR away from the highest close (longs) or the lowest close (shorts) of the last N candles. It only moves in the trade's direction, and it flips sides when the close crosses the other line; that flip prints the Buy or Sell label. "Use close for extremums" switches between closes and highs / lows.
- ZLSMA: a zero-lag least-squares moving average: the linear regression of the close over N candles, plus the difference between that line and its own regression.
- Heikin Ashi candles are computed from the chart's real candles for the versions that use them.

🔶 THE SIX VERSIONS (defaults = the rules as each was published)

A. "80 % accuracy": Heikin Ashi, Chandelier Exit 1 × 1.85 (closes off), ZLSMA 32. After a Buy label, buy on the first close above the ZLSMA. Exit when a candle closes back below the ZLSMA. Buys only. The published rules give no stop, so the stop is at the 10-candle swing.

B. "92 % win rate": Chandelier Exit 1 × 2, ZLSMA 130. Buy on a Buy label with the price above the ZLSMA, sell on a Sell label below it. Exit on the opposite signal. Stop at the swing.

C. "300 % profit": Heikin Ashi, Chandelier Exit 1 × 1.85 (closes off), ZLSMA 75. Buy on a Buy label above the ZLSMA (sell mirror). Stop at the swing. Target 2R.

D. "60 winners out of 100": Heikin Ashi, Chandelier Exit 1 × 1.85, ZLSMA 32, buys only. After a Buy label, buy on a green candle that crosses up through the ZLSMA (a Buy while the price is already above it is ignored). Stop at the swing. Target 1.5R.

E. "100x tested": Chandelier Exit 22 × 3, ZLSMA 50. Buy on a Buy label above the ZLSMA (sell mirror). Exit on a close back through the ZLSMA while in profit, or on the opposite signal. Stop at the swing.

F. The Chandelier Exit alone (everget's defaults, 22 × 3): every Buy and every Sell, the line itself is the stop, out on the opposite signal.

Every field of every version is an input, so you can test your own settings. A trade opens at the close of the candle on which its conditions first agree. Stops are never closer than 0.25 × ATR(14); that distance is 1R. One trade at a time per version. Every decision uses closed candles; when one candle touches both the stop and the target, the stop counts first.

REAL PRICES: entries, stops, targets and exits are measured at the real prices of the candle, also on a Heikin Ashi chart (the script reads the standard candles there). A switch, "Measure Heikin Ashi logs at Heikin Ashi prices", shows what a backtest on a Heikin Ashi chart sees instead: those averaged prices cannot be traded.

NON-REPAINTING: every decision is taken on barstate.isconfirmed; the matrix requests use lookahead off.

🔶 THE TABLE, THE RACE AND THE MATRIX

- Log table: trades, wins, win rate and total R of each version over its last N trades (100 by default); the version drawn on the chart is highlighted.
- Equity race (the script's pane): each version's running total in R from a start date you choose, with a leaderboard.
- Verdict matrix: the drawn version's total R on four markets × four timeframes (both lists are inputs), coloured green or red.
- "Test ends at": freezes every log at a moment you choose, so the table stays the same however long the chart stays open.

🔶 SETTINGS

Display
- Log drawn on the chart (A-F), the table (Log table, Verdict matrix or off), the leaderboard, text size and position, the equity race start.

Version A to F
- Name, Chandelier ATR period and multiplier, close for extremums, ZLSMA length, candles (regular or Heikin Ashi), entry, stop, exit, target (R), direction.

Stops and log
- Swing lookback (10), minimum stop distance (0.25 × ATR 14), the ZLSMA wait (5 candles), log size (100), Heikin Ashi prices on or off, test end.

Verdict matrix
- Four markets and four timeframes.

Visual
- Colours, trades kept on the chart, the Chandelier Exit and its labels on or off.

🔶 ALERTS

Two alertcondition hooks (long entry, short entry) for the version drawn on the chart.

🔶 LIMITATIONS

- Results depend on the market, the timeframe and the settings; the table shows them on your own chart, losses included.
- The logs count the script's own rules on closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- The last-N window covers different calendar spans on different timeframes and versions. The matrix needs enough history on the chart for the slower timeframes.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

🔶 RELEASE NOTES

v1.0 — Initial release. Chandelier Exit and ZLSMA computed with their own formulas; six versions with their own settings; a comparison table, an equity race with a leaderboard, a 16-cell verdict matrix; real prices on Heikin Ashi charts with a Heikin Ashi price switch; a test end date.

## Source Code

````pine
// This source code is subject to the terms of the GNU General Public License v3.0 (https://www.gnu.org/licenses/gpl-3.0.html):
// it reuses everget's Chandelier Exit (GPL-3.0) and veryfid's ZLSMA (MPL 2.0, compatible).
// © forexobroker
//@version=6
// ALGORITHM: Chandelier Verdict Lab — the viral Chandelier Exit + ZLSMA strategies (sold as "80 % accurate",
// "92 % win rate", "300 % profit", "100x tested") and the Chandelier Exit alone, each logged on the same chart with
// the same risk unit, side by side.
// THE INDICATORS (open source on TradingView, same formulas, credited by name):
//   Chandelier Exit (everget). An ATR trailing line: highest close of N candles minus multiplier x ATR(N) for longs,
//   lowest close plus multiplier x ATR(N) for shorts, each only allowed to move in the trade's favour. The direction
//   flips when the close crosses the other side's previous line; that flip prints the Buy / Sell label.
//   ZLSMA (veryfid). A zero-lag least-squares moving average: LSMA = linear regression of the close over N candles,
//   then LSMA + (LSMA - linear regression of the LSMA).
// THE LOGS: six versions, each with its own Chandelier settings, ZLSMA length, candle type, entry filter, stop and
//   exit (see the Version groups). A trade opens at the close of the candle where its conditions first agree; with
//   Heikin Ashi candles the signal is read from Heikin Ashi values, but the trade is filled and measured at the real
//   prices of the candle (what a broker gives you). The stop is checked first when one candle touches the stop and the
//   target. One trade at a time per log. 1R = the distance from the entry to the stop.
// Non-repainting: every decision is taken on barstate.isconfirmed; the matrix requests use lookahead off.
indicator("Chandelier Verdict Lab: Chandelier Exit Test [forexobroker]", shorttitle="CVL [fob]", overlay=false, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_show = "Display"
string g_v0 = "Version A"
string g_v1 = "Version B"
string g_v2 = "Version C"
string g_v3 = "Version D"
string g_v4 = "Version E"
string g_v5 = "Version F"
string g_risk = "Stops and log"
string g_mx = "Verdict matrix"
string g_vis = "Visual"

string O_REG = "Regular"
string O_HA  = "Heikin Ashi"
string F_NONE = "Chandelier signal only"
string F_CL   = "Signal + close beyond ZLSMA"
string F_WAIT = "Signal, then close beyond ZLSMA (wait)"
string F_SLOPE = "Signal + ZLSMA slope"
string F_CROSS = "Signal, then a candle crossing up through ZLSMA"
string D_BOTH = "Longs and shorts"
string D_LONG = "Longs only"
string S_CE  = "Chandelier line"
string S_SW  = "Swing (N candles)"
string S_ZL  = "ZLSMA"
string X_TGT = "Target (R)"
string X_OPP = "Opposite Chandelier signal"
string X_BOTH = "Target or opposite signal"
string X_ZL   = "Close back across ZLSMA"
string X_HALF = "Half at target, rest on ZLSMA close"
string X_ZLP  = "ZLSMA close in profit, or opposite signal"

// ─── DISPLAY ───────────────────────────────────────────────────────────────────
string i_show   = input.string("A", "Log drawn on the chart", options=["A", "B", "C", "D", "E", "F"], group=g_show, tooltip="All six logs are in the table; this one draws its trades, its Chandelier Exit and its ZLSMA on the chart.")
string i_board  = input.string("Log table", "Table on the chart", options=["Log table", "Verdict matrix", "Off"], group=g_show)
bool   i_rank   = input.bool(true, "Leaderboard in the pane", group=g_show)
string i_size   = input.string("Large", "Table text size", options=["Small", "Normal", "Large", "Huge"], group=g_show)
string i_pos    = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Center"], group=g_show)
int    i_raceFrom = input.time(timestamp("2026-01-01T00:00:00"), "Equity race starts", group=g_show, tooltip="The pane adds up each log's results (in R) from this moment on.")

// ─── VERSIONS ──────────────────────────────────────────────────────────────────
// defaults = what each creator showed (see the description); every field can be changed
string n0 = input.string("80% accuracy", "Name", group=g_v0)
int    l0 = input.int(1, "Chandelier ATR period", minval=1, maxval=200, group=g_v0, inline="0a")
float  m0 = input.float(1.85, "Multiplier", minval=0.1, maxval=20, step=0.1, group=g_v0, inline="0a")
bool   u0 = input.bool(false, "Close for extremums", group=g_v0, inline="0a")
int    z0 = input.int(32, "ZLSMA length", minval=2, maxval=500, group=g_v0, inline="0b")
string c0 = input.string(O_HA, "Candles", options=[O_REG, O_HA], group=g_v0, inline="0b")
string f0 = input.string(F_WAIT, "Entry", options=[F_NONE, F_CL, F_WAIT, F_SLOPE, F_CROSS], group=g_v0)
string s0 = input.string(S_SW, "Stop", options=[S_CE, S_SW, S_ZL], group=g_v0, inline="0c")
string x0 = input.string(X_ZL, "Exit", options=[X_TGT, X_OPP, X_BOTH, X_ZL, X_HALF, X_ZLP], group=g_v0, inline="0c")
float  r0 = input.float(2.0, "Target (R)", minval=0.5, maxval=10, step=0.1, group=g_v0)
string d0 = input.string(D_LONG, "Direction", options=[D_BOTH, D_LONG], group=g_v0)

string n1 = input.string("92% win rate", "Name", group=g_v1)
int    l1 = input.int(1, "Chandelier ATR period", minval=1, maxval=200, group=g_v1, inline="1a")
float  m1 = input.float(2.0, "Multiplier", minval=0.1, maxval=20, step=0.1, group=g_v1, inline="1a")
bool   u1 = input.bool(true, "Close for extremums", group=g_v1, inline="1a")
int    z1 = input.int(130, "ZLSMA length", minval=2, maxval=500, group=g_v1, inline="1b")
string c1 = input.string(O_REG, "Candles", options=[O_REG, O_HA], group=g_v1, inline="1b")
string f1 = input.string(F_CL, "Entry", options=[F_NONE, F_CL, F_WAIT, F_SLOPE, F_CROSS], group=g_v1)
string s1 = input.string(S_SW, "Stop", options=[S_CE, S_SW, S_ZL], group=g_v1, inline="1c")
string x1 = input.string(X_OPP, "Exit", options=[X_TGT, X_OPP, X_BOTH, X_ZL, X_HALF, X_ZLP], group=g_v1, inline="1c")
float  r1 = input.float(2.0, "Target (R)", minval=0.5, maxval=10, step=0.1, group=g_v1)
string d1 = input.string(D_BOTH, "Direction", options=[D_BOTH, D_LONG], group=g_v1)

string n2 = input.string("300% profit", "Name", group=g_v2)
int    l2 = input.int(1, "Chandelier ATR period", minval=1, maxval=200, group=g_v2, inline="2a")
float  m2 = input.float(1.85, "Multiplier", minval=0.1, maxval=20, step=0.1, group=g_v2, inline="2a")
bool   u2 = input.bool(false, "Close for extremums", group=g_v2, inline="2a")
int    z2 = input.int(75, "ZLSMA length", minval=2, maxval=500, group=g_v2, inline="2b")
string c2 = input.string(O_HA, "Candles", options=[O_REG, O_HA], group=g_v2, inline="2b")
string f2 = input.string(F_CL, "Entry", options=[F_NONE, F_CL, F_WAIT, F_SLOPE, F_CROSS], group=g_v2)
string s2 = input.string(S_SW, "Stop", options=[S_CE, S_SW, S_ZL], group=g_v2, inline="2c")
string x2 = input.string(X_TGT, "Exit", options=[X_TGT, X_OPP, X_BOTH, X_ZL, X_HALF, X_ZLP], group=g_v2, inline="2c")
float  r2 = input.float(2.0, "Target (R)", minval=0.5, maxval=10, step=0.1, group=g_v2)
string d2 = input.string(D_BOTH, "Direction", options=[D_BOTH, D_LONG], group=g_v2)

string n3 = input.string("15-minute scalp", "Name", group=g_v3)
int    l3 = input.int(1, "Chandelier ATR period", minval=1, maxval=200, group=g_v3, inline="3a")
float  m3 = input.float(1.85, "Multiplier", minval=0.1, maxval=20, step=0.1, group=g_v3, inline="3a")
bool   u3 = input.bool(false, "Close for extremums", group=g_v3, inline="3a")
int    z3 = input.int(32, "ZLSMA length", minval=2, maxval=500, group=g_v3, inline="3b")
string c3 = input.string(O_HA, "Candles", options=[O_REG, O_HA], group=g_v3, inline="3b")
string f3 = input.string(F_CROSS, "Entry", options=[F_NONE, F_CL, F_WAIT, F_SLOPE, F_CROSS], group=g_v3)
string s3 = input.string(S_SW, "Stop", options=[S_CE, S_SW, S_ZL], group=g_v3, inline="3c")
string x3 = input.string(X_TGT, "Exit", options=[X_TGT, X_OPP, X_BOTH, X_ZL, X_HALF, X_ZLP], group=g_v3, inline="3c")
float  r3 = input.float(1.5, "Target (R)", minval=0.5, maxval=10, step=0.1, group=g_v3)
string d3 = input.string(D_LONG, "Direction", options=[D_BOTH, D_LONG], group=g_v3)

string n4 = input.string("100x tested", "Name", group=g_v4)
int    l4 = input.int(22, "Chandelier ATR period", minval=1, maxval=200, group=g_v4, inline="4a")
float  m4 = input.float(3.0, "Multiplier", minval=0.1, maxval=20, step=0.1, group=g_v4, inline="4a")
bool   u4 = input.bool(true, "Close for extremums", group=g_v4, inline="4a")
int    z4 = input.int(50, "ZLSMA length", minval=2, maxval=500, group=g_v4, inline="4b")
string c4 = input.string(O_REG, "Candles", options=[O_REG, O_HA], group=g_v4, inline="4b")
string f4 = input.string(F_CL, "Entry", options=[F_NONE, F_CL, F_WAIT, F_SLOPE, F_CROSS], group=g_v4)
string s4 = input.string(S_SW, "Stop", options=[S_CE, S_SW, S_ZL], group=g_v4, inline="4c")
string x4 = input.string(X_ZLP, "Exit", options=[X_TGT, X_OPP, X_BOTH, X_ZL, X_HALF, X_ZLP], group=g_v4, inline="4c")
float  r4 = input.float(2.0, "Target (R)", minval=0.5, maxval=10, step=0.1, group=g_v4)
string d4 = input.string(D_BOTH, "Direction", options=[D_BOTH, D_LONG], group=g_v4)

string n5 = input.string("Chandelier alone", "Name", group=g_v5)
int    l5 = input.int(22, "Chandelier ATR period", minval=1, maxval=200, group=g_v5, inline="5a")
float  m5 = input.float(3.0, "Multiplier", minval=0.1, maxval=20, step=0.1, group=g_v5, inline="5a")
bool   u5 = input.bool(true, "Close for extremums", group=g_v5, inline="5a")
int    z5 = input.int(32, "ZLSMA length", minval=2, maxval=500, group=g_v5, inline="5b")
string c5 = input.string(O_REG, "Candles", options=[O_REG, O_HA], group=g_v5, inline="5b")
string f5 = input.string(F_NONE, "Entry", options=[F_NONE, F_CL, F_WAIT, F_SLOPE, F_CROSS], group=g_v5)
string s5 = input.string(S_CE, "Stop", options=[S_CE, S_SW, S_ZL], group=g_v5, inline="5c")
string x5 = input.string(X_OPP, "Exit", options=[X_TGT, X_OPP, X_BOTH, X_ZL, X_HALF, X_ZLP], group=g_v5, inline="5c")
float  r5 = input.float(2.0, "Target (R)", minval=0.5, maxval=10, step=0.1, group=g_v5)
string d5 = input.string(D_BOTH, "Direction", options=[D_BOTH, D_LONG], group=g_v5)

// ─── STOPS AND LOG ─────────────────────────────────────────────────────────────
int   i_swing   = input.int(10, "Swing stop: lookback (candles)", minval=2, maxval=200, group=g_risk, tooltip="Stop below the lowest low (long) or above the highest high (short) of this many candles, the signal candle included.")
float i_minAtr  = input.float(0.25, "Minimum stop distance (x ATR 14)", minval=0.0, maxval=5.0, step=0.05, group=g_risk, tooltip="A stop is never placed closer to the entry than this. That distance is 1R.")
int   i_wait    = input.int(5, "Wait for the ZLSMA close: max candles", minval=1, maxval=50, group=g_risk)
int   i_ledgerN = input.int(100, "Log size (last N trades per log)", minval=10, maxval=500, group=g_risk)
int   i_until   = input.time(timestamp("2100-01-01T00:00:00"), "Test ends at", group=g_risk, tooltip="No trade opens or closes after this moment: the logs, the table and the matrix stay exactly as they were then. A trade still open at that moment is not counted.")
bool  i_haFill  = input.bool(false, "Measure Heikin Ashi logs at Heikin Ashi prices", group=g_risk, tooltip="Off (default): logs with Heikin Ashi candles read their signals from Heikin Ashi values but are filled and measured at the real prices of the candle. On: entries, stops, targets and exits use the Heikin Ashi values, the way a backtest on a Heikin Ashi chart sees them. Those prices are averages, not prices you can trade.")

// ─── VERDICT MATRIX ────────────────────────────────────────────────────────────
string mS0 = input.symbol("BINANCE:BTCUSDT", "Market 1", group=g_mx, inline="m1")
string mN0 = input.string("Bitcoin", "", group=g_mx, inline="m1")
string mS1 = input.symbol("OANDA:NAS100USD", "Market 2", group=g_mx, inline="m2")
string mN1 = input.string("Nasdaq", "", group=g_mx, inline="m2")
string mS2 = input.symbol("OANDA:EURUSD", "Market 3", group=g_mx, inline="m3")
string mN2 = input.string("EUR/USD", "", group=g_mx, inline="m3")
string mS3 = input.symbol("OANDA:XAUUSD", "Market 4", group=g_mx, inline="m4")
string mN3 = input.string("Gold", "", group=g_mx, inline="m4")
string mT0 = input.timeframe("5", "Timeframes", group=g_mx, inline="t")
string mT1 = input.timeframe("15", "", group=g_mx, inline="t")
string mT2 = input.timeframe("30", "", group=g_mx, inline="t")
string mT3 = input.timeframe("60", "", group=g_mx, inline="t")

// ─── VISUAL ────────────────────────────────────────────────────────────────────
color i_bull  = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bear  = input.color(#FF3B5C, "Short colour", group=g_vis)
color i_zlCol = input.color(#FFD400, "ZLSMA colour", group=g_vis)
bool  i_showTrades = input.bool(true, "Draw trades on the chart", group=g_vis)
bool  i_showCE = input.bool(true, "Draw the Chandelier Exit and its Buy / Sell labels", group=g_vis)
int   i_keep  = input.int(80, "Trades kept on chart", minval=1, maxval=200, group=g_vis)
int   i_extend = input.int(25, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_vis)

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE
array<color> raceCols = array.from(#00E5A8, #FF3B5C, #FFB020, #3DA5FF, #C77DFF, #E8E8E8)

int showIdx = switch i_show
    "A" => 0
    "B" => 1
    "C" => 2
    "D" => 3
    "E" => 4
    => 5

// ─── REAL PRICES ───────────────────────────────────────────────────────────────
// On a Heikin Ashi chart TradingView feeds Heikin Ashi values to every script as open / high / low / close: a script that
// trusts them measures every trade at averaged prices nobody can trade. This one always reads the real candles.
bool haChart = chart.is_heikinashi
[stO, stH, stL, stC] = request.security(ticker.standard(syminfo.tickerid), timeframe.period, [open, high, low, close], lookahead=barmerge.lookahead_off)
float rO = haChart ? stO : open
float rH = haChart ? stH : high
float rL = haChart ? stL : low
float rC = haChart ? stC : close

// ─── THE INDICATORS ────────────────────────────────────────────────────────────
// Heikin Ashi from the chart's own candles (the same values as TradingView's Heikin Ashi chart type)
f_ha() =>
    float hc = (rO + rH + rL + rC) / 4
    float ho = na
    ho := na(ho[1]) ? (rO + rC) / 2 : (ho[1] + hc[1]) / 2
    [ho, math.max(rH, ho, hc), math.min(rL, ho, hc), hc]

// Chandelier Exit (everget) on any candle series -> [direction, long line, short line]
f_ce(float h, float l, float c, int len, float mult, bool useClose) =>
    float tr = na(c[1]) ? h - l : math.max(h - l, math.abs(h - c[1]), math.abs(l - c[1]))
    float atr = mult * ta.rma(tr, len)
    float hiC = ta.highest(c, len)
    float hiH = ta.highest(h, len)
    float loC = ta.lowest(c, len)
    float loL = ta.lowest(l, len)
    float longStop = (useClose ? hiC : hiH) - atr
    float longPrev = nz(longStop[1], longStop)
    longStop := c[1] > longPrev ? math.max(longStop, longPrev) : longStop
    float shortStop = (useClose ? loC : loL) + atr
    float shortPrev = nz(shortStop[1], shortStop)
    shortStop := c[1] < shortPrev ? math.min(shortStop, shortPrev) : shortStop
    var int dir = 1
    dir := c > shortPrev ? 1 : c < longPrev ? -1 : dir
    [dir, longStop, shortStop]

// ZLSMA (veryfid)
f_zl(float src, int len) =>
    float lsma = ta.linreg(src, len, 0)
    float lsma2 = ta.linreg(lsma, len, 0)
    lsma + (lsma - lsma2)

// ─── ONE LOG ───────────────────────────────────────────────────────────────────
// runs version v on the current context -> its signals, its trade events and its log statistics
f_book(int v, int raceFrom) =>
    int    len  = v == 0 ? l0 : v == 1 ? l1 : v == 2 ? l2 : v == 3 ? l3 : v == 4 ? l4 : l5
    float  mult = v == 0 ? m0 : v == 1 ? m1 : v == 2 ? m2 : v == 3 ? m3 : v == 4 ? m4 : m5
    bool   uc   = v == 0 ? u0 : v == 1 ? u1 : v == 2 ? u2 : v == 3 ? u3 : v == 4 ? u4 : u5
    int    zlen = v == 0 ? z0 : v == 1 ? z1 : v == 2 ? z2 : v == 3 ? z3 : v == 4 ? z4 : z5
    string cnd  = v == 0 ? c0 : v == 1 ? c1 : v == 2 ? c2 : v == 3 ? c3 : v == 4 ? c4 : c5
    string flt  = v == 0 ? f0 : v == 1 ? f1 : v == 2 ? f2 : v == 3 ? f3 : v == 4 ? f4 : f5
    string stp  = v == 0 ? s0 : v == 1 ? s1 : v == 2 ? s2 : v == 3 ? s3 : v == 4 ? s4 : s5
    string ext  = v == 0 ? x0 : v == 1 ? x1 : v == 2 ? x2 : v == 3 ? x3 : v == 4 ? x4 : x5
    float  rr   = v == 0 ? r0 : v == 1 ? r1 : v == 2 ? r2 : v == 3 ? r3 : v == 4 ? r4 : r5
    bool   lOnly = (v == 0 ? d0 : v == 1 ? d1 : v == 2 ? d2 : v == 3 ? d3 : v == 4 ? d4 : d5) == D_LONG
    [hO, hH, hL, hC] = f_ha()
    bool  ha = cnd == O_HA
    float sh = ha ? hH : rH
    float sl = ha ? hL : rL
    float sc = ha ? hC : rC
    [dir, lineL, lineS] = f_ce(sh, sl, sc, len, mult, uc)
    bool  haPx = ha and i_haFill
    float pH = haPx ? hH : rH
    float pL = haPx ? hL : rL
    float pC = haPx ? hC : rC
    float zl = f_zl(sc, zlen)
    bool buy  = dir == 1 and dir[1] == -1
    bool sell = dir == -1 and dir[1] == 1
    float atr14 = ta.rma(na(rC[1]) ? rH - rL : math.max(rH - rL, math.abs(rH - rC[1]), math.abs(rL - rC[1])), 14)
    float swLo = ta.lowest(pL, i_swing)
    float swHi = ta.highest(pH, i_swing)
    // the log
    var int   pos = 0
    var float entry = na
    var float stop = na
    var float target = na
    var float risk = na
    var int   obar = na
    var bool  half = false      // X_HALF: the first half was taken at the target
    var int   pend = 0          // F_WAIT: direction of a signal waiting for its ZLSMA close
    var int   pendBar = na
    var array<float> res = array.new<float>()
    var array<int>   tms = array.new<int>()
    var float race = 0.0
    float r = na
    float xPx = na
    int   opened = 0
    bool  ok = barstate.isconfirmed and time <= i_until and not na(zl) and not na(atr14) and not na(swLo)
    if ok
        // 1) settle the open trade on this candle
        if pos != 0 and bar_index > obar
            bool stopHit = pos == 1 ? pL <= stop : pH >= stop
            bool tgtHit = pos == 1 ? pH >= target : pL <= target
            bool oppSig = (pos == 1 and sell) or (pos == -1 and buy)
            bool zlBack = pos == 1 ? sc < zl : sc > zl
            if stopHit
                xPx := stop
            else if ext == X_HALF
                if not half and tgtHit
                    half := true
                if half and zlBack
                    xPx := pC
            else if (ext == X_TGT or ext == X_BOTH) and tgtHit
                xPx := target
            else if (ext == X_OPP or ext == X_BOTH) and oppSig
                xPx := pC
            else if ext == X_ZL and zlBack
                xPx := pC
            else if ext == X_ZLP and ((zlBack and pos * (pC - entry) > 0) or oppSig)
                xPx := pC
            if not na(xPx)
                float rRaw = pos * (xPx - entry) / risk
                r := math.round(ext == X_HALF and half ? 0.5 * rr + 0.5 * rRaw : rRaw, 2)
                array.push(res, r)
                array.push(tms, time)
                while array.size(res) > i_ledgerN
                    array.shift(res)
                    array.shift(tms)
                if time >= raceFrom
                    race += r
                pos := 0
                half := false
        // 2) the entry signal
        int want = 0
        if flt == F_NONE
            want := buy ? 1 : sell ? -1 : 0
        else if flt == F_CL
            want := buy and sc > zl ? 1 : sell and sc < zl ? -1 : 0
        else if flt == F_SLOPE
            want := buy and zl > zl[1] ? 1 : sell and zl < zl[1] ? -1 : 0
        else if flt == F_CROSS
            // a candle crossing the line in the trade's direction (green up through it, red down through it); a signal that
            // prints while the price is already on the far side is ignored
            bool upX = sc > zl and sc[1] <= zl[1] and sc > (ha ? hO : rO)
            bool dnX = sc < zl and sc[1] >= zl[1] and sc < (ha ? hO : rO)
            if buy
                pend := upX ? 0 : sc < zl ? 1 : 0
                pendBar := bar_index
                want := upX ? 1 : 0
            else if sell
                pend := dnX ? 0 : sc > zl ? -1 : 0
                pendBar := bar_index
                want := dnX ? -1 : 0
            else if pend != 0
                if dir != pend or bar_index - pendBar > i_wait
                    pend := 0
                else if pend == 1 and upX
                    want := 1
                    pend := 0
                else if pend == -1 and dnX
                    want := -1
                    pend := 0
        else
            if buy
                pend := 1
                pendBar := bar_index
            else if sell
                pend := -1
                pendBar := bar_index
            if pend != 0 and (dir != pend or bar_index - pendBar >= i_wait)
                pend := 0
            if pend == 1 and sc > zl
                want := 1
                pend := 0
            else if pend == -1 and sc < zl
                want := -1
                pend := 0
        if lOnly and want == -1
            want := 0
        // 3) open (one trade at a time)
        if want != 0 and pos == 0
            float minD = math.max(atr14 * i_minAtr, syminfo.mintick * 5)
            float lvl = stp == S_CE ? (want == 1 ? lineL : lineS) : stp == S_ZL ? zl : (want == 1 ? swLo : swHi)
            float s = want == 1 ? math.min(lvl, pC - minD) : math.max(lvl, pC + minD)
            pos := want
            entry := pC
            stop := s
            risk := math.abs(pC - s)
            target := pC + want * risk * rr
            obar := bar_index
            opened := want
    // statistics of the last N trades
    int n = array.size(res)
    int w = 0
    float tot = 0.0
    if n > 0
        for j = 0 to n - 1
            float q = array.get(res, j)
            tot += q
            if q > 0
                w += 1
    [opened, entry, stop, ext == X_OPP or ext == X_ZL ? float(na) : target, r, xPx, tot, n, w, race, dir, dir == 1 ? lineL : lineS, zl, buy, sell]

// matrix cell: version v on another market / timeframe -> [total R, trades, wins]
f_cell(int v) =>
    [o_, e_, s_, t_, r_, x_, tot, n, w, rc_, d_, ln_, z_, b_, sl_] = f_book(v, 0)
    [tot, n, w]

// ─── THE SIX LOGS ON THIS CHART ────────────────────────────────────────────────
[op0, en0, st0, tg0, rs0, xp0, tt0, nn0, ww0, rc0, dr0, ln0, zl0, by0, se0] = f_book(0, i_raceFrom)
[op1, en1, st1, tg1, rs1, xp1, tt1, nn1, ww1, rc1, dr1, ln1, zl1, by1, se1] = f_book(1, i_raceFrom)
[op2, en2, st2, tg2, rs2, xp2, tt2, nn2, ww2, rc2, dr2, ln2, zl2, by2, se2] = f_book(2, i_raceFrom)
[op3, en3, st3, tg3, rs3, xp3, tt3, nn3, ww3, rc3, dr3, ln3, zl3, by3, se3] = f_book(3, i_raceFrom)
[op4, en4, st4, tg4, rs4, xp4, tt4, nn4, ww4, rc4, dr4, ln4, zl4, by4, se4] = f_book(4, i_raceFrom)
[op5, en5, st5, tg5, rs5, xp5, tt5, nn5, ww5, rc5, dr5, ln5, zl5, by5, se5] = f_book(5, i_raceFrom)

array<string> names = array.from(n0, n1, n2, n3, n4, n5)
array<string> letters = array.from("A", "B", "C", "D", "E", "F")
array<float>  tots  = array.from(tt0, tt1, tt2, tt3, tt4, tt5)
array<int>    cnts  = array.from(nn0, nn1, nn2, nn3, nn4, nn5)
array<int>    wins  = array.from(ww0, ww1, ww2, ww3, ww4, ww5)
array<float>  races = array.from(rc0, rc1, rc2, rc3, rc4, rc5)

// the drawn log's values on this candle
int   sOp = showIdx == 0 ? op0 : showIdx == 1 ? op1 : showIdx == 2 ? op2 : showIdx == 3 ? op3 : showIdx == 4 ? op4 : op5
float sEn = showIdx == 0 ? en0 : showIdx == 1 ? en1 : showIdx == 2 ? en2 : showIdx == 3 ? en3 : showIdx == 4 ? en4 : en5
float sSt = showIdx == 0 ? st0 : showIdx == 1 ? st1 : showIdx == 2 ? st2 : showIdx == 3 ? st3 : showIdx == 4 ? st4 : st5
float sTg = showIdx == 0 ? tg0 : showIdx == 1 ? tg1 : showIdx == 2 ? tg2 : showIdx == 3 ? tg3 : showIdx == 4 ? tg4 : tg5
float sRs = showIdx == 0 ? rs0 : showIdx == 1 ? rs1 : showIdx == 2 ? rs2 : showIdx == 3 ? rs3 : showIdx == 4 ? rs4 : rs5
float sXp = showIdx == 0 ? xp0 : showIdx == 1 ? xp1 : showIdx == 2 ? xp2 : showIdx == 3 ? xp3 : showIdx == 4 ? xp4 : xp5
int   sDr = showIdx == 0 ? dr0 : showIdx == 1 ? dr1 : showIdx == 2 ? dr2 : showIdx == 3 ? dr3 : showIdx == 4 ? dr4 : dr5
float sLn = showIdx == 0 ? ln0 : showIdx == 1 ? ln1 : showIdx == 2 ? ln2 : showIdx == 3 ? ln3 : showIdx == 4 ? ln4 : ln5
float sZl = showIdx == 0 ? zl0 : showIdx == 1 ? zl1 : showIdx == 2 ? zl2 : showIdx == 3 ? zl3 : showIdx == 4 ? zl4 : zl5
bool  sBy = showIdx == 0 ? by0 : showIdx == 1 ? by1 : showIdx == 2 ? by2 : showIdx == 3 ? by3 : showIdx == 4 ? by4 : by5
bool  sSe = showIdx == 0 ? se0 : showIdx == 1 ? se1 : showIdx == 2 ? se2 : showIdx == 3 ? se3 : showIdx == 4 ? se4 : se5

// ─── ON THE PRICE CHART ────────────────────────────────────────────────────────
plot(i_showCE and sDr == 1 ? sLn : na, "Chandelier long line", color=i_bull, linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(i_showCE and sDr == -1 ? sLn : na, "Chandelier short line", color=i_bear, linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(sZl, "ZLSMA", color=i_zlCol, linewidth=3, force_overlay=true)
plotshape(i_showCE and sBy ? sLn : na, "Buy", shape.labelup, location.absolute, i_bull, text="Buy", textcolor=c_dark, size=size.small, force_overlay=true)
plotshape(i_showCE and sSe ? sLn : na, "Sell", shape.labeldown, location.absolute, i_bear, text="Sell", textcolor=c_white, size=size.small, force_overlay=true)

var box dRisk = na
var box dTarget = na
var array<box>   dBoxes = array.new<box>()
var array<label> dLabels = array.new<label>()
f_trim() =>
    while array.size(dBoxes) > i_keep * 2
        box.delete(array.shift(dBoxes))
    while array.size(dLabels) > i_keep * 2
        label.delete(array.shift(dLabels))

if i_showTrades and not na(sRs)
    bool win = sRs > 0
    if not na(dRisk)
        box.set_right(dRisk, bar_index)
    if not na(dTarget)
        box.set_right(dTarget, bar_index)
    array.push(dLabels, label.new(bar_index, sXp, (win ? "+" : "") + str.tostring(sRs, "#.#") + "R", color=win ? i_bull : sRs == 0 ? c_grey : i_bear, textcolor=win ? c_dark : c_white, style=win ? label.style_label_down : label.style_label_up, size=size.normal, force_overlay=true))
    dRisk := na
    dTarget := na
    f_trim()
if i_showTrades and sOp != 0
    dRisk := box.new(bar_index, math.max(sEn, sSt), bar_index + i_extend, math.min(sEn, sSt), bgcolor=color.new(i_bear, 80), border_color=color.new(i_bear, 40), force_overlay=true)
    array.push(dBoxes, dRisk)
    if not na(sTg)
        dTarget := box.new(bar_index, math.max(sEn, sTg), bar_index + i_extend, math.min(sEn, sTg), bgcolor=color.new(i_bull, 80), border_color=color.new(i_bull, 35), force_overlay=true)
        array.push(dBoxes, dTarget)
    string tip = (sOp == 1 ? "LONG" : "SHORT") + " · " + array.get(letters, showIdx) + " " + array.get(names, showIdx) + "\nEntry " + str.tostring(sEn, format.mintick) + "\nStop " + str.tostring(sSt, format.mintick) + (na(sTg) ? "\nExit: the opposite Chandelier signal" : "\nTarget " + str.tostring(sTg, format.mintick))
    array.push(dLabels, label.new(bar_index, sSt, sOp == 1 ? "LONG" : "SHORT", color=color.new(sOp == 1 ? i_bull : i_bear, 15), textcolor=sOp == 1 ? c_dark : c_white, style=sOp == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip, force_overlay=true))
    f_trim()
if not na(dRisk)
    box.set_right(dRisk, bar_index + i_extend)
if not na(dTarget)
    box.set_right(dTarget, bar_index + i_extend)

// ─── THE PANE: EQUITY RACE ─────────────────────────────────────────────────────
bool inRace = time >= i_raceFrom
plot(inRace ? rc0 : na, "Race A", color=array.get(raceCols, 0), linewidth=showIdx == 0 ? 4 : 2)
plot(inRace ? rc1 : na, "Race B", color=array.get(raceCols, 1), linewidth=showIdx == 1 ? 4 : 2)
plot(inRace ? rc2 : na, "Race C", color=array.get(raceCols, 2), linewidth=showIdx == 2 ? 4 : 2)
plot(inRace ? rc3 : na, "Race D", color=array.get(raceCols, 3), linewidth=showIdx == 3 ? 4 : 2)
plot(inRace ? rc4 : na, "Race E", color=array.get(raceCols, 4), linewidth=showIdx == 4 ? 4 : 2)
plot(inRace ? rc5 : na, "Race F", color=array.get(raceCols, 5), linewidth=showIdx == 5 ? 4 : 2)
hline(0, "Zero", color=color.new(c_grey, 50), linestyle=hline.style_dashed)

f_r(float v) =>
    na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.#") + "R"
f_pos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Center" => position.middle_center
        => position.top_right
string tS = i_size == "Huge" ? size.large : i_size == "Large" ? size.normal : i_size == "Small" ? size.tiny : size.small
string tH = i_size == "Huge" ? size.huge : i_size == "Large" ? size.large : i_size == "Small" ? size.small : size.normal

// race end labels and the leaderboard (in the pane)
var array<label> raceLabels = array.new<label>()
if barstate.islast
    while array.size(raceLabels) > 0
        label.delete(array.pop(raceLabels))
    if inRace
        for i = 0 to 5
            array.push(raceLabels, label.new(bar_index + 2, array.get(races, i), array.get(letters, i) + " " + f_r(array.get(races, i)), style=label.style_label_left, color=color.new(array.get(raceCols, i), 10), textcolor=c_dark, size=size.normal))
    if i_rank
        var table board = table.new(position.top_left, 3, 8, bgcolor=color.new(c_dark, 6), frame_color=color.new(c_purple, 20), frame_width=2, border_color=color.new(c_purple, 60), border_width=1)
        table.cell(board, 0, 0, "LEADERBOARD", text_color=c_white, text_size=tH, bgcolor=color.new(c_purple, 65), text_halign=text.align_left)
        table.merge_cells(board, 0, 0, 2, 0)
        array<int> order = array.from(0, 1, 2, 3, 4, 5)
        for a = 0 to 4
            for b = 0 to 4 - a
                if array.get(races, array.get(order, b)) < array.get(races, array.get(order, b + 1))
                    int tmp = array.get(order, b)
                    array.set(order, b, array.get(order, b + 1))
                    array.set(order, b + 1, tmp)
        for k = 0 to 5
            int i = array.get(order, k)
            table.cell(board, 0, k + 1, str.tostring(k + 1), text_color=c_grey, text_size=tS)
            table.cell(board, 1, k + 1, array.get(letters, i) + " " + array.get(names, i), text_color=array.get(raceCols, i), text_size=tS, text_halign=text.align_left)
            table.cell(board, 2, k + 1, f_r(array.get(races, i)), text_color=array.get(races, i) >= 0 ? i_bull : i_bear, text_size=tS)

// ─── THE TABLE ON THE PRICE CHART ──────────────────────────────────────────────
if barstate.islast and i_board == "Log table"
    var table led = table.new(f_pos(i_pos), 5, 8, bgcolor=color.new(c_dark, 6), border_color=color.new(c_purple, 55), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2, force_overlay=true)
    table.cell(led, 0, 0, "CHANDELIER VERDICT LAB · last " + str.tostring(i_ledgerN) + " trades", text_color=c_white, text_size=tH, text_halign=text.align_left, bgcolor=color.new(c_purple, 65))
    table.merge_cells(led, 0, 0, 4, 0)
    table.cell(led, 0, 1, "Version", text_color=c_grey, text_size=tS, text_halign=text.align_left)
    table.cell(led, 1, 1, "Trades", text_color=c_grey, text_size=tS)
    table.cell(led, 2, 1, "Wins", text_color=c_grey, text_size=tS)
    table.cell(led, 3, 1, "Won", text_color=c_grey, text_size=tS)
    table.cell(led, 4, 1, "Total", text_color=c_grey, text_size=tS)
    for i = 0 to 5
        int n = array.get(cnts, i)
        int w = array.get(wins, i)
        float t = array.get(tots, i)
        color rowBg = i == showIdx ? color.new(c_purple, 78) : na
        table.cell(led, 0, 2 + i, array.get(letters, i) + "  " + array.get(names, i), text_color=c_white, text_size=tS, text_halign=text.align_left, bgcolor=rowBg)
        table.cell(led, 1, 2 + i, str.tostring(n), text_color=c_white, text_size=tS, bgcolor=rowBg)
        table.cell(led, 2, 2 + i, str.tostring(w), text_color=i_bull, text_size=tS, bgcolor=rowBg)
        table.cell(led, 3, 2 + i, n > 0 ? str.tostring(100.0 * w / n, "#") + " %" : "-", text_color=c_white, text_size=tS, bgcolor=rowBg)
        table.cell(led, 4, 2 + i, f_r(t), text_color=t >= 0 ? i_bull : i_bear, text_size=tS, bgcolor=rowBg)

// ─── THE VERDICT MATRIX (the drawn log on 4 markets x 4 timeframes) ────────────
bool mxOn = i_board == "Verdict matrix"
// the 16 requests run only while the matrix is shown (on a 4-hour chart the lower timeframes timed out, 9 Oct)
float a00 = na
float a01 = na
float a02 = na
float a03 = na
float a10 = na
float a11 = na
float a12 = na
float a13 = na
float a20 = na
float a21 = na
float a22 = na
float a23 = na
float a30 = na
float a31 = na
float a32 = na
float a33 = na
if mxOn
    [t_a00, n_a00, w_a00] = request.security(mS0, mT0, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a00 := t_a00
if mxOn
    [t_a01, n_a01, w_a01] = request.security(mS0, mT1, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a01 := t_a01
if mxOn
    [t_a02, n_a02, w_a02] = request.security(mS0, mT2, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a02 := t_a02
if mxOn
    [t_a03, n_a03, w_a03] = request.security(mS0, mT3, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a03 := t_a03
if mxOn
    [t_a10, n_a10, w_a10] = request.security(mS1, mT0, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a10 := t_a10
if mxOn
    [t_a11, n_a11, w_a11] = request.security(mS1, mT1, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a11 := t_a11
if mxOn
    [t_a12, n_a12, w_a12] = request.security(mS1, mT2, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a12 := t_a12
if mxOn
    [t_a13, n_a13, w_a13] = request.security(mS1, mT3, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a13 := t_a13
if mxOn
    [t_a20, n_a20, w_a20] = request.security(mS2, mT0, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a20 := t_a20
if mxOn
    [t_a21, n_a21, w_a21] = request.security(mS2, mT1, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a21 := t_a21
if mxOn
    [t_a22, n_a22, w_a22] = request.security(mS2, mT2, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a22 := t_a22
if mxOn
    [t_a23, n_a23, w_a23] = request.security(mS2, mT3, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a23 := t_a23
if mxOn
    [t_a30, n_a30, w_a30] = request.security(mS3, mT0, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a30 := t_a30
if mxOn
    [t_a31, n_a31, w_a31] = request.security(mS3, mT1, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a31 := t_a31
if mxOn
    [t_a32, n_a32, w_a32] = request.security(mS3, mT2, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a32 := t_a32
if mxOn
    [t_a33, n_a33, w_a33] = request.security(mS3, mT3, f_cell(showIdx), lookahead=barmerge.lookahead_off)
    a33 := t_a33

f_tfName(string tf) =>
    tf == "60" ? "1 hour" : tf == "240" ? "4 hours" : tf == "D" or tf == "1D" ? "Daily" : tf + " min"
f_heat(float t) =>
    na(t) ? color.new(c_grey, 85) : t >= 0 ? color.new(i_bull, t >= 20 ? 20 : t >= 5 ? 45 : 65) : color.new(i_bear, t <= -20 ? 20 : t <= -5 ? 45 : 65)

if barstate.islast and mxOn
    var table mx = table.new(f_pos(i_pos), 5, 6, bgcolor=color.new(c_dark, 4), border_color=c_dark, border_width=3, frame_color=color.new(c_purple, 15), frame_width=2, force_overlay=true)
    table.cell(mx, 0, 0, array.get(letters, showIdx) + "  " + array.get(names, showIdx) + " · total R, last " + str.tostring(i_ledgerN) + " trades", text_color=c_white, text_size=tH, text_halign=text.align_left, bgcolor=color.new(c_purple, 65))
    table.merge_cells(mx, 0, 0, 4, 0)
    array<string> tfs = array.from(mT0, mT1, mT2, mT3)
    array<string> mks = array.from(mN0, mN1, mN2, mN3)
    array<float>  vals = array.from(a00, a01, a02, a03, a10, a11, a12, a13, a20, a21, a22, a23, a30, a31, a32, a33)
    for c = 0 to 3
        table.cell(mx, c + 1, 1, f_tfName(array.get(tfs, c)), text_color=c_grey, text_size=tS)
    for m = 0 to 3
        table.cell(mx, 0, m + 2, array.get(mks, m), text_color=c_white, text_size=tS, text_halign=text.align_left)
        for c = 0 to 3
            float t = array.get(vals, m * 4 + c)
            table.cell(mx, c + 1, m + 2, f_r(t), text_color=c_white, text_size=tH, bgcolor=f_heat(t), width=8, height=7)

// ─── DATA WINDOW (read by tools, hidden) ───────────────────────────────────────
plot(op0, "op0", display=display.data_window)
plot(op1, "op1", display=display.data_window)
plot(op2, "op2", display=display.data_window)
plot(op3, "op3", display=display.data_window)
plot(op4, "op4", display=display.data_window)
plot(op5, "op5", display=display.data_window)
plot(rs0, "rs0", display=display.data_window)
plot(rs1, "rs1", display=display.data_window)
plot(rs2, "rs2", display=display.data_window)
plot(rs3, "rs3", display=display.data_window)
plot(rs4, "rs4", display=display.data_window)
plot(rs5, "rs5", display=display.data_window)
plot(tt0, "tt0", display=display.data_window)
plot(tt1, "tt1", display=display.data_window)
plot(tt2, "tt2", display=display.data_window)
plot(tt3, "tt3", display=display.data_window)
plot(tt4, "tt4", display=display.data_window)
plot(tt5, "tt5", display=display.data_window)
plot(dr0, "dr0", display=display.data_window)
plot(dr1, "dr1", display=display.data_window)
plot(dr5, "dr5", display=display.data_window)
plot(zl0, "zl0", display=display.data_window)
plot(zl1, "zl1", display=display.data_window)
plot(st0, "st0", display=display.data_window)
plot(st1, "st1", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(sOp == 1, "CVL Long entry", "Chandelier Verdict Lab: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(sOp == -1, "CVL Short entry", "Chandelier Verdict Lab: SHORT on {{ticker}} {{interval}} at {{close}}")
````
