# DCA + DRIP Simulator [WynTrader]

- url: https://www.tradingview.com/script/RzY0hwBn-DCA-DRIP-Simulator-WynTrader/
- type: indicator
- pine_id: PUB;e8e80ef91d86429d8b29c7f9bf4805d7
- version: 27.0

## Description

DCA + DRIP Simulator [WynTrader]

Hello my friend

This tool simulates real effect of an investment  plan when a disciplined DCA+DRIP strategy compounds growth, compared to simply investing and pocketing the dividends. It applies to all kind of security with or without dividend paid, so you can compare what tickers you want..

This isn't a simplified estimate. It reads real price, dividend, and split data directly from TradingView — bar by bar, month by month — and reconstructs what a real investor would have experienced. Apply it to any security — dividend-paying or not, stock, ETF, closed-end fund — and see the picture side by side: with DRIP and no DRIP.

█ CONCEPTS

This indicator illustrates clearly that DCA+DRIP can build more wealth over time than a standard monthly investment approach where dividends are simply cashed out with no plan in mind.

— Dollar Cost Averaging (DCA) means investing a consistent amount every single month, no matter what the market does. When prices drop, your money buys more shares automatically. Over time, this discipline lowers your average cost and keeps emotion out of the equation.

— Dividend Re-Investment Plan (DRIP) means every dividend payment goes straight back into buying more shares, instead of sitting idle. Those extra shares generate their own dividends, which buy more shares — a compounding effect that grows the longer you stay invested.
Together, DCA + DRIP compound together over time.

█ HOW IT WORKS

Set your chart to MONTHLY intervals, else the table is set to zero.

Once configured, the indicator reads price, dividend, and split data directly from TradingView and simulates what a real investor would have experienced: buying every month (DCA), collecting dividends, reinvesting them automatically (DRIP) and adjust data with Splits.

█ FEATURES

[i][b]Configurable DCA Parameters[/b][/i]
Set your initial deposit, monthly contribution, and an optional annual DCA increase (e.g. +5%/yr to reflect salary growth and inflation over time). A withholding tax rate can also be applied for US-listed securities (e.g. 15% for ZQQ).

[i][b]Flexible Date Range[/b][/i]
The simulation runs from your chosen: a) [i]Number of years[/i] to date; b) [i]Start date[/i] to date; c)[i] Visible chart[/i] from Start/End  dates of your chart screen.

[i][b]Side-by-Side Comparison[/b][/i]
Every result is shown in two columns simultaneously — With DRIP and No DRIP. Capital, monthly dividend income, total dividends received, net gain, and share count — all at a glance.

[i][b]Fully Customizable Table Display[/b][/i]
Position, text size, and all colors are adjustable directly from the settings panel, so the table fits cleanly on any chart layout.

█ CONCLUSION

Load this indicator on any security — stock, ETF, closed-end fund, with or without dividends. DCA+DRIP Simulator applies to all of them, though DRIP's effect is most visible on dividend-paying securities, where reinvested dividends compound over time.

The difference between With DRIP and No DRIP can be significant over time.

█ WynTrader

I am not a Pine Script programmer — I am an investor who builds tools to support my own analysis, and maybe helps others. A few anomalies may have slipped through and there is likely room for improvement. 

Hope you find this little tool useful. Enjoy!
WynTrader

## Source Code

````pine
//@version=6
indicator(title="DCA + DRIP Simulator [WynTrader]", shorttitle="DCA+DRIP_wt", overlay=true, dynamic_requests=true)

// *************************************************************************
// DCA + DRIP Simulator [WynTrader]
// Shows how a smart and steady investment plan can really boost your savings, applying DCA+DRIP
//
// DCA : Dollar Cost Averaging means investing monthly a regular constant amount no matter what the market does.
// DRIP : Dividend Re-Investment Plan uses your dividend payouts to buy more shares.
// Buying (DCA+DRIP) consistently and letting your money snowball beats a regular strategy where you just pocket the dividends.
//
// *************************************************************************
// ~~~ Update 2026-10-04 ~~~
//  Gains: Avg/Year % is now a simple yearly average.
//  Yield: last payment X payments per year / price.
//  Last Pay: last single payment, with its frequency (W/SM/M/Q/S/A).
//  Table: Horizontal or Vertical, improved colors, tooltips on all cells.
//  Text size in points (8 to 16), wider spacing, longer symbol name.
//  Table colors adapt to a light or dark chart background.
//
// ~~~ Updates 2026-08-08 to 2026-10-03 ~~~
//  Day-by-day calendar: deposits, splits, ex-dates, DRIP on payment day.
//  Same results on D, W and M, and with the ADJ button ON or OFF.
//  Split-month value and dividend/split detection fixed; faster loading.
// *************************************************************************

// ─── INPUTS ───────────────────────────────────────────────────────────────
i_initial_deposit      = input.int(10000, "Initial ($)",   minval=0, step=100, inline="dep")
i_monthly_deposit      = input.int(500,   "Monthly ($)",   minval=0, step=50,  inline="dep",
               tooltip="INITIAL: amount invested on the first day of the period. MONTHLY: amount added every month (DCA).")
i_annual_increase_pct  = input.int(5,     "Aug. %/y",      minval=0, maxval=30, inline="ar")
i_tax_pct              = input.int(0,     "Tax %",         minval=0, maxval=30, inline="ar",
               tooltip="AUG. %/Y: yearly increase of the monthly amount, applied every 12 months. TAX %: tax withheld on dividends before reinvestment (e.g. 15% non-recoverable US withholding tax in a CELI/TFSA).")
i_date_mode            = input.string("Start Date", "Choose",
               options=["Nb Years/Months", "Start Date", "Visible Range"], inline="mode",
               tooltip="NB YEARS/MONTHS: goes back N years/months from the current month, starting on day 1 of that month. START DATE: uses the exact Year/Month/Day entered below. VISIBLE RANGE: ignores the settings below and uses the Start/End dates of the current screen.")
i_start_year           = input.int(2011, "Start Year", minval=1800, maxval=2100,    inline="dates")
i_start_month          = input.int(1,    "Month",       minval=1,    maxval=12,      inline="dates")
i_start_day            = input.int(1,    "Day",         minval=1,    maxval=31,      inline="dates",
               tooltip="Used only with Start Date.")
i_nb_years             = input.int(10, "Nb Years",  minval=0, maxval=300,        inline="nb")
i_nb_months            = input.int(0,  "Nb Months", minval=0, maxval=12,         inline="nb",
               tooltip="Used only with Nb Years/Months.")
i_table_position       = input.string("Top center", "Position",
               options=["Top left","Top center","Top right",
                        "Middle left","Middle center","Middle right",
                        "Bottom left","Bottom center","Bottom right"], inline="pt")
i_text_size            = input.int(16, "Size", minval=8, maxval=16,      inline="pt",
               tooltip="Table location on the chart and text size (points).")
i_orientation          = input.string("Horizontal", "Table",
               options=["Horizontal","Vertical"], inline="or",
               tooltip="HORIZONTAL: wide table, fits a bottom pane. VERTICAL: narrow table, easier to read on a phone.")

// ─── FIXED COLORS ─────────────────────────────────────────────────────────
// Two fixed sets, chosen from the chart's background: pale colors on a dark
// background, pure vivid colors on a white background (light chart), with
// values in bold there so the colors stand out. One plain background for
// the whole table.
bool IS_LIGHT_CHART = (color.r(chart.bg_color) * 299 + color.g(chart.bg_color) * 587 + color.b(chart.bg_color) * 114) / 1000 > 128
color C_TEXT       = IS_LIGHT_CHART ? color.new(#000000, 0) : color.new(color.white, 0)
color C_NEUTRAL_BG = IS_LIGHT_CHART ? color.new(#FFFFFF, 0) : color.new(#000000, 0)
color C_DRIP       = IS_LIGHT_CHART ? color.new(#000000, 0) : color.new(color.white, 0)
color C_NO_DRIP    = IS_LIGHT_CHART ? color.new(#404040, 0) : color.new(#9E9E9E, 0)
color C_CAPITAL    = IS_LIGHT_CHART ? color.new(#008C1A, 0) : color.new(#5CF09A, 0)
color C_INVESTED   = IS_LIGHT_CHART ? color.new(#000000, 0) : color.new(color.white, 0)
color C_GAIN       = IS_LIGHT_CHART ? color.new(#0055FF, 0) : color.new(#05D5FA, 0)
color C_DIVIDENDS  = IS_LIGHT_CHART ? color.new(#FF6A00, 0) : color.new(#FFB27A, 0)
color C_LAST_DIV   = C_CAPITAL
color C_YIELD      = IS_LIGHT_CHART ? color.new(#B88400, 0) : color.new(#FFD95A, 0)
color C_SHARES     = IS_LIGHT_CHART ? color.new(#9B30FF, 0) : color.new(#C3AEFF, 0)
color C_NEGATIVE   = IS_LIGHT_CHART ? color.new(#FF0000, 0) : color.new(#FF5A5A, 0)
color C_WARNING    = IS_LIGHT_CHART ? color.new(#8A6100, 0) : color.new(color.yellow, 0)

// ─── TOOLTIPS ─────────────────────────────────────────────────────────────
string TIP_DRIP      = "Dividends reinvested in new shares."
string TIP_NO_DRIP   = "Dividends kept in cash."
string TIP_CAPITAL   = "Value of the holding at the end."
string TIP_INVESTED  = "Total amount deposited."
string TIP_GAIN      = "Capital minus Invested."
string TIP_AVG_YEAR  = "Simple yearly average of the total gain %."
string TIP_DIV       = "Total dividends received."
string TIP_DIV_PCT   = "Dividends received as a % of Invested."
string TIP_LAST_DIV  = "Last dividend payment received. W: weekly, SM: semi-monthly, M: monthly, Q: quarterly, S: semi-annual, A: annual."
string TIP_YIELD     = "Last payment per share X payments per year / last price. Special dividends excluded."
string TIP_SHARES    = "Shares held at the end."

// ─── DRIP PAYMENT DELAY (fixed) ───────────────────────────────────────────
// TradingView provides only the ex-date. Each dividend is reinvested at the
// close of the Nth Daily bar (trading day) after its ex-date, an estimate of
// the payment day: 10 for funds/ETFs, 20 for stocks.
int DRIP_DELAY_BARS = syminfo.type == "fund" ? 10 : 20

// ─── FIRST DAY AND TODAY (from Daily data, never from the chart's bars) ───
// first_daily_time: first Daily bar received. last_daily_time: latest Daily
// bar received ("today"). Using Daily dates keeps D, W and M identical —
// a Weekly bar's own date is its Monday, which can fall in the prior month.
var int first_daily_time = na
var int last_daily_time  = na

// Effective dates — computed on the last bar, once last_daily_time is final
var int effective_start_date = 0
var int effective_end_date   = 0

// ─── KNOWN START DAY (Start Date and Visible Range modes) ─────────────────
// These two start days do not depend on "today", so the initial deposit's
// Daily open can be captured while history loads. In Nb Years/Months mode
// the start is day 1 of a month, so the month's first Daily open is used.
int capture_start_date = i_date_mode == "Start Date" ? timestamp(i_start_year, i_start_month, i_start_day, 0, 0) : i_date_mode == "Visible Range" ? chart.left_visible_bar_time : na

// ─── TV DATA SOURCES ──────────────────────────────────────────────────────
// Real (unadjusted) Daily prices drive the simulation on any chart interval.
// Dividends and splits are tracked on their own day.
string raw_ticker_id    = ticker.new(syminfo.prefix, syminfo.ticker, session.regular, adjustment.none)
// Fetched at Daily resolution on all chart intervals — TradingView serves
// D/W/M as separate feeds with independent update timing otherwise.
float  raw_close_price  = request.security(raw_ticker_id, "D", close,
                 gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off,
                 ignore_invalid_symbol=true)

string standard_ticker_id = ticker.standard(raw_ticker_id)

// Cumulative dividend accumulator, evaluated inside the Daily request below,
// captures every Daily ex-date (after Tax %), not just one per native bar.
cumulative_dividend_D(string tickerID) =>
    var float cum = 0.0
    float div = request.dividends(tickerID, dividends.gross,
                 gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off,
                 ignore_invalid_symbol=true)
    if not na(div)
        cum += div * (1.0 - i_tax_pct / 100.0)
    cum

split_ratio_D(string tickerID) =>
    float num = request.splits(tickerID, splits.numerator, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
    float den = request.splits(tickerID, splits.denominator, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
    not na(num) and not na(den) and den != 0.0 ? num / den : 1.0

// Single tuple call on the raw (unadjusted) Daily feed keeps all five
// arrays index-aligned to the same Daily bars. Dividends and splits are
// read from the standard ticker. On intraday charts the chart's own
// interval is requested instead (Daily is not a lower interval there), so
// the script runs and the table shows its interval warning.
string DAILY_TF = timeframe.isintraday ? timeframe.period : "D"
[arr_D_time, arr_D_cumdiv, arr_D_splitratio, arr_D_open, arr_D_close] = request.security_lower_tf(raw_ticker_id, DAILY_TF,
     [time, cumulative_dividend_D(standard_ticker_id), split_ratio_D(standard_ticker_id), open, close])

// ─── DATA COLLECTION — one entry per calendar month, always current ───────
// The current (still-open) month is updated in place each tick; a new
// month starts a fresh entry once the calendar month changes.
var array<int>   arr_bar_time    = array.new<int>()
var array<float> arr_close_price = array.new<float>()
var array<float> arr_first_open  = array.new<float>()
var array<int>   arr_first_time  = array.new<int>()
var int   last_entry_month_anchor  = -1

// Initial deposit's entry price (Start Date / Visible Range): Daily open of
// the first Daily bar at or after the known start day.
var float first_open_in_period      = na
var int   first_open_time_in_period = na

// Split events, in date order: day and ratio (new shares per old share).
var array<int>   sp_time  = array.new<int>()
var array<float> sp_ratio = array.new<float>()

var float cumulative_dividend_at_last_flush = 0.0

// Dividend events, in date order: ex-date, amount per share (after Tax %),
// and the reinvestment day and price, filled once DRIP_DELAY_BARS Daily
// bars have passed (left na while still pending).
var array<int>   ev_ex_time      = array.new<int>()
var array<float> ev_dividend     = array.new<float>()
var array<int>   ev_reinv_time   = array.new<int>()
var array<float> ev_reinv_price  = array.new<float>()
var array<int>   ev_bars_left    = array.new<int>()
var int          ev_first_pending = 0

if bar_index == 0
    array.clear(arr_bar_time)
    array.clear(arr_close_price)
    array.clear(arr_first_open)
    array.clear(arr_first_time)
    array.clear(sp_time)
    array.clear(sp_ratio)
    first_open_time_in_period         := na
    last_entry_month_anchor           := -1
    cumulative_dividend_at_last_flush := 0.0
    first_open_in_period              := na
    first_daily_time                  := na
    last_daily_time                   := na
    array.clear(ev_ex_time)
    array.clear(ev_dividend)
    array.clear(ev_reinv_time)
    array.clear(ev_reinv_price)
    array.clear(ev_bars_left)
    ev_first_pending := 0

if not na(raw_close_price)
    // Walks every Daily bar merged into this native bar's window and records
    // its own dates, prices, dividend and split.
    int n_D = array.size(arr_D_time)
    if n_D > 0
        for k = 0 to n_D - 1
            int   d_time  = array.get(arr_D_time,    k)
            float d_cum   = array.get(arr_D_cumdiv,  k)
            float d_split = array.get(arr_D_splitratio, k)
            float d_open  = array.get(arr_D_open,    k)
            float d_close = array.get(arr_D_close,   k)
            float d_dividend    = d_cum - cumulative_dividend_at_last_flush
            cumulative_dividend_at_last_flush := d_cum
            int d_month_anchor = timestamp(year(d_time), month(d_time), 1, 0, 0)

            if na(first_daily_time)
                first_daily_time := d_time
            last_daily_time := d_time

            if na(first_open_in_period) and not na(capture_start_date) and d_time >= capture_start_date
                first_open_in_period      := d_open
                first_open_time_in_period := d_time

            // Split on this Daily bar: applied at the start of that day.
            if d_split != 1.0
                array.push(sp_time,  d_time)
                array.push(sp_ratio, d_split)

            // Pending dividends: count down one Daily bar; at zero, record
            // this bar's day and close as the reinvestment day and price.
            int n_ev = array.size(ev_ex_time)
            if ev_first_pending < n_ev
                for e = ev_first_pending to n_ev - 1
                    int bars_left = array.get(ev_bars_left, e) - 1
                    array.set(ev_bars_left, e, bars_left)
                    if bars_left <= 0 and na(array.get(ev_reinv_time, e))
                        array.set(ev_reinv_time,  e, d_time)
                        array.set(ev_reinv_price, e, d_close)
                while ev_first_pending < n_ev and not na(array.get(ev_reinv_time, ev_first_pending))
                    ev_first_pending += 1

            // New dividend on this Daily bar (its ex-date).
            if d_dividend > 0.0
                array.push(ev_ex_time,     d_time)
                array.push(ev_dividend,    d_dividend)
                array.push(ev_reinv_time,  na)
                array.push(ev_reinv_price, na)
                array.push(ev_bars_left,   DRIP_DELAY_BARS)

            if d_month_anchor == last_entry_month_anchor and array.size(arr_bar_time) > 0
                // Still this Daily bar's calendar month — refresh its price.
                int last_idx = array.size(arr_bar_time) - 1
                array.set(arr_bar_time,    last_idx, d_time)
                array.set(arr_close_price, last_idx, d_close)
            else
                // New calendar month, detected at this exact Daily bar —
                // priced at this Daily bar's own close.
                array.push(arr_bar_time,    d_time)
                array.push(arr_close_price, d_close)
                array.push(arr_first_open,  d_open)
                array.push(arr_first_time,  d_time)
                last_entry_month_anchor := d_month_anchor

// ─── BUSINESS DAY COUNT (current, unclosed month) ──────────────────────────
// Counts weekdays (Mon-Fri) elapsed in the still-open month, from day 1
// to the given date (exchange holidays not tracked).
count_business_days(int end_time) =>
    int y = year(end_time)
    int m = month(end_time)
    int d = dayofmonth(end_time)
    int count = 0
    for day = 1 to d
        int day_time = timestamp(y, m, day, 0, 0)
        int dow = dayofweek(day_time)
        if dow != dayofweek.saturday and dow != dayofweek.sunday
            count += 1
    count

// ─── CALCULATION ──────────────────────────────────────────────────────────
var float capital_drip               = 0.0
var float capital_no_drip            = 0.0
var float total_invested             = 0.0
var float cumulative_dividends_drip  = 0.0
var float cumulative_dividends_no_drip = 0.0
var float shares_drip                = 0.0
var float shares_no_drip             = 0.0
var float last_dividend_paid_drip    = 0.0
var float last_dividend_paid_no_drip = 0.0
var string last_dividend_frequency   = ""
var float dividend_yield_pct         = na
var float period_years               = 0.0
var int   bars_in_period             = 0
var bool  is_period_invalid          = false
var string period_invalid_message    = ""
var int   current_month_day_count    = 0

// Recalculates on the last bar every time, whether still forming
// (isrealtime) or already closed with no new tick yet.
if barstate.islastconfirmedhistory or barstate.islast
    // "Today" and the first available day both come from Daily data.
    int live_bar_time        = na(last_daily_time) ? time : last_daily_time
    int chart_first_bar_time = na(first_daily_time) ? 0 : timestamp(year(first_daily_time), month(first_daily_time), 1, 0, 0)
    int period_start_date = 0
    int period_end_date   = live_bar_time
    if i_date_mode == "Nb Years/Months"
        int requested_total_months = i_nb_years * 12 + i_nb_months
        if requested_total_months == 0
            is_period_invalid       := true
            period_invalid_message  := "Enter Nb Years or Nb Months > 0"
        else
            is_period_invalid := false
            // Anchored to day 1 of the target month, matching the
            // monthly bars' own timestamps.
            int years_back  = int(requested_total_months / 12)
            int months_back = requested_total_months % 12
            period_start_date := timestamp(year(live_bar_time) - years_back, month(live_bar_time) - months_back, 1, 0, 0)
    else if i_date_mode == "Start Date"
        // Exact day supported, so this can match a TV preset's start date precisely.
        period_start_date := timestamp(i_start_year, i_start_month, i_start_day, 0, 0)
        if period_start_date > live_bar_time
            is_period_invalid      := true
            period_invalid_message := "Start date not yet available"
        else
            is_period_invalid := false
    else // "Visible Range"
        period_start_date := chart.left_visible_bar_time
        int visible_right_month_start = timestamp(year(chart.right_visible_bar_time), month(chart.right_visible_bar_time), 1, 0, 0)
        period_end_date   := math.min(visible_right_month_start, live_bar_time)
        if period_start_date > period_end_date
            is_period_invalid      := true
            period_invalid_message := "Visible range invalid"
        else
            is_period_invalid := false

    // Requires Daily/Weekly/Monthly — the DCA step assumes one contribution
    // per calendar month, which finer intervals would break.
    if not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
        is_period_invalid := true

    int effective_start_date_calc = math.max(period_start_date, chart_first_bar_time)
    effective_start_date := effective_start_date_calc
    effective_end_date   := period_end_date

    if is_period_invalid
        capital_drip                 := 0.0
        capital_no_drip              := 0.0
        total_invested               := 0.0
        cumulative_dividends_drip    := 0.0
        cumulative_dividends_no_drip := 0.0
        shares_drip                  := 0.0
        shares_no_drip               := 0.0
        last_dividend_paid_drip      := 0.0
        last_dividend_paid_no_drip   := 0.0
        last_dividend_frequency      := ""
        dividend_yield_pct           := na
        period_years                 := 0.0
        bars_in_period                := 0
        current_month_day_count       := 0
    else
        // Build filtered arrays for the selected period; the current
        // (still-open) month is included as a normal entry.
        int total_bars_collected = array.size(arr_close_price)
        var array<float> arr_price_filtered    = array.new<float>()
        var array<int>   arr_bar_time_filtered = array.new<int>()
        var array<float> arr_first_open_filtered = array.new<float>()
        var array<int>   arr_first_time_filtered = array.new<int>()
        array.clear(arr_first_open_filtered)
        array.clear(arr_first_time_filtered)
        array.clear(arr_price_filtered)
        array.clear(arr_bar_time_filtered)

        // End boundary compares by month anchor (not exact day) so the
        // still-open current month is included; start stays exact-day.
        int period_end_month_anchor = timestamp(year(period_end_date), month(period_end_date), 1, 0, 0)
        for i = 0 to total_bars_collected - 1
            int bar_time = array.get(arr_bar_time, i)
            int bar_month_anchor = timestamp(year(bar_time), month(bar_time), 1, 0, 0)
            if bar_time >= effective_start_date_calc and bar_month_anchor <= period_end_month_anchor
                array.push(arr_price_filtered,    array.get(arr_close_price, i))
                array.push(arr_bar_time_filtered, bar_time)
                array.push(arr_first_open_filtered, array.get(arr_first_open, i))
                array.push(arr_first_time_filtered, array.get(arr_first_time, i))

        int n_bars = array.size(arr_price_filtered)
        bars_in_period := n_bars

        int   end_time    = n_bars > 0 ? array.get(arr_bar_time_filtered, n_bars - 1) : na
        float final_price = n_bars > 0 ? array.get(arr_price_filtered, n_bars - 1) : 0.0

        // Is the last collected month the still-open current month?
        // Used only for the day-count shown in the table.
        bool last_entry_is_current_month = n_bars > 0 and (year(array.get(arr_bar_time_filtered, n_bars - 1)) == year(live_bar_time)) and (month(array.get(arr_bar_time_filtered, n_bars - 1)) == month(live_bar_time))
        // Counted up to the last Daily bar (last trading day), not the
        // chart bar's date or the wall clock.
        current_month_day_count := last_entry_is_current_month ? count_business_days(live_bar_time) : 0

        // End label matches the actual last month represented in the data.
        if n_bars > 0
            effective_end_date := end_time

        // ── Day-by-day calendar ──
        // Deposits: initial on the period's first trading day, then one per
        // month on the month's first trading day, bought at that day's open.
        // Same-day order: split (before the open) → ex-date (paid on shares
        // held before today's purchase) → deposit (open) → reinvestment (close).
        bool  use_month_open      = i_date_mode == "Nb Years/Months" or effective_start_date_calc > period_start_date or na(first_open_in_period)
        float initial_entry_price = n_bars == 0 ? na : use_month_open ? array.get(arr_first_open_filtered, 0) : first_open_in_period
        int   initial_entry_time  = n_bars == 0 ? na : use_month_open ? array.get(arr_first_time_filtered, 0) : first_open_time_in_period
        float annual_increase_rate = i_annual_increase_pct / 100.0

        // Length of the period in years, for the simple yearly average.
        period_years := n_bars > 0 and not na(initial_entry_time) and not na(end_time) ? (end_time - initial_entry_time) / 31557600000.0 : 0.0

        array<int>   dep_time   = array.new<int>()
        array<float> dep_amount = array.new<float>()
        array<float> dep_price  = array.new<float>()
        if n_bars > 0
            array.push(dep_time,   initial_entry_time)
            array.push(dep_amount, i_initial_deposit)
            array.push(dep_price,  initial_entry_price)
            if n_bars > 1
                for i = 1 to n_bars - 1
                    array.push(dep_time,   array.get(arr_first_time_filtered, i))
                    array.push(dep_amount, i_monthly_deposit * math.pow(1.0 + annual_increase_rate, int(i / 12)))
                    array.push(dep_price,  array.get(arr_first_open_filtered, i))

        float sh_drip    = 0.0
        float sh_no_drip = 0.0
        float div_drip   = 0.0
        float div_no_drip = 0.0
        float invested   = 0.0

        // Last Pay: the last single dividend payment, on shares held at its
        // ex-date.
        float last_div_drip    = 0.0
        float last_div_no_drip = 0.0

        // Pointers: splits, dividend events, deposits; reinvestment queue.
        int n_sp  = array.size(sp_time)
        int n_ev  = array.size(ev_ex_time)
        int n_dep = array.size(dep_time)
        int sp_ptr  = 0
        int ev_ptr  = 0
        int dep_ptr = 0
        if n_bars > 0
            while sp_ptr < n_sp and array.get(sp_time, sp_ptr) < initial_entry_time
                sp_ptr += 1
            while ev_ptr < n_ev and array.get(ev_ex_time, ev_ptr) < initial_entry_time
                ev_ptr += 1
        array<float> q_amount = array.new<float>()
        array<int>   q_time   = array.new<int>()
        array<float> q_price  = array.new<float>()
        int          q_head   = 0

        bool more_steps = n_bars > 0
        while more_steps
            int t_sp  = sp_ptr  < n_sp  and array.get(sp_time,    sp_ptr)  <= end_time ? array.get(sp_time,    sp_ptr)  : na
            int t_ev  = ev_ptr  < n_ev  and array.get(ev_ex_time, ev_ptr)  <= end_time ? array.get(ev_ex_time, ev_ptr)  : na
            int t_dep = dep_ptr < n_dep and array.get(dep_time,   dep_ptr) <= end_time ? array.get(dep_time,   dep_ptr) : na
            int t_rq  = q_head < array.size(q_time) and not na(array.get(q_time, q_head)) and array.get(q_time, q_head) <= end_time ? array.get(q_time, q_head) : na
            // Earliest step; on the same day: split, ex-date, deposit, reinvestment.
            int t_min = na
            int kind  = 0
            if not na(t_sp)
                t_min := t_sp
                kind  := 1
            if not na(t_ev) and (na(t_min) or t_ev < t_min)
                t_min := t_ev
                kind  := 2
            if not na(t_dep) and (na(t_min) or t_dep < t_min)
                t_min := t_dep
                kind  := 3
            if not na(t_rq) and (na(t_min) or t_rq < t_min)
                t_min := t_rq
                kind  := 4
            if kind == 1
                float ratio = array.get(sp_ratio, sp_ptr)
                sh_drip    := sh_drip    * ratio
                sh_no_drip := sh_no_drip * ratio
                sp_ptr += 1
            else if kind == 2
                float dps        = array.get(ev_dividend, ev_ptr)
                float pay_drip   = sh_drip    * dps
                float pay_nodrip = sh_no_drip * dps
                div_drip    += pay_drip
                div_no_drip += pay_nodrip
                array.push(q_amount, pay_drip)
                array.push(q_time,   array.get(ev_reinv_time,  ev_ptr))
                array.push(q_price,  array.get(ev_reinv_price, ev_ptr))
                last_div_drip    := pay_drip
                last_div_no_drip := pay_nodrip
                ev_ptr += 1
            else if kind == 3
                float amount = array.get(dep_amount, dep_ptr)
                float price  = array.get(dep_price,  dep_ptr)
                if price > 0.0
                    invested   += amount
                    sh_drip    += amount / price
                    sh_no_drip += amount / price
                dep_ptr += 1
            else if kind == 4
                float reinv_price = array.get(q_price, q_head)
                if reinv_price > 0.0
                    sh_drip += array.get(q_amount, q_head) / reinv_price
                array.set(q_amount, q_head, 0.0)
                q_head += 1
            else
                more_steps := false

        // Dividends paid but not yet reinvested at the period end.
        float pending_drip_cash = 0.0
        if q_head < array.size(q_amount)
            for q = q_head to array.size(q_amount) - 1
                pending_drip_cash += array.get(q_amount, q)

        shares_drip                  := sh_drip
        shares_no_drip               := sh_no_drip
        cumulative_dividends_drip    := div_drip
        cumulative_dividends_no_drip := div_no_drip
        total_invested               := invested

        // No-DRIP Capital includes dividends collected in cash, never
        // reinvested into shares. With-DRIP Capital includes dividends
        // still waiting for their reinvestment day.
        capital_drip    := sh_drip    * final_price + pending_drip_cash
        capital_no_drip := sh_no_drip * final_price + div_no_drip

        last_dividend_paid_drip    := last_div_drip
        last_dividend_paid_no_drip := last_div_no_drip

        // Dividends per share with ex-date in the 12 months before the end
        // day, brought to today's share count when a split happened after
        // the ex-date. The latest one is the last payment per share.
        // The same 12 months give the payment frequency, from the number of
        // payments: W (40+), SM (18-39), M (9-17), Q (3-8), S (2), A (1).
        int   ttm_count    = 0
        float last_dps     = na
        array<float> ttm_list = array.new<float>()
        if n_bars > 0 and n_ev > 0
            int window_start = end_time - 31536000000
            int e = n_ev - 1
            while e >= 0
                int ex_t = array.get(ev_ex_time, e)
                if ex_t <= window_start
                    break
                if ex_t <= end_time
                    float split_adj = 1.0
                    if n_sp > 0
                        for s = 0 to n_sp - 1
                            int s_t = array.get(sp_time, s)
                            if s_t > ex_t and s_t <= end_time
                                split_adj *= array.get(sp_ratio, s)
                    ttm_count    += 1
                    float adj_dps = array.get(ev_dividend, e) / split_adj
                    array.push(ttm_list, adj_dps)
                    if na(last_dps)
                        last_dps := adj_dps
                e -= 1
        float tax_factor = 1.0 - i_tax_pct / 100.0
        last_dividend_frequency := ttm_count >= 40 ? "W" : ttm_count >= 18 ? "SM" : ttm_count >= 9 ? "M" : ttm_count >= 3 ? "Q" : ttm_count == 2 ? "S" : ttm_count == 1 ? "A" : ""
        // Yield, as quoted by financial sites: last payment per share
        // (before tax) × payments per year ÷ last price. A last payment more
        // than 50% above the usual one (middle value of the last 12 months,
        // split-adjusted) is treated as a special dividend: the usual
        // payment is used instead.
        float usual_dps  = array.size(ttm_list) > 0 ? array.median(ttm_list) : na
        float yield_dps  = not na(last_dps) and not na(usual_dps) and last_dps > usual_dps * 1.5 ? usual_dps : last_dps
        int payments_per_year = last_dividend_frequency == "W" ? 52 : last_dividend_frequency == "SM" ? 24 : last_dividend_frequency == "M" ? 12 : last_dividend_frequency == "Q" ? 4 : last_dividend_frequency == "S" ? 2 : last_dividend_frequency == "A" ? 1 : 0
        dividend_yield_pct := final_price > 0.0 and not na(last_dps) and payments_per_year > 0 ? yield_dps / tax_factor * payments_per_year / final_price * 100.0 : na

// ─── METRICS ──────────────────────────────────────────────────────────────
float net_gain_drip    = capital_drip    - total_invested
float net_gain_no_drip = capital_no_drip - total_invested

// Total gain % — non-annualized, matches TV's own price-ratio convention.
float total_gain_invest_pct_drip    = total_invested > 0.0 ? (net_gain_drip    / total_invested * 100.0) : 0.0
float total_gain_invest_pct_no_drip = total_invested > 0.0 ? (net_gain_no_drip / total_invested * 100.0) : 0.0

// Avg/Year % — simple average: total gain % divided by years (not compounded).
float avg_year_pct_drip    = period_years > 0.0 ? total_gain_invest_pct_drip    / period_years : na
float avg_year_pct_no_drip = period_years > 0.0 ? total_gain_invest_pct_no_drip / period_years : na

// Dividends % — cumulative dividends over the whole period as
// a % of Invested. Same denominator for both columns, so the
// difference isolates the effect of reinvestment on dividends collected.
float dividend_invested_pct_drip    = total_invested > 0.0 ? (cumulative_dividends_drip    / total_invested * 100.0) : 0.0
float dividend_invested_pct_no_drip = total_invested > 0.0 ? (cumulative_dividends_no_drip / total_invested * 100.0) : 0.0

// ─── FORMATTING ───────────────────────────────────────────────────────────
format_money_no_decimals(float value) => value >= 2000000 ? str.tostring(math.round(value / 1000), "#,##0") + " K $" : str.tostring(math.round(value), "#,##0") + " $"
// Percent formatter — one decimal, "%" separated by a space (matches "$"
// spacing above), no leading "+" on positive values, "-" prefix kept on
// negative values, "–" when not available.
format_percent(float value) =>
    string absolute_formatted = str.tostring(math.round(math.abs(value)*10)/10, "#,##0.0") + " %"
    na(value) ? "–" : value < 0 ? "-" + absolute_formatted : absolute_formatted
format_last_dividend(float value, string frequency) => frequency == "" ? format_money_no_decimals(value) : format_money_no_decimals(value) + " - " + frequency
format_shares(float value)   => str.tostring(math.round(value), "#,##0")
format_month_year(int date_value) => str.format_time(date_value, "yyyy-MM", "UTC")
truncate_text(string text_value, int max_length) => str.length(text_value) > max_length ? str.substring(text_value, 0, max_length) : text_value
value_color(float value, color base_color) => not na(value) and value < 0 ? C_NEGATIVE : base_color
// ─── POSITION ─────────────────────────────────────────────────────────────
string position_value = switch i_table_position
    "Top left"      => position.top_left
    "Top center"    => position.top_center
    "Top right"     => position.top_right
    "Middle left"   => position.middle_left
    "Middle center" => position.middle_center
    "Middle right"  => position.middle_right
    "Bottom left"   => position.bottom_left
    "Bottom center" => position.bottom_center
    => position.bottom_right

// ─── TEXT SIZE ────────────────────────────────────────────────────────────
int text_size_label = i_text_size   // all cells, so every row has the same height

// Three points smaller, for the second title line of the Vertical table.
int text_size_small = math.max(i_text_size - 3, 6)
// Blank rows on top and at the bottom.
int TEXT_SIZE_BLANK = 6

// ─── TABLE HELPERS ────────────────────────────────────────────────────────
// One full-width row: a single cell merged across all columns.
full_row(table t, int row, int n_cols, string txt, color tc, color bg, int sz) =>
    table.cell(t, 0, row, txt, text_color=tc, bgcolor=bg, text_size=sz, text_halign=text.align_center)
    for c = 1 to n_cols - 1
        table.cell(t, c, row, "", bgcolor=bg, text_size=sz)
    table.merge_cells(t, 0, row, n_cols - 1, row)

// One cell merged across columns c0 to c1 of a row, text centered.
span_cell(table t, int c0, int c1, int row, string txt, color tc, color bg, int sz) =>
    table.cell(t, c0, row, txt, text_color=tc, bgcolor=bg, text_size=sz, text_halign=text.align_center)
    for c = c0 + 1 to c1
        table.cell(t, c, row, "", bgcolor=bg, text_size=sz)
    table.merge_cells(t, c0, row, c1, row)

// One results cell, placed by its position in the horizontal layout
// (col 0-9, row 0-2) and turned sideways when the table is Vertical.
grid_cell(table t, bool vertical, int top, int col, int row, string txt, color tc, color bg, string halign, string tip, bool bold = false) =>
    int c = vertical ? row : col
    int r = vertical ? top + col : top + row
    table.cell(t, c, r, txt, text_color=tc, bgcolor=bg, text_size=text_size_label, text_halign=halign, tooltip=tip, text_formatting=bold or (IS_LIGHT_CHART and row > 0 and col > 0) ? text.format_bold : text.format_none)

// ─── TABLE ────────────────────────────────────────────────────────────────
// No lines. Colored text on one plain background. The blank rows on top
// and at the bottom are fully transparent, so chart marks (dividends,
// splits, news) stay visible.
// Horizontal (10 columns): blank row · dates | Symbol - Name | parameters
// (one line, three parts) · headers (duration first) · With DRIP · No DRIP · blank row.
// Vertical (3 columns): blank row · Symbol - Name · dates and parameters
// (smaller text) · one row per result (label | With DRIP | No DRIP) · blank row.
// Results: Capital · Invested · Gains $ · Avg/Year % · Dividends $ ·
// Dividends % · Last Pay · Yield · Shares

var table result_table = table.new(position_value, 10, 15,
              bgcolor=na,
              border_width=0,
              frame_width=0)

if barstate.islast
    table.clear(result_table, 0, 0, 9, 14)
    bool   is_vertical = i_orientation == "Vertical"
    int    n_cols_total = is_vertical ? 3 : 10
    bool   is_invalid_interval_warning = not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
    string full_symbol_name = syminfo.ticker + " - " + syminfo.description
    string symbol_text  = is_invalid_interval_warning ? "Interval too small — use Daily, Weekly or Monthly" : is_period_invalid ? period_invalid_message : full_symbol_name
    color  symbol_color = (is_invalid_interval_warning or is_period_invalid) ? C_WARNING : C_TEXT

    string tax_label    = "  " + str.tostring(i_tax_pct) + "% tax"
    string params_values = format_money_no_decimals(i_initial_deposit) + " +" + format_money_no_decimals(i_monthly_deposit) + "/m  +" + str.tostring(i_annual_increase_pct) + "%/y" + tax_label

    string compact_params = str.replace_all(str.replace_all(params_values, " $", "$"), "  ", " ")

    string date_separator   = "⇢"                 // arrow between start and end date
    string start_date_label = format_month_year(effective_start_date)
    string end_date_label   = format_month_year(effective_end_date)

    // bars_in_period counts months inclusively; subtract 1 to get
    // elapsed months (partial month shown separately via day count).
    int    duration_months_total = math.max(bars_in_period - 1, 0)
    int    years_display    = int(duration_months_total / 12)
    int    months_display   = duration_months_total % 12
    int    days_display     = current_month_day_count
    string duration_label   = str.tostring(years_display) + "y " + str.tostring(months_display) + "m " + str.tostring(days_display) + "d"
    string period_label     = start_date_label + date_separator + end_date_label
    bool   show_warning_only = is_invalid_interval_warning or is_period_invalid
    color  no_bg            = na

    // Blank row on top (invisible)
    full_row(result_table, 0, n_cols_total, " ", C_TEXT, no_bg, TEXT_SIZE_BLANK)

    if show_warning_only
        full_row(result_table, 1, n_cols_total, symbol_text, symbol_color, C_NEUTRAL_BG, text_size_label)
        full_row(result_table, 2, n_cols_total, " ", C_TEXT, no_bg, TEXT_SIZE_BLANK)
    else
        int top = is_vertical ? 3 : 2

        // Cell texts by position in the horizontal layout (col 0-9).
        array<string> hdr_txt    = array.from(duration_label, "Capital", "Invested", is_vertical ? "Gains $" : "Gains - Avg/Year %", is_vertical ? "Avg/Year %" : "", is_vertical ? "Dividends $" : "Dividends", is_vertical ? "Dividends %" : "", "Last Pay", "Yield", "Shares")
        array<string> drip_txt   = array.from("✦ With DRIP", format_money_no_decimals(capital_drip), format_money_no_decimals(total_invested), format_money_no_decimals(net_gain_drip), format_percent(avg_year_pct_drip), format_money_no_decimals(cumulative_dividends_drip), format_percent(dividend_invested_pct_drip), format_last_dividend(last_dividend_paid_drip, last_dividend_frequency), format_percent(dividend_yield_pct), format_shares(shares_drip))
        array<string> nodrip_txt = array.from("No DRIP", format_money_no_decimals(capital_no_drip), format_money_no_decimals(total_invested), format_money_no_decimals(net_gain_no_drip), format_percent(avg_year_pct_no_drip), format_money_no_decimals(cumulative_dividends_no_drip), format_percent(dividend_invested_pct_no_drip), format_last_dividend(last_dividend_paid_no_drip, last_dividend_frequency), format_percent(dividend_yield_pct), format_shares(shares_no_drip))

        // Title. Horizontal: one line in three parts — dates over columns 1-2,
        // Symbol - Name centered over columns 3-6 (Invested, Gains $,
        // Avg/Year %, Dividends $), parameters over columns 7-10. The name gets
        // at least 36 characters, up to the estimated width of columns 3-6:
        // sum of each column's longest value (headers not counted), x1.2 since
        // a digit is wider than an average letter. TradingView gives no pixel
        // width, so this is an estimate.
        // Vertical: Symbol - Name cut to the width of the second line (smaller
        // text) plus two characters, then dates and parameters.
        if is_vertical
            string second_line   = period_label + "  " + compact_params
            int    title_max_len = math.max(int(str.length(second_line) * text_size_small / text_size_label) + 2, 10)
            full_row(result_table, 1, n_cols_total, truncate_text(symbol_text, title_max_len), symbol_color, C_NEUTRAL_BG, text_size_label)
            full_row(result_table, 2, n_cols_total, second_line, C_TEXT, C_NEUTRAL_BG, text_size_small)
        else
            array<int> wv = array.new<int>(10, 0)
            for c = 0 to 9
                array.set(wv, c, math.max(str.length(array.get(drip_txt, c)), str.length(array.get(nodrip_txt, c))))
            int est_width = int((array.get(wv, 2) + array.get(wv, 3) + array.get(wv, 4) + array.get(wv, 5)) * 1.2)
            string name_text = truncate_text(symbol_text, math.max(est_width, 36))
            span_cell(result_table, 0, 1, 1, period_label, C_TEXT, C_NEUTRAL_BG, text_size_label)
            span_cell(result_table, 2, 5, 1, name_text, C_TEXT, C_NEUTRAL_BG, text_size_label)
            span_cell(result_table, 6, 9, 1, compact_params, C_TEXT, C_NEUTRAL_BG, text_size_label)

        // Headers, each in the color of its values
        string c_align = text.align_center
        grid_cell(result_table, is_vertical, top, 0, 0, array.get(hdr_txt, 0), C_TEXT, C_NEUTRAL_BG, text.align_center, "")
        grid_cell(result_table, is_vertical, top, 1, 0, array.get(hdr_txt, 1), C_CAPITAL, C_NEUTRAL_BG, c_align, TIP_CAPITAL)
        grid_cell(result_table, is_vertical, top, 2, 0, array.get(hdr_txt, 2), C_INVESTED, C_NEUTRAL_BG, c_align, TIP_INVESTED)
        grid_cell(result_table, is_vertical, top, 3, 0, array.get(hdr_txt, 3), C_GAIN, C_NEUTRAL_BG, c_align, is_vertical ? TIP_GAIN : TIP_AVG_YEAR)
        grid_cell(result_table, is_vertical, top, 4, 0, array.get(hdr_txt, 4), C_GAIN, C_NEUTRAL_BG, c_align, is_vertical ? TIP_AVG_YEAR : "")
        grid_cell(result_table, is_vertical, top, 5, 0, array.get(hdr_txt, 5), C_DIVIDENDS, C_NEUTRAL_BG, c_align, TIP_DIV)
        grid_cell(result_table, is_vertical, top, 6, 0, array.get(hdr_txt, 6), C_DIVIDENDS, C_NEUTRAL_BG, c_align, is_vertical ? TIP_DIV_PCT : "")
        grid_cell(result_table, is_vertical, top, 7, 0, array.get(hdr_txt, 7), C_LAST_DIV, C_NEUTRAL_BG, c_align, TIP_LAST_DIV)
        grid_cell(result_table, is_vertical, top, 8, 0, array.get(hdr_txt, 8), C_YIELD, C_NEUTRAL_BG, c_align, TIP_YIELD)
        grid_cell(result_table, is_vertical, top, 9, 0, array.get(hdr_txt, 9), C_SHARES, C_NEUTRAL_BG, is_vertical ? text.align_center : text.align_right, TIP_SHARES)
        if not is_vertical
            table.merge_cells(result_table, 3, top, 4, top)
            table.merge_cells(result_table, 5, top, 6, top)

        // With DRIP / No DRIP values (tooltips on the With DRIP row)
        for r = 1 to 2
            bool          is_drip_row = r == 1
            array<string> row_txt     = is_drip_row ? drip_txt : nodrip_txt
            color         row_color   = is_drip_row ? C_DRIP : C_NO_DRIP
            float         v_gain      = is_drip_row ? net_gain_drip : net_gain_no_drip
            float         v_avg_year  = is_drip_row ? avg_year_pct_drip : avg_year_pct_no_drip

            grid_cell(result_table, is_vertical, top, 0, r, array.get(row_txt, 0), row_color, C_NEUTRAL_BG, text.align_center, is_drip_row ? TIP_DRIP : TIP_NO_DRIP, is_drip_row)
            grid_cell(result_table, is_vertical, top, 1, r, array.get(row_txt, 1), C_CAPITAL, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_CAPITAL : "")
            grid_cell(result_table, is_vertical, top, 2, r, array.get(row_txt, 2), C_INVESTED, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_INVESTED : "")
            grid_cell(result_table, is_vertical, top, 3, r, array.get(row_txt, 3), value_color(v_gain, C_GAIN), C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_GAIN : "")
            grid_cell(result_table, is_vertical, top, 4, r, array.get(row_txt, 4), value_color(v_avg_year, C_GAIN), C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_AVG_YEAR : "")
            grid_cell(result_table, is_vertical, top, 5, r, array.get(row_txt, 5), C_DIVIDENDS, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_DIV : "")
            grid_cell(result_table, is_vertical, top, 6, r, array.get(row_txt, 6), C_DIVIDENDS, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_DIV_PCT : "")
            grid_cell(result_table, is_vertical, top, 7, r, array.get(row_txt, 7), C_LAST_DIV, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_LAST_DIV : "")
            grid_cell(result_table, is_vertical, top, 8, r, array.get(row_txt, 8), C_YIELD, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_YIELD : "")
            grid_cell(result_table, is_vertical, top, 9, r, array.get(row_txt, 9), C_SHARES, C_NEUTRAL_BG, text.align_right, is_drip_row ? TIP_SHARES : "")

        // Blank row at the bottom (invisible)
        full_row(result_table, is_vertical ? top + 10 : top + 3, n_cols_total, " ", C_TEXT, no_bg, TEXT_SIZE_BLANK)
````
