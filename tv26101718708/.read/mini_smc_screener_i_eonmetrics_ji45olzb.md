# Mini SMC Screener I EonMetrics 

- url: https://www.tradingview.com/script/JI45oLzb-Mini-SMC-Screener-I-EonMetrics/
- type: indicator
- pine_id: PUB;c312e3d0bdb1446b9f327a421c43e61d
- version: 1.0

## Description

Mini SMC Screener

Mini SMC Screener watches up to 5 symbols at once and answers a question no single-chart indicator can: WHERE is something happening right now. Instead of flipping through charts, you read one small table: market structure direction and the freshest Fair Value Gap event for every symbol on your list.

https://www.tradingview.com/x/N1DsjVXu/

[b]HOW IT WORKS[/b]

The script scans each symbol on the timeframe you choose (empty = chart timeframe) and reports two independent readings per symbol.

🔵Structure — a strict MSS/BOS engine. Swing points are confirmed pivots (a candle with N higher/lower candles on both sides). A close above the last confirmed swing high in a downtrend is a Market Structure Shift to bullish; a close below the protected swing low in an uptrend shifts structure bearish. Between shifts, breaks of structure in trend direction keep updating the protected level. The column shows the current state: ▲ Bull or ▼ Bear.

🔵FVG — a three-candle imbalance tracker. A Fair Value Gap forms when the first and third candle of a three-candle sequence do not overlap (the low of the newest candle stays above the high of the candle two bars back, or the mirror for bearish). The gap between them is unfilled territory. The engine registers a gap only when its height clears an ATR-based minimum size, keeps it active until price trades through its far edge (a full fill), and reports the freshest of two events:
- New — a qualifying gap just formed (displacement is happening now)
- Retest — price traded back INTO a still-open gap (the return many traders wait for)

Each event ages out of the table after a configurable number of bars, so the column only ever shows fresh information — an FVG event from 200 bars ago is not a setup and is not displayed.

Why the two are combined in one script: they answer the two halves of the same scanning question. Structure tells you the directional context of a symbol; the FVG event tells you that something tradeable is happening there right now. One without the other is either context with no trigger, or a trigger with no context — a scanner needs both on one row to be useful.

https://www.tradingview.com/x/0PemAULZ/

[b]KEY FEATURES[/b]

- 5 symbol slots, each with its own on/off toggle — defaults cover crypto, forex, gold and an index; replace them with your own watchlist
- Structure column: live Bullish / Bearish read from confirmed swing pivots (non-repainting state machine — the state changes only on a confirmed close through a level)
- FVG column: New / Retest events with age in bars ("now", "3b", …); the cell background lights up when the event happened on the current bar
- ATR size filter — noise-sized gaps never make it into the table
- Freshness windows for FVG events, so stale signals disappear on their own
- Alerts: per-symbol alert() messages (structure flips, new FVG, FVG retest) plus two named conditions — "Structure flip (any symbol)" and "FVG event (any symbol)"
- Scan timeframe input — scan a higher timeframe than your chart; a warning shows if you accidentally scan below the chart timeframe (unreliable by design on TradingView)
- Table position and text size inputs

[b]HOW TO USE[/b]

1. Add the indicator to any chart and open Settings → Symbols. Replace the default tickers with the instruments you actually follow.
2. Pick a Scan Timeframe — the chart timeframe or higher. A common setup: chart on M15, scan on M15 or H1.
3. Read rows left to right: Structure gives you the direction bias, FVG tells you whether a fresh imbalance or a retest is in play on that symbol.
4. The combination many traders look for: structure and a fresh FVG event pointing the SAME way — e.g. ▲ Bull structure plus a bullish FVG retest.
5. Set an alert with "Any alert() function call" to get the detailed per-symbol messages without watching the table.

[b]SETTINGS[/b]

- Scan: scan timeframe
- Symbols: 5 slots with toggles
- Structure: pivot strength (candles each side to confirm a swing)
- Fair Value Gaps: minimum gap size (× ATR), event freshness (bars)
- Alerts: master toggle
- Table: position, text size, bullish/bearish colors

A note on how the scan works under the hood: each symbol is evaluated in its own sandboxed context via request.security — the full engine state (structure machine, active gap list) is kept separately per symbol, and signals commit on bar close. Disabled slots still consume their data request (a TradingView compile-time requirement); the toggle hides the row.

This tool reports structure state and imbalance events. It does not generate buy/sell signals, targets or stop levels — what you do with a reading is your decision.  It is not financial advice; always do your own analysis and manage your own risk.

Part of the EonMetrics toolset.

## Source Code

````pine
//@version=6
indicator('EonMetrics Mini SMC Screener', 'Mini SMC Screener by EonMetrics', overlay=true, max_bars_back=500)

// Mini SMC Screener by EonMetrics — multi-symbol structure & FVG scanner (open-source).
//
// Watches up to 5 symbols at once and reports per symbol:
//   • Structure — Bullish / Bearish trend read (strict MSS/BOS engine)
//   • FVG       — the freshest Fair Value Gap event: a NEW gap just formed
//                 (displacement) or a RETEST (price trading back into a still-open gap)
//
// ARCHITECTURE — request.security() budget (hard TradingView limits):
//   • max 40 unique request.*() calls per script          → this script uses 5 (one per symbol slot)
//   • max 127 tuple elements across ALL request.*() calls → this script uses 5 × 3 = 15
//   Each request evaluates the whole ENGINE block below inside that symbol's own sandboxed
//   context (a per-context copy of every var/array state). The engines are deliberately
//   drawing-free: drawings cannot be created inside a security context, so every signal is
//   compressed into one float per column (sign = direction, magnitude = payload).
//   No barstate.* is used inside the engines — intrabar rollback gives clean live values and
//   state commits only on bar close.
//   NOTE: disabled symbol slots still consume their data request (calls must exist at compile
//   time) — the toggle hides the row, it does not speed up loading.
//
// ENCODINGS returned per symbol (decoded chart-side):
//   r_trend  -1 / 0 / +1                        structure direction
//   r_fvg    0 no fresh event · sign: + bullish / − bearish
//            magnitude: bars-since-event + 1, plus 1000 when the event is a RETEST
//            (magnitude 1 / 1001 = the event happened on the current bar)
//   close    last price of the scanned symbol

// ═════════════════════════════════════════════════════════════════════════════
//  SCAN SETTINGS
// ═════════════════════════════════════════════════════════════════════════════
grpScan = 'Scan'

scanTf = input.timeframe('', 'Scan Timeframe',
  group   = grpScan,
  tooltip = 'Timeframe every symbol is scanned on. Empty = the chart timeframe. Use the chart timeframe or a HIGHER one — scanning a timeframe lower than the chart is unreliable (TradingView returns only the last intrabar value of each chart bar). A warning shows in the table title when this happens.')

// ═════════════════════════════════════════════════════════════════════════════
//  SYMBOLS  (5 slots — toggle + ticker; disabled slots are hidden, not skipped)
// ═════════════════════════════════════════════════════════════════════════════
grpSym = 'Symbols'

en01 = input.bool(true, '', inline='s01', group=grpSym)
sy01 = input.symbol('BINANCE:BTCUSDT',  '1', inline='s01', group=grpSym)
en02 = input.bool(true, '', inline='s02', group=grpSym)
sy02 = input.symbol('BINANCE:ETHUSDT',  '2', inline='s02', group=grpSym)
en03 = input.bool(true, '', inline='s03', group=grpSym)
sy03 = input.symbol('OANDA:EURUSD',     '3', inline='s03', group=grpSym)
en04 = input.bool(true, '', inline='s04', group=grpSym)
sy04 = input.symbol('OANDA:XAUUSD',     '4', inline='s04', group=grpSym)
en05 = input.bool(true, '', inline='s05', group=grpSym)
sy05 = input.symbol('CAPITALCOM:US100', '5', inline='s05', group=grpSym)

// ═════════════════════════════════════════════════════════════════════════════
//  ENGINE SETTINGS
// ═════════════════════════════════════════════════════════════════════════════
grpStr = 'Structure (MSS/BOS engine)'

structLen = input.int(3, 'Pivot Strength', minval=1, maxval=20,
  group   = grpStr,
  tooltip = 'Candles left and right required to confirm a swing point (strict mode: the protected level follows the last low/high that produced a structural break). Higher = slower, more significant structure.')

grpFvg = 'Fair Value Gaps'

fvMinAtr = input.float(0.15, 'Min FVG Size (× ATR)', minval=0.0, step=0.05,
  group   = grpFvg,
  tooltip = 'A 3-candle gap only registers when its height is at least this many ATR(14) — filters out noise-sized imbalances. 0 = report every gap.')

fvgFresh = input.int(20, 'FVG Freshness (bars)', minval=1, maxval=500,
  group   = grpFvg,
  tooltip = 'How many bars an FVG event stays FRESH. The FVG column only reports events younger than this — an old gap event is stale information, not a setup.')

grpAl = 'Alerts'

alertsOn = input.bool(true, 'Enable Alerts',
  group   = grpAl,
  tooltip = 'Fires an alert() on bar close when any enabled symbol flips structure or prints an FVG event. In the Create Alert dialog choose "Any alert() function call" for the per-symbol messages, or pick one of the two named conditions for a generic ping.')

grpTbl = 'Table'

tablePosInp = input.string('Top Right', 'Position', options=['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Middle Right'],
  group=grpTbl, tooltip='Corner of the chart where the screener table is anchored.')

tableSize = input.string('Small', 'Text Size', options=['Tiny', 'Small', 'Normal'],
  group=grpTbl, tooltip='Font size of the table text.')

bullC = input.color(#089981, 'Bullish', inline='cols', group=grpTbl, tooltip='Colors used for bullish / bearish readings across all columns.')
bearC = input.color(#f23645, 'Bearish', inline='cols', group=grpTbl)

// ═════════════════════════════════════════════════════════════════════════════
//  DERIVED / CHART-SIDE HELPERS
// ═════════════════════════════════════════════════════════════════════════════
neutralC = color.new(#9598a1, 0)
headBg   = color.new(color.gray, 60)

tsize = tableSize == 'Tiny' ? size.tiny : tableSize == 'Normal' ? size.normal : size.small

tablePos = tablePosInp == 'Top Left' ? position.top_left : tablePosInp == 'Bottom Left' ? position.bottom_left : tablePosInp == 'Bottom Right' ? position.bottom_right : tablePosInp == 'Middle Right' ? position.middle_right : position.top_right

// Magnitude-based price formatting (the chart mintick belongs to the CHART symbol,
// not the scanned one, so decimals are chosen from the price scale instead).
f_px(float p) =>
    na(p) ? '—' : math.abs(p) >= 1000 ? str.tostring(p, '#,###.##') : math.abs(p) >= 10 ? str.tostring(p, '#.####') : str.tostring(p, '#.#####')

// '15' → '15m', '240' → '4H', '1D' stays '1D'
f_tfName(string tf) =>
    float mins = str.tonumber(tf)
    na(mins) ? tf : mins >= 60 and mins % 60 == 0 ? str.tostring(mins / 60, '#') + 'H' : str.tostring(mins, '#') + 'm'

// 'BINANCE:BTCUSDT' → 'BTCUSDT'
f_symName(string s) =>
    array<string> parts = str.split(s, ':')
    array.size(parts) > 1 ? array.get(parts, 1) : s

tfDisplay = f_tfName(scanTf == '' ? timeframe.period : scanTf)
tfWarn    = timeframe.in_seconds(scanTf == '' ? timeframe.period : scanTf) < timeframe.in_seconds(timeframe.period)

// ═════════════════════════════════════════════════════════════════════════════
//  ENGINES — run once per security context (per-symbol sandboxed state).
//  Global-scope code on purpose: request.security evaluates these mutable-state
//  globals inside each symbol's own context. Drawing-free by design.
// ═════════════════════════════════════════════════════════════════════════════
g_atr = ta.atr(14)

// ────────────────────────────────────────────────────────────────────────────
//  1. STRUCTURE — strict MSS/BOS engine.
//     trend: 1 = Bullish, -1 = Bearish, 0 = not initialized.
// ────────────────────────────────────────────────────────────────────────────
st_ph = ta.pivothigh(high, structLen, structLen)
st_pl = ta.pivotlow(low,  structLen, structLen)

var int   st_trend   = 0
var float st_mssHigh = na
var float st_mssLow  = na
var float st_bosTgtH = na
var float st_bosTgtL = na
var float st_lastPH  = na
var float st_lastPL  = na
var float st_absHH   = na
var float st_absLL   = na

if not na(st_ph)
    st_lastPH := st_ph
    if st_trend == 1
        st_bosTgtH := st_ph
if not na(st_pl)
    st_lastPL := st_pl
    if st_trend == -1
        st_bosTgtL := st_pl

if na(st_absHH) or high > st_absHH
    st_absHH := high
if na(st_absLL) or low < st_absLL
    st_absLL := low

// direction bootstrap on startup
if st_trend == 0
    if not na(st_ph)
        st_bosTgtH := st_ph
    if not na(st_pl)
        st_bosTgtL := st_pl
    if not na(st_bosTgtH) and close > st_bosTgtH
        st_trend  := 1
        st_mssLow := st_absLL
    else if not na(st_bosTgtL) and close < st_bosTgtL
        st_trend   := -1
        st_mssHigh := st_absHH

if st_trend == 1
    if not na(st_mssLow) and close < st_mssLow
        st_trend   := -1
        st_mssHigh := st_absHH
        st_mssLow  := na
        st_absLL   := low
        st_bosTgtL := na
    else if not na(st_bosTgtH) and close > st_bosTgtH
        st_mssLow  := not na(st_lastPL) ? st_lastPL : st_absLL
        st_bosTgtH := na
else if st_trend == -1
    if not na(st_mssHigh) and close > st_mssHigh
        st_trend   := 1
        st_mssLow  := st_absLL
        st_mssHigh := na
        st_absHH   := high
        st_bosTgtH := na
    else if not na(st_bosTgtL) and close < st_bosTgtL
        st_mssHigh := not na(st_lastPH) ? st_lastPH : st_absHH
        st_bosTgtL := na

// ────────────────────────────────────────────────────────────────────────────
//  2. FAIR VALUE GAPS — 3-candle imbalance tracker (drawing-free).
//     A gap registers when the outer candles do not overlap (bull: low > high[2],
//     bear: high < low[2]) and its height clears the ATR size filter. Gaps stay
//     active until FILLED (price trades through the far edge). Two reportable
//     events, most recent wins:
//       NEW    — a gap formed (displacement just happened)
//       RETEST — price traded back into a still-open gap (the tradeable return)
// ────────────────────────────────────────────────────────────────────────────
var array<float> fv_bullT   = array.new<float>()
var array<float> fv_bullB   = array.new<float>()
var array<int>   fv_bullBar = array.new<int>()
var array<float> fv_bearT   = array.new<float>()
var array<float> fv_bearB   = array.new<float>()
var array<int>   fv_bearBar = array.new<int>()

var int  fv_evBar = na     // bar of the most recent FVG event
var int  fv_evDir = 0      // 1 = bullish gap event · -1 = bearish gap event
var bool fv_evRt  = false  // true when the event is a retest (false = new gap)

// mitigation first — a fill through the far edge closes the gap
if array.size(fv_bullT) > 0
    for i = array.size(fv_bullT) - 1 to 0
        if low <= array.get(fv_bullB, i)
            array.remove(fv_bullT, i)
            array.remove(fv_bullB, i)
            array.remove(fv_bullBar, i)
if array.size(fv_bearT) > 0
    for i = array.size(fv_bearT) - 1 to 0
        if high >= array.get(fv_bearT, i)
            array.remove(fv_bearT, i)
            array.remove(fv_bearB, i)
            array.remove(fv_bearBar, i)

// retest — price back inside a surviving gap (skip the formation bar itself:
// at formation the candle's own extreme sits exactly on the gap edge)
if array.size(fv_bullT) > 0
    for i = 0 to array.size(fv_bullT) - 1
        if bar_index > array.get(fv_bullBar, i) and low <= array.get(fv_bullT, i)
            fv_evBar := bar_index
            fv_evDir := 1
            fv_evRt  := true
if array.size(fv_bearT) > 0
    for i = 0 to array.size(fv_bearT) - 1
        if bar_index > array.get(fv_bearBar, i) and high >= array.get(fv_bearB, i)
            fv_evBar := bar_index
            fv_evDir := -1
            fv_evRt  := true

// detection — a new gap this bar overrides a same-bar retest (freshest event wins)
fv_bullSz = low - high[2]
fv_bearSz = low[2] - high

if low > high[2] and not na(g_atr) and fv_bullSz >= g_atr * fvMinAtr
    array.push(fv_bullT, low)
    array.push(fv_bullB, high[2])
    array.push(fv_bullBar, bar_index)
    if array.size(fv_bullT) > 20
        array.shift(fv_bullT)
        array.shift(fv_bullB)
        array.shift(fv_bullBar)
    fv_evBar := bar_index
    fv_evDir := 1
    fv_evRt  := false

if high < low[2] and not na(g_atr) and fv_bearSz >= g_atr * fvMinAtr
    array.push(fv_bearT, low[2])
    array.push(fv_bearB, high)
    array.push(fv_bearBar, bar_index)
    if array.size(fv_bearT) > 20
        array.shift(fv_bearT)
        array.shift(fv_bearB)
        array.shift(fv_bearBar)
    fv_evBar := bar_index
    fv_evDir := -1
    fv_evRt  := false

// ────────────────────────────────────────────────────────────────────────────
//  RESULT ENCODING — one float per column (see header for the decode map)
// ────────────────────────────────────────────────────────────────────────────
float r_trend = st_trend

float r_fvg = 0.0
if not na(fv_evBar) and fv_evDir != 0
    int fv_since = bar_index - fv_evBar
    if fv_since <= fvgFresh
        r_fvg := fv_evDir * (fv_since + 1 + (fv_evRt ? 1000 : 0))

// ═════════════════════════════════════════════════════════════════════════════
//  MULTI-SYMBOL REQUESTS — 5 calls × 3-tuple = 15 of the 127-element budget.
//  ignore_invalid_symbol: a bad ticker returns na (shown as n/a) instead of a
//  runtime error. Empty slots fall back to the chart symbol.
// ═════════════════════════════════════════════════════════════════════════════
[t01, f01, p01] = request.security(sy01 == '' ? syminfo.tickerid : sy01, scanTf,
  [r_trend, r_fvg, close],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[t02, f02, p02] = request.security(sy02 == '' ? syminfo.tickerid : sy02, scanTf,
  [r_trend, r_fvg, close],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[t03, f03, p03] = request.security(sy03 == '' ? syminfo.tickerid : sy03, scanTf,
  [r_trend, r_fvg, close],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[t04, f04, p04] = request.security(sy04 == '' ? syminfo.tickerid : sy04, scanTf,
  [r_trend, r_fvg, close],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[t05, f05, p05] = request.security(sy05 == '' ? syminfo.tickerid : sy05, scanTf,
  [r_trend, r_fvg, close],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS (chart-side; fire on bar close)
// ═════════════════════════════════════════════════════════════════════════════
var string n01 = f_symName(sy01)
var string n02 = f_symName(sy02)
var string n03 = f_symName(sy03)
var string n04 = f_symName(sy04)
var string n05 = f_symName(sy05)

// Per-slot event detection + alert. Called unconditionally every bar (so the [1]
// history of its arguments stays consistent); fires on bar close only.
// Returns [structure-flipped, fvg-event] for the two named alert conditions.
f_alert(bool en, string nm, float t, float f) =>
    bool flip = not na(t) and not na(t[1]) and math.abs(t) > 0.5 and t != t[1]
    float fm  = math.abs(f)
    bool  rt  = fm >= 1000
    int   fB  = fm > 0.5 ? int(fm - (rt ? 1000 : 0) - 1) : 0
    bool  fEv = fm > 0.5 and fB == 0
    bool sFired = false
    bool fFired = false
    if en and barstate.isconfirmed and not na(t)
        if flip
            sFired := true
            if alertsOn
                alert('Mini SMC Screener · ' + nm + ' ' + tfDisplay + ' — structure flipped to ' + (t > 0.5 ? 'BULLISH' : 'BEARISH'), alert.freq_once_per_bar)
        if fEv
            fFired := true
            if alertsOn
                alert('Mini SMC Screener · ' + nm + ' ' + tfDisplay + ' — ' + (rt ? 'FVG retest' : 'new FVG') + ' (' + (f > 0 ? 'bullish' : 'bearish') + ')', alert.freq_once_per_bar)
    [sFired, fFired]

[s01, v01] = f_alert(en01, n01, t01, f01)
[s02, v02] = f_alert(en02, n02, t02, f02)
[s03, v03] = f_alert(en03, n03, t03, f03)
[s04, v04] = f_alert(en04, n04, t04, f04)
[s05, v05] = f_alert(en05, n05, t05, f05)

anyFlip = s01 or s02 or s03 or s04 or s05
anyFvg  = v01 or v02 or v03 or v04 or v05

alertcondition(anyFlip, title='Structure flip (any symbol)',
  message='Mini SMC Screener: a symbol flipped structure — open the chart and check the table.')
alertcondition(anyFvg, title='FVG event (any symbol)',
  message='Mini SMC Screener: a symbol printed an FVG event — open the chart and check the table.')

// ═════════════════════════════════════════════════════════════════════════════
//  TABLE — one row per enabled symbol, input order
// ═════════════════════════════════════════════════════════════════════════════
aN = array.new<string>()
aT = array.new<float>()
aF = array.new<float>()
aP = array.new<float>()

f_push(bool en, string nm, float t, float f, float p) =>
    if en
        array.push(aN, nm)
        array.push(aT, t)
        array.push(aF, f)
        array.push(aP, p)

f_push(en01, n01, t01, f01, p01)
f_push(en02, n02, t02, f02, p02)
f_push(en03, n03, t03, f03, p03)
f_push(en04, n04, t04, f04, p04)
f_push(en05, n05, t05, f05, p05)

var table tbl = table.new(tablePos, 4, 7, bgcolor=color.new(#111318, 8), border_color=color.new(color.gray, 65), border_width=1, frame_color=color.new(color.gray, 55), frame_width=1)

// merge the title row once (merging is persistent; repeating it every tick is unsafe)
var bool tblMerged = false
if barstate.islast and not tblMerged
    tblMerged := true
    table.merge_cells(tbl, 0, 0, 3, 0)

f_head(int col, string txt) =>
    table.cell(tbl, col, 1, txt, text_color=color.new(color.white, 15), bgcolor=headBg, text_size=tsize)

f_row(int row, int k) =>
    string nm = array.get(aN, k)
    float  t  = array.get(aT, k)
    float  f  = array.get(aF, k)
    float  p  = array.get(aP, k)
    bool   bad = na(t)

    table.cell(tbl, 0, row, nm, text_color=color.white, text_halign=text.align_left, text_size=tsize)
    table.cell(tbl, 1, row, bad ? 'n/a' : f_px(p), text_color=bad ? neutralC : color.white, text_halign=text.align_right, text_size=tsize)

    string sTxt = bad ? '—' : t > 0.5 ? '▲ Bull' : t < -0.5 ? '▼ Bear' : 'Neutral'
    color  sCol = bad ? neutralC : t > 0.5 ? bullC : t < -0.5 ? bearC : neutralC
    table.cell(tbl, 2, row, sTxt, text_color=sCol, text_size=tsize)

    float fm  = math.abs(f)
    bool  rt  = fm >= 1000
    int   fB  = fm > 0.5 ? int(fm - (rt ? 1000 : 0) - 1) : 0
    string fTxt = bad or fm < 0.5 ? '—' : (f > 0 ? '▲ ' : '▼ ') + (rt ? 'Retest' : 'New') + (fB == 0 ? ' · now' : ' · ' + str.tostring(fB) + 'b')
    color  fCol = bad or fm < 0.5 ? neutralC : f > 0 ? bullC : bearC
    color  fBg  = bad or fm < 0.5 ? na : fB == 0 ? color.new(f > 0 ? bullC : bearC, 55) : na
    table.cell(tbl, 3, row, fTxt, text_color=fCol, bgcolor=fBg, text_size=tsize)

if barstate.islast
    table.cell(tbl, 0, 0, 'MINI SMC SCREENER · ' + tfDisplay + (tfWarn ? '  ⚠ scan TF below chart TF' : ''),
      text_color=tfWarn ? color.orange : color.white, bgcolor=color.new(#111318, 0), text_size=tsize)
    f_head(0, 'Symbol')
    f_head(1, 'Price')
    f_head(2, 'Structure')
    f_head(3, 'FVG')

    int n = array.size(aN)
    if n == 0
        table.cell(tbl, 0, 2, 'No symbols enabled', text_color=neutralC, text_size=tsize)
    else
        for r = 0 to n - 1
            f_row(r + 2, r)
````
