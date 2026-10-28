# Momentum Score

- url: https://www.tradingview.com/script/FPDjSTjd-Momentum-Score/
- type: indicator
- pine_id: PUB;d5cd9e60bb1b46fe99277da159bd470d
- version: 2.0

## Description

Momentum Score — Full Criteria Table
A comprehensive momentum scoring system that evaluates a stock across 13 weighted criteria and produces a single score out of 100. Designed for growth stock and momentum traders who want a fast, objective read on whether a stock is in a high-quality trending state.

How It Works
Each criterion is assigned a weight based on its importance to momentum quality. When a criterion passes, its weight is added to the total. The final score out of 100 tells you at a glance how strong the setup is:

≥ 80 — High momentum. Stock is exhibiting the full suite of leading characteristics.
60–79 — Developing. Momentum is building but not fully confirmed.
< 60 — Weak. Too many criteria failing for a high-conviction setup.


The 13 Criteria
Trend (32 pts)

Price > 20-day EMA (6 pts)
Price > 50-day EMA (8 pts)
Price > 200-day EMA (9 pts)
EMA Stack: 20 > 50 > 200 (9 pts)

Relative Strength (28 pts)

52-week RS vs benchmark (11 pts) — stock outperforming over 12 months
3-month RS vs benchmark (8 pts) — recent outperformance confirmed
Momentum Persistence (9 pts) — IBD-style weighted composite of 3m/6m/9m/12m returns (40/20/20/20 weighting)

Price Structure (20 pts)

Within 25% of 52-week high (8 pts)
At or near 52-week high — ATR-adjusted (8 pts)
Positive 6-month return (4 pts)

Volume (6 pts)

Up-day volume > down-day volume over 20 sessions (6 pts) — accumulation signal

Trend Intensity (8 pts)

EMA13 / EMA65 × 100 ≥ 108 (8 pts) — Qullamaggie filter requiring short-term trend to be 8%+ above long-term trend

Volatility / Tradability (6 pts)

20-day Average Daily Range ≥ 2% (6 pts) — ensures the stock has enough daily movement to be worth trading


ATR-Adjusted "Near High" Criterion
The near-52-week-high check uses ATR(20) as the yardstick rather than a fixed percentage. A stock passes if the gap between current price and its 52-week high is less than one ATR. This means a volatile $2 stock and a stable $50 stock are judged by the same standard — their own normal daily range — rather than an arbitrary 5% cutoff. Falls back to 5% if ATR is unavailable.

Benchmark Auto-Selection
The indicator detects the exchange of the chart symbol and selects the appropriate benchmark automatically:

ASX → XJO (S&P/ASX 200)
All other exchanges → SPX (S&P 500)

Relative strength calculations for both the 12-month and 3-month periods are computed against this benchmark.

Display
Results are shown in an overlay table with three columns: criterion name, pass/fail tick, and the underlying value. A toggle in settings lets you hide failing criteria to keep the table compact when a stock scores well.
Score colour mirrors the tier system — lime for high momentum, amber for developing, red for weak.

Alerts
Three alert conditions are included:

Score crosses above the high threshold (default 80)
Score crosses above the medium threshold (default 60)
Score drops back below the medium threshold

Both thresholds are configurable in the indicator settings.

Methodology Credits

EMA trend structure — standard momentum framework
RS composite weighting — inspired by IBD Relative Strength methodology
Trend Intensity (EMA13/EMA65) — based on Kristjan Qullamaggie's high-momentum scan filter
ATR-adjusted high proximity — volatility-normalised version of the classic "near new high" criterion

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════
// MOMENTUM SCORE — Full Criteria Table
// Mirrors @Jimmy_trader
//V1.0
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("Momentum Score", overlay=true, max_labels_count=1)

// ── Inputs ──────────────────────────────────────────────────────
var g_alert = "Alerts"
alert_thresh_high   = input.int(80, "Alert: Score ≥ (High)",    minval=50, maxval=100, group=g_alert)
alert_thresh_medium = input.int(60, "Alert: Score ≥ (Medium)",  minval=50, maxval=100, group=g_alert)

var g_disp = "Display"
show_failing = input.bool(true, "Show failing criteria", group=g_disp)
tbl_pos      = input.string("Top Right", "Table position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_disp)

// ── Benchmark: auto-switch by exchange ──────────────────────────
// Covers ASX, NYSE, NASDAQ, AMEX. Falls back to SPX for anything else.
//currentSymbol = str.contains(symbolExchange, "ASX") ? ASXIndexSymbol : USIndexSymbol
_ex = syminfo.prefix
_is_asx = str.contains(_ex, "ASX")  //== "ASX"
_bench_sym = _is_asx ? "ASX:XJO" : "SP:SPX"
_bench_label = _is_asx ? "XJO" : "SPX"

// ── EMAs ────────────────────────────────────────────────────────
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
ema13  = ta.ema(close, 13)
ema65  = ta.ema(close, 65)

// ── Benchmark closes ────────────────────────────────────────────
bench = request.security(_bench_sym, timeframe.period, close, ignore_invalid_symbol=true)

// ── ATR(20) ─────────────────────────────────────────────────────
atr20 = ta.atr(20)

// ── 52-week high (252 bars) ──────────────────────────────────────
high52 = ta.highest(high, 252)
low52  = ta.lowest(low,  252)

// ── Multi-period returns ─────────────────────────────────────────
ret3m  = (close - close[63])  / close[63]  * 100
ret6m  = (close - close[126]) / close[126] * 100
ret9m  = (close - close[189]) / close[189] * 100
ret12m = (close - close[252]) / close[252] * 100

// RS composite (IBD-style): 40% × 3m + 20% × 6m + 20% × 9m + 20% × 12m
rs_composite = ret3m * 0.40 + ret6m * 0.20 + ret9m * 0.20 + ret12m * 0.20

// ── Relative strength vs benchmark ──────────────────────────────
bench_ret12m = (bench - bench[252]) / bench[252] * 100
bench_ret3m  = (bench - bench[63])  / bench[63]  * 100
rs12m = ret12m - bench_ret12m
rs3m  = ret3m  - bench_ret3m

// ── Volume: up-day vs down-day (last 20 bars) ────────────────────
var float up_vol = 0.0
var float dn_vol = 0.0
up_vol := math.sum(close >= open ? volume : 0, 20)
dn_vol := math.sum(close <  open ? volume : 0, 20)

// ── ADR% (20-day avg daily range) ────────────────────────────────
adr = ta.sma((high - low) / low * 100, 20)

// ── Trend Intensity ──────────────────────────────────────────────
ti = ema65 > 0 ? (ema13 / ema65) * 100 : na

// ── Criteria evaluation ─────────────────────────────────────────
c_ema20    = close > ema20
c_ema50    = close > ema50
c_ema200   = close > ema200
c_ema_stk  = ema20 > ema50 and ema50 > ema200
c_rs52w    = rs12m > 0
c_rs3m     = rs3m  > 0
pct_hi     = (close / high52 - 1) * 100
c_near_hi  = pct_hi >= -25
gap_to_hi  = high52 - close
c_new_hi   = not na(atr20) ? gap_to_hi <= atr20 : pct_hi >= -5  // ATR-adjusted, fallback 5%
c_vol      = up_vol > dn_vol
c_pos6m    = ret6m > 0
c_rs_mom   = rs_composite > 0
c_ti       = not na(ti) and ti >= 108
c_adr      = adr >= 2.0

// ── Weights (sum = 100) ──────────────────────────────────────────
w_ema20   = 6
w_ema50   = 8
w_ema200  = 9
w_ema_stk = 9
w_rs52w   = 11
w_rs3m    = 8
w_near_hi = 8
w_new_hi  = 8
w_vol     = 6
w_pos6m   = 4
w_rs_mom  = 9
w_ti      = 8
w_adr     = 6

// ── Score ────────────────────────────────────────────────────────
score = (c_ema20   ? w_ema20   : 0)
      + (c_ema50   ? w_ema50   : 0)
      + (c_ema200  ? w_ema200  : 0)
      + (c_ema_stk ? w_ema_stk : 0)
      + (c_rs52w   ? w_rs52w   : 0)
      + (c_rs3m    ? w_rs3m    : 0)
      + (c_near_hi ? w_near_hi : 0)
      + (c_new_hi  ? w_new_hi  : 0)
      + (c_vol     ? w_vol     : 0)
      + (c_pos6m   ? w_pos6m   : 0)
      + (c_rs_mom  ? w_rs_mom  : 0)
      + (c_ti      ? w_ti      : 0)
      + (c_adr     ? w_adr     : 0)

// ── Score colour ─────────────────────────────────────────────────
score_col = score >= 80 ? color.new(#c8ff00, 0)
          : score >= 60 ? color.new(#ff8c00, 0)
          : color.new(#ff3a3a, 0)

// ── Table ────────────────────────────────────────────────────────
var tbl_position = tbl_pos == "Top Right"    ? position.top_right
                 : tbl_pos == "Top Left"     ? position.top_left
                 : tbl_pos == "Bottom Right" ? position.bottom_right
                 : position.bottom_left

var table t = table.new(tbl_position, 3, 16,
     bgcolor=color.new(#111111, 10),
     border_color=color.new(#222222, 0),
     border_width=1,
     frame_color=color.new(#222222, 0),
     frame_width=1)

// helpers
C_HEAD  = color.new(#1a1a1a, 0)
C_ROW   = color.new(#111111, 0)
C_PASS  = color.new(#c8ff00, 0)
C_FAIL  = color.new(#ff3a3a, 0)
C_MUTED = color.new(#dddbdb, 0)
C_TEXT  = color.new(#fffdfd, 0)
C_SCORE = score_col

_tick  (pass) => pass ? "✓" : "✗"
_pcol  (pass) => pass ? C_PASS : C_FAIL
_na_str(v, decimals) => not na(v) ? str.tostring(v, decimals == 1 ? "#.#" : "#.##") : "n/a"

if barstate.islast
    // ── Header row ──
    table.cell(t, 0, 0, "MOMENTUM SCORE", text_color=C_TEXT,    bgcolor=C_HEAD, text_size=size.small)
    table.cell(t, 1, 0, str.tostring(score) + " / 100",         text_color=C_SCORE, bgcolor=C_HEAD, text_size=size.small)
    table.cell(t, 2, 0, syminfo.ticker + " vs " + _bench_label, text_color=C_MUTED, bgcolor=C_HEAD, text_size=size.small)

    // ── Column headers ──
    table.cell(t, 0, 1, "CRITERION",  text_color=C_MUTED, bgcolor=C_HEAD, text_size=size.small)
    table.cell(t, 1, 1, "RESULT",     text_color=C_MUTED, bgcolor=C_HEAD, text_size=size.small)
    table.cell(t, 2, 1, "VALUE",      text_color=C_MUTED, bgcolor=C_HEAD, text_size=size.small)

    // Row helper — only render if passing OR show_failing = true
    // Row 2: Price > EMA20
    if c_ema20 or show_failing
        table.cell(t, 0, 2, "Price > EMA20",   text_color=C_TEXT,         bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 2, _tick(c_ema20),    text_color=_pcol(c_ema20), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 2, _na_str(close,2) + " / " + _na_str(ema20,2), text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 3: Price > EMA50
    if c_ema50 or show_failing
        table.cell(t, 0, 3, "Price > EMA50",   text_color=C_TEXT,         bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 3, _tick(c_ema50),    text_color=_pcol(c_ema50), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 3, _na_str(close,2) + " / " + _na_str(ema50,2), text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 4: Price > EMA200
    if c_ema200 or show_failing
        table.cell(t, 0, 4, "Price > EMA200",  text_color=C_TEXT,          bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 4, _tick(c_ema200),   text_color=_pcol(c_ema200), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 4, _na_str(close,2) + " / " + _na_str(ema200,2), text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 5: EMA Stack
    if c_ema_stk or show_failing
        table.cell(t, 0, 5, "EMA Stack 20>50>200", text_color=C_TEXT,          bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 5, _tick(c_ema_stk),      text_color=_pcol(c_ema_stk), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 5, _na_str(ema20,2) + " / " + _na_str(ema50,2) + " / " + _na_str(ema200,2), text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 6: RS 52w
    if c_rs52w or show_failing
        _rs12_str = not na(rs12m) ? (rs12m >= 0 ? "+" : "") + _na_str(rs12m,1) + "% vs " + _bench_label + " (12m)" : "n/a"
        table.cell(t, 0, 6, "RS 52-week",     text_color=C_TEXT,         bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 6, _tick(c_rs52w),   text_color=_pcol(c_rs52w), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 6, _rs12_str,        text_color=C_MUTED,        bgcolor=C_ROW, text_size=size.tiny)

    // Row 7: RS 3m
    if c_rs3m or show_failing
        _rs3_str = not na(rs3m) ? (rs3m >= 0 ? "+" : "") + _na_str(rs3m,1) + "% vs " + _bench_label + " (3m)" : "n/a"
        table.cell(t, 0, 7, "RS 3-month",    text_color=C_TEXT,        bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 7, _tick(c_rs3m),   text_color=_pcol(c_rs3m), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 7, _rs3_str,        text_color=C_MUTED,       bgcolor=C_ROW, text_size=size.tiny)

    // Row 8: Within 25% of 52w High
    if c_near_hi or show_failing
        table.cell(t, 0, 8, "Within 25% of 52w High", text_color=C_TEXT,          bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 8, _tick(c_near_hi),          text_color=_pcol(c_near_hi), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 8, _na_str(pct_hi,1) + "% from high " + _na_str(high52,2), text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 9: Near 52w High (ATR-adjusted)
    if c_new_hi or show_failing
        _nh_str = not na(atr20)
             ? "Gap " + _na_str(gap_to_hi,3) + " vs ATR " + _na_str(atr20,3)
             : _na_str(pct_hi,1) + "% (fallback 5%)"
        table.cell(t, 0, 9, "At/Near 52w High (ATR)", text_color=C_TEXT,          bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 9, _tick(c_new_hi),           text_color=_pcol(c_new_hi), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 9, _nh_str,                   text_color=C_MUTED,         bgcolor=C_ROW, text_size=size.tiny)

    // Row 10: Volume
    if c_vol or show_failing
        table.cell(t, 0, 10, "Up-Vol > Down-Vol", text_color=C_TEXT,       bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 10, _tick(c_vol),         text_color=_pcol(c_vol), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 10, "Up: " + _na_str(up_vol/1000000,1) + "M  Dn: " + _na_str(dn_vol/1000000,1) + "M", text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 11: Positive 6m return
    if c_pos6m or show_failing
        table.cell(t, 0, 11, "Positive 6m Return", text_color=C_TEXT,         bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 11, _tick(c_pos6m),        text_color=_pcol(c_pos6m), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 11, (ret6m >= 0 ? "+" : "") + _na_str(ret6m,1) + "%", text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 12: Momentum Persistence
    if c_rs_mom or show_failing
        table.cell(t, 0, 12, "Momentum Persistence", text_color=C_TEXT,          bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 12, _tick(c_rs_mom),         text_color=_pcol(c_rs_mom), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 12, "RS comp: " + (rs_composite >= 0 ? "+" : "") + _na_str(rs_composite,1) + "%", text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 13: Trend Intensity
    if c_ti or show_failing
        table.cell(t, 0, 13, "Trend Intensity ≥ 108", text_color=C_TEXT,      bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 13, _tick(c_ti),              text_color=_pcol(c_ti), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 13, "TI: " + _na_str(ti,1),  text_color=C_MUTED,     bgcolor=C_ROW, text_size=size.tiny)

    // Row 14: ADR
    if c_adr or show_failing
        table.cell(t, 0, 14, "ADR ≥ 2%",    text_color=C_TEXT,       bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 1, 14, _tick(c_adr),   text_color=_pcol(c_adr), bgcolor=C_ROW, text_size=size.tiny)
        table.cell(t, 2, 14, "ADR: " + _na_str(adr,2) + "%", text_color=C_MUTED, bgcolor=C_ROW, text_size=size.tiny)

    // Row 15: Passed count
    passed = (c_ema20 ? 1 : 0) + (c_ema50 ? 1 : 0) + (c_ema200 ? 1 : 0) + (c_ema_stk ? 1 : 0)
           + (c_rs52w ? 1 : 0) + (c_rs3m  ? 1 : 0) + (c_near_hi ? 1 : 0) + (c_new_hi ? 1 : 0)
           + (c_vol   ? 1 : 0) + (c_pos6m ? 1 : 0) + (c_rs_mom  ? 1 : 0) + (c_ti ? 1 : 0)
           + (c_adr   ? 1 : 0)
    table.cell(t, 0, 15, "PASSED",                           text_color=C_MUTED,  bgcolor=C_HEAD, text_size=size.tiny)
    table.cell(t, 1, 15, str.tostring(passed) + " / 13",     text_color=C_SCORE,  bgcolor=C_HEAD, text_size=size.tiny)
    table.cell(t, 2, 15, score >= 80 ? "⬆ HIGH MOMENTUM" : score >= 60 ? "~ DEVELOPING" : "⬇ WEAK",
         text_color=C_SCORE, bgcolor=C_HEAD, text_size=size.tiny)

// ── Alerts ───────────────────────────────────────────────────────
alertcondition(score >= alert_thresh_high and score[1] < alert_thresh_high,  title="Momentum Score — High" , message="{{ticker}} momentum score crossed ")

alertcondition(score >= alert_thresh_medium and score[1] < alert_thresh_medium,     title="Momentum Score — Medium",     message="{{ticker}} momentum score crossed")

alertcondition(score < alert_thresh_medium  and score[1] >= alert_thresh_medium,     title="Momentum Score — Dropped Below Medium",     message="{{ticker}} momentum score dropped below")

// ── Plot score (hidden by default, needed for alert {{plot_0}}) ──
plot(score, "Momentum Score", color=score_col, display=display.data_window)
````
