<!-- tradingview-pine-id: PUB;04a3d3e0a9c14e68ba719586ec4d767f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FT_TV_lib

Source: https://www.tradingview.com/script/su5UfvQs-FT-TV-lib/

## Description

FT_TV_lib is a Pine Script® v6 utility library which provides reusable components for systematic and algorithmic trading strategies.

The library centralizes a range of commonly required operations, including trading-session management, session-based OHLC calculations, strategy and position monitoring, trade-management utilities, futures rollover handling, technical calculations, alerts, and chart visualization tools.

Main exported functionality

[*]Session and OHLC utilities — Functions for identifying session and day transitions and retrieving session-aware Open, High, Low and Close values, including previous sessions. Main functions include [pine]sessionstart()[/pine], [pine]isNewDay()[/pine], [pine]isLastBarOfDay()[/pine], [pine]openD()[/pine], [pine]highD()[/pine], [pine]lowD()[/pine], [pine]closeD()[/pine] and their related session utilities.

[*]Strategy and trade management — Utilities for detecting position state, counting daily entries, measuring bars since entry, limiting trade duration and calculating dynamic trailing-stop levels. Relevant functions include [pine]mp()[/pine], [pine]BarsSinceLastEntry()[/pine], [pine]entriestoday()[/pine], [pine]MaxTradeDuration()[/pine] and [pine]TrailingStop()[/pine].

[*]Intraday market analysis — Session-aware Body Factor calculations and related OHLC components for analyzing directional price movement inside configurable intraday periods through functions such as [pine]IntradayBodyFactor_v2()[/pine] and the related [pine]IntradayBF_Open()[/pine], [pine]IntradayBF_High()[/pine], [pine]IntradayBF_Low()[/pine] and [pine]IntradayBF_Close()[/pine].

[*]Trade and order visualization — [pine]VisualTrades()[/pine] and [pine]DrawEntryOrdersHistorySeries()[/pine] provide reusable chart components for displaying entries, exits, stop-loss, trailing-stop, take-profit and pending order levels.

[*]Futures rollover utilities — Functions for resolving active futures expiries and symbols and supporting rollover notifications, including [pine]active_expiry()[/pine], [pine]active_symbol()[/pine] and [pine]check_and_build_alert()[/pine].

[*]Technical-analysis utilities — Reusable implementations of commonly used calculations including Average, Average True Range, MACD, Rate of Change, Standard Deviation, Bollinger Bands, Momentum, Stochastic, CCI, RSI, ADX and Inside Bar detection.

[*]Alerts and interface utilities — Additional exported functions support strategy trade alerts and reusable chart information displays, including [pine]AlertMessages()[/pine] and [pine]Badge()[/pine].

Purpose

This library is primarily designed as a shared dependency for other Pine Script® strategies, allowing common trading, analytical and visualization components to remain consistent across multiple strategy implementations.

Usage, attribution and intellectual property

This Pine Script® library is published open-source in accordance with TradingView's requirements for public Pine libraries.

Under TradingView's Script Publishing Rules, functions or code from a public Pine library may be reused in open-source publications without prior permission from the author. When publishing work that reuses this library, the original author must be properly credited in accordance with TradingView's rules.

Reuse of this library's functions or source code in a public Protected or Invite-only publication requires explicit permission from us.

The source code is provided under the license specified in the script header. TradingView's Script Publishing Rules govern reuse within the TradingView platform.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6

library("FT_TV_lib", overlay = true, dynamic_requests = true)




///////////////////////////// Z - OHLC - START /////////////////////////////
///////////////////////////// Z - OHLC - START /////////////////////////////
///////////////////////////// Z - OHLC - START /////////////////////////////
///////////////////////////// Z - OHLC - START /////////////////////////////
///////////////////////////// Z - OHLC - START /////////////////////////////
///////////////////////////// Z - OHLC - START /////////////////////////////


checkrange(int x, string name) =>
    if x < 0 or x > 10
        runtime.error(name + "(x): x must be between 0 and 10")   


inSess(string session, string timezone) =>
    parts    = str.split(session, "-")
    startHH  = str.tonumber(array.get(parts, 0)) - 0.01
    endHH    = str.tonumber(array.get(parts, 1)) - 0.01
    hh       = hour(time, timezone)
    mm       = minute(time, timezone)
    hhmm     = hh * 100 + mm
    if startHH < endHH
        hhmm >= startHH and hhmm <= endHH
    else
        // sessione overnight 
        hhmm >= startHH or hhmm <= endHH    


sessionstartstring(string session) =>
    parts    = str.split(session, "-")
    str.tonumber(array.get(parts, 0))


sessionendstring(string session) =>
    parts    = str.split(session, "-")
    str.tonumber(array.get(parts, 1))


f_sessionstart(int SessionStartTime, string timezone) =>

    hh       = hour(time, timezone)
    mm       = minute(time, timezone)
    hhmm     = hh * 100 + mm

    hhmm == SessionStartTime 


export sessionstart(int SessionStartTime, string timezone) =>

    hh       = hour(time, timezone)
    mm       = minute(time, timezone)
    hhmm     = hh * 100 + mm

    hhmm == SessionStartTime 


f_time(int barsback, string timezone) =>
    h = hour(time, timezone)[barsback]
    m = minute(time, timezone)[barsback]
    h * 100 + m


f_time_close(int barsback, string timezone) =>
    h = hour(time_close, timezone)[barsback]
    m = minute(time_close, timezone)[barsback]
    h * 100 + m


f_idx_now(timezone) =>
    hour(time, timezone) * 60 + minute(time, timezone)

f_hhmm_from_idx(idx) =>
    hh = int(math.floor(idx / 60))
    mm = idx % 60
    hh * 100 + mm


export isLastBarOfDay(string timezone) =>
    // Stato 
    var int   max_idx_today   = na        
    var int   mode_idx        = na        
    var int   days_counted    = 0
    var int[] counts_by_min   = array.new_int(1440, 0) 
    var int   last_day_marker = na
    var int min_hits_for_lock = 3

    // Corrente
    curr_day_marker = time("D")
    curr_idx        = f_idx_now(timezone)

    if na(last_day_marker)
        last_day_marker := curr_day_marker
        max_idx_today   := curr_idx

    if na(max_idx_today) or curr_idx > max_idx_today
        max_idx_today := curr_idx

    // Se inizia una nuova giornata, consolida il max di ieri e aggiorna la modalità
    if curr_day_marker != curr_day_marker[1]
        prev_idx = max_idx_today
        if not na(prev_idx) and prev_idx >= 0 and prev_idx < 1440
            prev_count = array.get(counts_by_min, prev_idx) + 1
            array.set(counts_by_min, prev_idx, prev_count)
            days_counted += 1

            // aggiorna il mode se necessario
            curr_mode_count = na(mode_idx) ? -1 : array.get(counts_by_min, mode_idx)
            if prev_count > curr_mode_count
                mode_idx := prev_idx

        // reset per il nuovo giorno
        last_day_marker := curr_day_marker
        max_idx_today   := curr_idx

    // Condizione VERA sulla barra che chiude la giornata
    stable = not na(mode_idx) and array.get(counts_by_min, mode_idx) >= min_hits_for_lock
    isLastBarOfDay = stable and (curr_idx == mode_idx)

    isLastBarOfDay



f_fixed_hhmm_from_offset_num(n, hhmm_target, tz) =>
    _tH = math.floor(hhmm_target / 100)
    _tM = hhmm_target % 100

    _bar_sec  = timeframe.in_seconds(timeframe.period)
    _step_min = int(math.round(_bar_sec / 60.0))

    _shift_min = n * _step_min

    _total_min       = _tH * 60 + _tM + _shift_min
    _total_min_norm  = ((_total_min % 1440) + 1440) % 1440

    _resH = int(_total_min_norm / 60)
    _resM = _total_min_norm % 60
    _resH * 100 + _resM 


inSessDay(string session, string timezone) =>
    parts    = str.split(session, "-")
    startHH  = str.tonumber(array.get(parts, 0)) 
    endHH    = str.tonumber(array.get(parts, 1))
    hh       = hour(time, timezone)
    mm       = minute(time, timezone)
    hhmm     = hh * 100 + mm
    if startHH < endHH
        hhmm >= startHH and hhmm <= endHH
    else
        hhmm >= startHH or hhmm <= endHH  


export openDay(int x, string session, string timezone) =>
    checkrange(x, "openDay")

    var float[] openArray = array.new_float()

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone) and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone)
    time_cond = f_time(1, timezone) <= f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_time(1, timezone) and inSessDay(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSessDay(session, timezone)

    _startHHmm = sessionstartstring(session)
    _curHHmm   = f_time(0, timezone)
    _dayChanged = dayofmonth(time, timezone) != dayofmonth(time, timezone)[1]
    missedStart = inSess and _dayChanged and (_curHHmm > _startHHmm)

    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone))
    newSess := newSess or missedStart  

    if newSess
        array.unshift(openArray, open)
        if array.size(openArray) > 11
            array.pop(openArray)

    if array.size(openArray) <= x
        na
    else
        array.get(openArray, x)



export highDay(int x, string session, string timezone) =>
    checkrange(x, "highDay")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone) and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone)
    time_cond = f_time(1, timezone) <= f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_time(1, timezone) and inSessDay(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSessDay(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone))


    _startHHmm  = sessionstartstring(session)
    _curHHmm    = f_time(0, timezone)
    _dayChanged = dayofmonth(time, timezone) != dayofmonth(time, timezone)[1]
    missedStart = inSess and _dayChanged and (_curHHmm > _startHHmm)
    newSess := newSess or missedStart


    var float[] Higharray = array.new_float()
    var float currHigh = na

    if inSess and not newSess
        currHigh := math.max(currHigh, high)
        array.set(Higharray, 0, currHigh)

    if newSess
        currHigh := high
        array.unshift(Higharray, currHigh)
        if array.size(Higharray) > 11
            array.pop(Higharray)


    if array.size(Higharray) <= x
        na
    else
        array.get(Higharray, x)




export lowDay(int x, string session, string timezone) =>
    checkrange(x, "lowDay")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone) and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone)
    time_cond = f_time(1, timezone) <= f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_time(1, timezone) and inSessDay(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSessDay(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone))


    _startHHmm  = sessionstartstring(session)
    _curHHmm    = f_time(0, timezone)
    _dayChanged = dayofmonth(time, timezone) != dayofmonth(time, timezone)[1]
    missedStart = inSess and _dayChanged and (_curHHmm > _startHHmm)
    newSess := newSess or missedStart


    var float[] Lowarray = array.new_float()
    var float currlow = 9999999999.0

    if inSess and not newSess
        currlow := math.min(currlow, low)
        array.set(Lowarray, 0, currlow)

    if newSess
        currlow := low
        array.unshift(Lowarray, currlow)
        if array.size(Lowarray) > 11
            array.pop(Lowarray)


    if array.size(Lowarray) <= x
        na
    else
        array.get(Lowarray, x)




export closeDay(int x, string session, string timezone) =>
    checkrange(x, "closeDay")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone) and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone)
    time_cond = f_time(1, timezone) <= f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_fixed_hhmm_from_offset_num(-1, sessionendstring(session), timezone) and f_time(0, timezone) < f_time(1, timezone) and inSessDay(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSessDay(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= f_fixed_hhmm_from_offset_num(-1, sessionstartstring(session), timezone))


    _startHHmm  = sessionstartstring(session)
    _curHHmm    = f_time(0, timezone)
    _dayChanged = dayofmonth(time, timezone) != dayofmonth(time, timezone)[1]
    missedStart = inSess and _dayChanged and (_curHHmm > _startHHmm)
    newSess := newSess or missedStart


    var float[] Closearray = array.new_float()

    if inSess and not newSess
        if array.size(Closearray) > 0
            array.set(Closearray, 0, close)

    if newSess
        array.unshift(Closearray, close)
        if array.size(Closearray) > 11
            array.pop(Closearray)


    if array.size(Closearray) <= x
        na
    else
        array.get(Closearray, x)





f_openD(int x, string session, string timezone) =>
    checkrange(x, "f_openD")

	var float[] openArray = array.new_float()

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))

	if newSess
    	array.unshift(openArray, open)
		if array.size(openArray) > 11
        	array.pop(openArray)

	

    if array.size(openArray) <= x
        na
    else
        array.get(openArray, x)



f_highD(int x, string session, string timezone) =>
    checkrange(x, "f_highD")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))


    var float[] Higharray = array.new_float()
    var float currHigh = na

    if inSess and not newSess
        currHigh := math.max(currHigh, high)
        array.set(Higharray, 0, currHigh)

    if newSess
        currHigh := high
        array.unshift(Higharray, currHigh)
        if array.size(Higharray) > 11
            array.pop(Higharray)


    if array.size(Higharray) <= x
        na
    else
        array.get(Higharray, x)



f_lowD(int x, string session, string timezone) =>
    checkrange(x, "f_lowD")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))

	var float[] Lowarray = array.new_float()
	var float currlow = 9999999999.0

    if inSess and not newSess
        currlow := math.min(currlow, low)
        array.set(Lowarray, 0, currlow)

	if newSess
        currlow := low
		array.unshift(Lowarray, currlow)
    	if array.size(Lowarray) > 11
    		array.pop(Lowarray)



    if array.size(Lowarray) <= x
        na
    else
        array.get(Lowarray, x)


f_closeD(int x, string session, string timezone) =>
    checkrange(x, "f_closeD")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))
        
	var float[] Closearray = array.new_float()

	if inSess and not newSess
        if array.size(Closearray) > 0
            array.set(Closearray, 0, close)		
			
	if newSess
		array.unshift(Closearray, close)
    	if array.size(Closearray) > 11
        	array.pop(Closearray)	



    if array.size(Closearray) <= x
        na
    else
        array.get(Closearray, x)





export openD(int x, string session, string timezone) =>
    checkrange(x, "openD")

	var float[] openArray = array.new_float()

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))

	if newSess
    	array.unshift(openArray, open)
		if array.size(openArray) > 11
        	array.pop(openArray)

	

    if array.size(openArray) <= x
        na
    else
        array.get(openArray, x)


export highD(int x, string session, string timezone) =>
    checkrange(x, "highD")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))


    var float[] Higharray = array.new_float()
    var float currHigh = na

    if inSess and not newSess
        currHigh := math.max(currHigh, high)
        array.set(Higharray, 0, currHigh)

    if newSess
        currHigh := high
        array.unshift(Higharray, currHigh)
        if array.size(Higharray) > 11
            array.pop(Higharray)


    if array.size(Higharray) <= x
        na
    else
        array.get(Higharray, x)



export lowD(int x, string session, string timezone) =>
    checkrange(x, "lowD")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))

	var float[] Lowarray = array.new_float()
	var float currlow = 9999999999.0

    if inSess and not newSess
        currlow := math.min(currlow, low)
        array.set(Lowarray, 0, currlow)

	if newSess
        currlow := low
		array.unshift(Lowarray, currlow)
    	if array.size(Lowarray) > 11
    		array.pop(Lowarray)



    if array.size(Lowarray) <= x
        na
    else
        array.get(Lowarray, x)



export closeD(int x, string session, string timezone) =>
    checkrange(x, "closeD")

    session_cond = sessionstartstring(session) < sessionendstring(session)
    sessionstarttime_cond = f_time(1, timezone) < sessionstartstring(session) and f_time(0, timezone) >= sessionstartstring(session)
    time_cond = f_time(1, timezone) <= sessionendstring(session) and f_time(0, timezone) < sessionendstring(session) and f_time(0, timezone) < f_time(1, timezone) and inSess(session, timezone) and not ((math.abs(time[1] - time))/(60*1000) == str.tonumber(timeframe.period))
    newSess = false

    inSess = inSess(session, timezone)
    newSess := (inSess and not inSess[1]) or (inSess and sessionstarttime_cond) or time_cond or (inSess and inSess[1] and dayofmonth(time, timezone) != dayofmonth(time, timezone)[1] and f_time(0, timezone) >= sessionstartstring(session))
        
	var float[] Closearray = array.new_float()

	if inSess and not newSess
        if array.size(Closearray) > 0
            array.set(Closearray, 0, close)		
			
	if newSess
		array.unshift(Closearray, close)
    	if array.size(Closearray) > 11
        	array.pop(Closearray)	



    if array.size(Closearray) <= x
        na
    else
        array.get(Closearray, x)


///////////////////////////// Z - OHLC - END /////////////////////////////
///////////////////////////// Z - OHLC - END /////////////////////////////
///////////////////////////// Z - OHLC - END /////////////////////////////
///////////////////////////// Z - OHLC - END /////////////////////////////
///////////////////////////// Z - OHLC - END /////////////////////////////
///////////////////////////// Z - OHLC - END /////////////////////////////






///////////////////////////// Z - FUNC - START /////////////////////////////
///////////////////////////// Z - FUNC - START /////////////////////////////
///////////////////////////// Z - FUNC - START /////////////////////////////
///////////////////////////// Z - FUNC - START /////////////////////////////
///////////////////////////// Z - FUNC - START /////////////////////////////
///////////////////////////// Z - FUNC - START /////////////////////////////

TrueLow() =>
    if close[1] < low
        close[1]

    else
        low


TrueHigh() =>
    if close[1] > high
        close[1]

    else
        high


TrueRange() =>
    TrueHigh() - TrueLow()



Summation(float PriceValue, int Length) =>
	var float var0 = 0.00000
	var0 := 0

	for value1 = 0 to (Length - 1)
		var0 := var0 + PriceValue[value1]
	
	var0



f_Avg(float PriceValue, int Length) =>
	Summation(PriceValue, Length) / Length



export AvgTrueRange(int Len) =>
    f_Avg(TrueRange(), Len)


export InsideBar() =>
    Inside = high < high[1] and low > low[1]
    if Inside[1]
        Inside := high < high[2] and low > low[2]
    if Inside[1] and Inside[2]
        Inside := high < high[3] and low > low[3]
    if Inside[1] and Inside[2] and Inside[3]
        Inside := high < high[4] and low > low[4]
    if Inside[1] and Inside[2] and Inside[3] and Inside[4]
        Inside := high < high[5] and low > low[5]
    Inside


f_timetoHHmm(int barsback, string timezone) =>
    h = hour(time[barsback], timezone)
    m = minute(time[barsback], timezone)
    h * 100 + m


export timetoHHmm(int barsback, string timezone) =>
    h = hour(time[barsback], timezone)
    m = minute(time[barsback], timezone)
    h * 100 + m


f_closetimetoHHmm(int barsback, string timezone) =>
    h = hour(time_close[barsback], timezone)
    m = minute(time_close[barsback], timezone)
    h * 100 + m

export closetimetoHHmm(int barsback, string timezone) =>
    h = hour(time_close[barsback], timezone)
    m = minute(time_close[barsback], timezone)
    h * 100 + m


export isNewDay(string timezone) =>
    barstate.isfirst or str.format_time(time, "dd", timezone) != str.format_time(time[1], "dd", timezone)



f_mp() =>
    if strategy.position_size > 0 
        1
    else if strategy.position_size < 0
        -1
    else 
        0

export mp() =>
    if strategy.position_size > 0 
        1
    else if strategy.position_size < 0
        -1
    else 
        0


export BarsSinceLastEntry() =>
    bar_index - strategy.opentrades.entry_bar_index(strategy.opentrades - 1)



export FT(int starttime, int endtime, string timezone) =>
    if starttime > endtime and not (starttime >= 2400 and endtime >= 2400)
        f_time_close(0, timezone) >= starttime or f_time_close(0, timezone) < endtime
    else if (starttime >= 2400 and endtime >= 2400)
        true
    else
        f_time_close(0, timezone) >= starttime and f_time_close(0, timezone) < endtime



export entriestoday(string timezone) =>
    int yC = year(time_close,  timezone)
    int mC = month(time_close, timezone)
    int dC = dayofmonth(time_close, timezone)

    int dayStart = timestamp(timezone, yC, mC, dC, 0, 0)
    int dayEnd   = dayStart + 24 * 60 * 60 * 1000

    int count = 0

    int nClosed = strategy.closedtrades
    for i = nClosed - 1 to 0
        int et = strategy.closedtrades.entry_time(i)
        if et >= dayStart and et < dayEnd
            count += 1
        else if et < dayStart
            break

    int nOpen = strategy.opentrades
    for j = nOpen - 1 to 0
        int eo = strategy.opentrades.entry_time(j)
        if eo >= dayStart and eo < dayEnd
            count += 1
        else if eo < dayStart
            break

    count



export Z_MaxTradeDuration(int SessionStartTime, string timezone, int MaxNDaysDuration) =>
    mp = f_mp()
    sessionBegin = f_sessionstart(SessionStartTime, timezone)
    preventry = strategy.opentrades.entry_price(strategy.opentrades - 1)
    var int tradeDaysHeld = 0
    tradeDaysHeld := tradeDaysHeld[1]

    wasjustopened = (preventry != preventry[1] and (strategy.opentrades.entry_price(strategy.opentrades - 1)) != 0) or (mp != 0 and mp != mp[1])

    if mp == 0 
        tradeDaysHeld := 0

    else if wasjustopened
        tradeDaysHeld := 1

    else if sessionBegin 
        tradeDaysHeld := tradeDaysHeld + 1

    if tradeDaysHeld >= MaxNDaysDuration and MaxNDaysDuration > 0 
        true

    else 
        false



export MaxTradeDuration(int SessionStartTime, string timezone, int MaxNDaysDuration) =>
    mp = f_mp()
    sessionBegin = f_sessionstart(SessionStartTime, timezone)
    preventry = strategy.opentrades.entry_price(strategy.opentrades - 1)
    var int tradeDaysHeld = 0
    tradeDaysHeld := tradeDaysHeld[1]

    wasjustopened = (mp != 0 and mp != mp[1])

    if mp == 0 
        tradeDaysHeld := 0

    else if wasjustopened
        tradeDaysHeld := 1

    else if sessionBegin 
        tradeDaysHeld := tradeDaysHeld + 1

    if tradeDaysHeld >= MaxNDaysDuration and MaxNDaysDuration > 0 
        true

    else 
        false

    


export TrailingStop(float TrailStopGainLevel, float TrailStopDistance, int TrailStopActivated) =>

    var float entry   = na
    var int   eBar    = na
    var float peakHi  = na
    var float troughLo= na

    bool inPos  = strategy.position_size != 0
    bool newPos = inPos and (
         strategy.position_size[1] == 0 or
         math.sign(strategy.position_size) != math.sign(strategy.position_size[1])
    )

    if newPos
        entry    := strategy.position_avg_price
        eBar     := bar_index
        peakHi   := high
        troughLo := low

    if inPos and not newPos
        if strategy.position_size > 0
            peakHi := na(peakHi) ? high : math.max(peakHi, high)
        else
            troughLo := na(troughLo) ? low : math.min(troughLo, low)

    float runupPts = na
    if inPos and not na(entry)
        runupPts := strategy.position_size > 0 ? (peakHi - entry) : (entry - troughLo)

    bool ok = TrailStopActivated == 1 and TrailStopGainLevel > 0 and TrailStopDistance > 0 and
              inPos and not na(runupPts) and runupPts >= TrailStopGainLevel and
              (bar_index - eBar) > 1

    float trail = na
    if ok
        float retr = runupPts * (1 - TrailStopDistance / 100)
        trail := strategy.position_size > 0 ? entry + retr : entry - retr

    trail





export IntradayBodyFactor(int SessionStartTime, int SessionEndTime, int MyBodyFactorStartTime, int MyBodyFactorEndTime, string session, string timezone) =>
    var float periodlow = 0
    var float ok = 0.000000
    var float periodopen = 0
    var float periodhigh = 0
    var float periodclose = 0
    var float periodhighest = 0
    var float periodlowest = 0
    var int mycountopen = 0
    var int mycountclose = 0
    var int verificamycountopen = 0
    var int verificamycountclose = 0
    var int RealBFEndTime = 2500
    var int RealSessEndTime = 2500
    var int RealBFStartTime = 2500
    var int RealSessStartTime = 2500
    bool IsStartofSession = false
    int ftime = f_timetoHHmm(0, timezone)


    if (MyBodyFactorEndTime/100) - int(MyBodyFactorEndTime/100) == 0.00
        RealBFEndTime := int(MyBodyFactorEndTime - 40 - str.tonumber(timeframe.period))
    else
        RealBFEndTime := int(MyBodyFactorEndTime - str.tonumber(timeframe.period))


    if (SessionEndTime/100) - int(SessionEndTime/100) == 0.00
        RealSessEndTime := int(SessionEndTime - 40 - str.tonumber(timeframe.period))
    else
        RealSessEndTime := int(SessionEndTime - str.tonumber(timeframe.period))


    if (MyBodyFactorStartTime/100) - int(MyBodyFactorStartTime/100) == 0.00
        RealBFStartTime := int(MyBodyFactorStartTime - 40 - str.tonumber(timeframe.period))
    else
        RealBFStartTime := int(MyBodyFactorStartTime - str.tonumber(timeframe.period))


    if (SessionStartTime/100) - int(SessionStartTime/100) == 0.00
        RealSessStartTime := int(SessionStartTime - 40 - str.tonumber(timeframe.period))
    else
        RealSessStartTime := int(SessionStartTime - str.tonumber(timeframe.period))


    periodopen := periodopen[1]
    periodclose := periodclose[1]
    periodhigh := periodhigh[1]
    periodlow := periodlow[1]
    periodhighest := periodhighest[1]
    periodlowest := periodlowest[1]
    ok := ok[1]


    IsStartofSession := f_sessionstart(SessionStartTime, timezone)
    opend1 = f_openD(1, session, timezone)
    highd1 = f_highD(1, session, timezone)
    lowd1 = f_lowD(1, session, timezone)
    closed1 = f_closeD(1, session, timezone)


    if MyBodyFactorStartTime != SessionStartTime 
        if ftime == RealBFStartTime
            verificamycountopen := 1
            mycountopen := 0

        if verificamycountopen[1] > 0 
            verificamycountopen := 1
            mycountopen := mycountopen[1] + 1
        
        if IsStartofSession
            mycountopen := 0
            verificamycountopen := 0


    if MyBodyFactorEndTime != SessionEndTime 

        if ftime == RealBFEndTime
            verificamycountclose := 1

        if verificamycountclose[1] > 0
            verificamycountclose := 1
            mycountclose := mycountclose[1] + 1

        if IsStartofSession
            mycountclose := 0
            verificamycountclose := 0


    if MyBodyFactorStartTime == SessionStartTime
        if (ftime >= RealSessEndTime and ftime[1] < RealSessEndTime) or (ftime[1] == RealSessEndTime)
            verificamycountopen := 1
            mycountopen := 0

        if verificamycountopen[1] > 0 //and not (ftime >= RealSessEndTime and ftime[1] < RealSessEndTime) or (ftime[1] == RealSessEndTime)
            verificamycountopen := 1
            mycountopen := mycountopen + 1


    if MyBodyFactorEndTime == SessionEndTime
        if (ftime >= RealSessEndTime and ftime[1] < RealSessEndTime) or (ftime[1] == RealSessEndTime)
            verificamycountclose := 1
            mycountclose := 2

        if verificamycountclose[1] > 0 and not ((ftime >= RealSessEndTime and ftime[1] < RealSessEndTime) or (ftime[1] == RealSessEndTime))
            verificamycountclose := 1
            mycountclose :=  mycountclose[1] + 1


    if na(mycountopen)
        mycountopen := 0

    if na(mycountclose)
        mycountclose := 0


    periodhighest := ta.highest(high, mycountopen + 1)
    periodlowest := ta.lowest(low, mycountopen + 1)


    if mycountclose > 0 and (MyBodyFactorStartTime != SessionStartTime or MyBodyFactorEndTime != SessionEndTime)
        periodclose := close[mycountclose]
        periodopen := open[mycountopen]

        periodhigh := periodhighest[mycountclose]
        periodlow := periodlowest[mycountclose]



    if MyBodyFactorStartTime == SessionStartTime and MyBodyFactorEndTime == SessionEndTime
        periodclose := closed1
        periodopen := opend1
        periodhigh := highd1
        periodlow := lowd1
        if periodclose > periodopen
            ok := (periodclose - periodopen) / (periodhigh - periodlow)

        if periodclose < periodopen 
            ok := -(periodopen - periodclose) / (periodhigh - periodlow)


    if mycountclose > 0 and mycountclose < mycountopen
        if periodclose > periodopen
            ok := (periodclose - periodopen) / (periodhigh - periodlow)

        if periodclose < periodopen 
            ok := -(periodopen - periodclose) / (periodhigh - periodlow)


    ok


export IntradayBodyFactor_v2(int SessionStartTime, int SessionEndTime, int MyBodyFactorStartTime, int MyBodyFactorEndTime, string timezone) =>
    if SessionStartTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if SessionEndTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if timezone == ""
        runtime.error("Set a correct timezone")

    var periodlow = 0.0000
    var periodopen = 0.0000
    var periodhigh = 0.0000
    var periodclose = 0.0000
    var previousperiodlow = 0.0000
    var previousperiodopen = 0.0000
    var previousperiodhigh = 0.0000
    var previousperiodclose = 0.0000
    var mycountopen = 0
    var mycountclose = 0
    var giornosett = 0
    var sesshigh = 0.0000
    var sesslow = 0.0000

    var IntradayBF_V2 = 0.0000


    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if SessionStartTime > SessionEndTime
            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0)
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0


        if SessionStartTime < SessionEndTime
            giornosett := dayofweek(time, timezone)

            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0) or (giornosett[1] != giornosett and MyBodyFactorStartTime == SessionStartTime)
                mycountopen := 0
            if f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and giornosett[1] != giornosett and MyBodyFactorStartTime != SessionStartTime
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0
            if giornosett[1] != giornosett and MyBodyFactorEndTime == SessionEndTime
                mycountclose := 1

    if na(mycountopen)
        mycountopen := 0

    sesshigh := ta.highest(high, mycountopen+1)[mycountclose]
    sesslow := ta.lowest(low, mycountopen+1)[mycountclose]

    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if mycountclose < mycountopen
            periodclose := close[mycountclose]
            periodopen := open[mycountopen]
            periodhigh := sesshigh
            periodlow := sesslow

            previousperiodclose := periodclose
            previousperiodopen := periodopen
            previousperiodhigh := periodhigh
            previousperiodlow := periodlow

        else
            periodclose := previousperiodclose
            periodopen := previousperiodopen
            periodhigh := previousperiodhigh
            periodlow := previousperiodlow


        if periodclose != periodopen and periodhigh != periodlow
            IntradayBF_V2 := (periodclose - periodopen) / (periodhigh - periodlow)


    if MyBodyFactorStartTime == MyBodyFactorEndTime 
        IntradayBF_V2 := 0

    IntradayBF_V2



export IntradayBF_High(int SessionStartTime, int SessionEndTime, int MyBodyFactorStartTime, int MyBodyFactorEndTime, string timezone) =>

    if SessionStartTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if SessionEndTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if timezone == ""
        runtime.error("Set a correct timezone")

    var periodlow = 0.0000
    var periodopen = 0.0000
    var periodhigh = 0.0000
    var periodclose = 0.0000
    var previousperiodlow = 0.0000
    var previousperiodopen = 0.0000
    var previousperiodhigh = 0.0000
    var previousperiodclose = 0.0000
    var mycountopen = 0
    var mycountclose = 0
    var giornosett = 0
    var sesshigh = 0.0000
    var sesslow = 0.0000

    var IntradayBF_V2 = 0.0000


    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if SessionStartTime > SessionEndTime
            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0)
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0


        if SessionStartTime < SessionEndTime
            giornosett := dayofweek(time, timezone)

            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0) or (giornosett[1] != giornosett and MyBodyFactorStartTime == SessionStartTime)
                mycountopen := 0
            if f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and giornosett[1] != giornosett and MyBodyFactorStartTime != SessionStartTime
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0
            if giornosett[1] != giornosett and MyBodyFactorEndTime == SessionEndTime
                mycountclose := 1

    if na(mycountopen)
        mycountopen := 0

    sesshigh := ta.highest(high, mycountopen+1)[mycountclose]
    sesslow := ta.lowest(low, mycountopen+1)[mycountclose]

    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if mycountclose < mycountopen
            periodclose := close[mycountclose]
            periodopen := open[mycountopen]
            periodhigh := sesshigh
            periodlow := sesslow

            previousperiodclose := periodclose
            previousperiodopen := periodopen
            previousperiodhigh := periodhigh
            previousperiodlow := periodlow

        else
            periodclose := previousperiodclose
            periodopen := previousperiodopen
            periodhigh := previousperiodhigh
            periodlow := previousperiodlow


        if periodclose != periodopen and periodhigh != periodlow
            periodhigh



export IntradayBF_Low(int SessionStartTime, int SessionEndTime, int MyBodyFactorStartTime, int MyBodyFactorEndTime, string timezone) =>

    if SessionStartTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if SessionEndTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if timezone == ""
        runtime.error("Set a correct timezone")

    var periodlow = 0.0000
    var periodopen = 0.0000
    var periodhigh = 0.0000
    var periodclose = 0.0000
    var previousperiodlow = 0.0000
    var previousperiodopen = 0.0000
    var previousperiodhigh = 0.0000
    var previousperiodclose = 0.0000
    var mycountopen = 0
    var mycountclose = 0
    var giornosett = 0
    var sesshigh = 0.0000
    var sesslow = 0.0000

    var IntradayBF_V2 = 0.0000


    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if SessionStartTime > SessionEndTime
            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0)
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0


        if SessionStartTime < SessionEndTime
            giornosett := dayofweek(time, timezone)

            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0) or (giornosett[1] != giornosett and MyBodyFactorStartTime == SessionStartTime)
                mycountopen := 0
            if f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and giornosett[1] != giornosett and MyBodyFactorStartTime != SessionStartTime
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0
            if giornosett[1] != giornosett and MyBodyFactorEndTime == SessionEndTime
                mycountclose := 1

    if na(mycountopen)
        mycountopen := 0

    sesshigh := ta.highest(high, mycountopen+1)[mycountclose]
    sesslow := ta.lowest(low, mycountopen+1)[mycountclose]

    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if mycountclose < mycountopen
            periodclose := close[mycountclose]
            periodopen := open[mycountopen]
            periodhigh := sesshigh
            periodlow := sesslow

            previousperiodclose := periodclose
            previousperiodopen := periodopen
            previousperiodhigh := periodhigh
            previousperiodlow := periodlow

        else
            periodclose := previousperiodclose
            periodopen := previousperiodopen
            periodhigh := previousperiodhigh
            periodlow := previousperiodlow


        if periodclose != periodopen and periodhigh != periodlow
            periodlow



export IntradayBF_Open(int SessionStartTime, int SessionEndTime, int MyBodyFactorStartTime, int MyBodyFactorEndTime, string timezone) =>

    if SessionStartTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if SessionEndTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if timezone == ""
        runtime.error("Set a correct timezone")

    var periodlow = 0.0000
    var periodopen = 0.0000
    var periodhigh = 0.0000
    var periodclose = 0.0000
    var previousperiodlow = 0.0000
    var previousperiodopen = 0.0000
    var previousperiodhigh = 0.0000
    var previousperiodclose = 0.0000
    var mycountopen = 0
    var mycountclose = 0
    var giornosett = 0
    var sesshigh = 0.0000
    var sesslow = 0.0000

    var IntradayBF_V2 = 0.0000


    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if SessionStartTime > SessionEndTime
            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0)
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0


        if SessionStartTime < SessionEndTime
            giornosett := dayofweek(time, timezone)

            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0) or (giornosett[1] != giornosett and MyBodyFactorStartTime == SessionStartTime)
                mycountopen := 0
            if f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and giornosett[1] != giornosett and MyBodyFactorStartTime != SessionStartTime
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0
            if giornosett[1] != giornosett and MyBodyFactorEndTime == SessionEndTime
                mycountclose := 1

    if na(mycountopen)
        mycountopen := 0

    sesshigh := ta.highest(high, mycountopen+1)[mycountclose]
    sesslow := ta.lowest(low, mycountopen+1)[mycountclose]

    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if mycountclose < mycountopen
            periodclose := close[mycountclose]
            periodopen := open[mycountopen]
            periodhigh := sesshigh
            periodlow := sesslow

            previousperiodclose := periodclose
            previousperiodopen := periodopen
            previousperiodhigh := periodhigh
            previousperiodlow := periodlow

        else
            periodclose := previousperiodclose
            periodopen := previousperiodopen
            periodhigh := previousperiodhigh
            periodlow := previousperiodlow


        if periodclose != periodopen and periodhigh != periodlow
            periodopen



export IntradayBF_Close(int SessionStartTime, int SessionEndTime, int MyBodyFactorStartTime, int MyBodyFactorEndTime, string timezone) =>

    if SessionStartTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if SessionEndTime < 0
        runtime.error("SessionStartTime must be greater than 0")

    if timezone == ""
        runtime.error("Set a correct timezone")

    var periodlow = 0.0000
    var periodopen = 0.0000
    var periodhigh = 0.0000
    var periodclose = 0.0000
    var previousperiodlow = 0.0000
    var previousperiodopen = 0.0000
    var previousperiodhigh = 0.0000
    var previousperiodclose = 0.0000
    var mycountopen = 0
    var mycountclose = 0
    var giornosett = 0
    var sesshigh = 0.0000
    var sesslow = 0.0000

    var IntradayBF_V2 = 0.0000


    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if SessionStartTime > SessionEndTime
            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0)
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0


        if SessionStartTime < SessionEndTime
            giornosett := dayofweek(time, timezone)

            mycountopen := mycountopen[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorStartTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorStartTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and MyBodyFactorStartTime == 0) or (giornosett[1] != giornosett and MyBodyFactorStartTime == SessionStartTime)
                mycountopen := 0
            if f_closetimetoHHmm(0, timezone) == MyBodyFactorStartTime and giornosett[1] != giornosett and MyBodyFactorStartTime != SessionStartTime
                mycountopen := 0

            mycountclose := mycountclose[1] + 1
            if (f_closetimetoHHmm(1, timezone) < MyBodyFactorEndTime and f_closetimetoHHmm(0, timezone) >= MyBodyFactorEndTime) or (f_closetimetoHHmm(0, timezone) == MyBodyFactorEndTime and MyBodyFactorEndTime == 0)
                mycountclose := 0
            if giornosett[1] != giornosett and MyBodyFactorEndTime == SessionEndTime
                mycountclose := 1

    if na(mycountopen)
        mycountopen := 0

    sesshigh := ta.highest(high, mycountopen+1)[mycountclose]
    sesslow := ta.lowest(low, mycountopen+1)[mycountclose]

    if MyBodyFactorStartTime != MyBodyFactorEndTime
        if mycountclose < mycountopen
            periodclose := close[mycountclose]
            periodopen := open[mycountopen]
            periodhigh := sesshigh
            periodlow := sesslow

            previousperiodclose := periodclose
            previousperiodopen := periodopen
            previousperiodhigh := periodhigh
            previousperiodlow := periodlow

        else
            periodclose := previousperiodclose
            periodopen := previousperiodopen
            periodhigh := previousperiodhigh
            periodlow := previousperiodlow


        if periodclose != periodopen and periodhigh != periodlow
            periodclose



export VisualTrades(float limitPrice, float stopPrice, string Levels_calc, int Text_size) =>
    // helper 
    float _prevEntry = strategy.opentrades > 0 ? strategy.opentrades.entry_price(strategy.opentrades - 1) : na
    bool  wasjustopened = ((_prevEntry != _prevEntry[1]) and not na(_prevEntry)) or (f_mp() != 0 and f_mp() != f_mp()[1])
    bool  inPos = f_mp() != 0

    int   nClosed    = strategy.closedtrades
    int   nClosedPrv = nz(strategy.closedtrades[1], 0)
    bool  tradeClosedNow = nClosed > nClosedPrv

    bool hasTP = not na(limitPrice) and limitPrice != 0
    bool hasSL = not na(stopPrice) and stopPrice != 0
    bool hadSLprev = not na(stopPrice[1]) and stopPrice[1] != 0
    bool startSLnow = hasSL and not hadSLprev

    // storage
    var int[]   entryBars     = array.new_int()
    var float[] entryPrices   = array.new_float()
    var int[]   posDirs       = array.new_int()

    var line[]  EP_lines      = array.new_line()
    var line[]  Close_lines   = array.new_line()
    var line[]  TP_lines      = array.new_line()
    var line[]  SL_lines      = array.new_line()
    var line[]  TS_lines      = array.new_line()

    var label[] SL_labels     = array.new_label()
    var label[] TP_labels     = array.new_label()

    var linefill[] Fill_TP_EP = array.new_linefill()
    var linefill[] Fill_SL_EP = array.new_linefill()

    var color EP_SL_color = color.new(color.blue, 80)

    int lastIdx = array.size(entryBars) - 1

    // apertura NUOVO trade
    if wasjustopened
        int   eBar   = bar_index
        float ePrice = strategy.position_avg_price
        int   dir    = strategy.position_size > 0 ? 1 : -1

        array.push(entryBars,   eBar)
        array.push(entryPrices, ePrice)
        array.push(posDirs,     dir)

        // EP e CLOSE
        line ep = line.new(eBar, ePrice, eBar + 5, ePrice, color = color.blue, width = 1)
        line cl = line.new(bar_index, close, bar_index + 5, close, color = color.new(color.white, 100))
        array.push(EP_lines,    ep)
        array.push(Close_lines, cl)

        // TP 
        if hasTP
            line tp = line.new(eBar, limitPrice, eBar + 5, limitPrice, color = color.green, width = 2)
            array.push(TP_lines, tp)
            label ltp = label.new(eBar, limitPrice, "Take Profit: " + str.tostring(limitPrice, format.mintick),
                                   color = color.new(#0c700f, 10), style = label.style_label_center, textcolor = color.white, size = Text_size)
            if Levels_calc == "Distance from Entry Price"
                label.set_text(ltp, "Take Profit: " + str.tostring(math.abs(ePrice - limitPrice), format.mintick))
            array.push(TP_labels, ltp)
            linefill f = linefill.new(tp, ep, color.new(color.green, 80))
            array.push(Fill_TP_EP, f)
        else
            array.push(TP_lines, na)
            array.push(TP_labels, na)
            array.push(Fill_TP_EP, na)

        // SL/TS 
        if hasSL
            line sl = line.new(eBar, stopPrice, eBar + 5, stopPrice, color = color.red, width = 1)
            line ts = line.new(eBar, stopPrice, eBar + 5, stopPrice, color = color.red, width = 2)
            array.push(SL_lines, sl)
            array.push(TS_lines, ts)
            label lsl = label.new(eBar, stopPrice, "Stop Loss: " + str.tostring(stopPrice, format.mintick),
                                   color = color.new(#9f1c1c, 10), style = label.style_label_center, textcolor = color.white, size = Text_size)
            if Levels_calc == "Distance from Entry Price"
                label.set_text(lsl, "Stop Loss: " + str.tostring(math.abs(ePrice - stopPrice), format.mintick))
            array.push(SL_labels, lsl)
            linefill fsl = linefill.new(sl, ep, color.new(color.red, 80))
            array.push(Fill_SL_EP, fsl)
        else
            array.push(SL_lines, na)
            array.push(TS_lines, na)
            array.push(SL_labels, na)
            array.push(Fill_SL_EP, na)

        lastIdx := array.size(entryBars) - 1

    // aggiornamenti
    if inPos and lastIdx >= 0
        // puntatori rapidi
        line  ep  = array.get(EP_lines,    lastIdx)
        line  cl  = array.get(Close_lines, lastIdx)
        line  tp  = array.get(TP_lines,    lastIdx)
        line  sl  = array.get(SL_lines,    lastIdx)
        line  ts  = array.get(TS_lines,    lastIdx)
        label lsl = array.get(SL_labels,   lastIdx)
        label ltp = array.get(TP_labels,   lastIdx)
        int   eBar= array.get(entryBars,   lastIdx)
        float ePx = array.get(entryPrices, lastIdx)

        line.set_y1(cl, close)
        line.set_y2(cl, close)

        // TP ricompare
        if hasTP and na(tp)
            tp := line.new(eBar, limitPrice, eBar + 5, limitPrice, color = color.green, width = 2)
            array.set(TP_lines, lastIdx, tp)
            ltp := label.new(eBar, limitPrice, "Take Profit: " + str.tostring(limitPrice, format.mintick),
                             color = color.new(#0c700f, 10), style = label.style_label_center, textcolor = color.white, size = Text_size)
            if Levels_calc == "Distance from Entry Price"
                label.set_text(ltp, "Take Profit: " + str.tostring(math.abs(ePx - limitPrice), format.mintick))
            array.set(TP_labels, lastIdx, ltp)
            linefill f = linefill.new(tp, ep, color.new(color.green, 80))
            array.set(Fill_TP_EP, lastIdx, f)

        if hasTP and not na(tp)
            line.set_y1(tp, limitPrice)
            line.set_y2(tp, limitPrice)
            if not na(ltp)
                label.set_y(ltp, limitPrice)
                if Levels_calc == "Distance from Entry Price"
                    label.set_text(ltp, "Take Profit: " + str.tostring(math.abs(ePx - limitPrice), format.mintick))

        // SL/TS
        if startSLnow and na(ts)
            sl := line.new(eBar, stopPrice, bar_index + 5, stopPrice, color = color.red, width = 1)
            ts := line.new(eBar, stopPrice, bar_index + 5, stopPrice, color = color.red, width = 2)
            array.set(SL_lines, lastIdx, sl)
            array.set(TS_lines, lastIdx, ts)
            lsl := label.new(eBar, stopPrice, "Stop Loss: " + str.tostring(stopPrice, format.mintick),
                             color = color.new(#9f1c1c, 10), style = label.style_label_center, textcolor = color.white, size = Text_size)
            if Levels_calc == "Distance from Entry Price"
                label.set_text(lsl, "Stop Loss: " + str.tostring(math.abs(ePx - stopPrice), format.mintick))
            array.set(SL_labels, lastIdx, lsl)
            linefill fsl = linefill.new(sl, ep, color.new(color.red, 80))
            array.set(Fill_SL_EP, lastIdx, fsl)

        // se esiste, aggiorna livello trailing
        if hasSL and not na(ts) and ((strategy.position_size > 0 and stopPrice >= strategy.position_avg_price) or (strategy.position_size < 0 and stopPrice <= strategy.position_avg_price))
            line.set_y1(ts, stopPrice)
            line.set_y2(ts, stopPrice)
            label.set_text(lsl, "Trailed Stop: " + str.tostring(stopPrice, format.mintick))
            if not na(lsl)
                label.set_y(lsl, stopPrice)
                if Levels_calc == "Distance from Entry Price"
                    label.set_text(lsl, "Trailed Stop: " + str.tostring(math.abs(strategy.position_avg_price - stopPrice), format.mintick))

        if not hasSL and not na(ts)
            line.set_color(ts, color.new(color.white, 100))
            if not na(lsl)
                label.delete(lsl)
                array.set(SL_labels, lastIdx, na)

        if (not wasjustopened) and (bar_index - eBar >= 5)
            line.set_x2(ep, bar_index + 1)
            line.set_x2(cl, bar_index + 1)
            if not na(tp)
                line.set_x2(tp, bar_index + 1)
            if not na(sl)
                line.set_x2(sl, bar_index + 1)
            if not na(ts)
                line.set_x2(ts, bar_index + 1)

        // colore area SL se trailing >= EP
        if hasSL
            if (f_mp() > 0 and stopPrice >= strategy.position_avg_price) or (f_mp() < 0 and stopPrice <= strategy.position_avg_price)
                linefill fsl2 = array.get(Fill_SL_EP, lastIdx)
                if not na(fsl2)
                    linefill.set_color(fsl2, EP_SL_color)

        // fill verde/rosso
        if (f_mp() > 0 and close >= strategy.position_avg_price) or (f_mp() < 0 and close <= strategy.position_avg_price)
            linefill _fc = linefill.new(ep, cl, color.new(color.green, 70))
        else if (f_mp() > 0 and close < strategy.position_avg_price) or (f_mp() < 0 and close > strategy.position_avg_price)
            linefill _fc2 = linefill.new(ep, cl, color.new(color.red, 70))

    // chiusura trade: congela TUTTI i trade chiusi in questa barra
    if tradeClosedNow and array.size(entryBars) > 0
        for t = nClosedPrv to nClosed - 1
            int exitBar = strategy.closedtrades.exit_bar_index(t)
            if exitBar != bar_index
                continue

            int   eBarClosed = strategy.closedtrades.entry_bar_index(t)
            float lastExit   = strategy.closedtrades.exit_price(t)

            int idxFreeze = na
            for k = array.size(entryBars) - 1 to 0
                if array.get(entryBars, k) == eBarClosed
                    idxFreeze := k
                    break
            if na(idxFreeze)
                continue

            line epc = array.get(EP_lines,    idxFreeze)
            line clc = array.get(Close_lines, idxFreeze)
            line tpc = array.get(TP_lines,    idxFreeze)
            line slc = array.get(SL_lines,    idxFreeze)
            line tsc = array.get(TS_lines,    idxFreeze)

            line.set_y1(clc, lastExit)
            line.set_y2(clc, lastExit)
            line.set_x2(epc, bar_index)
            line.set_x2(clc, bar_index)
            if not na(tpc)
                line.set_x2(tpc, bar_index)
            if not na(slc)
                line.set_x2(slc, bar_index)
            if not na(tsc)
                line.set_x2(tsc, bar_index)

            // fill finale 
            float ePxClosed = array.get(entryPrices, idxFreeze)
            int   dirClosed = array.get(posDirs,     idxFreeze)
            bool  profit    = dirClosed == 1 ? (lastExit >= ePxClosed) : (lastExit <= ePxClosed)
            linefill.new(epc, clc, profit ? color.new(color.green, 70) : color.new(color.red, 70))

    // ritorni
    line  ret_TP_line    = lastIdx >= 0 ? array.get(TP_lines,    lastIdx) : na
    line  ret_SL_line    = lastIdx >= 0 ? array.get(SL_lines,    lastIdx) : na
    line  ret_EP_line    = lastIdx >= 0 ? array.get(EP_lines,    lastIdx) : na
    line  ret_TS_line    = lastIdx >= 0 ? array.get(TS_lines,    lastIdx) : na
    line  ret_close_line = lastIdx >= 0 ? array.get(Close_lines, lastIdx) : na
    linefill ret_fill_TP = lastIdx >= 0 ? array.get(Fill_TP_EP,  lastIdx) : na
    linefill ret_fill_SL = lastIdx >= 0 ? array.get(Fill_SL_EP,  lastIdx) : na
    linefill ret_fill_cl = na
    label    ret_SL_text = lastIdx >= 0 ? array.get(SL_labels,   lastIdx) : na
    label    ret_TP_text = lastIdx >= 0 ? array.get(TP_labels,   lastIdx) : na

    ret_TP_line
    ret_SL_line
    ret_EP_line
    ret_TS_line
    ret_close_line
    ret_fill_TP
    ret_fill_SL
    ret_fill_cl
    ret_SL_text
    ret_TP_text






fValidType(string t) => not na(t) and str.length(t) > 0
fValidLvl(float v) => not na(v) and v != 0 and math.abs(v - close) <= close*0.20
labelSizeFrom(int sz) => sz<=1?size.tiny:sz==2?size.small:sz==3?size.normal:sz==4?size.large:size.huge

export DrawEntryOrdersHistorySeries(float myle, float myse, string Long_Order_Type, string Short_Order_Type, color Order_line_color_long, color Order_line_color_short, color Order_text_color_long, color Order_text_color_short, int Order_text_size, int PlotLength, int NContracts, string Long_Order_entry_exit, string Short_Order_entry_exit, bool Toggle_order_lines) =>

    var label longMainLbl   = na
    var label shortMainLbl  = na
    var label longPriceLbl  = na
    var label shortPriceLbl = na
    var int   longRunLen    = 0
    var int   shortRunLen   = 0
    var int   lastLongBar   = na
    var int   lastShortBar  = na
    var float lastLongY     = na
    var float lastShortY    = na
    var string lastLongText  = ""
    var string lastShortText = ""

    var int   longStartBar   = na
    var float longStartY     = na
    var float longStartRange = na
    var int   shortStartBar  = na
    var float shortStartY    = na
    var float shortStartRange= na

    winStart = math.max(0, last_bar_index - PlotLength)
    inWinNow = bar_index >= winStart

    if not Toggle_order_lines
        if not na(longMainLbl) 
            label.delete(longMainLbl), longMainLbl := na
        if not na(shortMainLbl)
            label.delete(shortMainLbl), shortMainLbl := na
        if not na(longPriceLbl)
            label.delete(longPriceLbl), longPriceLbl := na
        if not na(shortPriceLbl)
            label.delete(shortPriceLbl), shortPriceLbl := na
        [na, na]

    prevPos = barstate.isfirst ? 0 : strategy.position_size[1]
    longClosedNow  = (prevPos > 0 and strategy.position_size == 0)
    shortClosedNow = (prevPos < 0 and strategy.position_size == 0)

    longOkRaw  = fValidType(Long_Order_Type)  and fValidLvl(myle)  and strategy.position_size <= 0
    shortOkRaw = fValidType(Short_Order_Type) and fValidLvl(myse)  and strategy.position_size >= 0
    longOk  = longOkRaw  and (not longClosedNow  or barstate.isconfirmed)
    shortOk = shortOkRaw and (not shortClosedNow or barstate.isconfirmed)

    prevLongOk  = barstate.isfirst ? false : longOk[1]
    prevShortOk = barstate.isfirst ? false : shortOk[1]
    longStart = longOk  and not prevLongOk
    shortStart= shortOk and not prevShortOk
    longStop  = not longOk  and prevLongOk
    shortStop = not shortOk and prevShortOk

    // ---------- SERIE LONG ----------
    var float longSeries = na
    longDrawnNow = false
    if longOk and inWinNow
        longSeries := myle
        longRunLen := longStart ? 1 : longRunLen + 1
        lastLongBar := bar_index
        lastLongY   := myle
        longDrawnNow := true

        if longStart
            longStartBar   := bar_index
            longStartY     := myle
            longStartRange := high - low
    else
        longSeries := na
        if longStop
            longRunLen := 0

    // ---------- SERIE SHORT ----------
    var float shortSeries = na
    shortDrawnNow = false
    if shortOk and inWinNow
        shortSeries := myse
        shortRunLen := shortStart ? 1 : shortRunLen + 1
        lastShortBar := bar_index
        lastShortY   := myse
        shortDrawnNow := true
        if shortStart
            shortStartBar   := bar_index
            shortStartY     := myse
            shortStartRange := high - low
    else
        shortSeries := na
        if shortStop
            shortRunLen := 0

    // LABEL ALL’ULTIMA BARRA 
    ls = labelSizeFrom(Order_text_size)

    // Qty: raddoppia solo se lato opposto
    longIsEntry  = str.lower(Long_Order_entry_exit)  == "entry"
    shortIsEntry = str.lower(Short_Order_entry_exit) == "entry"
    longQtyNow  = (strategy.position_size < 0 and longIsEntry)  ? (NContracts * 2) : NContracts
    shortQtyNow = (strategy.position_size > 0 and shortIsEntry) ? (NContracts * 2) : NContracts

    _longType  = str.lower(Long_Order_Type)
    _shortType = str.lower(Short_Order_Type)

    // ------ LONG
    if longDrawnNow
        if longStart and not na(longStartBar) and longStartBar >= winStart
            longTextY = _longType == "stop" ? (longStartY + 2.0 * longStartRange) : (longStartY - 2.0 * longStartRange)
            lastLongText := "BUY " + _longType + "\n" + str.tostring(longQtyNow) + " contracts"

            if na(longMainLbl)
                longMainLbl := label.new(longStartBar, longTextY, lastLongText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textcolor=Order_text_color_long, color=color.new(color.black, 0), size=ls)
            else
                label.set_x(longMainLbl, longStartBar), label.set_y(longMainLbl, longTextY)
                label.set_text(longMainLbl, lastLongText)
                label.set_textcolor(longMainLbl, Order_text_color_long)
                label.set_style(longMainLbl, label.style_label_center), label.set_size(longMainLbl, ls)
                label.set_color(longMainLbl, color.new(color.black, 0))

        // etichetta PREZZO
        string lpTxt = str.tostring(lastLongY, format.mintick)
        if na(longPriceLbl)
            longPriceLbl := label.new(lastLongBar, lastLongY, lpTxt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, textcolor=color.white, color=color.new(Order_line_color_long, 0), size=ls)
        else
            label.set_x(longPriceLbl, lastLongBar), label.set_y(longPriceLbl, lastLongY)
            label.set_text(longPriceLbl, lpTxt)
            label.set_textcolor(longPriceLbl, color.white)
            label.set_color(longPriceLbl, color.new(Order_line_color_long, 0))
            label.set_style(longPriceLbl, label.style_label_right), label.set_size(longPriceLbl, ls)
    else
        if not na(longStartBar) and longStartBar < winStart
            if not na(longMainLbl)
                label.delete(longMainLbl), longMainLbl := na
        if not na(lastLongBar) and lastLongBar < winStart
            if not na(longPriceLbl)
                label.delete(longPriceLbl), longPriceLbl := na

    // ------ SHORT
    if shortDrawnNow
        if shortStart and not na(shortStartBar) and shortStartBar >= winStart
            shortTextY = _shortType == "stop" ? (shortStartY - 2.0 * shortStartRange) : (shortStartY + 2.0 * shortStartRange)
            lastShortText := "SELL " + _shortType + "\n" + str.tostring(shortQtyNow) + " contracts"

            if na(shortMainLbl)
                shortMainLbl := label.new(shortStartBar, shortTextY, lastShortText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textcolor=Order_text_color_short, color=color.new(color.black, 0), size=ls)
            else
                label.set_x(shortMainLbl, shortStartBar), label.set_y(shortMainLbl, shortTextY)
                label.set_text(shortMainLbl, lastShortText)
                label.set_textcolor(shortMainLbl, Order_text_color_short)
                label.set_style(shortMainLbl, label.style_label_center), label.set_size(shortMainLbl, ls)
                label.set_color(shortMainLbl, color.new(color.black, 0))

        // etichetta PREZZO
        string spTxt = str.tostring(lastShortY, format.mintick)
        if na(shortPriceLbl)
            shortPriceLbl := label.new(lastShortBar, lastShortY, spTxt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, textcolor=color.white, color=color.new(Order_line_color_short, 0), size=ls)
        else
            label.set_x(shortPriceLbl, lastShortBar), label.set_y(shortPriceLbl, lastShortY)
            label.set_text(shortPriceLbl, spTxt)
            label.set_textcolor(shortPriceLbl, color.white)
            label.set_color(shortPriceLbl, color.new(Order_line_color_short, 0))
            label.set_style(shortPriceLbl, label.style_label_right), label.set_size(shortPriceLbl, ls)
    else
        if not na(shortStartBar) and shortStartBar < winStart
            if not na(shortMainLbl)
                label.delete(shortMainLbl), shortMainLbl := na
        if not na(lastShortBar) and lastShortBar < winStart
            if not na(shortPriceLbl)
                label.delete(shortPriceLbl), shortPriceLbl := na

    // RITORNI 
    [longSeries, shortSeries]



export AlertMessages(bool EnableAlerts, string LongTradeOpened_alert, string ShortTradeOpened_alert, string LongTradeClosed_alert, string ShortTradeClosed_alert) =>
    
    preventry = strategy.opentrades.entry_price(strategy.opentrades - 1)
    wasjustopened = (preventry != preventry[1] and preventry != 0) or (f_mp() != 0 and f_mp() != f_mp()[1])

    if EnableAlerts
        if wasjustopened and strategy.position_size > 0
            alert(LongTradeOpened_alert)
        
        if wasjustopened and strategy.position_size < 0
            alert(ShortTradeOpened_alert)

        if strategy.position_size == 0 and strategy.position_size[1] > 0
            alert(LongTradeClosed_alert)
        
        if strategy.position_size == 0 and strategy.position_size[1] < 0
            alert(ShortTradeClosed_alert)



///////////////////////////// Z - FUNC - END /////////////////////////////
///////////////////////////// Z - FUNC - END /////////////////////////////
///////////////////////////// Z - FUNC - END /////////////////////////////
///////////////////////////// Z - FUNC - END /////////////////////////////
///////////////////////////// Z - FUNC - END /////////////////////////////
///////////////////////////// Z - FUNC - END /////////////////////////////





///////////////////////////// Z - ROLL - START /////////////////////////////
///////////////////////////// Z - ROLL - START /////////////////////////////
///////////////////////////// Z - ROLL - START /////////////////////////////
///////////////////////////// Z - ROLL - START /////////////////////////////
///////////////////////////// Z - ROLL - START /////////////////////////////
///////////////////////////// Z - ROLL - START /////////////////////////////

data() =>
    var string[] inst   = array.from("LE1!", "VX1!", "CL1!", "MCL1!", "QM1!", "HE1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "GC1!", "MGC1!", "BTC1!", "MBT1!", "ETH1!", "CC1!", "KC1!", "CT1!", "VX1!", "SB1!", "CL1!", "MCL1!", "QM1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "OJ1!", "ZL1!", "MZL1!", "ZC1!", "MZC1!", "HG1!", "MHG1!", "KE1!", "ZR1!", "ZS1!", "MZS1!", "SI1!", "ZM1!", "MZM1!", "ZW1!", "MZW1!", "ZN1!", "ZB1!", "BTC1!", "MBT1!", "ETH1!", "GF1!", "FGBL1!", "LE1!", "6A1!", "6B1!", "6C1!", "E71!", "6E1!", "J71!", "6J1!", "6S1!", "VX1!", "EMD1!", "ES1!", "NQ1!", "YM1!", "RTY1!", "MES1!", "MNQ1!", "M2K1!", "MYM1!", "HE1!", "CL1!", "MCL1!", "QM1!", "FDAX1!", "FDXM1!", "FESX1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "BTC1!", "MBT1!", "ETH1!", "GC1!", "MGC1!", "PL1!", "GF1!", "CC1!", "VX1!", "KC1!", "CT1!", "SB1!", "CL1!", "MCL1!", "QM1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "BTC1!", "MBT1!", "ETH1!", "OJ1!", "GF1!", "ZL1!", "MZL1!", "ZC1!", "MZC1!", "HG1!", "MHG1!", "KE1!", "ZR1!", "ZS1!", "MZS1!", "SI1!", "ZM1!", "MZM1!", "ZW1!", "MZW1!", "LE1!", "VX1!", "CL1!", "MCL1!", "QM1!", "HE1!", "NG1!", "QN1!", "HO1!", "RB1!", "MRB1!", "GC1!", "MGC1!", "ZN1!", "ZB1!", "BTC1!", "MBT1!", "ETH1!", "FGBL1!", "CC1!", "KC1!", "CT1!", "6A1!", "6B1!", "6C1!", "E71!", "6E1!", "J71!", "6J1!", "6S1!", "VX1!", "EMD1!", "ES1!", "NQ1!", "YM1!", "RTY1!", "MES1!", "MNQ1!", "M2K1!", "MYM1!", "SB1!", "CL1!", "MCL1!", "QM1!", "FDAX1!", "FDXM1!", "FESX1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "OJ1!", "BTC1!", "MBT1!", "ETH1!", "ZL1!", "MZL1!", "ZC1!", "MZC1!", "HG1!", "MHG1!", "KE1!", "PL1!", "ZR1!", "ZS1!", "MZS1!", "SI1!", "ZM1!", "MZM1!", "ZW1!", "MZW1!", "LE1!", "VX1!", "HE1!", "CL1!", "MCL1!", "QM1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "GF1!", "GC1!", "MGC1!", "BTC1!", "MBT1!", "ETH1!", "CC1!", "KC1!", "VX1!", "CL1!", "MCL1!", "QM1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "OJ1!", "GF1!", "ZC1!", "MZC1!", "HG1!", "MHG1!", "KE1!", "ZR1!", "SI1!", "ZW1!", "MZW1!", "ZN1!", "ZB1!", "BTC1!", "MBT1!", "ETH1!", "FGBL1!", "6A1!", "6B1!", "6C1!", "E71!", "6E1!", "J71!", "6J1!", "6S1!", "VX1!", "LE1!", "EMD1!", "ES1!", "NQ1!", "YM1!", "RTY1!", "MES1!", "MNQ1!", "M2K1!", "MYM1!", "FDAX1!", "FDXM1!", "FESX1!", "SB1!", "HE1!", "CL1!", "MCL1!", "QM1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "BTC1!", "MBT1!", "ETH1!", "PL1!", "GF1!", "VX1!", "CL1!", "MCL1!", "QM1!", "HO1!", "RB1!", "MRB1!", "NG1!", "QN1!", "OJ1!", "GF1!", "ZR1!", "ZS1!", "MZS1!", "BTC1!", "MBT1!", "ETH1!", "CC1!", "KC1!", "CT1!", "LE1!", "VX1!", "HE1!", "CL1!", "MCL1!", "QM1!", "NG1!", "QN1!", "HO1!", "RB1!", "MRB1!", "ZN1!", "ZB1!", "ZL1!", "MZL1!", "ZC1!", "MZC1!", "GC1!", "MGC1!", "HG1!", "MHG1!", "KE1!", "SI1!", "ZM1!", "MZM1!", "ZW1!", "MZW1!", "BTC1!", "MBT1!", "ETH1!", "FGBL1!", "6A1!", "6B1!", "6C1!", "E71!", "6E1!", "J71!", "6J1!", "6S1!", "VX1!", "EMD1!", "ES1!", "NQ1!", "YM1!", "MES1!", "MNQ1!", "M2K1!", "MYM1!", "RTY1!", "CL1!", "MCL1!", "QM1!", "FDAX1!", "FDXM1!", "FESX1!", "NG1!", "QN1!", "HO1!", "RB1!", "MRB1!", "BTC1!", "ETH1!", "MBT1!", "OJ1!", "GF1!", "ZL1!", "MZL1!", "PL1!", "ZR1!", "ZM1!", "MZM1!", "ZS1!", "MZS1!")
    var int[]    rollTs = array.from(timestamp("America/Chicago", 2026, 1, 9, 0, 0), timestamp("America/Chicago", 2026, 1, 14, 0, 0), timestamp("America/New_York", 2026, 1, 14, 0, 0), timestamp("America/New_York", 2026, 1, 14, 0, 0), timestamp("America/New_York", 2026, 1, 14, 0, 0), timestamp("America/Chicago", 2026, 1, 16, 0, 0), timestamp("America/New_York", 2026, 1, 21, 0, 0), timestamp("America/New_York", 2026, 1, 21, 0, 0), timestamp("America/New_York", 2026, 1, 21, 0, 0), timestamp("America/New_York", 2026, 1, 22, 0, 0), timestamp("America/New_York", 2026, 1, 22, 0, 0), timestamp("America/New_York", 2026, 1, 27, 0, 0), timestamp("America/New_York", 2026, 1, 27, 0, 0), timestamp("America/Chicago", 2026, 1, 28, 0, 0), timestamp("America/Chicago", 2026, 1, 28, 0, 0), timestamp("America/Chicago", 2026, 1, 28, 0, 0), timestamp("America/New_York", 2026, 2, 6, 0, 0), timestamp("America/New_York", 2026, 2, 10, 0, 0), timestamp("America/New_York", 2026, 2, 10, 0, 0), timestamp("America/Chicago", 2026, 2, 11, 0, 0), timestamp("America/New_York", 2026, 2, 12, 0, 0), timestamp("America/New_York", 2026, 2, 17, 0, 0), timestamp("America/New_York", 2026, 2, 17, 0, 0), timestamp("America/New_York", 2026, 2, 17, 0, 0), timestamp("America/New_York", 2026, 2, 18, 0, 0), timestamp("America/New_York", 2026, 2, 18, 0, 0), timestamp("America/New_York", 2026, 2, 18, 0, 0), timestamp("America/New_York", 2026, 2, 19, 0, 0), timestamp("America/New_York", 2026, 2, 19, 0, 0), timestamp("America/New_York", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/New_York", 2026, 2, 24, 0, 0), timestamp("America/New_York", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/New_York", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 24, 0, 0), timestamp("America/Chicago", 2026, 2, 25, 0, 0), timestamp("America/Chicago", 2026, 2, 25, 0, 0), timestamp("America/Chicago", 2026, 2, 25, 0, 0), timestamp("America/Chicago", 2026, 2, 26, 0, 0), timestamp("Europe/Berlin", 2026, 3, 3, 0, 0), timestamp("America/Chicago", 2026, 3, 10, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 11, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 13, 0, 0), timestamp("America/Chicago", 2026, 3, 16, 0, 0), timestamp("America/New_York", 2026, 3, 17, 0, 0), timestamp("America/New_York", 2026, 3, 17, 0, 0), timestamp("America/New_York", 2026, 3, 17, 0, 0), timestamp("Europe/Berlin", 2026, 3, 17, 0, 0), timestamp("Europe/Berlin", 2026, 3, 17, 0, 0), timestamp("Europe/Berlin", 2026, 3, 17, 0, 0), timestamp("America/New_York", 2026, 3, 20, 0, 0), timestamp("America/New_York", 2026, 3, 20, 0, 0), timestamp("America/New_York", 2026, 3, 20, 0, 0), timestamp("America/New_York", 2026, 3, 23, 0, 0), timestamp("America/New_York", 2026, 3, 23, 0, 0), timestamp("America/Chicago", 2026, 3, 25, 0, 0), timestamp("America/Chicago", 2026, 3, 25, 0, 0), timestamp("America/Chicago", 2026, 3, 25, 0, 0), timestamp("America/New_York", 2026, 3, 26, 0, 0), timestamp("America/New_York", 2026, 3, 26, 0, 0), timestamp("America/New_York", 2026, 3, 26, 0, 0), timestamp("America/Chicago", 2026, 3, 26, 0, 0), timestamp("America/New_York", 2026, 4, 8, 0, 0), timestamp("America/Chicago", 2026, 4, 8, 0, 0), timestamp("America/New_York", 2026, 4, 10, 0, 0), timestamp("America/New_York", 2026, 4, 10, 0, 0), timestamp("America/New_York", 2026, 4, 16, 0, 0), timestamp("America/New_York", 2026, 4, 16, 0, 0), timestamp("America/New_York", 2026, 4, 16, 0, 0), timestamp("America/New_York", 2026, 4, 16, 0, 0), timestamp("America/New_York", 2026, 4, 21, 0, 0), timestamp("America/New_York", 2026, 4, 21, 0, 0), timestamp("America/New_York", 2026, 4, 21, 0, 0), timestamp("America/New_York", 2026, 4, 22, 0, 0), timestamp("America/New_York", 2026, 4, 22, 0, 0), timestamp("America/Chicago", 2026, 4, 22, 0, 0), timestamp("America/Chicago", 2026, 4, 22, 0, 0), timestamp("America/Chicago", 2026, 4, 22, 0, 0), timestamp("America/New_York", 2026, 4, 24, 0, 0), timestamp("America/Chicago", 2026, 4, 24, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/New_York", 2026, 4, 27, 0, 0), timestamp("America/New_York", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/New_York", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 4, 27, 0, 0), timestamp("America/Chicago", 2026, 5, 8, 0, 0), timestamp("America/Chicago", 2026, 5, 13, 0, 0), timestamp("America/New_York", 2026, 5, 14, 0, 0), timestamp("America/New_York", 2026, 5, 14, 0, 0), timestamp("America/New_York", 2026, 5, 14, 0, 0), timestamp("America/Chicago", 2026, 5, 15, 0, 0), timestamp("America/New_York", 2026, 5, 20, 0, 0), timestamp("America/New_York", 2026, 5, 20, 0, 0), timestamp("America/New_York", 2026, 5, 20, 0, 0), timestamp("America/New_York", 2026, 5, 20, 0, 0), timestamp("America/New_York", 2026, 5, 20, 0, 0), timestamp("America/New_York", 2026, 5, 26, 0, 0), timestamp("America/New_York", 2026, 5, 26, 0, 0), timestamp("America/Chicago", 2026, 5, 26, 0, 0), timestamp("America/Chicago", 2026, 5, 26, 0, 0), timestamp("America/Chicago", 2026, 5, 27, 0, 0), timestamp("America/Chicago", 2026, 5, 27, 0, 0), timestamp("America/Chicago", 2026, 5, 27, 0, 0), timestamp("Europe/Berlin", 2026, 6, 3, 0, 0), timestamp("America/New_York", 2026, 6, 8, 0, 0), timestamp("America/New_York", 2026, 6, 10, 0, 0), timestamp("America/New_York", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 10, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/Chicago", 2026, 6, 12, 0, 0), timestamp("America/New_York", 2026, 6, 15, 0, 0), timestamp("America/New_York", 2026, 6, 16, 0, 0), timestamp("America/New_York", 2026, 6, 16, 0, 0), timestamp("America/New_York", 2026, 6, 16, 0, 0), timestamp("Europe/Berlin", 2026, 6, 16, 0, 0), timestamp("Europe/Berlin", 2026, 6, 16, 0, 0), timestamp("Europe/Berlin", 2026, 6, 16, 0, 0), timestamp("America/New_York", 2026, 6, 18, 0, 0), timestamp("America/New_York", 2026, 6, 18, 0, 0), timestamp("America/New_York", 2026, 6, 18, 0, 0), timestamp("America/New_York", 2026, 6, 22, 0, 0), timestamp("America/New_York", 2026, 6, 22, 0, 0), timestamp("America/New_York", 2026, 6, 24, 0, 0), timestamp("America/Chicago", 2026, 6, 24, 0, 0), timestamp("America/Chicago", 2026, 6, 24, 0, 0), timestamp("America/Chicago", 2026, 6, 24, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/New_York", 2026, 6, 25, 0, 0), timestamp("America/New_York", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/New_York", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/New_York", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 6, 25, 0, 0), timestamp("America/Chicago", 2026, 7, 10, 0, 0), timestamp("America/Chicago", 2026, 7, 15, 0, 0), timestamp("America/Chicago", 2026, 7, 16, 0, 0), timestamp("America/New_York", 2026, 7, 16, 0, 0), timestamp("America/New_York", 2026, 7, 16, 0, 0), timestamp("America/New_York", 2026, 7, 16, 0, 0), timestamp("America/New_York", 2026, 7, 22, 0, 0), timestamp("America/New_York", 2026, 7, 22, 0, 0), timestamp("America/New_York", 2026, 7, 22, 0, 0), timestamp("America/New_York", 2026, 7, 23, 0, 0), timestamp("America/New_York", 2026, 7, 23, 0, 0), timestamp("America/Chicago", 2026, 7, 24, 0, 0), timestamp("America/New_York", 2026, 7, 28, 0, 0), timestamp("America/New_York", 2026, 7, 28, 0, 0), timestamp("America/Chicago", 2026, 7, 29, 0, 0), timestamp("America/Chicago", 2026, 7, 29, 0, 0), timestamp("America/Chicago", 2026, 7, 29, 0, 0), timestamp("America/New_York", 2026, 8, 7, 0, 0), timestamp("America/New_York", 2026, 8, 10, 0, 0), timestamp("America/Chicago", 2026, 8, 12, 0, 0), timestamp("America/New_York", 2026, 8, 17, 0, 0), timestamp("America/New_York", 2026, 8, 17, 0, 0), timestamp("America/New_York", 2026, 8, 17, 0, 0), timestamp("America/New_York", 2026, 8, 21, 0, 0), timestamp("America/New_York", 2026, 8, 21, 0, 0), timestamp("America/New_York", 2026, 8, 21, 0, 0), timestamp("America/New_York", 2026, 8, 21, 0, 0), timestamp("America/New_York", 2026, 8, 21, 0, 0), timestamp("America/New_York", 2026, 8, 24, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/New_York", 2026, 8, 26, 0, 0), timestamp("America/New_York", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/New_York", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("America/Chicago", 2026, 8, 26, 0, 0), timestamp("Europe/Berlin", 2026, 9, 3, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 9, 0, 0), timestamp("America/Chicago", 2026, 9, 10, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("America/Chicago", 2026, 9, 11, 0, 0), timestamp("Europe/Berlin", 2026, 9, 15, 0, 0), timestamp("Europe/Berlin", 2026, 9, 15, 0, 0), timestamp("Europe/Berlin", 2026, 9, 15, 0, 0), timestamp("America/New_York", 2026, 9, 16, 0, 0), timestamp("America/Chicago", 2026, 9, 16, 0, 0), timestamp("America/New_York", 2026, 9, 17, 0, 0), timestamp("America/New_York", 2026, 9, 17, 0, 0), timestamp("America/New_York", 2026, 9, 17, 0, 0), timestamp("America/New_York", 2026, 9, 21, 0, 0), timestamp("America/New_York", 2026, 9, 21, 0, 0), timestamp("America/New_York", 2026, 9, 21, 0, 0), timestamp("America/New_York", 2026, 9, 22, 0, 0), timestamp("America/New_York", 2026, 9, 22, 0, 0), timestamp("America/Chicago", 2026, 9, 23, 0, 0), timestamp("America/Chicago", 2026, 9, 23, 0, 0), timestamp("America/Chicago", 2026, 9, 23, 0, 0), timestamp("America/New_York", 2026, 9, 25, 0, 0), timestamp("America/Chicago", 2026, 9, 25, 0, 0), timestamp("America/Chicago", 2026, 10, 14, 0, 0), timestamp("America/New_York", 2026, 10, 15, 0, 0), timestamp("America/New_York", 2026, 10, 15, 0, 0), timestamp("America/New_York", 2026, 10, 15, 0, 0), timestamp("America/New_York", 2026, 10, 21, 0, 0), timestamp("America/New_York", 2026, 10, 21, 0, 0), timestamp("America/New_York", 2026, 10, 21, 0, 0), timestamp("America/New_York", 2026, 10, 22, 0, 0), timestamp("America/New_York", 2026, 10, 22, 0, 0), timestamp("America/New_York", 2026, 10, 23, 0, 0), timestamp("America/Chicago", 2026, 10, 26, 0, 0), timestamp("America/Chicago", 2026, 10, 27, 0, 0), timestamp("America/Chicago", 2026, 10, 27, 0, 0), timestamp("America/Chicago", 2026, 10, 27, 0, 0), timestamp("America/Chicago", 2026, 10, 28, 0, 0), timestamp("America/Chicago", 2026, 10, 28, 0, 0), timestamp("America/Chicago", 2026, 10, 28, 0, 0), timestamp("America/New_York", 2026, 11, 6, 0, 0), timestamp("America/New_York", 2026, 11, 10, 0, 0), timestamp("America/New_York", 2026, 11, 10, 0, 0), timestamp("America/Chicago", 2026, 11, 10, 0, 0), timestamp("America/Chicago", 2026, 11, 11, 0, 0), timestamp("America/Chicago", 2026, 11, 16, 0, 0), timestamp("America/New_York", 2026, 11, 17, 0, 0), timestamp("America/New_York", 2026, 11, 17, 0, 0), timestamp("America/New_York", 2026, 11, 17, 0, 0), timestamp("America/New_York", 2026, 11, 19, 0, 0), timestamp("America/New_York", 2026, 11, 19, 0, 0), timestamp("America/New_York", 2026, 11, 20, 0, 0), timestamp("America/New_York", 2026, 11, 20, 0, 0), timestamp("America/New_York", 2026, 11, 20, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/New_York", 2026, 11, 24, 0, 0), timestamp("America/New_York", 2026, 11, 24, 0, 0), timestamp("America/New_York", 2026, 11, 24, 0, 0), timestamp("America/New_York", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/New_York", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("America/Chicago", 2026, 11, 24, 0, 0), timestamp("Europe/Berlin", 2026, 12, 3, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 9, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/Chicago", 2026, 12, 11, 0, 0), timestamp("America/New_York", 2026, 12, 16, 0, 0), timestamp("America/New_York", 2026, 12, 16, 0, 0), timestamp("America/New_York", 2026, 12, 16, 0, 0), timestamp("Europe/Berlin", 2026, 12, 16, 0, 0), timestamp("Europe/Berlin", 2026, 12, 16, 0, 0), timestamp("Europe/Berlin", 2026, 12, 16, 0, 0), timestamp("America/New_York", 2026, 12, 22, 0, 0), timestamp("America/New_York", 2026, 12, 22, 0, 0), timestamp("America/New_York", 2026, 12, 22, 0, 0), timestamp("America/New_York", 2026, 12, 22, 0, 0), timestamp("America/New_York", 2026, 12, 22, 0, 0), timestamp("America/Chicago", 2026, 12, 22, 0, 0), timestamp("America/Chicago", 2026, 12, 22, 0, 0), timestamp("America/Chicago", 2026, 12, 22, 0, 0), timestamp("America/New_York", 2026, 12, 24, 0, 0), timestamp("America/Chicago", 2026, 12, 24, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0), timestamp("America/New_York", 2026, 12, 28, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0), timestamp("America/Chicago", 2026, 12, 28, 0, 0))
    var string[] exch   = array.from("CME:", "CBOE:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "COMEX:", "COMEX:", "CME:", "CME:", "CME:", "ICEUS:", "ICEUS:", "ICEUS:", "CBOE:", "ICEUS:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "ICEUS:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CME:", "CME:", "CME:", "CME:", "EUREX:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CBOE:", "CME:", "CME:", "CME:", "CBOT:", "CME:", "CME:", "CME:", "CME:", "CBOT:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "EUREX:", "EUREX:", "EUREX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "CME:", "CME:", "COMEX:", "COMEX:", "NYMEX:", "CME:", "ICEUS:", "CBOE:", "ICEUS:", "ICEUS:", "ICEUS:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "CME:", "CME:", "ICEUS:", "CME:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CME:", "CBOE:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "COMEX:", "COMEX:", "CBOT:", "CBOT:", "CME:", "CME:", "CME:", "EUREX:", "ICEUS:", "ICEUS:", "ICEUS:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CBOE:", "CME:", "CME:", "CME:", "CBOT:", "CME:", "CME:", "CME:", "CME:", "CBOT:", "ICEUS:", "NYMEX:", "NYMEX:", "NYMEX:", "EUREX:", "EUREX:", "EUREX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "ICEUS:", "CME:", "CME:", "CME:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "COMEX:", "CBOT:", "NYMEX:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CME:", "CBOE:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "COMEX:", "COMEX:", "CME:", "CME:", "CME:", "ICEUS:", "ICEUS:", "CBOE:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "ICEUS:", "CME:", "CBOT:", "CBOT:", "COMEX:", "COMEX:", "CBOT:", "CBOT:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CME:", "CME:", "CME:", "EUREX:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CBOE:", "CME:", "CME:", "CME:", "CME:", "CBOT:", "CME:", "CME:", "CME:", "CME:", "CBOT:", "EUREX:", "EUREX:", "EUREX:", "ICEUS:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "CME:", "CME:", "NYMEX:", "CME:", "CBOE:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "ICEUS:", "CME:", "CBOT:", "CBOT:", "CBOT:", "CME:", "CME:", "CME:", "ICEUS:", "ICEUS:", "ICEUS:", "CME:", "CBOE:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "COMEX:", "COMEX:", "COMEX:", "COMEX:", "CBOT:", "COMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CME:", "CME:", "CME:", "EUREX:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CME:", "CBOE:", "CME:", "CME:", "CME:", "CBOT:", "CME:", "CME:", "CME:", "CBOT:", "CME:", "NYMEX:", "NYMEX:", "NYMEX:", "EUREX:", "EUREX:", "EUREX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "NYMEX:", "CME:", "CME:", "CME:", "ICEUS:", "CME:", "CBOT:", "CBOT:", "NYMEX:", "CBOT:", "CBOT:", "CBOT:", "CBOT:", "CBOT:")
    var string[] fromE  = array.from("LEG2026", "VXF2026", "CLG2026", "MCLG2026", "QMG2026", "HEG2026", "HOG2026", "RBG2026", "MRBG2026", "NGG2026", "QNG2026", "GCG2026", "MGCG2026", "BTCF2026", "MBTF2026", "ETHF2026", "CCH2026", "KCH2026", "CTH2026", "VXG2026", "SBH2026", "CLH2026", "MCLH2026", "QMH2026", "HOH2026", "RBH2026", "MRBH2026", "NGH2026", "QNH2026", "OJH2026", "ZLH2026", "MZLH2026", "ZCH2026", "MZCH2026", "HGH2026", "MHGH2026", "KEH2026", "ZRH2026", "ZSH2026", "MZSH2026", "SIH2026", "ZMH2026", "MZMH2026", "ZWH2026", "MZWH2026", "ZNH2026", "ZBH2026", "BTCG2026", "MBTG2026", "ETHG2026", "GFH2026", "FGBLH2026", "LEJ2026", "6AH2026", "6BH2026", "6CH2026", "E7H2026", "6EH2026", "J7H2026", "6JH2026", "6SH2026", "VXH2026", "EMDH2026", "ESH2026", "NQH2026", "YMH2026", "RTYH2026", "MESH2026", "MNQH2026", "M2KH2026", "MYMH2026", "HEJ2026", "CLJ2026", "MCLJ2026", "QMJ2026", "FDAXH2026", "FDXMH2026", "FESXH2026", "HOJ2026", "RBJ2026", "MRBJ2026", "NGJ2026", "QNJ2026", "BTCH2026", "MBTH2026", "ETHH2026", "GCJ2026", "MGCJ2026", "PLJ2026", "GFJ2026", "CCK2026", "VXJ2026", "KCK2026", "CTK2026", "SBK2026", "CLK2026", "MCLK2026", "QMK2026", "HOK2026", "RBK2026", "MRBK2026", "NGK2026", "QNK2026", "BTCJ2026", "MBTJ2026", "ETHJ2026", "OJK2026", "GFK2026", "ZLK2026", "MZLK2026", "ZCK2026", "MZCK2026", "HGK2026", "MHGK2026", "KEK2026", "ZRK2026", "ZSK2026", "MZSK2026", "SIK2026", "ZMK2026", "MZMK2026", "ZWK2026", "MZWK2026", "LEM2026", "VXK2026", "CLM2026", "MCLM2026", "QMM2026", "HEM2026", "NGM2026", "QNM2026", "HOM2026", "RBM2026", "MRBM2026", "GCM2026", "MGCM2026", "ZNM2026", "ZBM2026", "BTCK2026", "MBTK2026", "ETHK2026", "FGBLM2026", "CCN2026", "KCN2026", "CTN2026", "6AM2026", "6BM2026", "6CM2026", "E7M2026", "6EM2026", "J7M2026", "6JM2026", "6SM2026", "VXM2026", "EMDM2026", "ESM2026", "NQM2026", "YMM2026", "RTYM2026", "MESM2026", "MNQM2026", "M2KM2026", "MYMM2026", "SBN2026", "CLN2026", "MCLN2026", "QMN2026", "FDAXM2026", "FDXMM2026", "FESXM2026", "HON2026", "RBN2026", "MRBN2026", "NGN2026", "QNN2026", "OJN2026", "BTCM2026", "MBTM2026", "ETHM2026", "ZLN2026", "MZLN2026", "ZCN2026", "MZCN2026", "HGN2026", "MHGN2026", "KEN2026", "PLN2026", "ZRN2026", "ZSN2026", "MZSN2026", "SIN2026", "ZMN2026", "MZMN2026", "ZWN2026", "MZWN2026", "LEQ2026", "VXN2026", "HEQ2026", "CLQ2026", "MCLQ2026", "QMQ2026", "HOQ2026", "RBQ2026", "MRBQ2026", "NGQ2026", "QNQ2026", "GFQ2026", "GCQ2026", "MGCQ2026", "BTCN2026", "MBTN2026", "ETHN2026", "CCU2026", "KCU2026", "VXQ2026", "CLU2026", "MCLU2026", "QMU2026", "HOU2026", "RBU2026", "MRBU2026", "NGU2026", "QNU2026", "OJU2026", "GFU2026", "ZCU2026", "MZCU2026", "HGU2026", "MHGU2026", "KEU2026", "ZRU2026", "SIU2026", "ZWU2026", "MZWU2026", "ZNU2026", "ZBU2026", "BTCQ2026", "MBTQ2026", "ETHQ2026", "FGBLU2026", "6AU2026", "6BU2026", "6CU2026", "E7U2026", "6EU2026", "J7U2026", "6JU2026", "6SU2026", "VXU2026", "LEV2026", "EMDU2026", "ESU2026", "NQU2026", "YMU2026", "RTYU2026", "MESU2026", "MNQU2026", "M2KU2026", "MYMU2026", "FDAXU2026", "FDXMU2026", "FESXU2026", "SBV2026", "HEV2026", "CLV2026", "MCLV2026", "QMV2026", "HOV2026", "RBV2026", "MRBV2026", "NGV2026", "QNV2026", "BTCU2026", "MBTU2026", "ETHU2026", "PLV2026", "GFV2026", "VXV2026", "CLX2026", "MCLX2026", "QMX2026", "HOX2026", "RBX2026", "MRBX2026", "NGX2026", "QNX2026", "OJX2026", "GFX2026", "ZRX2026", "ZSX2026", "MZSX2026", "BTCV2026", "MBTV2026", "ETHV2026", "CCZ2026", "KCZ2026", "CTZ2026", "LEZ2026", "VXX2026", "HEZ2026", "CLZ2026", "MCLZ2026", "QMZ2026", "NGZ2026", "QNZ2026", "HOZ2026", "RBZ2026", "MRBZ2026", "ZNZ2026", "ZBZ2026", "ZLZ2026", "MZLZ2026", "ZCZ2026", "MZCZ2026", "GCZ2026", "MGCZ2026", "HGZ2026", "MHGZ2026", "KEZ2026", "SIZ2026", "ZMZ2026", "MZMZ2026", "ZWZ2026", "MZWZ2026", "BTCX2026", "MBTX2026", "ETHX2026", "FGBLZ2026", "6AZ2026", "6BZ2026", "6CZ2026", "E7Z2026", "6EZ2026", "J7Z2026", "6JZ2026", "6SZ2026", "VXZ2026", "EMDZ2026", "ESZ2026", "NQZ2026", "YMZ2026", "MESZ2026", "MNQZ2026", "M2KZ2026", "MYMZ2026", "RTYZ2026", "CLF2027", "MCLF2027", "QMF2027", "FDAXZ2026", "FDXMZ2026", "FESXZ2026", "NGF2027", "QNF2027", "HOF2027", "RBF2027", "MRBF2027", "BTCZ2026", "ETHZ2026", "MBTZ2026", "OJF2027", "GFF2027", "ZLF2027", "MZLF2027", "PLF2027", "ZRF2027", "ZMF2027", "MZMF2027", "ZSF2027", "MZSF2027")
    var string[] toE    = array.from("LEJ2026", "VXG2026", "CLH2026", "MCLH2026", "QMH2026", "HEJ2026", "HOH2026", "RBH2026", "MRBH2026", "NGH2026", "QNH2026", "GCJ2026", "MGCJ2026", "BTCG2026", "MBTG2026", "ETHG2026", "CCK2026", "KCK2026", "CTK2026", "VXH2026", "SBK2026", "CLJ2026", "MCLJ2026", "QMJ2026", "HOJ2026", "RBJ2026", "MRBJ2026", "NGJ2026", "QNJ2026", "OJK2026", "ZLK2026", "MZLK2026", "ZCK2026", "MZCK2026", "HGK2026", "MHGK2026", "KEK2026", "ZRK2026", "ZSK2026", "MZSK2026", "SIK2026", "ZMK2026", "MZMK2026", "ZWK2026", "MZWK2026", "ZNM2026", "ZBM2026", "BTCH2026", "MBTH2026", "ETHH2026", "GFJ2026", "FGBLM2026", "LEM2026", "6AM2026", "6BM2026", "6CM2026", "E7M2026", "6EM2026", "J7M2026", "6JM2026", "6SM2026", "VXJ2026", "EMDM2026", "ESM2026", "NQM2026", "YMM2026", "RTYM2026", "MESM2026", "MNQM2026", "M2KM2026", "MYMM2026", "HEM2026", "CLK2026", "MCLK2026", "QMK2026", "FDAXM2026", "FDXMM2026", "FESXM2026", "HOK2026", "RBK2026", "MRBK2026", "NGK2026", "QNK2026", "BTCJ2026", "MBTJ2026", "ETHJ2026", "GCM2026", "MGCM2026", "PLN2026", "GFK2026", "CCN2026", "VXK2026", "KCN2026", "CTN2026", "SBN2026", "CLM2026", "MCLM2026", "QMM2026", "HOM2026", "RBM2026", "MRBM2026", "NGM2026", "QNM2026", "BTCK2026", "MBTK2026", "ETHK2026", "OJN2026", "GFQ2026", "ZLN2026", "MZLN2026", "ZCN2026", "MZCN2026", "HGN2026", "MHGN2026", "KEN2026", "ZRN2026", "ZSN2026", "MZSN2026", "SIN2026", "ZMN2026", "MZMN2026", "ZWN2026", "MZWN2026", "LEQ2026", "VXM2026", "CLN2026", "MCLN2026", "QMN2026", "HEQ2026", "NGN2026", "QNN2026", "HON2026", "RBN2026", "MRBN2026", "GCQ2026", "MGCQ2026", "ZNU2026", "ZBU2026", "BTCM2026", "MBTM2026", "ETHM2026", "FGBLU2026", "CCU2026", "KCU2026", "CTZ2026", "6AU2026", "6BU2026", "6CU2026", "E7U2026", "6EU2026", "J7U2026", "6JU2026", "6SU2026", "VXN2026", "EMDU2026", "ESU2026", "NQU2026", "YMU2026", "RTYU2026", "MESU2026", "MNQU2026", "M2KU2026", "MYMU2026", "SBV2026", "CLQ2026", "MCLQ2026", "QMQ2026", "FDAXU2026", "FDXMU2026", "FESXU2026", "HOQ2026", "RBQ2026", "MRBQ2026", "NGQ2026", "QNQ2026", "OJU2026", "BTCN2026", "MBTN2026", "ETHN2026", "ZLZ2026", "MZLZ2026", "ZCU2026", "MZCU2026", "HGU2026", "MHGU2026", "KEU2026", "PLV2026", "ZRU2026", "ZSX2026", "MZSX2026", "SIU2026", "ZMZ2026", "MZMZ2026", "ZWU2026", "MZWU2026", "LEV2026", "VXQ2026", "HEV2026", "CLU2026", "MCLU2026", "QMU2026", "HOU2026", "RBU2026", "MRBU2026", "NGU2026", "QNU2026", "GFU2026", "GCZ2026", "MGCZ2026", "BTCQ2026", "MBTQ2026", "ETHQ2026", "CCZ2026", "KCZ2026", "VXU2026", "CLV2026", "MCLV2026", "QMV2026", "HOV2026", "RBV2026", "MRBV2026", "NGV2026", "QNV2026", "OJX2026", "GFV2026", "ZCZ2026", "MZCZ2026", "HGZ2026", "MHGZ2026", "KEZ2026", "ZRX2026", "SIZ2026", "ZWZ2026", "MZWZ2026", "ZNZ2026", "ZBZ2026", "BTCU2026", "MBTU2026", "ETHU2026", "FGBLZ2026", "6AZ2026", "6BZ2026", "6CZ2026", "E7Z2026", "6EZ2026", "J7Z2026", "6JZ2026", "6SZ2026", "VXV2026", "LEZ2026", "EMDZ2026", "ESZ2026", "NQZ2026", "YMZ2026", "RTYZ2026", "MESZ2026", "MNQZ2026", "M2KZ2026", "MYMZ2026", "FDAXZ2026", "FDXMZ2026", "FESXZ2026", "SBH2027", "HEZ2026", "CLX2026", "MCLX2026", "QMX2026", "HOX2026", "RBX2026", "MRBX2026", "NGX2026", "QNX2026", "BTCV2026", "MBTV2026", "ETHV2026", "PLF2027", "GFX2026", "VXX2026", "CLZ2026", "MCLZ2026", "QMZ2026", "HOZ2026", "RBZ2026", "MRBZ2026", "NGZ2026", "QNZ2026", "OJF2027", "GFF2027", "ZRF2027", "ZSF2027", "MZSF2027", "BTCX2026", "MBTX2026", "ETHX2026", "CCH2027", "KCH2027", "CTH2027", "LEG2027", "VXZ2026", "HEG2027", "CLF2027", "MCLF2027", "QMF2027", "NGF2027", "QNF2027", "HOF2027", "RBF2027", "MRBF2027", "ZNH2027", "ZBH2027", "ZLF2027", "MZLF2027", "ZCH2027", "MZCH2027", "GCG2027", "MGCG2027", "HGH2027", "MHGH2027", "KEH2027", "SIH2027", "ZMF2027", "MZMF2027", "ZWH2027", "MZWH2027", "BTCZ2026", "MBTZ2026", "ETHZ2026", "FGBLH2027", "6AH2027", "6BH2027", "6CH2027", "E7H2027", "6EH2027", "J7H2027", "6JH2027", "6SH2027", "VXF2027", "EMDH2027", "ESH2027", "NQH2027", "YMH2027", "MESH2027", "MNQH2027", "M2KH2027", "MYMH2027", "RTYH2027", "CLG2027", "MCLG2027", "QMG2027", "FDAXH2027", "FDXMH2027", "FESXH2027", "NGG2027", "QNG2027", "HOG2027", "RBG2027", "MRBG2027", "BTCF2027", "ETHF2027", "MBTF2027", "OJH2027", "GFH2027", "ZLH2027", "MZLH2027", "PLJ2027", "ZRH2027", "ZMH2027", "MZMH2027", "ZSH2027", "MZSH2027")
    var string[] name   = array.from("Live Cattle", "Vix Future", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Lean Hogs", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Gold", "Micro Gold", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Cocoa", "Coffee", "Cotton", "Vix Future", "Sugar No.11", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Orange Juice", "Soybean Oil", "Micro Soybean Oil", "Corn", "Micro Corn", "Copper", "Micro Copper", "Hard Red Winter Wheat", "Rough Rice", "Soybeans", "Micro Soybeans", "Silver", "Soybean Meal", "Micro Soybean Meal", "Wheat", "Micro Wheat", "10-y Treasury Note", "30-y Treasury Bond", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Feeder Cattle", "Bund", "Live Cattle", "Australian Dollar", "British Pound", "Canadian Dollar", "Mini EuroFX", "EuroFX", "Mini Japanese Yen", "Japanese Yen", "Swiss Franc", "Vix Future", "Mini E-Mini S&P MidCap", "Mini S&P 500", "Mini Nasdaq Futures", "Mini Dow Jones Futures", "Mini Russell Futures", "Micro S&P 500", "Micro Nasdaq Futures", "Micro Russell Futures", "Micro Dow Jones Futures", "Lean Hogs", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "DAX Future", "Mini DAX Future", "EuroStoxx", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Gold", "Micro Gold", "Platinum", "Feeder Cattle", "Cocoa", "Vix Future", "Coffee", "Cotton", "Sugar No.11", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Orange Juice", "Feeder Cattle", "Soybean Oil", "Micro Soybean Oil", "Corn", "Micro Corn", "Copper", "Micro Copper", "Hard Red Winter Wheat", "Rough Rice", "Soybeans", "Micro Soybeans", "Silver", "Soybean Meal", "Micro Soybean Meal", "Wheat", "Micro Wheat", "Live Cattle", "Vix Future", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Lean Hogs", "Natural Gas", "Mini Natural Gas", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Gold", "Micro Gold", "10-y Treasury Note", "30-y Treasury Bond", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Bund", "Cocoa", "Coffee", "Cotton", "Australian Dollar", "British Pound", "Canadian Dollar", "Mini EuroFX", "EuroFX", "Mini Japanese Yen", "Japanese Yen", "Swiss Franc", "Vix Future", "Mini E-Mini S&P MidCap", "Mini S&P 500", "Mini Nasdaq Futures", "Mini Dow Jones Futures", "Mini Russell Futures", "Micro S&P 500", "Micro Nasdaq Futures", "Micro Russell Futures", "Micro Dow Jones Futures", "Sugar No.11", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "DAX Future", "Mini DAX Future", "EuroStoxx", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Orange Juice", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Soybean Oil", "Micro Soybean Oil", "Corn", "Micro Corn", "Copper", "Micro Copper", "Hard Red Winter Wheat", "Platinum", "Rough Rice", "Soybeans", "Micro Soybeans", "Silver", "Soybean Meal", "Micro Soybean Meal", "Wheat", "Micro Wheat", "Live Cattle", "Vix Future", "Lean Hogs", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Feeder Cattle", "Gold", "Micro Gold", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Cocoa", "Coffee", "Vix Future", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Orange Juice", "Feeder Cattle", "Corn", "Micro Corn", "Copper", "Micro Copper", "Hard Red Winter Wheat", "Rough Rice", "Silver", "Wheat", "Micro Wheat", "10-y Treasury Note", "30-y Treasury Bond", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Bund", "Australian Dollar", "British Pound", "Canadian Dollar", "Mini EuroFX", "EuroFX", "Mini Japanese Yen", "Japanese Yen", "Swiss Franc", "Vix Future", "Live Cattle", "Mini E-Mini S&P MidCap", "Mini S&P 500", "Mini Nasdaq Futures", "Mini Dow Jones Futures", "Mini Russell Futures", "Micro S&P 500", "Micro Nasdaq Futures", "Micro Russell Futures", "Micro Dow Jones Futures", "DAX Future", "Mini DAX Future", "EuroStoxx", "Sugar No.11", "Lean Hogs", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Platinum", "Feeder Cattle", "Vix Future", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Natural Gas", "Mini Natural Gas", "Orange Juice", "Feeder Cattle", "Rough Rice", "Soybeans", "Micro Soybeans", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Cocoa", "Coffee", "Cotton", "Live Cattle", "Vix Future", "Lean Hogs", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "Natural Gas", "Mini Natural Gas", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "10-y Treasury Note", "30-y Treasury Bond", "Soybean Oil", "Micro Soybean Oil", "Corn", "Micro Corn", "Gold", "Micro Gold", "Copper", "Micro Copper", "Hard Red Winter Wheat", "Silver", "Soybean Meal", "Micro Soybean Meal", "Wheat", "Micro Wheat", "Bitcoin Future", "Micro Bitcoin Future", "Ethereum", "Bund", "Australian Dollar", "British Pound", "Canadian Dollar", "Mini EuroFX", "EuroFX", "Mini Japanese Yen", "Japanese Yen", "Swiss Franc", "Vix Future", "Mini E-Mini S&P MidCap", "Mini S&P 500", "Mini Nasdaq Futures", "Mini Dow Jones Futures", "Micro S&P 500", "Micro Nasdaq Futures", "Micro Russell Futures", "Micro Dow Jones Futures", "Mini Russell Futures", "Crude Oil", "Micro Crude Oil", "Mini Crude Oil", "DAX Future", "Mini DAX Future", "EuroStoxx", "Natural Gas", "Mini Natural Gas", "Heating Oil", "RBOB Gasoline", "Micro RBOB Gasoline", "Bitcoin Future", "Ethereum", "Micro Bitcoin Future", "Orange Juice", "Feeder Cattle", "Soybean Oil", "Micro Soybean Oil", "Platinum", "Rough Rice", "Soybean Meal", "Micro Soybean Meal", "Soybeans", "Micro Soybeans")
    [inst, rollTs, exch, fromE, toE, name]

findNext(string instrument, string[] inst, int[] rollTs) =>
    int idx = na
    for i = 0 to array.size(inst) - 1
        if array.get(inst, i) == instrument and array.get(rollTs, i) > time
            idx := i
            break
    idx

activeRowToday(string instrument, string[] inst, int[] rollTs) =>
    findNext(instrument, inst, rollTs)

prevTradingDayTs(int tsTarget) =>
    nz(ta.valuewhen(time("D") <= tsTarget, time("D"), 0), tsTarget)

export isFirstBarOfDay(int fireTs) =>
    not na(fireTs) and time("D") >= fireTs and time("D")[1] < fireTs


// EXPORT 1) Scadenza attiva "oggi"
export active_expiry(string instrument) =>
    [inst, rollTs, exch, fromE, toE, name] = data()
    int i = activeRowToday(instrument, inst, rollTs)
    na(i) ? "" : array.get(fromE, i)

_dayMs() => 24 * 60 * 60 * 1000

_dayStart(int ts) =>
    math.floor(ts / _dayMs()) * _dayMs()

_dowFromTs(int ts) =>
    int(((math.floor(ts / _dayMs()) + 4) % 7) + 1)

_weekdayBackToFri(int ts) =>
    int dow = _dowFromTs(ts)
    dow == dayofweek.saturday ? ts - _dayMs() : dow == dayofweek.sunday   ? ts - 2 * _dayMs() : ts



// =====================
// ROLLOVER ALERT ENGINE
// =====================

alreadyFired(string key, int fireTs, string[] firedKeys, int[] firedTs) =>
    if array.size(firedKeys) == 0 or array.size(firedTs) == 0
        false
    else
        bool seen = false
        for j = 0 to array.size(firedKeys) - 1
            if array.get(firedKeys, j) == key and array.get(firedTs, j) == fireTs
                seen := true
                break
        seen

markFired(string key, int fireTs, string[] firedKeys, int[] firedTs) =>
    array.push(firedKeys, key)
    array.push(firedTs, fireTs)
    true


export check_and_build_alert(string instrumentKey, int leadDays, string strategyName) =>
    // OUTPUTS
    bool   fire          = false
    string msg           = ""
    string active        = ""
    string next_sym      = ""
    string    next_roll  = "" 

    // DEBUG
    string reason        = ""
    bool bgcolorok = false

    // Stato persistente 
    var string[] firedKeys = array.new_string()
    var int[]    firedDays = array.new_int()

    // Carica i dati
    [inst, rollTs, exch, fromE, toE, name] = data()

    // Trova il prossimo rollover
    int i = findNext(instrumentKey, inst, rollTs)

    if na(i)
        reason := "No upcoming rollover found for key: " + instrumentKey
    else
        string disp      = array.get(name,   i)
        string roll_from = array.get(fromE,  i)
        string roll_to   = array.get(toE,    i)
        int    roll      = array.get(rollTs, i)
        string exchange  = array.get(exch,   i)

        active       := exchange + roll_from
        next_sym     := exchange + roll_to
        next_roll := str.format_time(roll, "dd/MM/yyyy")

        // FIRE DAY
        int leadTs   = roll - leadDays * _dayMs()
        int leadAdj  = _weekdayBackToFri(leadTs)
        int fireDay  = _dayStart(leadAdj)

        int todayDay = _dayStart(time)

        bool isFireDay   = (todayDay == fireDay)
        bool isRealtime  = barstate.isrealtime
        bool isBarClosed = barstate.isconfirmed

        string k = instrumentKey + ":" + str.tostring(fireDay)

        // Componi messaggio
        string posLine = ""
        float  ps      = nz(strategy.position_size, 0)
        posLine := ps == 0 ? "Has No open position." : "Has " + str.tostring(math.abs(ps)) + " open " + (ps > 0 ? "LONG" : "SHORT") + " position." + "\n" + "Close on " + roll_from + " and open on " + roll_to

        string onDate = str.tostring(year(roll)) + "-" + str.tostring(month(roll)) + "-" + str.tostring(dayofmonth(roll))

        msg := "Imminent rollover for " + disp + ":\n\n" +
               "On Date: " + onDate + "\n" +
               "From: "    + roll_from + "\n" +
               "To: "      + roll_to   + "\n" +
               "Exchange: "+ exchange  + "\n\n" +
               "Strategy: "+ strategyName + "\n" + posLine

        // Condizioni di fire
        if not isFireDay
            reason := "Not fire day. todayDay != fireDay"
        else if not isRealtime
            reason := "Bar not realtime. Alerts never fire on historical."
        else if not isBarClosed
            reason := "Bar not confirmed yet (waiting for close)."
        else if alreadyFired(k, fireDay, firedKeys, firedDays)
            reason := "This key/day already alerted (anti-duplicate)."
        else
            // Tutto ok -> Fire!
            fire   := true
            reason := "OK – alert fired."
            _      = markFired(k, fireDay, firedKeys, firedDays)

    [fire, msg, active, next_sym, next_roll]



export debug_roll(string instrumentKey, int leadDays) =>
    [inst, rollTs, exch, fromE, toE, name] = data()
    int i = findNext(instrumentKey, inst, rollTs)
    int nxt   = na(i) ? na : array.get(rollTs, i)
    int lead  = na(nxt) ? na : (nxt - leadDays * 24 * 60 * 60 * 1000)
    int fire  = na(lead) ? na : prevTradingDayTs(lead)
    [i, nxt, lead, fire, time("D")]



export active_symbol(string instrument, string continuous_contract) =>
    [inst, rollTs, exch, fromE, toE, name] = data()

    int   bestIdx  = na
    int   bestTs   = -1
    int   firstTs  = na

    for i = 0 to array.size(inst) - 1
        if array.get(inst, i) == instrument
            int ts = array.get(rollTs, i)
            if na(firstTs) or ts < firstTs
                firstTs := ts
            if time >= ts and ts > bestTs
                bestTs  := ts
                bestIdx := i

    string sym = na
    if na(bestIdx)
        sym := ticker.inherit(syminfo.main_tickerid, continuous_contract)
    else
        sym := array.get(toE, bestIdx)

    sym




///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////





///////////////////////////// Z - INDICATORS - START /////////////////////////////
///////////////////////////// Z - INDICATORS - START /////////////////////////////
///////////////////////////// Z - INDICATORS - START /////////////////////////////
///////////////////////////// Z - INDICATORS - START /////////////////////////////
///////////////////////////// Z - INDICATORS - START /////////////////////////////
///////////////////////////// Z - INDICATORS - START /////////////////////////////


XAverage(float PriceValue, int Length) =>
	var var0 = 2/(Length + 1)

	XAvg = 0.0000
	if bar_index == 1
		XAvg := PriceValue
	else
		XAvg := XAvg[1] + var0*(PriceValue - XAvg[1])

	XAvg



export Avg(float PriceValue, int Length) =>
	Summation(PriceValue, Length) / Length


export MACD(float PriceValue, int FastLen, int SlowLen) =>
	XAverage(PriceValue, FastLen) - XAverage(PriceValue, SlowLen)


export ROC(float price, int Length) =>
	if price[Length] > 0
		((price - price[Length]) / (price[Length])) * 100


VariancePS(float PriceValue, int Length, int DataType) =>
	var int var0 = 0
	var float var1 = 0.0000
	var float var2 = 0.0000

	Variance = 0.0000
	if DataType == 1
		var0 := Length
	else
		var0 := Length - 1

	value2 = f_Avg(PriceValue, Length)
	if var0 > 0
		var2 := value2
		var1 := 0
		for value1 = 0 to (Length - 1)
			var1 := var1 + ((PriceValue[value1] - var2) * (PriceValue[value1] - var2))

		Variance := var1 / var0

    Variance


StandardDev(float PriceValue, int Length, int DataType) =>
	value1 = VariancePS(PriceValue, Length, DataType)
	if value1 > 0
		math.sqrt(value1)
	else
		0


export StdDev(float PriceValue, int Length) =>
	StandardDev(PriceValue, Length, 1)


export BollingerBand(float PriceValue, int Length, int NumDevs) =>
	f_Avg(PriceValue, Length) + NumDevs*(StandardDev(PriceValue, Length, 1))


export Momentum(float PriceValue, int Length) =>
	PriceValue - PriceValue[Length]


Cum(float PriceValue) =>
	var Cumm = 0.0000
	Cumm := Cumm[1] + PriceValue
	Cumm


XAverageOrig(float PriceValue, int Length) =>
	var var0 = 1/Length
	var XAvgOrig = 0.0000
	if bar_index == 1
		XAvgOrig := PriceValue
	else
		XAvgOrig := XAvgOrig[1] + var0*(PriceValue - XAvgOrig[1])

	XAvgOrig


export Stochastic(float PriceValueH, float PriceValueL, float PriceValueC, int   StochLen, int   Len1, int   Len2, int   SmoothingType) =>
    cb = bar_index + 1 

    // Fast %K 
    lowestL  = ta.lowest(PriceValueL, StochLen)
    highestH = ta.highest(PriceValueH, StochLen)
    num = PriceValueC - lowestL
    den = highestH   - lowestL
    oFastK = den > 0 ? (num / den) * 100.0 : 0.0

    var float firstNum = na
    var float firstDen = na
    if barstate.isfirst
        firstNum := num
        firstDen := den

    float oFastD = na
    float oSlowD = na

    if SmoothingType == 1
        float var4 = na
        float var5 = na
        if cb <= Len1
            var4 := (ta.cum(num) + (Len1 - cb) * nz(firstNum, num)) / Len1
            var5 := (ta.cum(den) + (Len1 - cb) * nz(firstDen, den)) / Len1
        else
            var4 := ta.sma(num, Len1)
            var5 := ta.sma(den, Len1)
        oFastD := var5 > 0 ? (var4 / var5) * 100.0 : 0.0

        var float firstFastD = na
        if cb == 1
            firstFastD := oFastD

        if cb <= Len2
            oSlowD := (ta.cum(oFastD) + (Len2 - cb) * nz(firstFastD, oFastD)) / Len2
        else
            oSlowD := ta.sma(oFastD, Len2)

    else if SmoothingType == 2
        oFastD := XAverage(oFastK, Len1)
        oSlowD := XAverageOrig(oFastD, Len2)

    else
        float var4_fb = na
        float var5_fb = na
        if cb <= Len1
            var4_fb := (ta.cum(num) + (Len1 - cb) * nz(firstNum, num)) / Len1
            var5_fb := (ta.cum(den) + (Len1 - cb) * nz(firstDen, den)) / Len1
        else
            var4_fb := ta.sma(num, Len1)
            var5_fb := ta.sma(den, Len1)
        oFastD := var5_fb > 0 ? (var4_fb / var5_fb) * 100.0 : 0.0

        var float firstFastD_fb = na
        if cb == 1
            firstFastD_fb := oFastD
        if cb <= Len2
            oSlowD := (ta.cum(oFastD) + (Len2 - cb) * nz(firstFastD_fb, oFastD)) / Len2
        else
            oSlowD := ta.sma(oFastD, Len2)

    oSlowK = oFastD 

    [oFastK, oFastD, oSlowK, oSlowD]


export CCI(int Length) =>
	var var0 = 0.0000
	var var1 = 0.0000
	var CCI = 0.0000

	var0 := f_Avg(high+low+close, Length)
	var1 := 0
	for var2 = 0 to (Length - 1) 
		var1 := var1 + math.abs((high+low+close)[var2] - var0)
	
	var1 := var1 / Length

	if var1 == 0
		CCI := 0
	else
		CCI := (high+low+close - var0) / (0.015*var1)
	
	CCI

	
export RSI(float PriceValue, int Length) =>
	var var0 = 0.0000
	var var1 = 0.0000
	var var2 = 0.0000
	var var3 = 1/Length
	var var4 = 0.0000

	if bar_index == 1
		var0 := (PriceValue - PriceValue[Length]) / Length
		var1 := f_Avg(math.abs(PriceValue - PriceValue[1]), Length)

	else
		var2 := PriceValue - PriceValue[1]
		var0 := var0[1] + var3 * (var2 - var0[1])
		var1 := var1[1] + var3 * (math.abs(var2) - var1[1])
	
	if var1 != 0
		var4 := var0 / var1
	else
		var4 := 0

	50*(var4 + 1)


TrueRangeCustom(float PriceValueH, float PriceValueL, float PriceValueC) =>
	var var0 = 0.0000
	var var1 = 0.0000

	var0 := PriceValueH
	var1 := PriceValueL

	if PriceValueC[1] > PriceValueH
		var0 := PriceValueC[1]
	else if PriceValueC[1] < PriceValueL
		var1 := PriceValueC

	var0 - var1


DirMovement(float PriceValueH, float PriceValueL, float PriceValueC, int Len) =>
    var bool  seeded     = false
    var float avgPlus    = na
    var float avgMinus   = na
    var float oVolty   = na
    var int   cb         = 0
    var float firstAdx   = na
    var float cumDMI     = 0.0

    up   = PriceValueH - PriceValueH[1]
    down = PriceValueL[1] - PriceValueL
    plusDM  = (up   > down and up   > 0) ? up   : 0.0
    minusDM = (down > up   and down > 0) ? down : 0.0
    trNow   = TrueRangeCustom(PriceValueH, PriceValueL, PriceValueC)

    if not seeded and bar_index >= Len
        float sumPlus = 0.0
        float sumMinus = 0.0
        float sumTR = 0.0
        for i = 0 to Len - 1
            up_i   = PriceValueH[i] - PriceValueH[i + 1]
            down_i = PriceValueL[i + 1] - PriceValueL[i]
            plus_i  = (up_i   > down_i and up_i   > 0) ? up_i   : 0.0
            minus_i = (down_i > up_i   and down_i > 0) ? down_i : 0.0
            tr_i    = TrueRangeCustom(PriceValueH[i], PriceValueL[i], PriceValueC[i])
            sumPlus  += plus_i
            sumMinus += minus_i
            sumTR    += tr_i
        avgPlus  := sumPlus  / Len
        avgMinus := sumMinus / Len
        oVolty := sumTR    / Len
        seeded   := true
        cb       := 1

    if seeded and cb > 0
        alpha    = 1.0 / Len
        avgPlus  := avgPlus  + alpha * (plusDM  - avgPlus)
        avgMinus := avgMinus + alpha * (minusDM - avgMinus)
        oVolty := oVolty + alpha * (trNow   - oVolty)

    oDMIPlus  = oVolty > 0 ? 100.0 * avgPlus  / oVolty : 0.0
    oDMIMinus = oVolty > 0 ? 100.0 * avgMinus / oVolty : 0.0
    sumDI   = oDMIPlus + oDMIMinus
    oDMI     = sumDI > 0 ? 100.0 * math.abs(oDMIPlus - oDMIMinus) / sumDI : 0.0

    // ADX: early
    float oADX = na
    float oADXR = na
    if seeded and cb > 0
        if cb <= Len
            cumDMI += oDMI
            oADX := cumDMI / cb
            if cb == 1
                firstAdx := oADX
            oADXR := (oADX + nz(firstAdx, oADX)) * 0.5
        else
            oADX  := nz(oADX[1]) + (1.0 / Len) * (oDMI - nz(oADX[1]))
            oADXR := (oADX + nz(oADX[Len - 1], oADX)) * 0.5

    // incrementa il CurrentBar
    if seeded
        cb += 1

    dirMovementFlag = 1.0

    [oDMIPlus, oDMIMinus, oDMI, oADX, oADXR, oVolty, dirMovementFlag]



export ADX(int Len) =>
    [_, _, _, oADX, _, _, _] = DirMovement(high, low, close, Len)
    oADX


///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////
///////////////////////////// Z - ROLL - END /////////////////////////////




///////////////////////////// Z - BADGE - START /////////////////////////////
///////////////////////////// Z - BADGE - START /////////////////////////////
///////////////////////////// Z - BADGE - START /////////////////////////////
///////////////////////////// Z - BADGE - START /////////////////////////////
///////////////////////////// Z - BADGE - START /////////////////////////////
///////////////////////////// Z - BADGE - START /////////////////////////////

toPos(s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

export Badge(bool showBadge, string posInput, string sizeInput, int opacity, string active_sym, string tf_text, string next_sym, string next_roll_ts, string session_type) =>
    isCompact = sizeInput == "Compact"
    isLarge   = sizeInput == "Large"
    szLabel   = isCompact ? size.tiny  : isLarge ? size.large  : size.small
    szValue   = isCompact ? size.small : isLarge ? size.large  : size.normal

    cBlue  = color.new(color.rgb(45, 104, 196), opacity)
    cGreen = color.new(color.rgb(34, 135, 92),  opacity)
    cRed   = color.new(color.rgb(170, 57, 57),  opacity)
    cText  = color.white

    var table  tBadge  = na
    var string _posMem = na

    if showBadge
        curPos = toPos(posInput)
        if na(tBadge) or _posMem != posInput
            if not na(tBadge)
                table.delete(tBadge)
            tBadge := table.new(curPos, 2, 5, border_width=1, border_color=color.new(cText, 80))
            _posMem := posInput

        if barstate.islastconfirmedhistory
            lblInstrument = isCompact ? "Symbol:" : "Instrument:"
            lblTF         = isCompact ? "TF:"     : "Time Frame:"
            lblSess       = "Session:"
            lblNext       = isCompact ? "Next:"   : "Next Roll:"

            valSess = session_type
            valNext = isCompact ? (next_sym + " " + next_roll_ts) : (next_sym + " on date: " + next_roll_ts)

            // RIGA 0: WATERMARK 
            wmText   = ""

            table.cell(tBadge, 0, 0, "",       text_color=color.new(cText, 100), text_size=isCompact ? size.tiny : size.small, text_halign=text.align_left,  bgcolor=color.new(color.black, 0))
            table.cell(tBadge, 1, 0, wmText,   text_color=color.new(cText, 30),  text_size=isCompact ? size.tiny : size.small, text_halign=text.align_right, bgcolor=color.new(color.black, 0))

            // ---- RIGA 1
            table.cell(tBadge, 0, 1, lblInstrument, text_color=cText, text_size=szLabel, text_halign=text.align_left,  bgcolor=cBlue)
            table.cell(tBadge, 1, 1, active_sym,    text_color=cText, text_size=szValue, text_halign=text.align_right, bgcolor=cBlue)

            // ---- RIGA 2
            table.cell(tBadge, 0, 2, lblTF,   text_color=cText, text_size=szLabel, text_halign=text.align_left,  bgcolor=cGreen)
            table.cell(tBadge, 1, 2, tf_text, text_color=cText, text_size=szValue, text_halign=text.align_right, bgcolor=cGreen)

            // ---- RIGA 3
            table.cell(tBadge, 0, 3, lblSess, text_color=cText, text_size=szLabel, text_halign=text.align_left,  bgcolor=cRed)
            table.cell(tBadge, 1, 3, valSess, text_color=cText, text_size=szValue, text_halign=text.align_right, bgcolor=cRed)

            // ---- RIGA 4
            table.cell(tBadge, 0, 4, lblNext, text_color=cText, text_size=szLabel, text_halign=text.align_left,  bgcolor=cBlue)
            table.cell(tBadge, 1, 4, valNext, text_color=cText, text_size=isCompact ? size.small : size.normal, text_halign=text.align_right, bgcolor=cBlue)
    else
        if not na(tBadge)
            table.delete(tBadge)
            tBadge := na

    tBadge


///////////////////////////// Z - BADGE - END /////////////////////////////
///////////////////////////// Z - BADGE - END /////////////////////////////
///////////////////////////// Z - BADGE - END /////////////////////////////
///////////////////////////// Z - BADGE - END /////////////////////////////
///////////////////////////// Z - BADGE - END /////////////////////////////
///////////////////////////// Z - BADGE - END /////////////////////////////
````
