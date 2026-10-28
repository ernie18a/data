# Multi-Timeframe Squeeze Board Lite

- url: https://www.tradingview.com/script/To9aCrxn-Multi-Timeframe-Squeeze-Board-Lite/
- type: indicator
- pine_id: PUB;0863496274414ff39ef043c613ea445a
- version: 1.0

## Description

[b]What it shows[/b]

Multi-Timeframe Squeeze Board — Lite answers one question at a glance: "Where is this symbol compressed, and which way is momentum leaning, on every timeframe that matters?" For the chart's symbol it displays a compact table with one row per timeframe — 15m, 1h, 4h, Daily, Weekly — and two readings per row:

- Sqz — the TTM Squeeze compression state as a colored dot, using the standard three-level cascade: orange = high squeeze (deepest compression), red = mid squeeze, black = low squeeze, green = no squeeze (volatility released / normal).
- Mom — the squeeze momentum oscillator as a colored arrow using the classic 4-color scheme: aqua = positive and rising, blue = positive but falling, yellow = negative but rising, red = negative and falling. The arrow points up when momentum is increasing bar-over-bar and down when it is decreasing.

A stacked squeeze (orange/red dots on several adjacent timeframes) marks a market coiling across horizons; the momentum colors tell you which side the pressure is building on.

[b]How it works[/b]

Each row runs the full TTM Squeeze calculation on its own timeframe via request.security() with lookahead = barmerge.lookahead_off (no future data, ever):

1. Bollinger Bands: SMA(close, 20) basis, 2.0 × population standard deviation.
2. Keltner Channels: the same SMA(close, 20) basis, with band width = SMA of True Range over 20 bars (simple average of TR — not Wilder's ATR) at three multipliers: 1.0, 1.5, 2.0.
3. A squeeze is on when the Bollinger Bands sit fully inside the Keltner Channel on both sides. The narrower the Keltner band that still contains the BB, the deeper the compression — hence the 1.0-multiplier band defines the high squeeze, 1.5 the mid, 2.0 the low.
4. Momentum is the linear regression of price's deviation from the average of the Donchian midline and the SMA, over the same 20 bars.

By default the board evaluates confirmed bars only: every row shows the last fully closed bar of its timeframe, so a dot or arrow never changes after it appears. See Limitations for the tradeoff.

[b]Inputs[/b]

- Squeeze length — lookback for BB, KC and momentum (default 20, the canonical TTM setting).
- Confirmed HTF bars only — ON (default): stable, non-repainting readings that lag up to one bar of each row's timeframe. OFF: rows track the still-forming higher-timeframe bar — more current, but the reading can flip until that bar closes.
- Table position / Table size — where the board sits and how large it renders.

[b]How to use it[/b]

Apply it to a 15m chart (or lower) so all five rows populate. Scan the Sqz column top-to-bottom: multiple orange/red dots stacked across timeframes indicate multi-horizon compression — historically the precondition for expansion moves. Then read the Mom column for directional lean while the compression resolves. The board is a context tool: it tells you where energy is stored, not when or in which direction it must release.

[b]Limitations — please read[/b]

- Confirmed-bar lag: with the default non-repainting mode, the Weekly row updates once per week, the Daily row once per day, etc. That is the honest cost of stability. Turning the toggle off shows the live forming bar instead, and those readings can change until the bar closes.
- Rows below the chart's timeframe show "–": Pine's request.security() cannot reliably reconstruct lower-timeframe series, so instead of showing a possibly wrong dot the board declines to show one. Use a 15m chart to see everything.
- A squeeze has no direction. Compression means stored energy, not a buy or sell signal. The momentum color is a lean, not a prediction.
- Warm-up: each timeframe needs about 20 bars of history before its row populates (shown as "·" until then).

This board covers one symbol — the chart's.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Multi-Timeframe Squeeze Board — Lite
//
// TTM Squeeze compression state + momentum for the chart's symbol across
// 15m / 1h / 4h / Daily / Weekly, rendered as one compact table.
//
// The squeeze math follows the Beardy Squeeze Pro formulation exactly:
//   - BB basis  = SMA(close, length); BB width = 2.0 * population stdev (ta.stdev)
//   - KC basis  = SMA(close, length); KC width = SMA(true range, length) * mult
//     (SMA of TR — NOT Wilder's/RMA ATR)
//   - KC multipliers: high = 1.0 (tightest band = deepest compression),
//     mid = 1.5, low = 2.0 (widest). The naming is intentionally counter-
//     intuitive: the HIGH squeeze uses the NARROWEST Keltner band.
//   - Squeeze requires BB inside KC on BOTH sides (AND logic), with the
//     priority cascade: high -> orange, mid -> red, low -> black, none -> green.
//   - Momentum = linreg(close - avg(avg(highest(high,L), lowest(low,L)),
//     sma(close,L)), L, 0); colors: aqua (>0 rising), blue (>0 falling),
//     yellow (<=0 rising), red (<=0 falling).
//
// REPAINT HANDLING — read before editing:
// Each row is fetched with request.security(..., lookahead = barmerge.lookahead_off),
// so nothing ever peeks into the future. The remaining tradeoff is the LIVE
// higher-timeframe bar: with "Confirmed HTF bars only" ON (default), every row
// shows the last fully CLOSED bar of its timeframe — values never flip after
// they appear, at the cost of lagging up to one bar of that timeframe. With it
// OFF, rows track the still-forming HTF bar — more current, but a squeeze dot
// or momentum arrow can change until that bar closes (live-bar repaint). The
// toggle is implemented by offsetting the expression INSIDE the security
// context ([1] on the realtime bar), which keeps historical and realtime
// behavior consistent.
//
// Rows for timeframes BELOW the chart's timeframe are shown as "–": Pine's
// request.security only exposes the last intrabar of lower timeframes, which
// is not reliable enough for a state board. View this on a 15m (or lower)
// chart to populate all five rows.
//
// This Lite board covers one symbol — the chart's.

//@version=6
indicator("Multi-Timeframe Squeeze Board — Lite", shorttitle = "MTF Squeeze Lite", overlay = true)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
length = input.int(20, "Squeeze length", minval = 5, maxval = 200,
     tooltip = "Lookback for Bollinger Bands, Keltner Channels and the momentum " +
     "linear regression. 20 is the canonical TTM Squeeze setting.")

useConfirmed = input.bool(true, "Confirmed HTF bars only (non-repainting)",
     tooltip = "ON: each row shows the last fully closed bar of its timeframe — " +
     "stable, never flips after it appears, lags up to one bar of that timeframe. " +
     "OFF: rows track the still-forming higher-timeframe bar — more current, but " +
     "the state can change until that bar closes.")

tablePosStr = input.string("Top right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right", "Middle left"])
tableSizeStr = input.string("Normal", "Table size", options = ["Tiny", "Small", "Normal", "Large"])

tablePos = tablePosStr == "Top right"    ? position.top_right    :
           tablePosStr == "Top left"     ? position.top_left     :
           tablePosStr == "Bottom right" ? position.bottom_right :
           tablePosStr == "Bottom left"  ? position.bottom_left  :
           tablePosStr == "Middle right" ? position.middle_right :
           position.middle_left

tableSize = tableSizeStr == "Tiny"  ? size.tiny  :
     tableSizeStr == "Small" ? size.small :
     tableSizeStr == "Large" ? size.large :
     size.normal

// ─────────────────────────────────────────────────────────────────────────────
// TTM Squeeze engine (Beardy Squeeze Pro math — see header comment)
// Returns a tuple evaluated in the request.security() timeframe context:
//   stateCode : 3 = high squeeze, 2 = mid, 1 = low, 0 = no squeeze
//   mom       : momentum oscillator value (na during warm-up)
//   momUp     : mom strictly rising  (mom >  mom[1])
//   momDown   : mom strictly falling (mom <  mom[1])
// ─────────────────────────────────────────────────────────────────────────────
f_squeeze() =>
    // Bollinger Bands — SMA basis, population stdev (ta.stdev), 2.0 mult
    float basis = ta.sma(close, length)
    float dev   = 2.0 * ta.stdev(close, length)
    float bbU   = basis + dev
    float bbL   = basis - dev

    // Keltner Channels — same SMA basis, SMA of True Range (NOT RMA ATR)
    float devKC = ta.sma(ta.tr, length)
    float kcUHigh = basis + devKC * 1.0
    float kcLHigh = basis - devKC * 1.0
    float kcUMid  = basis + devKC * 1.5
    float kcLMid  = basis - devKC * 1.5
    float kcULow  = basis + devKC * 2.0
    float kcLLow  = basis - devKC * 2.0

    // Squeeze conditions — BB inside KC on BOTH sides (AND logic),
    // priority cascade high > mid > low > none
    bool highSqz = bbL >= kcLHigh and bbU <= kcUHigh
    bool midSqz  = bbL >= kcLMid  and bbU <= kcUMid
    bool lowSqz  = bbL >= kcLLow  and bbU <= kcULow
    int state = highSqz ? 3 : midSqz ? 2 : lowSqz ? 1 : 0

    // Momentum oscillator
    float mom = ta.linreg(close - math.avg(math.avg(ta.highest(high, length),
         ta.lowest(low, length)), ta.sma(close, length)), length, 0)
    bool momUp   = mom > mom[1]
    bool momDown = mom < mom[1]

    // Confirmed-bar offset, applied INSIDE the HTF context: on the realtime
    // bar of the requested timeframe we step back one bar, matching the
    // naturally-delayed delivery of historical bars under lookahead_off.
    int off = useConfirmed and barstate.isrealtime ? 1 : 0
    [state[off], mom[off], momUp[off], momDown[off]]

// ─────────────────────────────────────────────────────────────────────────────
// Fetch all five timeframes (lookahead_off everywhere — no future data)
// ─────────────────────────────────────────────────────────────────────────────
[s15, m15, u15, d15] = request.security(syminfo.tickerid, "15",  f_squeeze(), lookahead = barmerge.lookahead_off)
[s60, m60, u60, d60] = request.security(syminfo.tickerid, "60",  f_squeeze(), lookahead = barmerge.lookahead_off)
[s4h, m4h, u4h, d4h] = request.security(syminfo.tickerid, "240", f_squeeze(), lookahead = barmerge.lookahead_off)
[sD,  mD,  uD,  dD ] = request.security(syminfo.tickerid, "D",   f_squeeze(), lookahead = barmerge.lookahead_off)
[sW,  mW,  uW,  dW ] = request.security(syminfo.tickerid, "W",   f_squeeze(), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// Rendering helpers
// ─────────────────────────────────────────────────────────────────────────────
color COL_HEADER_BG  = color.new(#0f172a, 0)   // navy
color COL_HEADER_TXT = color.new(#e2e8f0, 0)
color COL_CELL_BG    = color.new(#e2e8f0, 0)   // light cell so the BLACK low-squeeze dot stays visible
color COL_TF_BG      = color.new(#1e293b, 0)
color COL_NA         = color.new(color.gray, 0)

// Squeeze state cascade colors: high -> orange, mid -> red, low -> black, none -> green
f_stateColor(int s) =>
    s == 3 ? color.orange : s == 2 ? color.red : s == 1 ? color.black : color.green

// Momentum 4-color scheme (exact Beardy logic, including the flat-value edges:
// >0 & not-rising is BLUE; <=0 & not-falling is YELLOW)
f_momColor(float m, bool up, bool dn) =>
    m > 0 ? (up ? color.aqua : color.blue) : (dn ? color.red : color.yellow)

f_momArrow(float m, bool up, bool dn) =>
    m > 0 ? (up ? "▲" : "▼") : (dn ? "▼" : "▲")

// Rows for timeframes below the chart's timeframe are unreliable via
// request.security (last-intrabar sampling) — render them as "–" instead.
f_rowUsable(string tf) =>
    timeframe.in_seconds(tf) >= timeframe.in_seconds(timeframe.period)

f_drawRow(table tbl, int row, string label, string tf, int s, float m, bool up, bool dn) =>
    table.cell(tbl, 0, row, label, text_color = COL_HEADER_TXT, bgcolor = COL_TF_BG, text_size = tableSize)
    if not f_rowUsable(tf)
        // Chart TF is above this row's TF — honest "not available" marker
        table.cell(tbl, 1, row, "–", text_color = COL_NA, bgcolor = COL_CELL_BG, text_size = tableSize)
        table.cell(tbl, 2, row, "–", text_color = COL_NA, bgcolor = COL_CELL_BG, text_size = tableSize)
    else if na(m)
        // Warm-up: not enough bars on that timeframe yet
        table.cell(tbl, 1, row, "·", text_color = COL_NA, bgcolor = COL_CELL_BG, text_size = tableSize)
        table.cell(tbl, 2, row, "·", text_color = COL_NA, bgcolor = COL_CELL_BG, text_size = tableSize)
    else
        table.cell(tbl, 1, row, "●", text_color = f_stateColor(s), bgcolor = COL_CELL_BG, text_size = tableSize)
        table.cell(tbl, 2, row, f_momArrow(m, up, dn), text_color = f_momColor(m, up, dn), bgcolor = COL_CELL_BG, text_size = tableSize)

// ─────────────────────────────────────────────────────────────────────────────
// Table — header + five timeframe rows
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = table.new(tablePos, 3, 6,
     frame_color  = color.new(#0f172a, 40), frame_width  = 1,
     border_color = color.new(color.gray, 75), border_width = 1)

if barstate.islast
    table.cell(tbl, 0, 0, "TF",  text_color = COL_HEADER_TXT, bgcolor = COL_HEADER_BG, text_size = tableSize)
    table.cell(tbl, 1, 0, "Sqz", text_color = COL_HEADER_TXT, bgcolor = COL_HEADER_BG, text_size = tableSize)
    table.cell(tbl, 2, 0, "Mom", text_color = COL_HEADER_TXT, bgcolor = COL_HEADER_BG, text_size = tableSize)

    f_drawRow(tbl, 1, "15m", "15",  s15, m15, u15, d15)
    f_drawRow(tbl, 2, "1h",  "60",  s60, m60, u60, d60)
    f_drawRow(tbl, 3, "4h",  "240", s4h, m4h, u4h, d4h)
    f_drawRow(tbl, 4, "D",   "D",   sD,  mD,  uD,  dD)
    f_drawRow(tbl, 5, "W",   "W",   sW,  mW,  uW,  dW)
````
