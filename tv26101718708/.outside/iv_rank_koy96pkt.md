# IV Rank

- url: https://www.tradingview.com/script/Koy96pkT-IV-Rank/
- type: indicator
- pine_id: PUB;759ead5a5a7c42f880806a86c5690f6d
- version: 1.0

## Description

What it does

IV Rank measures where current volatility sits relative to its own history — the single most important input for deciding whether to buy or sell options premium. It combines two complementary metrics on one oscillator: IV Rank and IV Percentile.

Two metrics, one panel

IV Rank answers: "Where is current volatility relative to the min/max of the last N bars?"

0 = vol at the cheapest it has been in the lookback
100 = vol at the most expensive it has been
Formula: (vol − lowest) / (highest − lowest) × 100
Sensitive to outlier spikes — one extreme reading can compress everything else toward the middle
IV Percentile answers: "What percentage of bars in the lookback had lower volatility than today?"

0 = vol is below all of the lookback → historically very cheap
100 = vol is above all of the lookback → historically very expensive
Formula: ta.percentrank(vol, lookback) — more robust against outliers
Better signal when the market had a one-off spike months ago that distorts IV Rank
Both run on Historical Volatility by default. Optionally, point it at any external IV ticker (e.g., CBOE:VIX, CBOE:VXN, CBOE:OVX) to use exchange-published implied volatility directly.

How to read the color zones

Zone IV Rank Trading implication
🟢 Green background < 25 Vol is cheap → favor long vega: buy calls/puts, straddles, debit spreads
🔴 Red background > 75 Vol is expensive → favor short vega: sell premium, iron condors, credit spreads
Yellow / Orange 25–75 Neutral vol → directional strategies, manage existing positions
The oscillator line is color-coded in four steps: green (<25), yellow (25–50), orange (50–75), red (>75).

Vol Crush and Vol Expansion signals

Vol Crush (down triangle) — fires when IV Rank drops more than the threshold in N bars AND was above 50 before the drop. Classic post-earnings or post-event collapse. If you sold premium into the event, this is your confirmation. If you held long options through it, this is the warning you're bleeding theta and vega simultaneously.

Vol Expansion (up triangle) — fires when IV Rank rises more than the threshold in N bars AND was below 50 before. Vol rising from a low base often precedes a breakout or an event being priced in — options are getting more expensive.

Both thresholds are configurable: how many points the rank must move (default 20) and over how many bars (default 5).

MTF Dashboard

A 5-column table at the top right shows IV Rank for the current timeframe plus three user-defined higher timeframes (default: 1H, 4H, Daily). Each cell uses the same 4-color coding. At a glance you see whether short-term vol compression exists inside a long-term elevated vol context — a classic mean reversion setup — or vice versa.

Inputs

Setting Default Description
Use custom IV ticker false Enable to use external IV like CBOE:VIX
Custom IV ticker CBOE:VIX Any symbol with IV data
HV period 20 Std deviation window (~1 month)
Lookback 252 History window for rank/percentile (~1 trading year)
Show IV Percentile true Secondary grey line
Vol crush signal true Post-event drop signal
Vol expansion signal true Rising vol from low base signal
Signal lookback 5 bars Measurement window for signals
Crush/expand threshold 20 pts Minimum rank change to trigger
TF 1 / 2 / 3 60 / 240 / D MTF dashboard timeframes
Alerts (5 conditions)

EV IVR: High (>75) — vol is expensive, consider premium selling strategies
EV IVR: Low (<25) — vol is cheap, consider long vega or directional plays with options
EV IVR: Vol Crush — post-event vol collapse detected
EV IVR: Vol Expansion — vol rising from low base
EV IVR: Cross 50 — midpoint cross, vol regime shift in progress
Volatility source

By default, Historical Volatility is calculated as:
HV = stddev(log(close/close[1]), period) × √252 × 100

Annualized realized volatility on log returns — the industry standard. No special data subscription needed. Works on stocks, indices, futures, crypto, forex — any instrument with OHLCV data.

For assets with published IV (S&P 500, Nasdaq, crude oil, gold, etc.), enabling the custom IV ticker gives you the exchange-implied volatility instead.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © EVLabs — 
//@version=6
indicator("IV Rank", overlay=false)

grp_src = "── Volatility Source ──"
use_custom    = input.bool(false, "Use custom IV ticker", group=grp_src,
                tooltip="Enable to use a specific IV index (e.g. CBOE:VIX for S&P options)")
custom_ticker = input.symbol("CBOE:VIX", "Custom IV ticker", group=grp_src)
hv_period     = input.int(20, "HV period (bars)", group=grp_src, minval=5, maxval=100,
                tooltip="Historical volatility window. 20 bars = standard 1-month HV.")

grp_rank = "── Rank Settings ──"
lookback = input.int(252, "Lookback (bars)", group=grp_rank, minval=50, maxval=504,
           tooltip="252 bars ≈ 1 year on daily. Scale down for intraday charts.")
show_pct = input.bool(true, "Show IV Percentile line", group=grp_rank)

grp_sig = "── Signals ──"
show_crush  = input.bool(true,  "Vol crush signal",              group=grp_sig)
show_expand = input.bool(true,  "Vol expansion signal",          group=grp_sig)
sig_bars    = input.int(5,      "Signal lookback (bars)",        group=grp_sig, minval=2, maxval=20)
sig_thr     = input.float(20.0, "Crush/expand threshold (pts)", group=grp_sig, minval=5.0, maxval=50.0)

grp_vis = "── Display ──"
col_cheap = input.color(color.new(#00c853, 88), "Cheap vol zone",     group=grp_vis)
col_exp   = input.color(color.new(#ff1744, 88), "Expensive vol zone", group=grp_vis)
show_dash = input.bool(true, "MTF dashboard", group=grp_vis)

grp_mtf = "── MTF Dashboard ──"
tf_1 = input.timeframe("60",  "TF 1", group=grp_mtf)
tf_2 = input.timeframe("240", "TF 2", group=grp_mtf)
tf_3 = input.timeframe("D",   "TF 3", group=grp_mtf)

log_ret = math.log(close / close[1])
hv      = ta.stdev(log_ret, hv_period) * math.sqrt(252) * 100.0

custom_vol = request.security(custom_ticker, timeframe.period, close)
vol_src    = use_custom ? custom_vol : hv

hv_hi   = ta.highest(vol_src, lookback)
hv_lo   = ta.lowest(vol_src,  lookback)
iv_rank = hv_hi != hv_lo ? (vol_src - hv_lo) / (hv_hi - hv_lo) * 100.0 : 50.0
iv_pct  = ta.percentrank(vol_src, lookback)

rank_chg   = iv_rank - iv_rank[sig_bars]
vol_crush  = show_crush  and rank_chg < -sig_thr and iv_rank[sig_bars] > 50.0
vol_expand = show_expand and rank_chg >  sig_thr and iv_rank[sig_bars] < 50.0

mtf_ivr(period, lb) =>
    lr = math.log(close / close[1])
    h  = ta.stdev(lr, period) * math.sqrt(252) * 100.0
    hi = ta.highest(h, lb)
    lo = ta.lowest(h,  lb)
    hi != lo ? (h - lo) / (hi - lo) * 100.0 : 50.0

ivr_tf1 = request.security(syminfo.tickerid, tf_1, mtf_ivr(hv_period, lookback))
ivr_tf2 = request.security(syminfo.tickerid, tf_2, mtf_ivr(hv_period, lookback))
ivr_tf3 = request.security(syminfo.tickerid, tf_3, mtf_ivr(hv_period, lookback))

bgcolor(iv_rank < 25 ? col_cheap : na, title="Cheap vol zone")
bgcolor(iv_rank > 75 ? col_exp   : na, title="Expensive vol zone")

hline(75, "High (75)", color=color.new(#ff1744, 50), linestyle=hline.style_dashed)
hline(50, "Mid (50)",  color=color.new(#787b86, 50), linestyle=hline.style_solid)
hline(25, "Low (25)",  color=color.new(#00c853, 50), linestyle=hline.style_dashed)

rank_col = iv_rank > 75 ? color.new(#ff1744, 0) : iv_rank > 50 ? color.new(#ff6d00, 0) : iv_rank > 25 ? color.new(#ffd600, 0) : color.new(#00c853, 0)

plot(iv_rank, "IV Rank",     color=rank_col,                      linewidth=2)
plot(show_pct ? iv_pct : na, "IV Percentile", color=color.new(#787b86, 40), linewidth=1)

plotshape(vol_crush,  "Vol Crush",     shape.triangledown, location.top,    color.new(#ff1744, 0), size=size.small)
plotshape(vol_expand, "Vol Expansion", shape.triangleup,   location.bottom, color.new(#00c853, 0), size=size.small)

_ivr_col(v) => v > 75 ? color.new(#ff1744, 20) : v > 50 ? color.new(#ff6d00, 20) : v > 25 ? color.new(#ffd600, 40) : color.new(#00c853, 20)
_ivr_txt(v) => str.tostring(math.round(v))

var table dash = na
if show_dash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(position.top_right, 5, 2,
         bgcolor=color.new(#1e222d, 5),
         border_width=1, border_color=color.new(#434651, 40),
         frame_width=1,  frame_color=color.new(#434651, 20))
    _c0 = color.new(#1e222d, 0)
    _ct = color.new(#787b86, 0)
    table.cell(dash, 0, 0, "",     bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 1, 0, "Now",  bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 2, 0, tf_1,   bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 3, 0, tf_2,   bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 4, 0, tf_3,   bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 0, 1, "IVR",  bgcolor=_c0, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 1, _ivr_txt(iv_rank), bgcolor=_ivr_col(iv_rank), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 1, _ivr_txt(ivr_tf1), bgcolor=_ivr_col(ivr_tf1), text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 1, _ivr_txt(ivr_tf2), bgcolor=_ivr_col(ivr_tf2), text_color=color.white, text_size=size.small)
    table.cell(dash, 4, 1, _ivr_txt(ivr_tf3), bgcolor=_ivr_col(ivr_tf3), text_color=color.white, text_size=size.small)

alertcondition(iv_rank > 75,          "EV IVR: High (>75)",    "IV Rank above 75 — expensive vol, consider selling premium")
alertcondition(iv_rank < 25,          "EV IVR: Low (<25)",     "IV Rank below 25 — cheap vol, consider buying options or long vega")
alertcondition(vol_crush,             "EV IVR: Vol Crush",     "IV Rank dropped sharply — post-event vol crush detected")
alertcondition(vol_expand,            "EV IVR: Vol Expansion", "IV Rank rising sharply from low — vol expansion / potential breakout")
alertcondition(ta.cross(iv_rank, 50), "EV IVR: Cross 50",      "IV Rank crossed the 50 midpoint")
````
