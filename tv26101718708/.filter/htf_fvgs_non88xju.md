# HTF FVGs

- url: https://www.tradingview.com/script/Non88Xju-HTF-FVGs/
- type: indicator
- pine_id: PUB;b0c5d6e194ed4b81ac312a34762eb4b3
- version: 1.0

## Description

Fadi's HTF FVG V2 with Labels fixed. Just choose the timeframes and how many FVG's you'd like displayed and set the conditions for the FVG to stop being displayed.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fadizeidan
//
//@version=6
indicator('HTF FVGs', overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)
// last published 712
//+------------------------------------------------------------------------------------------------------------+//
//+--- Types                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//
type Settings
	string style
	bool open_show
	string open_style
	int open_size
	bool close_show
	string close_style
	int close_size
	bool fill
	int fill_percent
	bool CE_show
	string CE_style
	int CE_size
	color CE_bull_color
	color CE_bear_color
	bool link_show
	string link_style
	int link_size
	int max_sets
	bool mitigated_show
	string mitigated_type
	color mitigated_color_bull
	color mitigated_color_bear
	int mitigated_extend
	bool ctf_hide
	bool label_show
	bool label_open
	bool label_close
	bool label_ce
	bool label_tf
	bool label_type
	bool label_level
	color label_color
	color label_bgcolor
	string label_size
	int extend
	string extendby
	int buffer
    bool useProximity
	int proximity
	int labelfactor
	float atrfactor

type Imbalance_Settings
	bool show
	string htf
	color color_bull
	color color_bear
	color color_bull_ce
	color color_bear_ce
	int max_count

type Box
	line open
	line close
	line ce
	line link
	linefill fill
	label label_open
	label label_close
	label label_ce

type Imbalance
	int open_time
	int close_time
	float open
	float middle
	float close
	bool mitigated
	int mitigated_time
	bool isbullish
	Box box2

type ImbalanceStructure
	array<Imbalance> imbalance
	Imbalance_Settings settings
	int order = 1
	int step = 0

type Helper
	string name = 'Helper'

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//
Settings_Display = 'Display'
Settings_Labels = 'Labeling'
Settings_Labels_Levels = 'Label Levels To Display'
Settings_Labels_Content = 'Label Display Content'
Settings_advanced = 'Advanced Settings'

Settings settings = Settings.new()
Imbalance_Settings HTF_1_Settings = Imbalance_Settings.new()
Imbalance_Settings HTF_2_Settings = Imbalance_Settings.new()
Imbalance_Settings HTF_3_Settings = Imbalance_Settings.new()
Imbalance_Settings HTF_4_Settings = Imbalance_Settings.new()
Imbalance_Settings HTF_5_Settings = Imbalance_Settings.new()
Imbalance_Settings HTF_6_Settings = Imbalance_Settings.new()

string tooltip1 = 'HTF FVG Settings:\n\tShow/Hide timeframe\n\tTimeframe to display\n\tBullish FVG Color\n\tBearish FVG Color\n\tMaximum number of FVGs to display'
string tooltip2 = 'Mitigated FVG Settings:\n\tShow/Hide mitigated (Applies to all).\n\tBullish FVG Color\n\tBearish FVG Color\n\tWhen to mark it as mitigated (Based on HTF timeframe, not current timeframe)'

HTF_1_Settings.show := input.bool(true, '', inline = 'htf1')
htf_1 = input.timeframe('5', '', inline = 'htf1')
HTF_1_Settings.htf := htf_1
HTF_1_Settings.color_bull := input.color(color.new(color.green, 0), '', inline = 'htf1')
HTF_1_Settings.color_bear := input.color(color.new(color.red, 0), '', inline = 'htf1')
HTF_1_Settings.max_count := input.int(20, '', inline = 'htf1', tooltip = tooltip1)

HTF_2_Settings.show := input.bool(true, '', inline = 'htf2')
htf_2 = input.timeframe('15', '', inline = 'htf2')
HTF_2_Settings.htf := htf_2
HTF_2_Settings.color_bull := input.color(color.new(color.green, 0), '', inline = 'htf2')
HTF_2_Settings.color_bear := input.color(color.new(color.red, 0), '', inline = 'htf2')
HTF_2_Settings.max_count := input.int(20, '', inline = 'htf2', tooltip = tooltip1)

HTF_3_Settings.show := input.bool(true, '', inline = 'htf3')
htf_3 = input.timeframe('60', '', inline = 'htf3')
HTF_3_Settings.htf := htf_3
HTF_3_Settings.color_bull := input.color(color.new(color.green, 0), '', inline = 'htf3')
HTF_3_Settings.color_bear := input.color(color.new(color.red, 0), '', inline = 'htf3')
HTF_3_Settings.max_count := input.int(20, '', inline = 'htf3', tooltip = tooltip1)

HTF_4_Settings.show := input.bool(true, '', inline = 'htf4')
htf_4 = input.timeframe('240', '', inline = 'htf4')
HTF_4_Settings.htf := htf_4
HTF_4_Settings.color_bull := input.color(color.new(color.green, 0), '', inline = 'htf4')
HTF_4_Settings.color_bear := input.color(color.new(color.red, 0), '', inline = 'htf4')
HTF_4_Settings.max_count := input.int(10, '', inline = 'htf4', tooltip = tooltip1)

HTF_5_Settings.show := input.bool(true, '', inline = 'htf5')
htf_5 = input.timeframe('1D', '', inline = 'htf5')
HTF_5_Settings.htf := htf_5
HTF_5_Settings.color_bull := input.color(color.new(color.green, 0), '', inline = 'htf5')
HTF_5_Settings.color_bear := input.color(color.new(color.red, 0), '', inline = 'htf5')
HTF_5_Settings.max_count := input.int(10, '', inline = 'htf5', tooltip = tooltip1)

HTF_6_Settings.show := input.bool(true, '', inline = 'htf6')
htf_6 = input.timeframe('1W', '', inline = 'htf6')
HTF_6_Settings.htf := htf_6
HTF_6_Settings.color_bull := input.color(color.new(color.green, 0), '', inline = 'htf6')
HTF_6_Settings.color_bear := input.color(color.new(color.red, 0), '', inline = 'htf6')
HTF_6_Settings.max_count := input.int(2, '', inline = 'htf6', tooltip = tooltip1)

settings.max_sets := input.int(6, 'Limit to next HTFs only', options = [1, 2, 3, 4, 5, 6])

settings.ctf_hide := input.bool(true, 'Hide Current Timeframe')

settings.fill := input.bool(true, 'Background Transparency', inline = 'fill')

settings.extendby := input.string('Always', 'Extend FVGs', options = ['Always', 'When in Range'])
settings.extend := input.int(4, 'Distance from current candle', minval = 0)
settings.buffer := input.int(4, 'Spacing between timeframes', minval = 0)
settings.fill_percent := input.int(98, '', options = [98, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50], inline = 'fill')

settings.mitigated_show := input.bool(false, 'Mitigated', inline = '2')
settings.mitigated_color_bull := input.color(color.new(color.gray, 50), '', inline = '2')
settings.mitigated_color_bear := input.color(color.new(color.gray, 50), '', inline = '2')
settings.mitigated_type := input.string('Wick filled', 'when', options = ['None', 'Touched', 'Wick filled', 'Body filled', 'Wick filled half', 'Body filled half'], inline = '2', tooltip = tooltip2)
settings.mitigated_extend := input.int(5, 'Extend mitigated lines', minval = 0)

settings.open_show := input.bool(true, 'Open                ', group = Settings_Display, inline = 'open')
settings.open_style := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], group = Settings_Display, inline = 'open')
settings.open_size := input.int(1, '', options = [1, 2, 3, 4], group = Settings_Display, inline = 'open')

settings.close_show := input.bool(true, 'Close                ', group = Settings_Display, inline = 'close')
settings.close_style := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], group = Settings_Display, inline = 'close')
settings.close_size := input.int(1, '', options = [1, 2, 3, 4], group = Settings_Display, inline = 'close')

settings.CE_show := input.bool(true, 'C.E.     ', group = Settings_Display, inline = '3')
settings.CE_bull_color := input.color(color.new(color.black, 60), '', group = Settings_Display, inline = '3')
settings.CE_bear_color := input.color(color.new(color.black, 60), '', group = Settings_Display, inline = '3')
settings.CE_style := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], group = Settings_Display, inline = '3')
settings.CE_size := input.int(1, '', options = [1, 2, 3, 4], group = Settings_Display, inline = '3')

settings.link_show := input.bool(true, 'Link                ', group = Settings_Display, inline = '4')
settings.link_style := input.string('⎯⎯⎯', ' ', options = ['⎯⎯⎯', '----', '····'], group = Settings_Display, inline = '4')
settings.link_size := input.int(2, '', options = [1, 2, 3, 4], group = Settings_Display, inline = '4')

settings.label_show := input.bool(true, 'Label   ', inline = 'label', group = Settings_Labels)
settings.label_color := input.color(color.new(color.black, 10), '', group = Settings_Labels, inline = 'label')
settings.label_bgcolor := input.color(color.new(color.white, 100), '', group = Settings_Labels, inline = 'label')
settings.label_size := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group = Settings_Labels, inline = 'label')

settings.label_open := input.bool(false, 'Open   ', group = Settings_Labels_Levels, inline = 'level')
settings.label_close := input.bool(false, 'Close   ', group = Settings_Labels_Levels, inline = 'level')
settings.label_ce := input.bool(true, 'C.E.   ', group = Settings_Labels_Levels, inline = 'level')

settings.label_tf := input.bool(true, 'Timeframe   ', group = Settings_Labels_Content, inline = 'level2')
settings.label_type := input.bool(false, 'BISI / SIBI   ', group = Settings_Labels_Content, inline = 'level3')
settings.label_level := input.bool(false, 'Open / Close / C.E.   ', group = Settings_Labels_Content, inline = 'level4')

settings.useProximity := input.bool(false, 'Use Proximity to show to show/hide FVGs', group = Settings_advanced)
settings.proximity := 11 - input.int(9, 'Proximity factor based on daily range', options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], group = Settings_advanced)
settings.labelfactor := input.int(10, 'Combine labels factor for visibility', options = [20, 15, 10, 6, 5, 4, 3], group = Settings_advanced) / 10
settings.atrfactor := input.int(10, 'Range should be within X candles', minval = 1, group = Settings_advanced)
//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//
color color_transparent = #ffffff00

Helper helper = Helper.new()

var ImbalanceStructure FVG_1 = ImbalanceStructure.new()
var ImbalanceStructure FVG_2 = ImbalanceStructure.new()
var ImbalanceStructure FVG_3 = ImbalanceStructure.new()
var ImbalanceStructure FVG_4 = ImbalanceStructure.new()
var ImbalanceStructure FVG_5 = ImbalanceStructure.new()
var ImbalanceStructure FVG_6 = ImbalanceStructure.new()

var array<Imbalance> FVGs_1 = array.new<Imbalance>()
var array<Imbalance> FVGs_2 = array.new<Imbalance>()
var array<Imbalance> FVGs_3 = array.new<Imbalance>()
var array<Imbalance> FVGs_4 = array.new<Imbalance>()
var array<Imbalance> FVGs_5 = array.new<Imbalance>()
var array<Imbalance> FVGs_6 = array.new<Imbalance>()

FVG_1.imbalance := FVGs_1
FVG_1.settings := HTF_1_Settings
FVG_2.imbalance := FVGs_2
FVG_2.settings := HTF_2_Settings
FVG_3.imbalance := FVGs_3
FVG_3.settings := HTF_3_Settings
FVG_4.imbalance := FVGs_4
FVG_4.settings := HTF_4_Settings
FVG_5.imbalance := FVGs_5
FVG_5.settings := HTF_5_Settings
FVG_6.imbalance := FVGs_6
FVG_6.settings := HTF_6_Settings

//Used internally for padding
var int TF_1 = 0
var int TF_2 = 0
var int TF_3 = 0
var int TF_4 = 0
var int TF_5 = 0
var int TF_6 = 0

var float daily = 0
var float monthly = 0

int cspacer = timeframe.in_seconds() * 1000

var array<float> median = array.new_float()
length = 500
median.unshift(high - low)
if median.size() > length
    median.pop()
float spacing = ta.sma(ta.sma(median.median(), length), length) * settings.labelfactor

//+------------------------------------------------------------------------------------------------------------+//
//+--- Methods                                                                                              ---+//
//+------------------------------------------------------------------------------------------------------------+//
method LineStyle(Helper helper, string style) =>
    helper.name := style

    out = switch style
        '----' => line.style_dashed
        '····' => line.style_dotted
        => line.style_solid

    out

method Text(Helper helper, string htf, string direction, string level, bool truncate) =>
    helper.name := htf

    string formatted = ''

    if settings.label_tf
        seconds = timeframe.in_seconds(htf)
        if seconds < 60
            formatted := str.tostring(seconds) + 's'
            formatted
        else if seconds / 60 < 60
            formatted := str.tostring(seconds / 60) + 'm'
            formatted
        else if seconds / 60 / 60 < 24
            formatted := str.tostring(seconds / 60 / 60) + 'H'
            formatted
        else
            formatted := htf
            formatted
    if not truncate
        if settings.label_type
            if formatted != '' and direction != ''
                formatted := formatted + ' '
                formatted
            formatted := formatted + direction
            formatted

        if settings.label_level
            if formatted != '' and level != ''
                formatted := formatted + ' '
                formatted
            formatted := formatted + level
            formatted

    formatted

method Validtimeframe(Helper helper, tf) =>
    bool valid = true

    helper.name := tf
    n1 = timeframe.in_seconds()
    n2 = timeframe.in_seconds(tf)

    if (settings.ctf_hide and n1 == n2)
        valid := false
    if n1 > n2
        valid := false
    valid

method highertimeframe(Helper helper, tf) =>
    helper.name := tf
    n1 = timeframe.in_seconds()
    n2 = timeframe.in_seconds(tf)

    n2 > n1

method ProximityRange(Helper helper, tf) =>
    helper.name := tf
    float range_high = 0
    float range_low = 0
    if timeframe.isseconds or timeframe.isminutes
        range_high := close + daily / settings.proximity
        range_low := close - daily / settings.proximity
        range_low
    if timeframe.isdaily
        range_high := close + monthly * 3
        range_low := close - monthly * 3
        range_low
    if timeframe.isweekly
        range_high := close + monthly * 12
        range_low := close - monthly * 12
        range_low
    [range_low, range_high]

method HTFEnabled(Helper helper) =>
    helper.name := 'HTFEnabled'
    int enabled = 0
    enabled := enabled + (FVG_1.settings.show and helper.Validtimeframe(FVG_1.settings.htf) ? 1 : 0)
    enabled := enabled + (FVG_2.settings.show and helper.Validtimeframe(FVG_2.settings.htf) ? 1 : 0)
    enabled := enabled + (FVG_3.settings.show and helper.Validtimeframe(FVG_3.settings.htf) ? 1 : 0)
    enabled := enabled + (FVG_4.settings.show and helper.Validtimeframe(FVG_4.settings.htf) ? 1 : 0)
    enabled := enabled + (FVG_5.settings.show and helper.Validtimeframe(FVG_5.settings.htf) ? 1 : 0)
    enabled := enabled + (FVG_6.settings.show and helper.Validtimeframe(FVG_6.settings.htf) ? 1 : 0)

    math.min(enabled, settings.max_sets)


findlow(float price, int start, int default, bool inverse) =>
    int loc = default
    int x = inverse ? 0 : (time - start) / cspacer
    int y = inverse ? (time - start) / cspacer : 0

    if x < 5000 and y < 5000
        for i = x to y by 1
            if low[i] == price
                loc := time[i]
                break
    loc

findhigh(float price, int start, int default, bool inverse) =>
    int loc = default
    int x = inverse ? 0 : (time - start) / cspacer
    int y = inverse ? (time - start) / cspacer : 0

    if x < 5000 and y < 5000
        for i = x to y by 1
            if high[i] == price
                loc := time[i]
                break
    loc

visibleHTFs() =>
    int step = 1

    FVG_1.step := 1
    for t in FVG_1.imbalance
        if not na(t.box2)
            FVG_1.step := step
            step := step + 1
            break

    FVG_2.step := 1
    for t in FVG_2.imbalance
        if not na(t.box2)
            FVG_2.step := step
            step := step + 1
            break

    FVG_3.step := 1
    for t in FVG_3.imbalance
        if not na(t.box2)
            FVG_3.step := step
            step := step + 1
            break

    FVG_4.step := 1
    for t in FVG_4.imbalance
        if not na(t.box2)
            FVG_4.step := step
            step := step + 1
            break

    FVG_5.step := 1
    for t in FVG_5.imbalance
        if not na(t.box2)
            FVG_5.step := step
            step := step + 1
            break

    FVG_6.step := 1
    for t in FVG_6.imbalance
        if not na(t.box2)
            FVG_6.step := step
            step := step + 1
            break

//+------------------------------------------------------------------------------------------------------------+//
//+--- Imbalances Methods                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

method clear(Imbalance imb) =>
    if not na(imb.box2)
        line.delete(imb.box2.open)
        line.delete(imb.box2.close)
        line.delete(imb.box2.ce)
        line.delete(imb.box2.link)
        linefill.delete(imb.box2.fill)
        label.delete(imb.box2.label_open)
        label.delete(imb.box2.label_close)
        label.delete(imb.box2.label_ce)
        imb.box2 := na
        imb.box2


// AddZone is used to display and manage imbalance related boxes
method AddZone(ImbalanceStructure IS, Imbalance imb, int step) =>
    bool visible = true
    if IS.settings.show
        int buffer = time + (time - time[1]) * (settings.extend + 1 + settings.buffer * (step - 1))

        if imb.mitigated and not settings.mitigated_show
            if not na(imb.box2)
                visible := false
                visible
            imb.clear()

        if na(imb.box2)
            color c = imb.isbullish ? IS.settings.color_bull : IS.settings.color_bear
            color cce = imb.isbullish ? settings.CE_bull_color : settings.CE_bear_color

            imb.box2 := Box.new()
            imb.box2.open := line.new(imb.open_time, imb.open, buffer, imb.open, xloc = xloc.bar_time, style = helper.LineStyle(settings.open_style), color = settings.open_show ? c : color_transparent, width = settings.open_size)
            imb.box2.close := line.new(imb.close_time, imb.close, buffer, imb.close, xloc = xloc.bar_time, style = helper.LineStyle(settings.close_style), color = settings.close_show ? c : color_transparent, width = settings.close_size)
            if settings.link_show
                imb.box2.link := line.new(buffer, imb.open, buffer, imb.close, xloc = xloc.bar_time, style = helper.LineStyle(settings.link_style), color = c, width = settings.link_size)
                imb.box2.link
            if settings.fill
                imb.box2.fill := linefill.new(imb.box2.open, imb.box2.close, color.new(c, settings.fill_percent))
                imb.box2.fill

            if settings.CE_show
                imb.box2.ce := line.new((imb.open_time + imb.close_time) / 2, imb.middle, buffer, imb.middle, xloc = xloc.bar_time, style = helper.LineStyle(settings.CE_style), color = cce, width = settings.CE_size)
                imb.box2.ce
            if settings.label_show
                if math.abs(imb.open - imb.close) >= spacing
                    if settings.open_show or settings.fill
                        if settings.label_open
                            imb.box2.label_open := label.new(buffer, imb.open, text = helper.Text(IS.settings.htf, imb.isbullish ? 'BISI' : 'SIBI', 'Open', false), xloc = xloc.bar_time, textcolor = settings.label_color, style = label.style_label_left, color = settings.label_bgcolor, size = settings.label_size)
                            imb.box2.label_open
                    if settings.close_show or settings.fill
                        if settings.label_close
                            imb.box2.label_close := label.new(buffer, imb.close, text = helper.Text(IS.settings.htf, imb.isbullish ? 'BISI' : 'SIBI', 'Close', false), xloc = xloc.bar_time, textcolor = settings.label_color, style = label.style_label_left, color = settings.label_bgcolor, size = settings.label_size)
                            imb.box2.label_close
                    if settings.CE_show and settings.label_ce
                        imb.box2.label_ce := label.new(buffer, imb.middle, text = helper.Text(IS.settings.htf, imb.isbullish ? 'BISI' : 'SIBI', 'ce', false), xloc = xloc.bar_time, textcolor = settings.label_color, style = label.style_label_left, color = settings.label_bgcolor, size = settings.label_size)
                        imb.box2.label_ce
                else
                    // FVG is smaller than spacing threshold — always create a CE label so the TF label is visible
                    imb.box2.label_ce := label.new(buffer, imb.middle, text = helper.Text(IS.settings.htf, imb.isbullish ? 'BISI' : 'SIBI', '', false), xloc = xloc.bar_time, textcolor = settings.label_color, style = label.style_label_left, color = settings.label_bgcolor, size = settings.label_size)
                    imb.box2.label_ce
    visible

method updateZone(ImbalanceStructure IS) =>
    if barstate.islast
        visibleHTFs()
        int level = IS.step
        for imb in IS.imbalance
            if not na(imb.box2)
                int buffer = 0
                if imb.mitigated
                    buffer := imb.close_time + cspacer * settings.mitigated_extend
                    line.set_color(imb.box2.open, imb.isbullish ? settings.mitigated_color_bull : settings.mitigated_color_bear)
                    line.set_color(imb.box2.close, imb.isbullish ? settings.mitigated_color_bull : settings.mitigated_color_bear)
                    line.set_color(imb.box2.ce, imb.isbullish ? settings.mitigated_color_bull : settings.mitigated_color_bear)
                    line.set_color(imb.box2.link, imb.isbullish ? settings.mitigated_color_bull : settings.mitigated_color_bear)
                    linefill.set_color(imb.box2.fill, color.new(imb.isbullish ? settings.mitigated_color_bull : settings.mitigated_color_bear, settings.fill_percent))
                else
                    if settings.extendby == 'When in Range'
                        float atrlength = ta.atr(14) * settings.atrfactor
                        if math.max(imb.open, imb.close) > close - atrlength and math.min(imb.open, imb.close) < close + atrlength
                            buffer := time + cspacer * (settings.extend + 1 + (level - 1) * settings.buffer)
                            buffer
                        else
                            buffer := imb.close_time + cspacer * (settings.extend + 1)
                            buffer
                    else
                        buffer := time + cspacer * (settings.extend + 1 + (level - 1) * settings.buffer)
                        buffer

                line.set_x2(imb.box2.open, buffer)
                line.set_x2(imb.box2.close, buffer)
                line.set_x1(imb.box2.link, buffer)
                line.set_x2(imb.box2.link, buffer)

                // --- FIX: guard all label updates with na() checks, and lazily create CE label if missing ---
                if settings.label_show
                    // Lazily create CE label if it was never created in AddZone
                    if na(imb.box2.label_ce)
                        imb.box2.label_ce := label.new(buffer, imb.middle, text = helper.Text(IS.settings.htf, imb.isbullish ? 'BISI' : 'SIBI', '', false), xloc = xloc.bar_time, textcolor = settings.label_color, style = label.style_label_left, color = settings.label_bgcolor, size = settings.label_size)
                    else
                        label.set_x(imb.box2.label_ce, buffer)
                        label.set_text(imb.box2.label_ce, helper.Text(IS.settings.htf, imb.isbullish ? 'BISI' : 'SIBI', '', false))
                    // Only update open/close labels if they actually exist
                    if not na(imb.box2.label_open)
                        label.set_x(imb.box2.label_open, buffer)
                    if not na(imb.box2.label_close)
                        label.set_x(imb.box2.label_close, buffer)

                if settings.CE_show
                    line.set_x2(imb.box2.ce, buffer)
                if imb.mitigated
                    if na(imb.box2.label_ce)
                        imb.box2.label_ce := label.new(buffer, imb.middle, text = helper.Text(IS.settings.htf, '', '', true), xloc = xloc.bar_time, textcolor = settings.label_color, style = label.style_label_left, color = settings.label_bgcolor, size = settings.label_size)
                        imb.box2.label_ce
                    else
                        label.set_text(imb.box2.label_ce, helper.Text(IS.settings.htf, '', '', true))
                    label.delete(imb.box2.label_open)
                    label.delete(imb.box2.label_close)

// AddImbalance adds a newly discovered imbalance. this applies for both FVG and Volume Imbalance
method AddImbalance(ImbalanceStructure IS, float o, float c, int o_time, int c_time) =>
    Imbalance imb = Imbalance.new()
    imb.open_time := o < c ? findhigh(o, o_time, o_time, false) : findlow(o, o_time, o_time, false) // o_time
    imb.close_time := o < c ? findlow(c, o_time, c_time, true) : findhigh(c, o_time, c_time, true) // c_time
    imb.open := o
    imb.middle := (o + c) / 2
    imb.close := c
    imb.isbullish := o < c
    IS.imbalance.unshift(imb)

    if IS.imbalance.size() > IS.settings.max_count
        temp = IS.imbalance.pop()
        temp.clear()
    IS

// CheckMitigated checks if the imbalance has been mitigated based on the settings
method CheckMitigated(ImbalanceStructure IS, o, h, l, c, bool isHTF) =>
    if IS.imbalance.size() > 0
        for i = IS.imbalance.size() - 1 to 0 by 1
            imb = IS.imbalance.get(i)

            if not imb.mitigated
                switch settings.mitigated_type
                    'None' => 
                	    imb.mitigated := false
                	    imb.mitigated
                    'Touched' => 
                	    imb.mitigated := (imb.open <= imb.close ? low < imb.close : high > imb.close)
                	    imb.mitigated
                    'Wick filled' => 
                	    imb.mitigated := (imb.open <= imb.close ? low <= imb.open : high >= imb.open)
                	    imb.mitigated
                    'Body filled' => 
                	    imb.mitigated := isHTF and (imb.open < imb.close ? math.min(o, c) <= imb.open : math.max(o, c) >= imb.open)
                	    imb.mitigated
                    'Wick filled half' => 
                	    imb.mitigated := imb.open <= imb.close ? low <= imb.middle : high >= imb.middle
                	    imb.mitigated
                    'Body filled half' => 
                	    imb.mitigated := isHTF and (imb.open <= imb.close ? math.min(o, c) <= imb.middle : math.max(o, c) >= imb.middle)
                	    imb.mitigated
                if imb.mitigated
                    if not settings.mitigated_show
                        imb.clear()
                        IS.imbalance.remove(i)
                    else
                        imb.mitigated_time := time
                        imb.mitigated_time
                    IS.updateZone()
    IS

method ProximityTest(ImbalanceStructure IS) =>
    if IS.imbalance.size() > 0
        [rl, rh] = helper.ProximityRange(IS.settings.htf)
        for i = 0 to IS.imbalance.size() - 1 by 1
            imb = IS.imbalance.get(i)
            if (math.max(imb.open, imb.close) > rl and math.min(imb.open, imb.close) < rh) or not settings.useProximity
                IS.AddZone(imb, IS.order)
            else
                imb.clear()
    IS
    // FindImbalance looks for imbalances and, if found, adds it to the list
method FindImbalance(ImbalanceStructure IS, o, h, l, c, t, o1, h1, l1, c1, t1, o2, h2, l2, c2, t2) =>
    if IS.settings.show
        if h < l2 and h > l1 and l2 < h1
            IS.AddImbalance(l2, h, t2, t)
        if l > h2 and l < h1 and h2 > l1
            IS.AddImbalance(h2, l, t2, t)
    IS

method Process(ImbalanceStructure IS, float o, float h, float l, float c, int t, float o1, float h1, float l1, float c1, int t1, float o2, float h2, float l2, float c2, int t2) =>
    bool show = false

    if IS.settings.show
        if helper.Validtimeframe(IS.settings.htf)
            IS.FindImbalance(o, h, l, c, t, o1, h1, l1, c1, t1, o2, h2, l2, c2, t2)

getHTF(string htf, int i) =>
    [open[i], high[i], low[i], close[i], time[i]]

method check(ImbalanceStructure IS, string htf) =>
    bool newCandle = bool(ta.change(time(htf, "america/New_York")))
    if newCandle
        int inc = 1 //barstate.isrealtime ? 1 : 0
        [o, h, l, c, t]        = request.security(syminfo.tickerid, htf, getHTF(htf, inc), lookahead = barmerge.lookahead_on)
        [o1, h1, l1, c1, t1]   = request.security(syminfo.tickerid, htf, getHTF(htf, inc+1), lookahead = barmerge.lookahead_on)
        [o2, h2, l2, c2, t2]   = request.security(syminfo.tickerid, htf, getHTF(htf, inc+2), lookahead = barmerge.lookahead_on)
        if not na(o)
            IS.Process(o, h, l, c, t, o1, h1, l1, c1, t1, o2, h2, l2, c2, t2)
            IS.ProximityTest()
            IS.CheckMitigated(o, h, l, c, bool(ta.change(time(htf, "america/New_York"))))

    IS.CheckMitigated(open, high, low, close, newCandle)

    IS.updateZone()

//+------------------------------------------------------------------------------------------------------------+//
//+--- Main call to start the process                                                                       ---+//
//+------------------------------------------------------------------------------------------------------------+//
// daily and monthly are used for proximity test on higher timeframes
daily := request.security(syminfo.tickerid, '1D', ta.atr(14))
monthly := request.security(syminfo.tickerid, '1M', ta.atr(14))

int cnt = 0
int last = helper.HTFEnabled()

if true// barstate.isconfirmed
    if FVG_1.settings.show
        if helper.Validtimeframe(htf_1)
            cnt := cnt + 1
            FVG_1.order := cnt
            FVG_1.check(htf_1)

    if FVG_2.settings.show
        if helper.Validtimeframe(htf_2)
            if cnt < last
                cnt := cnt + 1
                FVG_2.order := cnt
                FVG_2.check(htf_2)

    if FVG_3.settings.show
        if helper.Validtimeframe(htf_3)
            if cnt < last
                cnt := cnt + 1
                FVG_3.order := cnt
                FVG_3.check(htf_3)

    if FVG_4.settings.show
        if helper.Validtimeframe(htf_4)
            if cnt < last
                cnt := cnt + 1
                FVG_4.order := cnt
                FVG_4.check(htf_4)

    if FVG_5.settings.show
        if helper.Validtimeframe(htf_5)
            if cnt < last
                cnt := cnt + 1
                FVG_5.order := cnt
                FVG_5.check(htf_5)

    if FVG_6.settings.show
        if helper.Validtimeframe(htf_6)
            if cnt < last
                cnt := cnt + 1
                FVG_6.order := cnt
                FVG_6.check(htf_6)
````
