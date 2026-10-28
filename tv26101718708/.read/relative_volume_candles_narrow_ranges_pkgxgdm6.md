# Relative Volume Candles & Narrow Ranges

- url: https://www.tradingview.com/script/Pkgxgdm6-Relative-Volume-Candles-Narrow-Ranges/
- type: indicator
- pine_id: PUB;dea659769477440d9a014ed252232f39
- version: 1.0

## Description

Relative Volume Candles & Narrow Ranges brings volume and price contraction directly onto the chart. Five candle color-levels reveal volume dry-ups, normal participation, and expanding activity, while selective dots identify unusually narrow ranges. Together, they help swing traders assess consolidations, pullbacks, and price moves at a glance.

Low-volume and narrow-range clusters can be valuable areas to monitor because a tightening consolidation or quiet pullback may precede a sharp price expansion. 

[b]HOW IT WORKS[/b]

Relative Volume Candles & Narrow Ranges makes it easy to see how much trading activity supports each price candle. Rather than requiring a separate volume pane, the script translates relative volume into five bullish and bearish color shades.

These five levels distinguish volume dry-up from normal volume and explosive volume. On a dark chart, low-volume candles use the lightest shades. On a light chart, they use the darkest shades (see below). This makes quiet, low-participation candles easier to find. 

[image]https://www.tradingview.com/x/z4wCYjdx/[/image]

Dots above candles identify narrow ranges. Their frequency adapts to the symbol’s recent range behavior, and users can make these dots more or less selective or disable them entirely.

The script was designed primarily for equities on the daily timeframe, with swing traders, position traders, and active investors in mind. You may find the same volume and range relationships helpful on other markets and timeframes.

[b]FEATURES[/b]

The indicator combines relative-volume candles with selective narrow-range markers in one chart-level view.

[list]
[*] [b]Five relative-volume levels:[/b]Separates low volume from normal volume and more explosive volume.
[*] [b]Bullish and bearish palettes:[/b] Our defaults retain normal price colors while showing relative-volume levels in different shades, but you can choose more distinctive coloring as well.
[*] [b]Narrow-range dots:[/b] Highlights candles with particularly compressed price ranges.
[*] [b]Adjustable dot frequency:[/b] Controls how selective the narrow-range markers are, from Very High to Very Low, with an option to disable them.
[*] [b]Dark and Light color schemes:[/b] Reverses the shade order so volume dry-ups stand out against either background.
[*] [b]Customizable appearance:[/b] Includes editable candle colors, dot color, dot size, and brightness adjustments.
[/list]

[b]USE CASES[/b]

[b]Finding quiet consolidations[/b]
Low-volume colors reveal where participation is drying up. Narrow-range dots help locate the tightest candles within the consolidation. Together, they can draw attention to areas where price and volume are becoming increasingly quiet. In our humble opinion, this is where our script shines.

[b]Assessing pullbacks[/b]
A pullback occurring on declining relative volume can carry a different character from one accompanied by expanding participation. Narrow ranges can provide additional context when the pullback begins to stabilize or tighten.

[b]Monitoring potential entries[/b]
Some of the strongest price expansions begin after a quiet cluster of low-volume, narrow-range candles. The indicator helps make those conditions visible, allowing traders to monitor them alongside price structure, support and resistance, and their own entry criteria.

[b]Evaluating price moves[/b]
Expanded volume colors show when participation is increasing. This can help traders assess whether a breakout, rally, decline, or reversal attempt is attracting noticeably greater activity.

[b]SETTINGS[/b]

[b]Relative Volume[/b]
[list]
[*] [b]RVOL Lookback:[/b] Number of recent bars used to calculate average volume. The current bar is excluded.
[*] [b]Profound Dry-Up Below:[/b] Sets the upper boundary for the lowest relative-volume level. These candles use the lightest color on dark charts and the darkest color on light charts.
[*] [b]Constructive Dry-Up Below:[/b] Sets the upper boundary for the second-lowest relative-volume level. These candles use the second-lightest color on dark charts and the second-darkest color on light charts.
[*] [b]Expanded Volume Above:[/b] Sets the point above which volume is treated as expanded. These candles use the second-darkest color on dark charts and the second-lightest color on light charts.
[*] [b]Telling Volume Above:[/b] Sets the point above which volume is treated as telling. These candles use the darkest color on dark charts and the lightest color on light charts.
[/list]

Volume between the Constructive Dry-Up and Expanded Volume thresholds is treated as normal.

[b]Range Context[/b]
[list]
[*] [b]ADR Length:[/b] Number of recent bars used to calculate the average price range. The current bar is excluded.
[*] [b]Range Dot Frequency:[/b] Selects the narrowest ranges relative to the symbol’s recent history. Lower frequencies produce fewer, more exceptional dots.
[*] [b]Range Dot Size:[/b] Sets the size of the narrow-range dots to Tiny, Small, or Normal.
[*] [b]Range Dot Color:[/b] Sets the color of the narrow-range dots.
[/list]

[b]Main Color Settings[/b]
[list]
[*] [b]Color Scheme:[/b] Selects the palette order designed for either a Dark or Light chart background.
[*] [b]Dark Scheme Dimming (%):[/b] Makes the Dark scheme darker with positive values or lighter with negative values.
[*] [b]Light Scheme Dimming (%):[/b] Makes the Light scheme darker with positive values or lighter with negative values.
[/list]

[b]Relative Volume Colors (Light to Dark)[/b]

This section contains five editable bullish and bearish color pairs, ordered from lightest to darkest. The selected color scheme determines how these shades correspond to the five relative-volume levels.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © buchener

//@version=6
indicator("Relative Volume Candles & Narrow Ranges", shorttitle="Volume Candles & Range Dots", overlay=true, behind_chart=false)

// Inputs
RelativeVolumeGroup_c_str = "Relative Volume"
RangeContextGroup_c_str = "Range Context"
MainColorSettingsGroup_c_str = "Main Color Settings"
RelativeVolumeColorsGroup_c_str = "Relative Volume Colors (Light to Dark)"

RVOLLookback_i_int = input.int( 50, "RVOL Lookback", minval=1, tooltip="Number of recent bars used to calculate average volume. The current bar is excluded.", group=RelativeVolumeGroup_c_str)
ProfoundDryUpBelow_i_fl = input.float( 0.60, "Profound Dry-Up Below", minval=0.0, step=0.05, tooltip="RVOL below this level uses the lightest color in Dark mode and the darkest color in Light mode.", group=RelativeVolumeGroup_c_str)
ConstructiveDryUpBelow_i_fl = input.float( 0.80, "Constructive Dry-Up Below", minval=0.0, step=0.05, tooltip="RVOL below this level uses the second-lightest color in Dark mode and the second-darkest color in Light mode.", group=RelativeVolumeGroup_c_str)
ExpandedVolumeAbove_i_fl = input.float( 1.30, "Expanded Volume Above", minval=0.0, step=0.05, tooltip="RVOL above this level uses the second-darkest color in Dark mode and the second-lightest color in Light mode.", group=RelativeVolumeGroup_c_str)
TellingVolumeAbove_i_fl = input.float( 2.00, "Telling Volume Above", minval=0.0, step=0.05, tooltip="RVOL above this level uses the darkest color in Dark mode and the lightest color in Light mode.", group=RelativeVolumeGroup_c_str)

ADRLength_i_int = input.int( 20, "ADR Length", minval=1, tooltip="Number of recent bars used to calculate the average high-low range. The current bar is excluded.", group=RangeContextGroup_c_str)
RangeDotFrequency_i_str = input.string( "Medium", "Range Dot Frequency", options=["Very High", "High", "Medium", "Low", "Very Low", "None"], tooltip="Selects the narrowest ranges relative to the symbol's recent history. Lower frequencies produce fewer, more exceptional dots.", group=RangeContextGroup_c_str)
RangeDotSize_i_str = input.string( "Tiny", "Range Dot Size", options=["Tiny", "Small", "Normal"], group=RangeContextGroup_c_str)
RangeDotColor_i_cl = input.color( color.rgb(41, 98, 255), "Range Dot Color", group=RangeContextGroup_c_str)

ColorScheme_i_str = input.string( "Dark", "Color Scheme", options=["Dark", "Light"], tooltip="Dark makes low-volume candles lighter. Light reverses the palette and makes low-volume candles darker.", group=MainColorSettingsGroup_c_str)
DarkSchemeDimming_i_fl = input.float( 12.0, "Dark Scheme Dimming (%)", minval=-30.0, maxval=30.0, step=1.0, tooltip="Positive values darken the Dark scheme; negative values lighten it.", group=MainColorSettingsGroup_c_str)
LightSchemeDimming_i_fl = input.float( 0.0, "Light Scheme Dimming (%)", minval=-30.0, maxval=30.0, step=1.0, tooltip="Positive values darken the Light scheme; negative values lighten it.", group=MainColorSettingsGroup_c_str)

LightestBullishColor_i_cl = input.color( color.rgb(165, 214, 167), "Bullish / Bearish", inline="Lightest", group=RelativeVolumeColorsGroup_c_str)
LightestBearishColor_i_cl = input.color( color.rgb(250, 161, 164), "", inline="Lightest", group=RelativeVolumeColorsGroup_c_str)
LightBullishColor_i_cl = input.color( color.rgb(129, 199, 132), "Bullish / Bearish", inline="Light", group=RelativeVolumeColorsGroup_c_str)
LightBearishColor_i_cl = input.color( color.rgb(247, 124, 128), "", inline="Light", group=RelativeVolumeColorsGroup_c_str)
MiddleBullishColor_i_cl = input.color( color.rgb(102, 187, 106), "Bullish / Bearish", inline="Middle", group=RelativeVolumeColorsGroup_c_str)
MiddleBearishColor_i_cl = input.color( color.rgb(247, 82, 95), "", inline="Middle", group=RelativeVolumeColorsGroup_c_str)
DarkBullishColor_i_cl = input.color( color.rgb(56, 142, 60), "Bullish / Bearish", inline="Dark", group=RelativeVolumeColorsGroup_c_str)
DarkBearishColor_i_cl = input.color( color.rgb(178, 40, 51), "", inline="Dark", group=RelativeVolumeColorsGroup_c_str)
DarkestBullishColor_i_cl = input.color( color.rgb(27, 94, 32), "Bullish / Bearish", inline="Darkest", group=RelativeVolumeColorsGroup_c_str)
DarkestBearishColor_i_cl = input.color( color.rgb(128, 25, 34), "", inline="Darkest", group=RelativeVolumeColorsGroup_c_str)


// Calculations
InitialContractedRatio_c_fl = 0.60
CalibrationLookback_c_int = 252
QuarterCalibrationLookback_c_int = 63
HalfCalibrationLookback_c_int = 126

// Scaling all RGB channels preserves the palette while adapting it to alternative backgrounds.
_fAdjustBrightness(BaseColor_cl, DimmingPct_fl) =>
    BrightnessFactor_fl = 1.0 - DimmingPct_fl / 100.0
    RedChannel_int = int(math.max(0, math.min(255, math.round(color.r(BaseColor_cl) * BrightnessFactor_fl))))
    GreenChannel_int = int(math.max(0, math.min(255, math.round(color.g(BaseColor_cl) * BrightnessFactor_fl))))
    BlueChannel_int = int(math.max(0, math.min(255, math.round(color.b(BaseColor_cl) * BrightnessFactor_fl))))

    color.rgb(RedChannel_int, GreenChannel_int, BlueChannel_int)

DarkScheme_bl = ColorScheme_i_str == "Dark"
ActiveDimmingPct_fl = DarkScheme_bl ? DarkSchemeDimming_i_fl : LightSchemeDimming_i_fl

ProfoundBullishBaseColor_cl = DarkScheme_bl ? LightestBullishColor_i_cl : DarkestBullishColor_i_cl
ConstructiveBullishBaseColor_cl = DarkScheme_bl ? LightBullishColor_i_cl : DarkBullishColor_i_cl
NormalBullishBaseColor_cl = MiddleBullishColor_i_cl
ExpandedBullishBaseColor_cl = DarkScheme_bl ? DarkBullishColor_i_cl : LightBullishColor_i_cl
TellingBullishBaseColor_cl = DarkScheme_bl ? DarkestBullishColor_i_cl : LightestBullishColor_i_cl

ProfoundBearishBaseColor_cl = DarkScheme_bl ? LightestBearishColor_i_cl : DarkestBearishColor_i_cl
ConstructiveBearishBaseColor_cl = DarkScheme_bl ? LightBearishColor_i_cl : DarkBearishColor_i_cl
NormalBearishBaseColor_cl = MiddleBearishColor_i_cl
ExpandedBearishBaseColor_cl = DarkScheme_bl ? DarkBearishColor_i_cl : LightBearishColor_i_cl
TellingBearishBaseColor_cl = DarkScheme_bl ? DarkestBearishColor_i_cl : LightestBearishColor_i_cl

ProfoundBullishColor_cl = _fAdjustBrightness(ProfoundBullishBaseColor_cl, ActiveDimmingPct_fl)
ConstructiveBullishColor_cl = _fAdjustBrightness(ConstructiveBullishBaseColor_cl, ActiveDimmingPct_fl)
NormalBullishColor_cl = _fAdjustBrightness(NormalBullishBaseColor_cl, ActiveDimmingPct_fl)
ExpandedBullishColor_cl = _fAdjustBrightness(ExpandedBullishBaseColor_cl, ActiveDimmingPct_fl)
TellingBullishColor_cl = _fAdjustBrightness(TellingBullishBaseColor_cl, ActiveDimmingPct_fl)

ProfoundBearishColor_cl = _fAdjustBrightness(ProfoundBearishBaseColor_cl, ActiveDimmingPct_fl)
ConstructiveBearishColor_cl = _fAdjustBrightness(ConstructiveBearishBaseColor_cl, ActiveDimmingPct_fl)
NormalBearishColor_cl = _fAdjustBrightness(NormalBearishBaseColor_cl, ActiveDimmingPct_fl)
ExpandedBearishColor_cl = _fAdjustBrightness(ExpandedBearishBaseColor_cl, ActiveDimmingPct_fl)
TellingBearishColor_cl = _fAdjustBrightness(TellingBearishBaseColor_cl, ActiveDimmingPct_fl)

RangeDotColor_cl = _fAdjustBrightness(RangeDotColor_i_cl, ActiveDimmingPct_fl)

AverageVolume_fl = ta.sma(volume[1], RVOLLookback_i_int)
ValidVolumeData_bl = not na(volume) and not na(AverageVolume_fl) and AverageVolume_fl > 0
RVOL_fl = ValidVolumeData_bl ? volume / AverageVolume_fl : na

ProfoundDryUp_bl = ValidVolumeData_bl and RVOL_fl < ProfoundDryUpBelow_i_fl
ConstructiveDryUp_bl = ValidVolumeData_bl and RVOL_fl >= ProfoundDryUpBelow_i_fl and RVOL_fl < ConstructiveDryUpBelow_i_fl
ExpandedVolume_bl = ValidVolumeData_bl and RVOL_fl > ExpandedVolumeAbove_i_fl and RVOL_fl <= TellingVolumeAbove_i_fl
TellingVolume_bl = ValidVolumeData_bl and RVOL_fl > TellingVolumeAbove_i_fl

PreviousClose_fl = nz(close[1], open)
BullishCandle_bl = close > open or (close == open and close >= PreviousClose_fl)

BullishCandleColor_cl = ProfoundDryUp_bl ? ProfoundBullishColor_cl : ConstructiveDryUp_bl ? ConstructiveBullishColor_cl : TellingVolume_bl ? TellingBullishColor_cl : ExpandedVolume_bl ? ExpandedBullishColor_cl : NormalBullishColor_cl
BearishCandleColor_cl = ProfoundDryUp_bl ? ProfoundBearishColor_cl : ConstructiveDryUp_bl ? ConstructiveBearishColor_cl : TellingVolume_bl ? TellingBearishColor_cl : ExpandedVolume_bl ? ExpandedBearishColor_cl : NormalBearishColor_cl
CandleColor_cl = BullishCandle_bl ? BullishCandleColor_cl : BearishCandleColor_cl

CurrentRange_fl = high - low
AverageRange_fl = ta.sma((high - low)[1], ADRLength_i_int)
ValidRangeData_bl = not na(CurrentRange_fl) and not na(AverageRange_fl) and AverageRange_fl > 0
RangeRatio_fl = ValidRangeData_bl ? CurrentRange_fl / AverageRange_fl : na

RangeDotsEnabled_bl = RangeDotFrequency_i_str != "None"
ContractedPercentile_fl = RangeDotFrequency_i_str == "Very High" ? 27.0 : RangeDotFrequency_i_str == "High" ? 14.0 : RangeDotFrequency_i_str == "Medium" ? 9.0 : RangeDotFrequency_i_str == "Low" ? 6.0 : 3.0

QuarterContractedThreshold_fl = ta.percentile_nearest_rank( RangeRatio_fl, QuarterCalibrationLookback_c_int, ContractedPercentile_fl)
HalfContractedThreshold_fl = ta.percentile_nearest_rank( RangeRatio_fl, HalfCalibrationLookback_c_int, ContractedPercentile_fl)
FullContractedThreshold_fl = ta.percentile_nearest_rank( RangeRatio_fl, CalibrationLookback_c_int, ContractedPercentile_fl)

var AvailableRangeBars_int = 0
AvailableRangeBars_int := ValidRangeData_bl ? AvailableRangeBars_int + 1 : 0

QuarterCalibrationAvailable_bl = AvailableRangeBars_int >= QuarterCalibrationLookback_c_int
HalfCalibrationAvailable_bl = AvailableRangeBars_int >= HalfCalibrationLookback_c_int
FullCalibrationAvailable_bl = AvailableRangeBars_int >= CalibrationLookback_c_int

ActiveContractedThreshold_fl = FullCalibrationAvailable_bl ? FullContractedThreshold_fl : HalfCalibrationAvailable_bl ? HalfContractedThreshold_fl : QuarterCalibrationAvailable_bl ? QuarterContractedThreshold_fl : na
ContractedCalibrationPass_bl = not QuarterCalibrationAvailable_bl or (not na(ActiveContractedThreshold_fl) and RangeRatio_fl <= ActiveContractedThreshold_fl)

InitialContractedRange_bl = not QuarterCalibrationAvailable_bl and RangeRatio_fl < InitialContractedRatio_c_fl
CalibratedContractedRange_bl = QuarterCalibrationAvailable_bl and not na(ActiveContractedThreshold_fl) and RangeRatio_fl <= ActiveContractedThreshold_fl
ContractedRange_bl = RangeDotsEnabled_bl and ValidRangeData_bl and (InitialContractedRange_bl or CalibratedContractedRange_bl)

// Visuals
barcolor(CandleColor_cl)

plotcandle( open, high, low, close, title="Relative Volume Candles", color=CandleColor_cl, wickcolor=CandleColor_cl, bordercolor=CandleColor_cl, editable=false)
plotshape( ContractedRange_bl and RangeDotSize_i_str == "Tiny", title="Contracted Range — Tiny", style=shape.circle, location=location.abovebar, color=RangeDotColor_cl, size=size.tiny, editable=false)
plotshape( ContractedRange_bl and RangeDotSize_i_str == "Small", title="Contracted Range — Small", style=shape.circle, location=location.abovebar, color=RangeDotColor_cl, size=size.small, editable=false)
plotshape( ContractedRange_bl and RangeDotSize_i_str == "Normal", title="Contracted Range — Normal", style=shape.circle, location=location.abovebar, color=RangeDotColor_cl, size=size.normal, editable=false)
````
