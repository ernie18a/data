<!-- tradingview-pine-id: PUB;fae2d4abd26348178cd2b8b53925699a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FT_TV_EL

Source: https://www.tradingview.com/script/womXcQs4-FT-TV-EL/

## Description

FT_TV_EL is a Pine Script® v6 library which provides a reusable framework for calculating configurable long and short entry levels in systematic trading strategies.

The library works with the OHLC and pre-calculated market-context structures, allowing entry prices to be derived consistently from current market data, previous Day/Session periods and broader volatility or price-structure references.

Entry Level Framework

The available entry-level calculations cover several categories, including:

[*]Current and historical Day/Session Open, High, Low and Close references.

[*]Rolling highest-high and lowest-low levels.

[*]Moving-average and average-range based price levels.

[*]ATR-based volatility extensions using multiple ATR lengths and multipliers.

[*]Current-bar and historical-bar High/Low references.

[*]Session-start High, Low and range-based extensions.

[*]Percentage-based price offsets.

[*]Day/Session range-based extensions.

[*]Classic pivot-point support and resistance levels.

[*]Current weekly High and Low.

[*]Extrema calculated across the previous five Day/Session periods.

Main exported functionality

[*][pine]long_entry_level()[/pine] — Calculates the selected long-side entry price. The function provides a large catalog of configurable entry-level formulas using OHLC structures, volatility, recent extrema, pivot calculations, percentage offsets, session references and other price-derived methods.

[*][pine]short_entry_level()[/pine] — Calculates the corresponding short-side entry price using the same modular framework and a dedicated set of short-oriented level definitions.

[*][pine]plot_long_entry_level_info()[/pine] — Displays an optional chart information panel for the selected long entry level, including the chosen definition, a human-readable explanation of its logic and the OHLC calculation mode being used.

[*][pine]plot_short_entry_level_info()[/pine] — Provides the equivalent information panel for the selected short entry level.

Framework integration

The main entry-level functions use two shared data structures:

[*][pine]FT_OHLC[/pine] — Provides the current and previous Day/Session OHLC periods.

[*][pine]PtnCtx[/pine] — Provides pre-calculated contextual information including recent extrema, ranges, bodies and session-state references.

This architecture allows individual strategies to change their entry-price methodology without duplicating the underlying market-context calculations.

Purpose

FT_TV_EL is primarily designed as a shared entry-level dependency for other strategies. It separates entry-price generation from signal generation and trade-management logic, providing a consistent and reusable framework for testing and deploying different entry methodologies across multiple strategies.

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

library("FT_TV_EL", overlay = true, dynamic_requests = true)


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



export long_entry_level(string i_entry_myle, array<float> FT_OHLC, array<float> PtnCtx) =>

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

    float pivotP_0 = (highd0 + lowd0 + closed0) / 3.0
    float pivotR1_0 = 2.0*pivotP_0 - lowd0
    float pivotS1_0 = 2.0*pivotP_0 - highd0
    float pivotR2_0 = pivotP_0 + highd0 - lowd0
    float pivotS2_0 = pivotP_0 - highd0 + lowd0

    float pivotP_1 = (highd1 + lowd1 + closed1) / 3.0
    float pivotR1_1 = 2.0*pivotP_1 - lowd1
    float pivotS1_1 = 2.0*pivotP_1 - highd1
    float pivotR2_1 = pivotP_1 + highd1 - lowd1
    float pivotS2_1 = pivotP_1 - highd1 + lowd1

    float pivotP_2 = (highd2 + lowd2 + closed2) / 3.0
    float pivotR1_2 = 2.0*pivotP_2 - lowd2
    float pivotS1_2 = 2.0*pivotP_2 - highd2
    float pivotR2_2 = pivotP_2 + highd2 - lowd2
    float pivotS2_2 = pivotP_2 - highd2 + lowd2

    float pivotP_3 = (highd3 + lowd3 + closed3) / 3.0
    float pivotR1_3 = 2.0*pivotP_3 - lowd3
    float pivotS1_3 = 2.0*pivotP_3 - highd3
    float pivotR2_3 = pivotP_3 + highd3 - lowd3
    float pivotS2_3 = pivotP_3 - highd3 + lowd3

    float pivotP_4 = (highd4 + lowd4 + closed4) / 3.0
    float pivotR1_4 = 2.0*pivotP_4 - lowd4
    float pivotS1_4 = 2.0*pivotP_4 - highd4
    float pivotR2_4 = pivotP_4 + highd4 - lowd4
    float pivotS2_4 = pivotP_4 - highd4 + lowd4

    float pivotP_5 = (highd5 + lowd5 + closed5) / 3.0
    float pivotR1_5 = 2.0*pivotP_5 - lowd5
    float pivotS1_5 = 2.0*pivotP_5 - highd5
    float pivotR2_5 = pivotP_5 + highd5 - lowd5
    float pivotS2_5 = pivotP_5 - highd5 + lowd5

    float pivotP_W  = (HighestH + LowestL + closed1) / 3.0
    float pivotR1_W = 2.0*pivotP_W - LowestL
    float pivotS1_W = 2.0*pivotP_W - HighestH
    float pivotR2_W = pivotP_W + HighestH - LowestL
    float pivotS2_W = pivotP_W - HighestH + LowestL

    float weekHigh = request.security(syminfo.tickerid, "W", high, barmerge.gaps_off, barmerge.lookahead_on)
    float weekLow  = request.security(syminfo.tickerid, "W", low,  barmerge.gaps_off, barmerge.lookahead_on)

    float atr5 = AvgTrueRange(5)
    float atr10 = AvgTrueRange(10)
    float atr20 = AvgTrueRange(20)
    float atr30 = AvgTrueRange(30)
    float atr50 = AvgTrueRange(50)

    float myle = switch i_entry_myle
        "00 N0: D0 Low if close>Low" => close > lowd0[1] ? lowd0[1] : na
        "00 N1: D1 Low if close>Low" => close > lowd1 ? lowd1 : na
        "00 N2: D2 Low if close>Low" => close > lowd2 ? lowd2 : na
        "00 N3: D3 Low if close>Low" => close > lowd3 ? lowd3 : na
        "00 N4: D4 Low if close>Low" => close > lowd4 ? lowd4 : na
        "00 N5: D5 Low if close>Low" => close > lowd5 ? lowd5 : na
        "01 N0: 1% below D0 Low if close>Low" => close > lowd0[1] ? lowd0[1] * (1 - 0.01) : na
        "01 N1: 1% below D1 Low if close>Low" => close > lowd1 ? lowd1 * (1 - 0.01) : na
        "01 N2: 1% below D2 Low if close>Low" => close > lowd2 ? lowd2 * (1 - 0.01) : na
        "01 N3: 1% below D3 Low if close>Low" => close > lowd3 ? lowd3 * (1 - 0.01) : na
        "01 N4: 1% below D4 Low if close>Low" => close > lowd4 ? lowd4 * (1 - 0.01) : na
        "01 N5: 1% below D5 Low if close>Low" => close > lowd5 ? lowd5 * (1 - 0.01) : na
        "02 N0: 1% above D0 Low if close>Low" => close > lowd0[1] ? lowd0[1] * (1 + 0.01) : na
        "02 N1: 1% above D1 Low if close>Low" => close > lowd1 ? lowd1 * (1 + 0.01) : na
        "02 N2: 1% above D2 Low if close>Low" => close > lowd2 ? lowd2 * (1 + 0.01) : na
        "02 N3: 1% above D3 Low if close>Low" => close > lowd3 ? lowd3 * (1 + 0.01) : na
        "02 N4: 1% above D4 Low if close>Low" => close > lowd4 ? lowd4 * (1 + 0.01) : na
        "02 N5: 1% above D5 Low if close>Low" => close > lowd5 ? lowd5 * (1 + 0.01) : na
        "03: lowest low (5 bars)" => ta.lowest(low, 5)
        "04: lowest low (10 bars)" => ta.lowest(low, 10)
        "05: lowest low (30 bars)" => ta.lowest(low, 30)
        "06: lowest low (50 bars)" => ta.lowest(low, 50)
        "07: SMA(low,5) - SMA(range,5)" => ta.sma(low, 5) - ta.sma(high - low, 5)
        "08: SMA(low,10) - SMA(range,10)" => ta.sma(low, 10) - ta.sma(high - low, 10)
        "09: SMA(low,30) - SMA(range,30)" => ta.sma(low, 30) - ta.sma(high - low, 30)
        "10: SMA(low,50) - SMA(range,50)" => ta.sma(low, 50) - ta.sma(high - low, 50)
        "11: SMA(low,5)" => ta.sma(low, 5)
        "12: SMA(low,10)" => ta.sma(low, 10)
        "13: SMA(low,30)" => ta.sma(low, 30)
        "14: SMA(low,50)" => ta.sma(low, 50)
        "15: SMA(close,5) - SMA(range,5)" => ta.sma(close, 5) - ta.sma(high - low, 5)
        "16: SMA(close,10) - SMA(range,10)" => ta.sma(close, 10) - ta.sma(high - low, 10)
        "17: SMA(close,30) - SMA(range,30)" => ta.sma(close, 30) - ta.sma(high - low, 30)
        "18: SMA(close,50) - SMA(range,50)" => ta.sma(close, 50) - ta.sma(high - low, 50)
        "19 N0: 2 * D0 Low - Close" => 2*lowd0 - closed0
        "19 N1: 2 * D1 Low - Close" => 2*lowd1 - closed1
        "19 N2: 2 * D2 Low - Close" => 2*lowd2 - closed2
        "19 N3: 2 * D3 Low - Close" => 2*lowd3 - closed3
        "19 N4: 2 * D4 Low - Close" => 2*lowd4 - closed4
        "19 N5: 2 * D5 Low - Close" => 2*lowd5 - closed5
        "20 N0: extension of D0 Low toward D1 Close" => closed1 < lowd0 ? (lowd0 - (lowd0 - closed1)) : na
        "20 N1: extension of D1 Low toward D2 Close" => closed2 < lowd1 ? (lowd1 - (lowd1 - closed2)) : na
        "20 N2: extension of D2 Low toward D3 Close" => closed3 < lowd2 ? (lowd2 - (lowd2 - closed3)) : na
        "20 N3: extension of D3 Low toward D4 Close" => closed4 < lowd3 ? (lowd3 - (lowd3 - closed4)) : na
        "20 N4: extension of D4 Low toward D5 Close" => closed5 < lowd4 ? (lowd4 - (lowd4 - closed5)) : na
        "21: current bar low" => low
        "22: low[1]" => low[1]
        "23: low[2]" => low[2]
        "24: low[3]" => low[3]
        "25: low[4]" => low[4]
        "26: low[5]" => low[5]
        "27: session-start bar low" => sessStartLow
        "28: sessStartLow - sessStartRange" => sessStartLow - sessStartRange
        "29: LowestL (D1..D5)" => LowestL
        "30: LowestC (D1..D5)" => LowestC
        "31: LowestO (D1..D5)" => LowestO
        "32: lowest low (relative 5)" => ta.lowest(low, 5)
        "33: lowest low (relative 10)" => ta.lowest(low, 10)
        "34: lowest low (relative 20)" => ta.lowest(low, 20)
        "35: lowest low (relative 30)" => ta.lowest(low, 30)
        "36: lowest low (relative 40)" => ta.lowest(low, 40)
        "37: lowest low (relative 50)" => ta.lowest(low, 50)
        "38: low - range" => low - (high - low)
        "39: close - range" => close - (high - low)
        "40: low - 0.5*range" => low - (high - low)*0.5
        "41: close - 0.5*range" => close - (high - low)*0.5
        "42: low - 0.25*range" => low - (high - low)*0.25
        "43: close - 0.25*range" => close - (high - low)*0.25
        "44: low - 0.5% of low" => low * (1 - 0.01*0.5)
        "45: low - 1.0% of low" => low * (1 - 0.01*1.0)
        "46: low - 1.5% of low" => low * (1 - 0.01*1.5)
        "47: low - 2.0% of low" => low * (1 - 0.01*2.0)
        "48: low - 2.5% of low" => low * (1 - 0.01*2.5)
        "49: close - 0.5% of close" => close * (1 - 0.01*0.5)
        "50: close - 1.0% of close" => close * (1 - 0.01*1.0)
        "51: close - 1.5% of close" => close * (1 - 0.01*1.5)
        "52: close - 2.0% of close" => close * (1 - 0.01*2.0)
        "53: close - 2.5% of close" => close * (1 - 0.01*2.5)
        "54 N0: Pivot S1 from D0" => StartOfSession ? pivotS1_0 : na
        "55 N0: Pivot S2 from D0" => StartOfSession ? pivotS2_0 : na
        "54 N1: Pivot S1 from D1" => StartOfSession ? pivotS1_1 : na
        "55 N1: Pivot S2 from D1" => StartOfSession ? pivotS2_1 : na
        "54 N2: Pivot S1 from D2" => StartOfSession ? pivotS1_2 : na
        "55 N2: Pivot S2 from D2" => StartOfSession ? pivotS2_2 : na
        "54 N3: Pivot S1 from D3" => StartOfSession ? pivotS1_3 : na
        "55 N3: Pivot S2 from D3" => StartOfSession ? pivotS2_3 : na
        "54 N4: Pivot S1 from D4" => StartOfSession ? pivotS1_4 : na
        "55 N4: Pivot S2 from D4" => StartOfSession ? pivotS2_4 : na
        "54 N5: Pivot S1 from D5" => StartOfSession ? pivotS1_5 : na
        "55 N5: Pivot S2 from D5" => StartOfSession ? pivotS2_5 : na
        "56: current open" => open
        "57: current week low" => weekLow
        "58: low - ATR(5)" => low - atr5
        "59: low - 0.5*ATR(5)" => low - atr5*0.5
        "60: low - 0.25*ATR(5)" => low - atr5*0.25
        "61: low - ATR(10)" => low - atr10
        "62: low - 0.5*ATR(10)" => low - atr10*0.5
        "63: low - 0.25*ATR(10)" => low - atr10*0.25
        "64: low - ATR(20)" => low - atr20
        "65: low - 0.5*ATR(20)" => low - atr20*0.5
        "66: low - 0.25*ATR(20)" => low - atr20*0.25
        "67: low - ATR(30)" => low - atr30
        "68: low - 0.5*ATR(30)" => low - atr30*0.5
        "69: low - 0.25*ATR(30)" => low - atr30*0.25
        "70: low - ATR(50)" => low - atr50
        "71: low - 0.5*ATR(50)" => low - atr50*0.5
        "72: low - 0.25*ATR(50)" => low - atr50*0.25
        "73 N0: D0 Low - ATR(5)" => lowd0 - atr5*1.0
        "73 N1: D1 Low - ATR(5)" => lowd1 - atr5*1.0
        "73 N2: D2 Low - ATR(5)" => lowd2 - atr5*1.0
        "73 N3: D3 Low - ATR(5)" => lowd3 - atr5*1.0
        "73 N4: D4 Low - ATR(5)" => lowd4 - atr5*1.0
        "73 N5: D5 Low - ATR(5)" => lowd5 - atr5*1.0
        "74 N0: D0 Low - 0.5*ATR(5)" => lowd0 - atr5*0.5
        "74 N1: D1 Low - 0.5*ATR(5)" => lowd1 - atr5*0.5
        "74 N2: D2 Low - 0.5*ATR(5)" => lowd2 - atr5*0.5
        "74 N3: D3 Low - 0.5*ATR(5)" => lowd3 - atr5*0.5
        "74 N4: D4 Low - 0.5*ATR(5)" => lowd4 - atr5*0.5
        "74 N5: D5 Low - 0.5*ATR(5)" => lowd5 - atr5*0.5
        "75 N0: D0 Low - 0.25*ATR(5)" => lowd0 - atr5*0.25
        "75 N1: D1 Low - 0.25*ATR(5)" => lowd1 - atr5*0.25
        "75 N2: D2 Low - 0.25*ATR(5)" => lowd2 - atr5*0.25
        "75 N3: D3 Low - 0.25*ATR(5)" => lowd3 - atr5*0.25
        "75 N4: D4 Low - 0.25*ATR(5)" => lowd4 - atr5*0.25
        "75 N5: D5 Low - 0.25*ATR(5)" => lowd5 - atr5*0.25
        "76 N0: D0 Low - ATR(10)" => lowd0 - atr10*1.0
        "76 N1: D1 Low - ATR(10)" => lowd1 - atr10*1.0
        "76 N2: D2 Low - ATR(10)" => lowd2 - atr10*1.0
        "76 N3: D3 Low - ATR(10)" => lowd3 - atr10*1.0
        "76 N4: D4 Low - ATR(10)" => lowd4 - atr10*1.0
        "76 N5: D5 Low - ATR(10)" => lowd5 - atr10*1.0
        "77 N0: D0 Low - 0.5*ATR(10)" => lowd0 - atr10*0.5
        "77 N1: D1 Low - 0.5*ATR(10)" => lowd1 - atr10*0.5
        "77 N2: D2 Low - 0.5*ATR(10)" => lowd2 - atr10*0.5
        "77 N3: D3 Low - 0.5*ATR(10)" => lowd3 - atr10*0.5
        "77 N4: D4 Low - 0.5*ATR(10)" => lowd4 - atr10*0.5
        "77 N5: D5 Low - 0.5*ATR(10)" => lowd5 - atr10*0.5
        "78 N0: D0 Low - 0.25*ATR(10)" => lowd0 - atr10*0.25
        "78 N1: D1 Low - 0.25*ATR(10)" => lowd1 - atr10*0.25
        "78 N2: D2 Low - 0.25*ATR(10)" => lowd2 - atr10*0.25
        "78 N3: D3 Low - 0.25*ATR(10)" => lowd3 - atr10*0.25
        "78 N4: D4 Low - 0.25*ATR(10)" => lowd4 - atr10*0.25
        "78 N5: D5 Low - 0.25*ATR(10)" => lowd5 - atr10*0.25
        "79 N0: D0 Low - ATR(20)" => lowd0 - atr20*1.0
        "79 N1: D1 Low - ATR(20)" => lowd1 - atr20*1.0
        "79 N2: D2 Low - ATR(20)" => lowd2 - atr20*1.0
        "79 N3: D3 Low - ATR(20)" => lowd3 - atr20*1.0
        "79 N4: D4 Low - ATR(20)" => lowd4 - atr20*1.0
        "79 N5: D5 Low - ATR(20)" => lowd5 - atr20*1.0
        "80 N0: D0 Low - 0.5*ATR(20)" => lowd0 - atr20*0.5
        "80 N1: D1 Low - 0.5*ATR(20)" => lowd1 - atr20*0.5
        "80 N2: D2 Low - 0.5*ATR(20)" => lowd2 - atr20*0.5
        "80 N3: D3 Low - 0.5*ATR(20)" => lowd3 - atr20*0.5
        "80 N4: D4 Low - 0.5*ATR(20)" => lowd4 - atr20*0.5
        "80 N5: D5 Low - 0.5*ATR(20)" => lowd5 - atr20*0.5
        "81 N0: D0 Low - 0.25*ATR(20)" => lowd0 - atr20*0.25
        "81 N1: D1 Low - 0.25*ATR(20)" => lowd1 - atr20*0.25
        "81 N2: D2 Low - 0.25*ATR(20)" => lowd2 - atr20*0.25
        "81 N3: D3 Low - 0.25*ATR(20)" => lowd3 - atr20*0.25
        "81 N4: D4 Low - 0.25*ATR(20)" => lowd4 - atr20*0.25
        "81 N5: D5 Low - 0.25*ATR(20)" => lowd5 - atr20*0.25
        "82 N0: D0 Low - ATR(30)" => lowd0 - atr30*1.0
        "82 N1: D1 Low - ATR(30)" => lowd1 - atr30*1.0
        "82 N2: D2 Low - ATR(30)" => lowd2 - atr30*1.0
        "82 N3: D3 Low - ATR(30)" => lowd3 - atr30*1.0
        "82 N4: D4 Low - ATR(30)" => lowd4 - atr30*1.0
        "82 N5: D5 Low - ATR(30)" => lowd5 - atr30*1.0
        "83 N0: D0 Low - 0.5*ATR(30)" => lowd0 - atr30*0.5
        "83 N1: D1 Low - 0.5*ATR(30)" => lowd1 - atr30*0.5
        "83 N2: D2 Low - 0.5*ATR(30)" => lowd2 - atr30*0.5
        "83 N3: D3 Low - 0.5*ATR(30)" => lowd3 - atr30*0.5
        "83 N4: D4 Low - 0.5*ATR(30)" => lowd4 - atr30*0.5
        "83 N5: D5 Low - 0.5*ATR(30)" => lowd5 - atr30*0.5
        "84 N0: D0 Low - 0.25*ATR(30)" => lowd0 - atr30*0.25
        "84 N1: D1 Low - 0.25*ATR(30)" => lowd1 - atr30*0.25
        "84 N2: D2 Low - 0.25*ATR(30)" => lowd2 - atr30*0.25
        "84 N3: D3 Low - 0.25*ATR(30)" => lowd3 - atr30*0.25
        "84 N4: D4 Low - 0.25*ATR(30)" => lowd4 - atr30*0.25
        "84 N5: D5 Low - 0.25*ATR(30)" => lowd5 - atr30*0.25
        "85 N0: D0 Low - ATR(50)" => lowd0 - atr50*1.0
        "85 N1: D1 Low - ATR(50)" => lowd1 - atr50*1.0
        "85 N2: D2 Low - ATR(50)" => lowd2 - atr50*1.0
        "85 N3: D3 Low - ATR(50)" => lowd3 - atr50*1.0
        "85 N4: D4 Low - ATR(50)" => lowd4 - atr50*1.0
        "85 N5: D5 Low - ATR(50)" => lowd5 - atr50*1.0
        "86 N0: D0 Low - 0.5*ATR(50)" => lowd0 - atr50*0.5
        "86 N1: D1 Low - 0.5*ATR(50)" => lowd1 - atr50*0.5
        "86 N2: D2 Low - 0.5*ATR(50)" => lowd2 - atr50*0.5
        "86 N3: D3 Low - 0.5*ATR(50)" => lowd3 - atr50*0.5
        "86 N4: D4 Low - 0.5*ATR(50)" => lowd4 - atr50*0.5
        "86 N5: D5 Low - 0.5*ATR(50)" => lowd5 - atr50*0.5
        "87 N0: D0 Low - 0.25*ATR(50)" => lowd0 - atr50*0.25
        "87 N1: D1 Low - 0.25*ATR(50)" => lowd1 - atr50*0.25
        "87 N2: D2 Low - 0.25*ATR(50)" => lowd2 - atr50*0.25
        "87 N3: D3 Low - 0.25*ATR(50)" => lowd3 - atr50*0.25
        "87 N4: D4 Low - 0.25*ATR(50)" => lowd4 - atr50*0.25
        "87 N5: D5 Low - 0.25*ATR(50)" => lowd5 - atr50*0.25
        "88 N0: D0 Low - 1*Range(D0)" => lowd0 - (highd0 - lowd0)*1.0
        "88 N1: D1 Low - 1*Range(D1)" => lowd1 - (highd1 - lowd1)*1.0
        "88 N2: D2 Low - 1*Range(D2)" => lowd2 - (highd2 - lowd2)*1.0
        "88 N3: D3 Low - 1*Range(D3)" => lowd3 - (highd3 - lowd3)*1.0
        "88 N4: D4 Low - 1*Range(D4)" => lowd4 - (highd4 - lowd4)*1.0
        "88 N5: D5 Low - 1*Range(D5)" => lowd5 - (highd5 - lowd5)*1.0
        "89 N0: D0 Low - 0.6667*Range(D0)" => lowd0 - (highd0 - lowd0)*0.6666666666666666
        "89 N1: D1 Low - 0.6667*Range(D1)" => lowd1 - (highd1 - lowd1)*0.6666666666666666
        "89 N2: D2 Low - 0.6667*Range(D2)" => lowd2 - (highd2 - lowd2)*0.6666666666666666
        "89 N3: D3 Low - 0.6667*Range(D3)" => lowd3 - (highd3 - lowd3)*0.6666666666666666
        "89 N4: D4 Low - 0.6667*Range(D4)" => lowd4 - (highd4 - lowd4)*0.6666666666666666
        "89 N5: D5 Low - 0.6667*Range(D5)" => lowd5 - (highd5 - lowd5)*0.6666666666666666
        "90 N0: D0 Low - 0.5*Range(D0)" => lowd0 - (highd0 - lowd0)*0.5
        "90 N1: D1 Low - 0.5*Range(D1)" => lowd1 - (highd1 - lowd1)*0.5
        "90 N2: D2 Low - 0.5*Range(D2)" => lowd2 - (highd2 - lowd2)*0.5
        "90 N3: D3 Low - 0.5*Range(D3)" => lowd3 - (highd3 - lowd3)*0.5
        "90 N4: D4 Low - 0.5*Range(D4)" => lowd4 - (highd4 - lowd4)*0.5
        "90 N5: D5 Low - 0.5*Range(D5)" => lowd5 - (highd5 - lowd5)*0.5
        "91 N0: D0 Low - 0.3333*Range(D0)" => lowd0 - (highd0 - lowd0)*0.3333333333333333
        "91 N1: D1 Low - 0.3333*Range(D1)" => lowd1 - (highd1 - lowd1)*0.3333333333333333
        "91 N2: D2 Low - 0.3333*Range(D2)" => lowd2 - (highd2 - lowd2)*0.3333333333333333
        "91 N3: D3 Low - 0.3333*Range(D3)" => lowd3 - (highd3 - lowd3)*0.3333333333333333
        "91 N4: D4 Low - 0.3333*Range(D4)" => lowd4 - (highd4 - lowd4)*0.3333333333333333
        "91 N5: D5 Low - 0.3333*Range(D5)" => lowd5 - (highd5 - lowd5)*0.3333333333333333
        "92 N0: D0 Low - 0.25*Range(D0)" => lowd0 - (highd0 - lowd0)*0.25
        "92 N1: D1 Low - 0.25*Range(D1)" => lowd1 - (highd1 - lowd1)*0.25
        "92 N2: D2 Low - 0.25*Range(D2)" => lowd2 - (highd2 - lowd2)*0.25
        "92 N3: D3 Low - 0.25*Range(D3)" => lowd3 - (highd3 - lowd3)*0.25
        "92 N4: D4 Low - 0.25*Range(D4)" => lowd4 - (highd4 - lowd4)*0.25
        "92 N5: D5 Low - 0.25*Range(D5)" => lowd5 - (highd5 - lowd5)*0.25
        "93: Pivot S1 from 5-day extremes" => StartOfSession ? pivotS1_W : na
        "94: Pivot S2 from 5-day extremes" => StartOfSession ? pivotS2_W : na
        "95: None" => 0.0
        "00 N0: D0 High if close<High" => close < highd0[1] ? highd0[1] : na
        "00 N1: D1 High if close<High" => close < highd1 ? highd1 : na
        "00 N2: D2 High if close<High" => close < highd2 ? highd2 : na
        "00 N3: D3 High if close<High" => close < highd3 ? highd3 : na
        "00 N4: D4 High if close<High" => close < highd4 ? highd4 : na
        "00 N5: D5 High if close<High" => close < highd5 ? highd5 : na
        "01 N0: 1% above D0 High if close<High" => close < highd0[1] ? highd0[1] * (1 + 0.01) : na
        "01 N1: 1% above D1 High if close<High" => close < highd1 ? highd1 * (1 + 0.01) : na
        "01 N2: 1% above D2 High if close<High" => close < highd2 ? highd2 * (1 + 0.01) : na
        "01 N3: 1% above D3 High if close<High" => close < highd3 ? highd3 * (1 + 0.01) : na
        "01 N4: 1% above D4 High if close<High" => close < highd4 ? highd4 * (1 + 0.01) : na
        "01 N5: 1% above D5 High if close<High" => close < highd5 ? highd5 * (1 + 0.01) : na
        "02 N0: 1% below D0 High if close<High" => close < highd0[1] ? highd0[1] * (1 - 0.01) : na
        "02 N1: 1% below D1 High if close<High" => close < highd1 ? highd1 * (1 - 0.01) : na
        "02 N2: 1% below D2 High if close<High" => close < highd2 ? highd2 * (1 - 0.01) : na
        "02 N3: 1% below D3 High if close<High" => close < highd3 ? highd3 * (1 - 0.01) : na
        "02 N4: 1% below D4 High if close<High" => close < highd4 ? highd4 * (1 - 0.01) : na
        "02 N5: 1% below D5 High if close<High" => close < highd5 ? highd5 * (1 - 0.01) : na
        "03: highest high (5 bars)" => ta.highest(high, 5)
        "04: highest high (10 bars)" => ta.highest(high, 10)
        "05: highest high (30 bars)" => ta.highest(high, 30)
        "06: highest high (50 bars)" => ta.highest(high, 50)
        "07: SMA(high,5) + SMA(range,5)" => ta.sma(high, 5) + ta.sma(high - low, 5)
        "08: SMA(high,10) + SMA(range,10)" => ta.sma(high, 10) + ta.sma(high - low, 10)
        "09: SMA(high,30) + SMA(range,30)" => ta.sma(high, 30) + ta.sma(high - low, 30)
        "10: SMA(high,50) + SMA(range,50)" => ta.sma(high, 50) + ta.sma(high - low, 50)
        "11: SMA(high,5)" => ta.sma(high, 5)
        "12: SMA(high,10)" => ta.sma(high, 10)
        "13: SMA(high,30)" => ta.sma(high, 30)
        "14: SMA(high,50)" => ta.sma(high, 50)
        "15: SMA(close,5) + SMA(range,5)" => ta.sma(close, 5) + ta.sma(high - low, 5)
        "16: SMA(close,10) + SMA(range,10)" => ta.sma(close, 10) + ta.sma(high - low, 10)
        "17: SMA(close,30) + SMA(range,30)" => ta.sma(close, 30) + ta.sma(high - low, 30)
        "18: SMA(close,50) + SMA(range,50)" => ta.sma(close, 50) + ta.sma(high - low, 50)
        "19 N0: extension of D0 High - Close" => 2*highd0 - closed0
        "19 N1: extension of D1 High - Close" => 2*highd1 - closed1
        "19 N2: extension of D2 High - Close" => 2*highd2 - closed2
        "19 N3: extension of D3 High - Close" => 2*highd3 - closed3
        "19 N4: extension of D4 High - Close" => 2*highd4 - closed4
        "19 N5: extension of D5 High - Close" => 2*highd5 - closed5
        "20 N0: Short extend D0 High toward D1 Close" => closed1 > highd0 ? (highd0 + (closed1 - highd0)) : na
        "20 N1: Short extend D1 High toward D2 Close" => closed2 > highd1 ? (highd1 + (closed2 - highd1)) : na
        "20 N2: Short extend D2 High toward D3 Close" => closed3 > highd2 ? (highd2 + (closed3 - highd2)) : na
        "20 N3: Short extend D3 High toward D4 Close" => closed4 > highd3 ? (highd3 + (closed4 - highd3)) : na
        "20 N4: Short extend D4 High toward D5 Close" => closed5 > highd4 ? (highd4 + (closed5 - highd4)) : na
        "21: current bar high" => high
        "22: high[1]" => high[1]
        "23: high[2]" => high[2]
        "24: high[3]" => high[3]
        "25: high[4]" => high[4]
        "26: high[5]" => high[5]
        "27: session-start bar high" => sessStartHigh
        "28: sessStartHigh + sessStartRange" => sessStartHigh + sessStartRange
        "29: HighestH (D1..D5)" => HighestH
        "30: HighestC (D1..D5)" => HighestC
        "31: HighestO (D1..D5)" => HighestO
        "32: highest high (relative 5)" => ta.highest(high, 5)
        "33: highest high (relative 10)" => ta.highest(high, 10)
        "34: highest high (relative 20)" => ta.highest(high, 20)
        "35: highest high (relative 30)" => ta.highest(high, 30)
        "36: highest high (relative 40)" => ta.highest(high, 40)
        "37: highest high (relative 50)" => ta.highest(high, 50)
        "38: high + range" => high + (high - low)
        "39: close + range" => close + (high - low)
        "40: high + 0.5*range" => high + (high - low)*0.5
        "41: close + 0.5*range" => close + (high - low)*0.5
        "42: high + 0.25*range" => high + (high - low)*0.25
        "43: close + 0.25*range" => close + (high - low)*0.25
        "44: high + 0.5% of high" => high * (1 + 0.01*0.5)
        "45: high + 1.0% of high" => high * (1 + 0.01*1.0)
        "46: high + 1.5% of high" => high * (1 + 0.01*1.5)
        "47: high + 2.0% of high" => high * (1 + 0.01*2.0)
        "48: high + 2.5% of high" => high * (1 + 0.01*2.5)
        "49: close + 0.5% of close" => close * (1 + 0.01*0.5)
        "50: close + 1.0% of close" => close * (1 + 0.01*1.0)
        "51: close + 1.5% of close" => close * (1 + 0.01*1.5)
        "52: close + 2.0% of close" => close * (1 + 0.01*2.0)
        "53: close + 2.5% of close" => close * (1 + 0.01*2.5)
        "54 N0: Pivot R1 from D0" => StartOfSession ? pivotR1_0 : na
        "55 N0: Pivot R2 from D0" => StartOfSession ? pivotR2_0 : na
        "54 N1: Pivot R1 from D1" => StartOfSession ? pivotR1_1 : na
        "55 N1: Pivot R2 from D1" => StartOfSession ? pivotR2_1 : na
        "54 N2: Pivot R1 from D2" => StartOfSession ? pivotR1_2 : na
        "55 N2: Pivot R2 from D2" => StartOfSession ? pivotR2_2 : na
        "54 N3: Pivot R1 from D3" => StartOfSession ? pivotR1_3 : na
        "55 N3: Pivot R2 from D3" => StartOfSession ? pivotR2_3 : na
        "54 N4: Pivot R1 from D4" => StartOfSession ? pivotR1_4 : na
        "55 N4: Pivot R2 from D4" => StartOfSession ? pivotR2_4 : na
        "54 N5: Pivot R1 from D5" => StartOfSession ? pivotR1_5 : na
        "55 N5: Pivot R2 from D5" => StartOfSession ? pivotR2_5 : na
        "56: current open" => open
        "57: current week high" => weekHigh
        "58: high + ATR(5)" => high + atr5
        "59: high + 0.5*ATR(5)" => high + atr5*0.5
        "60: high + 0.25*ATR(5)" => high + atr5*0.25
        "61: high + ATR(10)" => high + atr10
        "62: high + 0.5*ATR(10)" => high + atr10*0.5
        "63: high + 0.25*ATR(10)" => high + atr10*0.25
        "64: high + ATR(20)" => high + atr20
        "65: high + 0.5*ATR(20)" => high + atr20*0.5
        "66: high + 0.25*ATR(20)" => high + atr20*0.25
        "67: high + ATR(30)" => high + atr30
        "68: high + 0.5*ATR(30)" => high + atr30*0.5
        "69: high + 0.25*ATR(30)" => high + atr30*0.25
        "70: high + ATR(50)" => high + atr50
        "71: high + 0.5*ATR(50)" => high + atr50*0.5
        "72: high + 0.25*ATR(50)" => high + atr50*0.25
        "73 N0: D0 High + ATR(5)" => highd0 + atr5*1.0
        "73 N1: D1 High + ATR(5)" => highd1 + atr5*1.0
        "73 N2: D2 High + ATR(5)" => highd2 + atr5*1.0
        "73 N3: D3 High + ATR(5)" => highd3 + atr5*1.0
        "73 N4: D4 High + ATR(5)" => highd4 + atr5*1.0
        "73 N5: D5 High + ATR(5)" => highd5 + atr5*1.0
        "74 N0: D0 High + 0.5*ATR(5)" => highd0 + atr5*0.5
        "74 N1: D1 High + 0.5*ATR(5)" => highd1 + atr5*0.5
        "74 N2: D2 High + 0.5*ATR(5)" => highd2 + atr5*0.5
        "74 N3: D3 High + 0.5*ATR(5)" => highd3 + atr5*0.5
        "74 N4: D4 High + 0.5*ATR(5)" => highd4 + atr5*0.5
        "74 N5: D5 High + 0.5*ATR(5)" => highd5 + atr5*0.5
        "75 N0: D0 High + 0.25*ATR(5)" => highd0 + atr5*0.25
        "75 N1: D1 High + 0.25*ATR(5)" => highd1 + atr5*0.25
        "75 N2: D2 High + 0.25*ATR(5)" => highd2 + atr5*0.25
        "75 N3: D3 High + 0.25*ATR(5)" => highd3 + atr5*0.25
        "75 N4: D4 High + 0.25*ATR(5)" => highd4 + atr5*0.25
        "75 N5: D5 High + 0.25*ATR(5)" => highd5 + atr5*0.25
        "76 N0: D0 High + ATR(10)" => highd0 + atr10*1.0
        "76 N1: D1 High + ATR(10)" => highd1 + atr10*1.0
        "76 N2: D2 High + ATR(10)" => highd2 + atr10*1.0
        "76 N3: D3 High + ATR(10)" => highd3 + atr10*1.0
        "76 N4: D4 High + ATR(10)" => highd4 + atr10*1.0
        "76 N5: D5 High + ATR(10)" => highd5 + atr10*1.0
        "77 N0: D0 High + 0.5*ATR(10)" => highd0 + atr10*0.5
        "77 N1: D1 High + 0.5*ATR(10)" => highd1 + atr10*0.5
        "77 N2: D2 High + 0.5*ATR(10)" => highd2 + atr10*0.5
        "77 N3: D3 High + 0.5*ATR(10)" => highd3 + atr10*0.5
        "77 N4: D4 High + 0.5*ATR(10)" => highd4 + atr10*0.5
        "77 N5: D5 High + 0.5*ATR(10)" => highd5 + atr10*0.5
        "78 N0: D0 High + 0.25*ATR(10)" => highd0 + atr10*0.25
        "78 N1: D1 High + 0.25*ATR(10)" => highd1 + atr10*0.25
        "78 N2: D2 High + 0.25*ATR(10)" => highd2 + atr10*0.25
        "78 N3: D3 High + 0.25*ATR(10)" => highd3 + atr10*0.25
        "78 N4: D4 High + 0.25*ATR(10)" => highd4 + atr10*0.25
        "78 N5: D5 High + 0.25*ATR(10)" => highd5 + atr10*0.25
        "79 N0: D0 High + ATR(20)" => highd0 + atr20*1.0
        "79 N1: D1 High + ATR(20)" => highd1 + atr20*1.0
        "79 N2: D2 High + ATR(20)" => highd2 + atr20*1.0
        "79 N3: D3 High + ATR(20)" => highd3 + atr20*1.0
        "79 N4: D4 High + ATR(20)" => highd4 + atr20*1.0
        "79 N5: D5 High + ATR(20)" => highd5 + atr20*1.0
        "80 N0: D0 High + 0.5*ATR(20)" => highd0 + atr20*0.5
        "80 N1: D1 High + 0.5*ATR(20)" => highd1 + atr20*0.5
        "80 N2: D2 High + 0.5*ATR(20)" => highd2 + atr20*0.5
        "80 N3: D3 High + 0.5*ATR(20)" => highd3 + atr20*0.5
        "80 N4: D4 High + 0.5*ATR(20)" => highd4 + atr20*0.5
        "80 N5: D5 High + 0.5*ATR(20)" => highd5 + atr20*0.5
        "81 N0: D0 High + 0.25*ATR(20)" => highd0 + atr20*0.25
        "81 N1: D1 High + 0.25*ATR(20)" => highd1 + atr20*0.25
        "81 N2: D2 High + 0.25*ATR(20)" => highd2 + atr20*0.25
        "81 N3: D3 High + 0.25*ATR(20)" => highd3 + atr20*0.25
        "81 N4: D4 High + 0.25*ATR(20)" => highd4 + atr20*0.25
        "81 N5: D5 High + 0.25*ATR(20)" => highd5 + atr20*0.25
        "82 N0: D0 High + ATR(30)" => highd0 + atr30*1.0
        "82 N1: D1 High + ATR(30)" => highd1 + atr30*1.0
        "82 N2: D2 High + ATR(30)" => highd2 + atr30*1.0
        "82 N3: D3 High + ATR(30)" => highd3 + atr30*1.0
        "82 N4: D4 High + ATR(30)" => highd4 + atr30*1.0
        "82 N5: D5 High + ATR(30)" => highd5 + atr30*1.0
        "83 N0: D0 High + 0.5*ATR(30)" => highd0 + atr30*0.5
        "83 N1: D1 High + 0.5*ATR(30)" => highd1 + atr30*0.5
        "83 N2: D2 High + 0.5*ATR(30)" => highd2 + atr30*0.5
        "83 N3: D3 High + 0.5*ATR(30)" => highd3 + atr30*0.5
        "83 N4: D4 High + 0.5*ATR(30)" => highd4 + atr30*0.5
        "83 N5: D5 High + 0.5*ATR(30)" => highd5 + atr30*0.5
        "84 N0: D0 High + 0.25*ATR(30)" => highd0 + atr30*0.25
        "84 N1: D1 High + 0.25*ATR(30)" => highd1 + atr30*0.25
        "84 N2: D2 High + 0.25*ATR(30)" => highd2 + atr30*0.25
        "84 N3: D3 High + 0.25*ATR(30)" => highd3 + atr30*0.25
        "84 N4: D4 High + 0.25*ATR(30)" => highd4 + atr30*0.25
        "84 N5: D5 High + 0.25*ATR(30)" => highd5 + atr30*0.25
        "85 N0: D0 High + ATR(50)" => highd0 + atr50*1.0
        "85 N1: D1 High + ATR(50)" => highd1 + atr50*1.0
        "85 N2: D2 High + ATR(50)" => highd2 + atr50*1.0
        "85 N3: D3 High + ATR(50)" => highd3 + atr50*1.0
        "85 N4: D4 High + ATR(50)" => highd4 + atr50*1.0
        "85 N5: D5 High + ATR(50)" => highd5 + atr50*1.0
        "86 N0: D0 High + 0.5*ATR(50)" => highd0 + atr50*0.5
        "86 N1: D1 High + 0.5*ATR(50)" => highd1 + atr50*0.5
        "86 N2: D2 High + 0.5*ATR(50)" => highd2 + atr50*0.5
        "86 N3: D3 High + 0.5*ATR(50)" => highd3 + atr50*0.5
        "86 N4: D4 High + 0.5*ATR(50)" => highd4 + atr50*0.5
        "86 N5: D5 High + 0.5*ATR(50)" => highd5 + atr50*0.5
        "87 N0: D0 High + 0.25*ATR(50)" => highd0 + atr50*0.25
        "87 N1: D1 High + 0.25*ATR(50)" => highd1 + atr50*0.25
        "87 N2: D2 High + 0.25*ATR(50)" => highd2 + atr50*0.25
        "87 N3: D3 High + 0.25*ATR(50)" => highd3 + atr50*0.25
        "87 N4: D4 High + 0.25*ATR(50)" => highd4 + atr50*0.25
        "87 N5: D5 High + 0.25*ATR(50)" => highd5 + atr50*0.25
        "88 N0: D0 High + 1*Range(D0)" => highd0 + (highd0 - lowd0)*1.0
        "88 N1: D1 High + 1*Range(D1)" => highd1 + (highd1 - lowd1)*1.0
        "88 N2: D2 High + 1*Range(D2)" => highd2 + (highd2 - lowd2)*1.0
        "88 N3: D3 High + 1*Range(D3)" => highd3 + (highd3 - lowd3)*1.0
        "88 N4: D4 High + 1*Range(D4)" => highd4 + (highd4 - lowd4)*1.0
        "88 N5: D5 High + 1*Range(D5)" => highd5 + (highd5 - lowd5)*1.0
        "89 N0: D0 High + 0.6667*Range(D0)" => highd0 + (highd0 - lowd0)*0.6666666666666666
        "89 N1: D1 High + 0.6667*Range(D1)" => highd1 + (highd1 - lowd1)*0.6666666666666666
        "89 N2: D2 High + 0.6667*Range(D2)" => highd2 + (highd2 - lowd2)*0.6666666666666666
        "89 N3: D3 High + 0.6667*Range(D3)" => highd3 + (highd3 - lowd3)*0.6666666666666666
        "89 N4: D4 High + 0.6667*Range(D4)" => highd4 + (highd4 - lowd4)*0.6666666666666666
        "89 N5: D5 High + 0.6667*Range(D5)" => highd5 + (highd5 - lowd5)*0.6666666666666666
        "90 N0: D0 High + 0.5*Range(D0)" => highd0 + (highd0 - lowd0)*0.5
        "90 N1: D1 High + 0.5*Range(D1)" => highd1 + (highd1 - lowd1)*0.5
        "90 N2: D2 High + 0.5*Range(D2)" => highd2 + (highd2 - lowd2)*0.5
        "90 N3: D3 High + 0.5*Range(D3)" => highd3 + (highd3 - lowd3)*0.5
        "90 N4: D4 High + 0.5*Range(D4)" => highd4 + (highd4 - lowd4)*0.5
        "90 N5: D5 High + 0.5*Range(D5)" => highd5 + (highd5 - lowd5)*0.5
        "91 N0: D0 High + 0.3333*Range(D0)" => highd0 + (highd0 - lowd0)*0.3333333333333333
        "91 N1: D1 High + 0.3333*Range(D1)" => highd1 + (highd1 - lowd1)*0.3333333333333333
        "91 N2: D2 High + 0.3333*Range(D2)" => highd2 + (highd2 - lowd2)*0.3333333333333333
        "91 N3: D3 High + 0.3333*Range(D3)" => highd3 + (highd3 - lowd3)*0.3333333333333333
        "91 N4: D4 High + 0.3333*Range(D4)" => highd4 + (highd4 - lowd4)*0.3333333333333333
        "91 N5: D5 High + 0.3333*Range(D5)" => highd5 + (highd5 - lowd5)*0.3333333333333333
        "92 N0: D0 High + 0.25*Range(D0)" => highd0 + (highd0 - lowd0)*0.25
        "92 N1: D1 High + 0.25*Range(D1)" => highd1 + (highd1 - lowd1)*0.25
        "92 N2: D2 High + 0.25*Range(D2)" => highd2 + (highd2 - lowd2)*0.25
        "92 N3: D3 High + 0.25*Range(D3)" => highd3 + (highd3 - lowd3)*0.25
        "92 N4: D4 High + 0.25*Range(D4)" => highd4 + (highd4 - lowd4)*0.25
        "92 N5: D5 High + 0.25*Range(D5)" => highd5 + (highd5 - lowd5)*0.25
        "93: Pivot R1 from 5-day extremes" => StartOfSession ? pivotR1_W : na
        "94: Pivot R2 from 5-day extremes" => StartOfSession ? pivotR2_W : na
        "95: None" => na
        => na

    myle





export short_entry_level(string i_entry_myse, array<float> FT_OHLC, array<float> PtnCtx) =>

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

    float pivotP_0 = (highd0 + lowd0 + closed0) / 3.0
    float pivotR1_0 = 2.0*pivotP_0 - lowd0
    float pivotS1_0 = 2.0*pivotP_0 - highd0
    float pivotR2_0 = pivotP_0 + highd0 - lowd0
    float pivotS2_0 = pivotP_0 - highd0 + lowd0

    float pivotP_1 = (highd1 + lowd1 + closed1) / 3.0
    float pivotR1_1 = 2.0*pivotP_1 - lowd1
    float pivotS1_1 = 2.0*pivotP_1 - highd1
    float pivotR2_1 = pivotP_1 + highd1 - lowd1
    float pivotS2_1 = pivotP_1 - highd1 + lowd1

    float pivotP_2 = (highd2 + lowd2 + closed2) / 3.0
    float pivotR1_2 = 2.0*pivotP_2 - lowd2
    float pivotS1_2 = 2.0*pivotP_2 - highd2
    float pivotR2_2 = pivotP_2 + highd2 - lowd2
    float pivotS2_2 = pivotP_2 - highd2 + lowd2

    float pivotP_3 = (highd3 + lowd3 + closed3) / 3.0
    float pivotR1_3 = 2.0*pivotP_3 - lowd3
    float pivotS1_3 = 2.0*pivotP_3 - highd3
    float pivotR2_3 = pivotP_3 + highd3 - lowd3
    float pivotS2_3 = pivotP_3 - highd3 + lowd3

    float pivotP_4 = (highd4 + lowd4 + closed4) / 3.0
    float pivotR1_4 = 2.0*pivotP_4 - lowd4
    float pivotS1_4 = 2.0*pivotP_4 - highd4
    float pivotR2_4 = pivotP_4 + highd4 - lowd4
    float pivotS2_4 = pivotP_4 - highd4 + lowd4

    float pivotP_5 = (highd5 + lowd5 + closed5) / 3.0
    float pivotR1_5 = 2.0*pivotP_5 - lowd5
    float pivotS1_5 = 2.0*pivotP_5 - highd5
    float pivotR2_5 = pivotP_5 + highd5 - lowd5
    float pivotS2_5 = pivotP_5 - highd5 + lowd5

    float pivotP_W  = (HighestH + LowestL + closed1) / 3.0
    float pivotR1_W = 2.0*pivotP_W - LowestL
    float pivotS1_W = 2.0*pivotP_W - HighestH
    float pivotR2_W = pivotP_W + HighestH - LowestL
    float pivotS2_W = pivotP_W - HighestH + LowestL

    float weekHigh = request.security(syminfo.tickerid, "W", high, barmerge.gaps_off, barmerge.lookahead_on)
    float weekLow  = request.security(syminfo.tickerid, "W", low,  barmerge.gaps_off, barmerge.lookahead_on)

    float atr5 = AvgTrueRange(5)
    float atr10 = AvgTrueRange(10)
    float atr20 = AvgTrueRange(20)
    float atr30 = AvgTrueRange(30)
    float atr50 = AvgTrueRange(50)

    float myse = switch i_entry_myse
        "00 N0: D0 High if close<High" => close < highd0[1] ? highd0[1] : na
        "00 N1: D1 High if close<High" => close < highd1 ? highd1 : na
        "00 N2: D2 High if close<High" => close < highd2 ? highd2 : na
        "00 N3: D3 High if close<High" => close < highd3 ? highd3 : na
        "00 N4: D4 High if close<High" => close < highd4 ? highd4 : na
        "00 N5: D5 High if close<High" => close < highd5 ? highd5 : na
        "01 N0: 1% above D0 High if close<High" => close < highd0[1] ? highd0[1] * (1 + 0.01) : na
        "01 N1: 1% above D1 High if close<High" => close < highd1 ? highd1 * (1 + 0.01) : na
        "01 N2: 1% above D2 High if close<High" => close < highd2 ? highd2 * (1 + 0.01) : na
        "01 N3: 1% above D3 High if close<High" => close < highd3 ? highd3 * (1 + 0.01) : na
        "01 N4: 1% above D4 High if close<High" => close < highd4 ? highd4 * (1 + 0.01) : na
        "01 N5: 1% above D5 High if close<High" => close < highd5 ? highd5 * (1 + 0.01) : na
        "02 N0: 1% below D0 High if close<High" => close < highd0[1] ? highd0[1] * (1 - 0.01) : na
        "02 N1: 1% below D1 High if close<High" => close < highd1 ? highd1 * (1 - 0.01) : na
        "02 N2: 1% below D2 High if close<High" => close < highd2 ? highd2 * (1 - 0.01) : na
        "02 N3: 1% below D3 High if close<High" => close < highd3 ? highd3 * (1 - 0.01) : na
        "02 N4: 1% below D4 High if close<High" => close < highd4 ? highd4 * (1 - 0.01) : na
        "02 N5: 1% below D5 High if close<High" => close < highd5 ? highd5 * (1 - 0.01) : na
        "03: highest high (5 bars)" => ta.highest(high, 5)
        "04: highest high (10 bars)" => ta.highest(high, 10)
        "05: highest high (30 bars)" => ta.highest(high, 30)
        "06: highest high (50 bars)" => ta.highest(high, 50)
        "07: SMA(high,5) + SMA(range,5)" => ta.sma(high, 5) + ta.sma(high - low, 5)
        "08: SMA(high,10) + SMA(range,10)" => ta.sma(high, 10) + ta.sma(high - low, 10)
        "09: SMA(high,30) + SMA(range,30)" => ta.sma(high, 30) + ta.sma(high - low, 30)
        "10: SMA(high,50) + SMA(range,50)" => ta.sma(high, 50) + ta.sma(high - low, 50)
        "11: SMA(high,5)" => ta.sma(high, 5)
        "12: SMA(high,10)" => ta.sma(high, 10)
        "13: SMA(high,30)" => ta.sma(high, 30)
        "14: SMA(high,50)" => ta.sma(high, 50)
        "15: SMA(close,5) + SMA(range,5)" => ta.sma(close, 5) + ta.sma(high - low, 5)
        "16: SMA(close,10) + SMA(range,10)" => ta.sma(close, 10) + ta.sma(high - low, 10)
        "17: SMA(close,30) + SMA(range,30)" => ta.sma(close, 30) + ta.sma(high - low, 30)
        "18: SMA(close,50) + SMA(range,50)" => ta.sma(close, 50) + ta.sma(high - low, 50)
        "19 N0: extension of D0 High - Close" => 2*highd0 - closed0
        "19 N1: extension of D1 High - Close" => 2*highd1 - closed1
        "19 N2: extension of D2 High - Close" => 2*highd2 - closed2
        "19 N3: extension of D3 High - Close" => 2*highd3 - closed3
        "19 N4: extension of D4 High - Close" => 2*highd4 - closed4
        "19 N5: extension of D5 High - Close" => 2*highd5 - closed5
        "20 N0: Short extend D0 High toward D1 Close" => closed1 > highd0 ? (highd0 + (closed1 - highd0)) : na
        "20 N1: Short extend D1 High toward D2 Close" => closed2 > highd1 ? (highd1 + (closed2 - highd1)) : na
        "20 N2: Short extend D2 High toward D3 Close" => closed3 > highd2 ? (highd2 + (closed3 - highd2)) : na
        "20 N3: Short extend D3 High toward D4 Close" => closed4 > highd3 ? (highd3 + (closed4 - highd3)) : na
        "20 N4: Short extend D4 High toward D5 Close" => closed5 > highd4 ? (highd4 + (closed5 - highd4)) : na
        "21: current bar high" => high
        "22: high[1]" => high[1]
        "23: high[2]" => high[2]
        "24: high[3]" => high[3]
        "25: high[4]" => high[4]
        "26: high[5]" => high[5]
        "27: session-start bar high" => sessStartHigh
        "28: sessStartHigh + sessStartRange" => sessStartHigh + sessStartRange
        "29: HighestH (D1..D5)" => HighestH
        "30: HighestC (D1..D5)" => HighestC
        "31: HighestO (D1..D5)" => HighestO
        "32: highest high (relative 5)" => ta.highest(high, 5)
        "33: highest high (relative 10)" => ta.highest(high, 10)
        "34: highest high (relative 20)" => ta.highest(high, 20)
        "35: highest high (relative 30)" => ta.highest(high, 30)
        "36: highest high (relative 40)" => ta.highest(high, 40)
        "37: highest high (relative 50)" => ta.highest(high, 50)
        "38: high + range" => high + (high - low)
        "39: close + range" => close + (high - low)
        "40: high + 0.5*range" => high + (high - low)*0.5
        "41: close + 0.5*range" => close + (high - low)*0.5
        "42: high + 0.25*range" => high + (high - low)*0.25
        "43: close + 0.25*range" => close + (high - low)*0.25
        "44: high + 0.5% of high" => high * (1 + 0.01*0.5)
        "45: high + 1.0% of high" => high * (1 + 0.01*1.0)
        "46: high + 1.5% of high" => high * (1 + 0.01*1.5)
        "47: high + 2.0% of high" => high * (1 + 0.01*2.0)
        "48: high + 2.5% of high" => high * (1 + 0.01*2.5)
        "49: close + 0.5% of close" => close * (1 + 0.01*0.5)
        "50: close + 1.0% of close" => close * (1 + 0.01*1.0)
        "51: close + 1.5% of close" => close * (1 + 0.01*1.5)
        "52: close + 2.0% of close" => close * (1 + 0.01*2.0)
        "53: close + 2.5% of close" => close * (1 + 0.01*2.5)
        "54 N0: Pivot R1 from D0" => StartOfSession ? pivotR1_0 : na
        "55 N0: Pivot R2 from D0" => StartOfSession ? pivotR2_0 : na
        "54 N1: Pivot R1 from D1" => StartOfSession ? pivotR1_1 : na
        "55 N1: Pivot R2 from D1" => StartOfSession ? pivotR2_1 : na
        "54 N2: Pivot R1 from D2" => StartOfSession ? pivotR1_2 : na
        "55 N2: Pivot R2 from D2" => StartOfSession ? pivotR2_2 : na
        "54 N3: Pivot R1 from D3" => StartOfSession ? pivotR1_3 : na
        "55 N3: Pivot R2 from D3" => StartOfSession ? pivotR2_3 : na
        "54 N4: Pivot R1 from D4" => StartOfSession ? pivotR1_4 : na
        "55 N4: Pivot R2 from D4" => StartOfSession ? pivotR2_4 : na
        "54 N5: Pivot R1 from D5" => StartOfSession ? pivotR1_5 : na
        "55 N5: Pivot R2 from D5" => StartOfSession ? pivotR2_5 : na
        "56: current open" => open
        "57: current week high" => weekHigh
        "58: high + ATR(5)" => high + atr5
        "59: high + 0.5*ATR(5)" => high + atr5*0.5
        "60: high + 0.25*ATR(5)" => high + atr5*0.25
        "61: high + ATR(10)" => high + atr10
        "62: high + 0.5*ATR(10)" => high + atr10*0.5
        "63: high + 0.25*ATR(10)" => high + atr10*0.25
        "64: high + ATR(20)" => high + atr20
        "65: high + 0.5*ATR(20)" => high + atr20*0.5
        "66: high + 0.25*ATR(20)" => high + atr20*0.25
        "67: high + ATR(30)" => high + atr30
        "68: high + 0.5*ATR(30)" => high + atr30*0.5
        "69: high + 0.25*ATR(30)" => high + atr30*0.25
        "70: high + ATR(50)" => high + atr50
        "71: high + 0.5*ATR(50)" => high + atr50*0.5
        "72: high + 0.25*ATR(50)" => high + atr50*0.25
        "73 N0: D0 High + ATR(5)" => highd0 + atr5*1.0
        "73 N1: D1 High + ATR(5)" => highd1 + atr5*1.0
        "73 N2: D2 High + ATR(5)" => highd2 + atr5*1.0
        "73 N3: D3 High + ATR(5)" => highd3 + atr5*1.0
        "73 N4: D4 High + ATR(5)" => highd4 + atr5*1.0
        "73 N5: D5 High + ATR(5)" => highd5 + atr5*1.0
        "74 N0: D0 High + 0.5*ATR(5)" => highd0 + atr5*0.5
        "74 N1: D1 High + 0.5*ATR(5)" => highd1 + atr5*0.5
        "74 N2: D2 High + 0.5*ATR(5)" => highd2 + atr5*0.5
        "74 N3: D3 High + 0.5*ATR(5)" => highd3 + atr5*0.5
        "74 N4: D4 High + 0.5*ATR(5)" => highd4 + atr5*0.5
        "74 N5: D5 High + 0.5*ATR(5)" => highd5 + atr5*0.5
        "75 N0: D0 High + 0.25*ATR(5)" => highd0 + atr5*0.25
        "75 N1: D1 High + 0.25*ATR(5)" => highd1 + atr5*0.25
        "75 N2: D2 High + 0.25*ATR(5)" => highd2 + atr5*0.25
        "75 N3: D3 High + 0.25*ATR(5)" => highd3 + atr5*0.25
        "75 N4: D4 High + 0.25*ATR(5)" => highd4 + atr5*0.25
        "75 N5: D5 High + 0.25*ATR(5)" => highd5 + atr5*0.25
        "76 N0: D0 High + ATR(10)" => highd0 + atr10*1.0
        "76 N1: D1 High + ATR(10)" => highd1 + atr10*1.0
        "76 N2: D2 High + ATR(10)" => highd2 + atr10*1.0
        "76 N3: D3 High + ATR(10)" => highd3 + atr10*1.0
        "76 N4: D4 High + ATR(10)" => highd4 + atr10*1.0
        "76 N5: D5 High + ATR(10)" => highd5 + atr10*1.0
        "77 N0: D0 High + 0.5*ATR(10)" => highd0 + atr10*0.5
        "77 N1: D1 High + 0.5*ATR(10)" => highd1 + atr10*0.5
        "77 N2: D2 High + 0.5*ATR(10)" => highd2 + atr10*0.5
        "77 N3: D3 High + 0.5*ATR(10)" => highd3 + atr10*0.5
        "77 N4: D4 High + 0.5*ATR(10)" => highd4 + atr10*0.5
        "77 N5: D5 High + 0.5*ATR(10)" => highd5 + atr10*0.5
        "78 N0: D0 High + 0.25*ATR(10)" => highd0 + atr10*0.25
        "78 N1: D1 High + 0.25*ATR(10)" => highd1 + atr10*0.25
        "78 N2: D2 High + 0.25*ATR(10)" => highd2 + atr10*0.25
        "78 N3: D3 High + 0.25*ATR(10)" => highd3 + atr10*0.25
        "78 N4: D4 High + 0.25*ATR(10)" => highd4 + atr10*0.25
        "78 N5: D5 High + 0.25*ATR(10)" => highd5 + atr10*0.25
        "79 N0: D0 High + ATR(20)" => highd0 + atr20*1.0
        "79 N1: D1 High + ATR(20)" => highd1 + atr20*1.0
        "79 N2: D2 High + ATR(20)" => highd2 + atr20*1.0
        "79 N3: D3 High + ATR(20)" => highd3 + atr20*1.0
        "79 N4: D4 High + ATR(20)" => highd4 + atr20*1.0
        "79 N5: D5 High + ATR(20)" => highd5 + atr20*1.0
        "80 N0: D0 High + 0.5*ATR(20)" => highd0 + atr20*0.5
        "80 N1: D1 High + 0.5*ATR(20)" => highd1 + atr20*0.5
        "80 N2: D2 High + 0.5*ATR(20)" => highd2 + atr20*0.5
        "80 N3: D3 High + 0.5*ATR(20)" => highd3 + atr20*0.5
        "80 N4: D4 High + 0.5*ATR(20)" => highd4 + atr20*0.5
        "80 N5: D5 High + 0.5*ATR(20)" => highd5 + atr20*0.5
        "81 N0: D0 High + 0.25*ATR(20)" => highd0 + atr20*0.25
        "81 N1: D1 High + 0.25*ATR(20)" => highd1 + atr20*0.25
        "81 N2: D2 High + 0.25*ATR(20)" => highd2 + atr20*0.25
        "81 N3: D3 High + 0.25*ATR(20)" => highd3 + atr20*0.25
        "81 N4: D4 High + 0.25*ATR(20)" => highd4 + atr20*0.25
        "81 N5: D5 High + 0.25*ATR(20)" => highd5 + atr20*0.25
        "82 N0: D0 High + ATR(30)" => highd0 + atr30*1.0
        "82 N1: D1 High + ATR(30)" => highd1 + atr30*1.0
        "82 N2: D2 High + ATR(30)" => highd2 + atr30*1.0
        "82 N3: D3 High + ATR(30)" => highd3 + atr30*1.0
        "82 N4: D4 High + ATR(30)" => highd4 + atr30*1.0
        "82 N5: D5 High + ATR(30)" => highd5 + atr30*1.0
        "83 N0: D0 High + 0.5*ATR(30)" => highd0 + atr30*0.5
        "83 N1: D1 High + 0.5*ATR(30)" => highd1 + atr30*0.5
        "83 N2: D2 High + 0.5*ATR(30)" => highd2 + atr30*0.5
        "83 N3: D3 High + 0.5*ATR(30)" => highd3 + atr30*0.5
        "83 N4: D4 High + 0.5*ATR(30)" => highd4 + atr30*0.5
        "83 N5: D5 High + 0.5*ATR(30)" => highd5 + atr30*0.5
        "84 N0: D0 High + 0.25*ATR(30)" => highd0 + atr30*0.25
        "84 N1: D1 High + 0.25*ATR(30)" => highd1 + atr30*0.25
        "84 N2: D2 High + 0.25*ATR(30)" => highd2 + atr30*0.25
        "84 N3: D3 High + 0.25*ATR(30)" => highd3 + atr30*0.25
        "84 N4: D4 High + 0.25*ATR(30)" => highd4 + atr30*0.25
        "84 N5: D5 High + 0.25*ATR(30)" => highd5 + atr30*0.25
        "85 N0: D0 High + ATR(50)" => highd0 + atr50*1.0
        "85 N1: D1 High + ATR(50)" => highd1 + atr50*1.0
        "85 N2: D2 High + ATR(50)" => highd2 + atr50*1.0
        "85 N3: D3 High + ATR(50)" => highd3 + atr50*1.0
        "85 N4: D4 High + ATR(50)" => highd4 + atr50*1.0
        "85 N5: D5 High + ATR(50)" => highd5 + atr50*1.0
        "86 N0: D0 High + 0.5*ATR(50)" => highd0 + atr50*0.5
        "86 N1: D1 High + 0.5*ATR(50)" => highd1 + atr50*0.5
        "86 N2: D2 High + 0.5*ATR(50)" => highd2 + atr50*0.5
        "86 N3: D3 High + 0.5*ATR(50)" => highd3 + atr50*0.5
        "86 N4: D4 High + 0.5*ATR(50)" => highd4 + atr50*0.5
        "86 N5: D5 High + 0.5*ATR(50)" => highd5 + atr50*0.5
        "87 N0: D0 High + 0.25*ATR(50)" => highd0 + atr50*0.25
        "87 N1: D1 High + 0.25*ATR(50)" => highd1 + atr50*0.25
        "87 N2: D2 High + 0.25*ATR(50)" => highd2 + atr50*0.25
        "87 N3: D3 High + 0.25*ATR(50)" => highd3 + atr50*0.25
        "87 N4: D4 High + 0.25*ATR(50)" => highd4 + atr50*0.25
        "87 N5: D5 High + 0.25*ATR(50)" => highd5 + atr50*0.25
        "88 N0: D0 High + 1*Range(D0)" => highd0 + (highd0 - lowd0)*1.0
        "88 N1: D1 High + 1*Range(D1)" => highd1 + (highd1 - lowd1)*1.0
        "88 N2: D2 High + 1*Range(D2)" => highd2 + (highd2 - lowd2)*1.0
        "88 N3: D3 High + 1*Range(D3)" => highd3 + (highd3 - lowd3)*1.0
        "88 N4: D4 High + 1*Range(D4)" => highd4 + (highd4 - lowd4)*1.0
        "88 N5: D5 High + 1*Range(D5)" => highd5 + (highd5 - lowd5)*1.0
        "89 N0: D0 High + 0.6667*Range(D0)" => highd0 + (highd0 - lowd0)*0.6666666666666666
        "89 N1: D1 High + 0.6667*Range(D1)" => highd1 + (highd1 - lowd1)*0.6666666666666666
        "89 N2: D2 High + 0.6667*Range(D2)" => highd2 + (highd2 - lowd2)*0.6666666666666666
        "89 N3: D3 High + 0.6667*Range(D3)" => highd3 + (highd3 - lowd3)*0.6666666666666666
        "89 N4: D4 High + 0.6667*Range(D4)" => highd4 + (highd4 - lowd4)*0.6666666666666666
        "89 N5: D5 High + 0.6667*Range(D5)" => highd5 + (highd5 - lowd5)*0.6666666666666666
        "90 N0: D0 High + 0.5*Range(D0)" => highd0 + (highd0 - lowd0)*0.5
        "90 N1: D1 High + 0.5*Range(D1)" => highd1 + (highd1 - lowd1)*0.5
        "90 N2: D2 High + 0.5*Range(D2)" => highd2 + (highd2 - lowd2)*0.5
        "90 N3: D3 High + 0.5*Range(D3)" => highd3 + (highd3 - lowd3)*0.5
        "90 N4: D4 High + 0.5*Range(D4)" => highd4 + (highd4 - lowd4)*0.5
        "90 N5: D5 High + 0.5*Range(D5)" => highd5 + (highd5 - lowd5)*0.5
        "91 N0: D0 High + 0.3333*Range(D0)" => highd0 + (highd0 - lowd0)*0.3333333333333333
        "91 N1: D1 High + 0.3333*Range(D1)" => highd1 + (highd1 - lowd1)*0.3333333333333333
        "91 N2: D2 High + 0.3333*Range(D2)" => highd2 + (highd2 - lowd2)*0.3333333333333333
        "91 N3: D3 High + 0.3333*Range(D3)" => highd3 + (highd3 - lowd3)*0.3333333333333333
        "91 N4: D4 High + 0.3333*Range(D4)" => highd4 + (highd4 - lowd4)*0.3333333333333333
        "91 N5: D5 High + 0.3333*Range(D5)" => highd5 + (highd5 - lowd5)*0.3333333333333333
        "92 N0: D0 High + 0.25*Range(D0)" => highd0 + (highd0 - lowd0)*0.25
        "92 N1: D1 High + 0.25*Range(D1)" => highd1 + (highd1 - lowd1)*0.25
        "92 N2: D2 High + 0.25*Range(D2)" => highd2 + (highd2 - lowd2)*0.25
        "92 N3: D3 High + 0.25*Range(D3)" => highd3 + (highd3 - lowd3)*0.25
        "92 N4: D4 High + 0.25*Range(D4)" => highd4 + (highd4 - lowd4)*0.25
        "92 N5: D5 High + 0.25*Range(D5)" => highd5 + (highd5 - lowd5)*0.25
        "93: Pivot R1 from 5-day extremes" => StartOfSession ? pivotR1_W : na
        "94: Pivot R2 from 5-day extremes" => StartOfSession ? pivotR2_W : na
        "95: None" => 0.0
        "00 N0: D0 Low if close>Low" => close > lowd0[1] ? lowd0[1] : na
        "00 N1: D1 Low if close>Low" => close > lowd1 ? lowd1 : na
        "00 N2: D2 Low if close>Low" => close > lowd2 ? lowd2 : na
        "00 N3: D3 Low if close>Low" => close > lowd3 ? lowd3 : na
        "00 N4: D4 Low if close>Low" => close > lowd4 ? lowd4 : na
        "00 N5: D5 Low if close>Low" => close > lowd5 ? lowd5 : na
        "01 N0: 1% below D0 Low if close>Low" => close > lowd0[1] ? lowd0[1] * (1 - 0.01) : na
        "01 N1: 1% below D1 Low if close>Low" => close > lowd1 ? lowd1 * (1 - 0.01) : na
        "01 N2: 1% below D2 Low if close>Low" => close > lowd2 ? lowd2 * (1 - 0.01) : na
        "01 N3: 1% below D3 Low if close>Low" => close > lowd3 ? lowd3 * (1 - 0.01) : na
        "01 N4: 1% below D4 Low if close>Low" => close > lowd4 ? lowd4 * (1 - 0.01) : na
        "01 N5: 1% below D5 Low if close>Low" => close > lowd5 ? lowd5 * (1 - 0.01) : na
        "02 N0: 1% above D0 Low if close>Low" => close > lowd0[1] ? lowd0[1] * (1 + 0.01) : na
        "02 N1: 1% above D1 Low if close>Low" => close > lowd1 ? lowd1 * (1 + 0.01) : na
        "02 N2: 1% above D2 Low if close>Low" => close > lowd2 ? lowd2 * (1 + 0.01) : na
        "02 N3: 1% above D3 Low if close>Low" => close > lowd3 ? lowd3 * (1 + 0.01) : na
        "02 N4: 1% above D4 Low if close>Low" => close > lowd4 ? lowd4 * (1 + 0.01) : na
        "02 N5: 1% above D5 Low if close>Low" => close > lowd5 ? lowd5 * (1 + 0.01) : na
        "03: lowest low (5 bars)" => ta.lowest(low, 5)
        "04: lowest low (10 bars)" => ta.lowest(low, 10)
        "05: lowest low (30 bars)" => ta.lowest(low, 30)
        "06: lowest low (50 bars)" => ta.lowest(low, 50)
        "07: SMA(low,5) - SMA(range,5)" => ta.sma(low, 5) - ta.sma(high - low, 5)
        "08: SMA(low,10) - SMA(range,10)" => ta.sma(low, 10) - ta.sma(high - low, 10)
        "09: SMA(low,30) - SMA(range,30)" => ta.sma(low, 30) - ta.sma(high - low, 30)
        "10: SMA(low,50) - SMA(range,50)" => ta.sma(low, 50) - ta.sma(high - low, 50)
        "11: SMA(low,5)" => ta.sma(low, 5)
        "12: SMA(low,10)" => ta.sma(low, 10)
        "13: SMA(low,30)" => ta.sma(low, 30)
        "14: SMA(low,50)" => ta.sma(low, 50)
        "15: SMA(close,5) - SMA(range,5)" => ta.sma(close, 5) - ta.sma(high - low, 5)
        "16: SMA(close,10) - SMA(range,10)" => ta.sma(close, 10) - ta.sma(high - low, 10)
        "17: SMA(close,30) - SMA(range,30)" => ta.sma(close, 30) - ta.sma(high - low, 30)
        "18: SMA(close,50) - SMA(range,50)" => ta.sma(close, 50) - ta.sma(high - low, 50)
        "19 N0: 2 * D0 Low - Close" => 2*lowd0 - closed0
        "19 N1: 2 * D1 Low - Close" => 2*lowd1 - closed1
        "19 N2: 2 * D2 Low - Close" => 2*lowd2 - closed2
        "19 N3: 2 * D3 Low - Close" => 2*lowd3 - closed3
        "19 N4: 2 * D4 Low - Close" => 2*lowd4 - closed4
        "19 N5: 2 * D5 Low - Close" => 2*lowd5 - closed5
        "20 N0: extension of D0 Low toward D1 Close" => closed1 < lowd0 ? (lowd0 - (lowd0 - closed1)) : na
        "20 N1: extension of D1 Low toward D2 Close" => closed2 < lowd1 ? (lowd1 - (lowd1 - closed2)) : na
        "20 N2: extension of D2 Low toward D3 Close" => closed3 < lowd2 ? (lowd2 - (lowd2 - closed3)) : na
        "20 N3: extension of D3 Low toward D4 Close" => closed4 < lowd3 ? (lowd3 - (lowd3 - closed4)) : na
        "20 N4: extension of D4 Low toward D5 Close" => closed5 < lowd4 ? (lowd4 - (lowd4 - closed5)) : na
        "21: current bar low" => low
        "22: low[1]" => low[1]
        "23: low[2]" => low[2]
        "24: low[3]" => low[3]
        "25: low[4]" => low[4]
        "26: low[5]" => low[5]
        "27: session-start bar low" => sessStartLow
        "28: sessStartLow - sessStartRange" => sessStartLow - sessStartRange
        "29: LowestL (D1..D5)" => LowestL
        "30: LowestC (D1..D5)" => LowestC
        "31: LowestO (D1..D5)" => LowestO
        "32: lowest low (relative 5)" => ta.lowest(low, 5)
        "33: lowest low (relative 10)" => ta.lowest(low, 10)
        "34: lowest low (relative 20)" => ta.lowest(low, 20)
        "35: lowest low (relative 30)" => ta.lowest(low, 30)
        "36: lowest low (relative 40)" => ta.lowest(low, 40)
        "37: lowest low (relative 50)" => ta.lowest(low, 50)
        "38: low - range" => low - (high - low)
        "39: close - range" => close - (high - low)
        "40: low - 0.5*range" => low - (high - low)*0.5
        "41: close - 0.5*range" => close - (high - low)*0.5
        "42: low - 0.25*range" => low - (high - low)*0.25
        "43: close - 0.25*range" => close - (high - low)*0.25
        "44: low - 0.5% of low" => low * (1 - 0.01*0.5)
        "45: low - 1.0% of low" => low * (1 - 0.01*1.0)
        "46: low - 1.5% of low" => low * (1 - 0.01*1.5)
        "47: low - 2.0% of low" => low * (1 - 0.01*2.0)
        "48: low - 2.5% of low" => low * (1 - 0.01*2.5)
        "49: close - 0.5% of close" => close * (1 - 0.01*0.5)
        "50: close - 1.0% of close" => close * (1 - 0.01*1.0)
        "51: close - 1.5% of close" => close * (1 - 0.01*1.5)
        "52: close - 2.0% of close" => close * (1 - 0.01*2.0)
        "53: close - 2.5% of close" => close * (1 - 0.01*2.5)
        "54 N0: Pivot S1 from D0" => StartOfSession ? pivotS1_0 : na
        "55 N0: Pivot S2 from D0" => StartOfSession ? pivotS2_0 : na
        "54 N1: Pivot S1 from D1" => StartOfSession ? pivotS1_1 : na
        "55 N1: Pivot S2 from D1" => StartOfSession ? pivotS2_1 : na
        "54 N2: Pivot S1 from D2" => StartOfSession ? pivotS1_2 : na
        "55 N2: Pivot S2 from D2" => StartOfSession ? pivotS2_2 : na
        "54 N3: Pivot S1 from D3" => StartOfSession ? pivotS1_3 : na
        "55 N3: Pivot S2 from D3" => StartOfSession ? pivotS2_3 : na
        "54 N4: Pivot S1 from D4" => StartOfSession ? pivotS1_4 : na
        "55 N4: Pivot S2 from D4" => StartOfSession ? pivotS2_4 : na
        "54 N5: Pivot S1 from D5" => StartOfSession ? pivotS1_5 : na
        "55 N5: Pivot S2 from D5" => StartOfSession ? pivotS2_5 : na
        "56: current open" => open
        "57: current week low" => weekLow
        "58: low - ATR(5)" => low - atr5
        "59: low - 0.5*ATR(5)" => low - atr5*0.5
        "60: low - 0.25*ATR(5)" => low - atr5*0.25
        "61: low - ATR(10)" => low - atr10
        "62: low - 0.5*ATR(10)" => low - atr10*0.5
        "63: low - 0.25*ATR(10)" => low - atr10*0.25
        "64: low - ATR(20)" => low - atr20
        "65: low - 0.5*ATR(20)" => low - atr20*0.5
        "66: low - 0.25*ATR(20)" => low - atr20*0.25
        "67: low - ATR(30)" => low - atr30
        "68: low - 0.5*ATR(30)" => low - atr30*0.5
        "69: low - 0.25*ATR(30)" => low - atr30*0.25
        "70: low - ATR(50)" => low - atr50
        "71: low - 0.5*ATR(50)" => low - atr50*0.5
        "72: low - 0.25*ATR(50)" => low - atr50*0.25
        "73 N0: D0 Low - ATR(5)" => lowd0 - atr5*1.0
        "73 N1: D1 Low - ATR(5)" => lowd1 - atr5*1.0
        "73 N2: D2 Low - ATR(5)" => lowd2 - atr5*1.0
        "73 N3: D3 Low - ATR(5)" => lowd3 - atr5*1.0
        "73 N4: D4 Low - ATR(5)" => lowd4 - atr5*1.0
        "73 N5: D5 Low - ATR(5)" => lowd5 - atr5*1.0
        "74 N0: D0 Low - 0.5*ATR(5)" => lowd0 - atr5*0.5
        "74 N1: D1 Low - 0.5*ATR(5)" => lowd1 - atr5*0.5
        "74 N2: D2 Low - 0.5*ATR(5)" => lowd2 - atr5*0.5
        "74 N3: D3 Low - 0.5*ATR(5)" => lowd3 - atr5*0.5
        "74 N4: D4 Low - 0.5*ATR(5)" => lowd4 - atr5*0.5
        "74 N5: D5 Low - 0.5*ATR(5)" => lowd5 - atr5*0.5
        "75 N0: D0 Low - 0.25*ATR(5)" => lowd0 - atr5*0.25
        "75 N1: D1 Low - 0.25*ATR(5)" => lowd1 - atr5*0.25
        "75 N2: D2 Low - 0.25*ATR(5)" => lowd2 - atr5*0.25
        "75 N3: D3 Low - 0.25*ATR(5)" => lowd3 - atr5*0.25
        "75 N4: D4 Low - 0.25*ATR(5)" => lowd4 - atr5*0.25
        "75 N5: D5 Low - 0.25*ATR(5)" => lowd5 - atr5*0.25
        "76 N0: D0 Low - ATR(10)" => lowd0 - atr10*1.0
        "76 N1: D1 Low - ATR(10)" => lowd1 - atr10*1.0
        "76 N2: D2 Low - ATR(10)" => lowd2 - atr10*1.0
        "76 N3: D3 Low - ATR(10)" => lowd3 - atr10*1.0
        "76 N4: D4 Low - ATR(10)" => lowd4 - atr10*1.0
        "76 N5: D5 Low - ATR(10)" => lowd5 - atr10*1.0
        "77 N0: D0 Low - 0.5*ATR(10)" => lowd0 - atr10*0.5
        "77 N1: D1 Low - 0.5*ATR(10)" => lowd1 - atr10*0.5
        "77 N2: D2 Low - 0.5*ATR(10)" => lowd2 - atr10*0.5
        "77 N3: D3 Low - 0.5*ATR(10)" => lowd3 - atr10*0.5
        "77 N4: D4 Low - 0.5*ATR(10)" => lowd4 - atr10*0.5
        "77 N5: D5 Low - 0.5*ATR(10)" => lowd5 - atr10*0.5
        "78 N0: D0 Low - 0.25*ATR(10)" => lowd0 - atr10*0.25
        "78 N1: D1 Low - 0.25*ATR(10)" => lowd1 - atr10*0.25
        "78 N2: D2 Low - 0.25*ATR(10)" => lowd2 - atr10*0.25
        "78 N3: D3 Low - 0.25*ATR(10)" => lowd3 - atr10*0.25
        "78 N4: D4 Low - 0.25*ATR(10)" => lowd4 - atr10*0.25
        "78 N5: D5 Low - 0.25*ATR(10)" => lowd5 - atr10*0.25
        "79 N0: D0 Low - ATR(20)" => lowd0 - atr20*1.0
        "79 N1: D1 Low - ATR(20)" => lowd1 - atr20*1.0
        "79 N2: D2 Low - ATR(20)" => lowd2 - atr20*1.0
        "79 N3: D3 Low - ATR(20)" => lowd3 - atr20*1.0
        "79 N4: D4 Low - ATR(20)" => lowd4 - atr20*1.0
        "79 N5: D5 Low - ATR(20)" => lowd5 - atr20*1.0
        "80 N0: D0 Low - 0.5*ATR(20)" => lowd0 - atr20*0.5
        "80 N1: D1 Low - 0.5*ATR(20)" => lowd1 - atr20*0.5
        "80 N2: D2 Low - 0.5*ATR(20)" => lowd2 - atr20*0.5
        "80 N3: D3 Low - 0.5*ATR(20)" => lowd3 - atr20*0.5
        "80 N4: D4 Low - 0.5*ATR(20)" => lowd4 - atr20*0.5
        "80 N5: D5 Low - 0.5*ATR(20)" => lowd5 - atr20*0.5
        "81 N0: D0 Low - 0.25*ATR(20)" => lowd0 - atr20*0.25
        "81 N1: D1 Low - 0.25*ATR(20)" => lowd1 - atr20*0.25
        "81 N2: D2 Low - 0.25*ATR(20)" => lowd2 - atr20*0.25
        "81 N3: D3 Low - 0.25*ATR(20)" => lowd3 - atr20*0.25
        "81 N4: D4 Low - 0.25*ATR(20)" => lowd4 - atr20*0.25
        "81 N5: D5 Low - 0.25*ATR(20)" => lowd5 - atr20*0.25
        "82 N0: D0 Low - ATR(30)" => lowd0 - atr30*1.0
        "82 N1: D1 Low - ATR(30)" => lowd1 - atr30*1.0
        "82 N2: D2 Low - ATR(30)" => lowd2 - atr30*1.0
        "82 N3: D3 Low - ATR(30)" => lowd3 - atr30*1.0
        "82 N4: D4 Low - ATR(30)" => lowd4 - atr30*1.0
        "82 N5: D5 Low - ATR(30)" => lowd5 - atr30*1.0
        "83 N0: D0 Low - 0.5*ATR(30)" => lowd0 - atr30*0.5
        "83 N1: D1 Low - 0.5*ATR(30)" => lowd1 - atr30*0.5
        "83 N2: D2 Low - 0.5*ATR(30)" => lowd2 - atr30*0.5
        "83 N3: D3 Low - 0.5*ATR(30)" => lowd3 - atr30*0.5
        "83 N4: D4 Low - 0.5*ATR(30)" => lowd4 - atr30*0.5
        "83 N5: D5 Low - 0.5*ATR(30)" => lowd5 - atr30*0.5
        "84 N0: D0 Low - 0.25*ATR(30)" => lowd0 - atr30*0.25
        "84 N1: D1 Low - 0.25*ATR(30)" => lowd1 - atr30*0.25
        "84 N2: D2 Low - 0.25*ATR(30)" => lowd2 - atr30*0.25
        "84 N3: D3 Low - 0.25*ATR(30)" => lowd3 - atr30*0.25
        "84 N4: D4 Low - 0.25*ATR(30)" => lowd4 - atr30*0.25
        "84 N5: D5 Low - 0.25*ATR(30)" => lowd5 - atr30*0.25
        "85 N0: D0 Low - ATR(50)" => lowd0 - atr50*1.0
        "85 N1: D1 Low - ATR(50)" => lowd1 - atr50*1.0
        "85 N2: D2 Low - ATR(50)" => lowd2 - atr50*1.0
        "85 N3: D3 Low - ATR(50)" => lowd3 - atr50*1.0
        "85 N4: D4 Low - ATR(50)" => lowd4 - atr50*1.0
        "85 N5: D5 Low - ATR(50)" => lowd5 - atr50*1.0
        "86 N0: D0 Low - 0.5*ATR(50)" => lowd0 - atr50*0.5
        "86 N1: D1 Low - 0.5*ATR(50)" => lowd1 - atr50*0.5
        "86 N2: D2 Low - 0.5*ATR(50)" => lowd2 - atr50*0.5
        "86 N3: D3 Low - 0.5*ATR(50)" => lowd3 - atr50*0.5
        "86 N4: D4 Low - 0.5*ATR(50)" => lowd4 - atr50*0.5
        "86 N5: D5 Low - 0.5*ATR(50)" => lowd5 - atr50*0.5
        "87 N0: D0 Low - 0.25*ATR(50)" => lowd0 - atr50*0.25
        "87 N1: D1 Low - 0.25*ATR(50)" => lowd1 - atr50*0.25
        "87 N2: D2 Low - 0.25*ATR(50)" => lowd2 - atr50*0.25
        "87 N3: D3 Low - 0.25*ATR(50)" => lowd3 - atr50*0.25
        "87 N4: D4 Low - 0.25*ATR(50)" => lowd4 - atr50*0.25
        "87 N5: D5 Low - 0.25*ATR(50)" => lowd5 - atr50*0.25
        "88 N0: D0 Low - 1*Range(D0)" => lowd0 - (highd0 - lowd0)*1.0
        "88 N1: D1 Low - 1*Range(D1)" => lowd1 - (highd1 - lowd1)*1.0
        "88 N2: D2 Low - 1*Range(D2)" => lowd2 - (highd2 - lowd2)*1.0
        "88 N3: D3 Low - 1*Range(D3)" => lowd3 - (highd3 - lowd3)*1.0
        "88 N4: D4 Low - 1*Range(D4)" => lowd4 - (highd4 - lowd4)*1.0
        "88 N5: D5 Low - 1*Range(D5)" => lowd5 - (highd5 - lowd5)*1.0
        "89 N0: D0 Low - 0.6667*Range(D0)" => lowd0 - (highd0 - lowd0)*0.6666666666666666
        "89 N1: D1 Low - 0.6667*Range(D1)" => lowd1 - (highd1 - lowd1)*0.6666666666666666
        "89 N2: D2 Low - 0.6667*Range(D2)" => lowd2 - (highd2 - lowd2)*0.6666666666666666
        "89 N3: D3 Low - 0.6667*Range(D3)" => lowd3 - (highd3 - lowd3)*0.6666666666666666
        "89 N4: D4 Low - 0.6667*Range(D4)" => lowd4 - (highd4 - lowd4)*0.6666666666666666
        "89 N5: D5 Low - 0.6667*Range(D5)" => lowd5 - (highd5 - lowd5)*0.6666666666666666
        "90 N0: D0 Low - 0.5*Range(D0)" => lowd0 - (highd0 - lowd0)*0.5
        "90 N1: D1 Low - 0.5*Range(D1)" => lowd1 - (highd1 - lowd1)*0.5
        "90 N2: D2 Low - 0.5*Range(D2)" => lowd2 - (highd2 - lowd2)*0.5
        "90 N3: D3 Low - 0.5*Range(D3)" => lowd3 - (highd3 - lowd3)*0.5
        "90 N4: D4 Low - 0.5*Range(D4)" => lowd4 - (highd4 - lowd4)*0.5
        "90 N5: D5 Low - 0.5*Range(D5)" => lowd5 - (highd5 - lowd5)*0.5
        "91 N0: D0 Low - 0.3333*Range(D0)" => lowd0 - (highd0 - lowd0)*0.3333333333333333
        "91 N1: D1 Low - 0.3333*Range(D1)" => lowd1 - (highd1 - lowd1)*0.3333333333333333
        "91 N2: D2 Low - 0.3333*Range(D2)" => lowd2 - (highd2 - lowd2)*0.3333333333333333
        "91 N3: D3 Low - 0.3333*Range(D3)" => lowd3 - (highd3 - lowd3)*0.3333333333333333
        "91 N4: D4 Low - 0.3333*Range(D4)" => lowd4 - (highd4 - lowd4)*0.3333333333333333
        "91 N5: D5 Low - 0.3333*Range(D5)" => lowd5 - (highd5 - lowd5)*0.3333333333333333
        "92 N0: D0 Low - 0.25*Range(D0)" => lowd0 - (highd0 - lowd0)*0.25
        "92 N1: D1 Low - 0.25*Range(D1)" => lowd1 - (highd1 - lowd1)*0.25
        "92 N2: D2 Low - 0.25*Range(D2)" => lowd2 - (highd2 - lowd2)*0.25
        "92 N3: D3 Low - 0.25*Range(D3)" => lowd3 - (highd3 - lowd3)*0.25
        "92 N4: D4 Low - 0.25*Range(D4)" => lowd4 - (highd4 - lowd4)*0.25
        "92 N5: D5 Low - 0.25*Range(D5)" => lowd5 - (highd5 - lowd5)*0.25
        "93: Pivot S1 from 5-day extremes" => StartOfSession ? pivotS1_W : na
        "94: Pivot S2 from 5-day extremes" => StartOfSession ? pivotS2_W : na
        "95: None" => na
        => na


    myse






// ENTRY LEVEL INFO BOXES

f_calcMethodText_EL(string calcMode) =>
    calcMode =="Day" ? "Day = The OHLC values used by this entry level are calculated on the daily bars that form between 00:00:00 and 23:59:59 (HH:mm:ss) in the set TimeZone." : "Session = The OHLC values used by this entry level are calculated on the daily bars that form between the set 'Session Start' and 'Session End' times."
    

f_id2(string key) =>
    int(nz(str.tonumber(str.substring(key, 0, 2)), na))


f_hasN(string key) => str.contains(key, " N")


f_getN(string key) =>
    int i = str.pos(key, " N")
    i >= 0 ? int(nz(str.tonumber(str.substring(key, i + 2, i + 3)), na)) : na


// returns "D0..D5" from N
f_Dn(int n) => "D" + str.tostring(n)


f_pt_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left


f_entry_level_meaning(string key, bool isLong) =>
    string sideWord = isLong ? "Long" : "Short"
    string orderVerb = isLong ? "place Long orders" : "place Short orders"

    bool hasN = f_hasN(key)
    int  n    = hasN ? f_getN(key) : na
    int  id   = f_id2(key)


    bool isLowGate   = str.contains(key, "Low if close>Low")
    bool isHighGate  = str.contains(key, "High if close<High")
    bool isPctBelow  = str.contains(key, "1% below")
    bool isPctAbove  = str.contains(key, "1% above")
    bool isLowestLow = str.contains(str.lower(key), "lowest low")
    bool isHighestHi = str.contains(str.lower(key), "highest high")
    bool isSMA       = str.contains(key, "SMA(")
    bool isATR       = str.contains(key, "ATR(")
    bool isPivot     = str.contains(key, "Pivot")
    bool isWeek      = str.contains(str.lower(key), "week")
    bool isSessStart = str.contains(str.lower(key), "session-start")
    bool isRangeFrac = str.contains(key, "Range(D")
    bool isRangeCur  = str.contains(key, "range") and not isATR and not isRangeFrac and not isSMA
    bool isExt5      = str.contains(key, "5-day extremes")
    bool isNone      = str.contains(key, "95: None") or str.contains(key, "95: Zero") or str.contains(key, "95: None/Zero")


    string dnTxt = (
        hasN ?
            (n == 0 ? "today's session values (measured up to the previous bar)" :
             "the completed session/day values of " + f_Dn(n))
        : ""
    )


    if id == 0 and hasN and isLowGate
        string lvl = (n == 0 ? "today's session low (as of the previous bar)" : "the " + f_Dn(n) + " session low")
        "Strategy will " + orderVerb + " at " + lvl + " if the current bar's close is above that low."


    else if id == 0 and hasN and isHighGate
        string lvl = (n == 0 ? "today's session high (as of the previous bar)" : "the " + f_Dn(n) + " session high")
        "Strategy will " + orderVerb + " at " + lvl + " if the current bar's close is below that high."


    else if (id == 1 or id == 2) and hasN and isPctBelow and (str.contains(key, "Low") or str.contains(key, "High"))
        string ref = (
            str.contains(key, "Low") ?
                (n == 0 ? "today's session low (previous bar)" : f_Dn(n) + " session low")
            :
                (n == 0 ? "today's session high (previous bar)" : f_Dn(n) + " session high")
        )
        string off = str.contains(key, "Low") ? "1% below the low" : "1% below the high"
        string gate = str.contains(key, "Low") ? "if the current close is above that low" : "if the current close is below that high"
        "Strategy will " + orderVerb + " at a level set " + off + " (" + ref + "), " + gate + "."


    else if (id == 1 or id == 2) and hasN and isPctAbove and (str.contains(key, "Low") or str.contains(key, "High"))
        string ref = (
            str.contains(key, "Low") ?
                (n == 0 ? "today's session low (previous bar)" : f_Dn(n) + " session low")
            :
                (n == 0 ? "today's session high (previous bar)" : f_Dn(n) + " session high")
        )
        string off = str.contains(key, "Low") ? "1% above the low" : "1% above the high"
        string gate = str.contains(key, "Low") ? "if the current close is above that low" : "if the current close is below that high"
        "Strategy will " + orderVerb + " at a level set " + off + " (" + ref + "), " + gate + "."


    else if isLowestLow
        "Strategy will " + orderVerb + " at the lowest low observed over the rolling bar lookback."


    else if isHighestHi
        "Strategy will " + orderVerb + " at the highest high observed over the rolling bar lookback."


    else if isSMA
        "Strategy will " + orderVerb + " at a dynamic level derived from moving averages, combining the average price (high/low/close) \nand the average bar range over the specified lookback."


    else if id == 19 and hasN
        string ref = str.contains(key, "High") ? (f_Dn(n) + " session high") : (f_Dn(n) + " session low")
        "Strategy will " + orderVerb + " at a projected level that extends beyond the selected session extreme (" + ref + ") \nby the same distance the session close is inside the range, creating a symmetric 'mirror' projection."


    else if id == 20 and hasN
        string ref = str.contains(str.lower(key), "high") ? (f_Dn(n) + " session high") : (f_Dn(n) + " session low")
        "Strategy will " + orderVerb + " only if the next session close moves beyond the selected extreme (" + ref + "); \nin that case, the entry level is extended beyond that extreme by the size of the overshoot."


    else if id >= 21 and id <= 26
        "Strategy will " + orderVerb + " at a bar-based level taken from the current bar or a specified number of bars back (high/low)."


    else if id == 27
        "Strategy will " + orderVerb + " at the start-of-session bar extreme (high or low), \ni.e., the high/low of the bar where the session begins."


    else if id == 28
        "Strategy will " + orderVerb + " at a session-start expansion level \n(start-of-session high/low plus or minus the start-of-session bar range)."


    else if id >= 29 and id <= 31 and not isPivot
        "Strategy will " + orderVerb + " at an extreme computed across the previous five sessions/days (D1..D5)."


    else if id >= 38 and id <= 43 and (str.contains(key, "range") or str.contains(key, "Range"))
        "Strategy will " + orderVerb + " at a level built by adding or subtracting a fraction of the current bar range (high-low) \nto a reference price (high/low/close)."


    else if id >= 44 and id <= 53 and str.contains(key, "%")
        "Strategy will " + orderVerb + " at a level offset by a fixed percentage of the reference price (high/low/close), \ncreating a proportional buffer."


    else if (id == 54 or id == 55) and isPivot
        "At the start of a new session only, the script computes classic floor-trader pivot levels (P, R1/R2, S1/S2) from the selected session's OHLC \nand uses the requested pivot level as the entry price. Outside session start, the level is not refreshed."


    else if id == 56
        "Strategy will " + orderVerb + " at the current bar open price."


    else if id == 57 and isWeek
        "Strategy will " + orderVerb + " at the current week's extreme (highest high or lowest low). \nThis level updates as the week develops."


    else if (id >= 58 and id <= 72) and isATR and not hasN
        "Strategy will " + orderVerb + " at a volatility-adjusted level: current bar high/low plus or minus ATR \nover the specified length (and multiplier)."


    else if (id >= 73 and id <= 87) and isATR and hasN
        "Strategy will " + orderVerb + " at a volatility-adjusted level based on the selected session/day extreme \n(High/Low of " + f_Dn(n) + "), offset by ATR over the specified length (and multiplier)."


    else if (id >= 88 and id <= 92) and isRangeFrac and hasN
        "Strategy will " + orderVerb + " at a level offset from the selected session/day extreme \n(High/Low of " + f_Dn(n) + ") by a fraction of that same session's range (High-Low)."


    else if (id == 93 or id == 94) and isExt5
        "At the start of a new session only, the script computes pivot levels using the 5-session extremes (HighestH and LowestL) \nand the reference close, then uses the requested pivot support/resistance level as the entry price."


    else if isNone
        "This entry level is disabled (no meaningful price level is produced)."


    else
        "Strategy will " + orderVerb + " at the selected entry level definition. \n(No dedicated description matched this label; ensure the option text matches the library cases exactly.)"




// LONG Entry Level info box 
export plot_long_entry_level_info(string selectedKey, string corner, int textSize, string calcMode) =>
    var table t = table.new(f_pt_pos(corner), 2, 6, frame_width=1, frame_color=color.new(color.white, 80), border_width=1, border_color=color.new(color.white, 90))

    color accent   = color.rgb(96, 180, 255)
    color hdrBg    = color.rgb(1, 26, 76)
    color bodyBg   = color.rgb(11, 14, 20)
    color hdrTxt   = color.rgb(235, 245, 255)
    color bodyTxt  = color.rgb(210, 220, 240)

    int sHdr  = textSize + 2

    if barstate.islast
        string meaning = f_entry_level_meaning(selectedKey, true)
        string calcTxt = f_calcMethodText_EL(calcMode)

        // Accent strip
        for r = 0 to 5
            table.cell(t, 0, r, text=" ", bgcolor=(r % 2 == 0 ? color.new(accent, 0) : color.new(accent, 15)))

        // Headers
        table.cell(t, 1, 0, text="CHOSEN LONG ENTRY LEVEL", text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 2, text="ENTRY LEVEL MEANING",     text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 4, text="CALCULATION METHOD",      text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)

        // Bodies
        table.cell(t, 1, 1, text=selectedKey, text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 3, text=meaning,     text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 5, text=calcTxt,     text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)




// SHORT Entry Level info box
export plot_short_entry_level_info(string selectedKey, string corner, int textSize, string calcMode) =>
    var table t = table.new(f_pt_pos(corner), 2, 6, frame_width=1, frame_color=color.new(color.white, 80), border_width=1, border_color=color.new(color.white, 90))

    color accent   = color.rgb(255, 120, 120)
    color hdrBg    = color.rgb(76, 10, 18)
    color bodyBg   = color.rgb(11, 14, 20)
    color hdrTxt   = color.rgb(235, 245, 255)
    color bodyTxt  = color.rgb(210, 220, 240)

    int sHdr  = textSize + 2

    if barstate.islast
        string meaning = f_entry_level_meaning(selectedKey, false)
        string calcTxt = f_calcMethodText_EL(calcMode)

        // Accent strip
        for r = 0 to 5
            table.cell(t, 0, r, text=" ", bgcolor=(r % 2 == 0 ? color.new(accent, 0) : color.new(accent, 15)))

        // Headers
        table.cell(t, 1, 0, text="CHOSEN SHORT ENTRY LEVEL", text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 2, text="ENTRY LEVEL MEANING",      text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)
        table.cell(t, 1, 4, text="CALCULATION METHOD",       text_color=hdrTxt, bgcolor=hdrBg, text_size=sHdr)

        // Bodies
        table.cell(t, 1, 1, text=selectedKey, text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 3, text=meaning,     text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
        table.cell(t, 1, 5, text=calcTxt,     text_color=bodyTxt, bgcolor=bodyBg, text_size=textSize)
````
