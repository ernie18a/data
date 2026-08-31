<!-- tradingview-pine-id: PUB;b364967d3305413da25281b5bb09bcff -->
<!-- tradingviewscripts-format: 1 -->
# Intraday Intensity Modes

Source: https://www.tradingview.com/script/S7HGang6-Intraday-Intensity-Modes/

## Description

Intraday Intensity Index was created by David Bostian and its use was later featured by John Bollinger in his book "Bollinger on Bollinger Bands". It is categorically a volume indicator and considered to be a useful tool for analyzing supply and demand dynamics in the market. By measuring the level of buying and selling pressure within a given trading session it attempts to provide insights into the strength of market participants' interest and their aggressiveness in executing trades throughout the day. It can be used in conjunction with Bollinger Bands® or other envelope type indicators as a complimentary indicator to aid in trying to identify potential turning points or trends.

Intraday intensity is calculated based upon the relationship between the price change and the volume of shares traded during each daily interval. It aims to capture the level of buying or selling activity relative to the overall volume. A high intraday intensity value suggests a higher level of buying or selling pressure, indicating a more active and potentially volatile market. Conversely, a low intraday intensity value indicates less pronounced trading activity and a potentially quieter market. Overall, intraday intensity provides a concise description of the intensity of trading activity during a particular trading session, giving traders an additional perspective on market dynamics. Note that because the calculation uses volume this indicator will only work on symbols where volume is available. 

While there are pre-existing versions within community scripts, none were found to have applied the calculations necessary for the various modes that are presented within this version, which are believed to be operating in the manner originally intended when first described by Bostian and again later by Bollinger. When operating in default modes on daily or lower chart timeframes the logic used within this script tracks the intraday high, low, close and volume for the day with each progressing intraday bar.

The BB indicator was included on the top main chart to help illustrate example usage as described below. The Intraday Intensity Modes indicator is pictured operating in three different modes beneath the main chart:

• The top pane beneath the main chart shows the indicator operating as a normalized 21 day II% oscillator. A potential use while in this mode would be to look for positive values as potential confirmation of strength when price tags the upper or lower Bollinger bands, and to look for negative values as potential confirmation of weakness when price tags the upper or lower Bollinger bands.

• The middle pane shows the indicator operating as an "open ended" cumulative sum of II. A potential use while in this mode would be to look for convergence or divergence of trend when price is making new highs or lows, or while price is walking the upper or lower Bollinger bands.

• The bottom pane shows the indicator operating in standard III mode, which provides independent values per session.

Indicator Settings:Inputs tab:

Osc Length: Set to 1 disables oscillation, values greater than 1 enables oscillation for II% (Intraday Intensity percent) mode.

Tootip: Hover mouse over (i) to show recommended example Settings for various modes.

Cumulative: When enabled values are cumulatively summed for the entire chart and indicator operates in II mode.

Normalized: When enabled a rolling window of Osc Length values are summed and normalized to the rolling window's volume.

Intrabar: When enabled price range and volume are evaluated for intensity per bar instead of per day which is a departure from the original
concept. Whenever this setting is enabled the indicator should be regarded as operating in an experimental mode.

Colors For Up Down: Sets the plot colors used, may be overridden in Settings:Style tab.

Styles / Width: Sets the plot style and width used, may be overridden in Settings:Style tab.

This indicator is designed to work with any chart timeframe, with the understanding that when used on timeframes higher than daily the indicator becomes "IntraPeriod" intensity, for example on weekly bars it would be "IntraWeek" intensity. On Daily or lower timeframes the indicator operates as "IntraDay" intensity and is being updated on each bar as each day progresses. If the experimental setting Intrabar is enabled then the indicator operates as "IntraBar" intensity and is no longer constrained to daily or higher evaluations, for example with Intrabar enabled on a 4H timeframe the indicator would operate as "Intra4H" intensity.

NOTICE: This is an example script and not meant to be used as an actual strategy. By using this script or any portion thereof, you acknowledge that you have read and understood that this is for research purposes only and I am not responsible for any financial losses you may incur by using this script!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © allanster on TradingView

//@version=5
// Original concept by David Bostian, with variations featured in "Bollinger on Bollinger Bands".
indicator("Intraday Intensity Modes", 'Intensity')

toolTipA  = 'III (Individual):\nOsc Length 1\n[   ] Cumulative (Off)\n[   ] Normalized (Off)\n[   ] Inverse Volu' +
 'me (Off)\n[   ] Show Levels (Off)\n\n'
toolTipB  = 'II  (Cumulative):\nOsc Length 1\n[✓] Cumulative (On)\n[   ] Normalized (Off)\n[   ] Inverse Volume ' +
 '(Off)\n[   ] Show Levels (Off)\n\n'
toolTipC  = 'II% (Oscillator):\nOsc Length 21\n[   ] Cumulative (Off)\n[✓] Normalized (On)\n[   ] Inverse Volume' +
 ' (Off)\n[✓] Show Levels (On)'
toolTipD  = 'Enables examination of intensity per bar instead of per day, this is a departure from the original ' +
 'concept. Whenever this setting is enabled the indicator should be regarded as operating in an experimental mode.'
toolTipV  = '[   ] Inverse Volume (Off):\n\n   (2 * close - high - low) * volume\n ────────────────\n           ' +
 '         high - low\n\n\n[✓] Inverse Volume (On):\n\n            2 * close - high - low\n          ───────────' +
 '\n            (high - low) * volume'

i_length  = input.int  (21,         'Osc Length',     minval = 1, tooltip = toolTipA + toolTipB + toolTipC)
i_cumltv  = input.bool (false,      'Cumulative')
i_normal  = input.bool (true,       'Normalized')
i_candle  = input.bool (false,      'Intrabar',                   tooltip = toolTipD)
i_invert  = input.bool (false,      'Inverse Volume',             tooltip = toolTipV)
i_colrUp  = input.color(#00BCD4,  'Colors For Up',                                             inline = 'a')
i_colrDn  = input.color(#E040FB,  'Down',                                                      inline = 'a')
i_styles  = input.string('Columns', 'Style & Width', options = ['Columns', 'Histogram', 'Line'], inline = 'b')
i_widths  = input.int  (1,          '',               minval = 1,                                inline = 'b')
i_shoLvl  = input.bool (true,       '',                                                          inline = 'c')
i_levelH  = input.int  (25,         'Show Levels Above',                                         inline = 'c')
i_levelL  = input.int  (-25,        'Below',                                                     inline = 'c')

id_cum(source) => // perform cumulative sum once per day when using realtime intraday source values
    var carrySum  = float(na)
    var dailySum  = float(na)
    if not timeframe.isintraday
        carrySum := ta.cum(nz(source))
    else
        dailySum := timeframe.change('D') ? nz(carrySum) : nz(dailySum)
        carrySum := nz(dailySum) + nz(source)

altSum(source, length) => normal = math.sum(nz(source), length) // treat na as 0 and return sum

var idRangeH = float(na)
var idRangeL = float(na)
var idVolume = float(na)
startDay  = timeframe.change('D')
idRangeH := not timeframe.isintraday or startDay ?   high : high > nz(idRangeH)        ? high : idRangeH // intraday high
idRangeL := not timeframe.isintraday or startDay ?    low :  low < nz(idRangeL, 10e99) ?  low : idRangeL // intraday low
idVolume := not timeframe.isintraday or startDay ? volume : nz(idVolume) + volume                        // intraday volume
idUseVol  = i_invert ? 1 / idVolume : idVolume
iiiValue  = nz(((2 * close - idRangeH - idRangeL) / (idRangeH - idRangeL)) * idUseVol)                   // intraday intensity

use_iii   = i_invert ?
 (2 * close - high - low) / ((high - low) * volume) :
 ((2 * close - high - low) / (high - low)) * volume

usePrcnt = i_normal ? 100 : 1

iiSource = 
 usePrcnt * altSum(i_cumltv ? i_candle ? ta.cum(nz(use_iii)) : id_cum(iiiValue) : i_candle ? nz(use_iii) : iiiValue, i_length) / 
 (i_normal ? altSum(i_cumltv ? i_candle ? ta.cum(volume) : id_cum(idVolume) : i_candle ? volume : idVolume, i_length) : 1)

colrSign = altSum(i_candle ? use_iii : iiiValue, i_length) / (i_normal ? i_candle ? volume : altSum(idVolume, i_length) : 1)
pltStyle = i_styles == 'Columns' ? plot.style_columns : i_styles == 'Histogram' ? plot.style_histogram : plot.style_line
plot(iiSource, 'III, II, or II%', math.sign(colrSign) != -1 ? i_colrUp : i_colrDn, i_widths, pltStyle)

plot(startDay ? 1 : 0, 'startDay', #ffff00, display = display.data_window)
plot(close,    'close',            #ffff00, display = display.data_window)

plot(high,     'high',             #ffff00, display = display.data_window)
plot(low,      'low',              #ffff00, display = display.data_window)
plot(volume,   'volume',           #ffff00, display = display.data_window)

plot(idRangeH, 'idRangeH',         #ffff00, display = display.data_window)
plot(idRangeL, 'idRangeL',         #ffff00, display = display.data_window)
plot(idVolume, 'idVolume',         #ffff00, display = display.data_window)

plot(iiiValue, 'iiiValue',         #ffff00, display = display.data_window)
plot(iiSource, 'iiSource',         #ffff00, display = display.data_window)

hline(i_shoLvl ? i_levelH : na)
hline(i_shoLvl ? i_levelL : na)

// Reference Equations Used For Normal Volume
// III = (((2 * close) - high - low) / (high - low)) * volume
// II  = ta.cum((((2 * close) - high - low) / ((high - low)) * volume)
// II% = 100 * math.sum((((2 * close) - high - low) / ((high - low)) * volume, 21) / math.sum(volume, 21)

// Reference Equations Used For Inverted Volume
// III = ((2 * close) - high - low) / ((high - low) * volume)
// II  = ta.cum(((2 * close) - high - low) / ((high - low) * volume))
// II% = 100 * math.sum(((2 * close) - high - low) / ((high - low) * volume), 21) / math.sum(volume, 21)
````
