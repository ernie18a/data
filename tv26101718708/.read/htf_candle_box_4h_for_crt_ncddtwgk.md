# HTF Candle Box ( 4H ) for CRT

- url: https://www.tradingview.com/script/nCdDtwgk-HTF-Candle-Box-4H-for-CRT/
- type: indicator
- pine_id: PUB;b6757ae39e8b41a7bc566347964720c5
- version: 1.0

## Description

DESCRIPTION:
 This indicator overlays the Higher Timeframe (default: 4H) candle
structure directly on your lower timeframe chart (5min, 15min etc).

It draws 3 boxes for every HTF candle:
//  - Body Box    : The Open-Close range (Bullish = Blue, Bearish = Red)
//   - Upper Wick  : High to Body Top (Orange dotted) — Liquidity zone
//   - Lower Wick  : Body Bottom to Low (Orange dotted) — Liquidity zone
//
// WHY USE THIS?
// When you trade on 5min or 15min, it is easy to lose context of where
// price is within the bigger 4H candle. This tool keeps you aware:
//   - Are we inside the body? (consolidation or trend continuation)
//   - Are we in the wick zone? (liquidity sweep, possible reversal)
//   - Where is the 4H open? (key reference level)
//
// SETTINGS:
//   - Higher Timeframe : Change to 1H, Daily, Weekly as needed
//   - Body & Wick colors are fully customizable
//   - Open Price Line can be toggled on/off
//
// Works on any market: Forex, Crypto, Stocks, Indices.
// No repainting — uses lookahead_off.

## Source Code

````pine
//@version=5
indicator("HTF Candle Box", shorttitle="HTF Box", overlay=true, max_boxes_count=500, max_lines_count=500)

// ── INPUTS ──────────────────────────────────────────────────────────
htf_tf        = input.timeframe("240",              "Higher Timeframe")
bull_body_col = input.color(color.new(#1E88E5, 95), "Bullish Body Fill", group="Body Colors")
bear_body_col = input.color(color.new(#E53935, 95), "Bearish Body Fill", group="Body Colors")
body_brd_col  = input.color(color.new(#455A64, 0), "Body Border",       group="Body Colors")
wick_bg_col   = input.color(color.new(#FF6D00, 95), "Wick Fill",         group="Wick Colors")
wick_brd_col  = input.color(color.new(#FF6D00, 0), "Wick Border",       group="Wick Colors")
show_open_ln  = input.bool(true, "Show Open Price Line", group="Options")

// ── HTF CANDLE PERIOD IN MILLISECONDS (calculated, not from security) ─
htf_ms = timeframe.in_seconds(htf_tf) * 1000

// ── HTF DATA ──────────────────────────────────────────────────────────
htf_o = request.security(syminfo.tickerid, htf_tf, open,  lookahead=barmerge.lookahead_off)
htf_h = request.security(syminfo.tickerid, htf_tf, high,  lookahead=barmerge.lookahead_off)
htf_l = request.security(syminfo.tickerid, htf_tf, low,   lookahead=barmerge.lookahead_off)
htf_c = request.security(syminfo.tickerid, htf_tf, close, lookahead=barmerge.lookahead_off)
htf_t = request.security(syminfo.tickerid, htf_tf, time,  lookahead=barmerge.lookahead_off)

// ── NEW 4H CANDLE DETECTION ───────────────────────────────────────────
new_htf = ta.change(htf_t) != 0

// ── DRAW COMPLETED CANDLE ─────────────────────────────────────────────
if new_htf and not na(htf_t[1])
    pO  = htf_o[1]
    pH  = htf_h[1]
    pL  = htf_l[1]
    pC  = htf_c[1]
    pT  = htf_t[1]
    // Right edge = exact candle open time + candle duration (no gaps, no drift)
    pTC = pT + htf_ms
    pBT = math.max(pO, pC)
    pBB = math.min(pO, pC)
    pBC = pC >= pO ? bull_body_col : bear_body_col

    if pH > pBT
        box.new(pT, pH, pTC, pBT, xloc=xloc.bar_time, bgcolor=wick_bg_col,   border_color=wick_brd_col, border_width=1, border_style=line.style_dotted)

    box.new(pT, pBT, pTC, pBB, xloc=xloc.bar_time, bgcolor=pBC, border_color=body_brd_col, border_width=1)

    if pL < pBB
        box.new(pT, pBB, pTC, pL, xloc=xloc.bar_time, bgcolor=wick_bg_col, border_color=wick_brd_col, border_width=1, border_style=line.style_dotted)

    if show_open_ln
        line.new(pT, pO, pTC, pO, xloc=xloc.bar_time, color=body_brd_col, style=line.style_dashed, width=1)

// ── LIVE CURRENT CANDLE (also uses calculated right edge) ─────────────
var box  live_body    = na
var box  live_upper   = na
var box  live_lower   = na
var line live_open_ln = na

// On new candle — delete old live boxes
if new_htf
    box.delete(live_body)
    box.delete(live_upper)
    box.delete(live_lower)
    line.delete(live_open_ln)
    live_body    := na
    live_upper   := na
    live_lower   := na
    live_open_ln := na

// Draw/update live boxes every bar
cT  = htf_t
cTC = htf_t + htf_ms     // fixed right edge, calculated
cBT = math.max(htf_o, htf_c)
cBB = math.min(htf_o, htf_c)
cBC = htf_c >= htf_o ? bull_body_col : bear_body_col

// Upper wick
if htf_h > cBT
    if na(live_upper)
        live_upper := box.new(cT, htf_h, cTC, cBT, xloc=xloc.bar_time, bgcolor=wick_bg_col, border_color=wick_brd_col, border_width=2, border_style=line.style_dotted)
    else
        box.set_top(live_upper, htf_h)
        box.set_bottom(live_upper, cBT)
else
    box.delete(live_upper)
    live_upper := na

// Body
if na(live_body)
    live_body := box.new(cT, cBT, cTC, cBB, xloc=xloc.bar_time, bgcolor=cBC, border_color=body_brd_col, border_width=2)
else
    box.set_top(live_body, cBT)
    box.set_bottom(live_body, cBB)
    box.set_bgcolor(live_body, cBC)

// Lower wick
if htf_l < cBB
    if na(live_lower)
        live_lower := box.new(cT, cBB, cTC, htf_l, xloc=xloc.bar_time, bgcolor=wick_bg_col, border_color=wick_brd_col, border_width=2, border_style=line.style_dotted)
    else
        box.set_top(live_lower, cBB)
        box.set_bottom(live_lower, htf_l)
else
    box.delete(live_lower)
    live_lower := na

// Open line
if show_open_ln
    if na(live_open_ln)
        live_open_ln := line.new(cT, htf_o, cTC, htf_o, xloc=xloc.bar_time, color=body_brd_col, style=line.style_dashed, width=1)
else
    line.delete(live_open_ln)
    live_open_ln := na
````
