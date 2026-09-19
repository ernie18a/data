<!-- tradingview-pine-id: PUB;45cf1936a5764434bcb3a4ab5276644d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FT_TV_Cond

Source: https://www.tradingview.com/script/S9e4GfDb-FT-TV-Cond/

## Description

FT_TV_Cond is a Pine Script® v6 library which provides reusable market-condition filters for systematic and algorithmic trading strategies.

The library operates on the structured OHLC and pre-calculated market context used by other strategies framework. It evaluates configurable conditions across the current Day/Session, previous completed periods and a broader five-period market context.

Available conditions cover a wide range of price-action concepts, including directional movement, OHLC relationships, breakouts, range and body expansion or contraction, recent extrema, crossovers, gaps, session development and multi-period market structure.

Main exported functionality

[*][pine]condition_day0()[/pine] — Evaluates conditions primarily related to the current Day/Session and current chart bars. Available filters include intraday directional movement, current OHLC relationships, new highs/lows, breakouts, range/body comparisons, session-start relationships and other current-period price-action structures.

[*][pine]condition_day1()[/pine] — Evaluates conditions centered on the previous completed Day/Session, comparing its Open, High, Low, Close, range and body with the current period and earlier historical periods.

[*][pine]condition_day2()[/pine] — Extends the same condition framework to the OHLC period two Day/Sessions back, allowing strategies to incorporate additional historical market structure.

[*][pine]condition_W()[/pine] — Evaluates broader five-period market conditions, including directional displacement, body-to-range relationships, position within recent extrema and other multi-period structures.

[*][pine]condition_day0_meaning()[/pine], [pine]condition_day1_meaning()[/pine], [pine]condition_day2_meaning()[/pine] and [pine]condition_W_meaning()[/pine] — Convert supported condition identifiers into human-readable explanations, making the selected trading logic easier to understand and inspect.

[*][pine]plot_condition_day0_info()[/pine], [pine]plot_condition_day1_info()[/pine], [pine]plot_condition_day2_info()[/pine] and [pine]plot_condition_W_info()[/pine] — Display optional information panels describing the selected condition, its practical meaning and whether OHLC calculations are based on calendar-day or custom-session data.

Framework integration

The condition evaluators are designed to work with the OHLC framework through two shared data structures:

[*][pine]FT_OHLC[/pine] — Contains the current and previous Day/Session OHLC periods.

[*][pine]PtnCtx[/pine] — Contains pre-calculated contextual values such as ranges, bodies, recent extrema and session-state information.

This architecture allows individual strategies to select and evaluate complex market filters without duplicating the underlying OHLC and contextual calculations.

Purpose

FT_TV_Cond is primarily intended as a shared condition-filtering dependency for other strategies. It separates reusable market-context conditions from the strategy's entry and trade-management logic, providing a consistent and modular filtering framework across multiple Pine Script® strategies.

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


library("FT_TV_Cond", overlay = true, dynamic_requests = true)


////////////////////////////////////////////////////////////////////////////////
// SWITCH EVALUATION 
////////////////////////////////////////////////////////////////////////////////
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


f_mid(_h, _l) => _l + (_h - _l) / 2.0

export condition_day0(string i_d0, array<float> FT_OHLC, array<float> PtnCtx) =>

    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")


    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)

    int barcount = int(nz(array.get(PtnCtx, 0), 0))

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

    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)

    float rng0 = high - low

	condition = switch i_d0
		"01: High rising (4 bars)" => high > high[1] and high[1] > high[2] and high[2] > high[3]
		"02: High > highD0[1]"     => high > highd0[1]
		"03: Low rising (4 bars)"  => low > low[1] and low[1] > low[2] and low[2] > low[3]
		"04: Close > OpenD0"       => close > opend0
		"05: Close rising (4 bars)"=> close > close[1] and close[1] > close[2] and close[2] > close[3]
		"06: Close > highD0[1]"    => close > highd0[1]
		"07: Bull bar & range > 2*ATR(45)" => close > open and (high - low) > AvgTrueRange(45) * 2.0
		"08: HighD0 > HighestH"    => highd0 > HighestH
		"09: HighD0 > HighestC"    => highd0 > HighestC
		"10 N0: Close > OpenD0" => close > opend0
		"10 N1: Close > OpenD1" => close > opend1
		"10 N2: Close > OpenD2" => close > opend2
		"10 N3: Close > OpenD3" => close > opend3
		"10 N4: Close > OpenD4" => close > opend4
		"10 N5: Close > OpenD5" => close > opend5

		"11 N1: Close > HighD1" => close > highd1
		"11 N2: Close > HighD2" => close > highd2
		"11 N3: Close > HighD3" => close > highd3
		"11 N4: Close > HighD4" => close > highd4
		"11 N5: Close > HighD5" => close > highd5

		"12 N1: Close > CloseD1" => close > closed1
		"12 N2: Close > CloseD2" => close > closed2
		"12 N3: Close > CloseD3" => close > closed3
		"12 N4: Close > CloseD4" => close > closed4
		"12 N5: Close > CloseD5" => close > closed5

		"13 N1: HighD0 > HighD1" => highd0 > highd1
		"13 N2: HighD0 > HighD2" => highd0 > highd2
		"13 N3: HighD0 > HighD3" => highd0 > highd3
		"13 N4: HighD0 > HighD4" => highd0 > highd4
		"13 N5: HighD0 > HighD5" => highd0 > highd5
		"14 N1: LowD0 > LowD1" => lowd0 > lowd1
		"14 N2: LowD0 > LowD2" => lowd0 > lowd2
		"14 N3: LowD0 > LowD3" => lowd0 > lowd3
		"14 N4: LowD0 > LowD4" => lowd0 > lowd4
		"14 N5: LowD0 > LowD5" => lowd0 > lowd5

		"15 N0: Close-OpenD0 > 0 & > 0.5*(HighD0-LowD0)" => (close - opend0) > 0 and (close - opend0) > 0.5 * (highd0 - lowd0)
		"15 N1: Close-OpenD1 > 0 & > 0.5*(HighD0-LowD1)" => (close - opend1) > 0 and (close - opend1) > 0.5 * (highd0 - lowd1)
		"15 N2: Close-OpenD2 > 0 & > 0.5*(HighD0-LowD2)" => (close - opend2) > 0 and (close - opend2) > 0.5 * (highd0 - lowd2)
		"15 N3: Close-OpenD3 > 0 & > 0.5*(HighD0-LowD3)" => (close - opend3) > 0 and (close - opend3) > 0.5 * (highd0 - lowd3)
		"15 N4: Close-OpenD4 > 0 & > 0.5*(HighD0-LowD4)" => (close - opend4) > 0 and (close - opend4) > 0.5 * (highd0 - lowd4)
		"15 N5: Close-OpenD5 > 0 & > 0.5*(HighD0-LowD5)" => (close - opend5) > 0 and (close - opend5) > 0.5 * (highd0 - lowd5)

		"16 N0: Close-OpenD0 > 0 & < 0.5*(HighD0-LowD0)" => (close - opend0) > 0 and (close - opend0) < 0.5 * (highd0 - lowd0)
		"16 N1: Close-OpenD1 > 0 & < 0.5*(HighD0-LowD1)" => (close - opend1) > 0 and (close - opend1) < 0.5 * (highd0 - lowd1)
		"16 N2: Close-OpenD2 > 0 & < 0.5*(HighD0-LowD2)" => (close - opend2) > 0 and (close - opend2) < 0.5 * (highd0 - lowd2)
		"16 N3: Close-OpenD3 > 0 & < 0.5*(HighD0-LowD3)" => (close - opend3) > 0 and (close - opend3) < 0.5 * (highd0 - lowd3)
		"16 N4: Close-OpenD4 > 0 & < 0.5*(HighD0-LowD4)" => (close - opend4) > 0 and (close - opend4) < 0.5 * (highd0 - lowd4)
		"16 N5: Close-OpenD5 > 0 & < 0.5*(HighD0-LowD5)" => (close - opend5) > 0 and (close - opend5) < 0.5 * (highd0 - lowd5)

		"17: HighD0 > HighD1,D2,D3" => highd0 > highd1 and highd0 > highd2 and highd0 > highd3
		"18: Close > CloseD1,D2,D3" => close > closed1 and close > closed2 and close > closed3

		"19 N1: LowD0 > CloseD1" => lowd0 > closed1
		"19 N2: LowD0 > CloseD2" => lowd0 > closed2
		"19 N3: LowD0 > CloseD3" => lowd0 > closed3
		"19 N4: LowD0 > CloseD4" => lowd0 > closed4
		"19 N5: LowD0 > CloseD5" => lowd0 > closed5

		"20 N1: LowD0 > HighD1" => lowd0 > highd1
		"20 N2: LowD0 > HighD2" => lowd0 > highd2
		"20 N3: LowD0 > HighD3" => lowd0 > highd3
		"20 N4: LowD0 > HighD4" => lowd0 > highd4
		"20 N5: LowD0 > HighD5" => lowd0 > highd5

		"21 N1: HighD0 > CloseD1" => highd0 > closed1
		"21 N2: HighD0 > CloseD2" => highd0 > closed2
		"21 N3: HighD0 > CloseD3" => highd0 > closed3
		"21 N4: HighD0 > CloseD4" => highd0 > closed4
		"21 N5: HighD0 > CloseD5" => highd0 > closed5

		"22 N1: OpenD0 > CloseD1" => opend0 > closed1
		"22 N2: OpenD0 > CloseD2" => opend0 > closed2
		"22 N3: OpenD0 > CloseD3" => opend0 > closed3
		"22 N4: OpenD0 > CloseD4" => opend0 > closed4
		"22 N5: OpenD0 > CloseD5" => opend0 > closed5

		"23 N1: OpenD0 > HighD1" => opend0 > highd1
		"23 N2: OpenD0 > HighD2" => opend0 > highd2
		"23 N3: OpenD0 > HighD3" => opend0 > highd3
		"23 N4: OpenD0 > HighD4" => opend0 > highd4
		"23 N5: OpenD0 > HighD5" => opend0 > highd5

		"24 N1: OpenD0 > LowD1" => opend0 > lowd1
		"24 N2: OpenD0 > LowD2" => opend0 > lowd2
		"24 N3: OpenD0 > LowD3" => opend0 > lowd3
		"24 N4: OpenD0 > LowD4" => opend0 > lowd4
		"24 N5: OpenD0 > LowD5" => opend0 > lowd5

		"25 N0: Close>OpenD0 & RangeD0>RangeD1..D5" => close > opend0 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
		"25 N1: Close>OpenD1 & RangeD0>RangeD1..D5" => close > opend1 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
		"25 N2: Close>OpenD2 & RangeD0>RangeD1..D5" => close > opend2 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
		"25 N3: Close>OpenD3 & RangeD0>RangeD1..D5" => close > opend3 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
		"25 N4: Close>OpenD4 & RangeD0>RangeD1..D5" => close > opend4 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
		"25 N5: Close>OpenD5 & RangeD0>RangeD1..D5" => close > opend5 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5

		"26 N0: Close>OpenD0 & |BodyD0|>|BodyD1..D5|" => close > opend0 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
		"26 N1: Close>OpenD1 & |BodyD0|>|BodyD1..D5|" => close > opend1 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
		"26 N2: Close>OpenD2 & |BodyD0|>|BodyD1..D5|" => close > opend2 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
		"26 N3: Close>OpenD3 & |BodyD0|>|BodyD1..D5|" => close > opend3 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
		"26 N4: Close>OpenD4 & |BodyD0|>|BodyD1..D5|" => close > opend4 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
		"26 N5: Close>OpenD5 & |BodyD0|>|BodyD1..D5|" => close > opend5 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)

		"27: Close > HighestC" => close > HighestC
		"28: OpenD0 > HighestO" => opend0 > HighestO
		"29: LowD0 > HighestL" => lowd0 > HighestL
		"30: Close > LowestH" => close > LowestH

		"32 N1: Close crosses above HighD1" => ta.crossover(close, highd1)
		"32 N2: Close crosses above HighD2" => ta.crossover(close, highd2)
		"32 N3: Close crosses above HighD3" => ta.crossover(close, highd3)
		"32 N4: Close crosses above HighD4" => ta.crossover(close, highd4)
		"32 N5: Close crosses above HighD5" => ta.crossover(close, highd5)

		"33 N1: Close crosses above CloseD1" => ta.crossover(close, closed1)
		"33 N2: Close crosses above CloseD2" => ta.crossover(close, closed2)
		"33 N3: Close crosses above CloseD3" => ta.crossover(close, closed3)
		"33 N4: Close crosses above CloseD4" => ta.crossover(close, closed4)
		"33 N5: Close crosses above CloseD5" => ta.crossover(close, closed5)

		"34: Close crosses above HighestH" => ta.crossover(close, HighestH)

		"35 N1: HighD0 > Mid(HighD1,LowD1)" => highd0 > f_mid(highd1, lowd1)
		"35 N2: HighD0 > Mid(HighD2,LowD2)" => highd0 > f_mid(highd2, lowd2)
		"35 N3: HighD0 > Mid(HighD3,LowD3)" => highd0 > f_mid(highd3, lowd3)
		"35 N4: HighD0 > Mid(HighD4,LowD4)" => highd0 > f_mid(highd4, lowd4)
		"35 N5: HighD0 > Mid(HighD5,LowD5)" => highd0 > f_mid(highd5, lowd5)

		"36 N1: LowD0  > Mid(HighD1,LowD1)" => lowd0 > f_mid(highd1, lowd1)
		"36 N2: LowD0  > Mid(HighD2,LowD2)" => lowd0 > f_mid(highd2, lowd2)
		"36 N3: LowD0  > Mid(HighD3,LowD3)" => lowd0 > f_mid(highd3, lowd3)
		"36 N4: LowD0  > Mid(HighD4,LowD4)" => lowd0 > f_mid(highd4, lowd4)
		"36 N5: LowD0  > Mid(HighD5,LowD5)" => lowd0 > f_mid(highd5, lowd5)

		"37: barcount>3 & Close crosses above sessStartLow" => barcount > 3 and ta.crossover(close, sessStartLow)
		"38: barcount>3 & Close crosses above sessStartHigh" => barcount > 3 and ta.crossover(close, sessStartHigh)
		"39: barcount>3 & Close crosses above OpenD0" => barcount > 3 and ta.crossover(close, opend0)
		"40: barcount>3 & (OpenD0-LowD0) < (HighD0-OpenD0)" => barcount > 3 and (opend0 - lowd0) < (highd0 - opend0)
		"41: barcount>3 & HighD0 > sessStartHigh+sessStartRange" => barcount > 3 and highd0 > (sessStartHigh + sessStartRange)
		"42: barcount>3 & Close  > sessStartHigh+sessStartRange" => barcount > 3 and close > (sessStartHigh + sessStartRange)



        "01: Low falling (4 bars)" => low < low[1] and low[1] < low[2] and low[2] < low[3]
        "02: Low < lowD0[1]" => low < lowd0[1]
        "03: High falling (4 bars)" => high < high[1] and high[1] < high[2] and high[2] < high[3]
        "04: Close < OpenD0" => close < opend0
        "05: Close falling (4 bars)" => close < close[1] and close[1] < close[2] and close[2] < close[3]
        "06: Close < lowD0[1]" => close < lowd0[1]
        "07: Bear bar & range > 2*ATR(45)" => close < open and (high - low) > AvgTrueRange(45) * 2.0
        "08: LowD0 < LowestL" => lowd0 < LowestL
        "09: LowD0 < LowestC" => lowd0 < LowestC

        "10 N0: Close < OpenD0" => close < opend0
        "10 N1: Close < OpenD1" => close < opend1
        "10 N2: Close < OpenD2" => close < opend2
        "10 N3: Close < OpenD3" => close < opend3
        "10 N4: Close < OpenD4" => close < opend4
        "10 N5: Close < OpenD5" => close < opend5

        "11 N1: Close < LowD1" => close < lowd1
        "11 N2: Close < LowD2" => close < lowd2
        "11 N3: Close < LowD3" => close < lowd3
        "11 N4: Close < LowD4" => close < lowd4
        "11 N5: Close < LowD5" => close < lowd5

        "12 N1: Close < CloseD1" => close < closed1
        "12 N2: Close < CloseD2" => close < closed2
        "12 N3: Close < CloseD3" => close < closed3
        "12 N4: Close < CloseD4" => close < closed4
        "12 N5: Close < CloseD5" => close < closed5

        "13 N1: LowD0 < LowD1" => lowd0 < lowd1
        "13 N2: LowD0 < LowD2" => lowd0 < lowd2
        "13 N3: LowD0 < LowD3" => lowd0 < lowd3
        "13 N4: LowD0 < LowD4" => lowd0 < lowd4
        "13 N5: LowD0 < LowD5" => lowd0 < lowd5

        "14 N1: HighD0 < HighD1" => highd0 < highd1
        "14 N2: HighD0 < HighD2" => highd0 < highd2
        "14 N3: HighD0 < HighD3" => highd0 < highd3
        "14 N4: HighD0 < HighD4" => highd0 < highd4
        "14 N5: HighD0 < HighD5" => highd0 < highd5

        "15 N0: OpenD0-Close>0 & >0.5*(HighD0-LowD0)" => (opend0 - close) > 0 and (opend0 - close) > 0.5 * (highd0 - lowd0)
        "15 N1: OpenD1-Close>0 & >0.5*(HighD0-LowD1)" => (opend1 - close) > 0 and (opend1 - close) > 0.5 * (highd0 - lowd1)
        "15 N2: OpenD2-Close>0 & >0.5*(HighD0-LowD2)" => (opend2 - close) > 0 and (opend2 - close) > 0.5 * (highd0 - lowd2)
        "15 N3: OpenD3-Close>0 & >0.5*(HighD0-LowD3)" => (opend3 - close) > 0 and (opend3 - close) > 0.5 * (highd0 - lowd3)
        "15 N4: OpenD4-Close>0 & >0.5*(HighD0-LowD4)" => (opend4 - close) > 0 and (opend4 - close) > 0.5 * (highd0 - lowd4)
        "15 N5: OpenD5-Close>0 & >0.5*(HighD0-LowD5)" => (opend5 - close) > 0 and (opend5 - close) > 0.5 * (highd0 - lowd5)

        "16 N0: OpenD0-Close>0 & <0.5*(HighD0-LowD0)" => (opend0 - close) > 0 and (opend0 - close) < 0.5 * (highd0 - lowd0)
        "16 N1: OpenD1-Close>0 & <0.5*(HighD0-LowD1)" => (opend1 - close) > 0 and (opend1 - close) < 0.5 * (highd0 - lowd1)
        "16 N2: OpenD2-Close>0 & <0.5*(HighD0-LowD2)" => (opend2 - close) > 0 and (opend2 - close) < 0.5 * (highd0 - lowd2)
        "16 N3: OpenD3-Close>0 & <0.5*(HighD0-LowD3)" => (opend3 - close) > 0 and (opend3 - close) < 0.5 * (highd0 - lowd3)
        "16 N4: OpenD4-Close>0 & <0.5*(HighD0-LowD4)" => (opend4 - close) > 0 and (opend4 - close) < 0.5 * (highd0 - lowd4)
        "16 N5: OpenD5-Close>0 & <0.5*(HighD0-LowD5)" => (opend5 - close) > 0 and (opend5 - close) < 0.5 * (highd0 - lowd5)

        "17: LowD0 < LowD1,D2,D3" => lowd0 < lowd1 and lowd0 < lowd2 and lowd0 < lowd3
        "18: Close < CloseD1,D2,D3" => close < closed1 and close < closed2 and close < closed3

        "19 N1: HighD0 < CloseD1" => highd0 < closed1
        "19 N2: HighD0 < CloseD2" => highd0 < closed2
        "19 N3: HighD0 < CloseD3" => highd0 < closed3
        "19 N4: HighD0 < CloseD4" => highd0 < closed4
        "19 N5: HighD0 < CloseD5" => highd0 < closed5

        "20 N1: HighD0 < LowD1" => highd0 < lowd1
        "20 N2: HighD0 < LowD2" => highd0 < lowd2
        "20 N3: HighD0 < LowD3" => highd0 < lowd3
        "20 N4: HighD0 < LowD4" => highd0 < lowd4
        "20 N5: HighD0 < LowD5" => highd0 < lowd5

        "21 N1: LowD0  < CloseD1" => lowd0 < closed1
        "21 N2: LowD0  < CloseD2" => lowd0 < closed2
        "21 N3: LowD0  < CloseD3" => lowd0 < closed3
        "21 N4: LowD0  < CloseD4" => lowd0 < closed4
        "21 N5: LowD0  < CloseD5" => lowd0 < closed5

        "22 N1: OpenD0 < CloseD1" => opend0 < closed1
        "22 N2: OpenD0 < CloseD2" => opend0 < closed2
        "22 N3: OpenD0 < CloseD3" => opend0 < closed3
        "22 N4: OpenD0 < CloseD4" => opend0 < closed4
        "22 N5: OpenD0 < CloseD5" => opend0 < closed5

        "23 N1: OpenD0 < LowD1" => opend0 < lowd1
        "23 N2: OpenD0 < LowD2" => opend0 < lowd2
        "23 N3: OpenD0 < LowD3" => opend0 < lowd3
        "23 N4: OpenD0 < LowD4" => opend0 < lowd4
        "23 N5: OpenD0 < LowD5" => opend0 < lowd5

        "24 N1: OpenD0 < HighD1" => opend0 < highd1
        "24 N2: OpenD0 < HighD2" => opend0 < highd2
        "24 N3: OpenD0 < HighD3" => opend0 < highd3
        "24 N4: OpenD0 < HighD4" => opend0 < highd4
        "24 N5: OpenD0 < HighD5" => opend0 < highd5

        "25 N0: Close<OpenD0 & RangeD0>RangeD1..D5" => close < opend0 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
        "25 N1: Close<OpenD1 & RangeD0>RangeD1..D5" => close < opend1 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
        "25 N2: Close<OpenD2 & RangeD0>RangeD1..D5" => close < opend2 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
        "25 N3: Close<OpenD3 & RangeD0>RangeD1..D5" => close < opend3 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
        "25 N4: Close<OpenD4 & RangeD0>RangeD1..D5" => close < opend4 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5
        "25 N5: Close<OpenD5 & RangeD0>RangeD1..D5" => close < opend5 and rangeD0 > rangeD1 and rangeD0 > rangeD2 and rangeD0 > rangeD3 and rangeD0 > rangeD4 and rangeD0 > rangeD5

        "26 N0: Close<OpenD0 & |BodyD0|>|BodyD1..D5|" => close < opend0 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
        "26 N1: Close<OpenD1 & |BodyD0|>|BodyD1..D5|" => close < opend1 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5) 
        "26 N2: Close<OpenD2 & |BodyD0|>|BodyD1..D5|" => close < opend2 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
        "26 N3: Close<OpenD3 & |BodyD0|>|BodyD1..D5|" => close < opend3 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
        "26 N4: Close<OpenD4 & |BodyD0|>|BodyD1..D5|" => close < opend4 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)
        "26 N5: Close<OpenD5 & |BodyD0|>|BodyD1..D5|" => close < opend5 and math.abs(bodyD0) > math.abs(bodyD1) and math.abs(bodyD0) > math.abs(bodyD2) and math.abs(bodyD0) > math.abs(bodyD3) and math.abs(bodyD0) > math.abs(bodyD4) and math.abs(bodyD0) > math.abs(bodyD5)

        "27: Close < LowestC" => close < LowestC
        "28: OpenD0 < LowestO" => opend0 < LowestO
        "29: HighD0 < LowestH" => highd0 < LowestH
        "30: Close < HighestL" => close < HighestL

        "32 N1: Close crosses below LowD1" => ta.crossunder(close, lowd1)
        "32 N2: Close crosses below LowD2" => ta.crossunder(close, lowd2)
        "32 N3: Close crosses below LowD3" => ta.crossunder(close, lowd3)
        "32 N4: Close crosses below LowD4" => ta.crossunder(close, lowd4)
        "32 N5: Close crosses below LowD5" => ta.crossunder(close, lowd5)

        "33 N1: Close crosses below CloseD1" => ta.crossunder(close, closed1)
        "33 N2: Close crosses below CloseD2" => ta.crossunder(close, closed2)
        "33 N3: Close crosses below CloseD3" => ta.crossunder(close, closed3)
        "33 N4: Close crosses below CloseD4" => ta.crossunder(close, closed4)
        "33 N5: Close crosses below CloseD5" => ta.crossunder(close, closed5)

        "34: Close crosses below LowestL" => ta.crossunder(close, LowestL)

        "35 N1: LowD0  < Mid(HighD1,LowD1)" => lowd0 < (lowd1 + (highd1 - lowd1) / 2.0)
        "35 N2: LowD0  < Mid(HighD2,LowD2)" => lowd0 < (lowd2 + (highd2 - lowd2) / 2.0)
        "35 N3: LowD0  < Mid(HighD3,LowD3)" => lowd0 < (lowd3 + (highd3 - lowd3) / 2.0)
        "35 N4: LowD0  < Mid(HighD4,LowD4)" => lowd0 < (lowd4 + (highd4 - lowd4) / 2.0)
        "35 N5: LowD0  < Mid(HighD5,LowD5)" => lowd0 < (lowd5 + (highd5 - lowd5) / 2.0)

        "36 N1: HighD0 < Mid(HighD1,LowD1)" => highd0 < (lowd1 + (highd1 - lowd1) / 2.0)
        "36 N2: HighD0 < Mid(HighD2,LowD2)" => highd0 < (lowd2 + (highd2 - lowd2) / 2.0)
        "36 N3: HighD0 < Mid(HighD3,LowD3)" => highd0 < (lowd3 + (highd3 - lowd3) / 2.0)
        "36 N4: HighD0 < Mid(HighD4,LowD4)" => highd0 < (lowd4 + (highd4 - lowd4) / 2.0)
        "36 N5: HighD0 < Mid(HighD5,LowD5)" => highd0 < (lowd5 + (highd5 - lowd5) / 2.0)

        "37: barcount>3 & Close crosses below sessStartHigh" => barcount > 3 and ta.crossunder(close, sessStartHigh)
        "38: barcount>3 & Close crosses below sessStartLow" => barcount > 3 and ta.crossunder(close, sessStartLow)
        "39: barcount>3 & Close crosses below OpenD0" => barcount > 3 and ta.crossunder(close, opend0)
        "40: barcount>3 & (OpenD0-LowD0) > (HighD0-OpenD0)" => barcount > 3 and (opend0 - lowd0) > (highd0 - opend0)
        "41: barcount>3 & LowD0  < sessStartLow - sessStartRange" => barcount > 3 and lowd0 < (sessStartLow - sessStartRange)
        "42: barcount>3 & Close  < sessStartLow - sessStartRange" => barcount > 3 and close < (sessStartLow - sessStartRange)

		"43: Always true" => true
		=> true

	condition





export condition_day1(string i_d1, array<float> FT_OHLC, array<float> PtnCtx) =>


    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")


    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)


    int barcount = int(nz(array.get(PtnCtx, 0), 0))

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


    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)


    float rng0 = high - low

	condition = switch i_d1
        "01 N0: CloseD1 > OpenD0" => closed1 > opend0
        "01 N1: CloseD1 > OpenD1" => closed1 > opend1
        "01 N2: CloseD1 > OpenD2" => closed1 > opend2
        "01 N3: CloseD1 > OpenD3" => closed1 > opend3
        "01 N4: CloseD1 > OpenD4" => closed1 > opend4
        "01 N5: CloseD1 > OpenD5" => closed1 > opend5

        "02 N0: CloseD1 > HighD0" => closed1 > highd0
        "02 N2: CloseD1 > HighD2" => closed1 > highd2
        "02 N3: CloseD1 > HighD3" => closed1 > highd3
        "02 N4: CloseD1 > HighD4" => closed1 > highd4
        "02 N5: CloseD1 > HighD5" => closed1 > highd5

        "03 N0: CloseD1 > CloseD0" => closed1 > closed0
        "03 N2: CloseD1 > CloseD2" => closed1 > closed2
        "03 N3: CloseD1 > CloseD3" => closed1 > closed3
        "03 N4: CloseD1 > CloseD4" => closed1 > closed4
        "03 N5: CloseD1 > CloseD5" => closed1 > closed5

        "04 N0: HighD1 > HighD0" => highd1 > highd0
        "04 N2: HighD1 > HighD2" => highd1 > highd2
        "04 N3: HighD1 > HighD3" => highd1 > highd3
        "04 N4: HighD1 > HighD4" => highd1 > highd4
        "04 N5: HighD1 > HighD5" => highd1 > highd5

        "05 N0: LowD1 > LowD0" => lowd1 > lowd0
        "05 N2: LowD1 > LowD2" => lowd1 > lowd2
        "05 N3: LowD1 > LowD3" => lowd1 > lowd3
        "05 N4: LowD1 > LowD4" => lowd1 > lowd4
        "05 N5: LowD1 > LowD5" => lowd1 > lowd5

        "06 N0: CloseD1-OpenD0>0 & >0.25*(HighD1-LowD0)" => (closed1 - opend0) > 0 and (closed1 - opend0) > 0.25 * (highd1 - lowd0)
        "06 N1: CloseD1-OpenD1>0 & >0.25*(HighD1-LowD1)" => (closed1 - opend1) > 0 and (closed1 - opend1) > 0.25 * (highd1 - lowd1)
        "06 N2: CloseD1-OpenD2>0 & >0.25*(HighD1-LowD2)" => (closed1 - opend2) > 0 and (closed1 - opend2) > 0.25 * (highd1 - lowd2)
        "06 N3: CloseD1-OpenD3>0 & >0.25*(HighD1-LowD3)" => (closed1 - opend3) > 0 and (closed1 - opend3) > 0.25 * (highd1 - lowd3)
        "06 N4: CloseD1-OpenD4>0 & >0.25*(HighD1-LowD4)" => (closed1 - opend4) > 0 and (closed1 - opend4) > 0.25 * (highd1 - lowd4)
        "06 N5: CloseD1-OpenD5>0 & >0.25*(HighD1-LowD5)" => (closed1 - opend5) > 0 and (closed1 - opend5) > 0.25 * (highd1 - lowd5)

        "07 N0: CloseD1-OpenD0>0 & <0.75*(HighD1-LowD0)" => (closed1 - opend0) > 0 and (closed1 - opend0) < 0.75 * (highd1 - lowd0)
        "07 N1: CloseD1-OpenD1>0 & <0.75*(HighD1-LowD1)" => (closed1 - opend1) > 0 and (closed1 - opend1) < 0.75 * (highd1 - lowd1)
        "07 N2: CloseD1-OpenD2>0 & <0.75*(HighD1-LowD2)" => (closed1 - opend2) > 0 and (closed1 - opend2) < 0.75 * (highd1 - lowd2)
        "07 N3: CloseD1-OpenD3>0 & <0.75*(HighD1-LowD3)" => (closed1 - opend3) > 0 and (closed1 - opend3) < 0.75 * (highd1 - lowd3)
        "07 N4: CloseD1-OpenD4>0 & <0.75*(HighD1-LowD4)" => (closed1 - opend4) > 0 and (closed1 - opend4) < 0.75 * (highd1 - lowd4)
        "07 N5: CloseD1-OpenD5>0 & <0.75*(HighD1-LowD5)" => (closed1 - opend5) > 0 and (closed1 - opend5) < 0.75 * (highd1 - lowd5)

        "08: HighD1 > HighD2,D3,D4" => highd1 > highd2 and highd1 > highd3 and highd1 > highd4
        "08: HighD1 > HighD2,D3" => highd1 > highd2 and highd1 > highd3
        "09: CloseD1 > CloseD2,D3,D4" => closed1 > closed2 and closed1 > closed3 and closed1 > closed4

        "10 N0: LowD1 > CloseD0" => lowd1 > closed0
        "10 N2: LowD1 > CloseD2" => lowd1 > closed2
        "10 N3: LowD1 > CloseD3" => lowd1 > closed3
        "10 N4: LowD1 > CloseD4" => lowd1 > closed4
        "10 N5: LowD1 > CloseD5" => lowd1 > closed5

        "11 N0: LowD1 > HighD0" => lowd1 > highd0
        "11 N2: LowD1 > HighD2" => lowd1 > highd2
        "11 N3: LowD1 > HighD3" => lowd1 > highd3
        "11 N4: LowD1 > HighD4" => lowd1 > highd4
        "11 N5: LowD1 > HighD5" => lowd1 > highd5

        "12 N0: HighD1 > CloseD0" => highd1 > closed0
        "12 N2: HighD1 > CloseD2" => highd1 > closed2
        "12 N3: HighD1 > CloseD3" => highd1 > closed3
        "12 N4: HighD1 > CloseD4" => highd1 > closed4
        "12 N5: HighD1 > CloseD5" => highd1 > closed5

        "13 N0: OpenD1 > CloseD0" => opend1 > closed0
        "13 N1: OpenD1 > CloseD1" => opend1 > closed1
        "13 N2: OpenD1 > CloseD2" => opend1 > closed2
        "13 N3: OpenD1 > CloseD3" => opend1 > closed3
        "13 N4: OpenD1 > CloseD4" => opend1 > closed4
        "13 N5: OpenD1 > CloseD5" => opend1 > closed5

        "14 N0: OpenD1 > HighD0" => opend1 > highd0
        "14 N2: OpenD1 > HighD2" => opend1 > highd2
        "14 N3: OpenD1 > HighD3" => opend1 > highd3
        "14 N4: OpenD1 > HighD4" => opend1 > highd4
        "14 N5: OpenD1 > HighD5" => opend1 > highd5

        "15 N0: OpenD1 > LowD0" => opend1 > lowd0
        "15 N2: OpenD1 > LowD2" => opend1 > lowd2
        "15 N3: OpenD1 > LowD3" => opend1 > lowd3
        "15 N4: OpenD1 > LowD4" => opend1 > lowd4
        "15 N5: OpenD1 > LowD5" => opend1 > lowd5

        "16 N0: CloseD1>OpenD0 & RangeD1>RangeD2..D5" => closed1 > opend0 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N1: CloseD1>OpenD1 & RangeD1>RangeD2..D5" => closed1 > opend1 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N2: CloseD1>OpenD2 & RangeD1>RangeD2..D5" => closed1 > opend2 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N3: CloseD1>OpenD3 & RangeD1>RangeD2..D5" => closed1 > opend3 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N4: CloseD1>OpenD4 & RangeD1>RangeD2..D5" => closed1 > opend4 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N5: CloseD1>OpenD5 & RangeD1>RangeD2..D5" => closed1 > opend5 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5

        "17 N0: CloseD1>OpenD0 & |BodyD1|>|BodyD2..D5|" => closed1 > opend0 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N1: CloseD1>OpenD1 & |BodyD1|>|BodyD2..D5|" => closed1 > opend1 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N2: CloseD1>OpenD2 & |BodyD1|>|BodyD2..D5|" => closed1 > opend2 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N3: CloseD1>OpenD3 & |BodyD1|>|BodyD2..D5|" => closed1 > opend3 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N4: CloseD1>OpenD4 & |BodyD1|>|BodyD2..D5|" => closed1 > opend4 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N5: CloseD1>OpenD5 & |BodyD1|>|BodyD2..D5|" => closed1 > opend5 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)

        "18: HighD1 == HighestH" => highd1 == HighestH
        "19: CloseD1 == HighestC" => closed1 == HighestC
        "20: OpenD1 == HighestO" => opend1 == HighestO
        "21: HighD1 > HighestC" => highd1 > HighestC
        "22: LowD1  > LowestH" => lowd1 > LowestH
        "23: CloseD1 > LowestH" => closed1 > LowestH

        "24 N0: CloseD1>CloseD0 & LowD1>LowD0" => closed1 > closed0 and lowd1 > lowd0
        "24 N2: CloseD1>CloseD2 & LowD1>LowD2" => closed1 > closed2 and lowd1 > lowd2
        "24 N3: CloseD1>CloseD3 & LowD1>LowD3" => closed1 > closed3 and lowd1 > lowd3
        "24 N4: CloseD1>CloseD4 & LowD1>LowD4" => closed1 > closed4 and lowd1 > lowd4
        "24 N5: CloseD1>CloseD5 & LowD1>LowD5" => closed1 > closed5 and lowd1 > lowd5

        "25 N0: CloseD1>OpenD0 & LowD1>LowD0" => closed1 > opend0 and lowd1 > lowd0
        "25 N2: CloseD1>OpenD2 & LowD1>LowD2" => closed1 > opend2 and lowd1 > lowd2
        "25 N3: CloseD1>OpenD3 & LowD1>LowD3" => closed1 > opend3 and lowd1 > lowd3
        "25 N4: CloseD1>OpenD4 & LowD1>LowD4" => closed1 > opend4 and lowd1 > lowd4
        "25 N5: CloseD1>OpenD5 & LowD1>LowD5" => closed1 > opend5 and lowd1 > lowd5

        "26: CloseD1>OpenD1 & CloseD2>OpenD2" => closed1 > opend1 and closed2 > opend2

        "27 N0: RangeD1 > RangeD0" => rangeD1 > rangeD0
        "27 N2: RangeD1 > RangeD2" => rangeD1 > rangeD2
        "27 N3: RangeD1 > RangeD3" => rangeD1 > rangeD3
        "27 N4: RangeD1 > RangeD4" => rangeD1 > rangeD4
        "27 N5: RangeD1 > RangeD5" => rangeD1 > rangeD5

        "28 N0: CloseD1>Opend1 & RangeD1>RangeD0" => closed1 > opend1 and rangeD1 > rangeD0
        "28 N2: CloseD1>Opend1 & RangeD1>RangeD2" => closed1 > opend1 and rangeD1 > rangeD2
        "28 N3: CloseD1>Opend1 & RangeD1>RangeD3" => closed1 > opend1 and rangeD1 > rangeD3
        "28 N4: CloseD1>Opend1 & RangeD1>RangeD4" => closed1 > opend1 and rangeD1 > rangeD4
        "28 N5: CloseD1>Opend1 & RangeD1>RangeD5" => closed1 > opend1 and rangeD1 > rangeD5



        "01 N0: CloseD1 < OpenD0" => closed1 < opend0
        "01 N1: CloseD1 < OpenD1" => closed1 < opend1
        "01 N2: CloseD1 < OpenD2" => closed1 < opend2
        "01 N3: CloseD1 < OpenD3" => closed1 < opend3
        "01 N4: CloseD1 < OpenD4" => closed1 < opend4
        "01 N5: CloseD1 < OpenD5" => closed1 < opend5

        "02 N0: CloseD1 < LowD0" => closed1 < lowd0
        "02 N2: CloseD1 < LowD2" => closed1 < lowd2
        "02 N3: CloseD1 < LowD3" => closed1 < lowd3
        "02 N4: CloseD1 < LowD4" => closed1 < lowd4
        "02 N5: CloseD1 < LowD5" => closed1 < lowd5

        "03 N0: CloseD1 < CloseD0" => closed1 < closed0
        "03 N2: CloseD1 < CloseD2" => closed1 < closed2
        "03 N3: CloseD1 < CloseD3" => closed1 < closed3
        "03 N4: CloseD1 < CloseD4" => closed1 < closed4
        "03 N5: CloseD1 < CloseD5" => closed1 < closed5

        "04 N0: LowD1 < LowD0" => lowd1 < lowd0
        "04 N2: LowD1 < LowD2" => lowd1 < lowd2
        "04 N3: LowD1 < LowD3" => lowd1 < lowd3
        "04 N4: LowD1 < LowD4" => lowd1 < lowd4
        "04 N5: LowD1 < LowD5" => lowd1 < lowd5

        "05 N0: HighD1 < HighD0" => highd1 < highd0
        "05 N2: HighD1 < HighD2" => highd1 < highd2
        "05 N3: HighD1 < HighD3" => highd1 < highd3
        "05 N4: HighD1 < HighD4" => highd1 < highd4
        "05 N5: HighD1 < HighD5" => highd1 < highd5

        "06 N0: OpenD0-CloseD1>0 & >0.25*(HighD1-LowD0)" => (opend0 - closed1) > 0 and (opend0 - closed1) > 0.25 * (highd1 - lowd0)
        "06 N1: OpenD1-CloseD1>0 & >0.25*(HighD1-LowD1)" => (opend1 - closed1) > 0 and (opend1 - closed1) > 0.25 * (highd1 - lowd1)
        "06 N2: OpenD2-CloseD1>0 & >0.25*(HighD1-LowD2)" => (opend2 - closed1) > 0 and (opend2 - closed1) > 0.25 * (highd1 - lowd2)
        "06 N3: OpenD3-CloseD1>0 & >0.25*(HighD1-LowD3)" => (opend3 - closed1) > 0 and (opend3 - closed1) > 0.25 * (highd1 - lowd3)
        "06 N4: OpenD4-CloseD1>0 & >0.25*(HighD1-LowD4)" => (opend4 - closed1) > 0 and (opend4 - closed1) > 0.25 * (highd1 - lowd4)
        "06 N5: OpenD5-CloseD1>0 & >0.25*(HighD1-LowD5)" => (opend5 - closed1) > 0 and (opend5 - closed1) > 0.25 * (highd1 - lowd5)

        "07 N0: OpenD0-CloseD1>0 & <0.75*(HighD1-LowD0)" => (opend0 - closed1) > 0 and (opend0 - closed1) < 0.75 * (highd1 - lowd0)
        "07 N1: OpenD1-CloseD1>0 & <0.75*(HighD1-LowD1)" => (opend1 - closed1) > 0 and (opend1 - closed1) < 0.75 * (highd1 - lowd1)
        "07 N2: OpenD2-CloseD1>0 & <0.75*(HighD1-LowD2)" => (opend2 - closed1) > 0 and (opend2 - closed1) < 0.75 * (highd1 - lowd2)
        "07 N3: OpenD3-CloseD1>0 & <0.75*(HighD1-LowD3)" => (opend3 - closed1) > 0 and (opend3 - closed1) < 0.75 * (highd1 - lowd3)
        "07 N4: OpenD4-CloseD1>0 & <0.75*(HighD1-LowD4)" => (opend4 - closed1) > 0 and (opend4 - closed1) < 0.75 * (highd1 - lowd4)
        "07 N5: OpenD5-CloseD1>0 & <0.75*(HighD1-LowD5)" => (opend5 - closed1) > 0 and (opend5 - closed1) < 0.75 * (highd1 - lowd5)

        "08: LowD1 < LowD2,D3,D4" => lowd1 < lowd2 and lowd1 < lowd3 and lowd1 < lowd4
        "08: LowD1 < LowD2,D3" => lowd1 < lowd2 and lowd1 < lowd3
        "09: CloseD1 < CloseD2,D3,D4" => closed1 < closed2 and closed1 < closed3 and closed1 < closed4

        "10 N0: HighD1 < CloseD0" => highd1 < closed0
        "10 N2: HighD1 < CloseD2" => highd1 < closed2
        "10 N3: HighD1 < CloseD3" => highd1 < closed3
        "10 N4: HighD1 < CloseD4" => highd1 < closed4
        "10 N5: HighD1 < CloseD5" => highd1 < closed5

        "11 N0: HighD1 < LowD0" => highd1 < lowd0
        "11 N2: HighD1 < LowD2" => highd1 < lowd2
        "11 N3: HighD1 < LowD3" => highd1 < lowd3
        "11 N4: HighD1 < LowD4" => highd1 < lowd4
        "11 N5: HighD1 < LowD5" => highd1 < lowd5

        "12 N0: LowD1  < CloseD0" => lowd1 < closed0
        "12 N2: LowD1  < CloseD2" => lowd1 < closed2
        "12 N3: LowD1  < CloseD3" => lowd1 < closed3
        "12 N4: LowD1  < CloseD4" => lowd1 < closed4
        "12 N5: LowD1  < CloseD5" => lowd1 < closed5

        "13 N0: OpenD1 < CloseD0" => opend1 < closed0
        "13 N1: OpenD1 < CloseD1" => opend1 < closed1
        "13 N2: OpenD1 < CloseD2" => opend1 < closed2
        "13 N3: OpenD1 < CloseD3" => opend1 < closed3
        "13 N4: OpenD1 < CloseD4" => opend1 < closed4
        "13 N5: OpenD1 < CloseD5" => opend1 < closed5

        "14 N0: OpenD1 < LowD0" => opend1 < lowd0
        "14 N2: OpenD1 < LowD2" => opend1 < lowd2
        "14 N3: OpenD1 < LowD3" => opend1 < lowd3
        "14 N4: OpenD1 < LowD4" => opend1 < lowd4
        "14 N5: OpenD1 < LowD5" => opend1 < lowd5

        "15 N0: OpenD1 < HighD0" => opend1 < highd0
        "15 N2: OpenD1 < HighD2" => opend1 < highd2
        "15 N3: OpenD1 < HighD3" => opend1 < highd3
        "15 N4: OpenD1 < HighD4" => opend1 < highd4
        "15 N5: OpenD1 < HighD5" => opend1 < highd5

        "16 N0: CloseD1<OpenD0 & RangeD1>RangeD2..D5" => closed1 < opend0 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N1: CloseD1<OpenD1 & RangeD1>RangeD2..D5" => closed1 < opend1 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N2: CloseD1<OpenD2 & RangeD1>RangeD2..D5" => closed1 < opend2 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N3: CloseD1<OpenD3 & RangeD1>RangeD2..D5" => closed1 < opend3 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N4: CloseD1<OpenD4 & RangeD1>RangeD2..D5" => closed1 < opend4 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5
        "16 N5: CloseD1<OpenD5 & RangeD1>RangeD2..D5" => closed1 < opend5 and rangeD1 > rangeD2 and rangeD1 > rangeD3 and rangeD1 > rangeD4 and rangeD1 > rangeD5

        "17 N0: CloseD1<OpenD0 & |BodyD1|>|BodyD2..D5|" => closed1 < opend0 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N1: CloseD1<OpenD1 & |BodyD1|>|BodyD2..D5|" => closed1 < opend1 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N2: CloseD1<OpenD2 & |BodyD1|>|BodyD2..D5|" => closed1 < opend2 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N3: CloseD1<OpenD3 & |BodyD1|>|BodyD2..D5|" => closed1 < opend3 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N4: CloseD1<OpenD4 & |BodyD1|>|BodyD2..D5|" => closed1 < opend4 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)
        "17 N5: CloseD1<OpenD5 & |BodyD1|>|BodyD2..D5|" => closed1 < opend5 and math.abs(bodyD1) > math.abs(bodyD2) and math.abs(bodyD1) > math.abs(bodyD3) and math.abs(bodyD1) > math.abs(bodyD4) and math.abs(bodyD1) > math.abs(bodyD5)

        "18: LowD1 == LowestL" => lowd1 == LowestL
        "19: CloseD1 == LowestC" => closed1 == LowestC
        "20: OpenD1 == LowestO" => opend1 == LowestO
        "21: LowD1 < LowestC" => lowd1 < LowestC
        "22: HighD1 < HighestL" => highd1 < HighestL
        "23: CloseD1 < HighestL" => closed1 < HighestL

        "24 N0: CloseD1<CloseD0 & HighD1<HighD0" => closed1 < closed0 and highd1 < highd0
        "24 N2: CloseD1<CloseD2 & HighD1<HighD2" => closed1 < closed2 and highd1 < highd2
        "24 N3: CloseD1<CloseD3 & HighD1<HighD3" => closed1 < closed3 and highd1 < highd3
        "24 N4: CloseD1<CloseD4 & HighD1<HighD4" => closed1 < closed4 and highd1 < highd4
        "24 N5: CloseD1<CloseD5 & HighD1<HighD5" => closed1 < closed5 and highd1 < highd5

        "25 N0: CloseD1<OpenD0 & HighD1<HighD0" => closed1 < opend0 and highd1 < highd0
        "25 N2: CloseD1<OpenD2 & HighD1<HighD2" => closed1 < opend2 and highd1 < highd2
        "25 N3: CloseD1<OpenD3 & HighD1<HighD3" => closed1 < opend3 and highd1 < highd3
        "25 N4: CloseD1<OpenD4 & HighD1<HighD4" => closed1 < opend4 and highd1 < highd4
        "25 N5: CloseD1<OpenD5 & HighD1<HighD5" => closed1 < opend5 and highd1 < highd5

        "26: CloseD1<OpenD1 & CloseD2<OpenD2" => closed1 < opend1 and closed2 < opend2

        "27 N0: RangeD1 < RangeD0" => rangeD1 < rangeD0
        "27 N2: RangeD1 < RangeD2" => rangeD1 < rangeD2
        "27 N3: RangeD1 < RangeD3" => rangeD1 < rangeD3
        "27 N4: RangeD1 < RangeD4" => rangeD1 < rangeD4
        "27 N5: RangeD1 < RangeD5" => rangeD1 < rangeD5

        "28 N0: CloseD1<Opend1 & RangeD1>RangeD0" => closed1 < opend1 and rangeD1 > rangeD0
        "28 N2: CloseD1<Opend1 & RangeD1>RangeD2" => closed1 < opend1 and rangeD1 > rangeD2
        "28 N3: CloseD1<Opend1 & RangeD1>RangeD3" => closed1 < opend1 and rangeD1 > rangeD3
        "28 N4: CloseD1<Opend1 & RangeD1>RangeD4" => closed1 < opend1 and rangeD1 > rangeD4
        "28 N5: CloseD1<Opend1 & RangeD1>RangeD5" => closed1 < opend1 and rangeD1 > rangeD5

        "29: Always true" => true
        => true

	condition










export condition_day2(string i_d2, array<float> FT_OHLC, array<float> PtnCtx) =>


    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")


    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)


    int barcount = int(nz(array.get(PtnCtx, 0), 0))

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


    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)


    float rng0 = high - low

	condition = switch i_d2
        "01 N0: CloseD2 > OpenD0" => closed2 > opend0
        "01 N1: CloseD2 > OpenD1" => closed2 > opend1
        "01 N2: CloseD2 > OpenD2" => closed2 > opend2
        "01 N3: CloseD2 > OpenD3" => closed2 > opend3
        "01 N4: CloseD2 > OpenD4" => closed2 > opend4
        "01 N5: CloseD2 > OpenD5" => closed2 > opend5

        "02 N0: CloseD2 > HighD0" => closed2 > highd0
        "02 N1: CloseD2 > HighD1" => closed2 > highd1
        "02 N3: CloseD2 > HighD3" => closed2 > highd3
        "02 N4: CloseD2 > HighD4" => closed2 > highd4
        "02 N5: CloseD2 > HighD5" => closed2 > highd5

        "03 N0: CloseD2 > CloseD0" => closed2 > closed0
        "03 N1: CloseD2 > CloseD1" => closed2 > closed1
        "03 N3: CloseD2 > CloseD3" => closed2 > closed3
        "03 N4: CloseD2 > CloseD4" => closed2 > closed4
        "03 N5: CloseD2 > CloseD5" => closed2 > closed5

        "04 N0: HighD2 > HighD0" => highd2 > highd0
        "04 N1: HighD2 > HighD1" => highd2 > highd1
        "04 N3: HighD2 > HighD3" => highd2 > highd3
        "04 N4: HighD2 > HighD4" => highd2 > highd4
        "04 N5: HighD2 > HighD5" => highd2 > highd5

        "05 N0: LowD2 > LowD0" => lowd2 > lowd0
        "05 N1: LowD2 > LowD1" => lowd2 > lowd1
        "05 N3: LowD2 > LowD3" => lowd2 > lowd3
        "05 N4: LowD2 > LowD4" => lowd2 > lowd4
        "05 N5: LowD2 > LowD5" => lowd2 > lowd5

        "06 N0: CloseD2-OpenD0>0 & >0.25*(HighD2-LowD0)" => (closed2 - opend0) > 0 and (closed2 - opend0) > 0.25 * (highd2 - lowd0)
        "06 N1: CloseD2-OpenD1>0 & >0.25*(HighD2-LowD1)" => (closed2 - opend1) > 0 and (closed2 - opend1) > 0.25 * (highd2 - lowd1)
        "06 N2: CloseD2-OpenD2>0 & >0.25*(HighD2-LowD2)" => (closed2 - opend2) > 0 and (closed2 - opend2) > 0.25 * (highd2 - lowd2)
        "06 N3: CloseD2-OpenD3>0 & >0.25*(HighD2-LowD3)" => (closed2 - opend3) > 0 and (closed2 - opend3) > 0.25 * (highd2 - lowd3)
        "06 N4: CloseD2-OpenD4>0 & >0.25*(HighD2-LowD4)" => (closed2 - opend4) > 0 and (closed2 - opend4) > 0.25 * (highd2 - lowd4)
        "06 N5: CloseD2-OpenD5>0 & >0.25*(HighD2-LowD5)" => (closed2 - opend5) > 0 and (closed2 - opend5) > 0.25 * (highd2 - lowd5)

        "07 N0: CloseD2-OpenD0>0 & <0.75*(HighD2-LowD0)" => (closed2 - opend0) > 0 and (closed2 - opend0) < 0.75 * (highd2 - lowd0)
        "07 N1: CloseD2-OpenD1>0 & <0.75*(HighD2-LowD1)" => (closed2 - opend1) > 0 and (closed2 - opend1) < 0.75 * (highd2 - lowd1)
        "07 N2: CloseD2-OpenD2>0 & <0.75*(HighD2-LowD2)" => (closed2 - opend2) > 0 and (closed2 - opend2) < 0.75 * (highd2 - lowd2)
        "07 N3: CloseD2-OpenD3>0 & <0.75*(HighD2-LowD3)" => (closed2 - opend3) > 0 and (closed2 - opend3) < 0.75 * (highd2 - lowd3)
        "07 N4: CloseD2-OpenD4>0 & <0.75*(HighD2-LowD4)" => (closed2 - opend4) > 0 and (closed2 - opend4) < 0.75 * (highd2 - lowd4)
        "07 N5: CloseD2-OpenD5>0 & <0.75*(HighD2-LowD5)" => (closed2 - opend5) > 0 and (closed2 - opend5) < 0.75 * (highd2 - lowd5)

        "08: HighD2 > HighD3,D4,D5" => highd2 > highd3 and highd2 > highd4 and highd2 > highd5
        "09: CloseD2 > CloseD3,D4,D5" => closed2 > closed3 and closed2 > closed4 and closed2 > closed5

        "10 N0: LowD2 > CloseD0" => lowd2 > closed0
        "10 N1: LowD2 > CloseD1" => lowd2 > closed1
        "10 N3: LowD2 > CloseD3" => lowd2 > closed3
        "10 N4: LowD2 > CloseD4" => lowd2 > closed4
        "10 N5: LowD2 > CloseD5" => lowd2 > closed5

        "11 N0: LowD2 > HighD0" => lowd2 > highd0
        "11 N1: LowD2 > HighD1" => lowd2 > highd1
        "11 N3: LowD2 > HighD3" => lowd2 > highd3
        "11 N4: LowD2 > HighD4" => lowd2 > highd4
        "11 N5: LowD2 > HighD5" => lowd2 > highd5

        "12 N0: HighD2 > CloseD0" => highd2 > closed0
        "12 N1: HighD2 > CloseD1" => highd2 > closed1
        "12 N3: HighD2 > CloseD3" => highd2 > closed3
        "12 N4: HighD2 > CloseD4" => highd2 > closed4
        "12 N5: HighD2 > CloseD5" => highd2 > closed5

        "13 N0: OpenD2 > CloseD0" => opend2 > closed0
        "13 N1: OpenD2 > CloseD1" => opend2 > closed1
        "13 N2: OpenD2 > CloseD2" => opend2 > closed2
        "13 N3: OpenD2 > CloseD3" => opend2 > closed3
        "13 N4: OpenD2 > CloseD4" => opend2 > closed4
        "13 N5: OpenD2 > CloseD5" => opend2 > closed5

        "14 N0: OpenD2 > HighD0" => opend2 > highd0
        "14 N1: OpenD2 > HighD1" => opend2 > highd1
        "14 N3: OpenD2 > HighD3" => opend2 > highd3
        "14 N4: OpenD2 > HighD4" => opend2 > highd4
        "14 N5: OpenD2 > HighD5" => opend2 > highd5

        "15 N0: OpenD2 > LowD0" => opend2 > lowd0
        "15 N1: OpenD2 > LowD1" => opend2 > lowd1
        "15 N3: OpenD2 > LowD3" => opend2 > lowd3
        "15 N4: OpenD2 > LowD4" => opend2 > lowd4
        "15 N5: OpenD2 > LowD5" => opend2 > lowd5

        "16 N0: CloseD2>OpenD0 & RangeD2>RangeD3..D5" => closed2 > opend0 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N1: CloseD2>OpenD1 & RangeD2>RangeD3..D5" => closed2 > opend1 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N2: CloseD2>OpenD2 & RangeD2>RangeD3..D5" => closed2 > opend2 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N3: CloseD2>OpenD3 & RangeD2>RangeD3..D5" => closed2 > opend3 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N4: CloseD2>OpenD4 & RangeD2>RangeD3..D5" => closed2 > opend4 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N5: CloseD2>OpenD5 & RangeD2>RangeD3..D5" => closed2 > opend5 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5

        "17 N0: CloseD2>OpenD0 & |BodyD2|>|BodyD3..D5|" => closed2 > opend0 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N1: CloseD2>OpenD1 & |BodyD2|>|BodyD3..D5|" => closed2 > opend1 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N2: CloseD2>OpenD2 & |BodyD2|>|BodyD3..D5|" => closed2 > opend2 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N3: CloseD2>OpenD3 & |BodyD2|>|BodyD3..D5|" => closed2 > opend3 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N4: CloseD2>OpenD4 & |BodyD2|>|BodyD3..D5|" => closed2 > opend4 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N5: CloseD2>OpenD5 & |BodyD2|>|BodyD3..D5|" => closed2 > opend5 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)

        "18: HighD2 == HighestH" => highd2 == HighestH
        "19: CloseD2 == HighestC" => closed2 == HighestC
        "20: OpenD2 == HighestO" => opend2 == HighestO
        "21: HighD2 > HighestC" => highd2 > HighestC
        "22: LowD2  > LowestH" => lowd2 > LowestH
        "23: CloseD2 > LowestH" => closed2 > LowestH

        "24 N0: CloseD2>CloseD0 & LowD2>LowD0" => closed2 > closed0 and lowd2 > lowd0
        "24 N1: CloseD2>CloseD1 & LowD2>LowD1" => closed2 > closed1 and lowd2 > lowd1
        "24 N3: CloseD2>CloseD3 & LowD2>LowD3" => closed2 > closed3 and lowd2 > lowd3
        "24 N4: CloseD2>CloseD4 & LowD2>LowD4" => closed2 > closed4 and lowd2 > lowd4
        "24 N5: CloseD2>CloseD5 & LowD2>LowD5" => closed2 > closed5 and lowd2 > lowd5

        "25 N0: CloseD2>OpenD0 & LowD2>LowD0" => closed2 > opend0 and lowd2 > lowd0
        "25 N1: CloseD2>OpenD1 & LowD2>LowD1" => closed2 > opend1 and lowd2 > lowd1
        "25 N3: CloseD2>OpenD3 & LowD2>LowD3" => closed2 > opend3 and lowd2 > lowd3
        "25 N4: CloseD2>OpenD4 & LowD2>LowD4" => closed2 > opend4 and lowd2 > lowd4
        "25 N5: CloseD2>OpenD5 & LowD2>LowD5" => closed2 > opend5 and lowd2 > lowd5

        "26: CloseD2>OpenD2 & CloseD3>OpenD3" => closed2 > opend2 and closed3 > opend3

        "27 N0: RangeD2 > RangeD0" => rangeD2 > rangeD0
        "27 N1: RangeD2 > RangeD1" => rangeD2 > rangeD1
        "27 N3: RangeD2 > RangeD3" => rangeD2 > rangeD3
        "27 N4: RangeD2 > RangeD4" => rangeD2 > rangeD4
        "27 N5: RangeD2 > RangeD5" => rangeD2 > rangeD5

        "28 N0: CloseD2>Opend2 & RangeD2>RangeD0" => closed2 > opend2 and rangeD2 > rangeD0
        "28 N1: CloseD2>OpenD2 & RangeD2>RangeD1" => closed2 > opend2 and rangeD2 > rangeD1
        "28 N3: CloseD2>Opend2 & RangeD2>RangeD3" => closed2 > opend2 and rangeD2 > rangeD3
        "28 N4: CloseD2>Opend2 & RangeD2>RangeD4" => closed2 > opend2 and rangeD2 > rangeD4
        "28 N5: CloseD2>Opend2 & RangeD2>RangeD5" => closed2 > opend2 and rangeD2 > rangeD5



        "01 N0: CloseD2 < OpenD0" => closed2 < opend0
        "01 N1: CloseD2 < OpenD1" => closed2 < opend1
        "01 N2: CloseD2 < OpenD2" => closed2 < opend2
        "01 N3: CloseD2 < OpenD3" => closed2 < opend3
        "01 N4: CloseD2 < OpenD4" => closed2 < opend4
        "01 N5: CloseD2 < OpenD5" => closed2 < opend5

        "02 N0: CloseD2 < LowD0" => closed2 < lowd0
        "02 N1: CloseD2 < LowD1" => closed2 < lowd1
        "02 N3: CloseD2 < LowD3" => closed2 < lowd3
        "02 N4: CloseD2 < LowD4" => closed2 < lowd4
        "02 N5: CloseD2 < LowD5" => closed2 < lowd5

        "03 N0: CloseD2 < CloseD0" => closed2 < closed0
        "03 N1: CloseD2 < CloseD1" => closed2 < closed1
        "03 N3: CloseD2 < CloseD3" => closed2 < closed3
        "03 N4: CloseD2 < CloseD4" => closed2 < closed4
        "03 N5: CloseD2 < CloseD5" => closed2 < closed5

        "04 N0: LowD2 < LowD0" => lowd2 < lowd0
        "04 N1: LowD2 < LowD1" => lowd2 < lowd1
        "04 N3: LowD2 < LowD3" => lowd2 < lowd3
        "04 N4: LowD2 < LowD4" => lowd2 < lowd4
        "04 N5: LowD2 < LowD5" => lowd2 < lowd5

        "05 N0: HighD2 < HighD0" => highd2 < highd0
        "05 N1: HighD2 < HighD1" => highd2 < highd1
        "05 N3: HighD2 < HighD3" => highd2 < highd3
        "05 N4: HighD2 < HighD4" => highd2 < highd4
        "05 N5: HighD2 < HighD5" => highd2 < highd5

        "06 N0: OpenD0-CloseD2>0 & >0.25*(HighD2-LowD0)" => (opend0 - closed2) > 0 and (opend0 - closed2) > 0.25 * (highd2 - lowd0)
        "06 N1: OpenD1-CloseD2>0 & >0.25*(HighD2-LowD1)" => (opend1 - closed2) > 0 and (opend1 - closed2) > 0.25 * (highd2 - lowd1)
        "06 N2: OpenD2-CloseD2>0 & >0.25*(HighD2-LowD2)" => (opend2 - closed2) > 0 and (opend2 - closed2) > 0.25 * (highd2 - lowd2)
        "06 N3: OpenD3-CloseD2>0 & >0.25*(HighD2-LowD3)" => (opend3 - closed2) > 0 and (opend3 - closed2) > 0.25 * (highd2 - lowd3)
        "06 N4: OpenD4-CloseD2>0 & >0.25*(HighD2-LowD4)" => (opend4 - closed2) > 0 and (opend4 - closed2) > 0.25 * (highd2 - lowd4)
        "06 N5: OpenD5-CloseD2>0 & >0.25*(HighD2-LowD5)" => (opend5 - closed2) > 0 and (opend5 - closed2) > 0.25 * (highd2 - lowd5)

        "07 N0: OpenD0-CloseD2>0 & <0.75*(HighD2-LowD0)" => (opend0 - closed2) > 0 and (opend0 - closed2) < 0.75 * (highd2 - lowd0)
        "07 N1: OpenD1-CloseD2>0 & <0.75*(HighD2-LowD1)" => (opend1 - closed2) > 0 and (opend1 - closed2) < 0.75 * (highd2 - lowd1)
        "07 N2: OpenD2-CloseD2>0 & <0.75*(HighD2-LowD2)" => (opend2 - closed2) > 0 and (opend2 - closed2) < 0.75 * (highd2 - lowd2)
        "07 N3: OpenD3-CloseD2>0 & <0.75*(HighD2-LowD3)" => (opend3 - closed2) > 0 and (opend3 - closed2) < 0.75 * (highd2 - lowd3)
        "07 N4: OpenD4-CloseD2>0 & <0.75*(HighD2-LowD4)" => (opend4 - closed2) > 0 and (opend4 - closed2) < 0.75 * (highd2 - lowd4)
        "07 N5: OpenD5-CloseD2>0 & <0.75*(HighD2-LowD5)" => (opend5 - closed2) > 0 and (opend5 - closed2) < 0.75 * (highd2 - lowd5)

        "08: LowD2 < LowD3,D4,D5" => lowd2 < lowd3 and lowd2 < lowd4 and lowd2 < lowd5
        "09: CloseD2 < CloseD3,D4,D5" => closed2 < closed3 and closed2 < closed4 and closed2 < closed5

        "10 N0: HighD2 < CloseD0" => highd2 < closed0
        "10 N1: HighD2 < CloseD1" => highd2 < closed1
        "10 N3: HighD2 < CloseD3" => highd2 < closed3
        "10 N4: HighD2 < CloseD4" => highd2 < closed4
        "10 N5: HighD2 < CloseD5" => highd2 < closed5

        "11 N0: HighD2 < LowD0" => highd2 < lowd0
        "11 N1: HighD2 < LowD1" => highd2 < lowd1
        "11 N3: HighD2 < LowD3" => highd2 < lowd3
        "11 N4: HighD2 < LowD4" => highd2 < lowd4
        "11 N5: HighD2 < LowD5" => highd2 < lowd5

        "12 N0: LowD2  < CloseD0" => lowd2 < closed0
        "12 N1: LowD2  < CloseD1" => lowd2 < closed1
        "12 N3: LowD2  < CloseD3" => lowd2 < closed3
        "12 N4: LowD2  < CloseD4" => lowd2 < closed4
        "12 N5: LowD2  < CloseD5" => lowd2 < closed5

        "13 N0: OpenD2 < CloseD0" => opend2 < closed0
        "13 N1: OpenD2 < CloseD1" => opend2 < closed1
        "13 N2: OpenD2 < CloseD2" => opend2 < closed2
        "13 N3: OpenD2 < CloseD3" => opend2 < closed3
        "13 N4: OpenD2 < CloseD4" => opend2 < closed4
        "13 N5: OpenD2 < CloseD5" => opend2 < closed5

        "14 N0: OpenD2 < LowD0" => opend2 < lowd0
        "14 N1: OpenD2 < LowD1" => opend2 < lowd1
        "14 N3: OpenD2 < LowD3" => opend2 < lowd3
        "14 N4: OpenD2 < LowD4" => opend2 < lowd4
        "14 N5: OpenD2 < LowD5" => opend2 < lowd5

        "15 N0: OpenD2 < HighD0" => opend2 < highd0
        "15 N1: OpenD2 < HighD1" => opend2 < highd1
        "15 N3: OpenD2 < HighD3" => opend2 < highd3
        "15 N4: OpenD2 < HighD4" => opend2 < highd4
        "15 N5: OpenD2 < HighD5" => opend2 < highd5

        "16 N0: CloseD2<OpenD0 & RangeD2>RangeD3..D5" => closed2 < opend0 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N1: CloseD2<OpenD1 & RangeD2>RangeD3..D5" => closed2 < opend1 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N2: CloseD2<OpenD2 & RangeD2>RangeD3..D5" => closed2 < opend2 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N3: CloseD2<OpenD3 & RangeD2>RangeD3..D5" => closed2 < opend3 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N4: CloseD2<OpenD4 & RangeD2>RangeD3..D5" => closed2 < opend4 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5
        "16 N5: CloseD2<OpenD5 & RangeD2>RangeD3..D5" => closed2 < opend5 and rangeD2 > rangeD3 and rangeD2 > rangeD4 and rangeD2 > rangeD5

        "17 N0: CloseD2<OpenD0 & |BodyD2|>|BodyD3..D5|" => closed2 < opend0 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N1: CloseD2<OpenD1 & |BodyD2|>|BodyD3..D5|" => closed2 < opend1 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N2: CloseD2<OpenD2 & |BodyD2|>|BodyD3..D5|" => closed2 < opend2 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N3: CloseD2<OpenD3 & |BodyD2|>|BodyD3..D5|" => closed2 < opend3 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N4: CloseD2<OpenD4 & |BodyD2|>|BodyD3..D5|" => closed2 < opend4 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)
        "17 N5: CloseD2<OpenD5 & |BodyD2|>|BodyD3..D5|" => closed2 < opend5 and math.abs(bodyD2) > math.abs(bodyD3) and math.abs(bodyD2) > math.abs(bodyD4) and math.abs(bodyD2) > math.abs(bodyD5)

        "18: LowD2 == LowestL" => lowd2 == LowestL
        "19: CloseD2 == LowestC" => closed2 == LowestC
        "20: OpenD2 == LowestO" => opend2 == LowestO
        "21: LowD2 < LowestC" => lowd2 < LowestC
        "22: HighD2 < HighestL" => highd2 < HighestL
        "23: CloseD2 < HighestL" => closed2 < HighestL

        "24 N0: CloseD2<CloseD0 & HighD2<HighD0" => closed2 < closed0 and highd2 < highd0
        "24 N1: CloseD2<CloseD1 & HighD2<HighD1" => closed2 < closed1 and highd2 < highd1
        "24 N3: CloseD2<CloseD3 & HighD2<HighD3" => closed2 < closed3 and highd2 < highd3
        "24 N4: CloseD2<CloseD4 & HighD2<HighD4" => closed2 < closed4 and highd2 < highd4
        "24 N5: CloseD2<CloseD5 & HighD2<HighD5" => closed2 < closed5 and highd2 < highd5

        "25 N0: CloseD2<OpenD0 & HighD2<HighD0" => closed2 < opend0 and highd2 < highd0
        "25 N1: CloseD2<OpenD1 & HighD2<HighD1" => closed2 < opend1 and highd2 < highd1
        "25 N3: CloseD2<OpenD3 & HighD2<HighD3" => closed2 < opend3 and highd2 < highd3
        "25 N4: CloseD2<OpenD4 & HighD2<HighD4" => closed2 < opend4 and highd2 < highd4
        "25 N5: CloseD2<OpenD5 & HighD2<HighD5" => closed2 < opend5 and highd2 < highd5

        "26: CloseD2<OpenD2 & CloseD3<OpenD3" => closed2 < opend2 and closed3 < opend3


        "27 N0: RangeD2 < RangeD0" => rangeD2 < rangeD0
        "27 N1: RangeD2 < RangeD1" => rangeD2 < rangeD1
        "27 N3: RangeD2 < RangeD3" => rangeD2 < rangeD3
        "27 N4: RangeD2 < RangeD4" => rangeD2 < rangeD4
        "27 N5: RangeD2 < RangeD5" => rangeD2 < rangeD5

        "28 N0: CloseD2<Opend2 & RangeD2>RangeD0" => closed2 < opend2 and rangeD2 > rangeD0
        "28 N1: CloseD2<OpenD2 & RangeD2>RangeD1" => closed2 < opend2 and rangeD2 > rangeD1
        "28 N3: CloseD2<Opend2 & RangeD2>RangeD3" => closed2 < opend2 and rangeD2 > rangeD3
        "28 N4: CloseD2<Opend2 & RangeD2>RangeD4" => closed2 < opend2 and rangeD2 > rangeD4
        "28 N5: CloseD2<Opend2 & RangeD2>RangeD5" => closed2 < opend2 and rangeD2 > rangeD5

        "29: Always true" => true
        => true



	condition




export condition_W(string i_W, array<float> FT_OHLC, array<float> PtnCtx) =>


    if array.size(FT_OHLC) < 24
        runtime.error("Strategy Engine: FT_OHLC array must have at least 24 elements (0..23).")
    if array.size(PtnCtx) < 32
        runtime.error("Strategy Engine: PtnCtx array must have at least 32 elements (0..31).")


    float opend0  = array.get(FT_OHLC, 0),  highd0  = array.get(FT_OHLC, 1),  lowd0  = array.get(FT_OHLC, 2),  closed0 = array.get(FT_OHLC, 3)
    float opend1  = array.get(FT_OHLC, 4),  highd1  = array.get(FT_OHLC, 5),  lowd1  = array.get(FT_OHLC, 6),  closed1 = array.get(FT_OHLC, 7)
    float opend2  = array.get(FT_OHLC, 8),  highd2  = array.get(FT_OHLC, 9),  lowd2  = array.get(FT_OHLC, 10), closed2 = array.get(FT_OHLC, 11)
    float opend3  = array.get(FT_OHLC, 12), highd3  = array.get(FT_OHLC, 13), lowd3  = array.get(FT_OHLC, 14), closed3 = array.get(FT_OHLC, 15)
    float opend4  = array.get(FT_OHLC, 16), highd4  = array.get(FT_OHLC, 17), lowd4  = array.get(FT_OHLC, 18), closed4 = array.get(FT_OHLC, 19)
    float opend5  = array.get(FT_OHLC, 20), highd5  = array.get(FT_OHLC, 21), lowd5  = array.get(FT_OHLC, 22), closed5 = array.get(FT_OHLC, 23)


    int barcount = int(nz(array.get(PtnCtx, 0), 0))

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


    bool  StartOfSession = (barcount == 0)
    float sessStartHigh  = nz(ta.valuewhen(StartOfSession, high, 0), high)
    float sessStartLow   = nz(ta.valuewhen(StartOfSession, low, 0), low)
    float sessStartRange = nz(ta.valuewhen(StartOfSession, high - low, 0), high - low)


    float rng0 = high - low

	condition = switch i_W
		"01: Week up & Body5D > 0.5*Range5D" => (closed1 - opend5) > 0 and body5d > 0.5 * range5d
		"02: Week up & Body5D < 0.5*Range5D" => (closed1 - opend5) > 0 and body5d < 0.5 * range5d
		"03: (HighestH-CloseD1) < (OpenD5-LowestL)" => (HighestH - closed1) < (opend5 - LowestL)
		"04: (HighestH-Max(HighestC,HighestO)) < (Min(LowestO,LowestC)-LowestL)" => (HighestH - math.max(HighestC, HighestO)) < (math.min(LowestO, LowestC) - LowestL)
		"05: (HighestH-CloseD1) < (CloseD1-LowestL)" => (HighestH - closed1) < (closed1 - LowestL)
		"06: CloseD1 > mid(LowestL,HighestH)" => closed1 > (LowestL + (HighestH - LowestL) / 2.0)
		"07: (OpenD5-LowestL) > 0.75*(HighestH-LowestL)" => (opend5 - LowestL) > 0.75 * (HighestH - LowestL)

		"01: Week down & Body5D > 0.5*Range5D" => (closed1 - opend5) < 0 and body5d > 0.5 * range5d
		"02: Week down & Body5D < 0.5*Range5D" => (closed1 - opend5) < 0 and body5d < 0.5 * range5d
		"03: (OpenD5-LowestL) < (HighestH-CloseD1)" => (opend5 - LowestL) < (HighestH - closed1)
		"04: (HighestH-Max(HighestC,HighestO)) > (Min(LowestO,LowestC)-LowestL)" => (HighestH - math.max(HighestC, HighestO)) > (math.min(LowestO, LowestC) - LowestL)
		"05: (HighestH-CloseD1) > (CloseD1-LowestL)" => (HighestH - closed1) > (closed1 - LowestL)
		"06: CloseD1 < mid(LowestL,HighestH)" => closed1 < (LowestL + (HighestH - LowestL) / 2.0)
		"07: (HighestH-CloseD1) > 0.75*(HighestH-LowestL)" => (HighestH - closed1) > 0.75 * (HighestH - LowestL)

		"08: Always true" => true
		=> true

	condition









// Day/session label helpers
f_dName(int d) =>
    d == 0 ? "today's" : d == 1 ? "yesterday's" : d == 2 ? "the session/day from 2 days ago" : d == 3 ? "the session/day from 3 days ago" : d == 4 ? "the session/day from 4 days ago" : d == 5 ? "the session/day from 5 days ago" : "a non-defined past session/day"

f_dShort(int d) => "D" + str.tostring(d)


f_tokenToEnglish(string token) =>
    string t = token

    t := str.replace_all(t, " ", "")

    bool hasPrev = str.contains(t, "[1]")
    if hasPrev
        t := str.replace_all(t, "[1]", "")

    string base = (
        t == "close" ? "the current bar close" :
        t == "open"  ? "the current bar open" :
        t == "high"  ? "the current bar high" :
        t == "low"   ? "the current bar low" :
        t == "HighestH" ? "the highest session high across the previous 5 sessions/days (D1..D5)" :
        t == "LowestH"  ? "the lowest session high across the previous 5 sessions/days (D1..D5)" :
        t == "HighestL" ? "the highest session low across the previous 5 sessions/days (D1..D5)" :
        t == "LowestL"  ? "the lowest session low across the previous 5 sessions/days (D1..D5)" :
        t == "HighestO" ? "the highest session open across the previous 5 sessions/days (D1..D5)" :
        t == "LowestO"  ? "the lowest session open across the previous 5 sessions/days (D1..D5)" :
        t == "HighestC" ? "the highest session close across the previous 5 sessions/days (D1..D5)" :
        t == "LowestC"  ? "the lowest session close across the previous 5 sessions/days (D1..D5)" :
        t == "rangeD0"  ? "today's session range (High(D0) - Low(D0))" :
        t == "rangeD1"  ? "yesterday's session range (High(D1) - Low(D1))" :
        t == "rangeD2"  ? "the session range from 2 days ago" :
        t == "rangeD3"  ? "the session range from 3 days ago" :
        t == "rangeD4"  ? "the session range from 4 days ago" :
        t == "rangeD5"  ? "the session range from 5 days ago" :
        t == "bodyD0"   ? "today's session body (abs(Close(D0) - Open(D0)))" :
        t == "bodyD1"   ? "yesterday's session body (abs(Close(D1) - Open(D1)))" :
        t == "bodyD2"   ? "the session body from 2 days ago" :
        t == "bodyD3"   ? "the session body from 3 days ago" :
        t == "bodyD4"   ? "the session body from 4 days ago" :
        t == "bodyD5"   ? "the session body from 5 days ago" :
        t == "sessStartHigh"  ? "the start-of-session bar high (the bar where barcount==0)" :
        t == "sessStartLow"   ? "the start-of-session bar low (the bar where barcount==0)" :
        t == "sessStartRange" ? "the start-of-session bar range (high-low where barcount==0)" :
        str.startswith(t, "OpenD")  ? (f_dName(int(str.tonumber(str.substring(t, 5, 6)))) + " session open") :
        str.startswith(t, "HighD")  ? (f_dName(int(str.tonumber(str.substring(t, 5, 6)))) + " session high") :
        str.startswith(t, "LowD")   ? (f_dName(int(str.tonumber(str.substring(t, 4, 5)))) + " session low") :
        str.startswith(t, "CloseD") ? (f_dName(int(str.tonumber(str.substring(t, 6, 7)))) + " session close") :
        t
    )

    hasPrev ? (base + " (measured up to the previous bar)") : base


f_calcMethodText(string calcMode) =>
    calcMode == "Day" ? "Day = The OHLC levels used by this condition are calculated on the daily bars that form between 00:00:00 and 23:59:59 (HH:mm:ss) in the set TimeZone." : "Session = The OHLC levels used by this condition are calculated on the daily bars that form between the set 'Session Start' and 'Session End' times."





// Meaning generator 
export condition_day0_meaning(string condKey) =>
    string meaningExplicit = switch condKey
        "01: High rising (4 bars)" =>
            "The last four bar highs must be strictly increasing, meaning each new high is higher than the previous one."
        "03: Low rising (4 bars)" =>
            "The last four bar lows must be strictly increasing, meaning each new low is higher than the previous one."
        "05: Close rising (4 bars)" =>
            "The last four bar closes must be strictly increasing, meaning each close is higher than the previous one."
        "01: Low falling (4 bars)" =>
            "The last four bar lows must be strictly decreasing, meaning each new low is lower than the previous one."
        "03: High falling (4 bars)" =>
            "The last four bar highs must be strictly decreasing, meaning each new high is lower than the previous one."
        "05: Close falling (4 bars)" =>
            "The last four bar closes must be strictly decreasing, meaning each close is lower than the previous one."

        "02: High > highD0[1]" =>
            "The current bar high must break above the running session high recorded up to the previous bar (i.e., a new session high is made)."
        "06: Close > highD0[1]" =>
            "The current bar close must be above the running session high recorded up to the previous bar (i.e., a close above the prior running session high)."
        "02: Low < lowD0[1]" =>
            "The current bar low must break below the running session low recorded up to the previous bar (i.e., a new session low is made)."
        "06: Close < lowD0[1]" =>
            "The current bar close must be below the running session low recorded up to the previous bar (i.e., a close below the prior running session low)."

        "04: Close > OpenD0" =>
            "The current bar close must be above today's session open."
        "04: Close < OpenD0" =>
            "The current bar close must be below today's session open."

        "07: Bull bar & range > 2*ATR(45)" =>
            "The current bar must be bullish (close above open) and its high-to-low range must be unusually large: greater than twice the 45-period ATR."
        "07: Bear bar & range > 2*ATR(45)" =>
            "The current bar must be bearish (close below open) and its high-to-low range must be unusually large: greater than twice the 45-period ATR."

        "08: HighD0 > HighestH" =>
            "Today's session high must exceed the highest session high observed across the previous five sessions/days (D1..D5)."
        "09: HighD0 > HighestC" =>
            "Today's session high must exceed the highest session close observed across the previous five sessions/days (D1..D5)."
        "08: LowD0 < LowestL" =>
            "Today's session low must be below the lowest session low observed across the previous five sessions/days (D1..D5)."
        "09: LowD0 < LowestC" =>
            "Today's session low must be below the lowest session close observed across the previous five sessions/days (D1..D5)."

        "17: HighD0 > HighD1,D2,D3" =>
            "Today's session high must be higher than the session highs of D1, D2, and D3."
        "18: Close > CloseD1,D2,D3" =>
            "The current close must be higher than the session closes of D1, D2, and D3."

        "17: LowD0 < LowD1,D2,D3" =>
            "Today's session low must be lower than the session lows of D1, D2, and D3."
        "18: Close < CloseD1,D2,D3" =>
            "The current close must be lower than the session closes of D1, D2, and D3."

        "27: Close > HighestC" =>
            "The current close must be above the highest session close across the previous five sessions/days (D1..D5)."
        "28: OpenD0 > HighestO" =>
            "Today's session open must be above the highest session open across the previous five sessions/days (D1..D5)."
        "29: LowD0 > HighestL" =>
            "Today's session low must be above the highest session low across the previous five sessions/days (D1..D5)."
        "30: Close > LowestH" =>
            "The current close must be above the lowest session high across the previous five sessions/days (D1..D5)."

        "27: Close < LowestC" =>
            "The current close must be below the lowest session close across the previous five sessions/days (D1..D5)."
        "28: OpenD0 < LowestO" =>
            "Today's session open must be below the lowest session open across the previous five sessions/days (D1..D5)."
        "29: HighD0 < LowestH" =>
            "Today's session high must be below the lowest session high across the previous five sessions/days (D1..D5)."
        "30: Close < HighestL" =>
            "The current close must be below the highest session low across the previous five sessions/days (D1..D5)."

        "34: Close crosses above HighestH" =>
            "On this bar, the close must cross above the highest session high across D1..D5 (it was below on the previous bar and is above now)."
        "34: Close crosses below LowestL" =>
            "On this bar, the close must cross below the lowest session low across D1..D5 (it was above on the previous bar and is below now)."

        "37: barcount>3 & Close crosses above sessStartLow" =>
            "After at least 4 bars from session start, the close must cross above the start-of-session bar low."
        "38: barcount>3 & Close crosses above sessStartHigh" =>
            "After at least 4 bars from session start, the close must cross above the start-of-session bar high."
        "39: barcount>3 & Close crosses above OpenD0" =>
            "After at least 4 bars from session start, the close must cross above today's session open."
        "40: barcount>3 & (OpenD0-LowD0) < (HighD0-OpenD0)" =>
            "After at least 4 bars from session start, today's session open must be closer to the session low than to the session high (the upper wick-distance is larger than the lower)."
        "41: barcount>3 & HighD0 > sessStartHigh+sessStartRange" =>
            "After at least 4 bars from session start, today's session high must exceed (start-of-session high + start-of-session range)."
        "42: barcount>3 & Close  > sessStartHigh+sessStartRange" =>
            "After at least 4 bars from session start, the close must be above (start-of-session high + start-of-session range)."

        "37: barcount>3 & Close crosses below sessStartHigh" =>
            "After at least 4 bars from session start, the close must cross below the start-of-session bar high."
        "38: barcount>3 & Close crosses below sessStartLow" =>
            "After at least 4 bars from session start, the close must cross below the start-of-session bar low."
        "39: barcount>3 & Close crosses below OpenD0" =>
            "After at least 4 bars from session start, the close must cross below today's session open."
        "41: barcount>3 & LowD0  < sessStartLow - sessStartRange" =>
            "After at least 4 bars from session start, today's session low must drop below (start-of-session low − start-of-session range)."
        "42: barcount>3 & Close  < sessStartLow - sessStartRange" =>
            "After at least 4 bars from session start, the close must be below (start-of-session low − start-of-session range)."

        "43: Always true" =>
            "This filter is disabled: it always evaluates to true."
        => ""

    if meaningExplicit != ""
        meaningExplicit
    else
        // Generic parsing for N-cases + remaining simple comparisons
        int p = str.pos(condKey, ":")
        string expr = p >= 0 ? str.trim(str.substring(condKey, p + 1, str.length(condKey))) : condKey
        string e0 = str.replace_all(expr, " ", "")
        // Handle range/body multi-part cases
        if str.contains(e0, "RangeD0>RangeD1..D5")
            bool bullish = str.contains(e0, "Close>OpenD")
            int dn = int(str.tonumber(str.substring(e0, str.pos(e0, "OpenD") + 5, str.pos(e0, "OpenD") + 6)))
            (bullish ? "The current close must be above the session open of " + f_dShort(dn) + ", and today's session range must be greater than the range of each of the previous five sessions/days (D1..D5)."
                     : "The current close must be below the session open of " + f_dShort(dn) + ", and today's session range must be greater than the range of each of the previous five sessions/days (D1..D5).")

        else if str.contains(e0, "|BodyD0|>|BodyD1..D5|")
            bool bullish = str.contains(e0, "Close>OpenD")
            int dn = int(str.tonumber(str.substring(e0, str.pos(e0, "OpenD") + 5, str.pos(e0, "OpenD") + 6)))
            (bullish ? "The current close must be above the session open of " + f_dShort(dn) + ", and today's session body (absolute open-to-close) must be larger than the body of each of the previous five sessions/days (D1..D5)."
                     : "The current close must be below the session open of " + f_dShort(dn) + ", and today's session body (absolute open-to-close) must be larger than the body of each of the previous five sessions/days (D1..D5).")
        
        else if str.contains(expr, "crosses above") or str.contains(expr, "crosses below")
            bool above = str.contains(expr, "crosses above")
            string tgt = above ? str.trim(str.replace_all(expr, "Close crosses above", "")) : str.trim(str.replace_all(expr, "Close crosses below", ""))
            "On this bar, the close must cross " + (above ? "above " : "below ") + f_tokenToEnglish(str.lower(tgt)) + " (it was on the other side on the previous bar and changes side now)."

        else if str.contains(e0, "Mid(")
            bool leftHigh = str.contains(e0, "HighD0")
            bool leftLow  = str.contains(e0, "LowD0")
            bool gt = str.contains(e0, ">")
            int dpos = str.pos(e0, "HighD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            string midTxt = "the midpoint of " + f_dName(dn) + " range ( (High + Low) / 2 )"
            string leftTxt = leftHigh ? "Today's session high" : leftLow ? "Today's session low" : "Today's session price level"
            string compTxt = gt ? "above" : "below"
            leftTxt + " must be " + compTxt + " " + midTxt + "."

        else if str.contains(e0, "Close-OpenD") and str.contains(e0, "0.5*(HighD0-LowD")
            bool isGreater = str.contains(e0, "&>0.5*(")
            int dpos = str.pos(e0, "OpenD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            string part2 = isGreater ? "greater than" : "less than"
            "The close must be above the session open of " + f_dShort(dn) + ", and the close-to-open distance must be " + part2 + " half of (today's session high minus " + f_dName(dn) + " session low)."

        else if str.contains(e0, "OpenD") and str.contains(e0, "-Close") and str.contains(e0, "0.5*(HighD0-LowD")
            bool isGreater = str.contains(e0, "&>0.5*(")
            int dpos = str.pos(e0, "OpenD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            string part2 = isGreater ? "greater than" : "less than"
            "The close must be below the session open of " + f_dShort(dn) + ", and the open-to-close distance must be " + part2 + " half of (today's session high minus " + f_dName(dn) + " session low)."

        else
            // Simple comparator parsing (>, <, ==) with “impossible self-compare” detection
            string nrm = str.replace_all(expr, " ", "")
            int eq = str.pos(nrm, "==")
            int gt = str.pos(nrm, ">")
            int lt = str.pos(nrm, "<")

            string op = eq >= 0 ? "==" : gt >= 0 ? ">" : lt >= 0 ? "<" : ""
            int    ix = eq >= 0 ? eq : gt >= 0 ? gt : lt >= 0 ? lt : -1

            if ix < 0
                "This condition label could not be parsed into a simple comparison. Please verify the exact option string."
            else
                string left  = eq >= 0 ? str.substring(nrm, 0, ix) : str.substring(nrm, 0, ix)
                string right = eq >= 0 ? str.substring(nrm, ix + 2, str.length(nrm)) : str.substring(nrm, ix + 1, str.length(nrm))

                string lTok = left
                string rTok = right

                // “Impossible” strict self-compare
                if (op == ">" or op == "<") and (lTok == rTok)
                    "This condition can never be satisfied because it requires " + f_tokenToEnglish(lTok) + " to be " + (op == ">" ? "greater" : "lower") + " than itself."
                else
                    string lEng = f_tokenToEnglish(lTok)
                    string rEng = f_tokenToEnglish(rTok)

                    if op == ">"
                        lEng + " must be higher than " + rEng + "."
                    else if op == "<"
                        lEng + " must be lower than " + rEng + "."
                    else
                        lEng + " must be equal to " + rEng + "."




export condition_day1_meaning(string condKey) =>
    string meaningExplicit = switch condKey

        "08: HighD1 > HighD2,D3,D4" =>
            "Yesterday's session high must be higher than the session highs of D2, D3, and D4."
        "08: HighD1 > HighD2,D3" =>
            "Yesterday's session high must be higher than the session highs of D2 and D3."
        "09: CloseD1 > CloseD2,D3,D4" =>
            "Yesterday's session close must be higher than the session closes of D2, D3, and D4."

        "08: LowD1 < LowD2,D3,D4" =>
            "Yesterday's session low must be lower than the session lows of D2, D3, and D4."
        "08: LowD1 < LowD2,D3" =>
            "Yesterday's session low must be lower than the session lows of D2 and D3."

        "09: CloseD1 < CloseD2,D3,D4" =>
            "Yesterday's session close must be lower than the session closes of D2, D3, and D4."

        "18: HighD1 == HighestH" =>
            "Yesterday's session high must match the highest session high across the previous five sessions/days (D1..D5). In other words, yesterday is the top high within that 5-session window."
        "19: CloseD1 == HighestC" =>
            "Yesterday's session close must match the highest session close across the previous five sessions/days (D1..D5)."
        "20: OpenD1 == HighestO" =>
            "Yesterday's session open must match the highest session open across the previous five sessions/days (D1..D5)."
        "21: HighD1 > HighestC" =>
            "Yesterday's session high must be above the highest session close across the previous five sessions/days (D1..D5)."
        "22: LowD1  > LowestH" =>
            "Yesterday's session low must be above the lowest session high across the previous five sessions/days (D1..D5)."
        "23: CloseD1 > LowestH" =>
            "Yesterday's session close must be above the lowest session high across the previous five sessions/days (D1..D5)."

        "18: LowD1 == LowestL" =>
            "Yesterday's session low must match the lowest session low across the previous five sessions/days (D1..D5). In other words, yesterday is the bottom low within that 5-session window."
        "19: CloseD1 == LowestC" =>
            "Yesterday's session close must match the lowest session close across the previous five sessions/days (D1..D5)."
        "20: OpenD1 == LowestO" =>
            "Yesterday's session open must match the lowest session open across the previous five sessions/days (D1..D5)."
        "21: LowD1 < LowestC" =>
            "Yesterday's session low must be below the lowest session close across the previous five sessions/days (D1..D5)."
        "22: HighD1 < HighestL" =>
            "Yesterday's session high must be below the highest session low across the previous five sessions/days (D1..D5)."
        "23: CloseD1 < HighestL" =>
            "Yesterday's session close must be below the highest session low across the previous five sessions/days (D1..D5)."

        "26: CloseD1>OpenD1 & CloseD2>OpenD2" =>
            "Both yesterday (D1) and the session/day from two days ago (D2) must be bullish sessions, meaning each one closed above its open."
        "26: CloseD1<OpenD1 & CloseD2<OpenD2" =>
            "Both yesterday (D1) and the session/day from two days ago (D2) must be bearish sessions, meaning each one closed below its open."

        "28: Always true" =>
            "This filter is disabled: it always evaluates to true."

        => ""

    if meaningExplicit != ""
        meaningExplicit
    else
        int p = str.pos(condKey, ":")
        string expr = p >= 0 ? str.trim(str.substring(condKey, p + 1, str.length(condKey))) : condKey
        string e0   = str.replace_all(expr, " ", "")

        if str.contains(e0, "RangeD1>RangeD2..D5")
            bool bullish = str.contains(e0, "CloseD1>OpenD")
            int dpos = str.pos(e0, "OpenD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            (bullish ?
                "Yesterday's close must be above the session open of " + f_dShort(dn) + ", and yesterday's session range must be greater than the range of each of the sessions/days D2..D5."
              :
                "Yesterday's close must be below the session open of " + f_dShort(dn) + ", and yesterday's session range must be greater than the range of each of the sessions/days D2..D5."
            )

        else if str.contains(e0, "|BodyD1|>|BodyD2..D5|")
            bool bullish = str.contains(e0, "CloseD1>OpenD")
            int dpos = str.pos(e0, "OpenD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            (bullish ?
                "Yesterday's close must be above the session open of " + f_dShort(dn) + ", and yesterday's session body (absolute open-to-close) must be larger than the body of each of the sessions/days D2..D5."
              :
                "Yesterday's close must be below the session open of " + f_dShort(dn) + ", and yesterday's session body (absolute open-to-close) must be larger than the body of each of the sessions/days D2..D5."
            )

        else if (str.contains(e0, "0.25*(HighD1-LowD") or str.contains(e0, "0.75*(HighD1-LowD")) and (str.contains(e0, "CloseD1-OpenD") or str.contains(e0, "OpenD") and str.contains(e0, "-CloseD1"))
            bool bullish = str.contains(e0, "CloseD1-OpenD")
            bool is25    = str.contains(e0, "0.25*")
            bool is75    = str.contains(e0, "0.75*")
            string coefTxt = is25 ? "25%" : is75 ? "75%" : "a fixed %"

            bool greaterSide = str.contains(e0, "&>") 
            string cmpTxt = greaterSide ? "greater than" : "less than"

            int opPos = str.pos(e0, "OpenD")
            int dnOpen = opPos >= 0 ? int(str.tonumber(str.substring(e0, opPos + 5, opPos + 6))) : na

            int lowPos = str.pos(e0, "LowD")
            int dnLow  = lowPos >= 0 ? int(str.tonumber(str.substring(e0, lowPos + 4, lowPos + 5))) : na

            string base1 = (
                bullish ?
                    "Yesterday's close must be above the session open of " + f_dShort(dnOpen) + "."
                :
                    "Yesterday's close must be below the session open of " + f_dShort(dnOpen) + "."
            )

            string base2 = (
                bullish ?
                    "The close-to-open distance must be " + cmpTxt + " " + coefTxt + " of the span between yesterday's session high and " + f_dName(dnLow) + " session low."
                :
                    "The open-to-close distance must be " + cmpTxt + " " + coefTxt + " of the span between yesterday's session high and " + f_dName(dnLow) + " session low."
            )

            base1 + "\n\n" + base2


        else
            string nrm = str.replace_all(expr, " ", "")
            int eq = str.pos(nrm, "==")
            int gt = str.pos(nrm, ">")
            int lt = str.pos(nrm, "<")

            string op = eq >= 0 ? "==" : gt >= 0 ? ">" : lt >= 0 ? "<" : ""
            int ix    = eq >= 0 ? eq : gt >= 0 ? gt : lt >= 0 ? lt : -1

            if ix < 0
                "This condition label could not be parsed into a simple comparison. Please verify the exact option string."
            else
                string left  = str.substring(nrm, 0, ix)
                string right = eq >= 0 ? str.substring(nrm, ix + 2, str.length(nrm)) : str.substring(nrm, ix + 1, str.length(nrm))

                if (op == ">" or op == "<") and (left == right)
                    "This condition can never be satisfied because it requires " + f_tokenToEnglish(left) + " to be " + (op == ">" ? "greater" : "lower") + " than itself."
                else
                    string lEng = f_tokenToEnglish(left)
                    string rEng = f_tokenToEnglish(right)

                    op == ">" ? (lEng + " must be higher than " + rEng + ".") : op == "<" ? (lEng + " must be lower than " + rEng + ".") : (lEng + " must be equal to " + rEng + ".")





export condition_day2_meaning(string condKey) =>

    string meaningExplicit = switch condKey

        "08: HighD2 > HighD3,D4,D5" =>
            "The session high from 2 days ago (D2) must be higher than the session highs of D3, D4, and D5."
        "09: CloseD2 > CloseD3,D4,D5" =>
            "The session close from 2 days ago (D2) must be higher than the session closes of D3, D4, and D5."

        "08: LowD2 < LowD3,D4,D5" =>
            "The session low from 2 days ago (D2) must be lower than the session lows of D3, D4, and D5."
        "09: CloseD2 < CloseD3,D4,D5" =>
            "The session close from 2 days ago (D2) must be lower than the session closes of D3, D4, and D5."

        "18: HighD2 == HighestH" =>
            "The D2 session high must match the highest session high across the previous five sessions/days (D1..D5). In other words, D2 is the top high inside that 5-session window."
        "19: CloseD2 == HighestC" =>
            "The D2 session close must match the highest session close across the previous five sessions/days (D1..D5)."
        "20: OpenD2 == HighestO" =>
            "The D2 session open must match the highest session open across the previous five sessions/days (D1..D5)."
        "21: HighD2 > HighestC" =>
            "The D2 session high must be above the highest session close across the previous five sessions/days (D1..D5)."
        "22: LowD2  > LowestH" =>
            "The D2 session low must be above the lowest session high across the previous five sessions/days (D1..D5)."
        "23: CloseD2 > LowestH" =>
            "The D2 session close must be above the lowest session high across the previous five sessions/days (D1..D5)."

        "18: LowD2 == LowestL" =>
            "The D2 session low must match the lowest session low across the previous five sessions/days (D1..D5). In other words, D2 is the bottom low inside that 5-session window."
        "19: CloseD2 == LowestC" =>
            "The D2 session close must match the lowest session close across the previous five sessions/days (D1..D5)."
        "20: OpenD2 == LowestO" =>
            "The D2 session open must match the lowest session open across the previous five sessions/days (D1..D5)."
        "21: LowD2 < LowestC" =>
            "The D2 session low must be below the lowest session close across the previous five sessions/days (D1..D5)."
        "22: HighD2 < HighestL" =>
            "The D2 session high must be below the highest session low across the previous five sessions/days (D1..D5)."
        "23: CloseD2 < HighestL" =>
            "The D2 session close must be below the highest session low across the previous five sessions/days (D1..D5)."

        "26: CloseD2>OpenD2 & CloseD3>OpenD3" =>
            "Both D2 and D3 must be bullish sessions, meaning each one closed above its open."
        "26: CloseD2<OpenD2 & CloseD3<OpenD3" =>
            "Both D2 and D3 must be bearish sessions, meaning each one closed below its open."

        "28: Always true" =>
            "This filter is disabled: it always evaluates to true."

        => ""

    if meaningExplicit != ""
        meaningExplicit
    else
        int p = str.pos(condKey, ":")
        string expr = p >= 0 ? str.trim(str.substring(condKey, p + 1, str.length(condKey))) : condKey
        string e0   = str.replace_all(expr, " ", "")

        if str.contains(e0, "RangeD2>RangeD3..D5")
            bool bullish = str.contains(e0, "CloseD2>OpenD")
            int dpos = str.pos(e0, "OpenD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            (bullish ?
                "The D2 close must be above the session open of " + f_dShort(dn) + ", and the D2 session range must be greater than the range of each of the sessions/days D3..D5."
              :
                "The D2 close must be below the session open of " + f_dShort(dn) + ", and the D2 session range must be greater than the range of each of the sessions/days D3..D5."
            )

        else if str.contains(e0, "|BodyD2|>|BodyD3..D5|")
            bool bullish = str.contains(e0, "CloseD2>OpenD")
            int dpos = str.pos(e0, "OpenD")
            int dn = dpos >= 0 ? int(str.tonumber(str.substring(e0, dpos + 5, dpos + 6))) : na
            (bullish ?
                "The D2 close must be above the session open of " + f_dShort(dn) + ", and the D2 session body (absolute open-to-close) must be larger than the body of each of the sessions/days D3..D5."
              :
                "The D2 close must be below the session open of " + f_dShort(dn) + ", and the D2 session body (absolute open-to-close) must be larger than the body of each of the sessions/days D3..D5."
            )


        else if (str.contains(e0, "0.25*(HighD2-LowD") or str.contains(e0, "0.75*(HighD2-LowD")) and (str.contains(e0, "CloseD2-OpenD") or (str.contains(e0, "OpenD") and str.contains(e0, "-CloseD2")))
            bool bullish = str.contains(e0, "CloseD2-OpenD")
            bool is25    = str.contains(e0, "0.25*")
            bool is75    = str.contains(e0, "0.75*")
            string coefTxt = is25 ? "25%" : is75 ? "75%" : "a fixed %"

            bool greaterSide = str.contains(e0, "&>")
            string cmpTxt = greaterSide ? "greater than" : "less than"

            int opPos = str.pos(e0, "OpenD")
            int dnOpen = opPos >= 0 ? int(str.tonumber(str.substring(e0, opPos + 5, opPos + 6))) : na

            int lowPos = str.pos(e0, "LowD")
            int dnLow  = lowPos >= 0 ? int(str.tonumber(str.substring(e0, lowPos + 4, lowPos + 5))) : na

            string base1 = (
                bullish ?
                    "The D2 close must be above the session open of " + f_dShort(dnOpen) + "."
                :
                    "The D2 close must be below the session open of " + f_dShort(dnOpen) + "."
            )

            string base2 = (
                bullish ?
                    "The close-to-open distance must be " + cmpTxt + " " + coefTxt + " of the span between the D2 session high and " + f_dName(dnLow) + " session low."
                :
                    "The open-to-close distance must be " + cmpTxt + " " + coefTxt + " of the span between the D2 session high and " + f_dName(dnLow) + " session low."
            )

            base1 + "\n\n" + base2


        else
            string nrm = str.replace_all(expr, " ", "")
            int eq = str.pos(nrm, "==")
            int gt = str.pos(nrm, ">")
            int lt = str.pos(nrm, "<")

            string op = eq >= 0 ? "==" : gt >= 0 ? ">" : lt >= 0 ? "<" : ""
            int ix    = eq >= 0 ? eq : gt >= 0 ? gt : lt >= 0 ? lt : -1

            if ix < 0
                "This condition label could not be parsed into a simple comparison. Please verify the exact option string."
            else
                string left  = str.substring(nrm, 0, ix)
                string right = eq >= 0 ? str.substring(nrm, ix + 2, str.length(nrm)) : str.substring(nrm, ix + 1, str.length(nrm))

                if (op == ">" or op == "<") and (left == right)
                    "This condition can never be satisfied because it requires " + f_tokenToEnglish(left) + " to be " + (op == ">" ? "greater" : "lower") + " than itself."
                else
                    string lEng = f_tokenToEnglish(left)
                    string rEng = f_tokenToEnglish(right)

                    op == ">" ? (lEng + " must be higher than " + rEng + ".") : op == "<" ? (lEng + " must be lower than " + rEng + ".") : (lEng + " must be equal to " + rEng + ".")






export condition_W_meaning(string condKey) =>
    switch condKey

        "01: Week up & Body5D > 0.5*Range5D" =>
            "The 5-session window must be net positive (yesterday's close is above the D5 open), and the 5-session body must be strong: more than half of the total 5-session range. This describes a directional week with meaningful follow-through."

        "02: Week up & Body5D < 0.5*Range5D" =>
            "The 5-session window must be net positive (yesterday's close is above the D5 open), but the 5-session body must be relatively small compared to the total 5-session range. This describes an up week with more back-and-forth (less directional pressure)."

        "03: (HighestH-CloseD1) < (OpenD5-LowestL)" =>
            "Yesterday's close must be closer to the 5-session high than the D5 open is to the 5-session low. In practice, it suggests the week ended nearer the top of its 5-session range, compared to where it started."

        "04: (HighestH-Max(HighestC,HighestO)) < (Min(LowestO,LowestC)-LowestL)" =>
            "Within the last 5 sessions, the 'upper tail' from the 5-session high down to the best of (highest open, highest close) must be smaller than the 'lower tail' from the worst of (lowest open, lowest close) down to the 5-session low. This indicates price action is positioned toward the upper part of the 5-session range (bullish distribution)."

        "05: (HighestH-CloseD1) < (CloseD1-LowestL)" =>
            "Yesterday's close must be closer to the 5-session high than to the 5-session low. In other words, the close is in the upper half of the 5-session range."

        "06: CloseD1 > mid(LowestL,HighestH)" =>
            "Yesterday's close must be above the midpoint of the 5-session range (midpoint between the lowest low and highest high across the last 5 sessions). This places the close in the upper half of the week."

        "07: (OpenD5-LowestL) > 0.75*(HighestH-LowestL)" =>
            "The D5 open must be in the top quarter of the 5-session range (it is more than 75% of the range above the 5-session low). This suggests the week started near the top of its range."


        "01: Week down & Body5D > 0.5*Range5D" =>
            "The 5-session window must be net negative (yesterday's close is below the D5 open), and the 5-session body must be strong: more than half of the total 5-session range. This describes a directional down week with meaningful follow-through."

        "02: Week down & Body5D < 0.5*Range5D" =>
            "The 5-session window must be net negative (yesterday's close is below the D5 open), but the 5-session body must be relatively small compared to the total 5-session range. This describes a down week with more back-and-forth (less directional pressure)."

        "03: (OpenD5-LowestL) < (HighestH-CloseD1)" =>
            "The D5 open must be closer to the 5-session low than yesterday's close is to the 5-session high. In practice, it suggests the week ended nearer the bottom of its 5-session range, compared to where it started."

        "04: (HighestH-Max(HighestC,HighestO)) > (Min(LowestO,LowestC)-LowestL)" =>
            "Within the last 5 sessions, the 'upper tail' from the 5-session high down to the best of (highest open, highest close) must be larger than the 'lower tail' from the worst of (lowest open, lowest close) down to the 5-session low. This indicates price action is positioned toward the lower part of the 5-session range (bearish distribution)."

        "05: (HighestH-CloseD1) > (CloseD1-LowestL)" =>
            "Yesterday's close must be closer to the 5-session low than to the 5-session high. In other words, the close is in the lower half of the 5-session range."

        "06: CloseD1 < mid(LowestL,HighestH)" =>
            "Yesterday's close must be below the midpoint of the 5-session range (midpoint between the lowest low and highest high across the last 5 sessions). This places the close in the lower half of the week."

        "07: (HighestH-CloseD1) > 0.75*(HighestH-LowestL)" =>
            "Yesterday's close must be in the bottom quarter of the 5-session range (it is more than 75% of the range below the 5-session high). This suggests the week ended near the bottom of its range."


        "08: Always true" =>
            "This filter is disabled: it always evaluates to true."

        =>
            "Selected weekly condition not recognized. Please verify that the option string matches exactly the switch case label."




// Day0 Info Box Plotter
f_hideTable(table t) =>
    for r = 0 to 5
        for c = 0 to 1
            table.cell(t, c, r, text="", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))

f_pt_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left




export plot_condition_day0_info(string condKey, string corner, int textSize, string calcMode) =>


    var table tBL = table.new(f_pt_pos(corner), 2, 6, frame_width=1, frame_color=color.new(color.white, 80), border_width=1, border_color=color.new(color.white, 90))


    color accent   = color.rgb(96, 180, 255)
    color hdrBg    = color.rgb(1, 26, 76)
    color bodyBg   = color.rgb(11, 14, 20)
    color hdrTxt   = color.rgb(235, 245, 255)
    color bodyTxt  = color.rgb(210, 220, 240)

    int sHdr = textSize + 2

    if barstate.islast
        string meaning = condition_day0_meaning(condKey)
        string calcTxt = f_calcMethodText(calcMode == "Day" ? "Day" : "Session")

        for r = 0 to 5
            table.cell(tBL, 0, r, text=" ", bgcolor=(r % 2 == 0 ? color.new(accent, 0) : color.new(accent, 15)))

        table.cell(tBL, 1, 0, text="CHOSEN CONDITION",     text_color=hdrTxt, bgcolor=hdrBg,  text_size=sHdr)
        table.cell(tBL, 1, 2, text="CONDITION MEANING",    text_color=hdrTxt, bgcolor=hdrBg,  text_size=sHdr)
        table.cell(tBL, 1, 4, text="CALCULATION METHOD",   text_color=hdrTxt, bgcolor=hdrBg,  text_size=sHdr)

        table.cell(tBL, 1, 1, text=condKey,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(tBL, 1, 3, text=meaning,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(tBL, 1, 5, text=calcTxt,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)







// Day1 Info Box Plotter
export plot_condition_day1_info(string condKey, string corner, int textSize, string calcMode) =>


    var table t = table.new(f_pt_pos(corner), 2, 6, frame_width=1, frame_color=color.new(color.white, 80), border_width=1, border_color=color.new(color.white, 90))

    int sHdr = textSize + 2

    color accent   = color.rgb(96, 180, 255)
    color hdrBg    = color.rgb(1, 26, 76)
    color bodyBg   = color.rgb(11, 14, 20)
    color hdrTxt   = color.rgb(235, 245, 255)
    color bodyTxt  = color.rgb(210, 220, 240)

    if barstate.islast
        string meaning = condition_day1_meaning(condKey)
        string calcTxt = f_calcMethodText(calcMode == "Day" ? "Day" : "Session")

        for r = 0 to 5
            table.cell(t, 0, r, text=" ", bgcolor=(r % 2 == 0 ? color.new(accent, 0) : color.new(accent, 15)))

        table.cell(t, 1, 0, text="CHOSEN CONDITION",   text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 2, text="CONDITION MEANING",  text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 4, text="CALCULATION METHOD", text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)

        table.cell(t, 1, 1, text=condKey,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 3, text=meaning,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 5, text=calcTxt,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)





// Day2 Info Box Plotter
export plot_condition_day2_info(string condKey, string corner, int textSize, string calcMode) =>


    var table t = table.new(f_pt_pos(corner), 2, 6, frame_width=1, frame_color=color.new(color.white, 80), border_width=1, border_color=color.new(color.white, 90))

    int sHdr = textSize + 2

    color accent   = color.rgb(96, 180, 255)
    color hdrBg    = color.rgb(1, 26, 76)
    color bodyBg   = color.rgb(11, 14, 20)
    color hdrTxt   = color.rgb(235, 245, 255)
    color bodyTxt  = color.rgb(210, 220, 240)

    if barstate.islast
        string meaning = condition_day2_meaning(condKey)
        string calcTxt = f_calcMethodText(calcMode == "Day" ? "Day" : "Session")

        // Accent strip
        for r = 0 to 5
            table.cell(t, 0, r, text=" ", bgcolor=(r % 2 == 0 ? color.new(accent, 0) : color.new(accent, 15)))

        // Section headers
        table.cell(t, 1, 0, text="CHOSEN CONDITION",   text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 2, text="CONDITION MEANING",  text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 4, text="CALCULATION METHOD", text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)

        // Bodies
        table.cell(t, 1, 1, text=condKey,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 3, text=meaning,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 5, text=calcTxt,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)



// Weekly Info Box Plotter

export plot_condition_W_info(string condKey, string corner, int textSize, string calcMode) =>

    var table t = table.new(f_pt_pos(corner), 2, 6, frame_width=1, frame_color=color.new(color.white, 80), border_width=1, border_color=color.new(color.white, 90))

    int sHdr = textSize + 2

    // Palette 
    color accent   = color.rgb(96, 180, 255)
    color hdrBg    = color.rgb(1, 26, 76)
    color bodyBg   = color.rgb(11, 14, 20)
    color hdrTxt   = color.rgb(235, 245, 255)
    color bodyTxt  = color.rgb(210, 220, 240)

    if barstate.islast
        string meaning = condition_W_meaning(condKey)
        string calcTxt = f_calcMethodText(calcMode == "Day" ? "Day" : "Session")

        // Accent strip
        for r = 0 to 5
            table.cell(t, 0, r, text=" ", bgcolor=(r % 2 == 0 ? color.new(accent, 0) : color.new(accent, 15)))

        // Headers 
        table.cell(t, 1, 0, text="CHOSEN CONDITION",   text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 2, text="CONDITION MEANING",  text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 4, text="CALCULATION METHOD", text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)

        // Bodies
        table.cell(t, 1, 1, text=condKey,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 3, text=meaning,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 5, text=calcTxt,  text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
````
