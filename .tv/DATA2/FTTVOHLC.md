<!-- tradingview-pine-id: PUB;024ab0ed580149f4b7267d03803943ad -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FT_TV_OHLC

Source: https://www.tradingview.com/script/3NLOZebz-FT-TV-OHLC/

## Description

FT_TV_OHLC is a Pine Script® v6 library which provides a reusable OHLC context, pattern-evaluation engine and entry-level framework for systematic trading strategies.

The library builds and maintains structured Open, High, Low and Close data for the current market period and the previous five completed periods. On intraday charts, these periods can represent either calendar days or custom trading sessions, allowing the same strategy logic to work with session-aware market data.

This OHLC history is combined with a pre-calculated market context containing candle ranges and bodies, recent extrema, multi-period measurements and session-start references. The resulting data is used by other libraries pattern and entry-level engines.

Main exported functionality

[*][pine]Z_FT_OHLC()[/pine] — Builds and maintains the OHLC data structure used by the library. It supports both Day and custom Session aggregation modes, configurable session times and timezone-aware processing.

[*][pine]ZPattern_Mir_PreCalc()[/pine] — Pre-calculates the common market context used by the pattern engine, including OHLC ranges and bodies, multi-period extrema, session bar state and session-start price references. This avoids repeatedly calculating the same data across individual pattern evaluations.

[*][pine]ZEntryLevel_Mir()[/pine] — Generates long and short entry-price levels from a broad collection of configurable methods. Available calculations include OHLC-derived levels, ATR and range extensions, moving-average references, recent extrema, session-start levels, percentage offsets, weekly levels and other price-based structures. A reversal mode can also swap the resulting long and short levels.

[*][pine]ZPattern_Mir()[/pine] — Main interface to the extended pattern catalog. It evaluates more than 480 directional market conditions based on current price action, Day/Session OHLC structures, multi-period relationships, breakouts, compression/expansion, candle characteristics and session context. Positive and negative pattern IDs select the corresponding directional variants of each condition.

[*][pine]ZPattern_MostUsed()[/pine] — Provides a compact subset of frequently used OHLC and price-action conditions for strategies that do not require the complete pattern catalog.

[*][pine]Z_OHLC_PatternsPanel()[/pine] — Provides an optional visual diagnostic panel for selected OHLC patterns, including their current verification state, descriptions and occurrence counters, with optional chart highlighting.

Purpose

FT_TV_OHLC is designed primarily as a shared analytical dependency for other strategies. It separates OHLC aggregation, market-context calculations, pattern evaluation and entry-level generation from the individual strategy logic, providing a consistent framework that can be reused across multiple Pine Script® strategies.

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


library("FT_TV_OHLC", overlay = true, dynamic_requests = true)



// ====================================================================================================
//FT_TV_OHLC / PATTERN CONTEXT — QUICK GUIDE & GLOSSARY (Variables Reference)
// ====================================================================================================

// PATTERN LIST CONTAINERS (functions that hold the patterns catalog)
// - Extended catalog split in chunks:
//   • ZPattern_Mir_1_160
//   • ZPattern_Mir_161_320
//   • ZPattern_Mir_321_478
//   • ZPattern_Mir_479_N

// - “Most Used” subset:
//   • ZPattern_MostUsed



// ----------------------------------------------------------------------------------------------------
// 1) CORE IDEA (what these variables represent)
// ----------------------------------------------------------------------------------------------------
// The pattern engine evaluates boolean “filters” (pattern IDs) using:
// - An OHLC ring-buffer array (FT_TV_OHLC) containing the current and previous 5 completed OHLC periods.
// - A pre-calculated context array (PtnCtx) containing heavy computations derived from FT_TV_OHLC plus
//   a session bar counter (barcount).

// Important: “OHLC period” is NOT always a calendar day.
// - On non-intraday charts (timeframe >= 1D): each bar is already a full OHLC day/bar.
// - On intraday charts: OHLC can be aggregated as:
//   • Daily (“Day”): calendar day depending on set timezone ('timezone_ohlc')
//   • Session (“Session”): custom trading window [sessStart..sessEnd] depending on set timezone ('timezone_ohlc')
// So variables named "opendX / highdX / lowdX / closedX" are the OHLC values of the selected period
// (Day or Session), not necessarily the chart bar.



// ----------------------------------------------------------------------------------------------------
// 2)FT_TV_OHLC ARRAY — OHLC DAY/SESSION VARIABLES
// ----------------------------------------------------------------------------------------------------
// FT_TV_OHLC is expected to have at least 24 elements, grouped in blocks of 4:
//   [0..3]   = d0 (current OHLC period still forming)
//   [4..7]   = d1 (previous completed OHLC period)
//   [8..11]  = d2
//   [12..15] = d3
//   [16..19] = d4
//   [20..23] = d5

// Glossary (each “dX” is one OHLC period back):
// - opend0, highd0, lowd0, closed0
//   • Open / High / Low / Close of the CURRENT OHLC period (Day/Session) being built right now.
// - opend1, highd1, lowd1, closed1
//   • OHLC of the PREVIOUS fully completed OHLC period.
// - opend2..closed2, opend3..closed3, opend4..closed4, opend5..closed5
//   • Same concept, going further back up to 5 periods.

// Practical reading:
// - “d0” moves/updates intrabar as new highs/lows form (and close updates to the latest close).
// - “d1..d5” are historical snapshots (stable), used for comparisons, ranges, and multi-day logic.



// ----------------------------------------------------------------------------------------------------
// 3) PtnCtx ARRAY — PRE-CALCULATED CONTEXT VARIABLES (from ZPattern_Mir_PreCalc)
// ----------------------------------------------------------------------------------------------------
// Pattern works with variables pre-calculated by using the function "ZPattern_Mir_PreCalc".
// Here is a complete explanation of all used variables:

// A) Session bar counter / session state
// - barcount
//   • Number of bars elapsed since the start of the current Session/Trading-day context.
//   • Reset to 0 on StartOfSession, then increments by 1 each new bar.
// - StartOfSession = (barcount == 0)
//   • True only on the first bar of the current session context.

// Why it matters:
// - Many patterns use `barcount > N` to avoid firing too early in the session and to ensure enough
//   intraday structure exists before evaluating conditions.


// B) Candle body and range measures (single period and multi-period)
// - body1d
//   • Absolute real body size of the previous OHLC period.
// - range1d
//   • Full high-low range of the previous OHLC period.

// - body5d
//   • Multi-period “net body” measure spanning from opend5 to closed1.
//   • Interpretable as the directional displacement across a 5-period window, expressed as an absolute size.
// - range5d
//   • Total range across the last 5 completed periods (d1..d5)

// Common usage:
// - body-to-range ratios (e.g., “small body day”, “large body vs range”) for compression/expansion filters.
// - Multi-period displacement vs multi-period range for trend/mean-reversion regime detection.


// C) Highest / lowest values across the last 5 completed OHLC periods (d1..d5)
// These are “rolling window” extrema for each OHLC component:
// - HighestO = Highest Open of the latest 5 sessions / days
// - LowestO  = Lowest Open of the latest 5 sessions / days

// - HighestH = Highest High of the latest 5 sessions / days
// - LowestH  = Lowest High of the latest 5 sessions / days

// - HighestL = Highest Low of the latest 5 sessions / days
// - LowestL  = Lowest Low of the latest 5 sessions / days

// - HighestC = Highest Close of the latest 5 sessions / days
// - LowestC  = Lowest Close of the latest 5 sessions / days

// Common usage:
// - Breakout / sweep filters (e.g., current values vs HighestH / LowestL).
// - Regime thresholds derived from “recent extremes” rather than a moving average.


// D) Per-period range and body
// Ranges (high-low) for each OHLC period:
// - rangeD0 = today's session / day range (highest high - lowest low)
// - rangeD1 = yesterday's session / day range
// - rangeD2 = 2 days ago's session / day range
// - rangeD3 = 3 days ago's session / day range
// - rangeD4 = 4 days ago's session / day range
// - rangeD5 = 5 days ago's session / day range

// Absolute Bodies for each OHLC period:
// - bodyD0  = today's session / day body (absolute value of (close - open))
// - bodyD1  = yesterday's session / day body 
// - bodyD2  = 2 days ago's session / day body 
// - bodyD3  = 3 days ago's session / day body 
// - bodyD4  = 4 days ago's session / day body 
// - bodyD5  = 5 days ago's session / day body 

// Notes:
// - rangeD0/bodyD0 update as the current OHLC period evolves.
// - rangeD1..rangeD5 and bodyD1..bodyD5 are stable references for comparisons.


// E) Combined extrema helpers (useful for “gap / displacement” style filters)
// - MaxCO
//   • Maximum between:
//     - HighestC (max close over d1..d5)
//     - HighestO (max open  over d1..d5)
//   • Interpretable as the “upper envelope” of opens/closes over the last 5 completed periods.

// - MinOC
//   • Minimum between:
//     - LowestO (min open  over d1..d5)
//     - LowestC (min close over d1..d5)
//   • Interpretable as the “lower envelope” of opens/closes over the last 5 completed periods.

// Why it matters:
// - Useful when you want to ignore wicks and focus on “accepted” price areas (opens/closes).



// ----------------------------------------------------------------------------------------------------
// 4) SESSION-START BAR CACHES (intraday reference anchors)
// ----------------------------------------------------------------------------------------------------
// In the pattern functions you’ll also see:
// - StartOfSession
// - sessStartHigh
// - sessStartLow
// - sessStartRange

// Meaning:
// - sessStartHigh / sessStartLow:
//   • High and Low of the FIRST chart bar of the current session context.
// - sessStartRange:
//   • The high-low range of that first bar.

// Typical usage:
// - “Break from the session start bar” logic (e.g., close > sessStartHigh, close < sessStartLow).
// - Early-session volatility anchoring (e.g., close > sessStartHigh + sessStartRange).



// ----------------------------------------------------------------------------------------------------
// 5) PER-BAR RANGE (chart bar, not OHLC period)
// ----------------------------------------------------------------------------------------------------
// - rng0 = high - low
//   • The high-low range of the CURRENT CHART BAR (single candle on your timeframe).
//   • This is distinct from rangeD0, which is the range of the current aggregated OHLC period
//     (day/session) that can span many chart bars on intraday timeframes.

// Quick distinction:
// - rng0   → “this candle’s volatility”
// - rangeD0 → “today/session’s volatility so far”

// ====================================================================================================
// END OF GLOSSARY
// ====================================================================================================




// ====================================================================================================
// APPENDIX — PATTERN READING EXAMPLES
// ====================================================================================================

// Direction convention used by the pattern engine:
// - `Each pattern has 2 opposite versions, only one of them is used depending on the sign "+" or "-"
//    of the set pattern number.
//     • "+" → first definition is used, the one before the ":" character)
//     • "-" → second definition is used, the one after the ":" character)

// Reminder:
// - d0 = current OHLC period (Day/Session) still forming
// - d1..d5 = previous completed OHLC periods
// - Highest*/Lowest* are computed across d1..d5
// - body1d / range1d refer to d1
// - rangeDk / bodyDk refer to the OHLC period "dk"
// - sessStartHigh / sessStartLow / sessStartRange anchor the FIRST CHART BAR of the session context
// - barcount counts chart bars since StartOfSession


// ----------------------------------------------------------------------------------------------------
// Example A) Pattern 36 — “Body vs range on d1 (near-marubozu test)”
// ----------------------------------------------------------------------------------------------------
// 36 => dir ? (body1d < 0.9 * range1d)
//           : (body1d > 0.9 * range1d)

// - positive:
//   “The previous completed OHLC period (d1) has a body (body1d) smaller than 90% of its range
//    (range1d).”
//   → d1 is NOT a full-body candle (wicks are non-negligible).

// - negative:
//   “The previous completed OHLC period (d1) has a body (body1d) larger than 90% of its range
//    (range1d).”
//   → d1 is a near-marubozu / dominant-body candle (wicks are small vs the total range).


// ----------------------------------------------------------------------------------------------------
// Example B) Pattern 68 — “Break of 5-period extremes”
// ----------------------------------------------------------------------------------------------------
// 68 => dir ? (highd0 > HighestH)
//           : (lowd0  < LowestL)

// - positive:
//   “The current OHLC period high (highd0) is greater than the highest High of the last 5 completed
//    OHLC periods (HighestH).”
//   → d0 is extending beyond the prior 5-period upper extreme.

// - negative:
//   “The current OHLC period low (lowd0) is lesser than the lowest Low of the last 5 completed
//    OHLC periods (LowestL).”
//   → d0 is extending beyond the prior 5-period lower extreme.


// ----------------------------------------------------------------------------------------------------
// Example C) Pattern 197 — “Explicit body1d/range1d ratio (75% threshold)”
// ----------------------------------------------------------------------------------------------------
// 197 => dir ? (abs(opend1 - closed1) > 0.75 * (highd1 - lowd1))
//            : (abs(opend1 - closed1) < 0.75 * (highd1 - lowd1))

// This is the same concept as comparing `body1d` to `range1d`, written explicitly.

// - positive:
//   “On d1, the candle body (body1d) is greater than 75% of the candle range (range1d).”
//   → Strong directional candle on the previous period.

// - negative:
//   “On d1, the candle body (body1d) is smaller than 75% of the candle range (range1d).”
//   → Less directional / more wick-based candle on the previous period.


// ----------------------------------------------------------------------------------------------------
// Example D) Pattern 205 — “Tight-range condition on d0 (percent compression)”
// ----------------------------------------------------------------------------------------------------
// 205 => dir ? (highd0 < (lowd0 + lowd0 * 1 * 0.01))
//            : (lowd0  > (highd0 - highd0 * 1 * 0.01))

// This checks whether the current OHLC period range (rangeD0 ≈ highd0 - lowd0) is very small
// relative to price (~1%).

// - positive:
//   “The current OHLC period high (highd0) is less than ~1% above the current OHLC period low (lowd0).”
//   → Equivalent intuition: excursion of today's bar is compressed to within ~1% of bar's low.

// - negative:
//   “The current OHLC period low (lowd0) is less than ~1% below the current OHLC period high (highd0).”
//   → Equivalent intuition: excursion of today's bar is compressed to within ~1% of bar's high.

// Practical meaning:
// - A volatility/compression filter on the CURRENT OHLC period (d0), independent of candle direction.


// ----------------------------------------------------------------------------------------------------
// Example E) Pattern 273 — “Session-start expansion with a minimum barcount”
// ----------------------------------------------------------------------------------------------------
// 273 => dir ? (barcount > 3 and (highd0 > (sessStartHigh + sessStartRange)))
//            : (barcount > 3 and (lowd0  < (sessStartLow  - sessStartRange)))

// This combines:
// 1) a timing constraint: `barcount > 3` (at least 4 chart bars after StartOfSession),
// 2) a threshold derived from the session-start bar anchors.

// - positive:
//   “After at least 4 bars into the session (barcount > 3), the current OHLC period high (highd0)
//    exceeds the session-start bar high (sessStartHigh) plus the session-start bar range (sessStartRange).”
//   → Early-session expansion / breakout beyond a 1× session-start-range buffer.

// - negative:
//   “After at least 4 bars into the session, the current OHLC period low (lowd0) drops below the
//    session-start bar low (sessStartLow) minus the session-start bar range (sessStartRange).”
//   → Early-session expansion / breakdown beyond a symmetric 1× range buffer.

// Note:
// - Because highd0/lowd0 are OHLC-period extremes, once the threshold is exceeded within d0,
//   the condition can remain true for the rest of the OHLC period.


// ----------------------------------------------------------------------------------------------------
// Example F) Pattern 476 — “Directional d2 + range contraction vs d3”
// ----------------------------------------------------------------------------------------------------
// 476 => dir ? (closed2 > opend2 and rangeD2 < rangeD3)
//            : (closed2 < opend2 and rangeD2 < rangeD3)

// - positive:
//   “The 2 sessions / days ago bar closed above its open (closed2 > opend2) AND its range (rangeD2) is smaller than
//    the range of the prior OHLC period d3 (rangeD3).”
//   → A bullish period (d2) occurring under contraction vs the previous period (d3).

// - negative:
//   “The 2 sessions / days ago bar closed below its open (closed2 < opend2) AND its range (rangeD2) is smaller than
//    the range of d3 (rangeD3).”
//   → A bearish period (d2) occurring under contraction vs the previous period (d3).


// ----------------------------------------------------------------------------------------------------
// Example G) Pattern 479 — “Multi-period displacement vs a custom cross-period range”
// ----------------------------------------------------------------------------------------------------
// 479 => dir ? (abs(opend5 - closed1) > 0.25 * (highd5 - lowd1))
//            : (abs(opend5 - closed1) < 0.25 * (highd5 - lowd1))

// This compares:
// - a multi-period displacement (abs(opend5 - closed1), i.e., a “body5d-style” displacement),
// against
// - a custom cross-period range (highd5 - lowd1).

// - positive:
//   “The displacement from the open of 5 sessions / days ago bar (opend5) to the close of yesterday's bar (closed1) 
//    is greater than 25% of the entire period range (highd5 - lowd1).”
//   → The multi-period move is meaningful relative to that reference range.

// - negative:
//   “That displacement is smaller than 25% of the entire period range (highd5 - lowd1).”
//   → The multi-period move is relatively small vs the reference range (more ‘flat/contained’ behavior).

// ====================================================================================================
// END OF APPENDIX
// ====================================================================================================







///////////////////////////////////////
// --------------------------------- //
// OHLC ARRAY
// --------------------------------- //
///////////////////////////////////////

// --- Helpers ---
f_mod(int x, int m) =>
    int r = x % m
    r < 0 ? r + m : r


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


AvgTrueRange(int Len) =>
    f_Avg(TrueRange(), Len)



export Z_FT_OHLC(int sessStart, int sessEndIn, string useDailyMode, string timezone_ohlc, array<float> FT_OHLC) =>
    // --- Validazione array
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements")

    bool _ret = false

    // TIMEFRAME NON-INTRADAY (>= D)
    if not timeframe.isintraday
        // 0..3: barra corrente
        array.set(FT_OHLC, 0, open)
        array.set(FT_OHLC, 1, high)
        array.set(FT_OHLC, 2, low)
        array.set(FT_OHLC, 3, close)

        for idxBack = 1 to 5
            int base = 4 * idxBack
            array.set(FT_OHLC, base + 0, open[idxBack])
            array.set(FT_OHLC, base + 1, high[idxBack])
            array.set(FT_OHLC, base + 2, low[idxBack])
            array.set(FT_OHLC, base + 3, close[idxBack])

        _ret := true

    // TIMEFRAME INTRADAY
    else
        // normalizzazione in caso start==end 
        int sEnd = sessEndIn
        if sessStart == sEnd
            sEnd := sEnd - 1
            if sEnd == -1
                sEnd := 2359
            if (sEnd % 100) == 99
                sEnd := sEnd - 40

        // time/date in timezone dell'exchange
        string tz = timezone_ohlc

        int t     = hour(time_close, tz) * 100 + minute(time_close, tz)
        int tPrev = hour(time_close[1], tz) * 100 + minute(time_close[1], tz)

        int y     = year(time_close, tz)
        int mth   = month(time_close, tz)
        int dom   = dayofmonth(time_close, tz)

        int yPrev   = year(time_close[1], tz)
        int mthPrev = month(time_close[1], tz)
        int domPrev = dayofmonth(time_close[1], tz)

        int D     = y * 10000 + mth * 100 + dom
        int DPrev = yPrev * 10000 + mthPrev * 100 + domPrev

        // LOGICA "TRADING DAY" 
        bool isOvernight = sessStart > sEnd
        bool inWindow = not isOvernight ? (t >= sessStart and t <= sEnd) : (t >= sessStart or  t <= sEnd)

        bool isNewTradingDay = false

        if inWindow
            // crossing dell'orario di start
            bool crossedStart = (t >= sessStart) and (tPrev < sessStart)
            isNewTradingDay := crossedStart

            if not isOvernight
                // sessione "in giornata": split/coerenza su cambio data
                if D != DPrev
                    isNewTradingDay := true
            else
                // overnight
                int DAY_MS = 24 * 60 * 60 * 1000
                int midTs     = timestamp(tz, y, mth, dom, 0, 0)
                int midPrevTs = timestamp(tz, yPrev, mthPrev, domPrev, 0, 0)

                bool missingDay = midTs > (midPrevTs + DAY_MS)
                if missingDay
                    isNewTradingDay := true

                // se cambia data e la barra precedente aveva un time prima dello start
                if (D != DPrev) and (tPrev < sessStart)
                    isNewTradingDay := true

        // LOGICA "OHLC PERIOD" 
        bool isNewOHLCDay = useDailyMode == "Day" ? (D != DPrev) : isNewTradingDay

        var float curO = na
        var float curH = na
        var float curL = na
        var float curC = na

        var int  ringSlot = 0
        var bool initDone = false

        var float[] ringO = array.new_float(20, na)
        var float[] ringH = array.new_float(20, na)
        var float[] ringL = array.new_float(20, na)
        var float[] ringC = array.new_float(20, na)

        if not initDone
            curO := open
            curH := high
            curL := low
            curC := close
            ringSlot := 0
            initDone := true

        // SALVATAGGIO STATO CORRENTE 
        array.set(ringO, ringSlot, curO)
        array.set(ringH, ringSlot, curH)
        array.set(ringL, ringSlot, curL)
        array.set(ringC, ringSlot, curC)

        if isNewOHLCDay
            curO := open
            curH := high
            curL := low
            curC := close
            ringSlot := f_mod(ringSlot + 1, 20)

        // UPDATE OHLC 
        if useDailyMode == "Day"
            // DAILY
            curH := math.max(curH, high)
            curL := math.min(curL, low)
            curC := close
        else
            // SESSION
            if inWindow
                curH := math.max(curH, high)
                curL := math.min(curL, low)
                curC := close

        // OUTPUT
        array.set(FT_OHLC, 0, curO)
        array.set(FT_OHLC, 1, curH)
        array.set(FT_OHLC, 2, curL)
        array.set(FT_OHLC, 3, curC)

        for idxBack = 1 to 5
            int srcSlot = f_mod(ringSlot - idxBack, 20)
            int base    = 4 * idxBack

            array.set(FT_OHLC, base + 0, array.get(ringO, srcSlot))
            array.set(FT_OHLC, base + 1, array.get(ringH, srcSlot))
            array.set(FT_OHLC, base + 2, array.get(ringL, srcSlot))
            array.set(FT_OHLC, base + 3, array.get(ringC, srcSlot))

        // RETURN
        _ret := isNewOHLCDay

    _ret




///////////////////////////////////////
// --------------------------------- //
// OHLC VARIABLES PRE-CALC
// --------------------------------- //
///////////////////////////////////////

// Helpers 
f_max5(float a, float b, float c, float d, float e) =>
    math.max(math.max(math.max(math.max(a, b), c), d), e)

f_min5(float a, float b, float c, float d, float e) =>
    math.min(math.min(math.min(math.min(a, b), c), d), e)


export ZPattern_Mir_PreCalc(array<float> FT_OHLC, bool StartOfSession, array<float> PtnCtx) =>
    // Guard rails 
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")

    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")

    var int lastBar   = na
    var int barcount  = -1

    if na(lastBar) or bar_index != lastBar
        lastBar := bar_index

        // Barcount
        if StartOfSession
            barcount := 0
        else
            barcount += 1

        float O0  = array.get(FT_OHLC, 0)
        float H0  = array.get(FT_OHLC, 1)
        float L0  = array.get(FT_OHLC, 2)
        float C0  = array.get(FT_OHLC, 3)

        float O1  = array.get(FT_OHLC, 4)
        float H1  = array.get(FT_OHLC, 5)
        float L1  = array.get(FT_OHLC, 6)
        float C1  = array.get(FT_OHLC, 7)

        float O2  = array.get(FT_OHLC, 8)
        float H2  = array.get(FT_OHLC, 9)
        float L2  = array.get(FT_OHLC, 10)
        float C2  = array.get(FT_OHLC, 11)

        float O3  = array.get(FT_OHLC, 12)
        float H3  = array.get(FT_OHLC, 13)
        float L3  = array.get(FT_OHLC, 14)
        float C3  = array.get(FT_OHLC, 15)

        float O4  = array.get(FT_OHLC, 16)
        float H4  = array.get(FT_OHLC, 17)
        float L4  = array.get(FT_OHLC, 18)
        float C4  = array.get(FT_OHLC, 19)

        float O5  = array.get(FT_OHLC, 20)
        float H5  = array.get(FT_OHLC, 21)
        float L5  = array.get(FT_OHLC, 22)
        float C5  = array.get(FT_OHLC, 23)

        // Calcoli pesanti
        float body1d  = math.abs(O1 - C1)
        float range1d = (H1 - L1)

        float body5d  = math.abs(O5 - C1)
        float range5d = f_max5(H1, H2, H3, H4, H5) - f_min5(L1, L2, L3, L4, L5)

        float HighestO = f_max5(O1, O2, O3, O4, O5)
        float LowestO  = f_min5(O1, O2, O3, O4, O5)

        float HighestH = f_max5(H1, H2, H3, H4, H5)
        float LowestH  = f_min5(H1, H2, H3, H4, H5)

        float HighestL = f_max5(L1, L2, L3, L4, L5)
        float LowestL  = f_min5(L1, L2, L3, L4, L5)

        float HighestC = f_max5(C1, C2, C3, C4, C5)
        float LowestC  = f_min5(C1, C2, C3, C4, C5)

        // Range e body per ciascun giorno
        float rangeD0 = H0 - L0
        float rangeD1 = H1 - L1
        float rangeD2 = H2 - L2
        float rangeD3 = H3 - L3
        float rangeD4 = H4 - L4
        float rangeD5 = H5 - L5

        float bodyD0 = math.abs(C0 - O0)
        float bodyD1 = math.abs(C1 - O1)
        float bodyD2 = math.abs(C2 - O2)
        float bodyD3 = math.abs(C3 - O3)
        float bodyD4 = math.abs(C4 - O4)
        float bodyD5 = math.abs(C5 - O5)

        float MaxCO = math.max(HighestC, HighestO)
        float MinOC = math.min(LowestO,  LowestC)

        // Session-start cached values
        float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
        float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
        float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)


        // Salvataggio 
        array.set(PtnCtx, 0,  float(barcount))

        array.set(PtnCtx, 1,  body1d)
        array.set(PtnCtx, 2,  range1d)
        array.set(PtnCtx, 3,  body5d)
        array.set(PtnCtx, 4,  range5d)

        array.set(PtnCtx, 5,  HighestO)
        array.set(PtnCtx, 6,  LowestO)
        array.set(PtnCtx, 7,  HighestH)
        array.set(PtnCtx, 8,  LowestH)
        array.set(PtnCtx, 9,  HighestL)
        array.set(PtnCtx, 10, LowestL)
        array.set(PtnCtx, 11, HighestC)
        array.set(PtnCtx, 12, LowestC)

        array.set(PtnCtx, 13, rangeD0)
        array.set(PtnCtx, 14, rangeD1)
        array.set(PtnCtx, 15, rangeD2)
        array.set(PtnCtx, 16, rangeD3)
        array.set(PtnCtx, 17, rangeD4)
        array.set(PtnCtx, 18, rangeD5)

        array.set(PtnCtx, 19, bodyD0)
        array.set(PtnCtx, 20, bodyD1)
        array.set(PtnCtx, 21, bodyD2)
        array.set(PtnCtx, 22, bodyD3)
        array.set(PtnCtx, 23, bodyD4)
        array.set(PtnCtx, 24, bodyD5)

        array.set(PtnCtx, 25, sessStartHigh)
        array.set(PtnCtx, 26, sessStartLow)
        array.set(PtnCtx, 27, sessStartRange)

        array.set(PtnCtx, 30, MaxCO)
        array.set(PtnCtx, 31, MinOC)

    true




///////////////////////////////////////
// --------------------------------- //
// ENTRY LEVELS  FUNCTION
// --------------------------------- //
///////////////////////////////////////

export ZEntryLevel_Mir(int entryLevel, int nBars, bool StartOfSession, string timezone, string flipMode, array<float> FT_OHLC, array<float> PtnCtx) =>
    // Guard rails 
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")


    int N = nBars < 0 ? 0 : nBars > 5 ? 5 : nBars

    float z = close * 0.0

    // NBars-based OHLC 
    float OpenN  = nz(array.get(FT_OHLC, 0 + N * 4), z)
    float HighN  = nz(array.get(FT_OHLC, 1 + N * 4), z)
    float LowN   = nz(array.get(FT_OHLC, 2 + N * 4), z)
    float CloseN = nz(array.get(FT_OHLC, 3 + N * 4), z)

    float OpenN1  = z
    float HighN1  = z
    float LowN1   = z
    float CloseN1 = z
    if N <= 4
        OpenN1  := nz(array.get(FT_OHLC, 0 + (N + 1) * 4), z)
        HighN1  := nz(array.get(FT_OHLC, 1 + (N + 1) * 4), z)
        LowN1   := nz(array.get(FT_OHLC, 2 + (N + 1) * 4), z)
        CloseN1 := nz(array.get(FT_OHLC, 3 + (N + 1) * 4), z)

    float rangeN = HighN - LowN

    // PreCalc context
    float HighestO = array.get(PtnCtx, 5)
    float LowestO  = array.get(PtnCtx, 6)
    float HighestH = array.get(PtnCtx, 7)
    float LowestH  = array.get(PtnCtx, 8)
    float LowestL  = array.get(PtnCtx, 10)
    float HighestC = array.get(PtnCtx, 11)
    float LowestC  = array.get(PtnCtx, 12)

    float closed1 = nz(array.get(FT_OHLC, 7), z)

    // Session-start cached values
    float sessStartHigh  = nz(array.get(PtnCtx, 25), nz(ta.valuewhen(StartOfSession, high, 0), high))
    float sessStartLow   = nz(array.get(PtnCtx, 26), nz(ta.valuewhen(StartOfSession, low, 0), low))
    float sessStartRange = nz(array.get(PtnCtx, 27), nz(ta.valuewhen(StartOfSession, high - low, 0), high - low))

    // Per-bar range
    float rng0 = high - low

    // ATR 
    float atr5  = AvgTrueRange(5)
    float atr10 = AvgTrueRange(10)
    float atr20 = AvgTrueRange(20)
    float atr30 = AvgTrueRange(30)
    float atr50 = AvgTrueRange(50)

    // Week high/low 
    var float wkHigh = na
    var float wkLow  = na
    var int   weekofyr = na
    var bool  newWeek  = false

    weekofyr := weekofyear(time, timezone)
    newWeek  := weekofyr[1] != weekofyr

    if na(wkHigh) or newWeek
        wkHigh := high
        wkLow  := low
    else
        wkHigh := math.max(wkHigh, high)
        wkLow  := math.min(wkLow, low)

    // Output 
    float myle = na
    float myse = na

    // =====================
    // SWITCH (statement) 
    // =====================
    switch entryLevel

        // NEW 0..2  (OLD 0..2)
        0 =>
            myle := close < HighN ? HighN : na
            myse := close > LowN  ? LowN  : na
        1 =>
            myle := close < HighN ? (HighN + (HighN * 0.01 * 1.0)) : na
            myse := close > LowN  ? (LowN  - (LowN  * 0.01 * 1.0)) : na
        2 =>
            myle := close < HighN ? (HighN - (HighN * 0.01 * 1.0)) : na
            myse := close > LowN  ? (LowN  + (LowN  * 0.01 * 1.0)) : na

        // NEW 3..4  (OLD 19..20)
        3 =>
            myle := HighN + (HighN - CloseN)
            myse := LowN  - (CloseN - LowN)
        4 =>
            myle := CloseN1 > HighN ? (HighN + (CloseN1 - HighN)) : na
            myse := CloseN1 < LowN  ? (LowN  - (LowN - CloseN1))  : na

        // NEW 5..6  (OLD 54..55)
        5 =>
            if StartOfSession
                myle := (2.0 * ((HighN + LowN + CloseN) / 3.0) - LowN)
                myse := (2.0 * ((HighN + LowN + CloseN) / 3.0) - HighN)
            else
                myle := na
                myse := na
        6 =>
            if StartOfSession
                myle := (((HighN + LowN + CloseN) / 3.0) + HighN - LowN)
                myse := (((HighN + LowN + CloseN) / 3.0) - HighN + LowN)
            else
                myle := na
                myse := na

        // NEW 7..21 (OLD 73..87)
        7  =>  myle := HighN + atr5,          myse := LowN - atr5
        8  =>  myle := HighN + atr5  * 0.5,   myse := LowN - atr5  * 0.5
        9  =>  myle := HighN + atr5  * 0.25,  myse := LowN - atr5  * 0.25
        10 =>  myle := HighN + atr10,         myse := LowN - atr10
        11 =>  myle := HighN + atr10 * 0.5,   myse := LowN - atr10 * 0.5
        12 =>  myle := HighN + atr10 * 0.25,  myse := LowN - atr10 * 0.25
        13 =>  myle := HighN + atr20,         myse := LowN - atr20
        14 =>  myle := HighN + atr20 * 0.5,   myse := LowN - atr20 * 0.5
        15 =>  myle := HighN + atr20 * 0.25,  myse := LowN - atr20 * 0.25
        16 =>  myle := HighN + atr30,         myse := LowN - atr30
        17 =>  myle := HighN + atr30 * 0.5,   myse := LowN - atr30 * 0.5
        18 =>  myle := HighN + atr30 * 0.25,  myse := LowN - atr30 * 0.25
        19 =>  myle := HighN + atr50,         myse := LowN - atr50
        20 =>  myle := HighN + atr50 * 0.5,   myse := LowN - atr50 * 0.5
        21 =>  myle := HighN + atr50 * 0.25,  myse := LowN - atr50 * 0.25

        // NEW 22..26 (OLD 88..92)
        22 =>  myle := HighN + rangeN,          myse := LowN - rangeN
        23 =>  myle := HighN + rangeN / 1.5,    myse := LowN - rangeN / 1.5
        24 =>  myle := HighN + rangeN / 2.0,    myse := LowN - rangeN / 2.0
        25 =>  myle := HighN + rangeN / 3.0,    myse := LowN - rangeN / 3.0
        26 =>  myle := HighN + rangeN / 4.0,    myse := LowN - rangeN / 4.0

        // NEW 27..28 (OLD 93..94)
        27 =>
            if StartOfSession
                myle := (2.0 * ((HighestH + LowestL + closed1) / 3.0) - LowestL)
                myse := (2.0 * ((HighestH + LowestL + closed1) / 3.0) - HighestH)
            else
                myle := na
                myse := na
        28 =>
            if StartOfSession
                myle := (((HighestH + LowestL + closed1) / 3.0) + HighestH - LowestL)
                myse := (((HighestH + LowestL + closed1) / 3.0) - HighestH + LowestL)
            else
                myle := na
                myse := na

        // NEW 29 (OLD 95)
        29 =>
            myle := high + (close - low) + (high - open)
            myse := low - (close - low) - (high - open)


        // NEW 30..33 (OLD 3..6) 
        30 => myle := ta.highest(high, 5),   myse := ta.lowest(low, 5)
        31 => myle := ta.highest(high, 10),  myse := ta.lowest(low, 10)
        32 => myle := ta.highest(high, 30),  myse := ta.lowest(low, 30)
        33 => myle := ta.highest(high, 50),  myse := ta.lowest(low, 50)

        // NEW 34..37 (OLD 7..10)
        34 => myle := ta.sma(high, 5)  + ta.sma(rng0, 5),   myse := ta.sma(low, 5)  - ta.sma(rng0, 5)
        35 => myle := ta.sma(high, 10) + ta.sma(rng0, 10),  myse := ta.sma(low, 10) - ta.sma(rng0, 10)
        36 => myle := ta.sma(high, 30) + ta.sma(rng0, 30),  myse := ta.sma(low, 30) - ta.sma(rng0, 30)
        37 => myle := ta.sma(high, 50) + ta.sma(rng0, 50),  myse := ta.sma(low, 50) - ta.sma(rng0, 50)

        // NEW 38..41 (OLD 11..14)
        38 => myle := ta.sma(high, 5),   myse := ta.sma(low, 5)
        39 => myle := ta.sma(high, 10),  myse := ta.sma(low, 10)
        40 => myle := ta.sma(high, 30),  myse := ta.sma(low, 30)
        41 => myle := ta.sma(high, 50),  myse := ta.sma(low, 50)

        // NEW 42..45 (OLD 15..18) 
        42 => myle := ta.sma(close, 5)  + ta.sma(rng0, 5),   myse := ta.sma(close, 5)  - ta.sma(rng0, 5)
        43 => myle := ta.sma(close, 10) + ta.sma(rng0, 10),  myse := ta.sma(close, 10) - ta.sma(rng0, 10)
        44 => myle := ta.sma(close, 30) + ta.sma(rng0, 30),  myse := ta.sma(close, 30) - ta.sma(rng0, 30)
        45 => myle := ta.sma(close, 50) + ta.sma(rng0, 50),  myse := ta.sma(close, 50) - ta.sma(rng0, 50)

        // NEW 46..51 (OLD 21..26)
        46 => myle := high,    myse := low
        47 => myle := high[1], myse := low[1]
        48 => myle := high[2], myse := low[2]
        49 => myle := high[3], myse := low[3]
        50 => myle := high[4], myse := low[4]
        51 => myle := high[5], myse := low[5]

        // NEW 52..53 (OLD 27..28)
        52 => myle := sessStartHigh,               myse := sessStartLow
        53 => myle := sessStartHigh + sessStartRange, myse := sessStartLow - sessStartRange

        // NEW 54..56 (OLD 29..31)
        54 => myle := HighestH, myse := LowestL
        55 => myle := HighestC, myse := LowestC
        56 => myle := HighestO, myse := LowestO

        // NEW 57..62 (OLD 32..37)
        57 => myle := ta.highest(high, 5),   myse := ta.lowest(low, 5)
        58 => myle := ta.highest(high, 10),  myse := ta.lowest(low, 10)
        59 => myle := ta.highest(high, 20),  myse := ta.lowest(low, 20)
        60 => myle := ta.highest(high, 30),  myse := ta.lowest(low, 30)
        61 => myle := ta.highest(high, 40),  myse := ta.lowest(low, 40)
        62 => myle := ta.highest(high, 50),  myse := ta.lowest(low, 50)

        // NEW 63..68 (OLD 38..43) 
        63 => myle := high  + rng0,          myse := low   - rng0
        64 => myle := close + rng0,          myse := close - rng0
        65 => myle := high  + rng0 * 0.5,    myse := low   - rng0 * 0.5
        66 => myle := close + rng0 * 0.5,    myse := close - rng0 * 0.5
        67 => myle := high  + rng0 * 0.25,   myse := low   - rng0 * 0.25
        68 => myle := close + rng0 * 0.25,   myse := close - rng0 * 0.25

        // NEW 69..78 (OLD 44..53) 
        69 => myle := high  + (high  * 0.01 * 0.5),  myse := low   - (low   * 0.01 * 0.5)
        70 => myle := high  + (high  * 0.01 * 1.0),  myse := low   - (low   * 0.01 * 1.0)
        71 => myle := high  + (high  * 0.01 * 1.5),  myse := low   - (low   * 0.01 * 1.5)
        72 => myle := high  + (high  * 0.01 * 2.0),  myse := low   - (low   * 0.01 * 2.0)
        73 => myle := high  + (high  * 0.01 * 2.5),  myse := low   - (low   * 0.01 * 2.5)
        74 => myle := close + (close * 0.01 * 0.5),  myse := close - (close * 0.01 * 0.5)
        75 => myle := close + (close * 0.01 * 1.0),  myse := close - (close * 0.01 * 1.0)
        76 => myle := close + (close * 0.01 * 1.5),  myse := close - (close * 0.01 * 1.5)
        77 => myle := close + (close * 0.01 * 2.0),  myse := close - (close * 0.01 * 2.0)
        78 => myle := close + (close * 0.01 * 2.5),  myse := close - (close * 0.01 * 2.5)

        // NEW 79..80 (OLD 56..57)
        79 => myle := open,   myse := open
        80 => myle := wkHigh, myse := wkLow

        // NEW 81..95 (OLD 58..72) 
        81 => myle := high + atr5,            myse := low - atr5
        82 => myle := high + atr5  * 0.5,     myse := low - atr5  * 0.5
        83 => myle := high + atr5  * 0.25,    myse := low - atr5  * 0.25
        84 => myle := high + atr10,           myse := low - atr10
        85 => myle := high + atr10 * 0.5,     myse := low - atr10 * 0.5
        86 => myle := high + atr10 * 0.25,    myse := low - atr10 * 0.25
        87 => myle := high + atr20,           myse := low - atr20
        88 => myle := high + atr20 * 0.5,     myse := low - atr20 * 0.5
        89 => myle := high + atr20 * 0.25,    myse := low - atr20 * 0.25
        90 => myle := high + atr30,           myse := low - atr30
        91 => myle := high + atr30 * 0.5,     myse := low - atr30 * 0.5
        92 => myle := high + atr30 * 0.25,    myse := low - atr30 * 0.25
        93 => myle := high + atr50,           myse := low - atr50
        94 => myle := high + atr50 * 0.5,     myse := low - atr50 * 0.5
        95 => myle := high + atr50 * 0.25,    myse := low - atr50 * 0.25

        // fallback
        =>
            myle := na
            myse := na

    // Flip mode
    bool  isRev = flipMode == "Reversal"
    float outLe = isRev ? myse : myle
    float outSe = isRev ? myle : myse

    [outLe, outSe]









///////////////////////////////////////
// --------------------------------- //
// PATTERNS FUNCTION
// --------------------------------- //
///////////////////////////////////////


ZPattern_Mir_1_160(int pattern, array<float> FT_OHLC, array<float> PtnCtx) =>
    // Guard rails
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")

    // OHLC day/session
    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)

    // Load pre-calcs
    int   barcount = int(nz(array.get(PtnCtx, 0), 0))

    float body1d   = array.get(PtnCtx, 1)
    float range1d  = array.get(PtnCtx, 2)
    float body5d   = array.get(PtnCtx, 3)
    float range5d  = array.get(PtnCtx, 4)

    float HighestO = array.get(PtnCtx, 5)
    float LowestO  = array.get(PtnCtx, 6)
    float HighestH = array.get(PtnCtx, 7)
    float LowestH  = array.get(PtnCtx, 8)
    float HighestL = array.get(PtnCtx, 9)
    float LowestL  = array.get(PtnCtx, 10)
    float HighestC = array.get(PtnCtx, 11)
    float LowestC  = array.get(PtnCtx, 12)

    float rangeD0  = array.get(PtnCtx, 13)
    float rangeD1  = array.get(PtnCtx, 14)
    float rangeD2  = array.get(PtnCtx, 15)
    float rangeD3  = array.get(PtnCtx, 16)
    float rangeD4  = array.get(PtnCtx, 17)
    float rangeD5  = array.get(PtnCtx, 18)

    float bodyD0   = array.get(PtnCtx, 19)
    float bodyD1   = array.get(PtnCtx, 20)
    float bodyD2   = array.get(PtnCtx, 21)
    float bodyD3   = array.get(PtnCtx, 22)
    float bodyD4   = array.get(PtnCtx, 23)
    float bodyD5   = array.get(PtnCtx, 24)

    float MaxCO    = array.get(PtnCtx, 30)
    float MinOC    = array.get(PtnCtx, 31)

    // Session-start bar 
    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)

    // Per-bar range 
    float rng0 = high - low

    // Switch patterns
    p = math.abs(pattern)
    dir = pattern > 0


    bool res = switch p
        1   => dir ? (high > high[1] and high[1] > high[2] and high[2] > high[3]) 
                   : (low  < low[1]  and low[1]  < low[2]  and low[2]  < low[3])

        2   => dir ? (low  > low[1]  and low[1]  > low[2]  and low[2]  > low[3]) 
                   : (high < high[1] and high[1] < high[2] and high[2] < high[3])

        3   => dir ? (close > close[1] and close[1] > close[2] and close[2] > close[3]) 
                   : (close < close[1] and close[1] < close[2] and close[2] < close[3])

        4   => dir ? (high > highd0[1]) 
                   : (low  < lowd0[1])

        5   => dir ? (close > open and (high - low) > (((high[1] - low[1]) + (high[2] - low[2]) + (high[3] - low[3]) + (high[4] - low[4]) + (high[5] - low[5])) * 0.4)) 
                   : (close < open and (high - low) > (((high[1] - low[1]) + (high[2] - low[2]) + (high[3] - low[3]) + (high[4] - low[4]) + (high[5] - low[5])) * 0.4))

        6   => dir ? (close[1] < highd0[2] and close > highd0[1])
                   : (close[1] >= lowd0[2] and close < lowd0[1])

        7   => dir ? (close[1] < highd1[1] and close > highd1)
                   : (close[1] >= lowd1[1] and close < lowd1)

        8   => dir ? (close[1] < closed1[1] and close > closed1)
                   : (close[1] >= closed1[1] and close < closed1)

        9   => dir ? (close[1] < HighestH[1] and close > HighestH)
                   : (close[1] >= LowestL[1] and close < LowestL)

        10  => dir ? (barcount > 3 and close[1] < sessStartHigh[1] and close > sessStartHigh)
                   : (barcount > 3 and close[1] >= sessStartLow[1]  and close < sessStartLow)

        11  => dir ? (barcount > 3 and (opend0 - lowd0) < (highd0 - opend0))
                   : (barcount > 3 and (opend0 - lowd0) > (highd0 - opend0))

        12  => dir ? (barcount > 3 and close > (sessStartHigh + sessStartRange))
                   : (barcount > 3 and close < (sessStartLow  - sessStartRange))

        13  => dir ? (close > opend0)
                   : (close < opend0)

        14  => dir ? (close > opend1)
                   : (close < opend1)

        15  => dir ? (close > opend0 * 0.99)
                   : (close < opend0 * 1.01)

        16  => dir ? (close > opend0 * 0.995)
                   : (close < opend0 * 1.005)

        17  => dir ? (close > opend0 * 1.005)
                   : (close < opend0 * 0.995)

        18  => dir ? (close > opend0 * 1.01)
                   : (close < opend0 * 0.99)

        19  => dir ? (close > highd0[1])
                   : (close < lowd0[1])

        20  => dir ? (close > highd1)
                   : (close < lowd1)

        21  => dir ? (close > closed1)
                   : (close < closed1)

        22  => dir ? ((close - opend0) > 0 and (close - opend0) > 0.5 * rangeD0)
                   : ((opend0 - close) > 0 and (opend0 - close) > 0.5 * rangeD0)

        23  => dir ? ((close - opend0) > 0 and (close - opend0) < 0.5 * rangeD0)
                   : ((opend0 - close) > 0 and (opend0 - close) < 0.5 * rangeD0)

        24  => dir ? ((close - opend1) > 0 and (close - opend1) > 0.5 * (highd0 - lowd1))
                   : ((opend1 - close) > 0 and (opend1 - close) > 0.5 * (highd0 - lowd1))

        25  => dir ? ((close - opend1) > 0 and (close - opend1) < 0.5 * (highd0 - lowd1))
                   : ((opend1 - close) > 0 and (opend1 - close) < 0.5 * (highd0 - lowd1))

        26  => dir ? ((close - opend2) > 0 and (close - opend2) > 0.5 * (highd0 - lowd2))
                   : ((opend2 - close) > 0 and (opend2 - close) > 0.5 * (highd0 - lowd2))

        27  => dir ? ((close - opend2) > 0 and (close - opend2) < 0.5 * (highd0 - lowd2))
                   : ((opend2 - close) > 0 and (opend2 - close) < 0.5 * (highd0 - lowd2))

        28  => dir ? ((highd1 - closed1) < 0.20 * range1d)
                   : ((closed1 - lowd1)  < 0.20 * range1d)

        29  => dir ? (opend0 > (closed1 + closed1 * 0.25 * 0.01))
                   : (opend0 < (closed1 - closed1 * 0.25 * 0.01))

        30  => dir ? (opend0 > (closed1 + closed1 * 0.50 * 0.01))
                   : (opend0 < (closed1 - closed1 * 0.50 * 0.01))

        31  => dir ? (opend0 > (closed1 + closed1 * 0.75 * 0.01))
                   : (opend0 < (closed1 - closed1 * 0.75 * 0.01))

        32  => dir ? (body1d < 0.1 * range1d)
                   : (body1d > 0.1 * range1d)

        33  => dir ? (body1d < 0.25 * range1d)
                   : (body1d > 0.25 * range1d)

        34  => dir ? (body1d < 0.5 * range1d)
                   : (body1d > 0.5 * range1d)

        35  => dir ? (body1d < 0.75 * range1d)
                   : (body1d > 0.75 * range1d)

        36  => dir ? (body1d < 0.9 * range1d)
                   : (body1d > 0.9 * range1d)

        37  => dir ? (body5d < 0.1 * range5d)
                   : (body5d > 0.1 * range5d)

        38  => dir ? (body5d < 0.25 * range5d)
                   : (body5d > 0.25 * range5d)

        39  => dir ? (body5d < 0.5 * range5d)
                   : (body5d > 0.5 * range5d)

        40  => dir ? (body5d < 0.75 * range5d)
                   : (body5d > 0.75 * range5d)

        41  => dir ? (body5d < 0.9 * range5d)
                   : (body5d > 0.9 * range5d)

        42  => dir ? (opend0 > closed1)
                   : (opend0 < closed1)

        43  => dir ? (close > opend0 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)
                   : (close < opend0 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)

        44  => dir ? (close > opend1 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)
                   : (close < opend1 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)

        45  => dir ? (close > opend0 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)
                   : (close < opend0 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)

        46  => dir ? (close > opend1 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)
                   : (close < opend1 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)

        47  => dir ? (highd0 > highd1)
                   : (lowd0  < lowd1)

        48  => dir ? (lowd0  > lowd1)
                   : (highd0 < highd1)

        49  => dir ? (opend0 > highd1)
                   : (opend0 < lowd1)

        50  => dir ? (opend0 > lowd1)
                   : (opend0 < highd1)

        51  => dir ? (lowd0  > highd1)
                   : (highd0 < lowd1)

        52  => dir ? (highd0 > highd1 + (range1d / 2))
                   : (lowd0  < lowd1  - (range1d / 2))

        53  => dir ? (highd0 > highd2 + (rangeD2 / 2))
                   : (lowd0  < lowd2  - (rangeD2 / 2))

        54  => dir ? (lowd0  > lowd1 + (range1d / 2))
                   : (highd0 < highd1 - (range1d / 2))

        55  => dir ? (lowd0  > lowd2 + (rangeD2 / 2))
                   : (highd0 < highd2 - (rangeD2 / 2))

        56  => dir ? (highd0 > (highd1 + highd1 * 0.25 * 0.01))
                   : (lowd0  < (lowd1  - lowd1  * 0.25 * 0.01))

        57  => dir ? (highd0 > (highd1 + highd1 * 0.5 * 0.01))
                   : (lowd0  < (lowd1  - lowd1  * 0.5 * 0.01))

        58  => dir ? (highd0 > (highd1 + highd1 * 0.75 * 0.01))
                   : (lowd0  < (lowd1  - lowd1  * 0.75 * 0.01))

        59  => dir ? (highd0 > (highd1 + highd1 * 1.0 * 0.01))
                   : (lowd0  < (lowd1  - lowd1  * 1.0 * 0.01))

        60  => dir ? (highd0 > (highd1 + highd1 * 1.5 * 0.01))
                   : (lowd0  < (lowd1  - lowd1  * 1.5 * 0.01))

        61  => dir ? (lowd0  > (lowd1 + lowd1 * 0.5 * 0.01))
                   : (highd0 < (highd1 - highd1 * 0.5 * 0.01))

        62  => dir ? (lowd0  > (lowd1 + lowd1 * 1.0 * 0.01))
                   : (highd0 < (highd1 - highd1 * 1.0 * 0.01))

        63  => dir ? (lowd0  > (lowd1 + lowd1 * 1.5 * 0.01))
                   : (highd0 < (highd1 - highd1 * 1.5 * 0.01))

        64  => dir ? (lowd0  > (lowd1 + lowd1 * 2.0 * 0.01))
                   : (highd0 < (highd1 - highd1 * 2.0 * 0.01))

        65  => dir ? (lowd0  > (lowd1 + lowd1 * 2.5 * 0.01))
                   : (highd0 < (highd1 - highd1 * 2.5 * 0.01))

        66  => dir ? (highd0 > highd1 and highd0 > highd2 and highd0 > highd3)
                   : (lowd0  < lowd1  and lowd0  < lowd2  and lowd0  < lowd3)

        67  => dir ? (close > closed1 and close > closed2 and close > closed3)
                   : (close < closed1 and close < closed2 and close < closed3)

        68  => dir ? (highd0 > HighestH)
                   : (lowd0  < LowestL)

        69  => dir ? (highd0 > HighestC)
                   : (lowd0  < LowestC)

        70  => dir ? (close > HighestC)
                   : (close < LowestC)

        71  => dir ? (opend0 > HighestO)
                   : (opend0 < LowestO)

        72  => dir ? (lowd0 > HighestL)
                   : (highd0 < LowestH)

        73  => dir ? (close > LowestH)
                   : (close < HighestL)

        74  => dir ? (highd0 < highd1 and lowd0 > lowd1)
                   : (highd0 > highd1 and lowd0 < lowd1)

        75  => dir ? (range1d < (((highd2 - lowd2) + (highd3 - lowd3)) / 3.0))
                   : (range1d > (((highd2 - lowd2) + (highd3 - lowd3)) / 3.0))

        76  => dir ? (range1d < (highd2 - lowd2) and (highd2 - lowd2) < (highd3 - lowd3))
                   : (range1d > (highd2 - lowd2) and (highd2 - lowd2) > (highd3 - lowd3))

        77  => dir ? (highd2 > highd1 and lowd2 < lowd1)
                   : (highd2 < highd1 and lowd2 > lowd1)

        78  => dir ? (highd1 < highd2 and lowd1 > lowd2)
                   : (highd1 > highd2 and lowd1 < lowd2)

        79  => dir ? (highd1 < highd2 or lowd1 > lowd2)
                   : (highd1 > highd2 or lowd1 < lowd2)

        80  => dir ? (highd2 < highd1 and lowd2 > lowd1)
                   : (highd2 > highd1 and lowd2 < lowd1)

        81  => dir ? (highd0 > highd1 and lowd0 < lowd1)
                   : (highd0 < highd1 and lowd0 > lowd1)

        82  => dir ? (closed1 > closed2 and closed2 > closed3 and closed3 > closed4)
                   : (closed1 < closed2 and closed2 < closed3 and closed3 < closed4)

        83  => dir ? (closed1 > closed2 and closed2 > closed3 and closed3 > closed4 and closed4 > closed5)
                   : (closed1 < closed2 and closed2 < closed3 and closed3 < closed4 and closed4 < closed5)

        84  => dir ? (closed1 > (closed2 + closed2 * 0.5 * 0.01))
                   : (closed1 < (closed2 - closed2 * 0.5 * 0.01))

        85  => dir ? (closed1 > (closed2 + closed2 * 1.0 * 0.01))
                   : (closed1 < (closed2 - closed2 * 1.0 * 0.01))

        86  => dir ? (closed1 > (closed2 + closed2 * 1.5 * 0.01))
                   : (closed1 < (closed2 - closed2 * 1.5 * 0.01))

        87  => dir ? (closed1 > (closed2 + closed2 * 2.0 * 0.01))
                   : (closed1 < (closed2 - closed2 * 2.0 * 0.01))

        88  => dir ? (closed1 > (closed2 + closed2 * 2.5 * 0.01))
                   : (closed1 < (closed2 - closed2 * 2.5 * 0.01))

        89  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.25))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.25))

        90  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.5))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.5))

        91  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.75))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.75))

        92  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 1.0))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 1.0))

        93  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 1.5))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 1.5))

        94  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 2.0))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 2.0))

        95  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 2.5))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 2.5))

        96  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 3.0))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 3.0))

        97  => dir ? ((highd0 - opend0) < (highd1 - opend1))
                   : ((opend0 - lowd0)  < (opend1 - lowd1))

        98  => dir ? (highd1 > highd2 and lowd1 > lowd2)
                   : (highd1 < highd2 and lowd1 < lowd2)

        99  => dir ? (highd1 > highd5)
                   : (lowd1  < lowd5)

        100 => dir ? (highd1 < highd5)
                   : (lowd1  > lowd5)

        101 => dir ? (highd1 > highd2)
                   : (lowd1  < lowd2)

        102 => dir ? (lowd1  > lowd2)
                   : (highd1 < highd2)

        103 => dir ? (closed1 > opend0)
                   : (closed1 < opend0)

        104 => dir ? (closed1 > opend1)
                   : (closed1 < opend1)

        105 => dir ? (closed1 > opend2)
                   : (closed1 < opend2)

        106 => dir ? (closed1 > highd1)
                   : (closed1 < lowd1)

        107 => dir ? (closed1 > highd2)
                   : (closed1 < lowd2)

        108 => dir ? (closed1 > closed2)
                   : (closed1 < closed2)

        109 => dir ? ((closed1 - opend0) > 0 and (closed1 - opend0) > 0.25 * (highd1 - lowd0))
                   : ((opend0 - closed1) > 0 and (opend0 - closed1) > 0.25 * (highd1 - lowd0))

        110 => dir ? ((closed1 - opend2) > 0 and (closed1 - opend2) > 0.25 * (highd1 - lowd2))
                   : ((opend2 - closed1) > 0 and (opend2 - closed1) > 0.25 * (highd1 - lowd2))

        111 => dir ? ((closed1 - opend0) > 0 and (closed1 - opend0) < 0.75 * (highd1 - lowd0))
                   : ((opend0 - closed1) > 0 and (opend0 - closed1) < 0.75 * (highd1 - lowd0))

        112 => dir ? ((closed1 - opend2) > 0 and (closed1 - opend2) < 0.75 * (highd1 - lowd2))
                   : ((opend2 - closed1) > 0 and (opend2 - closed1) < 0.75 * (highd1 - lowd2))

        113 => dir ? (highd1 > highd2 and highd1 > highd3 and highd1 > highd4)
                   : (lowd1  < lowd2  and lowd1  < lowd3  and lowd1  < lowd4)

        114 => dir ? (closed1 > closed2 and closed1 > closed3 and closed1 > closed4)
                   : (closed1 < closed2 and closed1 < closed3 and closed1 < closed4)

        115 => dir ? (lowd1  > closed2)
                   : (highd1 < closed2)

        116 => dir ? (highd1 > closed2)
                   : (lowd1  < closed2)

        117 => dir ? (lowd1  > highd0)
                   : (highd1 < lowd0)

        118 => dir ? (lowd1  > highd2)
                   : (highd1 < lowd2)

        119 => dir ? (opend1 > closed2)
                   : (opend1 < closed2)

        120 => dir ? (opend1 > highd2)
                   : (opend1 < lowd2)

        121 => dir ? (opend1 > lowd2)
                   : (opend1 < highd2)

        122 => dir ? (closed1 > opend0 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)
                   : (closed1 < opend0 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)

        123 => dir ? (closed1 > opend1 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)
                   : (closed1 < opend1 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)

        124 => dir ? (closed1 > opend2 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)
                   : (closed1 < opend2 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)

        125 => dir ? (closed1 > opend0 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)
                   : (closed1 < opend0 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)

        126 => dir ? (closed1 > opend1 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)
                   : (closed1 < opend1 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)

        127 => dir ? (closed1 > opend2 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)
                   : (closed1 < opend2 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)

        128 => dir ? (highd1 == HighestH)
                   : (lowd1  == LowestL)

        129 => dir ? (closed1 == HighestC)
                   : (closed1 == LowestC)

        130 => dir ? (opend1 == HighestO)
                   : (opend1 == LowestO)

        131 => dir ? (highd1 > HighestC)
                   : (lowd1  < LowestC)

        132 => dir ? (lowd1  > LowestH)
                   : (highd1 < HighestL)

        133 => dir ? (closed1 > LowestH)
                   : (closed1 < HighestL)

        134 => dir ? (closed1 > closed2 and lowd1 > lowd2)
                   : (closed1 < closed2 and highd1 < highd2)

        135 => dir ? (closed1 > opend2 and lowd1 > lowd2)
                   : (closed1 < opend2 and highd1 < highd2)

        136 => dir ? (closed1 > opend1 and closed2 > opend2)
                   : (closed1 < opend1 and closed2 < opend2)

        137 => dir ? (closed1 > opend1 and range1d > rangeD0)
                   : (closed1 < opend1 and range1d > rangeD0)

        138 => dir ? (closed1 > opend1 and range1d > rangeD2)
                   : (closed1 < opend1 and range1d > rangeD2)

        139 => dir ? (closed1 > opend1 and range1d < rangeD0)
                   : (closed1 < opend1 and range1d < rangeD0)

        140 => dir ? (closed1 > opend1 and range1d < rangeD2)
                   : (closed1 < opend1 and range1d < rangeD2)

        141 => dir ? (closed2 > opend2)
                   : (closed2 < opend2)

        142 => dir ? (closed2 > opend1)
                   : (closed2 < opend1)

        143 => dir ? (closed2 > highd0)
                   : (closed2 < lowd0)

        144 => dir ? (closed2 > highd1)
                   : (closed2 < lowd1)

        145 => dir ? (closed2 > closed1)
                   : (closed2 < closed1)

        146 => dir ? (highd2 > highd0)
                   : (lowd2  < lowd0)

        147 => dir ? (highd2 > highd1)
                   : (lowd2  < lowd1)

        148 => dir ? (lowd2  > lowd0)
                   : (highd2 < highd0)

        149 => dir ? (lowd2  > lowd1)
                   : (highd2 < highd1)

        150 => dir ? ((closed2 - opend0) > 0 and (closed2 - opend0) > 0.25 * (highd2 - lowd0))
                   : ((opend0 - closed2) > 0 and (opend0 - closed2) > 0.25 * (highd2 - lowd0))

        151 => dir ? ((closed2 - opend1) > 0 and (closed2 - opend1) > 0.25 * (highd2 - lowd1))
                   : ((opend1 - closed2) > 0 and (opend1 - closed2) > 0.25 * (highd2 - lowd1))

        152 => dir ? ((closed2 - opend2) > 0 and (closed2 - opend2) > 0.25 * rangeD2)
                   : ((opend2 - closed2) > 0 and (opend2 - closed2) > 0.25 * rangeD2)

        153 => dir ? ((closed2 - opend0) > 0 and (closed2 - opend0) < 0.75 * (highd2 - lowd0))
                   : ((opend0 - closed2) > 0 and (opend0 - closed2) < 0.75 * (highd2 - lowd0))

        154 => dir ? ((closed2 - opend1) > 0 and (closed2 - opend1) < 0.75 * (highd2 - lowd1))
                   : ((opend1 - closed2) > 0 and (opend1 - closed2) < 0.75 * (highd2 - lowd1))

        155 => dir ? ((closed2 - opend2) > 0 and (closed2 - opend2) < 0.75 * rangeD2)
                   : ((opend2 - closed2) > 0 and (opend2 - closed2) < 0.75 * rangeD2)

        156 => dir ? (highd2 > highd3 and highd2 > highd4 and highd2 > highd5)
                   : (lowd2  < lowd3  and lowd2  < lowd4  and lowd2  < lowd5)

        157 => dir ? (closed2 > closed3 and closed2 > closed4 and closed2 > closed5)
                   : (closed2 < closed3 and closed2 < closed4 and closed2 < closed5)

        158 => dir ? (lowd2  > closed1)
                   : (highd2 < closed1)

        159 => dir ? (highd2 > closed1)
                   : (lowd2  < closed1)

        160 => dir ? (lowd2  > highd0)
                   : (highd2 < lowd0)

        => false

    res

ZPattern_Mir_161_320(int pattern, array<float> FT_OHLC, array<float> PtnCtx) =>
    // Guard rails 
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")

    // OHLC day/session 
    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)

    // Load pre-calcs
    int   barcount = int(nz(array.get(PtnCtx, 0), 0))

    float body1d   = array.get(PtnCtx, 1)
    float range1d  = array.get(PtnCtx, 2)
    float body5d   = array.get(PtnCtx, 3)
    float range5d  = array.get(PtnCtx, 4)

    float HighestO = array.get(PtnCtx, 5)
    float LowestO  = array.get(PtnCtx, 6)
    float HighestH = array.get(PtnCtx, 7)
    float LowestH  = array.get(PtnCtx, 8)
    float HighestL = array.get(PtnCtx, 9)
    float LowestL  = array.get(PtnCtx, 10)
    float HighestC = array.get(PtnCtx, 11)
    float LowestC  = array.get(PtnCtx, 12)

    float rangeD0  = array.get(PtnCtx, 13)
    float rangeD1  = array.get(PtnCtx, 14)
    float rangeD2  = array.get(PtnCtx, 15)
    float rangeD3  = array.get(PtnCtx, 16)
    float rangeD4  = array.get(PtnCtx, 17)
    float rangeD5  = array.get(PtnCtx, 18)

    float bodyD0   = array.get(PtnCtx, 19)
    float bodyD1   = array.get(PtnCtx, 20)
    float bodyD2   = array.get(PtnCtx, 21)
    float bodyD3   = array.get(PtnCtx, 22)
    float bodyD4   = array.get(PtnCtx, 23)
    float bodyD5   = array.get(PtnCtx, 24)

    float MaxCO    = array.get(PtnCtx, 30)
    float MinOC    = array.get(PtnCtx, 31)

    // Session-start bar 
    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)

    // Per-bar range 
    float rng0 = high - low

    // Switch patterns
    p = math.abs(pattern)
    dir = pattern > 0


    bool res = switch p

        161 => dir ? (lowd2  > highd1)
                   : (highd2 < lowd1)

        162 => dir ? (opend2 > closed1)
                   : (opend2 < closed1)

        163 => dir ? (opend2 > closed2)
                   : (opend2 < closed2)

        164 => dir ? (opend2 > highd0)
                   : (opend2 < lowd0)

        165 => dir ? (opend2 > highd1)
                   : (opend2 < lowd1)

        166 => dir ? (opend2 > lowd0)
                   : (opend2 < highd0)

        167 => dir ? (opend2 > lowd1)
                   : (opend2 < highd1)

        168 => dir ? (closed2 > opend0 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)
                   : (closed2 < opend0 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)

        169 => dir ? (closed2 > opend1 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)
                   : (closed2 < opend1 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)

        170 => dir ? (closed2 > opend2 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)
                   : (closed2 < opend2 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)

        171 => dir ? (closed2 > opend0 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)
                   : (closed2 < opend0 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)

        172 => dir ? (closed2 > opend1 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)
                   : (closed2 < opend1 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)

        173 => dir ? (closed2 > opend2 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)
                   : (closed2 < opend2 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)

        174 => dir ? (highd2 == HighestH)
                   : (lowd2  == LowestL)

        175 => dir ? (closed2 == HighestC)
                   : (closed2 == LowestC)

        176 => dir ? (opend2 == HighestO)
                   : (opend2 == LowestO)

        177 => dir ? (highd2 > HighestC)
                   : (lowd2  < LowestC)

        178 => dir ? (lowd2  > LowestH)
                   : (highd2 < HighestL)

        179 => dir ? (closed2 > LowestH)
                   : (closed2 < HighestL)

        180 => dir ? (closed2 > closed1 and lowd2 > lowd1)
                   : (closed2 < closed1 and highd2 < highd1)

        181 => dir ? (closed2 > opend0 and lowd2 > lowd0)
                   : (closed2 < opend0 and highd2 < highd0)

        182 => dir ? (closed2 > opend1 and lowd2 > lowd1)
                   : (closed2 < opend1 and highd2 < highd1)

        183 => dir ? (closed2 > opend2 and closed3 > opend3)
                   : (closed2 < opend2 and closed3 < opend3)

        184 => dir ? (closed2 > opend2 and rangeD2 > rangeD0)
                   : (closed2 < opend2 and rangeD2 > rangeD0)

        185 => dir ? (closed2 > opend2 and rangeD2 > range1d)
                   : (closed2 < opend2 and rangeD2 > range1d)

        186 => dir ? (closed2 > opend2 and rangeD2 < rangeD0)
                   : (closed2 < opend2 and rangeD2 < rangeD0)

        187 => dir ? (closed2 > opend2 and rangeD2 < range1d)
                   : (closed2 < opend2 and rangeD2 < range1d)

        188 => dir ? ((closed1 - opend5) > 0 and body5d > 0.5 * range5d)
                   : ((closed1 - opend5) < 0 and body5d > 0.5 * range5d)

        189 => dir ? ((closed1 - opend5) > 0 and body5d < 0.5 * range5d)
                   : ((closed1 - opend5) < 0 and body5d < 0.5 * range5d)

        190 => dir ? ((HighestH - closed1) < (opend5 - LowestL))
                   : ((opend5 - LowestL) < (HighestH - closed1))

        191 => dir ? ((HighestH - MaxCO) < (MinOC - LowestL))
                   : ((HighestH - MaxCO) > (MinOC - LowestL))

        192 => dir ? ((HighestH - closed1) < (closed1 - LowestL))
                   : ((HighestH - closed1) > (closed1 - LowestL))

        193 => dir ? (closed1 > (LowestL + (HighestH - LowestL) / 2))
                   : (closed1 < (LowestL + (HighestH - LowestL) / 2))

        194 => dir ? ((opend5 - LowestL) > 0.75 * (HighestH - LowestL))
                   : ((HighestH - closed1) > 0.75 * (HighestH - LowestL))

        195 => dir ? (math.abs(opend1 - closed1) > 0.25 * (highd1 - lowd1))
                   : (math.abs(opend1 - closed1) < 0.25 * (highd1 - lowd1))

        196 => dir ? (math.abs(opend1 - closed1) > 0.50 * (highd1 - lowd1))
                   : (math.abs(opend1 - closed1) < 0.50 * (highd1 - lowd1))

        197 => dir ? (math.abs(opend1 - closed1) > 0.75 * (highd1 - lowd1))
                   : (math.abs(opend1 - closed1) < 0.75 * (highd1 - lowd1))

        198 => dir ? (math.abs(opend1 - closed1) > 0.90 * (highd1 - lowd1))
                   : (math.abs(opend1 - closed1) < 0.90 * (highd1 - lowd1))

        199 => dir ? (open > strategy.position_avg_price and close < ta.sma(close, 30))
                   : (open < strategy.position_avg_price and close > ta.sma(close, 30))

        200 => dir ? (math.abs(opend5 - closed1) > 0.25 * (HighestH - LowestL))
                   : (math.abs(opend5 - closed1) < 0.25 * (HighestH - LowestL))


        201 => dir ? (math.abs(opend5 - closed1) > 0.50 * (HighestH - LowestL))
                   : (math.abs(opend5 - closed1) < 0.50 * (HighestH - LowestL))

        202 => dir ? (math.abs(opend5 - closed1) > 0.75 * (HighestH - LowestL))
                   : (math.abs(opend5 - closed1) < 0.75 * (HighestH - LowestL))

        203 => dir ? (math.abs(opend5 - closed1) > 0.90 * (HighestH - LowestL))
                   : (math.abs(opend5 - closed1) < 0.90 * (HighestH - LowestL))

        204 => dir ? (highd0 < (lowd0 + lowd0 * 0.50 * 0.01))
                   : (lowd0  > (highd0 - highd0 * 0.50 * 0.01))

        205 => dir ? (highd0 < (lowd0 + lowd0 * 1 * 0.01))
                   : (lowd0  > (highd0 - highd0 * 1 * 0.01))

        206 => dir ? (highd0 < (lowd0 + lowd0 * 1.50 * 0.01))
                   : (lowd0  > (highd0 - highd0 * 1.50 * 0.01))

        207 => dir ? (highd0 < (lowd0 + lowd0 * 2 * 0.01))
                   : (lowd0  > (highd0 - highd0 * 2 * 0.01))

        208 => dir ? (highd0 < (lowd0 + lowd0 * 3 * 0.01))
                   : (lowd0  > (highd0 - highd0 * 3 * 0.01))

        209 => dir ? (highd0 > (lowd0 + lowd0 * 0.50 * 0.01))
                   : (lowd0  < (highd0 - highd0 * 0.50 * 0.01))

        210 => dir ? (highd0 > (lowd0 + lowd0 * 1 * 0.01))
                   : (lowd0  < (highd0 - highd0 * 1 * 0.01))

        211 => dir ? (highd0 > (lowd0 + lowd0 * 1.50 * 0.01))
                   : (lowd0  < (highd0 - highd0 * 1.50 * 0.01))

        212 => dir ? (highd0 > (lowd0 + lowd0 * 2 * 0.01))
                   : (lowd0  < (highd0 - highd0 * 2 * 0.01))

        213 => dir ? (highd0 > (lowd0 + lowd0 * 3 * 0.01))
                   : (lowd0  < (highd0 - highd0 * 3 * 0.01))

        214 => dir ? (lowd1 > lowd2 and lowd1 > lowd3 and lowd1 > lowd4)
                   : (lowd1 < lowd2 and lowd1 < lowd3 and lowd1 < lowd4)

        215 => dir ? (closed1 < closed2 and closed2 < closed3 and opend0 < closed1)
                   : (closed1 > closed2 and closed2 > closed3 and opend0 > closed1)

        216 => dir ? (close < highd1)
                   : (close > highd1)

        217 => dir ? (close < lowd1)
                   : (close > lowd1)

        218 => dir ? (highd0 < (highd1 + highd1 * 0.50 * 0.01))
                   : (lowd0  > (lowd1  - lowd1  * 0.50 * 0.01))

        219 => dir ? (highd0 < (highd1 + highd1 * 1 * 0.01))
                   : (lowd0  > (lowd1  - lowd1  * 1 * 0.01))

        220 => dir ? (highd0 < (highd1 + highd1 * 1.50 * 0.01))
                   : (lowd0  > (lowd1  - lowd1  * 1.50 * 0.01))

        221 => dir ? (highd0 < (highd1 + highd1 * 2 * 0.01))
                   : (lowd0  > (lowd1  - lowd1  * 2 * 0.01))

        222 => dir ? (highd0 < (highd1 + highd1 * 3 * 0.01))
                   : (lowd0  > (lowd1  - lowd1  * 3 * 0.01))

        223 => dir ? (highd0 > (highd1 - highd1 * 0.50 * 0.01))
                   : (lowd0  < (lowd1  + lowd1  * 0.50 * 0.01))

        224 => dir ? (highd0 > (highd1 - highd1 * 1 * 0.01))
                   : (lowd0  < (lowd1  + lowd1  * 1 * 0.01))

        225 => dir ? (highd0 > (highd1 - highd1 * 1.50 * 0.01))
                   : (lowd0  < (lowd1  + lowd1  * 1.50 * 0.01))

        226 => dir ? (highd0 > (highd1 - highd1 * 2 * 0.01))
                   : (lowd0  < (lowd1  + lowd1  * 2 * 0.01))

        227 => dir ? (highd0 > (highd1 - highd1 * 3 * 0.01))
                   : (lowd0  < (lowd1  + lowd1  * 3 * 0.01))

        228 => dir ? (math.abs(opend5 - closed1) > 0.50 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 0.50 * (highd5 - lowd1))

        229 => dir ? (math.abs(opend5 - closed1) > 0.75 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 0.75 * (highd5 - lowd1))

        230 => dir ? (math.abs(opend5 - closed1) > 1 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 1 * (highd5 - lowd1))

        231 => dir ? (math.abs(opend5 - closed1) > 1.50 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 1.50 * (highd5 - lowd1))

        232 => dir ? (close > open)
                   : (close < open)

        233 => dir ? (math.abs(opend1 - closed1) > 0.1 * (highd1 - lowd1))
                   : (math.abs(opend1 - closed1) < 0.1 * (highd1 - lowd1))

        234 => dir ? ((highd1 - lowd1) > (highd2 - lowd2))
                   : ((highd1 - lowd1) < (highd2 - lowd2))

        235 => dir ? (closed1 > highd5)
                   : (closed1 < lowd5)

        236 => dir ? (lowd0 > closed3)
                   : (highd0 < closed3)

        237 => dir ? ((opend0 < lowd1) or (opend0 > highd1))
                   : ((opend0 > lowd1) or (opend0 < highd1))

        238 => dir ? (lowd1 > LowestH)
                   : (highd1 < HighestL)

        239 => dir ? (closed2 - opend3 > 0 and closed2 - opend3 < 0.75 * (highd2 - lowd3))
                   : (opend3 - closed2 > 0 and opend3 - closed2 < 0.75 * (highd2 - lowd3))

        240 => dir ? (math.abs(opend5 - closed1) > 0.1 * (HighestH - LowestL))
                   : (math.abs(opend5 - closed1) < 0.1 * (HighestH - LowestL))

        241 => dir ? (math.abs(opend1 - closed1) > 0.1 * (highd1 - lowd1))
                   : (math.abs(opend1 - closed1) < 0.1 * (highd1 - lowd1))

        242 => dir ? ((close - opend1) > 0 and (close - opend1) > 0.7 * (highd0 - lowd1))
                   : ((opend1 - close) > 0 and (opend1 - close) > 0.7 * (highd0 - lowd1))

        243 => dir ? (closed1 > opend1 and rangeD1 > rangeD4)
                   : (closed1 < opend1 and rangeD1 > rangeD4)

        244 => dir ? (closed1 < closed2 and (closed1 - lowd1) > 0.14 * rangeD1)
                   : (closed1 > closed2 and (highd1 - closed1) > 0.14 * rangeD1)

        245 => dir ? (lowd0 > lowd1)
                   : (lowd0 < lowd1)

        246 => dir ? (lowd0 > lowd1 + (rangeD1 / 2))
                   : (highd0 < highd1 - (rangeD1 / 2))

        247 => dir ? (highd1 > highd2 and highd1 > highd3)
                   : (lowd1 < lowd2 and lowd1 < lowd3)

        248 => dir ? (math.abs(opend5 - closed1) > 0.1 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 0.1 * (highd5 - lowd1))

        249 => dir ? (barcount > 3 and (close[1] < opend0 and close > opend0))
                   : (barcount > 3 and (close[1] >= opend0 and close < opend0))

        250 => dir ? (closed1 - opend5 > 0 and closed1 - opend5 > 0.50 * (highd1 - lowd5))
                   : (opend5 - closed1 > 0 and opend5 - closed1 > 0.50 * (highd1 - lowd5))

        251 => dir ? (closed2 - opend5 > 0 and closed2 - opend5 > 0.50 * (highd2 - lowd5))
                   : (opend5 - closed2 > 0 and opend5 - closed2 > 0.50 * (highd2 - lowd5))

        252 => dir ? (closed3 - opend5 > 0 and closed3 - opend5 > 0.50 * (highd3 - lowd5))
                   : (opend5 - closed3 > 0 and opend5 - closed3 > 0.50 * (highd3 - lowd5))

        253 => dir ? (closed4 - opend5 > 0 and closed4 - opend5 > 0.50 * (highd4 - lowd5))
                   : (opend5 - closed4 > 0 and opend5 - closed4 > 0.50 * (highd4 - lowd5))

        254 => dir ? (closed5 - opend5 > 0 and closed5 - opend5 > 0.50 * (highd5 - lowd5))
                   : (opend5 - closed5 > 0 and opend5 - closed5 > 0.50 * (highd5 - lowd5))

        255 => dir ? (closed1 - opend5 > 0 and closed1 - opend5 < 0.50 * (highd1 - lowd5))
                   : (opend5 - closed1 > 0 and opend5 - closed1 < 0.50 * (highd1 - lowd5))

        256 => dir ? (closed2 - opend5 > 0 and closed2 - opend5 < 0.50 * (highd2 - lowd5))
                   : (opend5 - closed2 > 0 and opend5 - closed2 < 0.50 * (highd2 - lowd5))

        257 => dir ? (closed3 - opend5 > 0 and closed3 - opend5 < 0.50 * (highd3 - lowd5))
                   : (opend5 - closed3 > 0 and opend5 - closed3 < 0.50 * (highd3 - lowd5))

        258 => dir ? (closed4 - opend5 > 0 and closed4 - opend5 < 0.50 * (highd4 - lowd5))
                   : (opend5 - closed4 > 0 and opend5 - closed4 < 0.50 * (highd4 - lowd5))

        259 => dir ? (closed5 - opend5 > 0 and closed5 - opend5 < 0.50 * (highd5 - lowd5))
                   : (opend5 - closed5 > 0 and opend5 - closed5 < 0.50 * (highd5 - lowd5))

        260 => dir ? (close > open and (high - low) > AvgTrueRange(45) * 2)
                   : (close < open and (high - low) > AvgTrueRange(45) * 2)

        261 => dir ? (close > opend2)
                   : (close < opend2)

        262 => dir ? (close > opend3)
                   : (close < opend3)

        263 => dir ? (close > opend4)
                   : (close < opend4)

        264 => dir ? (close > opend5)
                   : (close < opend5)

        265 => dir ? (close > highd3)
                   : (close < highd3)

        266 => dir ? (close > highd4)
                   : (close < highd4)

        267 => dir ? (close > highd5)
                   : (close < highd5)

        268 => dir ? (close > closed2)
                   : (close < closed2)

        269 => dir ? (close > closed3)
                   : (close < closed3)

        270 => dir ? (close > closed4)
                   : (close < closed4)

        271 => dir ? (close > closed5)
                   : (close < closed5)

        272 => dir ? (barcount > 3 and close[1] < sessStartLow[1]  and close > sessStartLow)
                   : (barcount > 3 and close[1] >= sessStartHigh[1] and close < sessStartHigh)

        273 => dir ? (barcount > 3 and (highd0 > (sessStartHigh + sessStartRange)))
                   : (barcount > 3 and (lowd0  < (sessStartLow  - sessStartRange)))

        274 => dir ? (close > closed0)
                   : (close < closed0)

        275 => dir ? (highd0 > highd2)
                   : (lowd0  < lowd2)

        276 => dir ? (highd0 > highd3)
                   : (lowd0  < lowd3)

        277 => dir ? (highd0 > highd4)
                   : (lowd0  < lowd4)

        278 => dir ? (highd0 > highd5)
                   : (lowd0  < lowd5)

        // PL D0 case 14
        279 => dir ? (lowd0 > lowd2)
                   : (highd0 < highd2)

        280 => dir ? (lowd0 > lowd3)
                   : (highd0 < highd3)

        281 => dir ? (lowd0 > lowd4)
                   : (highd0 < highd4)

        282 => dir ? (lowd0 > lowd5)
                   : (highd0 < highd5)

        283 => dir ? ((close - opend3) > 0 and (close - opend3) > (highd0 - lowd3) * 0.5)
                   : ((opend3 - close) > 0 and (opend3 - close) > (highd0 - lowd3) * 0.5)

        284 => dir ? ((close - opend4) > 0 and (close - opend4) > (highd0 - lowd4) * 0.5)
                   : ((opend4 - close) > 0 and (opend4 - close) > (highd0 - lowd4) * 0.5)

        285 => dir ? ((close - opend5) > 0 and (close - opend5) > (highd0 - lowd5) * 0.5)
                   : ((opend5 - close) > 0 and (opend5 - close) > (highd0 - lowd5) * 0.5)

        // PL D0 case 16 (versione "< 0.5 * ...")
        286 => dir ? ((close - opend3) > 0 and (close - opend3) < (highd0 - lowd3) * 0.5)
                   : ((opend3 - close) > 0 and (opend3 - close) < (highd0 - lowd3) * 0.5)

        287 => dir ? ((close - opend4) > 0 and (close - opend4) < (highd0 - lowd4) * 0.5)
                   : ((opend4 - close) > 0 and (opend4 - close) < (highd0 - lowd4) * 0.5)

        288 => dir ? ((close - opend5) > 0 and (close - opend5) < (highd0 - lowd5) * 0.5)
                   : ((opend5 - close) > 0 and (opend5 - close) < (highd0 - lowd5) * 0.5)

        289 => dir ? (lowd0 > closed1)
                   : (highd0 < closed1)

        290 => dir ? (lowd0 > closed2)
                   : (highd0 < closed2)

        291 => dir ? (lowd0 > closed4)
                   : (highd0 < closed4)

        292 => dir ? (lowd0 > closed5)
                   : (highd0 < closed5)

        293 => dir ? (lowd0 > highd2)
                   : (highd0 < lowd2)

        294 => dir ? (lowd0 > highd3)
                   : (highd0 < lowd3)

        295 => dir ? (lowd0 > highd4)
                   : (highd0 < lowd4)

        296 => dir ? (lowd0 > highd5)
                   : (highd0 < lowd5)

        297 => dir ? (highd0 > closed1)
                   : (lowd0  < closed1)

        298 => dir ? (highd0 > closed2)
                   : (lowd0  < closed2)

        299 => dir ? (highd0 > closed3)
                   : (lowd0  < closed3)

        300 => dir ? (highd0 > closed4)
                   : (lowd0  < closed4)

        301 => dir ? (highd0 > closed5)
                   : (lowd0  < closed5)

        302 => dir ? (opend0 > closed0)
                   : (opend0 < closed0)

        303 => dir ? (opend0 > closed2)
                   : (opend0 < closed2)

        304 => dir ? (opend0 > closed3)
                   : (opend0 < closed3)

        305 => dir ? (opend0 > closed4)
                   : (opend0 < closed4)

        306 => dir ? (opend0 > closed5)
                   : (opend0 < closed5)

        307 => dir ? (opend0 > highd2)
                   : (opend0 < lowd2)

        308 => dir ? (opend0 > highd3)
                   : (opend0 < lowd3)

        309 => dir ? (opend0 > highd4)
                   : (opend0 < lowd4)

        310 => dir ? (opend0 > highd5)
                   : (opend0 < lowd5)

        311 => dir ? (opend0 > lowd0)
                   : (opend0 < highd0)

        312 => dir ? (opend0 > lowd2)
                   : (opend0 < highd2)

        313 => dir ? (opend0 > lowd3)
                   : (opend0 < highd3)

        314 => dir ? (opend0 > lowd4)
                   : (opend0 < highd4)

        315 => dir ? (opend0 > lowd5)
                   : (opend0 < highd5)

        316 => dir ? (close > opend2 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)
                   : (close < opend2 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)

        317 => dir ? (close > opend3 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)
                   : (close < opend3 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)

        318 => dir ? (close > opend4 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)
                   : (close < opend4 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)

        319 => dir ? (close > opend5 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)
                   : (close < opend5 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5)

        320 => dir ? (close > opend2 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)
                   : (close < opend2 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)


        => false

    res


ZPattern_Mir_321_478(int pattern, array<float> FT_OHLC, array<float> PtnCtx) =>
    // Guard rails
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")

    // OHLC day/session 
    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)

    // Load pre-calcs
    int   barcount = int(nz(array.get(PtnCtx, 0), 0))

    float body1d   = array.get(PtnCtx, 1)
    float range1d  = array.get(PtnCtx, 2)
    float body5d   = array.get(PtnCtx, 3)
    float range5d  = array.get(PtnCtx, 4)

    float HighestO = array.get(PtnCtx, 5)
    float LowestO  = array.get(PtnCtx, 6)
    float HighestH = array.get(PtnCtx, 7)
    float LowestH  = array.get(PtnCtx, 8)
    float HighestL = array.get(PtnCtx, 9)
    float LowestL  = array.get(PtnCtx, 10)
    float HighestC = array.get(PtnCtx, 11)
    float LowestC  = array.get(PtnCtx, 12)

    float rangeD0  = array.get(PtnCtx, 13)
    float rangeD1  = array.get(PtnCtx, 14)
    float rangeD2  = array.get(PtnCtx, 15)
    float rangeD3  = array.get(PtnCtx, 16)
    float rangeD4  = array.get(PtnCtx, 17)
    float rangeD5  = array.get(PtnCtx, 18)

    float bodyD0   = array.get(PtnCtx, 19)
    float bodyD1   = array.get(PtnCtx, 20)
    float bodyD2   = array.get(PtnCtx, 21)
    float bodyD3   = array.get(PtnCtx, 22)
    float bodyD4   = array.get(PtnCtx, 23)
    float bodyD5   = array.get(PtnCtx, 24)

    float MaxCO    = array.get(PtnCtx, 30)
    float MinOC    = array.get(PtnCtx, 31)

    // Session-start bar 
    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)

    // Per-bar range
    float rng0 = high - low

    // Switch patterns
    p = math.abs(pattern)
    dir = pattern > 0


    bool res = switch p

        321 => dir ? (close > opend3 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)
                   : (close < opend3 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)

        322 => dir ? (close > opend4 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)
                   : (close < opend4 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)

        323 => dir ? (close > opend5 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)
                   : (close < opend5 and bodyD0 > bodyD1 and bodyD0 > bodyD2 and bodyD0 > bodyD3 and bodyD0 > bodyD4 and bodyD0 > bodyD5)

        324 => dir ? (close[1] < highd2[1] and close > highd2)
                   : (close[1] >= lowd2[1] and close < lowd2)

        325 => dir ? (close[1] < highd3[1] and close > highd3)
                   : (close[1] >= lowd3[1] and close < lowd3)

        326 => dir ? (close[1] < highd4[1] and close > highd4)
                   : (close[1] >= lowd4[1] and close < lowd4)

        327 => dir ? (close[1] < highd5[1] and close > highd5)
                   : (close[1] >= lowd5[1] and close < lowd5)

        328 => dir ? (close[1] < closed2[1] and close > closed2)
                   : (close[1] >= closed2[1] and close < closed2)

        329 => dir ? (close[1] < closed3[1] and close > closed3)
                   : (close[1] >= closed3[1] and close < closed3)

        330 => dir ? (close[1] < closed4[1] and close > closed4)
                   : (close[1] >= closed4[1] and close < closed4)

        331 => dir ? (close[1] < closed5[1] and close > closed5)
                   : (close[1] >= closed5[1] and close < closed5)

        332 => dir ? (highd0 > (highd3 + rangeD3 * 0.5))
                   : (lowd0  < (lowd3  - rangeD3 * 0.5))

        333 => dir ? (highd0 > (highd4 + rangeD4 * 0.5))
                   : (lowd0  < (lowd4  - rangeD4 * 0.5))

        334 => dir ? (highd0 > (highd5 + rangeD5 * 0.5))
                   : (lowd0  < (lowd5  - rangeD5 * 0.5))

        335 => dir ? (lowd0 > (lowd3 + rangeD3 * 0.5))
                   : (highd0 < (highd3 - rangeD3 * 0.5))

        336 => dir ? (lowd0 > (lowd4 + rangeD4 * 0.5))
                   : (highd0 < (highd4 - rangeD4 * 0.5))

        337 => dir ? (lowd0 > (lowd5 + rangeD5 * 0.5))
                   : (highd0 < (highd5 - rangeD5 * 0.5))

        338 => dir ? (closed1 > opend3)
                   : (closed1 < opend3)

        339 => dir ? (closed1 > opend4)
                   : (closed1 < opend4)

        340 => dir ? (closed1 > opend5)
                   : (closed1 < opend5)

        341 => dir ? (closed1 > highd0)
                   : (closed1 < lowd0)

        342 => dir ? (closed1 > highd3)
                   : (closed1 < lowd3)

        343 => dir ? (closed1 > highd4)
                   : (closed1 < lowd4)

        344 => dir ? (closed1 > closed0)
                   : (closed1 < closed0)

        345 => dir ? (closed1 > closed3)
                   : (closed1 < closed3)

        346 => dir ? (closed1 > closed4)
                   : (closed1 < closed4)

        347 => dir ? (closed1 > closed5)
                   : (closed1 < closed5)

        348 => dir ? (highd1 > highd0)
                   : (lowd1  < lowd0)

        349 => dir ? (highd1 > highd2)
                   : (lowd1  < lowd2)

        350 => dir ? (highd1 > highd3)
                   : (lowd1  < lowd3)

        351 => dir ? (highd1 > highd4)
                   : (lowd1  < lowd4)

        352 => dir ? (highd1 > highd5)
                   : (lowd1  < lowd5)

        353 => dir ? (lowd1 > lowd0)
                   : (highd1 < highd0)

        354 => dir ? (lowd1 > lowd2)
                   : (highd1 < highd2)

        355 => dir ? (lowd1 > lowd3)
                   : (highd1 < highd3)

        356 => dir ? (lowd1 > lowd4)
                   : (highd1 < highd4)

        357 => dir ? (lowd1 > lowd5)
                   : (highd1 < highd5)

        358 => dir ? ((closed1 - opend1) > 0 and (closed1 - opend1) > (highd1 - lowd1) * 0.25)
                   : ((opend1 - closed1) > 0 and (opend1 - closed1) > (highd1 - lowd1) * 0.25)

        359 => dir ? ((closed1 - opend3) > 0 and (closed1 - opend3) > (highd1 - lowd3) * 0.25)
                   : ((opend3 - closed1) > 0 and (opend3 - closed1) > (highd1 - lowd3) * 0.25)

        360 => dir ? ((closed1 - opend4) > 0 and (closed1 - opend4) > (highd1 - lowd4) * 0.25)
                   : ((opend4 - closed1) > 0 and (opend4 - closed1) > (highd1 - lowd4) * 0.25)

        361 => dir ? ((closed1 - opend5) > 0 and (closed1 - opend5) > (highd1 - lowd5) * 0.25)
                   : ((opend5 - closed1) > 0 and (opend5 - closed1) > (highd1 - lowd5) * 0.25)

        362 => dir ? ((closed1 - opend1) > 0 and (closed1 - opend1) < (highd1 - lowd1) * 0.75)
                   : ((opend1 - closed1) > 0 and (opend1 - closed1) < (highd1 - lowd1) * 0.75)

        363 => dir ? ((closed1 - opend3) > 0 and (closed1 - opend3) < (highd1 - lowd3) * 0.75)
                   : ((opend3 - closed1) > 0 and (opend3 - closed1) < (highd1 - lowd3) * 0.75)

        364 => dir ? ((closed1 - opend4) > 0 and (closed1 - opend4) < (highd1 - lowd4) * 0.75)
                   : ((opend4 - closed1) > 0 and (opend4 - closed1) < (highd1 - lowd4) * 0.75)

        365 => dir ? ((closed1 - opend5) > 0 and (closed1 - opend5) < (highd1 - lowd5) * 0.75)
                   : ((opend5 - closed1) > 0 and (opend5 - closed1) < (highd1 - lowd5) * 0.75)

        366 => dir ? (lowd1 > closed0)
                   : (highd1 < closed0)

        367 => dir ? (lowd1 > closed3)
                   : (highd1 < closed3)

        368 => dir ? (lowd1 > closed4)
                   : (highd1 < closed4)

        369 => dir ? (lowd1 > closed5)
                   : (highd1 < closed5)

        370 => dir ? (lowd1 > highd3)
                   : (highd1 < lowd3)

        371 => dir ? (lowd1 > highd4)
                   : (highd1 < lowd4)

        372 => dir ? (lowd1 > highd5)
                   : (highd1 < lowd5)

        373 => dir ? (highd1 > closed0)
                   : (lowd1  < closed0)

        374 => dir ? (highd1 > closed3)
                   : (lowd1  < closed3)

        375 => dir ? (highd1 > closed4)
                   : (lowd1  < closed4)

        376 => dir ? (highd1 > closed5)
                   : (lowd1  < closed5)

        377 => dir ? (opend1 > closed0)
                   : (opend1 < closed0)

        378 => dir ? (opend1 > closed1)
                   : (opend1 < closed1)

        379 => dir ? (opend1 > closed3)
                   : (opend1 < closed3)

        380 => dir ? (opend1 > closed4)
                   : (opend1 < closed4)

        381 => dir ? (opend1 > closed5)
                   : (opend1 < closed5)

        382 => dir ? (opend1 > highd0)
                   : (opend1 < lowd0)

        383 => dir ? (opend1 > highd3)
                   : (opend1 < lowd3)

        384 => dir ? (opend1 > highd4)
                   : (opend1 < lowd4)

        385 => dir ? (opend1 > highd5)
                   : (opend1 < lowd5)

        386 => dir ? (opend1 > lowd0)
                   : (opend1 < highd0)

        387 => dir ? (opend1 > lowd1)
                   : (opend1 < highd1)

        388 => dir ? (opend1 > lowd3)
                   : (opend1 < highd3)

        389 => dir ? (opend1 > lowd4)
                   : (opend1 < highd4)

        390 => dir ? (opend1 > lowd5)
                   : (opend1 < highd5)

        391 => dir ? (closed1 > opend3 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)
                   : (closed1 < opend3 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)

        392 => dir ? (closed1 > opend4 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)
                   : (closed1 < opend4 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)

        393 => dir ? (closed1 > opend5 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)
                   : (closed1 < opend5 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5)

        394 => dir ? (closed1 > opend3 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)
                   : (closed1 < opend3 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)

        395 => dir ? (closed1 > opend4 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)
                   : (closed1 < opend4 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)

        396 => dir ? (closed1 > opend5 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)
                   : (closed1 < opend5 and bodyD1 > bodyD2 and bodyD1 > bodyD3 and bodyD1 > bodyD4 and bodyD1 > bodyD5)

        397 => dir ? (closed1 > closed0 and lowd1 > lowd0)
                   : (closed1 < closed0 and highd1 < highd0)

        398 => dir ? (closed1 > closed3 and lowd1 > lowd3)
                   : (closed1 < closed3 and highd1 < highd3)

        399 => dir ? (closed1 > closed4 and lowd1 > lowd4)
                   : (closed1 < closed4 and highd1 < highd4)

        400 => dir ? (closed1 > closed5 and lowd1 > lowd5)
                   : (closed1 < closed5 and highd1 < highd5)

        401 => dir ? (closed1 > opend0 and lowd1 > lowd0)
                   : (closed1 < opend0 and highd1 < highd0)

        402 => dir ? (closed1 > opend3 and lowd1 > lowd3)
                   : (closed1 < opend3 and highd1 < highd3)

        403 => dir ? (closed1 > opend4 and lowd1 > lowd4)
                   : (closed1 < opend4 and highd1 < highd4)

        404 => dir ? (closed1 > opend5 and lowd1 > lowd5)
                   : (closed1 < opend5 and highd1 < highd5)

        405 => dir ? (closed1 > opend1 and range1d > rangeD3)
                   : (closed1 < opend1 and range1d > rangeD3)

        406 => dir ? (closed1 > opend1 and range1d > rangeD4)
                   : (closed1 < opend1 and range1d > rangeD4)

        407 => dir ? (closed1 > opend1 and range1d > rangeD5)
                   : (closed1 < opend1 and range1d > rangeD5)

        408 => dir ? (closed1 > opend1 and range1d < rangeD3)
                   : (closed1 < opend1 and range1d < rangeD3)

        409 => dir ? (closed1 > opend1 and range1d < rangeD4)
                   : (closed1 < opend1 and range1d < rangeD4)

        410 => dir ? (closed1 > opend1 and range1d < rangeD5)
                   : (closed1 < opend1 and range1d < rangeD5)

        411 => dir ? (closed2 > opend0)
                   : (closed2 < opend0)

        412 => dir ? (closed2 > opend3)
                   : (closed2 < opend3)

        413 => dir ? (closed2 > opend4)
                   : (closed2 < opend4)

        414 => dir ? (closed2 > opend5)
                   : (closed2 < opend5)

        415 => dir ? (closed2 > highd2)
                   : (closed2 < lowd2)

        416 => dir ? (closed2 > highd3)
                   : (closed2 < lowd3)

        417 => dir ? (closed2 > highd4)
                   : (closed2 < lowd4)

        418 => dir ? (closed2 > highd5)
                   : (closed2 < lowd5)

        419 => dir ? (closed2 > closed0)
                   : (closed2 < closed0)

        420 => dir ? (closed2 > closed3)
                   : (closed2 < closed3)

        421 => dir ? (closed2 > closed4)
                   : (closed2 < closed4)

        422 => dir ? (closed2 > closed5)
                   : (closed2 < closed5)

        423 => dir ? (highd2 > highd0)
                   : (lowd2  < lowd0)

        424 => dir ? (highd2 > highd1)
                   : (lowd2  < lowd1)

        425 => dir ? (highd2 > highd3)
                   : (lowd2  < lowd3)

        426 => dir ? (highd2 > highd4)
                   : (lowd2  < lowd4)

        427 => dir ? (highd2 > highd5)
                   : (lowd2  < lowd5)

        428 => dir ? (lowd2 > lowd0)
                   : (highd2 < highd0)

        429 => dir ? (lowd2 > lowd1)
                   : (highd2 < highd1)

        430 => dir ? (lowd2 > lowd3)
                   : (highd2 < highd3)

        431 => dir ? (lowd2 > lowd4)
                   : (highd2 < highd4)

        432 => dir ? (lowd2 > lowd5)
                   : (highd2 < highd5)

        433 => dir ? ((closed2 - opend3) > 0 and (closed2 - opend3) > (highd2 - lowd3) * 0.25)
                   : ((opend3 - closed2) > 0 and (opend3 - closed2) > (highd2 - lowd3) * 0.25)

        434 => dir ? ((closed2 - opend4) > 0 and (closed2 - opend4) > (highd2 - lowd4) * 0.25)
                   : ((opend4 - closed2) > 0 and (opend4 - closed2) > (highd2 - lowd4) * 0.25)

        435 => dir ? ((closed2 - opend5) > 0 and (closed2 - opend5) > (highd2 - lowd5) * 0.25)
                   : ((opend5 - closed2) > 0 and (opend5 - closed2) > (highd2 - lowd5) * 0.25)

        436 => dir ? ((closed2 - opend3) > 0 and (closed2 - opend3) < (highd2 - lowd3) * 0.75)
                   : ((opend3 - closed2) > 0 and (opend3 - closed2) < (highd2 - lowd3) * 0.75)

        437 => dir ? ((closed2 - opend4) > 0 and (closed2 - opend4) < (highd2 - lowd4) * 0.75)
                   : ((opend4 - closed2) > 0 and (opend4 - closed2) < (highd2 - lowd4) * 0.75)

        438 => dir ? ((closed2 - opend5) > 0 and (closed2 - opend5) < (highd2 - lowd5) * 0.75)
                   : ((opend5 - closed2) > 0 and (opend5 - closed2) < (highd2 - lowd5) * 0.75)

        439 => dir ? (lowd2 > closed0)
                   : (highd2 < closed0)

        440 => dir ? (lowd2 > closed3)
                   : (highd2 < closed3)

        441 => dir ? (lowd2 > closed4)
                   : (highd2 < closed4)

        442 => dir ? (lowd2 > closed5)
                   : (highd2 < closed5)

        443 => dir ? (lowd2 > highd3)
                   : (highd2 < lowd3)

        444 => dir ? (lowd2 > highd4)
                   : (highd2 < lowd4)

        445 => dir ? (lowd2 > highd5)
                   : (highd2 < lowd5)

        446 => dir ? (highd2 > closed0)
                   : (lowd2  < closed0)

        447 => dir ? (highd2 > closed3)
                   : (lowd2  < closed3)

        448 => dir ? (highd2 > closed4)
                   : (lowd2  < closed4)

        449 => dir ? (highd2 > closed5)
                   : (lowd2  < closed5)

        450 => dir ? (opend2 > closed0)
                   : (opend2 < closed0)

        451 => dir ? (opend2 > closed3)
                   : (opend2 < closed3)

        452 => dir ? (opend2 > closed4)
                   : (opend2 < closed4)

        453 => dir ? (opend2 > closed5)
                   : (opend2 < closed5)

        454 => dir ? (opend2 > highd3)
                   : (opend2 < lowd3)

        455 => dir ? (opend2 > highd4)
                   : (opend2 < lowd4)

        456 => dir ? (opend2 > highd5)
                   : (opend2 < lowd5)

        457 => dir ? (opend2 > lowd3)
                   : (opend2 < highd3)

        458 => dir ? (opend2 > lowd4)
                   : (opend2 < highd4)

        459 => dir ? (opend2 > lowd5)
                   : (opend2 < highd5)

        460 => dir ? (closed2 > opend3 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)
                   : (closed2 < opend3 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)

        461 => dir ? (closed2 > opend4 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)
                   : (closed2 < opend4 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)

        462 => dir ? (closed2 > opend5 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)
                   : (closed2 < opend5 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5)

        463 => dir ? (closed2 > opend3 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)
                   : (closed2 < opend3 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)

        464 => dir ? (closed2 > opend4 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)
                   : (closed2 < opend4 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)

        465 => dir ? (closed2 > opend5 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)
                   : (closed2 < opend5 and bodyD2 > bodyD3 and bodyD2 > bodyD4 and bodyD2 > bodyD5)

        466 => dir ? (closed2 > closed0 and lowd2 > lowd0)
                   : (closed2 < closed0 and highd2 < highd0)

        467 => dir ? (closed2 > closed3 and lowd2 > lowd3)
                   : (closed2 < closed3 and highd2 < highd3)

        468 => dir ? (closed2 > closed4 and lowd2 > lowd4)
                   : (closed2 < closed4 and highd2 < highd4)

        469 => dir ? (closed2 > closed5 and lowd2 > lowd5)
                   : (closed2 < closed5 and highd2 < highd5)

        470 => dir ? (closed2 > opend3 and lowd2 > lowd3)
                   : (closed2 < opend3 and highd2 < highd3)

        471 => dir ? (closed2 > opend4 and lowd2 > lowd4)
                   : (closed2 < opend4 and highd2 < highd4)

        472 => dir ? (closed2 > opend5 and lowd2 > lowd5)
                   : (closed2 < opend5 and highd2 < highd5)

        473 => dir ? (closed2 > opend2 and rangeD2 > rangeD3)
                   : (closed2 < opend2 and rangeD2 > rangeD3)

        474 => dir ? (closed2 > opend2 and rangeD2 > rangeD4)
                   : (closed2 < opend2 and rangeD2 > rangeD4)

        475 => dir ? (closed2 > opend2 and rangeD2 > rangeD5)
                   : (closed2 < opend2 and rangeD2 > rangeD5)

        476 => dir ? (closed2 > opend2 and rangeD2 < rangeD3)
                   : (closed2 < opend2 and rangeD2 < rangeD3)

        477 => dir ? (closed2 > opend2 and rangeD2 < rangeD4)
                   : (closed2 < opend2 and rangeD2 < rangeD4)

        478 => dir ? (closed2 > opend2 and rangeD2 < rangeD5)
                   : (closed2 < opend2 and rangeD2 < rangeD5)


        => false

    res






ZPattern_Mir_479_N(int pattern, array<float> FT_OHLC, array<float> PtnCtx) =>
    // Guard rails 
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")

    // OHLC day/session 
    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)

    // Load pre-calcs
    int   barcount = int(nz(array.get(PtnCtx, 0), 0))

    float body1d   = array.get(PtnCtx, 1)
    float range1d  = array.get(PtnCtx, 2)
    float body5d   = array.get(PtnCtx, 3)
    float range5d  = array.get(PtnCtx, 4)

    float HighestO = array.get(PtnCtx, 5)
    float LowestO  = array.get(PtnCtx, 6)
    float HighestH = array.get(PtnCtx, 7)
    float LowestH  = array.get(PtnCtx, 8)
    float HighestL = array.get(PtnCtx, 9)
    float LowestL  = array.get(PtnCtx, 10)
    float HighestC = array.get(PtnCtx, 11)
    float LowestC  = array.get(PtnCtx, 12)

    float rangeD0  = array.get(PtnCtx, 13)
    float rangeD1  = array.get(PtnCtx, 14)
    float rangeD2  = array.get(PtnCtx, 15)
    float rangeD3  = array.get(PtnCtx, 16)
    float rangeD4  = array.get(PtnCtx, 17)
    float rangeD5  = array.get(PtnCtx, 18)

    float bodyD0   = array.get(PtnCtx, 19)
    float bodyD1   = array.get(PtnCtx, 20)
    float bodyD2   = array.get(PtnCtx, 21)
    float bodyD3   = array.get(PtnCtx, 22)
    float bodyD4   = array.get(PtnCtx, 23)
    float bodyD5   = array.get(PtnCtx, 24)

    float MaxCO    = array.get(PtnCtx, 30)
    float MinOC    = array.get(PtnCtx, 31)

    // Session-start bar 
    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)

    // Per-bar range
    float rng0 = high - low

    // Switch patterns
    p = math.abs(pattern)
    dir = pattern > 0


    bool res = switch p

        479 => dir ? (math.abs(opend5 - closed1) > 0.25 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 0.25 * (highd5 - lowd1))


        480  => dir ? (closed1 > (closed2 + closed2 * 3.0 * 0.01)) : (closed1 < (closed2 - closed2 * 3.0 * 0.01))

        481 => dir ? (math.abs(opend5 - closed1) > 2.5 * (highd5 - lowd1))
                   : (math.abs(opend5 - closed1) < 2.5 * (highd5 - lowd1))

        482 => dir ? true : true

        => false






export ZPattern_Mir(int pattern, array<float> FT_OHLC, array<float> PtnCtx) =>
    if array.size(FT_OHLC) < 24
        runtime.error("FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("PtnCtx array must have at least 32 elements (0..31).")

    int  p   = math.abs(pattern)
    bool dir = pattern > 0

    p == 0 ? false : p <= 160 ? ZPattern_Mir_1_160(pattern, FT_OHLC, PtnCtx) : p <= 320 ? ZPattern_Mir_161_320(pattern, FT_OHLC, PtnCtx) : p <= 478 ? ZPattern_Mir_321_478(pattern, FT_OHLC, PtnCtx) : ZPattern_Mir_479_N(pattern, FT_OHLC, PtnCtx)










// ==========================================
// PATTERN MOST USED
// ==========================================
f_ptn_title(int pid) =>
    int p = math.abs(pid)
    bool dir = pid >= 0
    switch p
        1  => dir ? "Close > Open(D0)" : "Close < Open(D0)"
        2  => dir ? "Close >= 0.99*Open(D0)" : "Close <= 1.01*Open(D0)"
        3  => dir ? "Close >= 0.995*Open(D0)" : "Close <= 1.005*Open(D0)"
        4  => dir ? "Close >= 1.005*Open(D0)" : "Close <= 0.995*Open(D0)"
        5  => dir ? "Close > High(D1)" : "Close < Low(D1)"
        6  => dir ? "Open(D0) > Close(D1) +0.25%" : "Open(D0) < Close(D1) -0.25%"
        7  => dir ? "Low(D0) > Low(D1)" : "High(D0) < High(D1)"
        8  => dir ? "D1 inside-ish vs D2" : "D1 outside-ish vs D2"
        9  => dir ? "4 rising closes" : "4 falling closes"
        10  => dir ? "Close(D1) > Close(D2) +0.5%" : "Close(D1) < Close(D2) -0.5%"
        11  => dir ? "Close(D1) > Close(D2) +2.0%" : "Close(D1) < Close(D2) -2.0%"
        12  => dir ? "Upper exc(D0) > 0.5x D1" : "Lower exc(D0) > 0.5x D1"
        13  => dir ? "Upper exc(D0) > 0.75x D1" : "Lower exc(D0) > 0.75x D1"
        14  => dir ? "Upper exc(D0) > 1.5x D1" : "Lower exc(D0) > 1.5x D1"
        15  => dir ? "Upper exc(D0) < D1" : "Lower exc(D0) < D1"
        16  => dir ? "D1 shift up vs D2" : "D1 shift down vs D2"
        17 => dir ? "D1 bullish candle" : "D1 bearish candle"
        18 => dir ? "Close(D1) > Close(D2)" : "Close(D1) < Close(D2)"
        19 => dir ? "D1 & D2 bullish" : "D1 & D2 bearish"
        20 => dir ? "D1 body > 75% range" : "D1 body < 75% range"
        21 => dir ? "D1 body > 90% range" : "D1 body < 90% range"
        22 => dir ? "|O(D5)-C(D1)| > 25% 5-day" : "|O(D5)-C(D1)| < 25% 5-day"
        23 => dir ? "|O(D5)-C(D1)| > 75% 5-day" : "|O(D5)-C(D1)| < 75% 5-day"
        24 => "D0 range < 0.5%"
        25 => "D0 range > 0.5%"
        26 => "D0 range > 3.0%"
        27 => dir ? "Low(D1) highest vs D2..D4" : "Low(D1) lowest vs D2..D4"
        28 => dir ? "3 down closes + gap down" : "3 up closes + gap up"
        29 => dir ? "|O(D5)-C(D1)| > 50% span(H5-L1)" : "|O(D5)-C(D1)| < 50% span(H5-L1)"
        30 => dir ? "D1 body > 10% range" : "D1 body < 10% (doji)"
        31 => dir ? "Range(D1) > Range(D2)" : "Range(D1) < Range(D2)"
        32 => dir ? "Open(D0) outside D1 range" : "Open(D0) inside D1 range"
        33 => dir ? "|O(D5)-C(D1)| > 25% span(H5-L1)" : "|O(D5)-C(D1)| < 25% span(H5-L1)"
        => "None"




f_ptn_desc(int pid) =>
    int p = math.abs(pid)
    bool dir = pid >= 0
    switch p
        1  => dir ? "Current close is above the current Day/Session open (bullish bias)." : "Current close is below the current Day/Session open (bearish bias)."
        2  => dir ? "Close is not more than ~1% below the current open (mild bullish/neutral positioning)." : "Close is not more than ~1% above the current open (mild bearish/neutral positioning)."
        3  => dir ? "Close is not more than ~0.5% below the current open." : "Close is not more than ~0.5% above the current open."
        4  => dir ? "Close is at least ~0.5% above the current open (stronger bullish bias)." : "Close is at least ~0.5% below the current open (stronger bearish bias)."
        5  => dir ? "Close breaks above the previous Day/Session high (D1 breakout)." : "Close breaks below the previous Day/Session low (D1 breakdown)."
        6  => dir ? "Gap-up open: current open is > previous close by ~0.25%." : "Gap-down open: current open is < previous close by ~0.25%."
        7  => dir ? "Today/session prints a higher low than yesterday (rising support)." : "Today/session prints a lower high than yesterday (falling resistance)."
        8  => dir ? "D1 is at least partially contained vs D2 (one-side inside behavior)." : "D1 extends beyond D2 on at least one bound (one-side outside behavior)."
        9  => dir ? "Four consecutive rising closes (momentum up)." : "Four consecutive falling closes (momentum down)."
        10  => dir ? "Close(D1) is > Close(D2) by ~0.5% (step-up)." : "Close(D1) is < Close(D2) by ~0.5% (step-down)."
        11  => dir ? "Close(D1) is > Close(D2) by ~2.0% (strong step-up)." : "Close(D1) is < Close(D2) by ~2.0% (strong step-down)."
        12  => dir ? "Upper excursion from open to high (D0) exceeds D1 by 0.5x (buying pressure expansion)." : "Lower excursion from open to low (D0) exceeds D1 by 0.5x (selling pressure expansion)."
        13  => dir ? "Upper excursion from open to high (D0) exceeds D1 by 0.75x." : "Lower excursion from open to low (D0) exceeds D1 by 0.75x."
        14  => dir ? "Upper excursion from open to high (D0) exceeds D1 by 1.5x (very strong expansion)." : "Lower excursion from open to low (D0) exceeds D1 by 1.5x (very strong expansion)."
        15  => dir ? "Upper excursion from open to high (D0) is smaller than D1 (reduced upside drive)." : "Lower excursion from open to low (D0) is smaller than D1 (reduced downside drive)."
        16  => dir ? "D1 shifts upward vs D2 (higher high AND higher low)." : "D1 shifts downward vs D2 (lower high AND lower low)."
        17 => dir ? "D1 closed above its open (bullish candle body)." : "D1 closed below its open (bearish candle body)."
        18 => dir ? "Close(D1) is higher than Close(D2) (1-day close gain)." : "Close(D1) is lower than Close(D2) (1-day close loss)."
        19 => dir ? "Last two days (D1 & D2) both closed above their opens (2-day bullish bodies)." : "Last two days (D1 & D2) both closed below their opens (2-day bearish bodies)."
        20 => dir ? "D1 candle body is > 75% of its range (trend-like day)." : "D1 candle body is < 75% of its range (mixed / mean-reverting structure)."
        21 => dir ? "D1 candle body is > 90% of its range (very strong trend day)." : "D1 candle body is < 90% of its range (not a clean trend day)."
        22 => dir ? "Displacement |O(D5)-C(D1)| exceeds 25% of the 5-day range (meaningful multi-day shift)." : "Displacement |O(D5)-C(D1)| stays below 25% of the 5-day range (compressed / balanced)."
        23 => dir ? "Displacement |O(D5)-C(D1)| exceeds 75% of the 5-day range (extreme multi-day shift)." : "Displacement |O(D5)-C(D1)| stays below 75% of the 5-day range."
        24 => "Current D0 range is very tight: High(D0) is within ~0.5% of Low(D0)."
        25 => "Current D0 range is expanded: High(D0) is more than ~0.5% above Low(D0)."
        26 => "Current D0 range is very wide: High(D0) is more than ~3% above Low(D0)."
        27 => dir ? "Low(D1) is the highest low compared to D2..D4 (rising floor)." : "Low(D1) is the lowest low compared to D2..D4 (falling floor)."
        28 => dir ? "Three falling closes into D1 plus a gap-down open on D0 (bear continuation profile)." : "Three rising closes into D1 plus a gap-up open on D0 (bull continuation profile)."
        29 => dir ? "Displacement |O(D5)-C(D1)| exceeds 50% of span (H5-L1) (large shift on a wide baseline)." : "Displacement |O(D5)-C(D1)| stays below 50% of span (H5-L1)."
        30 => dir ? "D1 has a non-trivial body (>10% of its range)." : "D1 body is tiny (<10% of its range) — doji-like."
        31 => dir ? "D1 is more volatile than D2 (range expansion)." : "D1 is less volatile than D2 (range contraction)."
        32 => dir ? "Open(D0) is outside the previous day/session range (gap behavior)." : "Open(D0) remains inside the previous day/session range (no gap)."
        33 => dir ? "Displacement |O(D5)-C(D1)| exceeds 25% of span (H5-L1)." : "Displacement |O(D5)-C(D1)| stays below 25% of span (H5-L1)."
        => "No condition is used."









export ZPattern_MostUsed(int pattern, array<float> FT_OHLC, array<float> PtnCtx) =>
    // Guard rails 
    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")

    // OHLC day/session 
    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)

    // Load pre-calcs
    int   barcount = int(nz(array.get(PtnCtx, 0), 0))

    float body1d   = array.get(PtnCtx, 1)
    float range1d  = array.get(PtnCtx, 2)
    float body5d   = array.get(PtnCtx, 3)
    float range5d  = array.get(PtnCtx, 4)

    float HighestO = array.get(PtnCtx, 5)
    float LowestO  = array.get(PtnCtx, 6)
    float HighestH = array.get(PtnCtx, 7)
    float LowestH  = array.get(PtnCtx, 8)
    float HighestL = array.get(PtnCtx, 9)
    float LowestL  = array.get(PtnCtx, 10)
    float HighestC = array.get(PtnCtx, 11)
    float LowestC  = array.get(PtnCtx, 12)

    float rangeD0  = array.get(PtnCtx, 13)
    float rangeD1  = array.get(PtnCtx, 14)
    float rangeD2  = array.get(PtnCtx, 15)
    float rangeD3  = array.get(PtnCtx, 16)
    float rangeD4  = array.get(PtnCtx, 17)
    float rangeD5  = array.get(PtnCtx, 18)

    float bodyD0   = array.get(PtnCtx, 19)
    float bodyD1   = array.get(PtnCtx, 20)
    float bodyD2   = array.get(PtnCtx, 21)
    float bodyD3   = array.get(PtnCtx, 22)
    float bodyD4   = array.get(PtnCtx, 23)
    float bodyD5   = array.get(PtnCtx, 24)

    float MaxCO    = array.get(PtnCtx, 30)
    float MinOC    = array.get(PtnCtx, 31)

    // Session-start bar 
    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)

    // Per-bar range
    float rng0 = high - low

    // Switch patterns
    p = math.abs(pattern)
    dir = pattern > 0


    bool res = switch p
        1  => dir ? (close > opend0) : (close < opend0)

        2  => dir ? (close > opend0 * 0.99)  : (close < opend0 * 1.01)
        3  => dir ? (close > opend0 * 0.995) : (close < opend0 * 1.005)
        4  => dir ? (close > opend0 * 1.005) : (close < opend0 * 0.995)

        5  => dir ? (close > highd1) : (close < lowd1)

        6  => dir ? (opend0 > (closed1 + closed1 * 0.25 * 0.01))
                  : (opend0 < (closed1 - closed1 * 0.25 * 0.01))

        7  => dir ? (lowd0 > lowd1) : (highd0 < highd1)

        8  => dir ? (highd1 < highd2 or lowd1 > lowd2)
                  : (highd1 > highd2 or lowd1 < lowd2)

        9  => dir ? (closed1 > closed2 and closed2 > closed3 and closed3 > closed4)
                  : (closed1 < closed2 and closed2 < closed3 and closed3 < closed4)

        10  => dir ? (closed1 > (closed2 + closed2 * 0.5 * 0.01))
                   : (closed1 < (closed2 - closed2 * 0.5 * 0.01))

        11  => dir ? (closed1 > (closed2 + closed2 * 2.0 * 0.01))
                   : (closed1 < (closed2 - closed2 * 2.0 * 0.01))

        12  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.5))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.5))

        13  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.75))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.75))

        14  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 1.5))
                   : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 1.5))

        15  => dir ? ((highd0 - opend0) < (highd1 - opend1))
                   : ((opend0 - lowd0)  < (opend1 - lowd1))

        16  => dir ? (highd1 > highd2 and lowd1 > lowd2)
                   : (highd1 < highd2 and lowd1 < lowd2)

        17 => dir ? (closed1 > opend1) : (closed1 < opend1)
        18 => dir ? (closed1 > closed2) : (closed1 < closed2)

        19 => dir ? (closed1 > opend1 and closed2 > opend2)
                  : (closed1 < opend1 and closed2 < opend2)

        20 => dir ? (math.abs(opend1 - closed1) > 0.75 * range1d)
                  : (math.abs(opend1 - closed1) < 0.75 * range1d)

        21 => dir ? (math.abs(opend1 - closed1) > 0.90 * range1d)
                  : (math.abs(opend1 - closed1) < 0.90 * range1d)

        22 => dir ? (math.abs(opend5 - closed1) > 0.25 * (HighestH - LowestL))
                  : (math.abs(opend5 - closed1) < 0.25 * (HighestH - LowestL))

        23 => dir ? (math.abs(opend5 - closed1) > 0.75 * (HighestH - LowestL))
                  : (math.abs(opend5 - closed1) < 0.75 * (HighestH - LowestL))

        24 => dir ? (highd0 < (lowd0 + lowd0 * 0.50 * 0.01))
                  : (lowd0  > (highd0 - highd0 * 0.50 * 0.01))

        25 => dir ? (highd0 > (lowd0 + lowd0 * 0.50 * 0.01))
                  : (lowd0  < (highd0 - highd0 * 0.50 * 0.01))

        26 => dir ? (highd0 > (lowd0 + lowd0 * 3 * 0.01))
                  : (lowd0  < (highd0 - highd0 * 3 * 0.01))

        27 => dir ? (lowd1 > lowd2 and lowd1 > lowd3 and lowd1 > lowd4)
                  : (lowd1 < lowd2 and lowd1 < lowd3 and lowd1 < lowd4)

        28 => dir ? (closed1 < closed2 and closed2 < closed3 and opend0 < closed1)
                  : (closed1 > closed2 and closed2 > closed3 and opend0 > closed1)

        29 => dir ? (math.abs(opend5 - closed1) > 0.50 * (highd5 - lowd1))
                  : (math.abs(opend5 - closed1) < 0.50 * (highd5 - lowd1))

        30 => dir ? (math.abs(opend1 - closed1) > 0.1 * range1d)
                  : (math.abs(opend1 - closed1) < 0.1 * range1d)

        31 => dir ? (range1d > rangeD2)
                  : (range1d < rangeD2)

        32 => dir ? ((opend0 < lowd1) or (opend0 > highd1))
                  : ((opend0 > lowd1) or (opend0 < highd1))

        33 => dir ? (math.abs(opend5 - closed1) > 0.25 * (highd5 - lowd1))
                  : (math.abs(opend5 - closed1) < 0.25 * (highd5 - lowd1))

        34 => dir ? true : true

        => false









// ==========================================
// UI helpers
// ==========================================
f_size_from_scale(int scale) =>
    scale <= 1 ? size.tiny : scale == 2 ? size.small : scale == 3 ? size.normal : scale == 4 ? size.large : size.huge

f_pos_from_string(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center : s == "Top Right" ? position.top_right : s == "Middle Left" ? position.middle_left : s == "Middle Center" ? position.middle_center : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : s == "Bottom Center" ? position.bottom_center : position.bottom_right

f_hhmm(int t) =>
    int hh = int(math.floor(t / 100))
    int mm = int(t - hh * 100)
    str.format("{0,number,00}:{1,number,00}", hh, mm)

f_slot_color(int slot) =>
    switch slot
        0 => color.rgb(0, 180, 216)
        1 => color.rgb(255, 140, 0)
        2 => color.rgb(0, 200, 83)
        3 => color.rgb(255, 64, 129)
        4 => color.rgb(171, 71, 188)
        5 => color.rgb(255, 235, 59)
        6 => color.rgb(38, 166, 154)
        7 => color.rgb(244, 67, 54)
        8 => color.rgb(121, 85, 72)
        => color.rgb(63, 81, 181)


// ==========================================
// Pattern panel
// ==========================================
export Z_OHLC_PatternsPanel(
     bool showPanel,
     bool showHighlights,
     int  uiScale,
     string panelPos,
     int sessStart,
     int sessEnd,
     string useDailyMode,
     string timezone_ohlc,
     int[] patternIds,
     string[] filterTypes,
     string[] titles,
     array<float> FT_OHLC,
     array<float> PtnCtx
 ) =>
    if array.size(FT_OHLC) < 24 or array.size(PtnCtx) < 32
        [na, na]

    else
        var table t = na
        var int[]  slotHits = array.new_int(10, 0)
        var bool[] slotPrev = array.new_bool(10, false)

        int nSlots = math.min(array.size(patternIds), 10)

        color outBar = na
        color outBg  = na

        float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2)
        float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
        float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
        float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
        float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
        float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22)

        float HighestH = array.get(PtnCtx, 7)
        float LowestL  = array.get(PtnCtx, 10)

        float range1d = highd1 - lowd1
        float range2d = highd2 - lowd2
        float rangeD0 = highd0 - lowd0

        bool[] slotNow = array.new_bool(nSlots, false)

        for i = 0 to nSlots - 1
            int pid = array.get(patternIds, i)
            int p   = math.abs(pid)
            bool dir = pid >= 0
            bool now = false

            now := switch p
                1  => dir ? (close > opend0) : (close < opend0)

                2  => dir ? (close > opend0 * 0.99)  : (close < opend0 * 1.01)
                3  => dir ? (close > opend0 * 0.995) : (close < opend0 * 1.005)
                4  => dir ? (close > opend0 * 1.005) : (close < opend0 * 0.995)

                5  => dir ? (close > highd1) : (close < lowd1)

                6  => dir ? (opend0 > (closed1 + closed1 * 0.25 * 0.01))
                          : (opend0 < (closed1 - closed1 * 0.25 * 0.01))

                7  => dir ? (lowd0 > lowd1) : (highd0 < highd1)

                8  => dir ? (highd1 < highd2 or lowd1 > lowd2)
                          : (highd1 > highd2 or lowd1 < lowd2)

                9  => dir ? (closed1 > closed2 and closed2 > closed3 and closed3 > closed4)
                          : (closed1 < closed2 and closed2 < closed3 and closed3 < closed4)

                10  => dir ? (closed1 > (closed2 + closed2 * 0.5 * 0.01))
                          : (closed1 < (closed2 - closed2 * 0.5 * 0.01))

                11  => dir ? (closed1 > (closed2 + closed2 * 2.0 * 0.01))
                           : (closed1 < (closed2 - closed2 * 2.0 * 0.01))

                12  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.5))
                           : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.5))

                13  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 0.75))
                           : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 0.75))

                14  => dir ? ((highd0 - opend0) > ((highd1 - opend1) * 1.5))
                           : ((opend0 - lowd0)  > ((opend1 - lowd1)  * 1.5))

                15  => dir ? ((highd0 - opend0) < (highd1 - opend1))
                           : ((opend0 - lowd0)  < (opend1 - lowd1))

                16  => dir ? (highd1 > highd2 and lowd1 > lowd2)
                           : (highd1 < highd2 and lowd1 < lowd2)

                17 => dir ? (closed1 > opend1) : (closed1 < opend1)
                18 => dir ? (closed1 > closed2) : (closed1 < closed2)

                19 => dir ? (closed1 > opend1 and closed2 > opend2)
                          : (closed1 < opend1 and closed2 < opend2)

                20 => dir ? (math.abs(opend1 - closed1) > 0.75 * range1d)
                          : (math.abs(opend1 - closed1) < 0.75 * range1d)

                21 => dir ? (math.abs(opend1 - closed1) > 0.90 * range1d)
                          : (math.abs(opend1 - closed1) < 0.90 * range1d)

                22 => dir ? (math.abs(opend5 - closed1) > 0.25 * (HighestH - LowestL))
                          : (math.abs(opend5 - closed1) < 0.25 * (HighestH - LowestL))

                23 => dir ? (math.abs(opend5 - closed1) > 0.75 * (HighestH - LowestL))
                          : (math.abs(opend5 - closed1) < 0.75 * (HighestH - LowestL))

                24 => dir ? (highd0 < (lowd0 + lowd0 * 0.50 * 0.01))
                          : (lowd0  > (highd0 - highd0 * 0.50 * 0.01))

                25 => dir ? (highd0 > (lowd0 + lowd0 * 0.50 * 0.01))
                          : (lowd0  < (highd0 - highd0 * 0.50 * 0.01))

                26 => dir ? (highd0 > (lowd0 + lowd0 * 3 * 0.01))
                          : (lowd0  < (highd0 - highd0 * 3 * 0.01))

                27 => dir ? (lowd1 > lowd2 and lowd1 > lowd3 and lowd1 > lowd4)
                          : (lowd1 < lowd2 and lowd1 < lowd3 and lowd1 < lowd4)

                28 => dir ? (closed1 < closed2 and closed2 < closed3 and opend0 < closed1)
                          : (closed1 > closed2 and closed2 > closed3 and opend0 > closed1)

                29 => dir ? (math.abs(opend5 - closed1) > 0.50 * (highd5 - lowd1))
                          : (math.abs(opend5 - closed1) < 0.50 * (highd5 - lowd1))

                30 => dir ? (math.abs(opend1 - closed1) > 0.1 * range1d)
                          : (math.abs(opend1 - closed1) < 0.1 * range1d)

                31 => dir ? (range1d > range2d)
                          : (range1d < range2d)

                32 => dir ? ((opend0 < lowd1) or (opend0 > highd1))
                          : ((opend0 > lowd1) or (opend0 < highd1))

                33 => dir ? (math.abs(opend5 - closed1) > 0.25 * (highd5 - lowd1))
                          : (math.abs(opend5 - closed1) < 0.25 * (highd5 - lowd1))

                34 => dir ? true : true

                => false

            array.set(slotNow, i, now)

            bool prev = array.get(slotPrev, i)
            if pid != 0 and math.abs(pid) < 34 and now and not prev
                array.set(slotHits, i, array.get(slotHits, i) + 1)
            array.set(slotPrev, i, now)

        if showHighlights
            for i = 0 to nSlots - 1
                int pid = array.get(patternIds, i)
                bool now = array.get(slotNow, i)
                if pid != 0 and math.abs(pid) < 34 and now and na(outBg)
                    color c = f_slot_color(i)
                    outBar := c
                    outBg  := color.new(c, 85)

        // ==============
        // TABLE: 
        // ==============
        if not showPanel
            if not na(t)
                table.delete(t)
                t := na
        else
            // create once
            if na(t)
                t := table.new(f_pos_from_string(panelPos), 6, 14, frame_width=1, border_width=1)

            string txtSize = f_size_from_scale(uiScale)

            // styling colors
            color bgFrame  = color.new(color.black, 0)
            color bgHeader = color.new(#14234e, 15)
            color bgRowA   = color.new(#3d3f44, 10)
            color bgRowB   = color.new(#4a4b4e, 10)
            color txtMain  = color.new(color.white, 0)
            color txtSoft  = color.new(color.white, 25)

            // Row 0: title
            table.cell(t, 0, 0, "", bgcolor=bgHeader)
            table.cell(t, 1, 0, "", bgcolor=bgHeader)
            table.cell(t, 2, 0, "", bgcolor=bgHeader)
            table.cell(t, 3, 0, "FT — OHLC Pattern Filters", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize, text_halign=text.align_left)
            table.cell(t, 4, 0, "", bgcolor=bgHeader)
            table.cell(t, 5, 0, "", bgcolor=bgHeader)

            // Row 1: general info
            string gen = str.format("Mode: {0} | TZ: {1} | Session: {2}-{3}", useDailyMode, timezone_ohlc, f_hhmm(sessStart), f_hhmm(sessEnd))
            table.cell(t, 0, 1, "", bgcolor=bgRowB)
            table.cell(t, 1, 1, "", bgcolor=bgRowB)
            table.cell(t, 2, 1, "", bgcolor=bgRowB)
            table.cell(t, 3, 1, gen, text_color=txtSoft, bgcolor=bgRowB, text_size=txtSize, text_halign=text.align_left)
            table.cell(t, 4, 1, "", bgcolor=bgRowB)
            table.cell(t, 5, 1, "", bgcolor=bgRowB)

            // Row 2: spacer
            for c = 0 to 5
                table.cell(t, c, 2, "", bgcolor=bgFrame)

            // Row 3: column headers
            table.cell(t, 0, 3, "■", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize)
            table.cell(t, 1, 3, "Filter", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize)
            table.cell(t, 2, 3, "Title (input)", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize)
            table.cell(t, 3, 3, "Auto description", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize)
            table.cell(t, 4, 3, "Hits", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize)
            table.cell(t, 5, 3, "Now", text_color=txtMain, bgcolor=bgHeader, text_size=txtSize)

            // Rows 4..13 data (max 10 righe)
            int rowBase = 4
            int used = 0

            // clear all data rows first
            for r = rowBase to 13
                color rb = (r % 2 == 0) ? bgRowA : bgRowB
                for c = 0 to 5
                    table.cell(t, c, r, "", bgcolor=rb, text_size=txtSize)

            // fill active patterns
            for i = 0 to nSlots - 1
                int pid = array.get(patternIds, i)
                if pid != 0 and math.abs(pid) < 34 and used < 10
                    int r = rowBase + used
                    used += 1

                    color c = f_slot_color(i)
                    bool now = array.get(slotNow, i)

                    string fType = i < array.size(filterTypes) ? array.get(filterTypes, i) : "-"
                    string ttl   = i < array.size(titles) ? array.get(titles, i) : f_ptn_title(pid)

                    string desc  = f_ptn_desc(pid)
                    int hits     = array.get(slotHits, i)
                    string st    = now ? "VERIFIED" : "NOT"

                    color rb = (r % 2 == 0) ? bgRowA : bgRowB
                    table.cell(t, 0, r, "■", text_color=c, bgcolor=rb, text_size=txtSize)
                    table.cell(t, 1, r, fType, text_color=txtSoft, bgcolor=rb, text_size=txtSize)
                    table.cell(t, 2, r, ttl, text_color=txtMain, bgcolor=rb, text_size=txtSize, text_halign=text.align_left)
                    table.cell(t, 3, r, desc, text_color=txtSoft, bgcolor=rb, text_size=txtSize, text_halign=text.align_left)
                    table.cell(t, 4, r, str.tostring(hits), text_color=txtMain, bgcolor=rb, text_size=txtSize)
                    table.cell(t, 5, r, st, text_color=now ? c : txtSoft, bgcolor=rb, text_size=txtSize)

        [outBar, outBg]
````
