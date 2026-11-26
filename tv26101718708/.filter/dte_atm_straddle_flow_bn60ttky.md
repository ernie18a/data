# DTE ATM Straddle & Flow

- url: https://www.tradingview.com/script/BN60tTky-DTE-ATM-Straddle-Flow/
- type: indicator
- pine_id: PUB;268d3cc217914d7e97a38a5105f4fee2
- version: 2.0

## Description

The 0DTE ATM Straddle & Flow Tracker is a real-time options flow and volatility tracking tool designed for day traders trading daily-expiring (0DTE) contracts on major index products (QQQ, SPY, and SPX).

It aggregates real-time OPRA option chain data inside Pine Script to display price movement, volatility decay, and order flow bias.

Key Features
Automated 0DTE Ticker Construction: Automatically generates OPRA option tickers for Call and Put options matching today's date ($YYMMDD$) in Eastern Time. Automatically handles the weekly root conversion for SPX (SPXW).

Intraday Premium Decay Tracking: Locks the 9:30 AM EST market open price to calculate percentage gain/loss (theta decay or volatility expansion) on the Call, the Put, and the combined Straddle price ([symbol="TSX:CALL"]TSX:CALL[/symbol] + Put$).

Market Maker Hedging Bias: Evaluates relative premium skew ([symbol="TSX:CALL"]TSX:CALL[/symbol] - Put$) to categorize institutional dealer hedging pressure in real time (e.g., Accelerated Call Squeeze, Put Dump, or Neutral Chop).

Visual Skew Flip Alerts: Highlights the chart background when net options premium crosses zero, signaling a shift in intraday dealer delta exposure.

Core Metrics Defined
Call / Put Premium: Live market price of individual legs. Identifies which side of the option chain is attracting aggressive buying.
Total Straddle: Combined value ([symbol="TSX:CALL"]TSX:CALL[/symbol] + Put$). Tracks total implied move priced into the market for the current session.

ol Regime: Evaluates total straddle decay vs. 9:30 AM open. Shows if options are undergoing THETA CRUSH ($<-20\%$) or VOL EXPANSION ($>+10\%$).

Net Premium (C - P): Dollar difference between Call and Put value. Crosses above/below zero signal real-time directional order flow shifts.

MM Hedging Bias: Dealer delta alignment based on premium ratio. Flags potential acceleration zones (squeezes/dumps) vs. range-bound chop.

How to Set Up and Use the Indicator
Step 1: Add to TradingView
Open TradingView and navigate to any chart.
Click the Pine Editor tab at the bottom of the screen.
Paste the Pine Script v6 code into the editor and click Save.
Click Add to Chart (the indicator runs in a separate panel below your main price chart).
Step 2: Configure Settings Each Morning
Open the indicator Settings gear icon:
Underlying Symbol: Choose QQQ, SPY, or SPX.
Strike Price: Enter the active At-The-Money (ATM) strike price near the market open (e.g., 760 for QQQ, 580 for SPY, 5800 for SPX).
DTE Expiry (YYMMDD): Leave blank to automatically select today's 0DTE date, or manually input a specific date (e.g., 261006 for Oct 6, 2026).
How to Interpret Signals in Live Trading
Scenario A: Theta Crush / Range-Bound Market
Dashboard Readout: Vol Regime: THETA CRUSH (Straddle down $>20\%$).

Flow State: MM Hedging Bias: NEUTRAL / CHOP.
Actionable Takeaway: Option sellers are draining extrinsic value. Expect price to stay pinned between key gamma levels. Long straddles/strangles will suffer heavy decay.
Scenario B: Momentum Expansion (Call Squeeze)

Dashboard Readout: MM Hedging Bias: ACCEL BUYING (CALL SQUEEZE).
Chart Signal: Background flashes Blue (Net premium crossed above zero).
Actionable Takeaway: Call pricing is heavily outperforming puts ([symbol="TSX:CALL"]TSX:CALL[/symbol] > 2 \times Put$). Dealers holding short calls are forced to buy underlying futures/shares to hedge, accelerating upward momentum.

cenario C: Downside Acceleration (Put Dump)
Dashboard Readout: MM Hedging Bias: ACCEL SELLING (PUT DUMP).
Chart Signal: Background flashes Red (Net premium crossed below zero).
Actionable Takeaway: Put pricing is surging relative to calls ([symbol="CBOE:PUT"]CBOE:PUT[/symbol] > 2 \times Call$). Dealers hedging short puts are forced to sell stock/futures, increasing downside pressure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KinetiCapital

//@version=6
indicator("DTE ATM Straddle & Flow", shorttitle="DTE Straddle", overlay=false)

// ==========================================
// USER INPUTS
// ==========================================
string i_underlying   = input.string("QQQ", "Underlying Symbol", options=["QQQ", "SPY", "SPX"], group="Contract Selection")
string i_expiry       = input.string("", "DTE Expiry (YYMMDD)", tooltip="Leave empty to auto-build today's 0DTE date in NY time", group="Contract Selection")
float  i_strike       = input.float(760.0, "Strike Price", step=1.0, group="Contract Selection", tooltip="Set to active strike (e.g., 760 for QQQ, 580 for SPY, 5800 for SPX)")

// Plot Toggles
bool   i_show_net     = input.bool(false, "Show Net Premium Line (Call - Put)", group="Display Options")
bool   i_show_flips   = input.bool(true, "Highlight Hedging Flip Bars", group="Display Options")

// Visual Customizations
color  col_call       = input.color(color.rgb(24, 144, 219), "Call Price", group="Visuals", inline="c1")
color  col_put        = input.color(color.rgb(229, 57, 53), "Put Price", group="Visuals", inline="c1")
color  col_straddle   = input.color(color.rgb(0, 0, 0), "Total Straddle", group="Visuals", inline="c2")
color  col_net        = input.color(color.rgb(155, 39, 176, 60), "Net Premium (C-P)", group="Visuals", inline="c2")
color  col_text       = input.color(color.rgb(54, 58, 69), "Table Text", group="Visuals", inline="c3")
color  col_bg         = color.rgb(54, 58, 69, 90)

// ==========================================
// DATE & SESSION HANDLING
// ==========================================
string tz = "America/New_York"
int    currYY = year(time, tz) % 100
int    currMM = month(time, tz)
int    currDD = dayofmonth(time, tz)

// Auto-generate YYMMDD string if input is blank
string auto_expiry   = str.format("{0,number,00}{1,number,00}{2,number,00}", currYY, currMM, currDD)
string active_expiry = str.length(i_expiry) == 6 ? i_expiry : auto_expiry

// Regular Trading Hours (9:30 AM - 4:00 PM EST)
bool is_today = (year(time, tz) == year(timenow, tz)) and (month(time, tz) == month(timenow, tz)) and (dayofmonth(time, tz) == dayofmonth(timenow, tz))
bool in_rth   = is_today and time >= timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 9, 30) and time < timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 16, 0)
bool is_open  = in_rth and not in_rth[1]

// ==========================================
// DYNAMIC OPRA TICKER MAPPING
// ==========================================
string base_symbol = i_underlying == "SPX" ? "SPXW" : i_underlying

f_sym(_u, _exp, _cp, _k) =>
    "OPRA:" + _u + _exp + _cp + str.format("{0,number,0.0}", _k)

string c_ticker = f_sym(base_symbol, active_expiry, "C", i_strike)
string p_ticker = f_sym(base_symbol, active_expiry, "P", i_strike)

// Request security data across active timeframe
[call_close, call_vol] = request.security(c_ticker, timeframe.period, [close, volume], barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
[put_close,  put_vol]  = request.security(p_ticker, timeframe.period, [close, volume], barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

// Request 1-minute resolution high data for the 9:30 AM open bar
float c_1m_high = nz(request.security(c_ticker, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p_1m_high = nz(request.security(p_ticker, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// Fallbacks for non-existent bars
float c_px = nz(call_close, 0.0)
float p_px = nz(put_close, 0.0)
float straddle_price = c_px + p_px
float net_premium    = c_px - p_px

// Lock 9:30 AM 1-Minute Max Open Prices
var float open_call     = na
var float open_put      = na
var float open_straddle = na

if is_open or (in_rth and na(open_straddle))
    open_call     := c_1m_high > 0 ? c_1m_high : (c_px > 0 ? c_px : na)
    open_put      := p_1m_high > 0 ? p_1m_high : (p_px > 0 ? p_px : na)
    open_straddle := (open_call + open_put) > 0 ? (open_call + open_put) : (straddle_price > 0 ? straddle_price : na)

// Decay percentages calculated against 9:30 AM 1m Max values
float call_decay     = not na(open_call) and open_call > 0         ? ((c_px - open_call) / open_call) * 100.0 : 0.0
float put_decay      = not na(open_put) and open_put > 0           ? ((p_px - open_put) / open_put) * 100.0 : 0.0
float straddle_decay = not na(open_straddle) and open_straddle > 0 ? ((straddle_price - open_straddle) / open_straddle) * 100.0 : 0.0

// Secondary Metrics
float call_put_ratio = p_px > 0 ? c_px / p_px : na

// ==========================================
// MM HEDGING FLIP LOGIC
// ==========================================
bool net_flip_bull = ta.crossover(net_premium, 0)
bool net_flip_bear = ta.crossunder(net_premium, 0)

bgcolor(i_show_flips and net_flip_bull ? color.new(color.blue, 80) : i_show_flips and net_flip_bear ? color.new(color.red, 80) : na)

// ==========================================
// PLOTS & DISPLAY
// ==========================================
plot(in_rth and c_px > 0 ? c_px : na,                     title="Call Option Price",   color=col_call,     linewidth=2)
plot(in_rth and p_px > 0 ? p_px : na,                     title="Put Option Price",    color=col_put,      linewidth=2)
plot(in_rth and straddle_price > 0 ? straddle_price : na, title="Total Straddle (C+P)",color=col_straddle, linewidth=2)
plot(in_rth and i_show_net ? net_premium : na,            title="Net Premium (C-P)",   color=col_net,      linewidth=1, style=plot.style_line)

hline(0, "Zero Level", color=color.new(color.gray, 70))

// Dashboard HUD (Positioned Middle-Left)
var table tDash = table.new(position.middle_left, 2, 5, border_width=1)
if barstate.islast
    table.cell(tDash, 0, 0, str.format("{0} ({1})", i_underlying, active_expiry), text_color=col_text, bgcolor=col_bg, text_size=size.small)
    table.cell(tDash, 1, 0, str.format("Strike: {0,number,#.0}", i_strike), text_color=col_text, bgcolor=col_bg, text_size=size.small)

    table.cell(tDash, 0, 1, "Call Premium", text_color=col_text, bgcolor=col_bg, text_size=size.small)
    table.cell(tDash, 1, 1, c_px > 0 ? str.format("${0,number,#.00} ({1,number,+#.0;-#.0}%)", c_px, call_decay) : "No Data", text_color=col_call, bgcolor=col_bg, text_size=size.small)

    table.cell(tDash, 0, 2, "Put Premium", text_color=col_text, bgcolor=col_bg, text_size=size.small)
    table.cell(tDash, 1, 2, p_px > 0 ? str.format("${0,number,#.00} ({1,number,+#.0;-#.0}%)", p_px, put_decay) : "No Data", text_color=col_put, bgcolor=col_bg, text_size=size.small)

    table.cell(tDash, 0, 3, "Total Straddle", text_color=col_text, bgcolor=col_bg, text_size=size.small)
    table.cell(tDash, 1, 3, straddle_price > 0 ? str.format("${0,number,#.00} ({1,number,+#.0;-#.0}%)", straddle_price, straddle_decay) : "No Data", text_color=col_straddle, bgcolor=col_bg, text_size=size.small)

    table.cell(tDash, 0, 4, "Call / Put Ratio", text_color=col_text, bgcolor=col_bg, text_size=size.small)
    table.cell(tDash, 1, 4, not na(call_put_ratio) ? str.format("{0,number,#.00}x", call_put_ratio) : "—", text_color=col_text, bgcolor=col_bg, text_size=size.small)
````
