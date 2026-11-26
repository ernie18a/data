# TechOpps VOLUME Surge Screener

- url: https://www.tradingview.com/script/sxJ1qfJ1-TechOpps-VOLUME-Surge-Screener/
- type: indicator
- pine_id: PUB;918e7e1fbb8e4a4d9ebce8f7b1e8ca03
- version: 1.0

## Description

I like to run a screener on the S&P 500 stocks to identify volume breakouts. It helps reduce my daily list down substantially. 

Here is how I use it.

Create a watchlist for S&P 500 stocks, or whatever asset list you like.

Go to Pine Screener, select the indicator "50 Day Volume Breakout" use either Prev-day vol % of 50d (if you want to review the past day's volume) or Cur-day vol % of 50d (if you want to review today). Once you chose one, put 120 in the value to represent 120% of the 50dma volume. If you are doing this intraday on current day volume, sometimes I use 100% assuming more volume is coming before close.

This should generate a list of 20-100 of S&P 500 stocks depending on the day. I visually eliminate any stinkers and look for breakouts from consolidation. This has helped me save a lot of time. Good luck!

## Source Code

````pine
//@version=6
// =====================================================================================
// TECHNICAL OPPORTUNITIES — VOLUME SURGE Screener (Path-2 / breakout-already-happened)
// =====================================================================================
// Strategy: Technical Opportunities  |  Author: Michael Lemas, Clearview Wealth Partners
// THIRD screener. Where FAST/SLOW find quiet bases BEFORE a move, this finds names
// whose VOLUME has already expanded — the footprint of a breakout that may have just
// fired. It feeds the DELAYED (Path-2) entry process: a flag = pull the chart, judge
// price yourself, confirm it's a real upside breakout still inside the ATR cap.
//
// PURE VOLUME — NO PRICE LOGIC BY DESIGN (per PM): price is screened by eye.
//
// TWO INDEPENDENT COLUMNS (filter on either or both in the Pine Screener):
//   PREV-DAY SURGE : yesterday's COMPLETED volume >= 120% of the 50-day average.
//                    Fixed at 120% — matches entry Criterion 5 (>=120% of 50-day avg).
//   CUR-DAY SURGE  : today's volume >= (adjustable %) of the 50-day average.
//                    Default 100%. Lower bar so you can watch a name build through
//                    the session toward the 120% confirmation line.
//
// INTRADAY PROJECTION (CUR-DAY only — WATCH/TRIAGE TOOL, NOT AN ENTRY TRIGGER):
//   Entry requires ACTUAL volume >= 120% of the 50-day avg, never projected. The
//   projection only helps you rank which names are worth watching into the close.
//   Raw intraday volume accumulates through the day, so at 9:45am it reads near zero.
//   This tool projects full-day volume using a U-SHAPED intraday volume curve (heavy
//   at the open and into the close, thin midday) rather than a flat line, so early
//   readings are far less inflated than a naive linear projection.
//   *** Still an estimate. Do not enter on it. Confirm with ACTUAL >=120% volume. ***
//
// PINE SCREENER: select S&P 500 watchlist -> this indicator ->
//   filter "Prev-day surge (1/0)" and/or "Cur-day surge (1/0)" = 1 -> Scan.
//   Run pre-market for prev-day hits; re-run intraday to watch cur-day build.
// =====================================================================================

indicator("TechOpps VOLUME Surge Screener", shorttitle="TechOpps VOL", overlay=false)

// ============== INPUTS ==============
grp_b = "Baseline"
vol_ma_len = input.int(50, "Volume MA length", group=grp_b, minval=10, tooltip="50-day average — same baseline as entry Criterion 5.")

grp_p = "Previous-day surge (fixed 120%)"
prev_mult = input.float(1.20, "Prev-day surge multiple", group=grp_p, minval=1.0, step=0.05, tooltip="Yesterday's COMPLETED volume vs 50-day avg. 1.20 = 120%. This mirrors the entry rule; leave at 1.20.")

grp_c = "Current-day surge (adjustable — watch it build)"
cur_mult = input.float(1.00, "Cur-day surge multiple", group=grp_c, minval=0.25, step=0.05, tooltip="Today's volume vs 50-day avg. Default 1.00 = 100%. Raise toward 1.20 as you track a name toward confirmation.")
use_projection = input.bool(true, "Project today's full-day volume", group=grp_c, tooltip="ON: estimate full-day volume via a U-shaped intraday curve so the column works from the open (TRIAGE only — entry needs ACTUAL 120%). OFF: raw cumulative volume.")

grp_disp = "Display"
show_box = input.bool(true, "Show status box", group=grp_disp)

// ============== BASELINE ==============
// 50-day average of COMPLETED daily volume. On an intraday timeframe ta.sma(volume,...)
// would average partial bars, so anchor the baseline to the daily series explicitly.
vol_ma_daily = request.security(syminfo.tickerid, "D", ta.sma(volume[1], vol_ma_len), lookahead=barmerge.lookahead_off)

// ============== PREVIOUS-DAY SURGE (completed) ==============
// Yesterday's full-day volume from the daily series.
prev_day_vol = request.security(syminfo.tickerid, "D", volume[1], lookahead=barmerge.lookahead_off)
prev_ratio_pct = vol_ma_daily > 0 ? prev_day_vol / vol_ma_daily * 100.0 : na
prev_surge = not na(prev_ratio_pct) and prev_ratio_pct >= prev_mult * 100.0

// ============== CURRENT-DAY SURGE (live, optionally projected) ==============
// Today's volume so far from the daily series (updates live on the last daily bar).
cur_day_vol_raw = request.security(syminfo.tickerid, "D", volume, lookahead=barmerge.lookahead_off)

// Fraction of the regular session elapsed (clock time), then mapped to the fraction
// of the day's VOLUME expected to have traded by now via a U-shaped profile.
var float sess_start = na
var float sess_end   = na
is_new_day = ta.change(time("D")) != 0
if is_new_day
    sess_start := na
    sess_end   := na
sec_now = hour * 3600 + minute * 60
SESS_OPEN_SEC  = 9  * 3600 + 30 * 60   // 34200  (09:30)
SESS_CLOSE_SEC = 16 * 3600 + 0  * 60   // 57600  (16:00)
SESS_SPAN_SEC  = SESS_CLOSE_SEC - SESS_OPEN_SEC
elapsed_sec = math.max(0.0, math.min(SESS_SPAN_SEC, sec_now - SESS_OPEN_SEC))
t = SESS_SPAN_SEC > 0 ? elapsed_sec / SESS_SPAN_SEC : 1.0   // clock fraction 0..1

// --- U-shaped expected cumulative-volume fraction g(t) ---
// US equities trade a U-curve: a heavy opening burst, a thin midday, and a heavy
// close. So by clock-time t, MORE than t of the day's volume has typically printed
// early (front-loaded), the curve flattens midday, then steepens again into the close.
// We approximate the expected cumulative fraction g(t) as a blend of the identity
// line and a symmetric "fast-ends, slow-middle" S-shape. expV controls U intensity.
expV = input.float(0.55, "U-curve intensity (0=linear, 1=strong U)", group="Current-day surge (adjustable — watch it build)", minval=0.0, maxval=1.0, step=0.05, tooltip="How front/back-loaded to assume volume is. 0 = flat (linear). ~0.55 ≈ typical S&P intraday U-shape.")
// Symmetric front-loaded curve: rises fast near the open and into the close, flat midday.
// g(t) = t + k*sin(2*pi*t)/(2*pi)  — the PLUS puts g above the identity line early,
// i.e. more of the day's volume is assumed already printed (correct for the U-shape).
k = expV
s_curve = t + k * math.sin(2 * math.pi * t) / (2 * math.pi)
g_t = math.max(0.0001, math.min(1.0, s_curve))   // expected cumulative VOLUME fraction
frac_vol = t <= 0 ? na : g_t

cur_day_vol_proj = use_projection and not na(frac_vol) ? cur_day_vol_raw / frac_vol : cur_day_vol_raw
cur_ratio_pct = vol_ma_daily > 0 and not na(cur_day_vol_proj) ? cur_day_vol_proj / vol_ma_daily * 100.0 : na
cur_surge = not na(cur_ratio_pct) and cur_ratio_pct >= cur_mult * 100.0

// Early-session unreliability flag (even U-curve projection is noisy in the first ~20 min).
proj_unreliable = use_projection and t > 0 and t < 0.05  // ~first 20 min of 6.5h

// ============== SCREENER COLUMNS (the plots are the filterable columns) ==============
plot(prev_ratio_pct,           "Prev-day vol % of 50d", color=color.teal)
plot(prev_surge ? 1 : 0,       "Prev-day surge (1/0)",  color=color.green)
plot(cur_ratio_pct,            "Cur-day vol % of 50d",  color=color.orange)
plot(cur_surge ? 1 : 0,        "Cur-day surge (1/0)",   color=color.blue)
plot(proj_unreliable ? 1 : 0,  "Early/unreliable (1/0)",color=color.red)

// ============== STATUS BOX ==============
var table box = table.new(position.top_right, 2, 6, border_width=1, frame_color=color.gray, frame_width=1)
if barstate.islast and show_box
    table.cell(box, 0, 0, "TechOpps VOLUME", text_color=color.white, bgcolor=color.new(color.navy, 0), text_size=size.normal)
    table.cell(box, 1, 0, "prev " + str.tostring(prev_mult*100, "#") + "% / cur " + str.tostring(cur_mult*100, "#") + "%", text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(box, 0, 1, "Prev-day vol %")
    table.cell(box, 1, 1, na(prev_ratio_pct) ? "—" : str.tostring(prev_ratio_pct, "#.0") + "%", bgcolor=prev_surge ? color.new(color.green, 60) : color.new(color.gray, 70))
    table.cell(box, 0, 2, "Prev-day SURGE")
    table.cell(box, 1, 2, prev_surge ? "YES (>=120%)" : "no", text_color=color.white, bgcolor=prev_surge ? color.new(color.green, 20) : color.new(color.gray, 50))
    table.cell(box, 0, 3, "Cur-day vol %" + (use_projection ? " (proj)" : " (raw)"))
    table.cell(box, 1, 3, na(cur_ratio_pct) ? "—" : str.tostring(cur_ratio_pct, "#.0") + "%", bgcolor=cur_surge ? color.new(color.blue, 60) : color.new(color.gray, 70))
    table.cell(box, 0, 4, "Cur-day SURGE")
    table.cell(box, 1, 4, cur_surge ? ("YES (>=" + str.tostring(cur_mult*100, "#") + "%)") : "no", text_color=color.white, bgcolor=cur_surge ? color.new(color.blue, 20) : color.new(color.gray, 50))
    table.cell(box, 0, 5, "Projection")
    table.cell(box, 1, 5, not use_projection ? "off (raw)" : (proj_unreliable ? "EARLY — unreliable" : "ok"), text_color=color.white, bgcolor=proj_unreliable ? color.new(color.red, 30) : color.new(color.gray, 50))

// ============== ALERTS / SCREENER CONDITIONS ==============
alertcondition(prev_surge and not prev_surge[1], title="Prev-day vol >= 120% of 50d",
     message="{{ticker}} VOLUME screener: prior day printed >=120% of its 50-day avg volume. Possible breakout — pull the chart, judge price, check Path-2 eligibility and the ATR cap.")
alertcondition(cur_surge and not cur_surge[1], title="Cur-day vol >= threshold",
     message="{{ticker}} VOLUME screener: today's (projected) volume crossed the current-day threshold vs the 50-day avg. Watch price into the close; projection is unreliable early.")
````
