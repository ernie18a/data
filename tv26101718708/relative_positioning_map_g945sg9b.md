# Relative Positioning Map

- url: https://www.tradingview.com/script/g945SG9b-Relative-Positioning-Map/
- type: indicator
- pine_id: PUB;c4e86ee49cde40e2b0a236d0b55b0f85
- version: 2.0

## Description

█ [b]OVERVIEW[/b]

A cross-sectional relative-positioning map. It shows where each of up to 20 instruments sits versus a configurable benchmark right now, measured in daily-volatility units of the relative spread and anchored to the current session's open. It is a visualization and decision-support tool for relative momentum, cross-sectional dispersion and mean-reversion attention on a basket that shares one reference — for example semiconductor names against an ETF, or any sector against a broad index.

The benchmark is fully configurable, so the same tool works on any universe you want to read against a common index. Because every spread is referenced to the same benchmark and scaled the same way, the curves are directly comparable to one another.


█ [b]WHAT IT IS, AND WHAT IT IS NOT[/b]

It is a relative-momentum and dispersion map, plus optional intraday attention shading. It is not a buy/sell signal generator and not a mean-reversion entry system: the shaded windows are attention zones, and any alert it raises flags a large relative move, not a trade.


█ [b]WHAT MAKES IT DIFFERENT[/b]

Many relative-strength plots normalise a windowed return, such as price now divided by price a fixed number of bars ago. That quantity decays on its own as the lookback rolls past an old move, so the line can fall back toward zero even when price has not reverted at all — the plot and the price disagree. This script avoids that by working on the [i]level[/i] of the relative spread rather than on a windowed return, and by anchoring to a static session reference that never chases the level the way a moving average would.


█ [b]CONCEPTS[/b]

For each instrument versus the benchmark:

 • [b]Relative spread, as a level.[/b] s = log( price of instrument / price of benchmark ). It is pulled as a single synthetic ratio series built from the bare tickers. A single series is required because the volatility of a difference carries the cross-covariance of the two legs, which only exists when the ratio is one series. All calculations run at the chosen resolution, which makes the map independent of the chart's own timeframe.

 • [b]Session anchor.[/b] The opening value of the spread is captured at the session open and held fixed for the whole day, resetting each morning. It is static, not a moving average, so it never chases the level.

 • [b]Positioning value.[/b] v = ( spread now minus the opening spread ) divided by the spread's daily volatility. A reading of +2 means the instrument is two daily spread standard deviations above where it opened versus the benchmark; a reading of -5 means it has been five below and stayed there. Persistence is information, not an error: a chronically weak name can legitimately sit near -5 all day. No reversion is implied.

 • [b]Cross-sectional dispersion bands.[/b] At every bar the mean and standard deviation of the values across the whole basket are drawn as envelopes. Wide bands mean high dispersion (names diverging — the classic dispersion-trading backdrop); narrow bands mean the group is moving together.

 • [b]Benchmark baseline.[/b] The benchmark is the zero line by definition. It is drawn as a band tinted by its own short-term trend, so the regime the whole basket is riding is always visible.


█ [b]HOW TO USE[/b]

 1 — Set the [i]Benchmark[/i]: the denominator of every spread. Change it to a broad index, a sector ETF, or any instrument. Prefer a bare ticker so the synthetic ratio resolves cleanly.

 2 — Fill the [i]Universe[/i] slots with up to 20 instruments; leave a slot empty to skip it.

 3 — Pick the [i]Resolution[/i]: the analysis timeframe that drives the calculations, independent of the chart timeframe.

 4 — Read the curves: the top of the pane holds the relative outperformers, the bottom the laggards, scaled in daily spread standard deviations since the open.

 5 — Read the dispersion bands for the regime: widening envelopes mean a dispersing basket (the dispersion-trading backdrop); contracting envelopes mean convergence.

 6 — Use the grey mean-reversion attention windows as reminders of the times of day you choose to watch for reversion in the spreads. They are visual only; validate any reversion with your own analysis.

 7 — Use the mover labels and the ranking table to see which names became extreme or accelerated away from the index, and the daily volatility of each spread for sizing.


█ [b]FEATURES[/b]

 • Configurable benchmark and up to 20 instruments, all comparable on one scale.

 • Chart-timeframe-independent computation through a synthetic ratio evaluated at a chosen resolution.

 • Cross-sectional dispersion envelopes around the basket mean.

 • A trend-tinted benchmark baseline.

 • Two configurable intraday attention windows (mean-reversion zones) plus further session highlights, with timezone and transparency controls.

 • Mover labels that trigger on extreme positioning OR on acceleration away from zero, with a confirmation requirement, a per-name re-label cooldown, an end-of-session suppression window, and automatic anti-overlap stacking. Historical mover labels are semi-transparent; the live right-margin labels showing the current state are solid.

 • A ranking table with each name's positioning value and its spread's daily volatility.


█ [b]LIMITATIONS[/b]

 • Relative spreads are not guaranteed to mean-revert. Whether a given pair reverts on your timeframe is an empirical question of stationarity and half-life that this tool does not test for you. Treat the shaded windows as attention zones only.

 • In extended hours the synthetic ratio depends on both legs trading; where one leg is illiquid you will see stepwise or flat segments. That is market microstructure, not a calculation error.

 • The synthetic ratio is built from bare tickers; an unusual symbol that does not resolve will show no data on that slot.

 • Higher-timeframe values are requested without lookahead, so historical values are fixed once a bar of the chosen resolution closes; only the currently forming bar updates in real time. This is expected behaviour.


█ [b]NOTES[/b]

This script is a context and visualization tool. It does not place orders, and its alerts are informational rather than trade instructions. Nothing in it constitutes financial advice, and past behaviour visible on the chart does not guarantee future results.

═════════════════════════════════════════════════════════════════════════

Published open-source so the calculations can be inspected and adapted. Reuse is governed by the license shown with the source and by TradingView's House Rules.

## Source Code

````pine
// =========================================================================
// RS Cross-Sectional Scanner — Pine v6 (chart-timeframe independent)
// =========================================================================
//
// Computes the double-normalized Relative Strength z-score for up to 20
// symbols vs a single benchmark on a USER-SELECTED resolution (default
// daily). The chart's own timeframe DOES NOT affect the RS values —
// switch the chart freely between 5m/1h/D/W: RS stays identical.
//
// Implementation detail: every series operator (pct_change, EWMA, rolling
// mean/std) is evaluated INSIDE request.security(sym, tf, ...) so that
// `close[k]` means "k tf-bars back", not "k chart-bars back".
//
// Defaults: SMH benchmark, 20-name semis universe (each slot editable).
// Source backtest: research/rs_strategy/  →  Sharpe 2.02 over 2023-26.
// =========================================================================
//@version=6
// max_bars_back=600 → buffer for k=504 lookback + EWMA warm-up.
indicator("RS Cross-Sectional Scanner", shorttitle="RS scan", overlay=false, precision=2, max_lines_count=500, max_labels_count=500, max_bars_back=600)

// ───────────────────────── INPUTS ────────────────────────────
g_bench  = "1. Benchmark (default SMH)"
g_params = "2. RS parameters"
g_uni    = "3. Universe (20 slots, leave empty to skip)"

benchmark_sym = input.symbol("SMH", title="Benchmark", group=g_bench, tooltip="Default SMH. Bare ticker — TradingView auto-resolves the exchange.")

tf      = input.timeframe("5", "Resolution", group=g_params, tooltip="ANALYSIS timeframe — drives all RS math. Independent of the chart's own TF.")
// Defaults below are tuned for tf=5min INTRADAY workflow:
//   k=78    →  1 trading day of 5-min bars (6.5h × 12) — captures
//              today's relative move with minimal lag
//   vol_win=24 → 2 hours of EWMA
//   zwin=156   → 2 trading days for z-score std normalization
// For daily TF (tf="D") switch to: k=252, vol_win=60, zwin=252
//                                  (the Antonacci backtest calibration).
// For very fast intraday reaction: k=12 (1h), vol_win=6, zwin=78.
k       = input.int(78,  "Momentum window k (bars at TF)", minval=6, maxval=504, group=g_params, tooltip="Lookback for momentum signal. On 5-min: 12=1h, 78=1day, 252=3days. On D: 63 or 252.")
vol_win = input.int(24,  "EWMA vol span (bars at TF)",     minval=6, maxval=252, group=g_params, tooltip="EWMA span for vol estimation. Should be < k.")
zwin    = input.int(200, "Z-score rolling window (bars at TF)", minval=24, maxval=504, group=g_params, tooltip="Std normalization window. Smaller = more responsive but noisier.")
band_smooth = input.int(20, "Band smoothing (EMA bars)", minval=0, maxval=100, group=g_params, tooltip="EMA span applied to the cross-sectional mean and std before plotting the σ-bands. 0 = no smoothing (raw, jagged). Higher = smoother but laggier bands. Affects only visual bands, not the per-stock RS curves.")
top_n   = input.int(3,   "Top-N / Bottom-N to highlight", minval=1, maxval=10, group=g_params)
use_eth = input.bool(true, "Include Extended Trading Hours (ETH)", group=g_params, tooltip="ON (default) → pre/post-market bars are included in the RS computation (session = extended). OFF uses Regular Trading Hours only (9:30-16:00 ET). On daily TF the difference is minimal; on intraday TFs it matters substantially.")
show_zones = input.bool(true, "Gradient bands (green above SMH, red below)", group=g_params)

// ── Intraday time-of-day shading (3 configurable windows) ─────────────
// Useful only on intraday chart TFs (5m/15m/1h/4h). Each window is
// defined as a session "HHMM-HHMM" string in the chosen timezone.
// All three default windows correspond to empirically distinct phases:
//   MR (18-22 CEST = 12-16 ET): US afternoon, the mean-reversion sweet
//                                spot used by the P3 strategy.
//   ETH morning (10-15:30 CEST = 04-09:30 ET): European session +
//                                US pre-market, low-volume drift.
//   ETH night (22-02 CEST = 16-20 ET + Asia overnight): US post-market.
g_mr        = "4. Intraday time-of-day shading"
tod_tz      = input.string("Europe/Rome", "Timezone", options=["Europe/Rome", "America/New_York", "UTC", "Europe/London", "Asia/Tokyo"], group=g_mr)

show_mr     = input.bool(true, "MR window (afternoon US)", group=g_mr)
mr_session  = input.session("1800-2200", "MR window session", group=g_mr, tooltip="Default 18:00–22:00 CEST = 12:00–16:00 ET (P3 mean-reversion zone).")
mr_color    = input.color(#000000, "MR color", group=g_mr)

show_eth_m  = input.bool(true, "ETH morning (Europe + US pre-mkt)", group=g_mr)
eth_m_sess  = input.session("1000-1530", "ETH morning session", group=g_mr, tooltip="Default 10:00–15:30 CEST = 04:00–09:30 ET (European cash + US pre-market).")
eth_m_color = input.color(#3b82f6, "ETH morning color", group=g_mr)

show_eth_n  = input.bool(true, "ETH night (post-US + Asia)", group=g_mr)
eth_n_sess  = input.session("2200-0200", "ETH night session", group=g_mr, tooltip="Default 22:00–02:00 CEST = 16:00–20:00 ET + Asia overnight (US post-market).")
eth_n_color = input.color(#7e22ce, "ETH night color", group=g_mr)

tod_alpha   = input.int(88, "Shading transparency (50=solid, 99=faint)", minval=50, maxval=99, group=g_mr)

// ── Top/Bottom extreme labels ─────────────────────────────────────────
g_lab        = "5. Top/Bottom rotation labels"
show_labels  = input.bool(true, "Show extreme rotation labels", group=g_lab)
label_thr    = input.float(1.0, "Min |RS| to label (σ)", minval=0.0, maxval=5.0, step=0.25, group=g_lab, tooltip="Only label transitions where the new top/bottom has |RS| above this threshold. Filters out noise when curves cross near zero.")
fractal_n    = input.int(2, "Fractal confirmation bars", minval=1, maxval=5, group=g_lab, tooltip="A new top/bottom must remain the leader for N consecutive bars before being labelled. Higher N = fewer but more meaningful labels (Williams-style fractal filter).")
label_size   = input.string("Normal", "Label size", options=["Tiny", "Small", "Normal", "Large"], group=g_lab)
label_alpha  = input.int(30, "Label transparency (0=solid, 80=very faint)", minval=0, maxval=80, group=g_lab, tooltip="Applied to the label background only. Text stays solid white for readability.")

// New group dedicated to the slot labels on the right margin (the 20
// per-ticker boxes), separate from the rotation labels above.
g_slot         = "6. Slot ticker labels (right margin)"
slot_size_str  = input.string("Small", "Slot label size", options=["Tiny", "Small", "Normal", "Large"], group=g_slot, tooltip="Pine font size for the 20 ticker boxes on the right margin. Smaller labels need less vertical space → tighter packing possible.")
slot_gap       = input.float(0.25, "Slot label min vertical gap (y units)", minval=0.05, maxval=1.0, step=0.01, group=g_slot, tooltip="Minimum vertical spacing between adjacent slot labels in chart y-units. This is HARD: labels never get closer than this. Increase if you still see visual overlap (pane-height-dependent). Decrease for tighter packing if your pane is tall enough.")

// ── ORB pre-market breakout (per stock) ───────────────────────────────
g_orb       = "7. Pre-market ORB breakout"
show_orb    = input.bool(true, "Show per-stock ORB breakout arrow", group=g_orb, tooltip="Adds an 'ORB' column to the ranking table: ↑ if the stock broke ABOVE its pre-market opening range, ↓ if it broke BELOW, · if no breakout yet. REQUIRES an intraday tf (5m/15m/...) — meaningless on daily/weekly. Forces extended-hours data so the pre-market window is available.")
orb_session = input.session("0400-0500", "ORB pre-market window", group=g_orb, tooltip="The pre-market window (in the timezone below) whose high/low define the opening range. Default 04:00–05:00 ET = the institutional low-volume positioning window used by the dispersion strategy.")
orb_tz      = input.string("America/New_York", "ORB timezone", options=["America/New_York", "Europe/Rome", "UTC"], group=g_orb)

sym0  = input.symbol("NVDA", "Slot 01", group=g_uni)
sym1  = input.symbol("AVGO", "Slot 02", group=g_uni)
sym2  = input.symbol("AMD",  "Slot 03", group=g_uni)
sym3  = input.symbol("INTC", "Slot 04", group=g_uni)
sym4  = input.symbol("QCOM", "Slot 05", group=g_uni)
sym5  = input.symbol("TXN",  "Slot 06", group=g_uni)
sym6  = input.symbol("ADI",  "Slot 07", group=g_uni)
sym7  = input.symbol("MCHP", "Slot 08", group=g_uni)
sym8  = input.symbol("NXPI", "Slot 09", group=g_uni)
sym9  = input.symbol("MPWR", "Slot 10", group=g_uni)
sym10 = input.symbol("AMAT", "Slot 11", group=g_uni)
sym11 = input.symbol("LRCX", "Slot 12", group=g_uni)
sym12 = input.symbol("KLAC", "Slot 13", group=g_uni)
sym13 = input.symbol("TSM",  "Slot 14", group=g_uni)
sym14 = input.symbol("MU",   "Slot 15", group=g_uni)
sym15 = input.symbol("WDC",  "Slot 16", group=g_uni)
sym16 = input.symbol("SNDK", "Slot 17", group=g_uni)
sym17 = input.symbol("STX",  "Slot 18", group=g_uni)
sym18 = input.symbol("MRVL", "Slot 19", group=g_uni)
sym19 = input.symbol("ON",   "Slot 20", group=g_uni)

// ───────────────────────── HELPERS ───────────────────────────
extract_ticker(string s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

// EWMA annualised vol over `span` bars (uses the SURROUNDING `close` —
// when called inside request.security(..., tf, ...) it resolves on the tf
// timeline, which is exactly what we want).
// EWMA volatility (per-bar, raw — no scaling). The unit is "σ of one
// bar's return at the security context's timeframe". Used INTERNALLY by
// the RS computation where both stock and benchmark sigmas are at the
// same tf → the units cancel out, the RS z-score is unitless.
//
// For DISPLAY purposes (the ranking table) we use a SEPARATE pull at
// "D" timeframe (see daily_sigma below) — that gives the proper
// close-to-close daily realised vol regardless of the scanner's tf.
ewma_vol_at(simple int span) =>
    ret   = (close - close[1]) / close[1]
    mu_r  = ta.ema(ret, span)
    var_r = ta.ema(math.pow(ret - mu_r, 2), span)
    math.sqrt(var_r)

pct_k(simple int kk) => close / close[kk] - 1

// ───────────────────────── SESSION HANDLING ──────────────────
// If use_eth, modify the symbol's session to include pre/post-market
// (session.extended). Otherwise leave it as the user typed (RTH default).
apply_session(simple string s) => use_eth ? ticker.modify(s, session=session.extended) : s

// Per-slot RS body — NO demean version, so sign(RS) = sign(current
// vol-adjusted outperformance vs SMH). This restores the index-decomp
// intuition: SMH = market-cap-weighted average of these stocks, so when
// SMH is up at least some components MUST be above zero (= outperforming
// SMH right now). With the original z-score-with-demean formula, the
// rolling mean of D absorbed each stock's historical outperformance bias,
// which made it possible for ALL curves to sit below zero even when SMH
// was rallying — counter to the index identity.
//
// Trade-off: dropping the demean means stocks that structurally always
// out- or under-perform SMH won't be centered at 0 on average. The
// signal now reads "currently above/below SMH on a vol-adjusted basis",
// which is what most traders intuitively expect from an RS chart.
rs_at_tf(simple int kk, simple int vw, simple int zw, series float bmom, series float bsigma) =>
    a_mom   = close / close[kk] - 1
    a_sigma = math.max(ewma_vol_at(vw), 1e-4)
    D       = a_mom / a_sigma - bmom / bsigma
    std_D   = ta.stdev(D, zw)
    std_D > 0 ? D / std_D : na

// SMH self-RS — full z-score (mean + std), same normalization as the
// per-slot RS so the two are visually COMPARABLE (both oscillate
// symmetrically around 0).
//   ps    = SMH pseudo-Sharpe at this tf-bar
//   z_ps  = (ps - mean(ps, zwin)) / std(ps, zwin)
//
// Interpretation: SMH line at +1.5 means "SMH itself is performing 1.5σ
// above its own rolling-year norm". Component RS curves at +1.5 mean
// "this stock is 1.5σ ahead of where the spread vs SMH usually sits".
// They use the same statistical machinery but encode different signals.
smh_self_rs(simple int kk, simple int vw, simple int zw) =>
    ps      = (close / close[kk] - 1) / math.max(ewma_vol_at(vw), 1e-4)
    mu_ps   = ta.sma(ps, zw)
    std_ps  = ta.stdev(ps, zw)
    std_ps > 0 ? (ps - mu_ps) / std_ps : na

// Daily realised vol estimator using REALIZED VARIANCE (RV) — the
// proper gold-standard high-frequency vol estimator. For each trading
// day d:
//   RV_d = Σ_i (log_ret_i)²    over all tf-bars i within day d
// Then we average RV over a rolling window of n_days and take √ to get
// the daily realised vol.
//
// This is what Merton (1980) and Andersen-Bollerslev (1998) recommend
// vs the approximate √(bars_per_day) scaling: realized variance uses
// ALL information from intraday returns and converges to integrated
// variance as the sampling frequency increases.
vol_disp_days = input.int(20, "Daily vol window (trading days)", minval=5, maxval=120, group=g_params, tooltip="Number of trailing trading days used to average daily realised variance (Σ r² within each day, smoothed over n days, then √).")

daily_rv_vol(simple int n_days) =>
    log_ret    = math.log(close / close[1])
    ret_sq     = math.pow(log_ret, 2)
    is_new_day = ta.change(time("D")) != 0

    // Intraday accumulator of squared returns. Resets at each new day.
    var float intraday_rv = 0.0
    intraday_rv := is_new_day ? ret_sq : intraday_rv + ret_sq

    // History buffer of completed daily RVs (last n_days). On a new-day
    // bar we snapshot intraday_rv[1] — i.e., the FULL accumulated sum
    // from the previous day (the last bar of yesterday holds the total
    // before today's bar resets the accumulator).
    var array<float> hist = array.new<float>()
    if is_new_day
        prev_day_rv = intraday_rv[1]
        if not na(prev_day_rv) and prev_day_rv > 0
            array.push(hist, prev_day_rv)
            if array.size(hist) > n_days
                array.shift(hist)

    avg_var = array.size(hist) > 0 ? array.avg(hist) : float(na)
    math.sqrt(avg_var)

// Pre-market ORB breakout direction for the symbol in the security
// context. Within the ORB session window we accumulate the high/low of
// the opening range; once the window closes we check whether price has
// broken ABOVE the range high (+1 ↑) or BELOW the range low (-1 ↓).
// State resets each new day. Returns +1 / -1 / 0 (no breakout yet).
// Needs intraday tf + extended-hours data (slots are fetched extended
// whenever show_orb is on — see slot_session()).
orb_dir(simple string orb_sess, simple string tz_) =>
    in_win = not na(time(tf, orb_sess, tz_))
    is_new = ta.change(time("D")) != 0
    var float orb_hi = na
    var float orb_lo = na
    var int   d_     = 0
    if is_new
        orb_hi := na
        orb_lo := na
        d_     := 0
    if in_win
        orb_hi := na(orb_hi) ? high : math.max(orb_hi, high)
        orb_lo := na(orb_lo) ? low  : math.min(orb_lo, low)
    else if not na(orb_hi) and d_ == 0
        d_ := close > orb_hi ? 1 : close < orb_lo ? -1 : 0
    d_

// ───────────────────────── BENCH PRE-PULL ────────────────────
// Pull the 3 benchmark components at TF in a single security call:
//   b_mom        k-period return (numerator of bench side of D)
//   b_sigma      per-tf-bar EWMA stdev (denominator of bench side of D)
//   b_daily_vol  daily realised vol via RV (displayed in info box)
bench_resolved = apply_session(benchmark_sym)
[b_mom, b_sigma, b_daily_vol] = request.security(bench_resolved, tf, [pct_k(k), math.max(ewma_vol_at(vol_win), 1e-4), daily_rv_vol(vol_disp_days)], lookahead=barmerge.lookahead_off)

// (smh_self_rs request.security removed — SMH is now rendered as the
//  trend-coloured zero baseline, no separate curve needed.)

// ───────────────────────── PER-SLOT RS ───────────────────────
// Functions used inside request.security expressions are now defined
// EARLIER in the script (near the other tf-helpers), so they're already
// in scope when first called. Pine v6 requires forward declarations.

// Slot session resolver: force extended hours when ETH is on OR when
// ORB arrows are shown (the pre-market window needs extended data).
slot_session(simple string s) => (use_eth or show_orb) ? ticker.modify(s, session=session.extended) : s

// Returns (rs, daily_vol_rv, orb_dir) tuple from a SINGLE request.security
// call (stays within Pine's 40-call budget: 1 bench + 20 slots = 21).
slot_rs_sig(simple string sym) =>
    if sym == ""
        [float(na), float(na), int(na)]
    else
        request.security(slot_session(sym), tf, [rs_at_tf(k, vol_win, zwin, b_mom, b_sigma), daily_rv_vol(vol_disp_days), orb_dir(orb_session, orb_tz)], lookahead=barmerge.lookahead_off)

[rs0,  sig0,  orb0]  = slot_rs_sig(sym0)
[rs1,  sig1,  orb1]  = slot_rs_sig(sym1)
[rs2,  sig2,  orb2]  = slot_rs_sig(sym2)
[rs3,  sig3,  orb3]  = slot_rs_sig(sym3)
[rs4,  sig4,  orb4]  = slot_rs_sig(sym4)
[rs5,  sig5,  orb5]  = slot_rs_sig(sym5)
[rs6,  sig6,  orb6]  = slot_rs_sig(sym6)
[rs7,  sig7,  orb7]  = slot_rs_sig(sym7)
[rs8,  sig8,  orb8]  = slot_rs_sig(sym8)
[rs9,  sig9,  orb9]  = slot_rs_sig(sym9)
[rs10, sig10, orb10] = slot_rs_sig(sym10)
[rs11, sig11, orb11] = slot_rs_sig(sym11)
[rs12, sig12, orb12] = slot_rs_sig(sym12)
[rs13, sig13, orb13] = slot_rs_sig(sym13)
[rs14, sig14, orb14] = slot_rs_sig(sym14)
[rs15, sig15, orb15] = slot_rs_sig(sym15)
[rs16, sig16, orb16] = slot_rs_sig(sym16)
[rs17, sig17, orb17] = slot_rs_sig(sym17)
[rs18, sig18, orb18] = slot_rs_sig(sym18)
[rs19, sig19, orb19] = slot_rs_sig(sym19)

// ───────────────────────── AGGREGATION ───────────────────────
N_SYMS = 20

rs_arr = array.new<float>()
array.push(rs_arr, rs0)
array.push(rs_arr, rs1)
array.push(rs_arr, rs2)
array.push(rs_arr, rs3)
array.push(rs_arr, rs4)
array.push(rs_arr, rs5)
array.push(rs_arr, rs6)
array.push(rs_arr, rs7)
array.push(rs_arr, rs8)
array.push(rs_arr, rs9)
array.push(rs_arr, rs10)
array.push(rs_arr, rs11)
array.push(rs_arr, rs12)
array.push(rs_arr, rs13)
array.push(rs_arr, rs14)
array.push(rs_arr, rs15)
array.push(rs_arr, rs16)
array.push(rs_arr, rs17)
array.push(rs_arr, rs18)
array.push(rs_arr, rs19)

// Per-slot historical vol (EWMA annualised at tf), parallel to rs_arr.
sig_arr = array.new<float>()
array.push(sig_arr, sig0)
array.push(sig_arr, sig1)
array.push(sig_arr, sig2)
array.push(sig_arr, sig3)
array.push(sig_arr, sig4)
array.push(sig_arr, sig5)
array.push(sig_arr, sig6)
array.push(sig_arr, sig7)
array.push(sig_arr, sig8)
array.push(sig_arr, sig9)
array.push(sig_arr, sig10)
array.push(sig_arr, sig11)
array.push(sig_arr, sig12)
array.push(sig_arr, sig13)
array.push(sig_arr, sig14)
array.push(sig_arr, sig15)
array.push(sig_arr, sig16)
array.push(sig_arr, sig17)
array.push(sig_arr, sig18)
array.push(sig_arr, sig19)

// Per-slot ORB breakout direction (+1 ↑ / -1 ↓ / 0 none), parallel.
orb_arr = array.new<int>()
array.push(orb_arr, orb0)
array.push(orb_arr, orb1)
array.push(orb_arr, orb2)
array.push(orb_arr, orb3)
array.push(orb_arr, orb4)
array.push(orb_arr, orb5)
array.push(orb_arr, orb6)
array.push(orb_arr, orb7)
array.push(orb_arr, orb8)
array.push(orb_arr, orb9)
array.push(orb_arr, orb10)
array.push(orb_arr, orb11)
array.push(orb_arr, orb12)
array.push(orb_arr, orb13)
array.push(orb_arr, orb14)
array.push(orb_arr, orb15)
array.push(orb_arr, orb16)
array.push(orb_arr, orb17)
array.push(orb_arr, orb18)
array.push(orb_arr, orb19)

name_arr = array.new<string>()
array.push(name_arr, extract_ticker(sym0))
array.push(name_arr, extract_ticker(sym1))
array.push(name_arr, extract_ticker(sym2))
array.push(name_arr, extract_ticker(sym3))
array.push(name_arr, extract_ticker(sym4))
array.push(name_arr, extract_ticker(sym5))
array.push(name_arr, extract_ticker(sym6))
array.push(name_arr, extract_ticker(sym7))
array.push(name_arr, extract_ticker(sym8))
array.push(name_arr, extract_ticker(sym9))
array.push(name_arr, extract_ticker(sym10))
array.push(name_arr, extract_ticker(sym11))
array.push(name_arr, extract_ticker(sym12))
array.push(name_arr, extract_ticker(sym13))
array.push(name_arr, extract_ticker(sym14))
array.push(name_arr, extract_ticker(sym15))
array.push(name_arr, extract_ticker(sym16))
array.push(name_arr, extract_ticker(sym17))
array.push(name_arr, extract_ticker(sym18))
array.push(name_arr, extract_ticker(sym19))

// Parallel array of per-slot line colors (used to colour the Symbol
// column of the ranking table to match the on-chart curve).
col_arr = array.new<color>()
array.push(col_arr, #1d4ed8)
array.push(col_arr, #15803d)
array.push(col_arr, #b91c1c)
array.push(col_arr, #ea580c)
array.push(col_arr, #7e22ce)
array.push(col_arr, #0891b2)
array.push(col_arr, #be185d)
array.push(col_arr, #65a30d)
array.push(col_arr, #ca8a04)
array.push(col_arr, #1e3a8a)
array.push(col_arr, #047857)
array.push(col_arr, #be123c)
array.push(col_arr, #6d28d9)
array.push(col_arr, #0f766e)
array.push(col_arr, #92400e)
array.push(col_arr, #4338ca)
array.push(col_arr, #581c87)
array.push(col_arr, #c026d3)
array.push(col_arr, #831843)
array.push(col_arr, #166534)

// Universe mean RS + cross-sectional standard deviation (rolling, no
// lookahead: both are computed from the 20 RS values AT THE CURRENT BAR).
mean_acc = 0.0
n_valid  = 0
for i = 0 to N_SYMS - 1
    v = array.get(rs_arr, i)
    if not na(v)
        mean_acc := mean_acc + v
        n_valid  := n_valid + 1
mean_rs = n_valid > 0 ? mean_acc / n_valid : na

// Cross-sectional stdev of the 20 RS values at this bar
std_acc = 0.0
if n_valid > 1
    for i = 0 to N_SYMS - 1
        v = array.get(rs_arr, i)
        if not na(v)
            std_acc := std_acc + math.pow(v - mean_rs, 2)
xs_std = n_valid > 1 ? math.sqrt(std_acc / (n_valid - 1)) : na

// ── Identify current top / bottom slot at every bar ──────────
// Series-typed loop so `top_val`/`bot_val` are first-class series we
// can compare across bars to detect changes. Pine v6 strict typing
// requires explicit `float`/`int` declarations when initialising to na.
float top_val = na
int   top_idx = -1
float bot_val = na
int   bot_idx = -1
for i = 0 to N_SYMS - 1
    v = array.get(rs_arr, i)
    if not na(v)
        if na(top_val) or v > top_val
            top_val := v
            top_idx := i
        if na(bot_val) or v < bot_val
            bot_val := v
            bot_idx := i

// ── Fractal-confirmed rotation labels ────────────────────────
// Track how long the current top/bot has held its position. Only place
// a label when the new leader has held for `fractal_n` consecutive
// confirmed bars AND its |RS| exceeds `label_thr` — filters out noisy
// 1-bar crossings near zero.
var int prev_top_idx     = -1
var int prev_bot_idx     = -1
var int top_streak       = 0
var int bot_streak       = 0
var int labelled_top_idx = -1   // last idx we already labelled
var int labelled_bot_idx = -1

if barstate.isconfirmed and show_labels
    // Streak counters
    if top_idx == prev_top_idx
        top_streak := top_streak + 1
    else
        top_streak := 1
    if bot_idx == prev_bot_idx
        bot_streak := bot_streak + 1
    else
        bot_streak := 1

    lbl_sz = label_size == "Tiny" ? size.tiny : label_size == "Small" ? size.small : label_size == "Large" ? size.large : size.normal

    // New top: confirmed only when fractal_n consecutive bars held
    if top_streak == fractal_n and top_idx != labelled_top_idx and top_idx >= 0 and not na(top_val) and math.abs(top_val) >= label_thr
        nm  = array.get(name_arr, top_idx)
        col = array.get(col_arr,  top_idx)
        label.new(bar_index, top_val, "▲ " + nm + "  " + str.tostring(top_val, "+#.##"), color=color.new(col, label_alpha), textcolor=#ffffff, style=label.style_label_down, size=lbl_sz)
        labelled_top_idx := top_idx

    // New bottom
    if bot_streak == fractal_n and bot_idx != labelled_bot_idx and bot_idx >= 0 and not na(bot_val) and math.abs(bot_val) >= label_thr
        nm  = array.get(name_arr, bot_idx)
        col = array.get(col_arr,  bot_idx)
        label.new(bar_index, bot_val, "▼ " + nm + "  " + str.tostring(bot_val, "+#.##"), color=color.new(col, label_alpha), textcolor=#ffffff, style=label.style_label_up, size=lbl_sz)
        labelled_bot_idx := bot_idx

    prev_top_idx := top_idx
    prev_bot_idx := bot_idx

// ───────────────────────── PLOTS ─────────────────────────────
// ── Reference: universe mean RS + cross-sectional rolling bands ──
// NB: bands are computed PER BAR from the 20 RS values at THAT bar.
// No lookahead — values only depend on the current bar's RS_t.
// As the cross-sectional dispersion of the universe widens, the bands
// expand; as it narrows (a regime where most stocks move together), the
// bands contract.
// ── SMH baseline = zero, with trend-colored gradient ─────────
// SMH IS the benchmark, so by definition it sits at RS = 0 (every per-
// stock RS is the deviation from SMH). Instead of a separate SMH curve,
// render the zero line as a THICK colored band whose colour reflects
// SMH's own trend:
//   strong bull  → deep green
//   weak bull    → pale green
//   flat         → neutral grey
//   weak bear    → pale red
//   strong bear  → deep red
//
// Trend signal = b_mom / b_sigma  (SMH's pseudo-Sharpe at tf). Already
// pulled upstream with lookahead=barmerge.lookahead_off → historical
// values are locked once a tf-bar closes (NO REPAINTING). Only the
// currently forming bar updates in real time, which is expected.
// Gradient anchors:
//   trend  0  → pure white (SMH flat / neutral baseline)
//   trend +1 → medium green     (bull moderate)
//   trend +2 → dark green       (bull strong, saturation)
//   trend -1 → medium red       (bear moderate)
//   trend -2 → dark red         (bear strong, saturation)
smh_trend  = b_mom / b_sigma                          // ±1 to ±2 typical range
trend_clip = math.max(math.min(smh_trend, 2.0), -2.0)
trend_col  = trend_clip >= 0 ? color.from_gradient(trend_clip,  0.0, 2.0, #ffffff, #14532d) : color.from_gradient(trend_clip, -2.0, 0.0, #7f1d1d, #ffffff)

// (The actual SMH benchmark band is rendered at the END of the script
//  via two invisible anchor plots + a thick solid fill — placed last so
//  it sits in the foreground above all RS curves and σ-bands.)

// EMA-smoothed mean and dispersion → bands look like clean rolling
// envelopes instead of jagged cross-sectional re-sampling at each bar.
mean_rs_plot = band_smooth > 0 ? ta.ema(mean_rs, band_smooth) : mean_rs
xs_std_plot  = band_smooth > 0 ? ta.ema(xs_std,  band_smooth) : xs_std

// σ-band palette: forest/crimson (darker, more discreet).
COL_UP = #15803d
COL_DN = #b91c1c

// Plot the smoothed rolling band levels as series (so fill() can use them).
p_top3 = plot(mean_rs_plot + 3 * xs_std_plot, "+3σ xs band", color=color.new(COL_UP, 80), linewidth=1)
p_top2 = plot(mean_rs_plot + 2 * xs_std_plot, "+2σ xs band", color=color.new(COL_UP, 60), linewidth=1)
p_top1 = plot(mean_rs_plot + 1 * xs_std_plot, "+1σ xs band", color=color.new(COL_UP, 40), linewidth=1)
p_mean = plot(mean_rs_plot,                    "mean (anchor)", color=color.new(#1e293b, 100))  // invisible anchor
p_bot1 = plot(mean_rs_plot - 1 * xs_std_plot, "-1σ xs band", color=color.new(COL_DN, 40), linewidth=1)
p_bot2 = plot(mean_rs_plot - 2 * xs_std_plot, "-2σ xs band", color=color.new(COL_DN, 60), linewidth=1)
p_bot3 = plot(mean_rs_plot - 3 * xs_std_plot, "-3σ xs band", color=color.new(COL_DN, 80), linewidth=1)

// Gradient fills between successive band plots (paler near mean, darker
// at extremes). Negative side mirrors positive.
fill(p_mean, p_top1, color=show_zones ? color.new(COL_UP, 92) : na, title="mean..+1σ band")
fill(p_top1, p_top2, color=show_zones ? color.new(COL_UP, 80) : na, title="+1..+2σ band")
fill(p_top2, p_top3, color=show_zones ? color.new(COL_UP, 65) : na, title="+2..+3σ band")
fill(p_mean, p_bot1, color=show_zones ? color.new(COL_DN, 92) : na, title="mean..-1σ band")
fill(p_bot1, p_bot2, color=show_zones ? color.new(COL_DN, 80) : na, title="-1..-2σ band")
fill(p_bot2, p_bot3, color=show_zones ? color.new(COL_DN, 65) : na, title="-2..-3σ band")

// Per-slot RS — 20 visually distinct dark colors for light backgrounds.
// Spaced across the hue wheel so any two adjacent or distant lines can be
// told apart at a glance.
//   slot00 NVDA #1d4ed8 royal blue
//   slot01 AVGO #15803d emerald green
//   slot02 AMD  #b91c1c crimson red
//   slot03 INTC #ea580c warm orange
//   slot04 QCOM #7e22ce deep purple
//   slot05 TXN  #0891b2 cyan
//   slot06 ADI  #be185d rose pink
//   slot07 MCHP #65a30d lime green
//   slot08 NXPI #ca8a04 amber gold
//   slot09 MPWR #1e3a8a navy
//   slot10 AMAT #047857 dark emerald
//   slot11 LRCX #be123c hot pink
//   slot12 KLAC #6d28d9 violet
//   slot13 TSM  #0f766e teal
//   slot14 MU   #92400e brown
//   slot15 WDC  #4338ca indigo
//   slot16 SNDK #581c87 deep purple
//   slot17 STX  #c026d3 magenta
//   slot18 MRVL #831843 dark rose
//   slot19 ON   #166534 forest
plot(rs0,  "Slot 01", color=#1d4ed8, linewidth=2)
plot(rs1,  "Slot 02", color=#15803d, linewidth=2)
plot(rs2,  "Slot 03", color=#b91c1c, linewidth=2)
plot(rs3,  "Slot 04", color=#ea580c, linewidth=2)
plot(rs4,  "Slot 05", color=#7e22ce, linewidth=2)
plot(rs5,  "Slot 06", color=#0891b2, linewidth=2)
plot(rs6,  "Slot 07", color=#be185d, linewidth=2)
plot(rs7,  "Slot 08", color=#65a30d, linewidth=2)
plot(rs8,  "Slot 09", color=#ca8a04, linewidth=2)
plot(rs9,  "Slot 10", color=#1e3a8a, linewidth=2)
plot(rs10, "Slot 11", color=#047857, linewidth=2)
plot(rs11, "Slot 12", color=#be123c, linewidth=2)
plot(rs12, "Slot 13", color=#6d28d9, linewidth=2)
plot(rs13, "Slot 14", color=#0f766e, linewidth=2)
plot(rs14, "Slot 15", color=#92400e, linewidth=2)
plot(rs15, "Slot 16", color=#4338ca, linewidth=2)
plot(rs16, "Slot 17", color=#581c87, linewidth=2)
plot(rs17, "Slot 18", color=#c026d3, linewidth=2)
plot(rs18, "Slot 19", color=#831843, linewidth=2)
plot(rs19, "Slot 20", color=#166534, linewidth=2)

// ───────────── Intraday session highlighters (3 windows) ─────
// Each window is checked via time(timeframe.period, session, tz) — Pine
// returns non-NA if the current bar's time falls inside the session.
// Multiple bgcolor() calls stack additively (transparency blends), so if
// two windows overlap you'll see a combined shade.
in_mr     = not na(time(timeframe.period, mr_session,  tod_tz))
in_eth_m  = not na(time(timeframe.period, eth_m_sess,  tod_tz))
in_eth_n  = not na(time(timeframe.period, eth_n_sess,  tod_tz))

bgcolor(show_mr    and in_mr    ? color.new(mr_color,    tod_alpha) : na, title="MR (afternoon US)")
bgcolor(show_eth_m and in_eth_m ? color.new(eth_m_color, tod_alpha) : na, title="ETH morning")
bgcolor(show_eth_n and in_eth_n ? color.new(eth_n_color, tod_alpha) : na, title="ETH night")

// ───────────── Dynamic ticker labels at right edge ───────────
// Pine v6 does NOT allow comma-separated declarations on the same line —
// each `var` must be its own statement.
var label lbl0  = na
var label lbl1  = na
var label lbl2  = na
var label lbl3  = na
var label lbl4  = na
var label lbl5  = na
var label lbl6  = na
var label lbl7  = na
var label lbl8  = na
var label lbl9  = na
var label lbl10 = na
var label lbl11 = na
var label lbl12 = na
var label lbl13 = na
var label lbl14 = na
var label lbl15 = na
var label lbl16 = na
var label lbl17 = na
var label lbl18 = na
var label lbl19 = na

// Slot label factory.
// `_y_pos`: where to PLACE the label (may be offset to avoid overlap)
// `_y_val`: the TRUE RS value shown in the text
// `_size`:  Pine size constant (size.tiny .. size.large)
make_rs_label(label _prev, float _y_pos, float _y_val, string _ticker, color _line_col, string _size) =>
    label.delete(_prev)
    sz = _size == "Tiny" ? size.tiny : _size == "Small" ? size.small : _size == "Large" ? size.large : size.normal
    na(_y_pos) ? na : label.new(bar_index + 1, _y_pos, _ticker + " " + str.tostring(_y_val, "+#.##"), color=_line_col, textcolor=#ffffff, style=label.style_label_left, size=sz)

if barstate.islast
    // Anti-overlap algorithm. When two slot labels would land at very
    // close y values (e.g., STX -0.51 / LRCX -0.62 / KLAC -0.65), the
    // boxes overlap visually. Fix: sort slots by RS descending, then
    // stack labels top-down enforcing a minimum vertical gap. The text
    // still displays the TRUE RS value; only the BOX POSITION is shifted.
    min_gap = slot_gap   // configurable via section 6
    sort_rs = array.copy(rs_arr)
    sort_idx = array.new<int>()
    for ii = 0 to N_SYMS - 1
        array.push(sort_idx, ii)

    // Selection sort by RS desc (NA goes to bottom)
    for ii = 0 to N_SYMS - 2
        max_i = ii
        for jj = ii + 1 to N_SYMS - 1
            vi = array.get(sort_rs, max_i)
            vj = array.get(sort_rs, jj)
            if (na(vi) and not na(vj)) or (not na(vi) and not na(vj) and vj > vi)
                max_i := jj
        if max_i != ii
            tmpv = array.get(sort_rs,  ii)
            tmpi = array.get(sort_idx, ii)
            array.set(sort_rs,  ii, array.get(sort_rs,  max_i))
            array.set(sort_idx, ii, array.get(sort_idx, max_i))
            array.set(sort_rs,  max_i, tmpv)
            array.set(sort_idx, max_i, tmpi)

    // Compute adjusted y per original slot index
    adj_y = array.new<float>(N_SYMS, na)
    float last_y = 1e9
    for rank = 0 to N_SYMS - 1
        v   = array.get(sort_rs,  rank)
        idx = array.get(sort_idx, rank)
        if not na(v)
            y_placed = math.min(v, last_y - min_gap)
            array.set(adj_y, idx, y_placed)
            last_y := y_placed

    // Now create the labels with adj_y (position) but show true rs value
    lbl0  := make_rs_label(lbl0,  array.get(adj_y, 0),  rs0,  extract_ticker(sym0),  #1d4ed8, slot_size_str)
    lbl1  := make_rs_label(lbl1,  array.get(adj_y, 1),  rs1,  extract_ticker(sym1),  #15803d, slot_size_str)
    lbl2  := make_rs_label(lbl2,  array.get(adj_y, 2),  rs2,  extract_ticker(sym2),  #b91c1c, slot_size_str)
    lbl3  := make_rs_label(lbl3,  array.get(adj_y, 3),  rs3,  extract_ticker(sym3),  #ea580c, slot_size_str)
    lbl4  := make_rs_label(lbl4,  array.get(adj_y, 4),  rs4,  extract_ticker(sym4),  #7e22ce, slot_size_str)
    lbl5  := make_rs_label(lbl5,  array.get(adj_y, 5),  rs5,  extract_ticker(sym5),  #0891b2, slot_size_str)
    lbl6  := make_rs_label(lbl6,  array.get(adj_y, 6),  rs6,  extract_ticker(sym6),  #be185d, slot_size_str)
    lbl7  := make_rs_label(lbl7,  array.get(adj_y, 7),  rs7,  extract_ticker(sym7),  #65a30d, slot_size_str)
    lbl8  := make_rs_label(lbl8,  array.get(adj_y, 8),  rs8,  extract_ticker(sym8),  #ca8a04, slot_size_str)
    lbl9  := make_rs_label(lbl9,  array.get(adj_y, 9),  rs9,  extract_ticker(sym9),  #1e3a8a, slot_size_str)
    lbl10 := make_rs_label(lbl10, array.get(adj_y, 10), rs10, extract_ticker(sym10), #047857, slot_size_str)
    lbl11 := make_rs_label(lbl11, array.get(adj_y, 11), rs11, extract_ticker(sym11), #be123c, slot_size_str)
    lbl12 := make_rs_label(lbl12, array.get(adj_y, 12), rs12, extract_ticker(sym12), #6d28d9, slot_size_str)
    lbl13 := make_rs_label(lbl13, array.get(adj_y, 13), rs13, extract_ticker(sym13), #0f766e, slot_size_str)
    lbl14 := make_rs_label(lbl14, array.get(adj_y, 14), rs14, extract_ticker(sym14), #92400e, slot_size_str)
    lbl15 := make_rs_label(lbl15, array.get(adj_y, 15), rs15, extract_ticker(sym15), #4338ca, slot_size_str)
    lbl16 := make_rs_label(lbl16, array.get(adj_y, 16), rs16, extract_ticker(sym16), #581c87, slot_size_str)
    lbl17 := make_rs_label(lbl17, array.get(adj_y, 17), rs17, extract_ticker(sym17), #c026d3, slot_size_str)
    lbl18 := make_rs_label(lbl18, array.get(adj_y, 18), rs18, extract_ticker(sym18), #831843, slot_size_str)
    lbl19 := make_rs_label(lbl19, array.get(adj_y, 19), rs19, extract_ticker(sym19), #166534, slot_size_str)

// ───────────────────────── RANKING TABLE ─────────────────────
if barstate.islast
    sorted_rs   = array.copy(rs_arr)
    sorted_name = array.copy(name_arr)
    sorted_col  = array.copy(col_arr)
    sorted_sig  = array.copy(sig_arr)
    sorted_orb  = array.copy(orb_arr)

    // Selection sort by RS desc — swap rs, name, col, sigma AND orb together
    for i = 0 to N_SYMS - 2
        max_idx = i
        for j = i + 1 to N_SYMS - 1
            vi = array.get(sorted_rs, max_idx)
            vj = array.get(sorted_rs, j)
            if na(vi) and not na(vj)
                max_idx := j
            else if not na(vj) and not na(vi) and vj > vi
                max_idx := j
        if max_idx != i
            tmp_v = array.get(sorted_rs,   i)
            tmp_n = array.get(sorted_name, i)
            tmp_c = array.get(sorted_col,  i)
            tmp_s = array.get(sorted_sig,  i)
            tmp_o = array.get(sorted_orb,  i)
            array.set(sorted_rs,   i, array.get(sorted_rs,   max_idx))
            array.set(sorted_name, i, array.get(sorted_name, max_idx))
            array.set(sorted_col,  i, array.get(sorted_col,  max_idx))
            array.set(sorted_sig,  i, array.get(sorted_sig,  max_idx))
            array.set(sorted_orb,  i, array.get(sorted_orb,  max_idx))
            array.set(sorted_rs,   max_idx, tmp_v)
            array.set(sorted_name, max_idx, tmp_n)
            array.set(sorted_col,  max_idx, tmp_c)
            array.set(sorted_sig,  max_idx, tmp_s)
            array.set(sorted_orb,  max_idx, tmp_o)

    n_active = 0
    for i = 0 to N_SYMS - 1
        if not na(array.get(sorted_rs, i))
            n_active := n_active + 1

    // Ranking table — Rank cell tinted green/red for top/bottom; Symbol
    // cell painted with the slot's plot color so you can match curve→row
    // visually at a glance. Last column = pre-market ORB breakout arrow
    // (only filled when show_orb; otherwise it stays blank).
    var table tb = table.new(position.top_right, 5, 22, bgcolor=#ffffff, border_width=1, border_color=#cbd5e1)
    table.cell(tb, 0, 0, "Rank",   text_color=#ffffff, bgcolor=#0f172a, text_size=size.normal)
    table.cell(tb, 1, 0, "Symbol", text_color=#ffffff, bgcolor=#0f172a, text_size=size.normal)
    table.cell(tb, 2, 0, "RS vs " + extract_ticker(benchmark_sym) + " @ " + tf, text_color=#ffffff, bgcolor=#0f172a, text_size=size.normal)
    table.cell(tb, 3, 0, "σ day %", text_color=#ffffff, bgcolor=#0f172a, text_size=size.normal)
    if show_orb
        table.cell(tb, 4, 0, "ORB", text_color=#ffffff, bgcolor=#0f172a, text_size=size.normal)

    for i = 0 to N_SYMS - 1
        nm = array.get(sorted_name, i)
        rv = array.get(sorted_rs, i)
        cl = array.get(sorted_col,  i)
        sg = array.get(sorted_sig,  i)
        ob = array.get(sorted_orb,  i)
        is_top    = i < top_n and not na(rv)
        is_bottom = i >= n_active - top_n and i < n_active and not na(rv)
        rank_bg  = is_top ? #15803d : is_bottom ? #b91c1c : #ffffff
        rank_tc  = is_top or is_bottom ? #ffffff : #0f172a
        rs_bg    = is_top ? #15803d : is_bottom ? #b91c1c : #ffffff
        rs_tc    = is_top or is_bottom ? #ffffff : #0f172a
        table.cell(tb, 0, i + 1, str.tostring(i + 1), bgcolor=rank_bg, text_color=rank_tc, text_size=size.normal)
        // Symbol cell ALWAYS painted with the slot's curve colour, white bold text
        table.cell(tb, 1, i + 1, nm, bgcolor=cl, text_color=#ffffff, text_size=size.normal)
        table.cell(tb, 2, i + 1, na(rv) ? "n/a" : str.tostring(rv, "+#.##"), bgcolor=rs_bg, text_color=rs_tc, text_size=size.normal)
        // σ column — daily realised vol, in %
        table.cell(tb, 3, i + 1, na(sg) ? "n/a" : str.tostring(sg * 100, "#.#") + "%", bgcolor=#ffffff, text_color=#0f172a, text_size=size.normal)
        // ORB column — pre-market breakout arrow (↑ green / ↓ red / · grey)
        if show_orb
            orb_txt = na(ob) ? "·" : ob > 0 ? "▲" : ob < 0 ? "▼" : "·"
            orb_tc  = na(ob) or ob == 0 ? #94a3b8 : ob > 0 ? #15803d : #b91c1c
            table.cell(tb, 4, i + 1, orb_txt, bgcolor=#ffffff, text_color=orb_tc, text_size=size.large)

// ───────── SMH benchmark band — FOREGROUND, opaque, thick ─────────
// Rendered LAST so the band sits on top of all RS curves and σ-bands.
// Two invisible anchor plots at ±band_half create a polygon that fill()
// paints with the trend-derived colour. Fully opaque (no alpha) → it
// dominates the visual hierarchy as the primary baseline reference.
band_half     = input.float(0.2, "Benchmark baseline thickness (±)", minval=0.04, maxval=0.4, step=0.02, group=g_bench, tooltip="Half-height of the foreground benchmark band. 0.2 → total height 0.4 on the RS y-axis.")
smh_band_top  = plot(+band_half, "_smh_top", color=na, display=display.none, editable=false)
smh_band_bot  = plot(-band_half, "_smh_bot", color=na, display=display.none, editable=false)
fill(smh_band_top, smh_band_bot, color=trend_col, title="SMH benchmark band (trend coloured, foreground)")

// ── Extend the SMH band into the right margin (past the live bar) ──
// plot+fill only renders up to the last historical/live bar. To make
// the colored band continue into the future-bars area (where the slot
// labels and info box live), we draw a box.new at every live bar.
// Same colour as the live trend → the band visually flows past the
// curves all the way to the right edge.
band_extend_bars = input.int(5, "Benchmark band extension (bars past live)", minval=0, maxval=80, group=g_bench, tooltip="How many bars to extend the trend-coloured band beyond the live bar. The info box is placed at the end of this extension.")
var box smh_extension = na
if barstate.islast
    box.delete(smh_extension)
    smh_extension := box.new(
         bar_index, +band_half,
         bar_index + band_extend_bars, -band_half,
         bgcolor=trend_col,
         border_color=color.new(trend_col, 100))

// ── SMH info box — bar-anchored, sits on the extended band ────────
// Placed at bar_index + 12 with style_label_left so the box extends
// rightward INTO the right margin, past the slot labels (which sit at
// bar_index + 1 and span ~5-7 bars to the right). The extended SMH band
// (drawn below in the foreground section) reaches up to bar_index + 25,
// so the info box visually "rests on" the colored band.
var label info_lbl = na
if barstate.islast
    label.delete(info_lbl)
    top_nm = top_idx >= 0 ? array.get(name_arr, top_idx) : "—"
    bot_nm = bot_idx >= 0 ? array.get(name_arr, bot_idx) : "—"
    trend_str   = na(smh_trend) ? "—" : str.tostring(smh_trend, "+#.##") + "σ"
    top_str     = na(top_val)   ? "—" : str.tostring(top_val, "+#.##")
    bot_str     = na(bot_val)   ? "—" : str.tostring(bot_val, "+#.##")
    disp_str    = na(xs_std)    ? "—" : str.tostring(xs_std,  "#.##")
    bench_vol_s = na(b_daily_vol) ? "—" : str.tostring(b_daily_vol * 100, "#.#") + "%"
    ctx_text = extract_ticker(benchmark_sym) + "  •  trend " + trend_str + "\n" +
               "σ day  " + bench_vol_s + "\n" +
               "▲ " + top_nm + "  " + top_str + "\n" +
               "▼ " + bot_nm + "  " + bot_str + "\n" +
               "dispersion  " + disp_str
    info_lbl := label.new(
         bar_index + band_extend_bars, 0,
         ctx_text,
         color=#0f172a,
         textcolor=#ffffff,
         style=label.style_label_left,   // box extends to the RIGHT of anchor,
                                          // sitting flush with the band's end
         size=size.normal,
         textalign=text.align_left)

// ───────────────────────── ALERTS ────────────────────────────
alertcondition(ta.crossover(rs0, 1.0), title="Slot 1 RS enters top zone", message="Slot-1 RS crossed above +1σ vs benchmark")
````
