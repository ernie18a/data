# SPY Wheel Strategy

- url: https://www.tradingview.com/script/KKGMELzx-SPY-Wheel-Strategy/
- type: strategy
- pine_id: PUB;d24e00ead29540c9a15e2b445039d92c
- version: 1.0

## Description

SPY Wheel Strategy — Methodology
Version: 1.0
Instrument: SPY (SPDR S&P 500 ETF)
Timeframe: Daily chart
Backtested: April 2023 – March 2026

Overview
This strategy implements a modified covered call wheel on SPY. The core idea is simple: hold 100 shares, sell a daily covered call slightly above market, collect premium continuously, and re-enter immediately when shares are called away. The strategy is designed as a premium income machine first, with share appreciation as a secondary benefit.
Options premium income is not modeled in the TradingView backtest — the P&L shown reflects share transactions only. Estimated real-world premium income adds approximately $1,500–2,500 over the backtest period on top of reported figures, depending on prevailing IV.

Entry
Buy 100 shares of SPY at market open on the strategy start date. This is the only discretionary entry — all subsequent re-entries are rule-based.

Covered Call Leg (CC)
No gate required. The CC fires every trading day while shares are held.

Normal conditions (VIX < 25): Sell a 1DTE call at the strike price calculated as ceil(close × 1.0125), rounded up to the nearest $1 strike.
Elevated volatility (VIX ≥ 25): Switch to a 0DTE call at ceil(close × 1.03) to eliminate overnight gap risk while maintaining wider strike protection.
Cost basis rule: The CC strike is never set below the current cost basis. On days where the calculated strike would fall below cost basis, no CC is sold and the position is held unchanged. This prevents locking in a loss on assignment.
Assignment trigger: Shares are called away only if the daily close exceeds the strike. Intraday touches do not constitute assignment. This matches real 1DTE options expiration behavior.


Re-entry
After CC assignment, shares are repurchased at the open of the next trading day. No waiting, no conditions. Instant re-entry was chosen over a CSP-based re-entry after backtesting showed that gate-filtered CSP waiting caused the strategy to sit idle during extended bull runs, significantly underperforming buy and hold.

CSP Gate — Six Conditions (Reference Only)
The six-gate framework was developed for an optional CSP re-entry mode and for live trading order discipline. All six must pass before a CSP order is placed. In the default instant re-entry configuration these gates are not active, but they remain visible in the status table as a live market environment dashboard.
GateConditionPurpose① 200 SMAClose > 200-day SMAMacro regime filter② 20 EMAClose > 20-day EMAShort-term trend filter③ RSIRSI(14) not in 75–85Not topping out④ VIXVIX < 25Volatility environment⑤ VWAPDisabled on daily chartIntraday execution timing⑥ MacroNot FOMC / CPI / NFP dayScheduled event filter

Emergency Exit
If SPY closes below the 200-day SMA for 3 consecutive days while shares are held, the position is closed at the next open and the strategy moves to cash. Re-entry occurs automatically when SPY closes back above the 200 SMA. This rule protects against prolonged bear market drawdowns where the cost basis trap would prevent meaningful CC income.
A secondary alert (yellow background) fires when SPY closes below the 20 EMA for 2 consecutive days, signaling the trader to consider purchasing a protective put to define downside risk.

Visual Reference
Chart ElementMeaningOrange line200-day SMABlue line20-day EMARed dashed lineCurrent cost basisGreen dashed lineActive CC strikeRed background tintVIX ≥ 25 — high volatility regimeYellow background tint20 EMA breach — hedge alert

Backtest Results (Share P&L Only)
MetricValuePeriodApr 2023 – Mar 2026Starting capital$70,000Total trades11 complete cyclesRealized share P&L$23,393Unrealized (open trade)$5,296Combined$28,689Buy & hold same period$25,595Estimated premium income$1,200 – $2,500
Premium income is estimated based on 637 CC contracts sold at an average of $1.50–2.50 per contract, reflecting 1DTE 1.25% OTM pricing at prevailing IV conditions. Actual results will vary with market volatility.

Known Limitations

Cost basis trap: During extended drawdowns the CC strike constraint (never below cost basis) prevents selling calls near the money. Premium income drops significantly during these periods.
Tail risk: A multi-year bear market will eventually breach the 200 SMA exit rule, realizing a loss. The strategy does not fully hedge equity risk — it reduces it through active cost basis management and daily premium income.
Premium not modeled: The backtest P&L reflects shares only. A complete picture requires adding real options premium data.
Daily bar assignment: TradingView backtests on daily bars. Assignment logic uses close-of-bar price checks to replicate real expiration behavior. Intraday simulation is not possible in this framework.


Settings (Adjustable via ⚙ Settings Cog)
ParameterDefaultDescriptionCC Strike % — Normal VIX1.25%OTM distance for 1DTE CCCC Strike % — High VIX3.00%OTM distance for 0DTE CCVIX Gate Threshold25VIX level triggering high-VIX CC modeRSI Block Zone75–85RSI range blocking CSP (set Lo > Hi to disable)200 SMA Length200Long-term trend MA20 EMA Length20Short-term trend MA200 SMA Breach Days3Consecutive days below 200 SMA to trigger exit20 EMA Breach Days2Consecutive days below 20 EMA to trigger hedge alertRe-entry ModeInstantInstant open re-entry vs CSP waitStart Date2023-04-03Backtest start

Disclaimer
This script is published for educational and research purposes. It does not constitute financial advice. Past backtest performance does not guarantee future results. Options trading involves substantial risk. Always conduct your own due diligence before trading.

## Source Code

````pine
//@version=6
strategy(
     title                   = "SPY Wheel Strategy",
     shorttitle              = "SPY Wheel",
     overlay                 = true,
     initial_capital         = 70000,
     default_qty_type        = strategy.fixed,
     default_qty_value       = 100,
     pyramiding              = 0,
     process_orders_on_close = true,
     calc_on_every_tick      = false)

// ═══════════════════════════════════════════════════════════════
//  Run on a DAILY SPY chart
//  CC assignment fires on CLOSE > strike only — not intraday touch
//  This matches real 1DTE options expiration behavior
//  Options premium P&L is NOT modeled — share transactions only
// ═══════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════

// CC leg
cc_pct_norm = input.float(1.25, title="CC Strike % OTM — Normal VIX", minval=0.25, maxval=5.0, step=0.25, group="CC Settings", tooltip="1DTE. Strike = ceil(close x (1+%)). Assignment only if next CLOSE > strike.") / 100
cc_pct_vix  = input.float(3.00, title="CC Strike % OTM — High VIX",   minval=0.50, maxval=8.0, step=0.25, group="CC Settings", tooltip="0DTE. Fires when VIX >= threshold. Same-day close must exceed strike.") / 100

// Re-entry mode
use_csp = input.bool(false, title="Use CSP re-entry (uncheck = instant re-entry at open)", group="Re-entry Settings", tooltip="OFF = buy shares at next open after CC assignment. ON = sell CSP and wait for assignment. OFF recommended.")
csp_pct = input.float(1.50, title="CSP Strike % OTM (only if CSP enabled)", minval=0.25, maxval=5.0, step=0.25, group="Re-entry Settings", tooltip="0DTE. Strike = floor(open x (1-%)). All 6 gates required.") / 100

// Gate settings
vix_thresh = input.float(25.0, title="VIX Gate Threshold",    minval=10.0, maxval=50.0, step=1.0, group="Gate Settings", tooltip="CSP blocked when VIX >= this. Also switches CC to High VIX mode.")
rsi_lo     = input.float(75.0, title="RSI Block Zone — Low",  minval=50.0, maxval=89.0, step=1.0, group="Gate Settings", tooltip="CSP blocked when RSI inside this band. Set Low > High to disable.")
rsi_hi     = input.float(85.0, title="RSI Block Zone — High", minval=51.0, maxval=95.0, step=1.0, group="Gate Settings")
sma_len    = input.int(200,    title="Long MA Length (SMA)",   minval=50,   maxval=500,            group="Gate Settings", tooltip="200-day SMA. Macro regime. SPY must be above for CSP.")
ema_len    = input.int(20,     title="Short MA Length (EMA)",  minval=5,    maxval=100,            group="Gate Settings", tooltip="20-day EMA. Short-term trend. SPY must be above for CSP.")
rsi_len    = input.int(14,     title="RSI Length",             minval=5,    maxval=30,             group="Gate Settings")
use_vwap   = input.bool(false, title="Gate 5: VWAP (uncheck = disabled)", group="Gate Settings", tooltip="OFF = gate disabled, always passes. ON = requires close >= VWAP. Only meaningful intraday.")

// Emergency exit
sma_days   = input.int(3,    title="200 SMA Breach Days to Exit",      minval=1, maxval=10, group="Emergency Exit", tooltip="Close shares if SPY closes below 200 SMA this many consecutive days.")
ema_days   = input.int(2,    title="20 EMA Breach Days — Hedge Alert", minval=1, maxval=10, group="Emergency Exit", tooltip="Yellow background = manually buy a protective put.")
show_hedge = input.bool(true, title="Show 20 EMA Hedge Alert", group="Emergency Exit")

// Macro filter
// UNCHECKED (default) = no block, all days pass
// CHECKED = today is blocked — toggle ON manually on FOMC/CPI/NFP morning
macro_block = input.bool(false, title="Block Today — FOMC / CPI / NFP", group="Macro Filter", tooltip="UNCHECKED = filter is OFF, days pass normally. CHECK on FOMC/CPI/NFP morning to block CSP that day only. Uncheck next morning. Never affects CC leg.")

// Backtest
start_dt = input.time(timestamp("2023-04-03"), title="Strategy Start Date", group="Backtest")


// ═══════════════════════════════════════════════════════════════
//  INDICATORS
// ═══════════════════════════════════════════════════════════════
sma200  = ta.sma(close, sma_len)
ema20   = ta.ema(close, ema_len)
rsi_val = ta.rsi(close, rsi_len)
vwap_v  = ta.vwap(hlc3)
vix_val = request.security("VIX", timeframe.period, close, ignore_invalid_symbol=true)

hi_vix  = not na(vix_val) and vix_val >= vix_thresh
holding = strategy.position_size >= 100


// ═══════════════════════════════════════════════════════════════
//  CSP GATE EVALUATION
//  CC has NO gate. Gate 5 OFF = always passes.
//  RSI gate: set lo > hi to disable.
// ═══════════════════════════════════════════════════════════════
g1_sma   = close > sma200
g2_ema   = close > ema20
g3_rsi   = rsi_lo > rsi_hi or not (rsi_val >= rsi_lo and rsi_val <= rsi_hi)
g4_vix   = not na(vix_val) and vix_val < vix_thresh
g5_vwap  = use_vwap ? close >= vwap_v : true
g6_macro = not macro_block
csp_ok   = g1_sma and g2_ema and g3_rsi and g4_vix and g5_vwap and g6_macro


// ═══════════════════════════════════════════════════════════════
//  STATE VARIABLES
// ═══════════════════════════════════════════════════════════════
var float cost_basis  = na
var float cc_str_live = na
var int   sma_ct      = 0
var int   ema_ct      = 0
var bool  exited      = false
var int   start_bar   = na
var bool  reenter_bar = false

reenter_bar := false

sma_ct := holding ? (close < sma200 ? sma_ct + 1 : 0) : 0
ema_ct := holding ? (close < ema20  ? ema_ct + 1 : 0) : 0

regime_break = holding and sma_ct >= sma_days
hedge_alert  = holding and show_hedge and ema_ct >= ema_days


// ═══════════════════════════════════════════════════════════════
//  1. INITIAL ENTRY
// ═══════════════════════════════════════════════════════════════
if time >= start_dt and time[1] < start_dt and strategy.position_size == 0
    strategy.entry("LONG", strategy.long, qty=100, comment="Initial buy")
    start_bar := bar_index


// ═══════════════════════════════════════════════════════════════
//  2. COST BASIS — updated on every new fill
// ═══════════════════════════════════════════════════════════════
if strategy.position_size >= 100 and strategy.position_size[1] < 100
    if strategy.opentrades > 0
        cost_basis := strategy.opentrades.entry_price(strategy.opentrades - 1)


// ═══════════════════════════════════════════════════════════════
//  3. EMERGENCY REGIME EXIT
// ═══════════════════════════════════════════════════════════════
if regime_break and not exited
    strategy.close_all(comment="REGIME EXIT — " + str.tostring(sma_days) + "d below 200 SMA")
    strategy.cancel_all()
    cost_basis  := na
    cc_str_live := na
    exited      := true


// ═══════════════════════════════════════════════════════════════
//  4. RE-ENTRY AFTER REGIME EXIT
// ═══════════════════════════════════════════════════════════════
if exited and not holding and close > sma200 and time >= start_dt
    strategy.entry("LONG", strategy.long, qty=100, comment="Re-entry — 200 SMA reclaimed")
    exited      := false
    reenter_bar := true


// ═══════════════════════════════════════════════════════════════
//  5. CC MODE — NO GATE
//
//  KEY FIX: Assignment uses CLOSE vs strike, never intraday high.
//
//  Each bar:
//    a) Check if yesterday's strike was exceeded by today's CLOSE
//       → if yes: close position (CC assigned)
//    b) Set today's new strike from today's CLOSE for use tomorrow
//
//  1DTE (normal VIX): strike set today on close, expires tomorrow
//  0DTE (high VIX):   strike set and checked on same bar's close
// ═══════════════════════════════════════════════════════════════
if holding and not regime_break and time >= start_dt and not na(cost_basis)

    pct        = hi_vix ? cc_pct_vix : cc_pct_norm
    new_strike = float(math.ceil(close * (1.0 + pct)))

    // For 1DTE: check yesterday's strike against today's close
    // For 0DTE: check today's strike against today's close (same bar)
    prev_strike = cc_str_live[1]
    check_strike = hi_vix ? new_strike : prev_strike

    if not na(check_strike) and close > check_strike and check_strike >= cost_basis
        strategy.close_all(comment="CC assigned @ $" + str.tostring(int(check_strike)) + (hi_vix ? " [HiVIX 0DTE]" : " [1DTE]"))
        cc_str_live := na
    else
        if new_strike >= cost_basis
            cc_str_live := new_strike
        else
            cc_str_live := na


// ═══════════════════════════════════════════════════════════════
//  6. RE-ENTRY AFTER CC ASSIGNMENT
//
//  Instant (default): buy at next open
//  CSP (optional):    all 6 gates, 0DTE put, floor to $1
// ═══════════════════════════════════════════════════════════════
csp_eligible = not holding and not exited and not reenter_bar and not na(start_bar) and bar_index > start_bar and time >= start_dt

if csp_eligible
    if not use_csp
        strategy.entry("LONG", strategy.long, qty=100, comment="Re-entry at open")
    else
        strategy.cancel("LONG")
        if csp_ok
            csp_strike = float(math.floor(open * (1.0 - csp_pct)))
            strategy.entry("LONG", strategy.long, qty=100, limit=csp_strike, comment="CSP @ $" + str.tostring(int(csp_strike)))


// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
plot(sma200, title="200 SMA",  color=color.new(color.orange, 0), linewidth=2)
plot(ema20,  title="20 EMA",   color=color.new(color.blue,   0), linewidth=1)
plot(holding ? cost_basis  : na, title="Cost Basis", color=color.new(color.red,   0), style=plot.style_linebr, linewidth=1)
plot(holding ? cc_str_live : na, title="CC Strike",  color=color.new(color.green, 0), style=plot.style_linebr, linewidth=1)

bgcolor(hi_vix      ? color.new(color.red,    93) : na, title="High VIX Regime")
bgcolor(hedge_alert ? color.new(color.yellow, 88) : na, title="Hedge Alert — 20 EMA")
bgcolor(not holding and csp_ok     and not exited and use_csp ? color.new(color.green, 95) : na, title="CSP Gates Open")
bgcolor(not holding and not csp_ok and not exited and use_csp ? color.new(color.gray,  95) : na, title="CSP Gates Blocked")


// ═══════════════════════════════════════════════════════════════
//  GATE STATUS TABLE — top right corner
// ═══════════════════════════════════════════════════════════════
var table gt = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 12,
     bgcolor      = color.new(color.black, 72),
     border_width = 1,
     frame_width  = 1,
     frame_color  = color.new(color.gray, 60))

if barstate.islast
    table.cell(gt, 0, 0,  "GATE",      text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 55))
    table.cell(gt, 1, 0,  "CSP ONLY",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 55))
    table.cell(gt, 0, 1,  "① 200 SMA", text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 1,  g1_sma  ? "✓" : "✗", text_color=g1_sma  ? color.lime : color.red, text_size=size.small)
    table.cell(gt, 0, 2,  "② 20 EMA",  text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 2,  g2_ema  ? "✓" : "✗", text_color=g2_ema  ? color.lime : color.red, text_size=size.small)
    table.cell(gt, 0, 3,  "③ RSI",     text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 3,  g3_rsi  ? "✓" : "✗", text_color=g3_rsi  ? color.lime : color.red, text_size=size.small)
    table.cell(gt, 0, 4,  "④ VIX",     text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 4,  g4_vix  ? "✓" : "✗", text_color=g4_vix  ? color.lime : color.red, text_size=size.small)
    table.cell(gt, 0, 5,  "⑤ VWAP",    text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 5,  use_vwap ? (g5_vwap ? "✓" : "✗") : "OFF", text_color=use_vwap ? (g5_vwap ? color.lime : color.red) : color.gray, text_size=size.small)
    table.cell(gt, 0, 6,  "⑥ Macro",   text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 6,  g6_macro ? "✓" : "✗", text_color=g6_macro ? color.lime : color.red, text_size=size.small)
    table.cell(gt, 0, 7,  "────────",  text_color=color.gray,   text_size=size.small)
    table.cell(gt, 1, 7,  "────────",  text_color=color.gray,   text_size=size.small)
    table.cell(gt, 0, 8,  "ALL GATES", text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 8,  csp_ok ? "GREEN" : "RED", text_color=csp_ok ? color.lime : color.red, text_size=size.small)
    table.cell(gt, 0, 9,  "VIX",       text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 9,  not na(vix_val) ? str.tostring(math.round(vix_val, 1)) : "n/a", text_color=hi_vix ? color.red : color.lime, text_size=size.small)
    table.cell(gt, 0, 10, "RE-ENTRY",  text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 10, use_csp ? "CSP" : "INSTANT", text_color=use_csp ? color.orange : color.lime, text_size=size.small)
    table.cell(gt, 0, 11, "MODE",      text_color=color.white,  text_size=size.small)
    table.cell(gt, 1, 11, holding ? "CC" : (exited ? "FLAT" : (use_csp ? "CSP" : "WAIT")), text_color=holding ? color.lime : (exited ? color.gray : color.orange), text_size=size.small)
````
