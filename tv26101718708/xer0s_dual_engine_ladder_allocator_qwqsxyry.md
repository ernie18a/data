# Xer0's Dual Engine Ladder Allocator

- url: https://www.tradingview.com/script/QWqsxYRy-Xer0-s-Dual-Engine-Ladder-Allocator/
- type: indicator
- pine_id: PUB;4b85f0caf2fb44209935c971a8741815
- version: 9.0

## Description

Overview
This indicator is designed for long-term investors using a "Dual Engine" portfolio strategy on M1 Finance — mixing a broad-market index fund with a leveraged counterpart in the same Pie. Instead of guessing when to buy the dip, this script provides a systematic, step-by-step roadmap for increasing your leveraged allocation as the market falls, and resetting it as the market recovers.

How It Works
The strategy is built on "Sticky All-Time High" logic. It tracks the highest close price and calculates the current drawdown from that peak, then responds with one of three scenarios:

Ladder Down (Risk On): For every defined drop step (e.g. every -5%), the indicator signals a RISK UP event — automatically calculating your new target allocation to the leveraged slice of your Pie. This forces systematic, disciplined buying at lower prices.

Recovery Reset (Risk Off): Once the market recovers by a set percentage from the bottom, the script signals a RESET — returning your allocation to the base level and locking in the gains from the dip-buying phase.

Bull Step: When the market pushes into new high territory, the script tracks each new leg up and keeps your reference point current.

Key Features
Sticky ATH Tracking: Automatically calculates true drawdown from the cycle peak
Customizable Ladder Steps: Define your own drop trigger percentage and leverage increase per step
Max Cap: Hard ceiling on leverage exposure to protect against catastrophic drawdowns
Bar Confirmation: All signals fire on daily close to avoid intraday false triggers
Visual Dashboard: Bottom-right table showing current mode, target leverage, drawdown, and recovery price target
Alert Conditions: Built-in RISK UP and RESET alerts compatible with TradingView's "Once Per Bar Close" setting

Backtested Performance (Simulated — Read Carefully)
The following results are from a Python backtest covering approximately 30 years (1996–2026), using $923/week in contributions every Friday. The strategy used two M1 Pies: Pie 1 (S&P 500 index fund / 3× S&P 500 ETF, base leverage 35%) and Pie 2 (Nasdaq-100 index fund / 3× Nasdaq-100 ETF, base leverage 25%). Tax assumptions reflect California state + federal rates for a $47K–$100K income bracket. Data prior to 2010 is synthetic, modeled from underlying index returns.
Results are hypothetical and do not represent actual trading. Past performance does not guarantee future results.
                                   Ladder Strategy |  VOO Benchmark
Total Contributed                $1,395,576 |  $1,395,576
Final Value (after-tax)       $25,286,879 |    $9,025,443
Total Return                           1,711.9% |   546.7%
CAGR (on contributions)              10.1% |   6.4%
Max Drawdown                           -91.8% |   -50.5%
Taxes Paid (CA)                    $5,358,907 |   N/A (buy & hold)
Cash After Full Liquidation  $23,500,189 |   $7,171,385

The ladder strategy produced approximately 227.7% more after-tax cash than buy-and-hold VOO after full liquidation. However, the strategy experienced a maximum drawdown of -91.8% — meaning at its worst point, the portfolio lost nearly all of its value on paper. This level of volatility is not suitable for most investors and requires strong conviction and a long time horizon to hold through.

How to Use
Add this indicator to a Daily (1D) chart of your chosen index. Configure the inputs to match your risk tolerance — Base Leverage %, Drop Step %, and Max Cap %. Enter your M1 Pie name in the input field so alerts reference it by name. Set alerts using "Once Per Bar Close" and adjust your Pie allocation whenever a signal fires.

Disclaimer
This script is for informational and educational purposes only. It does not constitute financial advice. Backtested results are simulated and hypothetical — they do not account for all real-world frictions and should not be interpreted as a guarantee of future performance. Trading leveraged instruments involves significant risk, including the potential loss of your entire investment, and is not suitable for all investors.

## Source Code

````pine
// =================================================================================
// DUAL ENGINE LADDER ALLOCATOR v4
// 40/60 split + Fib Drops + Bull Rebal + DRIFT10 Cross-Pie + R5/B4 thresholds
// =================================================================================
// FINAL CONFIGURATION:
//   - 40/60 SPX/NDX contribution split
//   - Fibonacci drop steps: -5%, -8%, -13%, -21%, -34%, -55%
//   - +5% leverage increment per step
//   - Cap 80%
//   - Initial reset at ATH x 1.05 (R5: price reaches new high by +5%)
//   - Bull rebalance at +4% above benchmark (B4: tighter for better P10)
//   - Cross-pie 40/60 transfer ONLY when NDX > 70% of total portfolio (DRIFT10)
//   - Reverse cross-pie transfer when SPX > 46% of total portfolio (REV-DRIFT46)
//     triggers any time, any phase — fires ~4x per 30 years (catches 2008)
//
// =================================================================================
// BACKTEST UPDATE — BASE LEVERAGE OPTIMIZATION
// =================================================================================
// Previous validation used broad Monte Carlo simulations (500 runs, stylized
// SPX/NDX stats 1990-2025). This update uses a more reliable methodology:
//
//   DATA:
//     - 30-year synthetic series built from real ^NDX and ^GSPC daily prices
//     - TQQQ synthetic = 3x NDX daily return - 0.88% ER / 252
//     - UPRO synthetic = 3x SPX daily return - 0.91% ER / 252
//     - Calibrated to match real historical CAGR and volatility profiles
//
//   CONTRIBUTION LOGIC (M1 Finance accurate):
//     - Previous model blindly split deposits 40/60 every month
//     - Updated model calculates each pie's current value vs its 40/60 target
//       weight before each deposit, and directs the contribution toward the
//       most underweight pie — exactly how M1 Finance smart deposits work
//       inside a parent pie
//
//   GRID SEARCH:
//     - Tested all 64 combinations of SPX base (20-55%) x NDX base (20-55%)
//       in 5% increments
//     - Each combination scored on 4 equally weighted metrics:
//         1. CAGR
//         2. Sharpe ratio (4% risk-free rate)
//         3. Calmar ratio (CAGR / Max Drawdown)
//         4. Max drawdown control (inverted — less drawdown = higher score)
//     - Composite score used to find the balance point across all metrics
//
//   OPTIMAL BASE LEVERAGE (implement on next drawdown reset):
//     - SPX pie: 55% UPRO / 45% VOO  (was 35% UPRO)
//     - NDX pie: 40% TQQQ / 60% QQQ  (was 25% TQQQ)
//
//   RESULTS AT OPTIMAL BASE (70K start, 2K/month, 30 years):
//     - Dual Engine v4:   $28.2M  |  CAGR 22.22%  |  Sharpe 0.575  |  Max DD -78.7%
//     - 100% QQQ:          $7.4M  |  CAGR 16.84%  |  Sharpe 0.610  |  Max DD -44.8%
//     - 60/40 QQQ+VOO:     $6.1M  |  CAGR 16.12%  |  Sharpe 0.640  |  Max DD -43.6%
//
//   KEY FINDINGS:
//     - SPX pie strongly prefers 55% — lower SPX volatility absorbs higher
//       starting leverage without materially worsening the drawdown profile
//     - NDX pie sweet zone is 35-45% — above 45% pushes max DD past -80%,
//       below 35% leaves meaningful CAGR on the table
//     - The M1-accurate deposit routing naturally rebalances toward the 40/60
//       target over time, adding ~$500K in terminal value vs naive splitting
//     - Ladder events over 30 years: ~48 SPX step-ups, ~65 NDX step-ups,
//       ~27 SPX bull rebals, ~22 NDX bull rebals, ~16-26 resets per pie
//
//   REVERSE-DRIFT RULE (REV-DRIFT46) — new addition:
//     When SPX pie > 46% of total portfolio (any time, any phase),
//     rebalance full portfolio back to 40/60 SPX/NDX split.
//     Fine sweep tested SPX 41%-50% thresholds in 1% increments:
//       - SPX > 46%: conservative pick, fires ~4x/30y, same end value as 49%
//         catches 2008 imbalance that 49% misses — ~once per decade
//       - SPX > 49%: fires ~2x/30y, misses 2008 scenario
//       - SPX > 41-43%: over-triggers (25-59 events), no additional benefit
//     Thresholds above 50% never fired in 30-year dataset (M1 contributions
//     naturally rebalance SPX back toward 40% before it drifts that far).
//     Historical fire dates (46% threshold): 1998, 2005, 2012, 2019
//
//   NOTE: Current Pine Script base levels (SPX 35%, NDX 25%) remain active
//   until the next drawdown reset event, at which point base levels should
//   be updated to 55% / 40% respectively.
// =================================================================================
//@version=6
indicator("Dual Engine v4", overlay=true, max_labels_count=500)
// =================================================================================
// USER INPUTS
// =================================================================================
pie_type = input.string("NDX", "Pie Type", options=["SPX", "NDX"])
increment_per_step = input.float(5.0, "Drawdown Increment per Step (%)", minval=1.0, maxval=20.0, step=1.0)
reset_above_ath_pct = input.float(5.0, "Initial Reset Threshold (% above ATH)", minval=1.0, maxval=20.0, step=0.5)
bull_rebal_pct = input.float(4.0, "Bull Rebalance Threshold (% above benchmark)", minval=1.0, maxval=20.0, step=0.5)
max_leverage_pct = input.float(80.0, "Max Leverage Cap (%)", minval=25.0, maxval=100.0, step=5.0)
show_alerts_table = input.bool(true, "Show Status Table", group="Display")
table_pos = input.string("Top Right", "Status Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group="Display")
show_step_labels = input.bool(true, "Show Step Labels on Chart", group="Display")
show_bull_marks = input.bool(true, "Show Bull Rebalance Marks", group="Display")
// =================================================================================
// FIBONACCI DROP-STEP THRESHOLDS
// =================================================================================
get_step_for_drawdown(dd_pct) =>
    step = 0
    if dd_pct >= 89.0
        step := 7
    else if dd_pct >= 55.0
        step := 6
    else if dd_pct >= 34.0
        step := 5
    else if dd_pct >= 21.0
        step := 4
    else if dd_pct >= 13.0
        step := 3
    else if dd_pct >= 8.0
        step := 2
    else if dd_pct >= 5.0
        step := 1
    step
target_leverage_at_step(base_pct, step) =>
    target = base_pct + (step * increment_per_step)
    math.min(target, max_leverage_pct)
// =================================================================================
// CONFIG: BASE LEVERAGE BY PIE
// Updated per grid search optimization (implement on next drawdown reset):
//   SPX: 55% UPRO (was 35%)
//   NDX: 40% TQQQ (was 25%)
// =================================================================================
base_leverage_pct = pie_type == "SPX" ? 55.0 : 40.0
leveraged_etf_name = pie_type == "SPX" ? "UPRO" : "TQQQ"
underlying_etf_name = pie_type == "SPX" ? "VOO" : "QQQ"
// =================================================================================
// LADDER STATE
// =================================================================================
var float ath = na
var float bull_benchmark = na
var int current_step = 0
var bool in_drawdown = false
var bool bull_active = false
if na(ath)
    ath := close
    bull_benchmark := close
    current_step := 0
    in_drawdown := false
    bull_active := false
// =================================================================================
// LADDER LOGIC
// =================================================================================
// (1) INITIAL RESET: in drawdown and price >= ATH x 1.05 (R5)
initial_reset_triggered = in_drawdown and close >= ath * (1.0 + reset_above_ath_pct / 100.0)
if initial_reset_triggered
    current_step := 0
    in_drawdown := false
    ath := close
    bull_benchmark := close
    bull_active := true
// (2) BULL REBALANCE: not in drawdown, bull active, price >= benchmark x 1.04 (B4)
bull_rebal_triggered = (not in_drawdown) and bull_active and (not initial_reset_triggered) and close >= bull_benchmark * (1.0 + bull_rebal_pct / 100.0)
if bull_rebal_triggered
    bull_benchmark := close
// (3) ATH UPDATE: if not in drawdown and price > ATH, ATH floats up
if not in_drawdown and close > ath
    ath := close
// (4) STEP UP: drawdown from frozen ATH against Fibonacci thresholds
drawdown_pct = (close / ath - 1.0) * 100.0
drawdown_abs = -drawdown_pct
target_step = get_step_for_drawdown(drawdown_abs)
step_up_triggered = target_step > current_step
if step_up_triggered
    current_step := target_step
    in_drawdown := true
// =================================================================================
// COMPUTED CURRENT TARGET
// =================================================================================
current_target_lev_pct = target_leverage_at_step(base_leverage_pct, current_step)
current_target_und_pct = 100.0 - current_target_lev_pct
effective_leverage = (current_target_und_pct * 1.0 + current_target_lev_pct * 3.0) / 100.0
next_threshold_dd = current_step == 0 ? 5.0 : current_step == 1 ? 8.0 : current_step == 2 ? 13.0 : current_step == 3 ? 21.0 : current_step == 4 ? 34.0 : current_step == 5 ? 55.0 : 89.0
// Threshold that triggered the current step (for display)
current_threshold_dd = current_step == 1 ? 5.0 : current_step == 2 ? 8.0 : current_step == 3 ? 13.0 : current_step == 4 ? 21.0 : current_step == 5 ? 34.0 : current_step == 6 ? 55.0 : current_step == 7 ? 89.0 : 0.0
next_step_price = ath * (1.0 - next_threshold_dd / 100.0)
// Recompute thresholds AFTER state updates for accurate display
reset_threshold_display = ath * (1.0 + reset_above_ath_pct / 100.0)
bull_threshold_display = bull_benchmark * (1.0 + bull_rebal_pct / 100.0)
// =================================================================================
// VISUAL: STEP LABELS
// =================================================================================
plotshape(step_up_triggered, "Step Up", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="UP")
plotshape(initial_reset_triggered, "Initial Reset", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="RESET")
plotshape(show_bull_marks and bull_rebal_triggered, "Bull Rebalance", style=shape.diamond, location=location.belowbar, color=color.aqua, size=size.tiny, text="BULL")
if show_step_labels and step_up_triggered
    label.new(bar_index, high, text=str.format("STEP {0} (triggered at -{1}%)\n{2}: {3}%\n{4}: {5}%\nLev: {6,number,#.##}x\nNext step at -{7}%", current_step, current_threshold_dd, leveraged_etf_name, current_target_lev_pct, underlying_etf_name, current_target_und_pct, effective_leverage, next_threshold_dd), color=color.new(color.red, 20), textcolor=color.white, size=size.small, style=label.style_label_down)
if show_step_labels and initial_reset_triggered
    label.new(bar_index, low, text=str.format("INITIAL RESET\nSnap to BASE\n{0}: {1}%\n{2}: {3}%\n(Bull benchmark anchored)", leveraged_etf_name, base_leverage_pct, underlying_etf_name, 100 - base_leverage_pct), color=color.new(color.green, 20), textcolor=color.white, size=size.small, style=label.style_label_up)
if show_step_labels and show_bull_marks and bull_rebal_triggered
    label.new(bar_index, low, text=str.format("BULL REBAL ({0})\n{0} -> base ({1}%/{2}%)\nCheck cross-pie drift:\n  NDX>70% of total? -> DRIFT10\n  SPX>46% of total? -> REV-DRIFT46\nNew benchmark: {3,number,#.##}", pie_type, base_leverage_pct, 100 - base_leverage_pct, close), color=color.new(color.aqua, 20), textcolor=color.black, size=size.tiny, style=label.style_label_up)
// =================================================================================
// STATUS TABLE
// =================================================================================
if show_alerts_table and barstate.islast
    // muted TradingView-native palette + one phase accent
    c_panel = color.new(#131722, 5)
    c_head  = color.new(#1e222d, 0)
    c_grid  = color.new(#2a2e39, 0)
    c_lbl   = #787b86
    c_val   = #d1d4dc
    c_acc   = #2962ff
    phase_c = in_drawdown ? #f5a623 : bull_active ? #089981 : #787b86
    pos = table_pos == "Top Left" ? position.top_left : table_pos == "Bottom Right" ? position.bottom_right : table_pos == "Bottom Left" ? position.bottom_left : table_pos == "Middle Right" ? position.middle_right : position.top_right
    var table tbl = table.new(pos, 2, 11, bgcolor=c_panel, border_width=1, border_color=c_grid, frame_width=1, frame_color=c_grid)
    // (0) title
    table.cell(tbl, 0, 0, "DUAL ENGINE v4", text_color=c_val, bgcolor=c_head, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, pie_type, text_color=c_acc, bgcolor=c_head, text_size=size.small, text_halign=text.align_right)
    // (1) headline phase banner
    table.cell(tbl, 0, 1, "PHASE", text_color=color.white, bgcolor=phase_c, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, in_drawdown ? "DRAWDOWN · step " + str.tostring(current_step) : (bull_active ? "BULL" : "PRE-RESET"), text_color=color.white, bgcolor=phase_c, text_size=size.normal, text_halign=text.align_right)
    // (2) plain-English action
    act = in_drawdown ? "Add " + leveraged_etf_name + " to " + str.tostring(current_target_lev_pct, "#") + "%" : "Hold base " + str.tostring(current_target_lev_pct, "#") + "%"
    table.cell(tbl, 0, 2, "Do now", text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, act, text_color=c_val, text_size=size.small, text_halign=text.align_right)
    // (3) ALLOCATION section
    table.cell(tbl, 0, 3, "ALLOCATION", text_color=c_lbl, bgcolor=c_head, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 3, "", bgcolor=c_head)
    table.cell(tbl, 0, 4, leveraged_etf_name, text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(current_target_lev_pct, "#.#") + "%", text_color=c_val, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 0, 5, underlying_etf_name, text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(current_target_und_pct, "#.#") + "%", text_color=c_val, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 0, 6, "Leverage", text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(effective_leverage, "#.##") + "x", text_color=phase_c, text_size=size.small, text_halign=text.align_right)
    // (7) MARKET section
    table.cell(tbl, 0, 7, "MARKET", text_color=c_lbl, bgcolor=c_head, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 7, "", bgcolor=c_head)
    table.cell(tbl, 0, 8, "Drawdown", text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 8, str.tostring(drawdown_pct, "#.#") + "%", text_color=drawdown_pct < -10 ? #f23645 : c_val, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 0, 9, "Frozen ATH", text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 9, str.tostring(ath, "#.#"), text_color=c_val, text_size=size.small, text_halign=text.align_right)
    nxt_lbl = in_drawdown ? "Next step @" : "Bull trig @"
    nxt_val = in_drawdown ? next_step_price : bull_threshold_display
    table.cell(tbl, 0, 10, nxt_lbl, text_color=c_lbl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 10, str.tostring(nxt_val, "#.#"), text_color=c_val, text_size=size.small, text_halign=text.align_right)
// =================================================================================
// ALERT CONDITIONS
// =================================================================================
alertcondition(step_up_triggered, "Drawdown Step Up", "Dual Engine v4: Drawdown step UP. Rebalance leveraged ETF to next step %.")
alertcondition(initial_reset_triggered, "Initial Reset", "Dual Engine v4: INITIAL RESET (new ATH +5%). Snap to base allocation. Bull benchmark anchored.")
alertcondition(bull_rebal_triggered, "Bull Rebalance", "Dual Engine v4: BULL REBALANCE (+4% above benchmark) on THIS pie - rebalance this pie back to its base allocation (see chart label / status table for the exact %). Also manually check M1 for cross-pie drift: if NDX pie > 70% of total portfolio, transfer excess to SPX (DRIFT10). If SPX pie > 46% of total portfolio, rebalance the full portfolio back to 40/60 (REV-DRIFT46).")
// DRIFT10 / REV-DRIFT46 have no dedicated alertcondition of their own - Pine Script
// can't see the other pie's live value to auto-calculate the cross-pie ratio, so
// there's no way to fire on their own triggers. The Bull Rebalance alert above
// carries a reminder for both instead, since it already fires periodically during
// bull runs. REV-DRIFT46's threshold is SPX pie > 46% of total portfolio (matches
// the header/backtest above - the fine sweep rejected 49% because it misses 2008).
// =================================================================================
// PLOTS
// =================================================================================
plot(ath, "Frozen ATH", color=color.new(color.green, 50), linewidth=1, style=plot.style_line)
plot((bull_active and not in_drawdown) ? bull_benchmark : na, "Bull Benchmark", color=color.new(color.aqua, 30), linewidth=1, style=plot.style_line)
plot(in_drawdown ? reset_threshold_display : na, "Initial Reset Threshold", color=color.new(color.lime, 50), linewidth=1, style=plot.style_circles)
plot((bull_active and not in_drawdown) ? bull_threshold_display : na, "Bull Trigger Price", color=color.new(color.aqua, 70), linewidth=1, style=plot.style_circles)
plot(in_drawdown ? next_step_price : na, "Next Step Trigger", color=color.new(color.red, 50), linewidth=1, style=plot.style_circles)
````
