# Custom Session VWAP by Bybllo

- url: https://www.tradingview.com/script/zcOpTyr7/
- type: indicator
- pine_id: PUB;d549f4e5a999493398760b383f05bd67
- version: 2.0

## Description

A VWAP with a fully adjustable session start time, plus three configurable deviation bands and cloud fills between them.

Standard "Session" VWAP resets at midnight - which doesn't match how many markets actually trade. This version lets you set exactly what time of day (in US Eastern Time) counts as the start of a new session, so the anchor lines up with your instrument's real trading day instead of being locked to midnight.

Note: the default setting is 0000 (midnight) in US Eastern Time. If your chart is displaying times in a different timezone (e.g. Korea Standard Time), the session may appear to start at a time like 13:00 on your chart - that's simply your local display of US Eastern midnight, not an error. This start time is fully adjustable to whatever time you prefer.

The +1~+2 and -1~-2 deviation zones are also shaded as their own cloud, which is a convenient way to read price at a glance instead of judging the gap between two separate lines.

Works well across every intraday timeframe and the daily timeframe alike. I personally use it for short-term futures scalping on the 1-minute chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bybllo

//@version=6
// ══════════════════════════════════════════════════════════════════
// Custom Session VWAP by Bybllo

// ══════════════════════════════════════════════════════════════════
// OVERVIEW
// A Volume Weighted Average Price (VWAP) indicator with a
// user-adjustable session start time, plus three configurable
// standard-deviation (or percentage) bands and cloud fills between
// them.
//
// Standard "Session" VWAP tools reset at midnight, which does not
// match how many markets actually trade (for example, index futures
// that run on an overnight session starting well before the New York
// stock market open). This indicator lets you set exactly what time
// of day counts as the start of a new session, so the VWAP anchor
// lines up with how your instrument actually trades - instead of
// being locked to midnight.
//
// CUSTOM SESSION START TIME
// When Anchor Period is set to "Session", the "Custom Session Start
// Time (HHMM)" input determines what time of day a new VWAP session
// begins, always interpreted in US Eastern Time (New York),
// regardless of the timeframe or symbol you're viewing. Leaving it
// at the default "0000" reproduces the standard midnight-anchored
// behavior. Any other 4-digit value (e.g. "0930" for 9:30, "1800"
// for 18:00) shifts the session boundary to that time. Invalid
// entries are automatically clamped to a valid time.
// Anchor Period options other than "Session" (Week, Month, Quarter,
// Year, Decade, Century, Earnings, Dividends, Splits) are unaffected
// by this setting and behave the same as any standard VWAP anchor.
//
// CHART-TYPE COMPATIBILITY
// The price source is pulled via request.security() against the
// plain underlying ticker rather than read directly off the chart,
// so the VWAP calculation is identical whether your chart is
// displaying candlesticks, Heikin Ashi, Renko, Kagi, or any other
// non-standard chart type.
//
// BANDS AND CLOUDS
// Three independent bands (multipliers configurable, default 1/2/3)
// can be shown either as standard-deviation distances or as a fixed
// percentage of the VWAP. Each band has its own fill between its
// upper and lower line ("Bands Fill #1/#2/#3"), and an additional
// cloud ("Bands Fill #1~#2") highlights the region between the 1st
// and 2nd band on both the upside and downside. In particular, having
// the +1~+2 and -1~-2 deviation zone shaded as its own cloud is very
// convenient for reading price at a glance - it marks out the "one
// step beyond the first band" zone as a distinct area, rather than
// having to visually judge the gap between two separate lines.
//
// INTENDED USE
// Works well across every intraday timeframe and on the daily
// timeframe alike. I personally use it for short-term futures
// scalping, on the 1-minute chart.
//
// NOTES
// - This indicator does not place real orders; it is a visual
//   analysis tool.
// - "Custom Session Start Time" only affects the "Session" anchor.
//
// DISCLAIMER
// For educational and informational purposes only. This is not
// financial advice. Past performance does not guarantee future
// results. Always test on your own instrument and timeframe before
// relying on it.
// ══════════════════════════════════════════════════════════════════
indicator(title="Custom Session VWAP by Bybllo", overlay=true, timeframe="", timeframe_gaps=true)

hideonDWM = input(false, title="Hide VWAP on Daily and Higher Timeframes", group="VWAP Settings", display = display.none)
var anchor = input.string(defval = "Session", title="Anchor Period",
 options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group="VWAP Settings")
sessionStartInput = input.string("0000", title="Custom Session Start Time (HHMM)", group="VWAP Settings",
 tooltip="When Anchor Period is 'Session', a new session starts at this time of day instead of midnight. Always interpreted in US Eastern Time (New York), regardless of the instrument's own exchange timezone. Example: 1800 = 18:00. Leave at 0000 for the standard midnight-anchored behavior. Invalid values are automatically corrected.")
src = input(title = "Source", defval = hlc3, group="VWAP Settings", display = display.none)
offset = input.int(0, title="Offset", group="VWAP Settings", display = display.none)

BANDS_GROUP = "Bands Settings"
CALC_MODE_TOOLTIP = "Determines the units used to calculate the distance of the bands. When 'Percentage' is selected, a multiplier of 1 means 1%."
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = BANDS_GROUP, tooltip = CALC_MODE_TOOLTIP, display = display.none)
showBand_1 = input(true, title = "", group = BANDS_GROUP, inline = "band_1", display = display.none)
bandMult_1 = input.float(1.0, title = "Bands Multiplier #1", group = BANDS_GROUP, inline = "band_1", step = 0.5, minval=0, display = display.none, active = showBand_1)
showBand_2 = input(true, title = "", group = BANDS_GROUP, inline = "band_2", display = display.none)
bandMult_2 = input.float(2.0, title = "Bands Multiplier #2", group = BANDS_GROUP, inline = "band_2", step = 0.5, minval=0, display = display.none, active = showBand_2)
showBand_3 = input(true, title = "", group = BANDS_GROUP, inline = "band_3", display = display.none)
bandMult_3 = input.float(3.0, title = "Bands Multiplier #3", group = BANDS_GROUP, inline = "band_3", step = 0.5, minval=0, display = display.none, active = showBand_3)

// ============================================
// Always use real market prices regardless of chart type (Heikin Ashi,
// Renko, etc.) - force-fetched via request.security. Volume is used
// as-is since it is always the real value regardless of chart type.
// ============================================
t = ticker.new(syminfo.prefix, syminfo.ticker)
realSrc = request.security(t, timeframe.period, src)

cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

// ============================================
// "Custom Session Start Time (HHMM)" - parses the HHMM string and
// auto-corrects out-of-range values (same approach as this author's
// "Multiday Anchored Auto VWAP" indicator). This value is used as the
// start of the trading day, and a new "session" is detected whenever
// the calendar date changes relative to that shifted time (0000
// reproduces the standard midnight-anchored behavior exactly).
// ============================================
getSessionStartMinutes(hhmmStr) =>
    numVal = str.tonumber(str.trim(hhmmStr))
    raw = na(numVal) ? 0 : math.round(numVal)
    raw := math.max(0, math.min(2359, raw))
    hh = int(raw / 100)
    mm = int(raw % 100)
    hh := math.min(23, hh)
    mm := math.min(59, mm)
    hh * 60 + mm

sessionStartMinutes = getSessionStartMinutes(sessionStartInput)
sessionStartMs = sessionStartMinutes * 60 * 1000
shiftedTime = time - sessionStartMs
// Calling dayofmonth()/month()/year() without a timezone argument
// uses the instrument's own exchange timezone, which would make the
// HHMM value mean something different on every symbol. Since the
// HHMM value is always meant as US Eastern Time (New York), the
// timezone is fixed explicitly here so the day boundary is consistent
// across every symbol regardless of its own exchange timezone.
isNewSessionDay = dayofmonth(shiftedTime, "America/New_York") != dayofmonth(shiftedTime[1], "America/New_York") or month(shiftedTime, "America/New_York") != month(shiftedTime[1], "America/New_York") or year(shiftedTime, "America/New_York") != year(shiftedTime[1], "America/New_York")

isNewPeriod = switch anchor
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
	"Session"   => isNewSessionDay
	"Week"      => timeframe.change("W")
	"Month"     => timeframe.change("M")
	"Quarter"   => timeframe.change("3M")
	"Year"      => timeframe.change("12M")
	"Decade"    => timeframe.change("12M") and year % 10 == 0
	"Century"   => timeframe.change("12M") and year % 100 == 0
	=> false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(realSrc[1]) and not isEsdAnchor
	isNewPeriod := true

float vwapValue = na
float upperBandValue1 = na
float lowerBandValue1 = na
float upperBandValue2 = na
float lowerBandValue2 = na
float upperBandValue3 = na
float lowerBandValue3 = na

if not (hideonDWM and timeframe.isdwm)
    [_vwap, _stdevUpper, _] = ta.vwap(realSrc, isNewPeriod, 1)
	vwapValue := _vwap
    stdevAbs = _stdevUpper - _vwap
	bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _vwap * 0.01
	upperBandValue1 := _vwap + bandBasis * bandMult_1
	lowerBandValue1 := _vwap - bandBasis * bandMult_1
	upperBandValue2 := _vwap + bandBasis * bandMult_2
	lowerBandValue2 := _vwap - bandBasis * bandMult_2
	upperBandValue3 := _vwap + bandBasis * bandMult_3
	lowerBandValue3 := _vwap - bandBasis * bandMult_3

plot(vwapValue, title = "VWAP", color = color.new(#ffe31b, 0), offset = offset, linestyle = plot.linestyle_dotted, linewidth = 4)

displayBand1 = showBand_1 ? display.all : display.none
upperBand_1 = plot(upperBandValue1, title="Upper Band #1", color = color.new(#3029ff, 0), offset = offset, display = displayBand1, linestyle = plot.linestyle_dotted, linewidth = 2)
lowerBand_1 = plot(lowerBandValue1, title="Lower Band #1", color = color.new(#3029ff, 0), offset = offset, display = displayBand1, linestyle = plot.linestyle_dotted, linewidth = 2)
fill(upperBand_1, lowerBand_1,      title="Bands Fill #1", color = color.new(color.blue, 96),   display = displayBand1)

displayBand2 = showBand_2 ? display.all : display.none
upperBand_2 = plot(upperBandValue2, title="Upper Band #2", color = color.new(#6c960a, 0), offset = offset, display = displayBand2, linestyle = plot.linestyle_dotted, linewidth = 2)
lowerBand_2 = plot(lowerBandValue2, title="Lower Band #2", color = color.new(#6c960a, 0), offset = offset, display = displayBand2, linestyle = plot.linestyle_dotted, linewidth = 2)
fill(upperBand_2, lowerBand_2,      title="Bands Fill #2", color = color.new(color.olive, 93),   display = displayBand2)

displayBand3 = showBand_3 ? display.all : display.none
upperBand_3 = plot(upperBandValue3, title="Upper Band #3", color = color.new(#006e89, 0), offset = offset, display = displayBand3, linestyle = plot.linestyle_dotted, linewidth = 2)
lowerBand_3 = plot(lowerBandValue3, title="Lower Band #3", color = color.new(#006e89, 0), offset = offset, display = displayBand3, linestyle = plot.linestyle_dotted, linewidth = 2)
fill(upperBand_3, lowerBand_3,      title="Bands Fill #3", color = color.new(color.teal, 95),   display = displayBand3)

// ============================================
// "Bands Fill #1~#2" - a cloud covering only the region between the
// 1st and 2nd band, on both the upside (+1 to +2) and downside (-1
// to -2). Uses the same color as "Bands Fill #1". Only shown when
// both Band #1 and Band #2 are enabled.
// ============================================
displayBand1and2 = (showBand_1 and showBand_2) ? display.all : display.none
fill(upperBand_1, upperBand_2, title="Bands Fill #1~#2 (Upper)", color = color.new(color.blue, 90), display = displayBand1and2)
fill(lowerBand_1, lowerBand_2, title="Bands Fill #1~#2 (Lower)", color = color.new(color.blue, 90), display = displayBand1and2)
````
