# MA Ribbon, Triple VWAP & TWAP Combined

- url: https://www.tradingview.com/script/X3DBB77j-MA-Ribbon-Triple-VWAP-TWAP-Combined/
- type: indicator
- pine_id: PUB;b336fdfd4a72425da00bc9fd22fd4c4f
- version: 1.0

## Description

MA Ribbon, Triple VWAP & TWAP Combined
An amazing tool if used correctly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("MA Ribbon, Triple VWAP & TWAP Combined", shorttitle = "MA Ribbon + 3xVWAP + TWAP", overlay = true, timeframe = "", timeframe_gaps = true)

// --- Groups ---
const string G_MA    = "Moving Average Ribbon Settings"
const string G_VWAP1 = "VWAP #1 Settings"
const string G_BND1  = "VWAP #1 Bands Settings"
const string G_VWAP2 = "VWAP #2 Settings"
const string G_BND2  = "VWAP #2 Bands Settings"
const string G_VWAP3 = "VWAP #3 Settings"
const string G_BND3  = "VWAP #3 Bands Settings"
const string G_TWAP  = "TWAP Settings"

// ==========================================
// --- Moving Average Ribbon Section ---
// ==========================================

// MA Calculation Function
f_ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length) 
        "EMA"        => ta.ema(source,  length) 
        "SMMA (RMA)" => ta.rma(source,  length) 
        "WMA"        => ta.wma(source,  length) 
        "VWMA"       => ta.vwma(source, length) 
        => na

// MA Inputs
show_ma1   = input.bool(true,         "MA #1", inline = "MA1", group = G_MA)
ma1_type   = input.string("SMA", "",      inline = "MA1", group = G_MA, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input.source(close,     "",      inline = "MA1", group = G_MA)
ma1_length = input.int(20,       "",      inline = "MA1", group = G_MA, minval  = 1)
ma1_color  = input.color(#f6c309,    "",      inline = "MA1", group = G_MA)

show_ma2   = input.bool(true,         "MA #2", inline = "MA2", group = G_MA)
ma2_type   = input.string("SMA", "",      inline = "MA2", group = G_MA, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input.source(close,     "",      inline = "MA2", group = G_MA)
ma2_length = input.int(50,       "",      inline = "MA2", group = G_MA, minval  = 1)
ma2_color  = input.color(#fb9800,    "",      inline = "MA2", group = G_MA)

show_ma3   = input.bool(true,         "MA #3", inline = "MA3", group = G_MA)
ma3_type   = input.string("SMA", "",      inline = "MA3", group = G_MA, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input.source(close,     "",      inline = "MA3", group = G_MA)
ma3_length = input.int(100,      "",      inline = "MA3", group = G_MA, minval  = 1)
ma3_color  = input.color(#fb6500,    "",      inline = "MA3", group = G_MA)

show_ma4   = input.bool(true,         "MA #4", inline = "MA4", group = G_MA)
ma4_type   = input.string("SMA", "",      inline = "MA4", group = G_MA, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input.source(close,     "",      inline = "MA4", group = G_MA)
ma4_length = input.int(200,      "",      inline = "MA4", group = G_MA, minval  = 1)
ma4_color  = input.color(#f60c0c,    "",      inline = "MA4", group = G_MA)

// MA Logic
ma1 = show_ma1 ? f_ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? f_ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? f_ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? f_ma(ma4_source, ma4_length, ma4_type) : na

// Volume check
if barstate.islast and ta.cum(volume) == 0
    runtime.error("No volume is provided by the data vendor.")

// ==========================================
// --- VWAP #1 Section ---
// ==========================================

// VWAP #1 Inputs
show_vwap1 = input.bool(true, "Show VWAP #1", group = G_VWAP1)
hideonDWM1 = input.bool(false, "Hide VWAP #1 on 1D or Above", group = G_VWAP1)
anchor1    = input.string("Session", "Anchor Period", options = ["Session", "NYSE Open", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group = G_VWAP1)
vwap_src1  = input.source(hlc3, "Source", group = G_VWAP1)
offset1    = input.int(0, "Offset", group = G_VWAP1)

// VWAP #1 Bands Inputs
calcMode1  = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = G_BND1)
showBand1_1 = input.bool(true, "Band #1", inline = "B1_1", group = G_BND1)
bandMult1_1 = input.float(1.0, "Mult", step = 0.5, minval = 0, inline = "B1_1", group = G_BND1)
showBand1_2 = input.bool(false, "Band #2", inline = "B1_2", group = G_BND1)
bandMult1_2 = input.float(2.0, "Mult", step = 0.5, minval = 0, inline = "B1_2", group = G_BND1)
showBand1_3 = input.bool(false, "Band #3", inline = "B1_3", group = G_BND1)
bandMult1_3 = input.float(3.0, "Mult", step = 0.5, minval = 0, inline = "B1_3", group = G_BND1)

// VWAP #1 Reset Logic
isNewPeriod1 = switch anchor1
	"Earnings" => 
		new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_earnings_actual) or not na(new_earnings_standardized)
	"Dividends" => 
		new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_dividends)
	"Splits"    => 
		new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_split)
	"Session"   => timeframe.change("D")
    "NYSE Open" => 
        t = time("1", "0930-0931", "America/New_York")
        not na(t) and na(t[1])
	"Week"      => timeframe.change("W")
	"Month"     => timeframe.change("M")
	"Quarter"   => timeframe.change("3M")
	"Year"      => timeframe.change("12M")
	"Decade"    => timeframe.change("12M") and year % 10 == 0
	"Century"   => timeframe.change("12M") and year % 100 == 0
	=> false

if na(vwap_src1[1]) and anchor1 != "Earnings" and anchor1 != "Dividends" and anchor1 != "Splits"
	isNewPeriod1 := true

// VWAP #1 Calculation
float vwap1Value = na
float u1_1 = na, float l1_1 = na
float u1_2 = na, float l1_2 = na
float u1_3 = na, float l1_3 = na

if show_vwap1 and not (hideonDWM1 and timeframe.isdwm)
    [_vwap, _stdevUpper, _] = ta.vwap(vwap_src1, isNewPeriod1, 1)
	vwap1Value := _vwap
    stdevAbs = _stdevUpper - _vwap
	bandBasis = calcMode1 == "Standard Deviation" ? stdevAbs : _vwap * 0.01
	u1_1 := _vwap + bandBasis * bandMult1_1
	l1_1 := _vwap - bandBasis * bandMult1_1
	u1_2 := _vwap + bandBasis * bandMult1_2
	l1_2 := _vwap - bandBasis * bandMult1_2
	u1_3 := _vwap + bandBasis * bandMult1_3
	l1_3 := _vwap - bandBasis * bandMult1_3

// ==========================================
// --- VWAP #2 Section ---
// ==========================================

// VWAP #2 Inputs
show_vwap2 = input.bool(true, "Show VWAP #2", group = G_VWAP2)
hideonDWM2 = input.bool(false, "Hide VWAP #2 on 1D or Above", group = G_VWAP2)
anchor2    = input.string("Week", "Anchor Period", options = ["Session", "NYSE Open", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group = G_VWAP2)
vwap_src2  = input.source(hlc3, "Source", group = G_VWAP2)
offset2    = input.int(0, "Offset", group = G_VWAP2)

// VWAP #2 Bands Inputs
calcMode2  = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = G_BND2)
showBand2_1 = input.bool(true, "Band #1", inline = "B2_1", group = G_BND2)
bandMult2_1 = input.float(1.0, "Mult", step = 0.5, minval = 0, inline = "B2_1", group = G_BND2)
showBand2_2 = input.bool(false, "Band #2", inline = "B2_2", group = G_BND2)
bandMult2_2 = input.float(2.0, "Mult", step = 0.5, minval = 0, inline = "B2_2", group = G_BND2)
showBand2_3 = input.bool(false, "Band #3", inline = "B2_3", group = G_BND2)
bandMult2_3 = input.float(3.0, "Mult", step = 0.5, minval = 0, inline = "B2_3", group = G_BND2)

// VWAP #2 Reset Logic
isNewPeriod2 = switch anchor2
	"Earnings" => 
		new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_earnings_actual) or not na(new_earnings_standardized)
	"Dividends" => 
		new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_dividends)
	"Splits"    => 
		new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_split)
	"Session"   => timeframe.change("D")
    "NYSE Open" => 
        t = time("1", "0930-0931", "America/New_York")
        not na(t) and na(t[1])
	"Week"      => timeframe.change("W")
	"Month"     => timeframe.change("M")
	"Quarter"   => timeframe.change("3M")
	"Year"      => timeframe.change("12M")
	"Decade"    => timeframe.change("12M") and year % 10 == 0
	"Century"   => timeframe.change("12M") and year % 100 == 0
	=> false

if na(vwap_src2[1]) and anchor2 != "Earnings" and anchor2 != "Dividends" and anchor2 != "Splits"
	isNewPeriod2 := true

// VWAP #2 Calculation
float vwap2Value = na
float u2_1 = na, float l2_1 = na
float u2_2 = na, float l2_2 = na
float u2_3 = na, float l2_3 = na

if show_vwap2 and not (hideonDWM2 and timeframe.isdwm)
    [_vwap2, _stdevUpper2, _] = ta.vwap(vwap_src2, isNewPeriod2, 1)
	vwap2Value := _vwap2
    stdevAbs2 = _stdevUpper2 - _vwap2
	bandBasis2 = calcMode2 == "Standard Deviation" ? stdevAbs2 : _vwap2 * 0.01
	u2_1 := _vwap2 + bandBasis2 * bandMult2_1
	l2_1 := _vwap2 - bandBasis2 * bandMult2_1
	u2_2 := _vwap2 + bandBasis2 * bandMult2_2
	l2_2 := _vwap2 - bandBasis2 * bandMult2_2
	u2_3 := _vwap2 + bandBasis2 * bandMult2_3
	l2_3 := _vwap2 - bandBasis2 * bandMult2_3

// ==========================================
// --- VWAP #3 Section ---
// ==========================================

// VWAP #3 Inputs
show_vwap3 = input.bool(true, "Show VWAP #3", group = G_VWAP3)
hideonDWM3 = input.bool(false, "Hide VWAP #3 on 1D or Above", group = G_VWAP3)
anchor3    = input.string("Month", "Anchor Period", options = ["Session", "NYSE Open", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group = G_VWAP3)
vwap_src3  = input.source(hlc3, "Source", group = G_VWAP3)
offset3    = input.int(0, "Offset", group = G_VWAP3)

// VWAP #3 Bands Inputs
calcMode3  = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = G_BND3)
showBand3_1 = input.bool(true, "Band #1", inline = "B3_1", group = G_BND3)
bandMult3_1 = input.float(1.0, "Mult", step = 0.5, minval = 0, inline = "B3_1", group = G_BND3)
showBand3_2 = input.bool(false, "Band #2", inline = "B3_2", group = G_BND3)
bandMult3_2 = input.float(2.0, "Mult", step = 0.5, minval = 0, inline = "B3_2", group = G_BND3)
showBand3_3 = input.bool(false, "Band #3", inline = "B3_3", group = G_BND3)
bandMult3_3 = input.float(3.0, "Mult", step = 0.5, minval = 0, inline = "B3_3", group = G_BND3)

// VWAP #3 Reset Logic
isNewPeriod3 = switch anchor3
	"Earnings" => 
		new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_earnings_actual) or not na(new_earnings_standardized)
	"Dividends" => 
		new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_dividends)
	"Splits"    => 
		new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_split)
	"Session"   => timeframe.change("D")
    "NYSE Open" => 
        t = time("1", "0930-0931", "America/New_York")
        not na(t) and na(t[1])
	"Week"      => timeframe.change("W")
	"Month"     => timeframe.change("M")
	"Quarter"   => timeframe.change("3M")
	"Year"      => timeframe.change("12M")
	"Decade"    => timeframe.change("12M") and year % 10 == 0
	"Century"   => timeframe.change("12M") and year % 100 == 0
	=> false

if na(vwap_src3[1]) and anchor3 != "Earnings" and anchor3 != "Dividends" and anchor3 != "Splits"
	isNewPeriod3 := true

// VWAP #3 Calculation
float vwap3Value = na
float u3_1 = na, float l3_1 = na
float u3_2 = na, float l3_2 = na
float u3_3 = na, float l3_3 = na

if show_vwap3 and not (hideonDWM3 and timeframe.isdwm)
    [_vwap3, _stdevUpper3, _] = ta.vwap(vwap_src3, isNewPeriod3, 1)
	vwap3Value := _vwap3
    stdevAbs3 = _stdevUpper3 - _vwap3
	bandBasis3 = calcMode3 == "Standard Deviation" ? stdevAbs3 : _vwap3 * 0.01
	u3_1 := _vwap3 + bandBasis3 * bandMult3_1
	l3_1 := _vwap3 - bandBasis3 * bandMult3_1
	u3_2 := _vwap3 + bandBasis3 * bandMult3_2
	l3_2 := _vwap3 - bandBasis3 * bandMult3_2
	u3_3 := _vwap3 + bandBasis3 * bandMult3_3
	l3_3 := _vwap3 - bandBasis3 * bandMult3_3

// ==========================================
// --- TWAP Section ---
// ==========================================

// TWAP Inputs
show_twap  = input.bool(true, "Show TWAP", group = G_TWAP)
twap_anch  = input.timeframe("1D", "Anchor Period", group = G_TWAP)
twap_src   = input.source(ohlc4, "Source", group = G_TWAP)
twap_off   = input.int(0, "Offset", group = G_TWAP)

// TWAP Calculation Function
twap(source, anchorChange) =>
    var float prices = 0.0
    var int count = 0

    if anchorChange
        prices := 0.0
        count := 0

    prices += source
    count += 1

    prices / count

// TWAP Logic
twapValue = show_twap ? twap(twap_src, timeframe.change(twap_anch)) : na

// ==========================================
// --- Plotting ---
// ==========================================

// MA Plots
plot(ma1, "MA #1", ma1_color, 1, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, 1, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, 1, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, 1, display = show_ma4 ? display.all : display.none)

// VWAP #1 Plots
plot(vwap1Value, "VWAP #1", #2962FF, offset = offset1)

p1_u1 = plot(u1_1, "VWAP1 Upper Band #1", color.green, offset = offset1, display = showBand1_1 ? display.all : display.none)
p1_l1 = plot(l1_1, "VWAP1 Lower Band #1", color.green, offset = offset1, display = showBand1_1 ? display.all : display.none)
fill(p1_u1, p1_l1, color.new(color.green, 95), "VWAP1 Bands Fill #1", display = showBand1_1 ? display.all : display.none)

p1_u2 = plot(u1_2, "VWAP1 Upper Band #2", color.olive, offset = offset1, display = showBand1_2 ? display.all : display.none)
p1_l2 = plot(l1_2, "VWAP1 Lower Band #2", color.olive, offset = offset1, display = showBand1_2 ? display.all : display.none)
fill(p1_u2, p1_l2, color.new(color.olive, 95), "VWAP1 Bands Fill #2", display = showBand1_2 ? display.all : display.none)

p1_u3 = plot(u1_3, "VWAP1 Upper Band #3", color.teal, offset = offset1, display = showBand1_3 ? display.all : display.none)
p1_l3 = plot(l1_3, "VWAP1 Lower Band #3", color.teal, offset = offset1, display = showBand1_3 ? display.all : display.none)
fill(p1_u3, p1_l3, color.new(color.teal, 95), "VWAP1 Bands Fill #3", display = showBand1_3 ? display.all : display.none)

// VWAP #2 Plots
plot(vwap2Value, "VWAP #2", #FF5252, offset = offset2)

p2_u1 = plot(u2_1, "VWAP2 Upper Band #1", color.red, offset = offset2, display = showBand2_1 ? display.all : display.none)
p2_l1 = plot(l2_1, "VWAP2 Lower Band #1", color.red, offset = offset2, display = showBand2_1 ? display.all : display.none)
fill(p2_u1, p2_l1, color.new(color.red, 95), "VWAP2 Bands Fill #1", display = showBand2_1 ? display.all : display.none)

p2_u2 = plot(u2_2, "VWAP2 Upper Band #2", color.maroon, offset = offset2, display = showBand2_2 ? display.all : display.none)
p2_l2 = plot(l2_2, "VWAP2 Lower Band #2", color.maroon, offset = offset2, display = showBand2_2 ? display.all : display.none)
fill(p2_u2, p2_l2, color.new(color.maroon, 95), "VWAP2 Bands Fill #2", display = showBand2_2 ? display.all : display.none)

p2_u3 = plot(u2_3, "VWAP2 Upper Band #3", color.orange, offset = offset2, display = showBand2_3 ? display.all : display.none)
p2_l3 = plot(l2_3, "VWAP2 Lower Band #3", color.orange, offset = offset2, display = showBand2_3 ? display.all : display.none)
fill(p2_u3, p2_l3, color.new(color.orange, 95), "VWAP2 Bands Fill #3", display = showBand2_3 ? display.all : display.none)

// VWAP #3 Plots
plot(vwap3Value, "VWAP #3", #9c27b0, offset = offset3)

p3_u1 = plot(u3_1, "VWAP3 Upper Band #1", color.purple, offset = offset3, display = showBand3_1 ? display.all : display.none)
p3_l1 = plot(l3_1, "VWAP3 Lower Band #1", color.purple, offset = offset3, display = showBand3_1 ? display.all : display.none)
fill(p3_u1, p3_l1, color.new(color.purple, 95), "VWAP3 Bands Fill #1", display = showBand3_1 ? display.all : display.none)

p3_u2 = plot(u3_2, "VWAP3 Upper Band #2", color.fuchsia, offset = offset3, display = showBand3_2 ? display.all : display.none)
p3_l2 = plot(l3_2, "VWAP3 Lower Band #2", color.fuchsia, offset = offset3, display = showBand3_2 ? display.all : display.none)
fill(p3_u2, p3_l2, color.new(color.fuchsia, 95), "VWAP3 Bands Fill #2", display = showBand3_2 ? display.all : display.none)

p3_u3 = plot(u3_3, "VWAP3 Upper Band #3", color.blue, offset = offset3, display = showBand3_3 ? display.all : display.none)
p3_l3 = plot(l3_3, "VWAP3 Lower Band #3", color.blue, offset = offset3, display = showBand3_3 ? display.all : display.none)
fill(p3_u3, p3_l3, color.new(color.blue, 95), "VWAP3 Bands Fill #3", display = showBand3_3 ? display.all : display.none)

// TWAP Plot
plot(twapValue, "TWAP", #dd7a28, offset = twap_off)
````
