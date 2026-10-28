# Leveraged ETF Strategy Tester

- url: https://www.tradingview.com/script/UnTAKUJc-Leveraged-ETF-Strategy-Tester/
- type: indicator
- pine_id: PUB;f7c613d13f3545a8a9b4c1bea3b89118
- version: 4.0

## Description

A comprehensive backtesting tool for comparing three distinct leveraged ETF investment strategies with customizable parameters, visual indicators, and risk metrics.

[b]Features:[/b]
[list]
[*]Test three proven strategies side-by-side
[*]Fully customizable parameters via settings
[*]Visual buy signals color-coded by deployment tier
[*]ATH tracking and drawdown bands
[*]Monthly contribution support
[*]Sharpe and Sortino ratios for risk assessment
[*]Separate tables for statistics and strategy descriptions
[/list]
[b]Strategy 1: Stars (Lee Ekholm)[/b]
A rebalancing strategy that maintains a conservative 20% TQQQ / 80% SPY base allocation with an automatic risk-on mechanism during severe drawdowns.

How it works:
[list]
[*]Annual rebalancing at 20/80 allocation
[*]When TQQQ drops 40%+, shifts to 40% TQQQ at next rebalance
[*]Skips rebalancing for 1 year after market bottoms
[*]Resets to base allocation after TQQQ recovers to new ATH
[*]Monthly contributions accumulate and deploy during rebalances
[*]Best for: Long-term investors seeking systematic exposure increase during crashes
[/list]
[b]Strategy 2: BD Collins 80/20 DCA[/b]
A four-tier dollar-cost averaging strategy that deploys cash more aggressively as drawdowns deepen, automatically buying more during corrections.

How it works:
[list]
[*]Accumulates monthly contributions as cash reserves
[*]Deploys at quarterly intervals (customizable)
[*]4 deployment tiers based on drawdown from ATH:
[*]0-15%: Deploy 20% of cash
[*]15-25%: Deploy 40% of cash
[*]25-35%: Deploy 60% of cash
[*]35%+: Deploy 80% of cash
[*]Best for: Investors wanting automated "buy the dip" behavior with increasing aggression
[/list]
[b]Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)[/b]
A simplified three-tier approach with clear escalating deployment levels based on drawdown severity.

How it works:
[list]
[*]Baseline: 20% deployment near ATH
[*]20% drop: 33% deployment (1/3)
[*]40% drop: 67% deployment (2/3)
[*]60% drop: 100% deployment (full cash)
[*]Monthly contributions accumulate and deploy at chosen cadence
[*]Best for: Investors preferring a simpler, more aggressive deployment schedule with clear trigger points
[/list]

Color-Coded Buy Signals:
Strategy 1: Aqua (normal) | Orange (40% trigger active)
Strategy 2: Green (20%) | Yellow (40%) | Orange (60%) | Red (80%)
Strategy 3: Green (20-33%) | Orange (67%) | Red (100%)

Note: This indicator is for educational and backtesting purposes. Past performance does not guarantee future results. Leveraged ETFs carry significant risk and may not be suitable for all investors.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Strategy Tester for Stars, BD Collins 80/20, Henrique, and 14-week SMA
//
// STRATEGY DESCRIPTIONS:
//
// Strategy 1 - Stars (Lee Ekholm):
// Base: 20% TQQQ, 80% SPY rebalanced annually
// If TQQQ drops 40%, shift to 40% TQQQ at next rebalance (temporary)
// Skip rebalancing in 1st year after market bottom
// After bottom recovery period, reset back to 20% TQQQ allocation
//
// Strategy 2 - BD Collins 80/20 DCA:
// Deploy cash based on distance from ATH:
// Within 15% → 20% of cash | 15-25% → 40% | 25-35% → 60% | >35% → 80%
// Accumulates monthly contributions and deploys at DCA intervals
//
// Strategy 3 - Henrique Centieiro's Strategy (1/3 Cash):
// Baseline: 20% of cash when near ATH
// 20% drop → 33% | 40% drop → 67% | 60% drop → 100%
// Simplified approach with escalating deployment as drawdown increases
//
// Strategy 4 - BD Collins 14-week SMA (Advanced):
// Entry: Monday open after confirmed weekly close ABOVE 14W-SMA
// Exit: Monday open once the trailing peak has been given back by dd%
// Violent Break: If weekly close >10% below threshold, exit Friday close
// Holds the chosen cash asset while out of the leveraged ETF
//
// CHANGES TO STRATEGY 4 IN THIS VERSION (all switchable; defaults follow the book)
// a) Exit Trigger: "Intraweek touch" (book) or "Weekly close below" (original behaviour)
// b) Trailing Peak Source: weekly high/wick (book) or weekly close
// c) Trailing peak is now updated BEFORE the exit test, not after
// d) Start Already Invested is now optional and OFF by default
// e) Green weekly candle is now optional and OFF by default (not a Collins rule)
// f) Cash asset no longer silently falls back to a $1.00 price
// g) Transaction cost input, charged on both sides of every switch
//
// TRIANGLE COLOR LEGEND:
// Strategy 1: Aqua = Normal Rebalance | Orange = Triggered (40%+ drawdown)
// Strategy 2: Green = 20% | Yellow = 40% | Orange = 60% | Red = 80%
// Strategy 3: Green = 33% | Orange = 67% | Red = 100%
// Strategy 4: Green = Buy Signal | Red = Sell Signal

//@version=6
indicator("Leveraged ETF Strategy Tester", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY SELECTION
// ═══════════════════════════════════════════════════════════════════════════
strategy_choice = input.string("Strategy 1: Stars (Ekholm)", "Strategy",
     options=["Strategy 1: Stars (Ekholm)", "Strategy 2: BD Collins 80/20 DCA", "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)", "Strategy 4: BD Collins 14-week SMA"],
     tooltip="Strategy 1: 20/80 TQQQ/SPY rebalanced annually, shifts to 40% TQQQ after 40% drop\nStrategy 2: DCA with 4-tier deployment (20/40/60/80%) based on drawdown bands\nStrategy 3: Simplified 3-tier deployment (20/33/67/100%) at drawdown triggers\nStrategy 4: Buy above 14-week SMA, sell on 40% drop from peak")

// ═══════════════════════════════════════════════════════════════════════════
// COMMON PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════
group_common = "═══ Common Parameters ═══"
initial_capital = input.float(1000, "Initial Capital ($)", group=group_common)
monthly_contribution = input.float(250, "Monthly Contribution ($)", group=group_common, tooltip="Regular cash contribution per month")
leveraged_ticker = input.string("TQQQ", "Leveraged ETF Ticker", group=group_common, tooltip="TQQQ, UPRO, SOXL, etc.")
spy_ticker = input.string("SPY", "SPY Ticker (for Strategy 1)", group=group_common)

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 1: STARS (EKHOLM) PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════
group_s1 = "═══ Strategy 1: Stars Parameters ═══"
s1_base_lev_pct = input.float(20, "Base TQQQ Allocation (%)", group=group_s1, minval=0, maxval=100)
s1_base_spy_pct = input.float(80, "Base SPY Allocation (%)", group=group_s1, minval=0, maxval=100)
s1_drawdown_trigger = input.float(40, "Drawdown Trigger for Rebalance (%)", group=group_s1, minval=0, maxval=100)
s1_new_lev_pct = input.float(40, "New TQQQ Allocation After Trigger (%)", group=group_s1, minval=0, maxval=100)
s1_bottom_threshold = input.float(20, "Market Bottom Detection Threshold (%)", group=group_s1, minval=0, maxval=100, tooltip="SPY drawdown % to detect bottom")
s1_recovery_pct = input.float(50, "Recovery % from Bottom", group=group_s1, minval=0, maxval=100, tooltip="% recovery to confirm bottom")
s1_rebalance_cadence = input.string("Annual", "Rebalance Cadence", group=group_s1, options=["Monthly", "Quarterly", "Annual"])

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 2: BD COLLINS 80/20 DCA PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════
group_s2 = "═══ Strategy 2: BD Collins 80/20 Parameters ═══"
s2_cadence = input.string("Quarterly", "DCA Cadence", group=group_s2, options=["Monthly", "Quarterly"])
s2_dd_band1 = input.float(15, "Drawdown Band 1 (%)", group=group_s2, minval=0, maxval=100, tooltip="Within this % of ATH")
s2_dd_band2 = input.float(25, "Drawdown Band 2 (%)", group=group_s2, minval=0, maxval=100)
s2_dd_band3 = input.float(35, "Drawdown Band 3 (%)", group=group_s2, minval=0, maxval=100)
s2_cash_deploy1 = input.float(20, "Cash Deploy Band 1 (%)", group=group_s2, minval=0, maxval=100, tooltip="% of cash to deploy within band 1")
s2_cash_deploy2 = input.float(40, "Cash Deploy Band 2 (%)", group=group_s2, minval=0, maxval=100)
s2_cash_deploy3 = input.float(60, "Cash Deploy Band 3 (%)", group=group_s2, minval=0, maxval=100)
s2_cash_deploy4 = input.float(80, "Cash Deploy Band 4 (%)", group=group_s2, minval=0, maxval=100, tooltip="Beyond band 3")
s2_cash_mode = input.bool(false, "Deploy from Current Period Only", group=group_s2, tooltip="If true, only deploy from current period's contribution. If false, deploy from entire cash bucket")

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 3: HENRIQUE CENTIEIRO'S STRATEGY (1/3 CASH) PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════
group_s3 = "═══ Strategy 3: Henrique Centieiro's Strategy ═══"
s3_cadence = input.string("Monthly", "DCA Cadence", group=group_s3, options=["Monthly", "Quarterly"])
s3_baseline_deploy = input.float(20, "Baseline Cash Deploy (%)", group=group_s3, minval=0, maxval=100, tooltip="% deployed when near ATH")
s3_dd_trigger1 = input.float(20, "Drawdown Trigger 1 (%)", group=group_s3, minval=0, maxval=100)
s3_dd_trigger2 = input.float(40, "Drawdown Trigger 2 (%)", group=group_s3, minval=0, maxval=100)
s3_dd_trigger3 = input.float(60, "Drawdown Trigger 3 (%)", group=group_s3, minval=0, maxval=100)
s3_cash_deploy1 = input.float(33.33, "Cash Deploy at Trigger 1 (%)", group=group_s3, minval=0, maxval=100)
s3_cash_deploy2 = input.float(66.67, "Cash Deploy at Trigger 2 (%)", group=group_s3, minval=0, maxval=100)
s3_cash_deploy3 = input.float(100, "Cash Deploy at Trigger 3 (%)", group=group_s3, minval=0, maxval=100)
s3_cash_mode = input.bool(false, "Deploy from Current Period Only", group=group_s3, tooltip="If true, only deploy from current period's contribution. If false, deploy from entire cash bucket")

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 4: BD COLLINS 14-WEEK SMA (ADVANCED) PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════
group_s4 = "═══ Strategy 4: BD Collins 14-week SMA (Advanced) ═══"
s4_sma_length = input.int(14, "SMA Length (weeks)", group=group_s4, minval=1, tooltip="Number of weeks for SMA calculation")
s4_exit_dd_pct = input.float(40, "Exit Drawdown (%)", group=group_s4, minval=1, maxval=99, tooltip="% drop from trailing high to trigger exit")
s4_cash_ticker = input.symbol("VDST", "Cash Asset (out of TQQQ)", group=group_s4, tooltip="Ticker held while OUT of TQQQ. VDST, SGOV, BIL, SHV are USD t-bills")
s4_use_violent = input.bool(false, "Violent-Break Exception", group=group_s4, tooltip="If ON, when weekly close is >10% below exit threshold, exit at Friday's close instead of Monday's open")
s4_vb_margin = input.float(10, "Violent-Break Margin (%)", group=group_s4, minval=0, maxval=50, tooltip="How far below exit threshold to trigger Friday close exit")

// --- new inputs -----------------------------------------------------------
s4_exit_trigger = input.string("Intraweek touch (book)", "Exit Trigger", group=group_s4,
     options=["Intraweek touch (book)", "Weekly close below (original)"],
     tooltip="Intraweek touch: exit once the week's LOW reaches the threshold, which is how the rule is written.\nWeekly close below: exit only if the week CLOSES at or under the threshold. This is the original behaviour and it changes results substantially.")
s4_peak_source = input.string("Weekly high / wick (book)", "Trailing Peak Source", group=group_s4,
     options=["Weekly high / wick (book)", "Weekly close"],
     tooltip="Which weekly value the trailing peak tracks. The book refers to the highest wick.")
s4_start_invested = input.bool(false, "Start Already Invested at First Bar", group=group_s4,
     tooltip="ON restores the original behaviour: the account is long from the very first bar on the chart, before any signal exists. OFF waits for the first valid entry signal, which is what the strategy actually instructs.")
s4_require_green = input.bool(false, "Require Green Weekly Candle to Enter", group=group_s4,
     tooltip="ON restores the original behaviour. This condition is not part of the published rules. On TQQQ history it is almost never binding, but it can delay an entry.")
s4_cost_pct = input.float(0.10, "Cost per Transaction (%)", group=group_s4, minval=0, maxval=5, step=0.01,
     tooltip="Commission plus slippage, charged on the way out and again on the way in. 0.10 is a reasonable retail assumption.")

// ═══════════════════════════════════════════════════════════════════════════
// DISPLAY OPTIONS
// ═══════════════════════════════════════════════════════════════════════════
group_display = "═══ Display Options ═══"
show_ath = input.bool(true, "Show ATH Line", group=group_display)
show_dd_bands = input.bool(true, "Show Drawdown Bands", group=group_display)
show_buy_signals = input.bool(true, "Show Buy Signals", group=group_display)
show_equity_curve = input.bool(true, "Show Equity Curve (separate pane)", group=group_display)

table_font_size = input.string("Normal", "Table Font Size", group=group_display,
     options=["Tiny", "Small", "Normal", "Large", "Huge"])
stats_table_position = input.string("Middle Right", "Stats Table Position", group=group_display,
     options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"])
desc_table_position = input.string("Bottom Right", "Description Table Position", group=group_display,
     options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"])

// Convert string inputs to Pine Script position constants
get_table_position(pos_string) =>
    pos_string == "Top Left" ? position.top_left :
     pos_string == "Top Center" ? position.top_center :
     pos_string == "Top Right" ? position.top_right :
     pos_string == "Middle Left" ? position.middle_left :
     pos_string == "Middle Center" ? position.middle_center :
     pos_string == "Middle Right" ? position.middle_right :
     pos_string == "Bottom Left" ? position.bottom_left :
     pos_string == "Bottom Center" ? position.bottom_center :
     position.bottom_right

get_font_size(size_string) =>
    size_string == "Tiny" ? size.tiny :
     size_string == "Small" ? size.small :
     size_string == "Normal" ? size.normal :
     size_string == "Large" ? size.large :
     size.huge

font_size = get_font_size(table_font_size)
stats_position = get_table_position(stats_table_position)
desc_position = get_table_position(desc_table_position)

// ═══════════════════════════════════════════════════════════════════════════
// DATA FETCHING
// ═══════════════════════════════════════════════════════════════════════════
lev_price = close  // Assume chart is on leveraged ETF
spy_price = request.security(spy_ticker, timeframe.period, close)

// ═══════════════════════════════════════════════════════════════════════════
// ALL-TIME HIGH TRACKING
// ═══════════════════════════════════════════════════════════════════════════
var float lev_ath = na
var float spy_ath = na

lev_ath := na(lev_ath) ? lev_price : math.max(lev_ath, lev_price)
spy_ath := na(spy_ath) ? spy_price : math.max(spy_ath, spy_price)

lev_drawdown = 100 * (lev_ath - lev_price) / lev_ath
spy_drawdown = 100 * (spy_ath - spy_price) / spy_ath

// ═══════════════════════════════════════════════════════════════════════════
// DATE/TIME HELPERS
// ═══════════════════════════════════════════════════════════════════════════
is_new_month = ta.change(month) != 0
current_quarter = math.floor((month - 1) / 3) + 1
is_new_quarter = ta.change(current_quarter) != 0
is_new_year = ta.change(year) != 0

get_period_trigger(cadence) =>
    cadence == "Monthly" ? is_new_month :
     cadence == "Quarterly" ? is_new_quarter :
     is_new_year

// ═══════════════════════════════════════════════════════════════════════════
// MARKET BOTTOM DETECTION (for Strategy 1)
// ═══════════════════════════════════════════════════════════════════════════
var bool in_bottom_period = false
var int bottom_year = na
var bool spy_was_in_deep_drawdown = false

// Track when SPY enters deep drawdown
if spy_drawdown >= s1_bottom_threshold
    spy_was_in_deep_drawdown := true

// Detect recovery after drawdown (market bottom confirmation)
recovery_threshold = s1_bottom_threshold * (100 - s1_recovery_pct) / 100
if spy_was_in_deep_drawdown and spy_drawdown <= recovery_threshold and not in_bottom_period
    in_bottom_period := true
    bottom_year := year
    spy_was_in_deep_drawdown := false  // Reset for next cycle

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 1: STARS (EKHOLM)
// ═══════════════════════════════════════════════════════════════════════════
var float s1_lev_shares = 0.0
var float s1_spy_shares = 0.0
var bool s1_triggered = false
var float s1_total_contributed = 0.0

// Initial allocation
if bar_index == 0
    s1_lev_shares := (initial_capital * s1_base_lev_pct / 100) / lev_price
    s1_spy_shares := (initial_capital * s1_base_spy_pct / 100) / spy_price
    s1_total_contributed := initial_capital

// Accumulate monthly contributions as cash
var float s1_cash = 0.0
if is_new_month and bar_index > 0
    s1_cash := s1_cash + monthly_contribution
    s1_total_contributed := s1_total_contributed + monthly_contribution

s1_lev_value = s1_lev_shares * lev_price
s1_spy_value = s1_spy_shares * spy_price
s1_total_value = s1_lev_value + s1_spy_value + s1_cash

s1_should_rebalance = get_period_trigger(s1_rebalance_cadence) and not in_bottom_period

// Check trigger - activates when TQQQ drops 40%+
var bool s1_just_triggered = false
var int s1_ath_recovery_year = na
s1_just_triggered := false

if lev_drawdown >= s1_drawdown_trigger and not s1_triggered
    s1_triggered := true
    s1_just_triggered := true
    s1_ath_recovery_year := na  // Clear recovery tracking when trigger activates

// Track when TQQQ reaches new ATH (0% drawdown) while triggered
if s1_triggered and lev_drawdown <= 0 and na(s1_ath_recovery_year)
    s1_ath_recovery_year := year

// Reset trigger at annual rebalance in the year AFTER TQQQ hit new ATH
if s1_triggered and not na(s1_ath_recovery_year) and year > s1_ath_recovery_year and is_new_year
    s1_triggered := false
    s1_ath_recovery_year := na

// Reset trigger after bottom recovery period ends (go back to 20% allocation)
if in_bottom_period and year > bottom_year
    in_bottom_period := false
    s1_triggered := false  // Reset to base 20% TQQQ allocation
    s1_ath_recovery_year := na  // Clear recovery year tracking

// Rebalance logic
var bool s1_buy_signal = false
var string s1_signal_type = ""
s1_buy_signal := false

if s1_should_rebalance and bar_index > 0
    target_lev_pct = s1_triggered ? s1_new_lev_pct : s1_base_lev_pct
    target_spy_pct = 100 - target_lev_pct

    // Include accumulated cash in rebalance
    total_portfolio = s1_lev_value + s1_spy_value + s1_cash

    target_lev_value = total_portfolio * target_lev_pct / 100
    target_spy_value = total_portfolio * target_spy_pct / 100

    s1_lev_shares := target_lev_value / lev_price
    s1_spy_shares := target_spy_value / spy_price
    s1_cash := 0.0  // All cash deployed during rebalance

    s1_buy_signal := true
    s1_signal_type := s1_triggered ? "triggered" : "normal"

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 2: BD COLLINS 80/20 DCA
// ═══════════════════════════════════════════════════════════════════════════
var float s2_shares = 0.0
var float s2_cash = 0.0
var int s2_months_elapsed = 0
var float s2_total_contributed = 0.0

// Initial allocation
if bar_index == 0
    s2_shares := initial_capital / lev_price
    s2_cash := 0.0
    s2_total_contributed := initial_capital

s2_equity = s2_shares * lev_price
s2_total = s2_equity + s2_cash

s2_is_period = get_period_trigger(s2_cadence)

// Accumulate monthly contributions
if is_new_month and bar_index > 0
    s2_cash := s2_cash + monthly_contribution
    s2_months_elapsed := s2_months_elapsed + 1
    s2_total_contributed := s2_total_contributed + monthly_contribution

// Determine cash deployment %
get_s2_deploy_pct(dd) =>
    dd <= s2_dd_band1 ? s2_cash_deploy1 :
     dd <= s2_dd_band2 ? s2_cash_deploy2 :
     dd <= s2_dd_band3 ? s2_cash_deploy3 :
     s2_cash_deploy4

var bool s2_buy_signal = false
var float s2_deploy_pct_used = 0.0
s2_buy_signal := false
s2_deploy_pct_used := 0.0  // Reset each bar

if s2_is_period and bar_index > 0 and s2_cash > 0
    deploy_pct = get_s2_deploy_pct(lev_drawdown)

    cash_to_deploy = s2_cash_mode ?
         (monthly_contribution * deploy_pct / 100) :
         (s2_cash * deploy_pct / 100)

    if cash_to_deploy > s2_cash
        cash_to_deploy := s2_cash

    shares_to_buy = cash_to_deploy / lev_price
    s2_shares := s2_shares + shares_to_buy
    s2_cash := s2_cash - cash_to_deploy

    if cash_to_deploy > 0
        s2_buy_signal := true
        s2_deploy_pct_used := deploy_pct  // Only set when actually buying

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 3: HENRIQUE CENTIEIRO'S STRATEGY (1/3 CASH)
// ═══════════════════════════════════════════════════════════════════════════
var float s3_shares = 0.0
var float s3_cash = 0.0
var int s3_months_elapsed = 0
var float s3_total_contributed = 0.0

// Initial allocation
if bar_index == 0
    s3_shares := initial_capital / lev_price
    s3_cash := 0.0
    s3_total_contributed := initial_capital

s3_equity = s3_shares * lev_price
s3_total = s3_equity + s3_cash

s3_is_period = get_period_trigger(s3_cadence)

// Accumulate monthly contributions
if is_new_month and bar_index > 0
    s3_cash := s3_cash + monthly_contribution
    s3_months_elapsed := s3_months_elapsed + 1
    s3_total_contributed := s3_total_contributed + monthly_contribution

// Determine cash deployment %
get_s3_deploy_pct(dd) =>
    dd >= s3_dd_trigger3 ? s3_cash_deploy3 :
     dd >= s3_dd_trigger2 ? s3_cash_deploy2 :
     dd >= s3_dd_trigger1 ? s3_cash_deploy1 :
     s3_baseline_deploy

var bool s3_buy_signal = false
var float s3_deploy_pct_used = 0.0
s3_buy_signal := false
s3_deploy_pct_used := 0.0  // Reset each bar

if s3_is_period and bar_index > 0 and s3_cash > 0
    deploy_pct = get_s3_deploy_pct(lev_drawdown)

    cash_to_deploy = s3_cash_mode ?
         (monthly_contribution * deploy_pct / 100) :
         (s3_cash * deploy_pct / 100)

    if cash_to_deploy > s3_cash
        cash_to_deploy := s3_cash

    shares_to_buy = cash_to_deploy / lev_price
    s3_shares := s3_shares + shares_to_buy
    s3_cash := s3_cash - cash_to_deploy

    if cash_to_deploy > 0
        s3_buy_signal := true
        s3_deploy_pct_used := deploy_pct  // Only set when actually buying

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY 4: BD COLLINS 14-WEEK SMA (ADVANCED)
// ═══════════════════════════════════════════════════════════════════════════

// Get confirmed weekly data (previous complete week [1] to avoid repainting)
[s4_wOpen_p, s4_wHigh_p, s4_wLow_p, s4_wClose_p, s4_wSMA_p] = request.security(
     syminfo.tickerid, "W",
     [open[1], high[1], low[1], close[1], ta.sma(close, s4_sma_length)[1]],
     lookahead=barmerge.lookahead_off)

// For plotting the SMA on chart
s4_sma_plot = request.security(syminfo.tickerid, "W", ta.sma(close, s4_sma_length), lookahead=barmerge.lookahead_off)

s4_isNewWeek = timeframe.change("W")

// Cash asset data
[s4_cashOpen, s4_cashClose] = request.security(s4_cash_ticker, timeframe.period, [open, close],
     lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

s4_cashClose_p = request.security(s4_cash_ticker, "W", close[1],
     lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Is the cash ticker returning usable data on this bar?
s4_cashLive = not na(s4_cashClose) and s4_cashClose > 0
var float s4_cashLastPx = na
if s4_cashLive
    s4_cashLastPx := s4_cashClose

// Has the cash ticker ever been unavailable while the strategy was flat?
var bool s4_cashGap = false

// Cost multiplier, applied to each leg of a switch
s4_costMult = 1.0 - s4_cost_pct / 100.0

// Strategy state
var bool  s4_inPos        = false
var float s4_entryPrice   = na
var float s4_trailHigh    = na
var float s4_exitThresh   = na
var int   s4_numBuys      = 0
var int   s4_numSells     = 0
var int   s4_numViolent   = 0

// Position tracking.
// Cash is held EITHER as shares of the cash ticker (when it has data) OR as
// plain dollars (when it does not). The two are never mixed, which is what
// produced the $1.00 pricing artefact in the original.
var float s4_shares_tqqq  = 0.0
var float s4_cash_shares  = 0.0
var float s4_cash_usd     = 0.0
var bool  s4_holding_tqqq = false
var float s4_total_contributed = 0.0

// Backtest metrics
var int   s4_nTrades      = 0
var int   s4_nWins        = 0
var float s4_peak_equity  = na
var float s4_max_dd       = 0.0

// Initialize
if bar_index == 0
    s4_total_contributed := initial_capital
    s4_peak_equity := initial_capital
    if s4_start_invested
        // original behaviour: long from bar one, before any signal has been generated
        s4_shares_tqqq  := initial_capital / lev_price
        s4_holding_tqqq := true
        s4_inPos        := true
        s4_entryPrice   := lev_price
        s4_trailHigh    := na
        s4_exitThresh   := na
    else
        // Wait for the first genuine entry signal
        s4_holding_tqqq := false
        s4_inPos        := false
        if s4_cashLive
            s4_cash_shares := initial_capital / s4_cashClose
        else
            s4_cash_usd := initial_capital
            s4_cashGap  := true

// Accumulate monthly contributions based on current position
if is_new_month and bar_index > 0
    s4_total_contributed := s4_total_contributed + monthly_contribution
    if s4_holding_tqqq
        if not na(lev_price) and lev_price > 0
            s4_shares_tqqq := s4_shares_tqqq + (monthly_contribution / lev_price)
    else
        if s4_cash_shares > 0 and s4_cashLive
            s4_cash_shares := s4_cash_shares + (monthly_contribution / s4_cashClose)
        else
            s4_cash_usd := s4_cash_usd + monthly_contribution

// Signal detection
var bool s4_buy_signal = false
var bool s4_sell_signal = false
var bool s4_violent_exit = false
s4_buy_signal := false
s4_sell_signal := false
s4_violent_exit := false

// Execute signals on new week
if s4_isNewWeek and not na(s4_wClose_p) and not na(s4_wOpen_p) and not na(s4_wSMA_p)

    // Which weekly value the trailing peak follows
    s4_peakVal = s4_peak_source == "Weekly close" ? s4_wClose_p : s4_wHigh_p

    // Initialize trailing peak if needed (first week in position)
    if s4_inPos and na(s4_trailHigh)
        s4_trailHigh  := s4_peakVal
        s4_exitThresh := s4_trailHigh * (1 - s4_exit_dd_pct / 100.0)

    // FIX: update the trailing peak BEFORE testing the exit, so the threshold
    // always reflects the same week that is being tested. The original tested against a
    // threshold built from the week before, which delayed some exits.
    if s4_inPos and not na(s4_trailHigh) and s4_peakVal > s4_trailHigh
        s4_trailHigh  := s4_peakVal
        s4_exitThresh := s4_trailHigh * (1 - s4_exit_dd_pct / 100.0)

    // EXIT LOGIC
    s4_exitHit = na(s4_exitThresh) ? false : (s4_exit_trigger == "Weekly close below (original)" ? s4_wClose_p <= s4_exitThresh : s4_wLow_p <= s4_exitThresh)

    if s4_inPos and not na(s4_exitThresh) and s4_exitHit
        vbLevel = s4_exitThresh * (1 - s4_vb_margin / 100.0)
        isVBreak = s4_use_violent and s4_wClose_p < vbLevel

        if isVBreak
            s4_violent_exit := true
            s4_numViolent := s4_numViolent + 1

        if s4_holding_tqqq and s4_shares_tqqq > 0
            // Friday close for a violent break, Monday open otherwise
            sellPx = (isVBreak and not na(s4_wClose_p) and s4_wClose_p > 0) ? s4_wClose_p : open
            buyPx  = isVBreak ? s4_cashClose_p : s4_cashOpen

            if not na(sellPx) and sellPx > 0
                proceeds = s4_shares_tqqq * sellPx * s4_costMult
                if proceeds > 0
                    // second leg is only charged if a cash instrument is actually bought
                    parked = (not na(buyPx) and buyPx > 0) ? proceeds * s4_costMult : proceeds
                    if not na(buyPx) and buyPx > 0
                        s4_cash_shares := parked / buyPx
                        s4_cash_usd    := 0.0
                    else
                        s4_cash_shares := 0.0
                        s4_cash_usd    := parked
                        s4_cashGap     := true
                    s4_shares_tqqq  := 0.0
                    s4_holding_tqqq := false
                    s4_nTrades := s4_nTrades + 1

                    if not na(s4_entryPrice) and sellPx > s4_entryPrice
                        s4_nWins := s4_nWins + 1

                    s4_sell_signal := true
                    s4_numSells := s4_numSells + 1
                    s4_inPos := false
                    s4_entryPrice := na
                    s4_trailHigh := na
                    s4_exitThresh := na

    // ENTRY LOGIC
    greenWeek = s4_wClose_p > s4_wOpen_p
    aboveSMA  = s4_wClose_p > s4_wSMA_p
    entryOK   = aboveSMA and (s4_require_green ? greenWeek : true)

    if not s4_inPos and entryOK
        if not s4_holding_tqqq and not na(open) and open > 0
            // Value the parked balance at Monday's open, not at last close
            sellCashPx = s4_cashLive and not na(s4_cashOpen) and s4_cashOpen > 0 ? s4_cashOpen : s4_cashLastPx
            proceeds = s4_cash_shares > 0 and not na(sellCashPx) ? s4_cash_shares * sellCashPx * s4_costMult : s4_cash_usd
            if proceeds > 0
                s4_shares_tqqq  := proceeds * s4_costMult / open
                s4_cash_shares  := 0.0
                s4_cash_usd     := 0.0
                s4_holding_tqqq := true

                s4_buy_signal := true
                s4_numBuys := s4_numBuys + 1
                s4_inPos := true
                s4_entryPrice := open
                s4_trailHigh  := s4_peakVal
                s4_exitThresh := s4_trailHigh * (1 - s4_exit_dd_pct / 100.0)

// Calculate equity
s4_cashPxNow = s4_cashLive ? s4_cashClose : s4_cashLastPx
s4_parkedUSD = s4_cash_shares > 0 and not na(s4_cashPxNow) ? s4_cash_shares * s4_cashPxNow : s4_cash_usd
s4_equity = s4_holding_tqqq ? s4_shares_tqqq * lev_price : s4_parkedUSD
s4_total = s4_equity

// Track max drawdown
if na(s4_peak_equity) or s4_equity > s4_peak_equity
    s4_peak_equity := s4_equity

if not na(s4_peak_equity) and s4_peak_equity > 0
    s4_dd = (s4_peak_equity - s4_equity) / s4_peak_equity
    if s4_dd > s4_max_dd
        s4_max_dd := s4_dd

// ═══════════════════════════════════════════════════════════════════════════
// SELECT ACTIVE STRATEGY
// ═══════════════════════════════════════════════════════════════════════════
active_equity = strategy_choice == "Strategy 1: Stars (Ekholm)" ? s1_total_value :
     strategy_choice == "Strategy 2: BD Collins 80/20 DCA" ? s2_total :
     strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)" ? s3_total :
     s4_total

active_buy_signal = strategy_choice == "Strategy 1: Stars (Ekholm)" ? s1_buy_signal :
     strategy_choice == "Strategy 2: BD Collins 80/20 DCA" ? s2_buy_signal :
     strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)" ? s3_buy_signal :
     s4_buy_signal

active_total_contributed = strategy_choice == "Strategy 1: Stars (Ekholm)" ? s1_total_contributed :
     strategy_choice == "Strategy 2: BD Collins 80/20 DCA" ? s2_total_contributed :
     strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)" ? s3_total_contributed :
     s4_total_contributed

// Determine buy signal color based on strategy and deployment
buy_signal_color = color.lime
sell_signal_color = color.red
if strategy_choice == "Strategy 1: Stars (Ekholm)"
    buy_signal_color := s1_signal_type == "triggered" ? color.orange : color.aqua
else if strategy_choice == "Strategy 2: BD Collins 80/20 DCA"
    buy_signal_color := s2_deploy_pct_used >= s2_cash_deploy4 ? color.red :
         s2_deploy_pct_used >= s2_cash_deploy3 ? color.orange :
         s2_deploy_pct_used >= s2_cash_deploy2 ? color.yellow :
         color.lime
else if strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)"
    buy_signal_color := s3_deploy_pct_used >= s3_cash_deploy3 ? color.red :
         s3_deploy_pct_used >= s3_cash_deploy2 ? color.orange :
         color.lime
else if strategy_choice == "Strategy 4: BD Collins 14-week SMA"
    buy_signal_color := color.lime
    sell_signal_color := color.red

// ═══════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ═══════════════════════════════════════════════════════════════════════════

// ATH Line
plot(show_ath ? lev_ath : na, "ATH", color=color.new(color.blue, 0), linewidth=2, style=plot.style_line)

// Drawdown Bands (depends on strategy)
var float band1_price = na
var float band2_price = na
var float band3_price = na

if strategy_choice == "Strategy 2: BD Collins 80/20 DCA"
    band1_price := lev_ath * (1 - s2_dd_band1 / 100)
    band2_price := lev_ath * (1 - s2_dd_band2 / 100)
    band3_price := lev_ath * (1 - s2_dd_band3 / 100)
else if strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)"
    band1_price := lev_ath * (1 - s3_dd_trigger1 / 100)
    band2_price := lev_ath * (1 - s3_dd_trigger2 / 100)
    band3_price := lev_ath * (1 - s3_dd_trigger3 / 100)
else
    band1_price := na
    band2_price := na
    band3_price := na

plot(show_dd_bands ? band1_price : na, "Band 1", color=color.new(color.red, 60), linewidth=1, style=plot.style_line)
plot(show_dd_bands ? band2_price : na, "Band 2", color=color.new(color.orange, 60), linewidth=1, style=plot.style_line)
plot(show_dd_bands ? band3_price : na, "Band 3", color=color.new(color.green, 60), linewidth=1, style=plot.style_line)

// Strategy 4: 14-week SMA line
plot(strategy_choice == "Strategy 4: BD Collins 14-week SMA" ? s4_sma_plot : na, "14-week SMA",
     color=color.new(color.purple, 0), linewidth=2, style=plot.style_line)

// Strategy 4: Trailing high and exit threshold
plot(strategy_choice == "Strategy 4: BD Collins 14-week SMA" and show_dd_bands and s4_inPos ? s4_trailHigh : na,
     "S4 Trail High", color=color.new(color.green, 0), style=plot.style_linebr, linewidth=1)
plot(strategy_choice == "Strategy 4: BD Collins 14-week SMA" and show_dd_bands and s4_inPos ? s4_exitThresh : na,
     "S4 Exit Threshold", color=color.new(color.red, 0), style=plot.style_linebr, linewidth=1)

// Strategy 4: Background highlight
bgcolor(strategy_choice == "Strategy 4: BD Collins 14-week SMA" and show_dd_bands ?
     (s4_inPos ? color.new(color.green, 95) : color.new(color.red, 95)) : na, title="S4 State BG")

// Buy Signals (color-coded by deployment type)
plotshape(show_buy_signals and active_buy_signal, "Buy Signal", shape.triangleup, location.belowbar,
     color=color.new(buy_signal_color, 0), size=size.small)

// Sell Signals (for Strategy 4)
plotshape(show_buy_signals and strategy_choice == "Strategy 4: BD Collins 14-week SMA" and s4_sell_signal,
     "Sell Signal", shape.triangledown, location.abovebar,
     color=color.new(sell_signal_color, 0), size=size.small)

// Label when Strategy 1 shifts to 40% TQQQ allocation
if strategy_choice == "Strategy 1: Stars (Ekholm)" and s1_just_triggered
    label.new(bar_index, high, "40% TQQQ\nTRIGGERED",
         style=label.style_label_down, color=color.new(color.orange, 0),
         textcolor=color.white, size=size.normal)

// ═══════════════════════════════════════════════════════════════════════════
// EQUITY CURVE (as separate plot)
// ═══════════════════════════════════════════════════════════════════════════
equity_to_plot = show_equity_curve ? active_equity : na
plot(equity_to_plot, "Portfolio Value", color=color.new(color.purple, 0), linewidth=2, display=display.none)

// ═══════════════════════════════════════════════════════════════════════════
// RISK METRICS (SHARPE & SORTINO RATIOS)
// ═══════════════════════════════════════════════════════════════════════════
var array<float> monthly_returns = array.new<float>()
var float prev_month_equity = na
risk_free_rate = 0.0  // Assume 0% risk-free rate for simplicity

// Calculate monthly returns
if is_new_month and bar_index > 0
    if not na(prev_month_equity) and prev_month_equity > 0
        monthly_return = (active_equity - prev_month_equity) / prev_month_equity
        array.push(monthly_returns, monthly_return)

        // Keep only last 60 months (5 years) for calculation
        if array.size(monthly_returns) > 60
            array.shift(monthly_returns)

    prev_month_equity := active_equity

// Calculate Sharpe Ratio
sharpe_ratio = 0.0
if array.size(monthly_returns) > 1
    mean_return = array.avg(monthly_returns)
    std_dev = array.stdev(monthly_returns)

    if std_dev > 0
        // Annualized Sharpe Ratio
        sharpe_ratio := (mean_return - risk_free_rate / 12) / std_dev * math.sqrt(12)

// Calculate Sortino Ratio (only downside deviation)
sortino_ratio = 0.0
if array.size(monthly_returns) > 1
    mean_return = array.avg(monthly_returns)

    // Calculate downside deviation (only negative returns)
    var array<float> downside_returns = array.new<float>()
    array.clear(downside_returns)

    for i = 0 to array.size(monthly_returns) - 1
        ret = array.get(monthly_returns, i)
        if ret < 0
            array.push(downside_returns, ret)

    if array.size(downside_returns) > 0
        downside_dev = array.stdev(downside_returns)
        if downside_dev > 0
            // Annualized Sortino Ratio
            sortino_ratio := (mean_return - risk_free_rate / 12) / downside_dev * math.sqrt(12)

// ═══════════════════════════════════════════════════════════════════════════
// STATISTICS TABLE
// ═══════════════════════════════════════════════════════════════════════════
var table stats_table = table.new(stats_position, 2, 12, border_width=1)

if barstate.islast
    table.cell(stats_table, 0, 0, "Metric", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=font_size)
    table.cell(stats_table, 1, 0, "Value", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=font_size)

    table.cell(stats_table, 0, 1, "Strategy", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 1, strategy_choice, text_size=font_size, text_color=color.white)

    table.cell(stats_table, 0, 2, "Portfolio Value", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 2, "$" + str.tostring(active_equity, "#,###.00"), text_size=font_size, text_color=color.lime)

    table.cell(stats_table, 0, 3, "Total Contributed", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 3, "$" + str.tostring(active_total_contributed, "#,###.00"), text_size=font_size, text_color=color.white)

    table.cell(stats_table, 0, 4, "Initial Capital", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 4, "$" + str.tostring(initial_capital, "#,###"), text_size=font_size, text_color=color.white)

    total_return_pct = 100 * (active_equity - active_total_contributed) / active_total_contributed
    table.cell(stats_table, 0, 5, "Total Return", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 5, str.tostring(total_return_pct, "#,###.00") + "%", text_size=font_size,
         text_color=total_return_pct > 0 ? color.lime : color.red)

    table.cell(stats_table, 0, 6, "Current Drawdown", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 6, str.tostring(lev_drawdown, "0.00") + "%", text_size=font_size,
         text_color=lev_drawdown > 20 ? color.red : color.yellow)

    table.cell(stats_table, 0, 7, "ATH", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 7, "$" + str.tostring(lev_ath, "0.00"), text_size=font_size, text_color=color.white)

    table.cell(stats_table, 0, 8, "Sharpe Ratio", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 8, str.tostring(sharpe_ratio, "0.00"), text_size=font_size,
         text_color=sharpe_ratio > 1 ? color.lime : (sharpe_ratio > 0 ? color.yellow : color.red))

    table.cell(stats_table, 0, 9, "Sortino Ratio", text_size=font_size, text_color=color.white)
    table.cell(stats_table, 1, 9, str.tostring(sortino_ratio, "0.00"), text_size=font_size,
         text_color=sortino_ratio > 1 ? color.lime : (sortino_ratio > 0 ? color.yellow : color.red))

    // Strategy-specific info
    if strategy_choice == "Strategy 2: BD Collins 80/20 DCA"
        table.cell(stats_table, 0, 10, "Cash Reserve", text_size=font_size, text_color=color.white)
        table.cell(stats_table, 1, 10, "$" + str.tostring(s2_cash, "#,###.00"), text_size=font_size, text_color=color.white)
    else if strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)"
        table.cell(stats_table, 0, 10, "Cash Reserve", text_size=font_size, text_color=color.white)
        table.cell(stats_table, 1, 10, "$" + str.tostring(s3_cash, "#,###.00"), text_size=font_size, text_color=color.white)
    else if strategy_choice == "Strategy 4: BD Collins 14-week SMA"
        s4_position_text = s4_holding_tqqq ? "IN " + leveraged_ticker : (s4_cash_shares > 0 ? "IN " + s4_cash_ticker : "IN CASH")
        s4_win_rate = s4_nTrades > 0 ? s4_nWins * 100.0 / s4_nTrades : 0.0
        s4_trades_text = str.tostring(s4_nTrades) + " closed (" + str.tostring(s4_win_rate, "#.#") + "% win)"
        table.cell(stats_table, 0, 10, "Position / Trades", text_size=font_size, text_color=color.white)
        table.cell(stats_table, 1, 10, s4_position_text + " | " + s4_trades_text, text_size=font_size,
             text_color=s4_holding_tqqq ? color.lime : color.yellow)
        s4_mode_text = (s4_exit_trigger == "Weekly close below (original)" ? "close" : "touch") +
             (s4_start_invested ? " | seeded" : "") + (s4_require_green ? " | green" : "") +
             (s4_use_violent ? " | VB" : "")
        table.cell(stats_table, 0, 11, s4_cashGap ? "Mode (cash gap!)" : "Mode", text_size=font_size,
             text_color=s4_cashGap ? color.orange : color.white)
        table.cell(stats_table, 1, 11, s4_cashGap ? s4_mode_text + " | " + s4_cash_ticker + " had no data" : s4_mode_text,
             text_size=font_size, text_color=s4_cashGap ? color.orange : color.gray)
    else
        triggered_text = s1_triggered ? "YES (40%)" : "NO (20%)"
        table.cell(stats_table, 0, 10, "Trigger Active", text_size=font_size, text_color=color.white)
        table.cell(stats_table, 1, 10, triggered_text, text_size=font_size,
             text_color=s1_triggered ? color.orange : color.lime)

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY DESCRIPTION & LEGEND TABLE
// ═══════════════════════════════════════════════════════════════════════════
var table desc_table = table.new(desc_position, 1, 6, border_width=1)

if barstate.islast
    // Title
    table.cell(desc_table, 0, 0, "STRATEGY INFO", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=font_size)

    // Strategy description based on selection
    if strategy_choice == "Strategy 1: Stars (Ekholm)"
        table.cell(desc_table, 0, 1, "Stars is a rebalancing strategy that maintains a 20% TQQQ / 80% SPY allocation.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 2, "Monthly contributions accumulate as cash and are deployed during rebalances.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 3, "If TQQQ drops 40%+, the next rebalance shifts to 40% TQQQ / 60% SPY.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 4, "Rebalancing is skipped in the 1st year after a market bottom is detected.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 5, "🔺 Aqua = Normal Rebalance | 🔺 Orange = 40% Trigger Active", text_size=font_size, text_color=color.yellow, text_halign=text.align_left)

    else if strategy_choice == "Strategy 2: BD Collins 80/20 DCA"
        table.cell(desc_table, 0, 1, "BD Collins 80/20 DCA deploys cash based on distance from all-time high.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 2, "Monthly contributions accumulate, then deploy at your chosen cadence (quarterly default).", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 3, "Within 15% ATH → 20% cash | 15-25% → 40% | 25-35% → 60% | Beyond 35% → 80%", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 4, "This creates 4 deployment zones that automatically buy more during deeper corrections.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 5, "🔺 Green = 20% | 🔺 Yellow = 40% | 🔺 Orange = 60% | 🔺 Red = 80%", text_size=font_size, text_color=color.yellow, text_halign=text.align_left)

    else if strategy_choice == "Strategy 3: Henrique Centieiro's Strategy (1/3 Cash)"
        table.cell(desc_table, 0, 1, "Henrique Centieiro's Strategy uses a simplified 3-tier approach for cash deployment.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 2, "Monthly contributions accumulate and deploy based on drawdown triggers.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 3, "Near ATH → 20% baseline | 20% drop → 33% | 40% drop → 67% | 60% drop → 100%", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 4, "Simpler than BD Collins with clear trigger levels for increasing aggression.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 5, "🔺 Green = 20-33% | 🔺 Orange = 67% | 🔺 Red = 100%", text_size=font_size, text_color=color.yellow, text_halign=text.align_left)

    else  // Strategy 4: BD Collins 14-week SMA
        table.cell(desc_table, 0, 1, "BD Collins 14-week SMA (Advanced) uses confirmed weekly data for non-repainting signals.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 2, "ENTRY: Monday open after weekly close ABOVE " + str.tostring(s4_sma_length) + "W-SMA" + (s4_require_green ? " AND green weekly candle." : "."), text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 3, "EXIT: Monday open once the week's " + (s4_exit_trigger == "Weekly close below (original)" ? "CLOSE is at or below" : "LOW touches") + " trailing_peak × (1 - DD%). Holds " + s4_cash_ticker + " when out.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 4, "VIOLENT BREAK: If weekly close >10% below threshold, exits Friday close instead.", text_size=font_size, text_color=color.white, text_halign=text.align_left)
        table.cell(desc_table, 0, 5, "🔺 Green = Buy (Mon open) | 🔻 Red = Sell (Mon open or Fri close)", text_size=font_size, text_color=color.yellow, text_halign=text.align_left)
````
