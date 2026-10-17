# North Node Sign Crossings

- url: https://www.tradingview.com/script/WQ3v3QvV-North-Node-Sign-Crossings/
- type: indicator
- pine_id: PUB;af1db15b06064994af4b91fe21f7a474
- version: 3.0

## Description

1. Title
North Node Sign Crossings

2. Short Description
Plots vertical chart lines at predefined North Node sign-entry times. An optional estimated mode generates sign entries for 1960 through 2060 and can label whole-sign houses using a selected reference Ascendant.

3. Full Description
North Node Sign Crossings marks sign-entry events on the chart with vertical lines. The lines are positioned by event time and extend across the chart; they do not use the chart’s price data to calculate the events. Each line is colored according to the sign entered.

Event modes

With Vedic Astrology Mode unchecked, the indicator uses the predefined timestamps in its event list, described by the script as tropical True Node events. The list includes retrograde crossings and a direct crossing. These event times are fixed inputs to the script, not values calculated from the chart.

With Vedic Astrology Mode checked, the indicator generates estimated sign-entry times from a constant-speed model. It estimates the average full-cycle duration from the intervals between Capricorn entries in the predefined event list, divides that duration into twelve equal sign intervals, and anchors the sequence to Capricorn on November 26, 2026 at 00:00 UTC. The generated events cover January 1, 1960 through December 31, 2060. This is a modeled sign sequence, not a verified astronomical or sidereal ephemeris.

Inputs and interpretation

Show transit lines controls whether the indicator displays its lines.
Vedic Astrology Mode selects between the predefined event list and the estimated constant-speed mode.
Reference Ascendant sign is used only in the estimated mode. When selected, that sign is assigned whole-sign house 1, and the remaining signs are mapped to houses in zodiac order.
Each zodiac sign has its own visibility toggle and color setting. The line color identifies the destination sign; use distinct colors to distinguish all enabled signs.
When the estimated mode is active and a reference Ascendant is selected, labels show the Rahu whole-sign house. A label’s tooltip includes the entered sign, the opposite Ketu sign and house, the reference Ascendant, crossing direction, event time in UTC, and the model’s anchor and estimation notes. Without a selected Ascendant, the estimated transit lines remain visible, but house labels are unavailable.

This script assigns houses from a user-selected sign; it does not calculate or convert an Ascendant, determine a natal chart, or calculate Placidus houses.

4. Usage Notes and Limitations
Use the lines as time markers for the listed or modeled sign entries. Changing the chart symbol or price does not change the event timestamps.

The predefined mode displays its encoded event list rather than computing a live ephemeris. The estimated mode assumes constant speed between sign entries and uses a fixed anchor; its timestamps should not be interpreted as verified astronomical or sidereal ingress times. Whole-sign house labels depend on the reference Ascendant selected in the settings.

## Source Code

````pine
//@version=6
indicator("North Node Sign Crossings", overlay = true, max_lines_count = 100, max_labels_count = 100)

const string SETTINGS = "North Node Signs"
const string HOUSE_SETTINGS = "House Interpretation"
const string REGION_SETTINGS = "Graphic Objects"
const int VEDIC_ANCHOR = timestamp("26 Nov 2026 00:00 +0000")
const int VEDIC_START = timestamp("01 Jan 1960 00:00 +0000")
const int VEDIC_END = timestamp("01 Jan 2061 00:00 +0000")
const int ARIES = 0
const int TAURUS = 1
const int GEMINI = 2
const int CANCER = 3
const int LEO = 4
const int VIRGO = 5
const int LIBRA = 6
const int SCORPIO = 7
const int SAGITTARIUS = 8
const int CAPRICORN = 9
const int AQUARIUS = 10
const int PISCES = 11
bool enabled = input.bool(true, "Show transit lines", display = display.none)
bool vedicMode = input.bool(false, "Vedic Astrology Mode (Whole-Sign Houses)", group = HOUSE_SETTINGS, tooltip = "Unchecked: original PDF tropical True Node events. Checked: estimated constant-speed 30-degree sign entries, anchored to Capricorn on November 26, 2026 at 00:00 UTC by convention. The average full-cycle duration is calibrated from the PDF's Capricorn entries. Covers 1960-2060; not a verified sidereal ephemeris or Placidus calculation.", display = display.none)
bool swissTrueNodeMode = input.bool(false, "Swiss Ephemeris True Node (Lahiri)", group = HOUSE_SETTINGS, tooltip = "Precomputed apparent geocentric Swiss Ephemeris True Node entries using Lahiri sidereal mode. Timestamps are rounded to seconds; historical and far-future conversion follows Swiss Ephemeris UT1 fallback when UTC is unavailable. This mode takes precedence over the estimated Vedic mode. Swiss Ephemeris 2.10.03; no astronomical calculation runs in Pine.", display = display.none)
string referenceAscendant = input.string("Not set", "Reference Ascendant sign", options = ["Not set", "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"], group = HOUSE_SETTINGS, tooltip = "Select the Ascendant sign of your fixed reference chart for the modeled sign convention. Its entire sign becomes house 1. This assigns houses only; it does not calculate or convert the Ascendant. Not set leaves house labels unavailable without hiding modeled transit lines.", display = display.none)
bool ariesOn = input.bool(true, "Aries", inline = "a", group = SETTINGS, display = display.none)
color ariesInk = input.color(#E64A19, "Color", inline = "a", group = SETTINGS, display = display.none)
bool taurusOn = input.bool(true, "Taurus", inline = "b", group = SETTINGS, display = display.none)
color taurusInk = input.color(#A66A00, "Color", inline = "b", group = SETTINGS, display = display.none)
bool geminiOn = input.bool(true, "Gemini", inline = "c", group = SETTINGS, display = display.none)
color geminiInk = input.color(#827717, "Color", inline = "c", group = SETTINGS, display = display.none)
bool cancerOn = input.bool(true, "Cancer", inline = "d", group = SETTINGS, display = display.none)
color cancerInk = input.color(#65A30D, "Color", inline = "d", group = SETTINGS, display = display.none)
bool leoOn = input.bool(true, "Leo", inline = "e", group = SETTINGS, display = display.none)
color leoInk = input.color(#00875A, "Color", inline = "e", group = SETTINGS, display = display.none)
bool virgoOn = input.bool(true, "Virgo", inline = "f", group = SETTINGS, display = display.none)
color virgoInk = input.color(#00838F, "Color", inline = "f", group = SETTINGS, display = display.none)
bool libraOn = input.bool(true, "Libra", inline = "g", group = SETTINGS, display = display.none)
color libraInk = input.color(#039BE5, "Color", inline = "g", group = SETTINGS, display = display.none)
bool scorpioOn = input.bool(true, "Scorpio", inline = "h", group = SETTINGS, display = display.none)
color scorpioInk = input.color(#3454D1, "Color", inline = "h", group = SETTINGS, display = display.none)
bool sagittariusOn = input.bool(true, "Sagittarius", inline = "i", group = SETTINGS, display = display.none)
color sagittariusInk = input.color(#7E57C2, "Color", inline = "i", group = SETTINGS, display = display.none)
bool capricornOn = input.bool(true, "Capricorn", inline = "j", group = SETTINGS, display = display.none)
color capricornInk = input.color(#C2185B, "Color", inline = "j", group = SETTINGS, display = display.none)
bool aquariusOn = input.bool(true, "Aquarius", inline = "k", group = SETTINGS, display = display.none)
color aquariusInk = input.color(#B71C1C, "Color", inline = "k", group = SETTINGS, display = display.none)
bool piscesOn = input.bool(true, "Pisces", inline = "l", group = SETTINGS, display = display.none)
color piscesInk = input.color(#707070, "Color", inline = "l", group = SETTINGS, display = display.none)
int regionOpacity = input.int(20, "Region opacity", minval = 0, maxval = 100, group = REGION_SETTINGS, display = display.none)

type NodeCrossing
	int instant
	int destination
	bool backward

var array<NodeCrossing> crossings = array.new<NodeCrossing>()
var array<NodeCrossing> vedicCrossings = array.new<NodeCrossing>()
var array<NodeCrossing> swissCrossings = array.new<NodeCrossing>()
var array<line> strokes = array.new<line>()
var table paletteNotice = table.new(position.top_right, 1, 1)
var table houseNotice = table.new(position.bottom_right, 1, 1)

registerCrossing(int year, int month, int day, int hour, int minute, int second, string zone, int destination, bool backward = true) =>
	array.push(crossings, NodeCrossing.new(timestamp(zone, year, month, day, hour, minute, second), destination, backward))

registerSwissCrossing(int year, int month, int day, int hour, int minute, int second, int destination, bool backward) =>
	array.push(swissCrossings, NodeCrossing.new(timestamp("GMT+0", year, month, day, hour, minute, second), destination, backward))

wholeSignHouse(int signIndex, int ascendantIndex) =>
	(signIndex - ascendantIndex + 12) % 12 + 1

buildVedicCrossings() =>
	float totalCycleDuration = 0.0
	int cycleCount = 0
	int previousCapricorn = na
	for crossing in crossings
		if crossing.destination == CAPRICORN
			if not na(previousCapricorn)
				totalCycleDuration += crossing.instant - previousCapricorn
				cycleCount += 1
			previousCapricorn := crossing.instant
	if cycleCount == 0 or totalCycleDuration <= 0
		runtime.error("Whole-Sign estimates require valid full-cycle Capricorn intervals in the PDF dataset.")
	float stepDuration = totalCycleDuration / cycleCount / 12.0
	int firstStep = int(math.floor((VEDIC_START - VEDIC_ANCHOR) / stepDuration))
	int lastStep = int(math.floor((VEDIC_END - VEDIC_ANCHOR) / stepDuration))
	for stepIndex = firstStep to lastStep
		int entryTime = VEDIC_ANCHOR + int(math.round(stepIndex * stepDuration))
		int signIndex = ((CAPRICORN - stepIndex) % 12 + 12) % 12
		if entryTime < VEDIC_END
			array.push(vedicCrossings, NodeCrossing.new(entryTime, signIndex, true))

if barstate.isfirst
	registerCrossing(1961, 6, 10, 16, 27, 43, "GMT-4", LEO)
	registerCrossing(1962, 12, 22, 23, 44, 13, "GMT-5", CANCER)
	registerCrossing(1964, 8, 25, 7, 2, 0, "GMT-4", GEMINI)
	registerCrossing(1966, 2, 19, 12, 2, 40, "GMT-5", TAURUS)
	registerCrossing(1967, 8, 19, 13, 39, 9, "GMT-4", ARIES)
	registerCrossing(1969, 4, 19, 2, 0, 15, "GMT-5", PISCES)
	registerCrossing(1970, 11, 2, 2, 54, 23, "GMT-5", AQUARIUS)
	registerCrossing(1972, 4, 27, 2, 40, 32, "GMT-5", CAPRICORN)
	registerCrossing(1973, 10, 26, 21, 14, 26, "GMT-4", SAGITTARIUS)
	registerCrossing(1975, 7, 9, 20, 25, 55, "GMT-4", SCORPIO)
	registerCrossing(1977, 1, 7, 12, 44, 24, "GMT-5", LIBRA)
	registerCrossing(1978, 7, 5, 6, 38, 35, "GMT-4", VIRGO)
	registerCrossing(1980, 1, 5, 12, 17, 33, "GMT-5", LEO)
	registerCrossing(1980, 1, 6, 18, 31, 45, "GMT-5", VIRGO, false)
	registerCrossing(1980, 1, 12, 14, 11, 48, "GMT-5", LEO)
	registerCrossing(1981, 9, 24, 5, 28, 1, "GMT-4", CANCER)
	registerCrossing(1983, 3, 15, 21, 36, 59, "GMT-5", GEMINI)
	registerCrossing(1984, 9, 11, 13, 33, 47, "GMT-4", TAURUS)
	registerCrossing(1986, 4, 6, 2, 21, 36, "GMT-5", ARIES)
	registerCrossing(1987, 12, 2, 0, 21, 20, "GMT-5", PISCES)
	registerCrossing(1989, 5, 22, 7, 39, 2, "GMT-4", AQUARIUS)
	registerCrossing(1990, 11, 18, 13, 48, 20, "GMT-5", CAPRICORN)
	registerCrossing(1992, 8, 1, 16, 42, 27, "GMT-4", SAGITTARIUS)
	registerCrossing(1994, 2, 1, 2, 20, 8, "GMT-5", SCORPIO)
	registerCrossing(1995, 7, 31, 7, 43, 38, "GMT-4", LIBRA)
	registerCrossing(1997, 1, 24, 19, 43, 7, "GMT-5", VIRGO)
	registerCrossing(1998, 10, 20, 2, 16, 42, "GMT-4", LEO)
	registerCrossing(2000, 4, 8, 21, 34, 6, "GMT-4", CANCER)
	registerCrossing(2001, 10, 12, 23, 1, 24, "GMT-4", GEMINI)
	registerCrossing(2003, 4, 13, 20, 56, 26, "GMT-4", TAURUS)
	registerCrossing(2004, 12, 26, 2, 47, 9, "GMT-5", ARIES)
	registerCrossing(2006, 6, 22, 5, 8, 26, "GMT-4", PISCES)
	registerCrossing(2007, 12, 14, 19, 25, 18, "GMT-5", AQUARIUS)
	registerCrossing(2009, 8, 21, 13, 47, 19, "GMT-4", CAPRICORN)
	registerCrossing(2011, 3, 3, 7, 0, 8, "GMT-5", SAGITTARIUS)
	registerCrossing(2012, 8, 29, 23, 5, 29, "GMT-4", SCORPIO)
	registerCrossing(2014, 2, 18, 9, 50, 20, "GMT-5", LIBRA)
	registerCrossing(2015, 11, 11, 20, 3, 5, "GMT-5", VIRGO)
	registerCrossing(2017, 5, 9, 14, 27, 32, "GMT-4", LEO)
	registerCrossing(2018, 11, 6, 13, 9, 4, "GMT-5", CANCER)
	registerCrossing(2020, 5, 5, 1, 48, 30, "GMT-4", GEMINI)
	registerCrossing(2022, 1, 18, 13, 49, 41, "GMT-5", TAURUS)
	registerCrossing(2023, 7, 17, 15, 59, 36, "GMT-4", ARIES)
	registerCrossing(2025, 1, 11, 18, 1, 31, "GMT-5", PISCES)
	registerCrossing(2026, 7, 26, 20, 46, 22, "GMT-4", AQUARIUS)
	registerCrossing(2028, 3, 26, 12, 2, 36, "GMT-4", CAPRICORN)
	registerCrossing(2029, 9, 23, 7, 47, 21, "GMT-4", SAGITTARIUS)
	registerCrossing(2031, 3, 20, 18, 30, 23, "GMT-5", SCORPIO)
	registerCrossing(2032, 12, 1, 23, 38, 51, "GMT-5", LIBRA)
	registerCrossing(2034, 6, 3, 12, 25, 9, "GMT-5", VIRGO)
	registerCrossing(2035, 11, 30, 2, 27, 19, "GMT-5", LEO)
	registerCrossing(2037, 5, 29, 5, 51, 59, "GMT-5", CANCER)
	registerCrossing(2039, 2, 9, 23, 7, 18, "GMT-5", GEMINI)
	registerCrossing(2040, 8, 11, 3, 47, 3, "GMT-5", TAURUS)
	registerCrossing(2042, 2, 4, 4, 33, 57, "GMT-5", ARIES)
	registerCrossing(2043, 8, 18, 10, 3, 8, "GMT-5", PISCES)
	registerCrossing(2045, 4, 18, 16, 45, 40, "GMT-5", AQUARIUS)
	registerCrossing(2046, 10, 18, 15, 52, 29, "GMT-5", CAPRICORN)
	registerCrossing(2048, 4, 12, 4, 17, 20, "GMT-5", SAGITTARIUS)
	registerCrossing(2049, 12, 14, 4, 40, 23, "GMT-5", SCORPIO)
	registerCrossing(2051, 6, 28, 5, 21, 46, "GMT-5", LIBRA)
	registerCrossing(2052, 12, 23, 12, 48, 8, "GMT-5", VIRGO)
	registerCrossing(2054, 6, 21, 12, 0, 54, "GMT-5", LEO)
	registerCrossing(2056, 3, 4, 2, 24, 12, "GMT-5", CANCER)
	registerCrossing(2057, 9, 11, 4, 15, 15, "GMT-5", GEMINI)
	registerCrossing(2059, 2, 28, 11, 52, 25, "GMT-5", TAURUS)
	// Precomputed Swiss Ephemeris 2.10.03 True Node events; Lahiri sidereal mode.
	registerSwissCrossing(1960, 5, 8, 23, 9, 16, LEO, true)
	registerSwissCrossing(1961, 11, 8, 19, 3, 6, CANCER, true)
	registerSwissCrossing(1963, 5, 4, 18, 39, 5, GEMINI, true)
	registerSwissCrossing(1964, 11, 15, 20, 46, 6, TAURUS, true)
	registerSwissCrossing(1966, 7, 18, 14, 33, 44, ARIES, true)
	registerSwissCrossing(1968, 1, 14, 12, 46, 30, PISCES, true)
	registerSwissCrossing(1969, 7, 11, 21, 19, 43, AQUARIUS, true)
	registerSwissCrossing(1971, 3, 13, 7, 0, 46, CAPRICORN, true)
	registerSwissCrossing(1972, 9, 24, 17, 5, 7, SAGITTARIUS, true)
	registerSwissCrossing(1974, 3, 21, 6, 13, 54, SCORPIO, true)
	registerSwissCrossing(1975, 9, 18, 22, 58, 15, LIBRA, true)
	registerSwissCrossing(1977, 5, 24, 1, 20, 43, VIRGO, true)
	registerSwissCrossing(1978, 12, 1, 8, 51, 0, LEO, true)
	registerSwissCrossing(1980, 5, 27, 20, 1, 54, CANCER, true)
	registerSwissCrossing(1981, 11, 25, 14, 3, 0, GEMINI, true)
	registerSwissCrossing(1983, 8, 10, 22, 54, 13, TAURUS, true)
	registerSwissCrossing(1985, 2, 4, 23, 49, 34, ARIES, true)
	registerSwissCrossing(1986, 8, 4, 19, 52, 30, PISCES, true)
	registerSwissCrossing(1988, 2, 2, 2, 39, 15, AQUARIUS, true)
	registerSwissCrossing(1989, 10, 18, 11, 1, 9, CAPRICORN, true)
	registerSwissCrossing(1991, 4, 12, 22, 26, 39, SAGITTARIUS, true)
	registerSwissCrossing(1992, 10, 11, 3, 40, 13, SCORPIO, true)
	registerSwissCrossing(1994, 5, 27, 12, 16, 52, LIBRA, true)
	registerSwissCrossing(1994, 6, 6, 0, 20, 41, SCORPIO, false)
	registerSwissCrossing(1994, 6, 8, 11, 51, 23, LIBRA, true)
	registerSwissCrossing(1995, 12, 24, 14, 19, 7, VIRGO, true)
	registerSwissCrossing(1997, 6, 19, 22, 10, 58, LEO, true)
	registerSwissCrossing(1998, 12, 17, 20, 26, 46, CANCER, true)
	registerSwissCrossing(2000, 8, 30, 14, 0, 33, GEMINI, true)
	registerSwissCrossing(2002, 2, 28, 7, 9, 38, TAURUS, true)
	registerSwissCrossing(2003, 8, 28, 1, 43, 11, ARIES, true)
	registerSwissCrossing(2005, 2, 22, 13, 54, 17, PISCES, true)
	registerSwissCrossing(2006, 11, 8, 16, 2, 40, AQUARIUS, true)
	registerSwissCrossing(2008, 5, 5, 15, 3, 42, CAPRICORN, true)
	registerSwissCrossing(2009, 11, 2, 22, 34, 23, SAGITTARIUS, true)
	registerSwissCrossing(2011, 5, 3, 2, 10, 23, SCORPIO, true)
	registerSwissCrossing(2013, 1, 14, 12, 34, 53, LIBRA, true)
	registerSwissCrossing(2014, 7, 13, 15, 36, 24, VIRGO, true)
	registerSwissCrossing(2016, 1, 9, 4, 54, 22, LEO, true)
	registerSwissCrossing(2017, 9, 8, 23, 55, 40, CANCER, true)
	registerSwissCrossing(2019, 3, 23, 7, 6, 55, GEMINI, true)
	registerSwissCrossing(2020, 9, 19, 15, 52, 34, TAURUS, true)
	registerSwissCrossing(2022, 3, 17, 0, 50, 32, ARIES, true)
	registerSwissCrossing(2023, 11, 28, 20, 58, 36, PISCES, true)
	registerSwissCrossing(2025, 5, 29, 18, 47, 37, AQUARIUS, true)
	registerSwissCrossing(2026, 11, 25, 12, 16, 7, CAPRICORN, true)
	registerSwissCrossing(2028, 5, 24, 9, 37, 42, SAGITTARIUS, true)
	registerSwissCrossing(2030, 2, 4, 7, 38, 19, SCORPIO, true)
	registerSwissCrossing(2031, 8, 9, 7, 2, 11, LIBRA, true)
	registerSwissCrossing(2033, 1, 30, 2, 4, 25, VIRGO, true)
	registerSwissCrossing(2034, 8, 12, 17, 3, 21, LEO, true)
	registerSwissCrossing(2036, 4, 12, 23, 13, 21, CANCER, true)
	registerSwissCrossing(2037, 10, 19, 13, 55, 28, GEMINI, true)
	registerSwissCrossing(2039, 4, 7, 21, 59, 43, TAURUS, true)
	registerSwissCrossing(2040, 12, 9, 14, 59, 5, ARIES, true)
	registerSwissCrossing(2040, 12, 12, 10, 2, 56, TAURUS, false)
	registerSwissCrossing(2040, 12, 18, 5, 39, 41, ARIES, true)
	registerSwissCrossing(2042, 6, 21, 11, 50, 24, PISCES, true)
	registerSwissCrossing(2043, 12, 19, 10, 36, 11, AQUARIUS, true)
	registerSwissCrossing(2045, 6, 15, 5, 43, 27, CAPRICORN, true)
	registerSwissCrossing(2047, 2, 25, 22, 17, 18, SAGITTARIUS, true)
	registerSwissCrossing(2048, 9, 3, 22, 37, 25, SCORPIO, true)
	registerSwissCrossing(2050, 2, 22, 4, 16, 26, LIBRA, true)
	registerSwissCrossing(2051, 9, 1, 3, 7, 14, VIRGO, true)
	registerSwissCrossing(2053, 5, 5, 7, 8, 47, LEO, true)
	registerSwissCrossing(2054, 11, 11, 18, 59, 50, CANCER, true)
	registerSwissCrossing(2056, 4, 30, 1, 39, 52, GEMINI, true)
	registerSwissCrossing(2057, 11, 10, 0, 35, 32, TAURUS, true)
	registerSwissCrossing(2059, 7, 14, 12, 56, 2, ARIES, true)
	if vedicMode
		buildVedicCrossings()

array<NodeCrossing> activeCrossings = swissTrueNodeMode ? swissCrossings : vedicMode ? vedicCrossings : crossings
array<bool> visibleSigns = array.from(ariesOn, taurusOn, geminiOn, cancerOn, leoOn, virgoOn, libraOn, scorpioOn, sagittariusOn, capricornOn, aquariusOn, piscesOn)
array<color> palette = array.from(ariesInk, taurusInk, geminiInk, cancerInk, leoInk, virgoInk, libraInk, scorpioInk, sagittariusInk, capricornInk, aquariusInk, piscesInk)
array<string> signNames = array.from("Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces")
int ascendantIndex = array.indexof(signNames, referenceAscendant)
bool housesAvailable = (vedicMode or swissTrueNodeMode) and ascendantIndex >= 0

color regionColor = na
int crossingCount = array.size(activeCrossings)
if crossingCount > 1
	for crossingIndex = 0 to crossingCount - 2
		NodeCrossing regionCrossing = array.get(activeCrossings, crossingIndex)
		NodeCrossing nextCrossing = array.get(activeCrossings, crossingIndex + 1)
		if time >= regionCrossing.instant and time < nextCrossing.instant and array.get(visibleSigns, regionCrossing.destination)
			regionColor := color.new(array.get(palette, regionCrossing.destination), 100 - regionOpacity)
bgcolor(regionColor, title = "Regions", editable = true)

if barstate.islast
	if enabled and array.size(strokes) == 0
		for crossing in activeCrossings
			bool withinCoverage = not (vedicMode or swissTrueNodeMode) or (crossing.instant >= VEDIC_START and crossing.instant < VEDIC_END)
			if withinCoverage and array.get(visibleSigns, crossing.destination)
				float upperAnchor = high > low ? high : low + syminfo.mintick
				line stroke = line.new(crossing.instant, low, crossing.instant, upperAnchor, xloc = xloc.bar_time, extend = extend.both, color = array.get(palette, crossing.destination), style = line.style_solid, width = 2)
				array.push(strokes, stroke)
				if housesAvailable or swissTrueNodeMode
					int rahuHouse = wholeSignHouse(crossing.destination, ascendantIndex)
					int oppositeSign = (crossing.destination + 6) % 12
					int ketuHouse = wholeSignHouse(oppositeSign, ascendantIndex)
					string houseText = housesAvailable ? "Rahu H" + str.tostring(rahuHouse) : array.get(signNames, crossing.destination)
					string details = "Rahu enters " + array.get(signNames, crossing.destination)
					if housesAvailable
						details += " / Whole-Sign house " + str.tostring(rahuHouse)
						details += "\nOpposite Ketu: " + array.get(signNames, oppositeSign) + " / house " + str.tostring(ketuHouse)
						details += "\nReference Ascendant: " + referenceAscendant
					details += "\n" + (crossing.backward ? "Retrograde crossing" : "Direct crossing")
					details += "\nEvent UTC: " + str.format_time(crossing.instant, "yyyy-MM-dd HH:mm:ss", "UTC")
					if swissTrueNodeMode
						details += "\nPrecomputed Swiss Ephemeris 2.10.03 True Node; Lahiri sidereal mode."
						details += "\nApparent geocentric position; nutation included; no Pine ephemeris calculation."
						details += "\nHistorical and far-future labels may follow the library's UT1 fallback."
					else
						details += "\nEstimated constant-speed Whole-Sign dataset, calibrated from PDF Capricorn cycles."
						details += "\nAnchor convention: November 26, 2026 at 00:00 UTC, entering Capricorn."
						details += "\nNot verified astronomical or sidereal ingress times."
					label.new(crossing.instant, upperAnchor, houseText, xloc = xloc.bar_time, yloc = yloc.price, color = array.get(palette, crossing.destination), style = label.style_label_down, textcolor = color.white, size = size.small, tooltip = details)
	if enabled and (vedicMode or swissTrueNodeMode) and not housesAvailable
		table.cell(houseNotice, 0, 0, "Whole-Sign houses: reference Ascendant not set.", text_color = color.white, bgcolor = color.new(color.red, 15), text_size = size.small)
	else
		table.clear(houseNotice, 0, 0)
	bool repeatedInk = false
	for firstIndex = 0 to 10
		for secondIndex = firstIndex + 1 to 11
			repeatedInk := repeatedInk or array.get(palette, firstIndex) == array.get(palette, secondIndex)
	if enabled and repeatedInk
		table.cell(paletteNotice, 0, 0, "North Node: sign colors must be distinct.", text_color = color.white, bgcolor = color.new(color.red, 15), text_size = size.small)
	else
		table.clear(paletteNotice, 0, 0)
````
