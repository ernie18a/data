# @tom_w777 Turtles and EMA200 BB 

- url: https://www.tradingview.com/script/yyDL1Dq0-tom-w777-Turtles-and-EMA200-BB/
- type: indicator
- pine_id: PUB;ecccdfcfb3134dd5966db4c91593904f
- version: 1.0

## Description

indicator mixing turtles with EMA 200 and bollinger multiple deviations

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tom_w777

//@version=6
indicator("@tom_w777 Turtles and MA200 BB MultiTimeFrame", overlay=true)
/// MultiTimeFrame setup for close : colors : besoins : 9 couleurs : 
/// and indicators : BB length 20 sma close stdev 2, ema 200 close, 
/// BB on ema close length 20 stdev 20 and BB on ema close length 40 stdev 20

// Autres : inputs
color couleur_BB = input(color.blue, "Bollinger")
color couleur_BB_filling = color.new(couleur_BB, 95)
color couleur_EMA200 = input(color.purple, "EMA200")
color couleur_bb20_ema200 = input(color.fuchsia, "BB20/EMA200")
color couleur_bb40_ema200 = input(color.rgb(142, 8, 165, 34), "BB40/EMA200")

// Turtles

/////////
length_IN_S1 = input.int(title="Length IN S1", defval=20, minval=1)
length_OUT_S1 = input.int(title="Length OUT S1", defval=10, minval=1)
color c_IN_S1 = input(color.aqua, "Take position S1")
color c_OUT_S1 = input(color.maroon, "Out of position S1")
length_IN_S2 = input.int(title="Length IN S2", defval=55, minval=1)
length_OUT_S2 = input.int(title="Length OUT S2", defval=20, minval=1)
color c_IN_S2 = input(color.navy, "Take position S2")
color c_OUT_S2 = input(color.fuchsia, "Out of position S2")
bool show_system1 = input(title='Show System 1', defval=true)
bool show_system2 = input(title='Show System 2', defval=true)


//// calculs SMA / EMA / BB

// Bollinger : 
int bb_length = input.int(defval = 20, title = "BB Length:", group = "Bollinger Band Setting")
bb_src = input(defval = close, title="BB Source", group = "Bollinger Band Setting")
float bb_stdev = input.float(defval = 2.0, title="BB Standard-Deviation", group = "Bollinger Band Setting")
upper_band = ta.sma(bb_src, bb_length) + (bb_stdev * ta.stdev(bb_src, bb_length))
lower_band = ta.sma(bb_src, bb_length) - (bb_stdev * ta.stdev(bb_src, bb_length))

ema200 = ta.ema(source = close, length = 200)

// 20/ 200
int bb_length20 = 20
int bb_length40 = 40
bb_src20 = ema200
float bb_stdev20 = 20.0
upper_band20 = ta.sma(bb_src20, bb_length20) + (bb_stdev20 * ta.stdev(bb_src20, bb_length20))
lower_band20 = ta.sma(bb_src20, bb_length20) - (bb_stdev20 * ta.stdev(bb_src20, bb_length20))

upper_band40 = ta.sma(bb_src20, bb_length40) + (bb_stdev20 * ta.stdev(bb_src20, bb_length40))
lower_band40 = ta.sma(bb_src20, bb_length40) - (bb_stdev20 * ta.stdev(bb_src20, bb_length40))





// Calculs Turtles

_trueRange_smoothing = input.string(title="Smoothing True Range", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"])
zGreatest(_source, int _length = 20, bool _highest = true) => 
    _counter = _length
    series float _s_temp = na
    while _counter >= 0
        _s_temp := _source[_counter]
        _counter -= 1
    float _greatest = ta.highest(source = _s_temp, length = _length)
    float _lowest = ta.lowest(source = _s_temp, length = _length)
    switch _highest
        true => _greatest
        false => _lowest
zTrueRange(source, length) =>
	switch _trueRange_smoothing
		"RMA" => ta.rma(source, length)[0]
		"SMA" => ta.sma(source, length)[0]
		"EMA" => ta.ema(source, length)[0]
		=> ta.wma(source, length)[0]

_short_ATR_S1 = zTrueRange(source = ta.tr(true), length = length_OUT_S1)
_long_ATR_S1 = zTrueRange(source = ta.tr(true), length = length_IN_S1)
_short_ATR_S2 = zTrueRange(source = ta.tr(true), length = length_OUT_S2)
_long_ATR_S2 = zTrueRange(source = ta.tr(true), length = length_IN_S2)
/// traitement entrée de LONG
float _greatest_long_S1 = zGreatest(high, _length = length_IN_S1, _highest = true)
float _greatest_long_S2 = zGreatest(high, _length = length_IN_S2, _highest = true)
/// traitement pour la sortie de long
float _greatest_short_S1 = zGreatest(high, _length = length_OUT_S1, _highest = true)
float _greatest_short_S2 = zGreatest(high, _length = length_OUT_S2, _highest = true)
// traitement entrée de SHORT
float _lowest_long_S1 = zGreatest(low, _length = length_IN_S1, _highest = false)
float _lowest_long_S2 = zGreatest(low, _length = length_IN_S2, _highest = false)
/// traitement pour la sortie de SHORT
float _lowest_short_S1 = zGreatest(low, _length = length_OUT_S1, _highest = false)
float _lowest_short_S2 = zGreatest(low, _length = length_OUT_S2, _highest = false)

/// DRAWINGS others
// Bollinger
upper = plot(upper_band, "BB Upper", color=couleur_BB, linestyle = plot.linestyle_dashed)
lower = plot(lower_band, "BB Lower", color=couleur_BB, linestyle = plot.linestyle_dashed)
fill(upper, lower, title = "BB Background", color=couleur_BB_filling)
ema200_drawing = plot(series=ema200, title="ema200", color=couleur_EMA200, linewidth=2)

upper20 = plot(upper_band20, "BB Upper20", color=couleur_bb20_ema200, linestyle = plot.linestyle_dotted, linewidth = 2)
lower20 = plot(lower_band20, "BB Lower20", color=couleur_bb20_ema200, linestyle = plot.linestyle_dotted, linewidth = 2)

upper40 = plot(upper_band40, "BB Upper40", color=couleur_bb40_ema200, linestyle = plot.linestyle_dotted, linewidth = 2)
lower40 = plot(lower_band40, "BB Lower40", color=couleur_bb40_ema200, linestyle = plot.linestyle_dotted, linewidth = 2)

//// DRAWINGS TURTLES
//// highs - lows - lines - system 01
if show_system1
    _line_high_long_S1 = line.new(bar_index,_greatest_long_S1, (bar_index-length_IN_S1), _greatest_long_S1, xloc=xloc.bar_index, color=c_IN_S1, width=2)
    _line_high_short_S1 = line.new(bar_index, _greatest_short_S1, (bar_index-length_OUT_S1), _greatest_short_S1, xloc=xloc.bar_index, color=c_OUT_S1, width=2)
    _line_low_long_S1 = line.new(bar_index,_lowest_long_S1, (bar_index-length_IN_S1), _lowest_long_S1, xloc=xloc.bar_index, color=c_IN_S1, width=2)
    _line_low_short_S1 = line.new(bar_index, _lowest_short_S1, (bar_index-length_OUT_S1), _lowest_short_S1, xloc=xloc.bar_index, color=c_OUT_S1, width=2)
    line.delete(_line_high_long_S1[1])
    line.delete(_line_high_short_S1[1])
    line.delete(_line_low_long_S1[1])
    line.delete(_line_low_short_S1[1])
//// highs - lows - lines - system 02
if show_system2
    _line_high_long_S2 = line.new(bar_index,_greatest_long_S2, (bar_index-length_IN_S2), _greatest_long_S2, xloc=xloc.bar_index, color=c_IN_S2, width=2)
    _line_high_short_S2 = line.new(bar_index, _greatest_short_S2, (bar_index-length_OUT_S2), _greatest_short_S2, xloc=xloc.bar_index, color=c_OUT_S2, width=2)
    _line_low_long_S2 = line.new(bar_index,_lowest_long_S2, (bar_index-length_IN_S2), _lowest_long_S2, xloc=xloc.bar_index, color=c_IN_S2, width=2)
    _line_low_short_S2 = line.new(bar_index, _lowest_short_S2, (bar_index-length_OUT_S2), _lowest_short_S2, xloc=xloc.bar_index, color=c_OUT_S2, width=2)
    line.delete(_line_high_long_S2[1])
    line.delete(_line_high_short_S2[1])
    line.delete(_line_low_long_S2[1])
    line.delete(_line_low_short_S2[1])

/// 2N DRAWINGS
/// system 1
if show_system1
    float _current_high_ATR_S1 = high+2*_long_ATR_S1[0]
    float _current_low_ATR_S1 = high-2*_short_ATR_S1[0]
    _line_plus_2N_S1 = line.new(bar_index,_current_high_ATR_S1, (bar_index-(2*length_IN_S1)), _current_high_ATR_S1, xloc=xloc.bar_index, color=color.orange)
    _line_moins_2N_S1 = line.new(bar_index,_current_low_ATR_S1, (bar_index-(2*length_IN_S1)), _current_low_ATR_S1, xloc=xloc.bar_index, color=color.orange)
    line.delete(_line_plus_2N_S1[1])
    line.delete(_line_moins_2N_S1[1])
/// system 2
if show_system2
    float _current_high_ATR_S2 = high+2*_long_ATR_S2[0]
    float _current_low_ATR_S2 = high-2*_short_ATR_S2[0]
    _line_plus_2N_S2 = line.new(bar_index,_current_high_ATR_S2, (bar_index-(2*length_IN_S2)), _current_high_ATR_S2, xloc=xloc.bar_index, color=color.purple)
    _line_moins_2N_S2 = line.new(bar_index,_current_low_ATR_S2, (bar_index-(2*length_IN_S2)), _current_low_ATR_S2, xloc=xloc.bar_index, color=color.purple)
    line.delete(_line_plus_2N_S2[1])
    line.delete(_line_moins_2N_S2[1])
````
