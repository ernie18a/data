# [FN] Session Range & Date Range For Backtesting

- url: https://www.tradingview.com/script/OCk8Jdf8-FN-Session-Range-Date-Range-For-Backtesting/
- type: indicator
- pine_id: PUB;iGhsheC918D8pkqypy7rqMgNK7DgBnbL
- version: 2.0

## Description

This has been done before in different ways, however, my goal is to publish a single, simplified copy/paste version of the idea so you can quickly and easily incorporate it into your strategy backtesting. 
You can designate weekdays, weekdays + weekends for 24/7 markets, and also session range. 
So, you trade bitcoin? It works. CME futures? It works. You are a discretionary trader so the only signals that matter are the ones that happen when you're awake? It works. Copy and paste. 
The goal is that its that easy. You'll have to let me know if it is. glhf everyone. 

If I'm not mistaken, you should be able to copy/paste this directly into your strategy script  (Paste it in before your entry declarations). Just leave out the last 2 lines where the bgcolor() is declared... unless you want the background color lit up, that's up to you. It's just for demonstration purposes in this script.

After you've pasted it in, then in your strategy.entry() function you are adding: [ signal_backtest() ]  to the strategy.entry() function. 
e.g: 
strategy.entry("Long", strategy.long, qty=1, when = ENTRY_SIGNAL and signal_backtest())   

Shoutouts to @zenandtheartoftrading and @allanster for providing the basis of this code that I put together here. We stand on the shoulders of giants.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kurtsmock

//@version=5
indicator("Backtesting Session Range Tool", shorttitle="BacktestRange", overlay=true)
// ───── BACKTESTING DATE RANGE ↴
c_startBacktest = input.time(timestamp('01 May 2022 00:00 +0000'),  'Start Date')
c_endBacktest   = input.time(timestamp('01 Jan 2023 00:00 +0000'),  'End Date')

// ───── BACKTESTING SESSION RANGE ↴
s_useSession    = input.bool(true,           'Use Session Constraint')
s_incWeekends   = input.bool(true,           'Include Weekends')
c_sessPeriod    = input.session('1800-1500', 'Session Definition')

// @function Determines Backtesting Date and Session Range. 
// @param _start [time] UNIX time that triggers beginning of backtest range. Used with input.time()
// @param _end [time] UNIX time that triggers the end of the backtest range. Used with input.time() 
// @param _sessions [bool] Boolean Condition - Determines if range should be continuous or broken into sessions
// @param _incWeekends [bool] Boolean Condition - Determines if Weekends should be traded or not. Requires _session = TRUE
// @param _sessPeriod [String] Determines what the session period should be. Used with input.session()
// @returns A boolean result that indicates trades can be taken when TRUE
backtest(int _start, int _end, bool _sessions, bool _incWeekends, string _sessPeriod) => 
    session         = _sessions and _incWeekends ? not na(time(timeframe.period, _sessPeriod + ":1234567")) : _sessions ? not na(time(timeframe.period, _sessPeriod + ":23456")) : true
    backtestRange   = time >= _start and time <= _end and session ? true : false
    backtestRange
    
o_sessionActive = backtest(c_startBacktest, c_endBacktest, s_useSession, s_incWeekends, c_sessPeriod)
bgcolor(o_sessionActive ? color.new(color.black,95) : na, title = "Session Active Background Fill")
````
