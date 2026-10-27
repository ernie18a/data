# MTF Trend Table(Dau)

- url: https://www.tradingview.com/script/popzjS6U-MTF-Trend-Table-Dau/
- type: indicator
- pine_id: PUB;ab097f717fac4d74a67207268fd6dc5d
- version: 2.0

## Description

What it is

  A two-part indicator that sits in the bottom-right corner of your chart. The top half tells you the market trend
  across multiple timeframes. The bottom half calculates your lot size based on your risk and stop loss.

  ---
  Part 1 — Trend Analysis

  The indicator evaluates 3 timeframes simultaneously: 15 minutes, 1 hour, and 4 hours. On each timeframe it runs 3
  checks:

  Check 1 — EMA Position
  Is price above or below the EMA 50? Above = bullish pressure, below = bearish pressure.

  Check 2 — EMA Slope
  Is the EMA 50 actually rising or falling? It compares the current EMA to where it was 3 bars ago. If it's flat or
  moving against price, the signal is ignored. This prevents false signals in choppy markets.

  Check 3 — Market Structure
  Is the market making higher highs and higher lows (bullish), or lower highs and lower lows (bearish)? A small
  ATR-based tolerance is applied so minor pullbacks don't break the trend classification.

  Check 4 — Trend Strength
  Is price far enough from the EMA to confirm conviction? If price is hovering right on the EMA, it's classified as
  Ranging regardless of the other conditions.

  All 4 checks must agree before a timeframe is classified as Bullish or Bearish. If they don't all agree, the timeframe
   is either Transition or Ranging.

  ---
  The 4 States

  ┌────────┬────────────┬────────────────────────────────────────────────────┐
  │ Symbol │   State    │                      Meaning                       │
  ├────────┼────────────┼────────────────────────────────────────────────────┤
  │ ▲      │ Bullish    │ All conditions confirmed bullish                   │
  ├────────┼────────────┼────────────────────────────────────────────────────┤
  │ ▼      │ Bearish    │ All conditions confirmed bearish                   │
  ├────────┼────────────┼────────────────────────────────────────────────────┤
  │ ↕      │ Transition │ Something shifting — partial signal or TF conflict │
  ├────────┼────────────┼────────────────────────────────────────────────────┤
  │ ◆      │ Ranging    │ No meaningful directional signal                   │
  └────────┴────────────┴────────────────────────────────────────────────────┘

  ---
  Overall Trend & Confidence

  After evaluating all 3 timeframes individually, the indicator produces an overall verdict with the 4H timeframe
  weighted most heavily:

  - Bullish — at least 2 timeframes bullish and 4H is not bearish
  - Bearish — at least 2 timeframes bearish and 4H is not bullish
  - Transition — timeframes conflict, or a reversal is starting but not confirmed
  - Ranging — no directional agreement

  Confidence reflects how many timeframes agree:
  - High — all 3 timeframes aligned
  - Medium — 2 out of 3 aligned
  - Low — minimum agreement
  - — — shown during Transition (confidence is not meaningful)

  ---
  Part 2 — Lot Size Calculator

  Once you draw your position and know your stop loss distance, you enter two values in the settings:

  - SL — your stop loss in pips (GBP/USD) or points (DAX, UK100)
  - Risk Amount — how much you are willing to risk in € or $

  The indicator then calculates your exact lot size using live exchange rates fetched directly from the market. Nothing
  is hardcoded — the calculation updates in real time.

  - GBP/USD: converts your EUR/USD risk into USD using the live EURUSD rate, then divides by the pip value
  - DAX: divides your risk directly by the point distance (already in EUR)
  - UK100: converts your risk to GBP using a live synthetic rate, then divides by the point distance

  It supports both a EUR account and a USD account — selectable in settings.

  ---
  How to use it in a trade

  1. Check the Trend row — only consider trades when it shows Bullish or Bearish
  2. Check the Conf row — prefer Medium or High confidence
  3. Check the per-TF arrows — ideally 4H and 1H should agree with your direction
  4. Draw your position on the chart, note the SL distance in pips/points
  5. Enter the SL and your risk amount in the indicator settings
  6. Read the Size row — that is your lot size

## Source Code

````pine
//@version=6
indicator("MTF Trend Table", overlay=true)

g_t = "Trend Settings"
g_r = "Risk Settings"
g_s = "Session Zones"

ema_len       = input.int(50,    "EMA Length",            group=g_t, minval=1)
slope_lb      = input.int(3,     "Slope Smoothing",       group=g_t, minval=1, maxval=10)
struct_lb     = input.int(10,    "Structure Lookback",    group=g_t, minval=5,  maxval=50)
atr_mult      = input.float(0.5, "Strength Filter (ATR)", group=g_t, step=0.1,  minval=0.0, maxval=3.0)
sl_input      = input.float(10,  "SL (pips or points)",  group=g_r, step=0.5,  minval=0.1)
risk_amt      = input.float(400, "Risk Amount",           group=g_r, step=10,   minval=1)
acc_currency  = input.string("EUR", "Account Currency",  group=g_r, options=["EUR","USD"])
show_sessions = input.bool(true,  "Show Session Zones",  group=g_s)

// ── Fetch per-TF data ─────────────────────────────────────────────────────────
[c15, e15, e15p, hh15, hh15p, ll15, ll15p, atr15] = request.security(syminfo.tickerid, "15",
    [close, ta.ema(close,ema_len), ta.ema(close,ema_len)[slope_lb],
     ta.highest(high,struct_lb), ta.highest(high,struct_lb)[struct_lb],
     ta.lowest(low,struct_lb),   ta.lowest(low,struct_lb)[struct_lb], ta.atr(14)])

[c60, e60, e60p, hh60, hh60p, ll60, ll60p, atr60] = request.security(syminfo.tickerid, "60",
    [close, ta.ema(close,ema_len), ta.ema(close,ema_len)[slope_lb],
     ta.highest(high,struct_lb), ta.highest(high,struct_lb)[struct_lb],
     ta.lowest(low,struct_lb),   ta.lowest(low,struct_lb)[struct_lb], ta.atr(14)])

[c240, e240, e240p, hh240, hh240p, ll240, ll240p, atr240] = request.security(syminfo.tickerid, "240",
    [close, ta.ema(close,ema_len), ta.ema(close,ema_len)[slope_lb],
     ta.highest(high,struct_lb), ta.highest(high,struct_lb)[struct_lb],
     ta.lowest(low,struct_lb),   ta.lowest(low,struct_lb)[struct_lb], ta.atr(14)])

// ── Trend per TF ──────────────────────────────────────────────────────────────
f_trend(c, e, ep, hhn, hhp, lln, llp, atr_v) =>
    slope_bull          = e > ep
    slope_bear          = e < ep
    is_strong           = atr_mult == 0.0 or math.abs(c - e) > atr_v * atr_mult
    tol                 = atr_v * 0.3
    s_bull              = hhn > (hhp - tol) and lln > (llp - tol)
    s_bear              = hhn < (hhp + tol) and lln < (llp + tol)
    bull                = c > e and slope_bull and is_strong and s_bull
    bear                = c < e and slope_bear and is_strong and s_bear
    partial_bull        = c > e and slope_bull and (not is_strong or not s_bull)
    partial_bear        = c < e and slope_bear and (not is_strong or not s_bear)
    ema_struct_conflict = (slope_bull and s_bear) or (slope_bear and s_bull)
    trans               = not bull and not bear and (partial_bull or partial_bear or ema_struct_conflict)
    bull ? 1 : bear ? -1 : trans ? 2 : 0

t15  = f_trend(c15,  e15,  e15p,  hh15,  hh15p,  ll15,  ll15p,  atr15)
t60  = f_trend(c60,  e60,  e60p,  hh60,  hh60p,  ll60,  ll60p,  atr60)
t240 = f_trend(c240, e240, e240p, hh240, hh240p, ll240, ll240p, atr240)

// ── Final trend ───────────────────────────────────────────────────────────────
bull_n       = (t15==1?1:0)  + (t60==1?1:0)  + (t240==1?1:0)
bear_n       = (t15==-1?1:0) + (t60==-1?1:0) + (t240==-1?1:0)
trans_n      = (t15==2?1:0)  + (t60==2?1:0)  + (t240==2?1:0)
has_conflict = (t240==1 and (t60==-1 or t15==-1)) or (t240==-1 and (t60==1 or t15==1))
final_bull   = bull_n >= 2 and t240 != -1
final_bear   = bear_n >= 2 and t240 != 1
in_trans     = not final_bull and not final_bear and (trans_n > 0 or has_conflict)
final_trend  = final_bull ? 1 : final_bear ? -1 : in_trans ? 2 : 0

agree_n   = final_bull ? bull_n : final_bear ? bear_n : 0
conf_str  = final_trend == 2 ? "—" : agree_n == 3 ? "High" : agree_n == 2 ? "Medium" : "Low"
conf_col  = final_trend == 2 ? color.orange : agree_n == 3 ? color.lime : agree_n == 2 ? color.yellow : color.gray
trend_str = final_trend == 1 ? "Bullish" : final_trend == -1 ? "Bearish" : final_trend == 2 ? "Trans" : "Ranging"
trend_col = final_trend == 1 ? color.lime : final_trend == -1 ? color.red : final_trend == 2 ? color.orange : color.gray

// ── Currency conversion ────────────────────────────────────────────────────────
float eurusd = request.security("OANDA:EURUSD", timeframe.period, close)
float gbpusd = request.security("OANDA:GBPUSD", timeframe.period, close)

float qcr = 1.0
if acc_currency == "EUR"
    if syminfo.currency == "USD"
        qcr := eurusd
    else if syminfo.currency == "GBP"
        qcr := eurusd / gbpusd
else
    if syminfo.currency == "EUR"
        qcr := 1.0 / eurusd
    else if syminfo.currency == "GBP"
        qcr := 1.0 / gbpusd

// ── Position sizing ────────────────────────────────────────────────────────────
sl_dist = syminfo.type == "forex" ? sl_input * 0.0001 : sl_input

float pos_size = na
string pos_unit = "—"
if sl_dist > 0 and qcr > 0
    float units = risk_amt * qcr / sl_dist
    if syminfo.type == "forex"
        pos_size := math.round(units / 100000.0 * 100.0) / 100.0
        pos_unit := "Lots"
    else
        pos_size := math.round(units * 100.0) / 100.0
        pos_unit := "Units"

// ── Table helpers ──────────────────────────────────────────────────────────────
f_sym(t) => t == 1 ? "▲" : t == -1 ? "▼" : t == 2 ? "↕" : "◆"
f_col(t) => t == 1 ? color.lime : t == -1 ? color.red : t == 2 ? color.orange : color.gray

bool is_forex   = syminfo.type == "forex"
string sl_lbl   = is_forex ? str.tostring(sl_input,"#.#") + " pips" : str.tostring(sl_input,"#.#") + " pts"
string risk_lbl = (acc_currency == "EUR" ? "€" : "$") + str.tostring(math.round(risk_amt))

// ── Table ─────────────────────────────────────────────────────────────────────
C_HDR = color.new(color.gray, 55)
C_SEP = color.new(color.gray, 75)

var table tbl = table.new(position.bottom_right, 2, 10,
     bgcolor=color.new(color.black,20), border_width=1,
     border_color=color.new(color.gray,50),
     frame_color=color.new(color.gray,30), frame_width=1)

if barstate.islast
    table.cell(tbl, 0, 0, "TF",     text_color=color.white, text_size=size.small, bgcolor=C_HDR)
    table.cell(tbl, 1, 0, "Signal", text_color=color.white, text_size=size.small, bgcolor=C_HDR)
    table.cell(tbl, 0, 1, "15m", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 1, f_sym(t15),  text_color=f_col(t15),  text_size=size.large)
    table.cell(tbl, 0, 2, "1H",  text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 2, f_sym(t60),  text_color=f_col(t60),  text_size=size.large)
    table.cell(tbl, 0, 3, "4H",  text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 3, f_sym(t240), text_color=f_col(t240), text_size=size.large)
    table.cell(tbl, 0, 4, "Trend", text_color=color.white, text_size=size.small, bgcolor=C_HDR)
    table.cell(tbl, 1, 4, trend_str,   text_color=trend_col,   text_size=size.small, bgcolor=C_HDR)
    table.cell(tbl, 0, 5, "Conf",  text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 5, conf_str,    text_color=conf_col,    text_size=size.small)
    table.cell(tbl, 0, 6, "", bgcolor=C_SEP)
    table.cell(tbl, 1, 6, "", bgcolor=C_SEP)
    table.cell(tbl, 0, 7, "SL",   text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 7, sl_lbl,     text_color=color.red,    text_size=size.small)
    table.cell(tbl, 0, 8, "Risk", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 8, risk_lbl,   text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 0, 9, "Size", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 9, not na(pos_size) ? str.tostring(pos_size,"#.##") + " " + pos_unit : "—", text_color=color.new(#00CED1, 0), text_size=size.small)

// ── Session Zones ─────────────────────────────────────────────────────────────
float _atr    = ta.atr(14)
float _day_hi = ta.highest(high, 500)
float _day_lo = ta.lowest(low,  500)

var box[] _zboxes = array.new<box>()

if barstate.islast and show_sessions
    for b in _zboxes
        box.delete(b)
    array.clear(_zboxes)

    y = year(timenow)
    m = month(timenow)
    d = dayofmonth(timenow)

    float tp = _day_hi + _atr * 10
    float bt = _day_lo - _atr * 10

    C_GRN = color.new(color.green,  87)
    C_ORG = color.new(color.orange, 78)
    C_BLU = color.new(color.blue,   93)

    lon7   = timestamp("Europe/London",    y, m, d,  7,  0)
    lon745 = timestamp("Europe/London",    y, m, d,  7, 45)
    lon815 = timestamp("Europe/London",    y, m, d,  8, 15)
    lon10  = timestamp("Europe/London",    y, m, d, 10,  0)
    ny8    = timestamp("America/New_York", y, m, d,  8,  0)
    ny915  = timestamp("America/New_York", y, m, d,  9, 15)
    ny945  = timestamp("America/New_York", y, m, d,  9, 45)
    ny12   = timestamp("America/New_York", y, m, d, 12,  0)
    ny13   = timestamp("America/New_York", y, m, d, 13,  0)
    ny15   = timestamp("America/New_York", y, m, d, 15,  0)

    if is_forex
        array.push(_zboxes, box.new(left=lon7,  top=tp, right=lon10,  bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=lon10, top=tp, right=ny8,    bottom=bt, xloc=xloc.bar_time, bgcolor=C_BLU, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny8,   top=tp, right=ny915,  bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny915, top=tp, right=ny945,  bottom=bt, xloc=xloc.bar_time, bgcolor=C_ORG, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny945, top=tp, right=ny12,   bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny12,  top=tp, right=ny13,   bottom=bt, xloc=xloc.bar_time, bgcolor=C_ORG, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny13,  top=tp, right=ny15,   bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
    else
        array.push(_zboxes, box.new(left=lon745, top=tp, right=lon815, bottom=bt, xloc=xloc.bar_time, bgcolor=C_ORG, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=lon815, top=tp, right=lon10,  bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=lon10,  top=tp, right=ny8,    bottom=bt, xloc=xloc.bar_time, bgcolor=C_BLU, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny8,    top=tp, right=ny915,  bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny915,  top=tp, right=ny945,  bottom=bt, xloc=xloc.bar_time, bgcolor=C_ORG, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny945,  top=tp, right=ny12,   bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny12,   top=tp, right=ny13,   bottom=bt, xloc=xloc.bar_time, bgcolor=C_ORG, border_color=na, border_width=0))
        array.push(_zboxes, box.new(left=ny13,   top=tp, right=ny15,   bottom=bt, xloc=xloc.bar_time, bgcolor=C_GRN, border_color=na, border_width=0))
````
