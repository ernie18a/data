<!-- tradingview-pine-id: PUB;2e962ddcd1a44346838bfe03261e50c1 -->
<!-- tradingviewscripts-format: 1 -->
# NQ VWAP State Board

Source: https://www.tradingview.com/script/HQzH0mdO-NQ-VWAP-State-Board/

## Description

VWMA process just to screen trades 
Tracks multiple session vwaps including  globex, RTH and prior RTH. 
Lets you focus down on the "State" of the market identify where volume traded relative to prior levels.

---

## Source Code

````pine
// NQ VWAP State Board — process location for TD / trap review
// Pine v6 · overlay
//
// Boards:
//   1) Session (Globex) VWAP  ±1..4σ   — resets ~18:00 ET (1800-1700)
//   2) RTH VWAP               ±1..4σ   — 09:30–16:00 ET
//   3) t−1 RTH VWAP           ±1..4σ   — frozen at prior RTH close
//   4) Globex t−1 VWAP        ±1..4σ   — frozen at prior Globex rollover
//   5) 4σ volume candle high/low marks
//   6) Rolling 15m VWAP 5 / 9 / 21 / 100 / 200 (via request.security)
//
// Usage: Pine Editor → paste → Add to chart on NQ1! (CME). Chart tz America/New_York recommended.
// Verify: session VWAP restarts each ~18:00 ET (not a multi-day smear);
//         RTH cone from 09:30; t−1 rails flat.

//@version=6
indicator("NQ VWAP State Board", overlay = true, max_labels_count = 500)

// ── Inputs ──────────────────────────────────────────────────────────
grpS = "Sessions (America/New_York)"
tz           = input.string("America/New_York", "Timezone", group = grpS)
rth_session  = input.session("0930-1600", "RTH session", group = grpS)
globex_sess  = input.session("1800-1700", "Globex / overnight session", group = grpS)
sigma_floor  = input.float(5.0, "σ floor (pts)", minval = 0.0, group = grpS)

grpShow = "Visibility"
show_sess   = input.bool(true, "Session (Globex) VWAP ±σ", group = grpShow)
show_rth    = input.bool(true, "RTH VWAP ±σ", group = grpShow)
show_t1_rth = input.bool(true, "t−1 RTH VWAP ±σ", group = grpShow)
show_t1_gx  = input.bool(true, "Globex t−1 VWAP ±σ", group = grpShow)
show_vol4   = input.bool(true, "4σ volume H/L marks", group = grpShow)
show_rib    = input.bool(true, "15m rolling VWAP ribbon", group = grpShow)
show_bands  = input.string("1-4", "σ bands to plot", options = ["1-4", "1-3", "2-3 only"], group = grpShow)

grpVol = "4σ volume candles"
vol_len = input.int(50, "Volume SMA / stdev length", minval = 10, group = grpVol)

grpRib = "15m rolling VWAP"
rib_5   = input.bool(true, "VWAP-5", group = grpRib)
rib_9   = input.bool(true, "VWAP-9", group = grpRib)
rib_21  = input.bool(true, "VWAP-21", group = grpRib)
rib_100 = input.bool(false, "VWAP-100", group = grpRib)
rib_200 = input.bool(false, "VWAP-200", group = grpRib)

// ── Session flags ───────────────────────────────────────────────────
// IMPORTANT: do NOT use `in_sess and not in_sess[1]` for Globex reset.
// CME has almost no bars in the 17:00–18:00 ET gap, so that edge never
// fires and VWAP accumulates across many sessions (looks "too far back").
// `time("D", session, tz)` is the session's day-open stamp; it changes
// at each new Globex/RTH day even when gap bars are missing.
in_rth      = not na(time(timeframe.period, rth_session, tz))
in_globex   = not na(time(timeframe.period, globex_sess, tz))
globex_day  = time("D", globex_sess, tz)
rth_day     = time("D", rth_session, tz)
new_globex  = not na(globex_day) and ta.change(globex_day) != 0
new_rth     = not na(rth_day) and ta.change(rth_day) != 0
rth_ended   = in_rth[1] and not in_rth

tp  = hlc3
vol = volume

// ── Helpers: VWAP + volume-weighted σ from cumulative sums ──────────
f_vwap_sig(float spv, float sv, float spv2) =>
    float vwap = sv > 0 ? spv / sv : na
    float vari = sv > 0 ? spv2 / sv - vwap * vwap : na
    float sig  = na(vari) ? na : math.max(math.sqrt(math.max(vari, 0.0)), sigma_floor)
    [vwap, sig]

band_ok(int k) =>
    show_bands == "1-4" ? true : show_bands == "1-3" ? k <= 3 : k == 2 or k == 3

// ── Session (Globex) cumulative — freeze t−1 BEFORE reset ───────────
var float g_spv = 0.0
var float g_sv = 0.0
var float g_spv2 = 0.0
var float t1_gx_vwap = na
var float t1_gx_sig = na

if new_globex
    // Capture completed Globex board, then zero for the new session
    if g_sv > 0
        [fv, fs] = f_vwap_sig(g_spv, g_sv, g_spv2)
        t1_gx_vwap := fv
        t1_gx_sig  := fs
    g_spv  := 0.0
    g_sv   := 0.0
    g_spv2 := 0.0

if in_globex and vol > 0
    g_spv  += tp * vol
    g_sv   += vol
    g_spv2 += tp * tp * vol

[sess_vwap, sess_sig] = f_vwap_sig(g_spv, g_sv, g_spv2)

// ── RTH cumulative — freeze t−1 on first bar after RTH ──────────────
var float r_spv = 0.0
var float r_sv = 0.0
var float r_spv2 = 0.0
var float t1_rth_vwap = na
var float t1_rth_sig = na

if new_rth
    r_spv  := 0.0
    r_sv   := 0.0
    r_spv2 := 0.0

if in_rth and vol > 0
    r_spv  += tp * vol
    r_sv   += vol
    r_spv2 += tp * tp * vol

[rth_vwap, rth_sig] = f_vwap_sig(r_spv, r_sv, r_spv2)

// After RTH ends, sums still hold the final board — freeze once
if rth_ended and r_sv > 0
    [fv, fs] = f_vwap_sig(r_spv, r_sv, r_spv2)
    t1_rth_vwap := fv
    t1_rth_sig  := fs

// ── Colors ──────────────────────────────────────────────────────────
c_sess = color.new(color.orange, 0)
c_rth  = color.new(color.aqua, 0)
c_t1r  = color.new(color.blue, 0)
c_t1g  = color.new(color.purple, 0)

// linebr avoids diagonal connectors across session resets / na gaps
ps = plot.style_linebr

// Orange dots = Globex day flip (should appear near each ~18:00 ET open)
plotshape(new_globex, title = "Globex session open", style = shape.circle, location = location.belowbar, size = size.tiny, color = color.new(color.orange, 30), text = "Gx")

// ── Session VWAP ±1..4σ ─────────────────────────────────────────────
plot(show_sess and in_globex ? sess_vwap : na, "Session VWAP", color = c_sess, linewidth = 2, style = ps)
plot(show_sess and in_globex and band_ok(1) ? sess_vwap + sess_sig : na, "Sess +1σ", color = color.new(c_sess, 55), style = ps)
plot(show_sess and in_globex and band_ok(1) ? sess_vwap - sess_sig : na, "Sess −1σ", color = color.new(c_sess, 55), style = ps)
plot(show_sess and in_globex and band_ok(2) ? sess_vwap + 2 * sess_sig : na, "Sess +2σ", color = color.new(c_sess, 40), style = ps)
plot(show_sess and in_globex and band_ok(2) ? sess_vwap - 2 * sess_sig : na, "Sess −2σ", color = color.new(c_sess, 40), style = ps)
plot(show_sess and in_globex and band_ok(3) ? sess_vwap + 3 * sess_sig : na, "Sess +3σ", color = color.new(c_sess, 25), style = ps)
plot(show_sess and in_globex and band_ok(3) ? sess_vwap - 3 * sess_sig : na, "Sess −3σ", color = color.new(c_sess, 25), style = ps)
plot(show_sess and in_globex and band_ok(4) ? sess_vwap + 4 * sess_sig : na, "Sess +4σ", color = color.new(c_sess, 15), style = ps)
plot(show_sess and in_globex and band_ok(4) ? sess_vwap - 4 * sess_sig : na, "Sess −4σ", color = color.new(c_sess, 15), style = ps)

// ── RTH VWAP ±1..4σ (RTH bars only → natural daily gaps) ────────────
plot(show_rth and in_rth ? rth_vwap : na, "RTH VWAP", color = c_rth, linewidth = 2, style = ps)
plot(show_rth and in_rth and band_ok(1) ? rth_vwap + rth_sig : na, "RTH +1σ", color = color.new(c_rth, 55), style = ps)
plot(show_rth and in_rth and band_ok(1) ? rth_vwap - rth_sig : na, "RTH −1σ", color = color.new(c_rth, 55), style = ps)
plot(show_rth and in_rth and band_ok(2) ? rth_vwap + 2 * rth_sig : na, "RTH +2σ", color = color.new(c_rth, 40), style = ps)
plot(show_rth and in_rth and band_ok(2) ? rth_vwap - 2 * rth_sig : na, "RTH −2σ", color = color.new(c_rth, 40), style = ps)
plot(show_rth and in_rth and band_ok(3) ? rth_vwap + 3 * rth_sig : na, "RTH +3σ", color = color.new(c_rth, 25), style = ps)
plot(show_rth and in_rth and band_ok(3) ? rth_vwap - 3 * rth_sig : na, "RTH −3σ", color = color.new(c_rth, 25), style = ps)
plot(show_rth and in_rth and band_ok(4) ? rth_vwap + 4 * rth_sig : na, "RTH +4σ", color = color.new(c_rth, 15), style = ps)
plot(show_rth and in_rth and band_ok(4) ? rth_vwap - 4 * rth_sig : na, "RTH −4σ", color = color.new(c_rth, 15), style = ps)

// ── t−1 RTH VWAP ±1..4σ ─────────────────────────────────────────────
plot(show_t1_rth ? t1_rth_vwap : na, "t−1 RTH VWAP", color = c_t1r, linewidth = 2, style = ps)
plot(show_t1_rth and band_ok(1) ? t1_rth_vwap + t1_rth_sig : na, "t−1 RTH +1σ", color = color.new(c_t1r, 50), style = ps)
plot(show_t1_rth and band_ok(1) ? t1_rth_vwap - t1_rth_sig : na, "t−1 RTH −1σ", color = color.new(c_t1r, 50), style = ps)
plot(show_t1_rth and band_ok(2) ? t1_rth_vwap + 2 * t1_rth_sig : na, "t−1 RTH +2σ", color = color.new(c_t1r, 40), style = ps)
plot(show_t1_rth and band_ok(2) ? t1_rth_vwap - 2 * t1_rth_sig : na, "t−1 RTH −2σ", color = color.new(c_t1r, 40), style = ps)
plot(show_t1_rth and band_ok(3) ? t1_rth_vwap + 3 * t1_rth_sig : na, "t−1 RTH +3σ", color = color.new(c_t1r, 30), style = ps)
plot(show_t1_rth and band_ok(3) ? t1_rth_vwap - 3 * t1_rth_sig : na, "t−1 RTH −3σ", color = color.new(c_t1r, 30), style = ps)
plot(show_t1_rth and band_ok(4) ? t1_rth_vwap + 4 * t1_rth_sig : na, "t−1 RTH +4σ", color = color.new(c_t1r, 20), style = ps)
plot(show_t1_rth and band_ok(4) ? t1_rth_vwap - 4 * t1_rth_sig : na, "t−1 RTH −4σ", color = color.new(c_t1r, 20), style = ps)

// ── Globex t−1 VWAP ±1..4σ ──────────────────────────────────────────
plot(show_t1_gx ? t1_gx_vwap : na, "Globex t−1 VWAP", color = c_t1g, linewidth = 2, style = ps)
plot(show_t1_gx and band_ok(1) ? t1_gx_vwap + t1_gx_sig : na, "Gx t−1 +1σ", color = color.new(c_t1g, 50), style = ps)
plot(show_t1_gx and band_ok(1) ? t1_gx_vwap - t1_gx_sig : na, "Gx t−1 −1σ", color = color.new(c_t1g, 50), style = ps)
plot(show_t1_gx and band_ok(2) ? t1_gx_vwap + 2 * t1_gx_sig : na, "Gx t−1 +2σ", color = color.new(c_t1g, 40), style = ps)
plot(show_t1_gx and band_ok(2) ? t1_gx_vwap - 2 * t1_gx_sig : na, "Gx t−1 −2σ", color = color.new(c_t1g, 40), style = ps)
plot(show_t1_gx and band_ok(3) ? t1_gx_vwap + 3 * t1_gx_sig : na, "Gx t−1 +3σ", color = color.new(c_t1g, 30), style = ps)
plot(show_t1_gx and band_ok(3) ? t1_gx_vwap - 3 * t1_gx_sig : na, "Gx t−1 −3σ", color = color.new(c_t1g, 30), style = ps)
plot(show_t1_gx and band_ok(4) ? t1_gx_vwap + 4 * t1_gx_sig : na, "Gx t−1 +4σ", color = color.new(c_t1g, 20), style = ps)
plot(show_t1_gx and band_ok(4) ? t1_gx_vwap - 4 * t1_gx_sig : na, "Gx t−1 −4σ", color = color.new(c_t1g, 20), style = ps)

// ── 4σ volume candle H/L (absolute price requires numeric series) ───
vol_ma = ta.sma(volume, vol_len)
vol_sd = ta.stdev(volume, vol_len)
is_vol4 = not na(vol_sd) and vol_sd > 0 and volume > vol_ma + 4.0 * vol_sd
plotshape(show_vol4 and is_vol4 ? high : na, title = "4σ Vol High", style = shape.triangledown, location = location.absolute, size = size.tiny, color = color.new(color.yellow, 0), text = "4σH")
plotshape(show_vol4 and is_vol4 ? low : na, title = "4σ Vol Low", style = shape.triangleup, location = location.absolute, size = size.tiny, color = color.new(color.yellow, 0), text = "4σL")

// ── Rolling 15m VWAP ribbon ─────────────────────────────────────────
f_roll_vwap(int len) =>
    float pvs = math.sum(hlc3 * volume, len)
    float vs  = math.sum(volume, len)
    vs > 0 ? pvs / vs : na

// One security call → five lengths (cheaper than 5× request.security)
[vwap5_15, vwap9_15, vwap21_15, vwap100_15, vwap200_15] =
     request.security(syminfo.tickerid, "15",
         [f_roll_vwap(5), f_roll_vwap(9), f_roll_vwap(21), f_roll_vwap(100), f_roll_vwap(200)],
         barmerge.gaps_off, barmerge.lookahead_off)

plot(show_rib and rib_5   ? vwap5_15   : na, "15m VWAP-5",   color = color.new(color.lime, 20), style = ps)
plot(show_rib and rib_9   ? vwap9_15   : na, "15m VWAP-9",   color = color.new(color.teal, 20), style = ps)
plot(show_rib and rib_21  ? vwap21_15  : na, "15m VWAP-21",  color = color.new(color.olive, 20), style = ps)
plot(show_rib and rib_100 ? vwap100_15 : na, "15m VWAP-100", color = color.new(color.gray, 10), style = ps)
plot(show_rib and rib_200 ? vwap200_15 : na, "15m VWAP-200", color = color.new(color.silver, 0), linewidth = 2, style = ps)

// ── Table: live readouts ────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 70), border_width = 1)
if barstate.islast
    table.cell(tbl, 0, 0, "Board", text_color = color.white)
    table.cell(tbl, 1, 0, "Value", text_color = color.white)
    table.cell(tbl, 0, 1, "Sess VWAP", text_color = c_sess)
    table.cell(tbl, 1, 1, str.tostring(sess_vwap, format.mintick), text_color = color.white)
    table.cell(tbl, 0, 2, "Sess σ", text_color = c_sess)
    table.cell(tbl, 1, 2, str.tostring(sess_sig, format.mintick), text_color = color.white)
    table.cell(tbl, 0, 3, "RTH VWAP", text_color = c_rth)
    table.cell(tbl, 1, 3, str.tostring(rth_vwap, format.mintick), text_color = color.white)
    table.cell(tbl, 0, 4, "RTH σ", text_color = c_rth)
    table.cell(tbl, 1, 4, str.tostring(rth_sig, format.mintick), text_color = color.white)
    table.cell(tbl, 0, 5, "t−1 RTH", text_color = c_t1r)
    table.cell(tbl, 1, 5, str.tostring(t1_rth_vwap, format.mintick), text_color = color.white)
    table.cell(tbl, 0, 6, "Gx t−1", text_color = c_t1g)
    table.cell(tbl, 1, 6, str.tostring(t1_gx_vwap, format.mintick), text_color = color.white)
    table.cell(tbl, 0, 7, "15m VWAP5", text_color = color.lime)
    table.cell(tbl, 1, 7, str.tostring(vwap5_15, format.mintick), text_color = color.white)
````
