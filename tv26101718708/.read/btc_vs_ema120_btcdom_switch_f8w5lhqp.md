# BTC vs EMA120 / BTCDOM Switch

- url: https://www.tradingview.com/script/F8w5LhQp-BTC-vs-EMA120-BTCDOM-Switch/
- type: indicator
- pine_id: PUB;52f7c2c831ba4a20bec1b8284e574901
- version: 1.0

## Description

A research backtest that compares a simple regime-switching rule against buy-and-hold BTC.

  The rule

  On each daily bar, the script computes BTCUSDT's 120-day EMA.

  - If yesterday's BTC close was above yesterday's EMA → today the strategy is long BTC.
  - Otherwise → today it holds BTCDOMUSDT.P (Binance BTC dominance perpetual).

  The signal is taken from the previous bar's close (close[1] > ema[1]) and applied to the current bar's return, so there is no look-ahead bias. The strategy is always 100%
  allocated to one of the two assets — never flat, never short.

  The intuition: when BTC is trending up, ride BTC. When BTC drops below the long-term trend, rotate into BTC dominance, which has historically tended to rise during alt-led
  drawdowns.

  Why indicator() and not strategy()

  TradingView's strategy engine can only place orders in the chart symbol. This script needs to alternate between BTCUSDT and BTCDOMUSDT.P, so it bypasses strategy() entirely
   and tracks two equity curves manually:

  - Strategy: starts at Initial Equity, multiplied each day by the held asset's close-to-close return.
  - HODL BTC: same start, multiplied each day by BTC's return.

  BTCDOM is fetched with request.security(..., lookahead=barmerge.lookahead_off).

  What you see

  - Two equity curves in the indicator pane: blue = Strategy, orange = HODL BTC. Both denominated in USDT, both starting at Initial Equity.
  - Faint background tint in the indicator pane: green when currently holding BTC, red when holding BTCDOM.
  - Switch markers drawn on the main price chart (force_overlay=true): green up-triangle below the candle when rotating into BTC, red down-triangle above when rotating into
  BTCDOM.
  - Top-right table — overall stats: Total Return, Max Drawdown, CAGR, Switch Count.
  - Bottom-right table — per-year breakdown: yearly return and intra-year max drawdown for both lines. Years marked with * are partial (the first one because the backtest
  doesn't start on Jan 1, the last one because it's YTD).

  Inputs

  - EMA Length — default 120
  - Backtest Start — default 2021-06-01 (the BTCDOMUSDT.P listing date)
  - Initial Equity — default 100

  How to use

  Attach to a BINANCE:BTCUSDT daily chart. Lower timeframes will run but the rule is designed for daily bars; intraday results should be treated with skepticism.

  Honest caveats

  - Zero transaction costs. No commission, no slippage, no funding. BTCDOM.P is a perpetual contract with funding settled every 8 hours, so real-world execution will deliver
  meaningfully lower returns than the equity curve shown.
  - Single regime, single parameter. BTCDOMUSDT.P only began trading in mid-2021. The full sample covers one BTC cycle. The 120-day EMA was not tuned, but the strategy has
  not been validated out-of-sample on a fundamentally different market regime — and one such regime is not enough to conclude anything robust.
  - Past performance is not predictive. This is a research tool for thinking about BTC vs. dominance, not a signal service and not financial advice.
  - The first calendar year is partial (begins at Backtest Start, not Jan 1) and the last is YTD. Both are flagged with * in the breakdown table.

## Source Code

````pine
//@version=6
// ============================================================
// BTC vs EMA120 / BTCDOM Switch Strategy Backtest
// ------------------------------------------------------------
// Signal:   BTC close > EMA(close, 120)  -> hold BTC
//           otherwise                    -> hold BTCDOMUSDT.P
// Execution: signal formed at bar i's close,
//            bar i+1 is settled by the held asset's close-to-close return
// Symbols:  BINANCE:BTCUSDT (chart) + BINANCE:BTCDOMUSDT.P (security)
// Range:    2021-06-01 to current (after BTCDOM.P launch)
// Costs:    none (0 commission, 0 slippage)
//
// Usage:    attach the script to a BINANCE:BTCUSDT 1D chart
// Outputs:  1) blue Strategy equity curve
//           2) orange HODL BTC equity curve
//           3) position background color (green=BTC, red=BTCDOM)
//           4) top-right: overall stats (Total Return / MaxDD / CAGR / Switches)
//           5) bottom-right: per-year breakdown (* = partial year)
// ============================================================
indicator("BTC vs EMA120 / BTCDOM Switch", overlay=false, max_bars_back=5000)

// ============================================================
// Inputs
// ============================================================
ema_length     = input.int(120, "EMA Length", minval=1)
start_date     = input.time(timestamp("2021-06-01 00:00 +0000"), "Backtest Start")
initial_equity = input.float(100.0, "Initial Equity", minval=0.01)

// ============================================================
// Helper functions (must be top-level — Pine v6 disallows function defs inside if blocks)
// ============================================================
f_pct(x) => str.tostring(x * 100, "#.##") + "%"

// ============================================================
// Per-year tracking state and arrays
// ============================================================
var array<int>   years            = array.new<int>()
var array<float> strat_year_ret   = array.new<float>()
var array<float> strat_year_dd    = array.new<float>()
var array<float> hodl_year_ret    = array.new<float>()
var array<float> hodl_year_dd     = array.new<float>()
var array<bool>  year_partial     = array.new<bool>()

var float strat_year_start_eq = na
var float hodl_year_start_eq  = na
var float strat_year_peak     = na
var float hodl_year_peak      = na
var float strat_year_maxdd    = 0.0
var float hodl_year_maxdd     = 0.0
var int   current_year        = na
var int   first_year_seen     = na  // marks the first year as partial

// ============================================================
// Data sources
// ============================================================
btcdom_close = request.security("BINANCE:BTCDOMUSDT.P", timeframe.period, close, lookahead=barmerge.lookahead_off)

// ============================================================
// Signal: hold BTC if previous bar's close > previous bar's EMA
// ============================================================
ema = ta.ema(close, ema_length)

// v6 has strict bool — must explicitly guard against na (EMA isn't stable for the first ema_length bars)
hold_btc = na(close[1]) or na(ema[1]) ? false : close[1] > ema[1]

// ============================================================
// Background color by position
// ============================================================
bgcolor(time >= start_date ? (hold_btc ? color.new(color.green, 90) : color.new(color.red, 90)) : na)

// ============================================================
// Equity curves + global peak/drawdown + switch count
// ============================================================
var float strat_eq    = initial_equity
var float hodl_eq     = initial_equity
var float strat_peak  = initial_equity
var float hodl_peak   = initial_equity
var float strat_maxdd = 0.0
var float hodl_maxdd  = 0.0
var int   switch_cnt  = 0

if time >= start_date and not na(close[1]) and not na(btcdom_close[1])
    // ----- 1) Year-boundary detection (MUST run before updating this bar's equity) -----
    bar_year = year
    if na(current_year)
        // First valid bar: initialize per-year state
        current_year        := bar_year
        first_year_seen     := bar_year
        strat_year_start_eq := strat_eq
        hodl_year_start_eq  := hodl_eq
        strat_year_peak     := strat_eq
        hodl_year_peak      := hodl_eq
        strat_year_maxdd    := 0.0
        hodl_year_maxdd     := 0.0
    else if bar_year != current_year
        // Year rollover: archive the prior year (use *current* equity since this bar's return hasn't been applied yet)
        array.push(years,          current_year)
        array.push(strat_year_ret, strat_eq / strat_year_start_eq - 1.0)
        array.push(strat_year_dd,  strat_year_maxdd)
        array.push(hodl_year_ret,  hodl_eq  / hodl_year_start_eq  - 1.0)
        array.push(hodl_year_dd,   hodl_year_maxdd)
        array.push(year_partial,   current_year == first_year_seen)
        // Reset per-year state for the new year
        current_year        := bar_year
        strat_year_start_eq := strat_eq
        hodl_year_start_eq  := hodl_eq
        strat_year_peak     := strat_eq
        hodl_year_peak      := hodl_eq
        strat_year_maxdd    := 0.0
        hodl_year_maxdd     := 0.0

    // ----- 2) Update this bar's equity -----
    btc_ret    = close / close[1]
    btcdom_ret = btcdom_close / btcdom_close[1]
    strat_eq := strat_eq * (hold_btc ? btc_ret : btcdom_ret)
    hodl_eq  := hodl_eq  * btc_ret

    // ----- 3) Update global peak / drawdown / switch count -----
    strat_peak  := math.max(strat_peak, strat_eq)
    hodl_peak   := math.max(hodl_peak,  hodl_eq)
    strat_maxdd := math.max(strat_maxdd, (strat_peak - strat_eq) / strat_peak)
    hodl_maxdd  := math.max(hodl_maxdd,  (hodl_peak  - hodl_eq)  / hodl_peak)
    if hold_btc != hold_btc[1]
        switch_cnt := switch_cnt + 1

    // ----- 4) Update per-year peak / drawdown -----
    strat_year_peak  := math.max(strat_year_peak, strat_eq)
    hodl_year_peak   := math.max(hodl_year_peak,  hodl_eq)
    strat_year_maxdd := math.max(strat_year_maxdd, (strat_year_peak - strat_eq) / strat_year_peak)
    hodl_year_maxdd  := math.max(hodl_year_maxdd,  (hodl_year_peak  - hodl_eq)  / hodl_year_peak)

// Last bar: archive the in-progress current year (flagged partial because it's YTD)
if barstate.islast and not na(current_year)
    array.push(years,          current_year)
    array.push(strat_year_ret, strat_eq / strat_year_start_eq - 1.0)
    array.push(strat_year_dd,  strat_year_maxdd)
    array.push(hodl_year_ret,  hodl_eq  / hodl_year_start_eq  - 1.0)
    array.push(hodl_year_dd,   hodl_year_maxdd)
    array.push(year_partial,   true)  // last year is always partial (hasn't crossed 12-31)

plot(strat_eq, title="Strategy",  color=color.new(color.blue,   0), linewidth=2)
plot(hodl_eq,  title="HODL BTC",  color=color.new(color.orange, 0), linewidth=2)

// ============================================================
// Switch markers on the main price chart (force_overlay=true)
// Switch to BTC: green up-triangle below the candle; switch to BTCDOM: red down-triangle above the candle
// ============================================================
switch_to_btc    = time >= start_date and hold_btc      and not hold_btc[1]
switch_to_btcdom = time >= start_date and not hold_btc  and hold_btc[1]
plotshape(switch_to_btc,    title="→ BTC",    style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0), size=size.small, force_overlay=true)
plotshape(switch_to_btcdom, title="→ BTCDOM", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,  0), size=size.small, force_overlay=true)

// ============================================================
// Tables: rendered only on the last bar
// ============================================================
var table tbl_overall = table.new(position.top_right, 3, 5, border_width=1)
var table tbl_yearly = table.new(position.bottom_right, 5, 21, border_width=1)

if barstate.islast
    // Compute CAGR
    days_elapsed = (time - start_date) / 86400000.0
    strat_cagr = days_elapsed > 0 ? math.pow(strat_eq / initial_equity, 365.0 / days_elapsed) - 1.0 : 0.0
    hodl_cagr  = days_elapsed > 0 ? math.pow(hodl_eq  / initial_equity, 365.0 / days_elapsed) - 1.0 : 0.0
    strat_total = strat_eq / initial_equity - 1.0
    hodl_total  = hodl_eq  / initial_equity - 1.0

    // Header
    table.cell(tbl_overall, 0, 0, "Metric",      bgcolor=color.gray, text_color=color.white)
    table.cell(tbl_overall, 1, 0, "Strategy",    bgcolor=color.gray, text_color=color.white)
    table.cell(tbl_overall, 2, 0, "HODL BTC",    bgcolor=color.gray, text_color=color.white)

    cell_bg = color.new(#1e1e1e, 20)  // semi-transparent dark gray — gives a panel look on black backgrounds

    table.cell(tbl_overall, 0, 1, "Total Return", bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 1, 1, f_pct(strat_total), bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 2, 1, f_pct(hodl_total),  bgcolor=cell_bg, text_color=color.white)

    table.cell(tbl_overall, 0, 2, "Max Drawdown", bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 1, 2, f_pct(strat_maxdd), bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 2, 2, f_pct(hodl_maxdd),  bgcolor=cell_bg, text_color=color.white)

    table.cell(tbl_overall, 0, 3, "CAGR", bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 1, 3, f_pct(strat_cagr), bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 2, 3, f_pct(hodl_cagr),  bgcolor=cell_bg, text_color=color.white)

    table.cell(tbl_overall, 0, 4, "Switch Count", bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 1, 4, str.tostring(switch_cnt), bgcolor=cell_bg, text_color=color.white)
    table.cell(tbl_overall, 2, 4, "—",                       bgcolor=cell_bg, text_color=color.white)

    // ----- Per-year breakdown table -----
    table.cell(tbl_yearly, 0, 0, "Year",      bgcolor=color.gray, text_color=color.white)
    table.cell(tbl_yearly, 1, 0, "Strat Ret", bgcolor=color.gray, text_color=color.white)
    table.cell(tbl_yearly, 2, 0, "Strat DD",  bgcolor=color.gray, text_color=color.white)
    table.cell(tbl_yearly, 3, 0, "HODL Ret", bgcolor=color.gray, text_color=color.white)
    table.cell(tbl_yearly, 4, 0, "HODL DD",  bgcolor=color.gray, text_color=color.white)

    n_years = array.size(years)
    for i = 0 to n_years - 1
        y      = array.get(years,          i)
        sr     = array.get(strat_year_ret, i)
        sd     = array.get(strat_year_dd,  i)
        hr     = array.get(hodl_year_ret,  i)
        hd     = array.get(hodl_year_dd,   i)
        is_par = array.get(year_partial,   i)
        y_str  = str.tostring(y) + (is_par ? "*" : "")
        row    = i + 1

        // On black-background themes use more saturated tints (30 transparency) + white text
        sr_col = sr >= 0 ? color.new(color.green, 30) : color.new(color.red, 30)
        hr_col = hr >= 0 ? color.new(color.green, 30) : color.new(color.red, 30)

        table.cell(tbl_yearly, 0, row, y_str,          bgcolor=cell_bg, text_color=color.white)
        table.cell(tbl_yearly, 1, row, f_pct(sr),      bgcolor=sr_col,  text_color=color.white)
        table.cell(tbl_yearly, 2, row, f_pct(sd),      bgcolor=cell_bg, text_color=color.white)
        table.cell(tbl_yearly, 3, row, f_pct(hr),      bgcolor=hr_col,  text_color=color.white)
        table.cell(tbl_yearly, 4, row, f_pct(hd),      bgcolor=cell_bg, text_color=color.white)
````
