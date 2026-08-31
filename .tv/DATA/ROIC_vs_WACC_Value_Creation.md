<!-- tradingview-pine-id: PUB;e97ebbd055d449c9b4581e0568a8da5f -->
<!-- tradingviewscripts-format: 1 -->
# ROIC vs WACC (Value Creation)

Source: https://www.tradingview.com/script/sO40YCme-ROIC-vs-WACC-Value-Creation/

## Description

The Recommended Timeframe This indicator must be used on a Daily (1D) timeframe.

There are two primary reasons for this:

The Beta Calculation: The script calculates the stock's volatility (Beta) against the S&P 500 using a default 252-bar lookback. There are roughly 252 trading days in a year. If you drop to a 1-hour chart, the script will calculate Beta over the last 252 hours, which completely breaks the Capital Asset Pricing Model (CAPM) math used to find the Cost of Equity.

Fundamental Data Frequency: Corporate financial data (like debt, tax rates, and ROIC) is only reported quarterly. Viewing this on an intraday chart provides no extra data and just wastes computing resources.

How the Indicator Works At its core, this indicator visualizes the most important rule in corporate finance: A company only creates true wealth for shareholders if its Return on Invested Capital (ROIC) is higher than its Weighted Average Cost of Capital (WACC).

If a company borrows money at 8% (WACC) to fund projects that only return 5% (ROIC), it is destroying value, even if its total revenue is growing.

Here is how the script breaks that down visually on your chart:

The Blue Line (ROIC) What it is: Return on Invested Capital. It measures how efficiently a company turns debt and equity into profit.
How it behaves: Because this data is pulled directly from the company's financial statements (Form 10-K or 10-Q), the line will look like a "staircase." It remains flat until a new earnings report is released, at which point it steps up or down.

The Orange Line (WACC) What it is: Weighted Average Cost of Capital. This is the "hurdle rate" the company must beat. It blends the cost of the company's debt (interest payments) and the cost of its equity (what shareholders expect to earn given the stock's risk).
How it behaves: Unlike ROIC, this line wiggles and waves every single day. This is because the script actively calculates WACC using live market data:

It checks the real-time US 10-Year Treasury yield to find the risk-free rate.

It calculates a live Beta to measure the stock's daily risk against the S&P 500.

It uses the live stock price to calculate the Market Cap, constantly shifting the weight between debt and equity.

The Histogram (Economic Spread) What it is: The visual difference between the Blue Line and the Orange Line (ROIC - WACC).
How to read it:

Teal Bars (Above Zero): The company is a Value Creator. It is earning more on its capital than that capital costs to acquire. These are typically high-quality businesses with strong competitive moats.

Red Bars (Below Zero): The company is a Value Destroyer. Its cost of funding is dragging down its actual returns.

A Note on the "Manual" Setting Because WACC relies heavily on a stock's historical volatility (Beta), extremely volatile tech stocks (like heavily shorted meme stocks) or highly leveraged Real Estate Investment Trusts (REITs) can temporarily cause the math to spit out absurd WACC numbers (like 40% or 50%).

If you are looking at an unusual stock and the Orange line looks broken, you can open the indicator settings and change the WACC Mode from "Estimated" to "Manual". This will lock the Orange line at a flat, sensible hurdle rate (default 8%) so you can still measure the company's ROIC against a standard benchmark.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Assistant

//@version=6
indicator("ROIC vs WACC (Value Creation)", shorttitle="ROIC / WACC", overlay=false, format=format.percent, precision=2)

// ============================================================================
// USER INPUTS
// ============================================================================
grp_main = "General Settings"
period   = input.string("FY", "Financial Period", options=["FY", "FQ", "TTM"], group=grp_main)
mode     = input.string("Estimated", title="WACC Mode", options=["Estimated", "Manual"], group=grp_main, tooltip="Estimated computes dynamic WACC using financials & CAPM. Manual uses a fixed rate.")
manualW  = input.float(8.0, title="Manual WACC (%)", step=0.5, group=grp_main)

grp_wacc = "Estimated WACC Parameters (CAPM)"
rfTicker = input.symbol("US10Y", title="Risk-Free Rate Ticker", group=grp_wacc, tooltip="Proxy for the risk-free rate.")
bench    = input.symbol("SPY", title="Market Benchmark", group=grp_wacc, tooltip="Used to calculate Beta.")
erpInput = input.float(5.5, title="Equity Risk Premium (%)", group=grp_wacc, tooltip="The expected return of the market above the risk-free rate.")
betaLen  = input.int(252, title="Beta Lookback (Bars)", group=grp_wacc, tooltip="Number of bars for Beta calculation. 252 represents 1 trading year on a daily chart.")

// ============================================================================
// FINANCIAL DATA FETCHING
// ============================================================================
// Target metric: ROIC
roic = request.financial(syminfo.tickerid, "RETURN_ON_INVESTED_CAPITAL", period)

// Debt & Interest for Cost of Debt
int_exp_raw  = request.financial(syminfo.tickerid, "INTEREST_EXPENSE_ON_DEBT", period)
tot_debt_raw = request.financial(syminfo.tickerid, "TOTAL_DEBT", period)

// Taxes & Income for Tax Rate
inc_tax_raw = request.financial(syminfo.tickerid, "INCOME_TAX", period)
net_inc_raw = request.financial(syminfo.tickerid, "NET_INCOME", period)

// Shares Outstanding for Market Cap
shares_raw = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", period)

// ============================================================================
// COST OF EQUITY (CAPM)
// ============================================================================
rf_rate = request.security(rfTicker, timeframe.period, close)

// Beta Calculation (Timeframe dependent - use 1D chart for daily Beta)
sym_ret = ta.change(close) / close[1]
b_close = request.security(bench, timeframe.period, close)
b_ret   = ta.change(b_close) / b_close[1]

// Calculate Beta using Correlation and Standard Deviation
corr      = ta.correlation(sym_ret, b_ret, betaLen)
stdev_sym = ta.stdev(sym_ret, betaLen)
stdev_b   = ta.stdev(b_ret, betaLen)

// Fallback to market average beta (1.0) if missing data or division by zero
beta = (stdev_b > 0 and not na(corr)) ? corr * (stdev_sym / stdev_b) : 1.0

ke = rf_rate + (beta * erpInput)

// ============================================================================
// COST OF DEBT & TAX RATE
// ============================================================================
int_exp  = math.abs(nz(int_exp_raw, 0.0))
tot_debt = math.max(nz(tot_debt_raw, 0.0), 0.0)
kd       = tot_debt > 0 ? (int_exp / tot_debt) * 100 : 0.0

inc_tax       = math.abs(nz(inc_tax_raw, 0.0))
net_inc       = nz(net_inc_raw, 0.0)
pre_tax_inc   = net_inc + inc_tax
tax_rate_calc = pre_tax_inc > 0 ? (inc_tax / pre_tax_inc) : 0.21
tax_rate      = math.max(0.0, math.min(tax_rate_calc, 0.40)) // Cap tax rate between 0% and 40%

// ============================================================================
// CAPITAL WEIGHTS & WACC
// ============================================================================
shares_out = nz(shares_raw, 0.0)
market_cap = shares_out * close
V = market_cap + tot_debt

// Calculate capital weights; default to 100% equity if data is missing
we = V > 0 ? market_cap / V : 1.0
wd = V > 0 ? tot_debt / V : 0.0

est_wacc = (we * ke) + (wd * kd * (1 - tax_rate))
wacc = mode == "Estimated" ? est_wacc : manualW

// ============================================================================
// PLOTTING
// ============================================================================
spread = roic - wacc
is_creating_value = spread > 0

// Histogram for the Economic Spread
c_spread = is_creating_value ? color.new(color.teal, 30) : color.new(color.red, 30)
plot(spread, title="Economic Spread (ROIC - WACC)", style=plot.style_columns, color=c_spread)

// Main metric lines
plot(roic, title="ROIC", color=color.new(color.blue, 0), linewidth=2)
plot(wacc, title="WACC", color=color.new(color.orange, 0), linewidth=2)

// Zero line baseline
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
````
