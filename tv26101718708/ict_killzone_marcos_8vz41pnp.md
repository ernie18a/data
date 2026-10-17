# ICT Killzone+ Marcos

- url: https://www.tradingview.com/script/8vZ41PNP-ICT-Killzone-Marcos/
- type: indicator
- pine_id: PUB;31cc842667fc4f4eb285b93010f4605f
- version: 3.0

## Description

Due to the limit of indicator, I create this pine script which is a combination of the below two scripts related to ICT Killzones & ICT Marcos
Then, user can conveniently use one script to indicate both Timezone related ICT

Reference Script:
1. ICT Killzones Toolkit [LuxAlgo] by LuxAlgo
2. ICT Hydra Macros by dabarlea

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xiu_00
// reference ICT Killzones Toolkit [LuxAlgo] by LuxAlgo
// reference ICT Hydra Macros by dabarlea
// Due to the limit of indicator, I create this pine script
// which is a combination of the above two scripts related to ICT Killzones & ICT Marcos
// Then, user can conveniently use one script to indicate both Timezone

//@version=6
indicator('Killzone+ Marcos', 'ICT Timezone', overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)
// Killzones
// ---------------------------------------- Inputs --------------------------------------------------
disp = display.all - display.status_line

kzGR = 'Killzones'
asSH = input(true, '', inline = 'asia', group = kzGR)
asST = input.string('Asian', '', inline = 'asia', group = kzGR, display = disp)
asS = input.session('1900-2300', '', inline = 'asia', group = kzGR, display = disp)
asC = input.color(color.new(#e91e63, 95), '', inline = 'asia', group = kzGR)

ldnOSH = input(true, '', inline = 'ldno', group = kzGR)
ldnOST = input.string('London', '', inline = 'ldno', group = kzGR, display = disp)
ldnOS = input.session('0100-0400', '', inline = 'ldno', group = kzGR, display = disp)
ldnOC = input.color(color.new(#00bcd4, 95), '', inline = 'ldno', group = kzGR)

nySH = input(true, '', inline = 'nyam', group = kzGR)
nyST = input.string('New York AM', '', inline = 'nyam', group = kzGR, display = disp)
nyS = input.session('0730-1000', '', inline = 'nyam', group = kzGR, display = disp)
nyC = input.color(color.new(#ff5d00, 95), '', inline = 'nyam', group = kzGR)

ldnCSH = input(true, '', inline = 'nypm', group = kzGR)
ldnCST = input.string('New York PM', '', inline = 'nypm', group = kzGR, display = disp)
ldnCS = input.session('1230-1500', '', inline = 'nypm', group = kzGR, display = disp)
ldnCC = input.color(color.new(#2157f3, 95), '', inline = 'nypm', group = kzGR)

kzMML = input(true, 'Killzone Lines : Top/Bottom', inline = 'LN', group = kzGR)
kzML = input(false, 'Mean', inline = 'LN', group = kzGR)
kzLE = input(true, 'Extend Top/Bottom', inline = 'LN', group = kzGR)
kzLB = input(true, 'Killzone Labels', group = kzGR)
kzSH = input.int(15, 'Display Killzones within Timeframes Up To', options = [1, 3, 5, 15, 30, 45, 60], group = kzGR, display = disp)
dwmO = input.string('None', 'Open Price of', options = ['Killzones', 'the Day', 'the Week', 'the Month', 'None'], inline = 'OP', group = kzGR, display = disp)
dwmS = input.bool(true, 'Separator', inline = 'OP', group = kzGR)
dwmC = input(color.new(color.gray, 89), '', inline = 'OP', group = kzGR)
dwmL = input.bool(true, 'Label', inline = 'OP', group = kzGR)

// Inputs

// User Defined Types
type bar
	float o = open
	float h = high
	float l = low
	float c = close
	int t = time
	int i = bar_index

type pivotPoint
	float h
	int hi
	bool hx

	float l
	int li
	bool lx

type KZ
	line lnT
	line lnM
	line lnB
	line lnO
	label lb
	label lbO

type DWM
	line ln
	label lb
	// User Defined Types

// Var

bar b = bar.new()

tfM = timeframe.multiplier

nyam = not na(time(timeframe.period, nyS, 'UTC-5')) and nySH and tfM <= kzSH
ldnO = not na(time(timeframe.period, ldnOS, 'UTC-5')) and ldnOSH and tfM <= kzSH
ldnC = not na(time(timeframe.period, ldnCS, 'UTC-5')) and ldnCSH and tfM <= kzSH
asian = not na(time(timeframe.period, asS, 'UTC-5')) and asSH and tfM <= kzSH

inKZ = nyam or ldnO or ldnC or asian
var KZ kz = KZ.new()
var DWM dwm = DWM.new()
// Var

// Functions / Methods
method killzones(KZ _id, _s, _kz, _o, _h, _l, _c, _t, _cr, _tx, _mml, _ml, _lb, _le, _ol, _olC, _olL, areaCss) =>
    var float max = na
    var float mid = na
    var float min = na
    var int sbT = na
    var bool xt = false
    var bool xb = false
    var box area = na
    var tC = color.rgb(color.r(_cr), color.g(_cr), color.b(_cr))

    if _s and not _s[1]
        max := _h
        sbT := _t
        min := _l
        mid := math.avg(max, min)
        area := box.new(bar_index, max, bar_index, min, na, bgcolor = areaCss)

        if _mml
            _id.lnT := line.new(sbT, max, sbT, max, xloc.bar_time, color = tC) //, xt := true
            _id.lnB := line.new(sbT, min, sbT, min, xloc.bar_time, color = tC) //, xb := true
            _id.lnB

        if _ml
            _id.lnM := line.new(sbT, mid, sbT, mid, xloc.bar_time, color = tC, style = line.style_dotted)
            _id.lnM

        if _ol
            _id.lnO := line.new(sbT, _o, sbT, _o, xloc.bar_time, color = color.new(_olC, 0), style = line.style_dotted)

            if _olL
                _id.lbO := label.new(sbT, _o, 'KZO(' + str.tostring(_o, format.mintick) + ')', xloc.bar_time, color = color(na), style = label.style_label_left, textcolor = color.new(_olC, 0), size = size.tiny)
                _id.lbO

        if _lb
            _id.lb := label.new(sbT, max, _tx, xloc.bar_time, color = #ffffff00, style = label.style_label_down, textcolor = tC, size = size.small)
            _id.lb

    if _s
        max := math.max(_h, max)
        min := math.min(_l, min)
        mid := math.avg(max, min)
        xt := true
        xb := true

        area.set_top(max)
        area.set_rightbottom(bar_index, min)

        if _lb
            label.set_x(_id.lb, int(math.avg(_t, sbT)))
            label.set_y(_id.lb, max)

        if _mml
            _id.lnT.set_y1(max)
            _id.lnT.set_xy2(_t, max)
            _id.lnB.set_y1(min)
            _id.lnB.set_xy2(_t, min)

        if _ml
            _id.lnM.set_y1(mid)
            _id.lnM.set_xy2(_t, mid)

        if _ol
            _id.lnO.set_x2(_t)

            if _olL
                _id.lbO.set_x(_t)

    if not _s and _le and not _kz

        if _mml
            if xt
                if _h < _id.lnT.get_y1()
                    _id.lnT.set_x2(_t)
                else
                    _id.lnT.set_x2(_t)
                    xt := false
                    xt

            if xb
                if _l > _id.lnB.get_y1()
                    _id.lnB.set_x2(_t)
                else
                    _id.lnB.set_x2(_t)
                    xb := false
                    xb

        if _ml
            _id.lnM.set_x2(_t)

method pDWM(DWM _id, _tC, _t, _o, _cl, _lbTX, _olL) =>
    if _tC
        _id.lb.delete()
        _id.ln := line.new(_t, _o, _t, _o, xloc.bar_time, extend.none, color.new(_cl, 0), line.style_dotted, 1)

        if _olL
            _id.lb := label.new(_t, _o, _lbTX + '(' + str.tostring(_o, format.mintick) + ')', xloc.bar_time, yloc.price, color(na), label.style_label_left, color.new(_cl, 0), size.tiny)
            _id.lb
    else
        _id.ln.set_x2(_t)

        if _olL
            _id.lb.set_x(_t)
        na
        // Functions / Methods

// Calculations - Killzones
kzO = dwmO == 'Killzones'

kz.killzones(nyam and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, nyC, nyST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, nyC)
kz.killzones(ldnO and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, ldnOC, ldnOST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, ldnOC)
kz.killzones(ldnC and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, ldnCC, ldnCST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, ldnCC)
kz.killzones(asian and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, asC, asST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, asC)

[xChg, xTxt] = switch dwmO
    'the Day' => [timeframe.change('D'), 'DO']
    'the Week' => [timeframe.change('W'), 'WO']
    'the Month' => [timeframe.change('M'), 'MO']

if not kzO and timeframe.isintraday and tfM <= kzSH
    dwm.pDWM(xChg, b.t, b.o, dwmC, xTxt, dwmL)

bgcolor(dwmS and not kzO and timeframe.isintraday and tfM <= kzSH ? xChg ? dwmC : na : na)
// Calculations - Killzones
// Killzones -----

// ---- Marcos ----
// Inputs
var MACROS_SETTINGS = 'Macros Settings'
max_days = input.int(10, 'Limit Days to Draw', 1, group = MACROS_SETTINGS)
max_timeframe = input.timeframe('15', 'Timeframe Limit', group = MACROS_SETTINGS)
gmt_timezone = input.string('America/New_York', 'Timezone', options = ['America/New_York', 'GMT-12', 'GMT-11', 'GMT-10', 'GMT-9', 'GMT-8', 'GMT-7', 'GMT-6', 'GMT-5', 'GMT-4', 'GMT-3', 'GMT-2', 'GMT-1', 'GMT+0', 'GMT+1', 'GMT+2', 'GMT+3', 'GMT+4', 'GMT+5', 'GMT+6', 'GMT+7', 'GMT+8', 'GMT+9', 'GMT+10', 'GMT+11', 'GMT+12'], group = MACROS_SETTINGS)


show_macros = input.bool(true, 'Show Macros Boxes', inline = 'Macros', group = MACROS_SETTINGS)
show_macros_text = input.bool(false, 'Display Text', inline = 'Macros', group = MACROS_SETTINGS)
macros_transparency = input.int(80, 'Macros Transparency', 0, 100, group = MACROS_SETTINGS)
default_color = #2e2e2e20

use_m1 = input.bool(false, 'Macro 1', inline = 'Macro1', group = MACROS_SETTINGS)
m1 = input.session('0320-0340', '', inline = 'Macro1', group = MACROS_SETTINGS)
m1_color = input.color(default_color, '', inline = 'Macro1', group = MACROS_SETTINGS)

use_m2 = input.bool(false, 'Macro 2', inline = 'Macro2', group = MACROS_SETTINGS)
m2 = input.session('0350-0410', '', inline = 'Macro2', group = MACROS_SETTINGS)
m2_color = input.color(default_color, '', inline = 'Macro2', group = MACROS_SETTINGS)

use_m3 = input.bool(false, 'Macro 3', inline = 'Macro3', group = MACROS_SETTINGS)
m3 = input.session('0420-0440', '', inline = 'Macro3', group = MACROS_SETTINGS)
m3_color = input.color(default_color, '', inline = 'Macro3', group = MACROS_SETTINGS)

use_m4 = input.bool(false, 'Macro 4', inline = 'Macro4', group = MACROS_SETTINGS)
m4 = input.session('0450-0510', '', inline = 'Macro4', group = MACROS_SETTINGS)
m4_color = input.color(default_color, '', inline = 'Macro4', group = MACROS_SETTINGS)

use_m5 = input.bool(false, 'Macro 5', inline = 'Macro5', group = MACROS_SETTINGS)
m5 = input.session('0520-0540', '', inline = 'Macro5', group = MACROS_SETTINGS)
m5_color = input.color(default_color, '', inline = 'Macro5', group = MACROS_SETTINGS)

use_m6 = input.bool(false, 'Macro 6', inline = 'Macro6', group = MACROS_SETTINGS)
m6 = input.session('0550-0610', '', inline = 'Macro6', group = MACROS_SETTINGS)
m6_color = input.color(default_color, '', inline = 'Macro6', group = MACROS_SETTINGS)

use_m7 = input.bool(false, 'Macro 7', inline = 'Macro7', group = MACROS_SETTINGS)
m7 = input.session('0620-0640', '', inline = 'Macro7', group = MACROS_SETTINGS)
m7_color = input.color(default_color, '', inline = 'Macro7', group = MACROS_SETTINGS)

use_m8 = input.bool(false, 'Macro 8', inline = 'Macro8', group = MACROS_SETTINGS)
m8 = input.session('0650-0710', '', inline = 'Macro8', group = MACROS_SETTINGS)
m8_color = input.color(default_color, '', inline = 'Macro8', group = MACROS_SETTINGS)

use_m9 = input.bool(false, 'Macro 9', inline = 'Macro9', group = MACROS_SETTINGS)
m9 = input.session('0720-0740', '', inline = 'Macro9', group = MACROS_SETTINGS)
m9_color = input.color(default_color, '', inline = 'Macro9', group = MACROS_SETTINGS)


use_m10 = input.bool(true, 'Macro 10', inline = 'Macro10', group = MACROS_SETTINGS)
m10 = input.session('0750-0810', '', inline = 'Macro10', group = MACROS_SETTINGS)
m10_color = input.color(default_color, '', inline = 'Macro10', group = MACROS_SETTINGS)

use_m11 = input.bool(false, 'Macro 11', inline = 'Macro11', group = MACROS_SETTINGS)
m11 = input.session('0820-0840', '', inline = 'Macro11', group = MACROS_SETTINGS)
m11_color = input.color(default_color, '', inline = 'Macro11', group = MACROS_SETTINGS)

use_m12 = input.bool(true, 'Macro 12', inline = 'Macro12', group = MACROS_SETTINGS)
m12 = input.session('0850-0910', '', inline = 'Macro12', group = MACROS_SETTINGS)
m12_color = input.color(default_color, '', inline = 'Macro12', group = MACROS_SETTINGS)

use_m13 = input.bool(false, 'Macro 13', inline = 'Macro13', group = MACROS_SETTINGS)
m13 = input.session('0920-0940', '', inline = 'Macro13', group = MACROS_SETTINGS)
m13_color = input.color(default_color, '', inline = 'Macro13', group = MACROS_SETTINGS)

use_m14 = input.bool(true, 'Macro 14', inline = 'Macro14', group = MACROS_SETTINGS)
m14 = input.session('0950-1010', '', inline = 'Macro14', group = MACROS_SETTINGS)
m14_color = input.color(default_color, '', inline = 'Macro14', group = MACROS_SETTINGS)

use_m15 = input.bool(false, 'Macro 15', inline = 'Macro15', group = MACROS_SETTINGS)
m15 = input.session('1020-1040', '', inline = 'Macro15', group = MACROS_SETTINGS)
m15_color = input.color(default_color, '', inline = 'Macro15', group = MACROS_SETTINGS)

use_m16 = input.bool(true, 'Macro 16', inline = 'Macro16', group = MACROS_SETTINGS)
m16 = input.session('1050-1110', '', inline = 'Macro16', group = MACROS_SETTINGS)
m16_color = input.color(default_color, '', inline = 'Macro16', group = MACROS_SETTINGS)

use_m17 = input.bool(false, 'Macro 17', inline = 'Macro17', group = MACROS_SETTINGS)
m17 = input.session('1120-1140', '', inline = 'Macro17', group = MACROS_SETTINGS)
m17_color = input.color(default_color, '', inline = 'Macro17', group = MACROS_SETTINGS)

use_m18 = input.bool(true, 'Macro 18', inline = 'Macro18', group = MACROS_SETTINGS)
m18 = input.session('1150-1210', '', inline = 'Macro18', group = MACROS_SETTINGS)
m18_color = input.color(default_color, '', inline = 'Macro18', group = MACROS_SETTINGS)

use_m19 = input.bool(false, 'Macro 19', inline = 'Macro19', group = MACROS_SETTINGS)
m19 = input.session('1220-1240', '', inline = 'Macro19', group = MACROS_SETTINGS)
m19_color = input.color(default_color, '', inline = 'Macro19', group = MACROS_SETTINGS)

use_m20 = input.bool(false, 'Macro 20', inline = 'Macro20', group = MACROS_SETTINGS)
m20 = input.session('1250-1310', '', inline = 'Macro20', group = MACROS_SETTINGS)
m20_color = input.color(default_color, '', inline = 'Macro20', group = MACROS_SETTINGS)

use_m21 = input.bool(true, 'Macro 21', inline = 'Macro21', group = MACROS_SETTINGS)
m21 = input.session('1320-1340', '', inline = 'Macro21', group = MACROS_SETTINGS)
m21_color = input.color(default_color, '', inline = 'Macro21', group = MACROS_SETTINGS)

use_m22 = input.bool(false, 'Macro 22', inline = 'Macro22', group = MACROS_SETTINGS)
m22 = input.session('1350-1410', '', inline = 'Macro22', group = MACROS_SETTINGS)
m22_color = input.color(default_color, '', inline = 'Macro22', group = MACROS_SETTINGS)

use_m23 = input.bool(false, 'Macro 23', inline = 'Macro23', group = MACROS_SETTINGS)
m23 = input.session('1420-1440', '', inline = 'Macro23', group = MACROS_SETTINGS)
m23_color = input.color(default_color, '', inline = 'Macro23', group = MACROS_SETTINGS)

use_m24 = input.bool(true, 'Macro 24', inline = 'Macro24', group = MACROS_SETTINGS)
m24 = input.session('1450-1510', '', inline = 'Macro24', group = MACROS_SETTINGS)
m24_color = input.color(default_color, '', inline = 'Macro24', group = MACROS_SETTINGS)

use_m25 = input.bool(true, 'Macro 25', inline = 'Macro25', group = MACROS_SETTINGS)
m25 = input.session('1520-1540', '', inline = 'Macro25', group = MACROS_SETTINGS)
m25_color = input.color(default_color, '', inline = 'Macro25', group = MACROS_SETTINGS)

use_m26 = input.bool(true, 'Macro 26', inline = 'Macro26', group = MACROS_SETTINGS)
m26 = input.session('1550-1610', '', inline = 'Macro26', group = MACROS_SETTINGS)
m26_color = input.color(default_color, '', inline = 'Macro26', group = MACROS_SETTINGS)


var TRUE_MACRO_SETTINGS = 'True Macro Open'
line_show = input.bool(true, 'Show True Macro Open', group = TRUE_MACRO_SETTINGS, inline = 'TrueMacroOpen1')
line_color = input.color(color.black, 'Color', group = TRUE_MACRO_SETTINGS, inline = 'TrueMacroOpen2')
line_style = input.string('dotted', 'Style', options = ['solid', 'dotted', 'dashed'], group = TRUE_MACRO_SETTINGS, inline = 'TrueMacroOpen2')
line_width = input.int(1, 'Width', minval = 1, maxval = 5, group = TRUE_MACRO_SETTINGS, inline = 'TrueMacroOpen2')

line_style_val = line_style == 'solid' ? line.style_solid : line_style == 'dotted' ? line.style_dotted : line.style_dashed
// Inputs
// Var& Const
m1_time = not na(time('', m1, gmt_timezone))
m2_time = not na(time('', m2, gmt_timezone))
m3_time = not na(time('', m3, gmt_timezone))
m4_time = not na(time('', m4, gmt_timezone))
m5_time = not na(time('', m5, gmt_timezone))
m6_time = not na(time('', m6, gmt_timezone))
m7_time = not na(time('', m7, gmt_timezone))
m8_time = not na(time('', m8, gmt_timezone))
m9_time = not na(time('', m9, gmt_timezone))
m10_time = not na(time('', m10, gmt_timezone))
m11_time = not na(time('', m11, gmt_timezone))
m12_time = not na(time('', m12, gmt_timezone))
m13_time = not na(time('', m13, gmt_timezone))
m14_time = not na(time('', m14, gmt_timezone))
m15_time = not na(time('', m15, gmt_timezone))
m16_time = not na(time('', m16, gmt_timezone))
m17_time = not na(time('', m17, gmt_timezone))
m18_time = not na(time('', m18, gmt_timezone))
m19_time = not na(time('', m19, gmt_timezone))
m20_time = not na(time('', m20, gmt_timezone))
m21_time = not na(time('', m21, gmt_timezone))
m22_time = not na(time('', m22, gmt_timezone))
m23_time = not na(time('', m23, gmt_timezone))
m24_time = not na(time('', m24, gmt_timezone))
m25_time = not na(time('', m25, gmt_timezone))
m26_time = not na(time('', m26, gmt_timezone))


var m1_box = array.new_box()
var m2_box = array.new_box()
var m3_box = array.new_box()
var m4_box = array.new_box()
var m5_box = array.new_box()
var m6_box = array.new_box()
var m7_box = array.new_box()
var m8_box = array.new_box()
var m9_box = array.new_box()
var m10_box = array.new_box()
var m11_box = array.new_box()
var m12_box = array.new_box()
var m13_box = array.new_box()
var m14_box = array.new_box()
var m15_box = array.new_box()
var m16_box = array.new_box()
var m17_box = array.new_box()
var m18_box = array.new_box()
var m19_box = array.new_box()
var m20_box = array.new_box()
var m21_box = array.new_box()
var m22_box = array.new_box()
var m23_box = array.new_box()
var m24_box = array.new_box()
var m25_box = array.new_box()
var m26_box = array.new_box()


m1_text = ''
m2_text = ''
m3_text = ''
m4_text = ''
m5_text = ''
m6_text = ''
m7_text = ''
m8_text = ''
m9_text = ''
m10_text = ''
m11_text = ''
m12_text = ''
m13_text = ''
m14_text = ''
m15_text = ''
m16_text = ''
m17_text = ''
m18_text = ''
m19_text = ''
m20_text = ''
m21_text = ''
m22_text = ''
m23_text = ''
m24_text = ''
m25_text = ''
m26_text = ''


m1_color := color.new(m1_color, macros_transparency)
m2_color := color.new(m2_color, macros_transparency)
m3_color := color.new(m3_color, macros_transparency)
m4_color := color.new(m4_color, macros_transparency)
m5_color := color.new(m5_color, macros_transparency)
m6_color := color.new(m6_color, macros_transparency)
m7_color := color.new(m7_color, macros_transparency)
m8_color := color.new(m8_color, macros_transparency)
m9_color := color.new(m9_color, macros_transparency)
m10_color := color.new(m10_color, macros_transparency)
m11_color := color.new(m11_color, macros_transparency)
m12_color := color.new(m12_color, macros_transparency)
m13_color := color.new(m13_color, macros_transparency)
m14_color := color.new(m14_color, macros_transparency)
m15_color := color.new(m15_color, macros_transparency)
m16_color := color.new(m16_color, macros_transparency)
m17_color := color.new(m17_color, macros_transparency)
m18_color := color.new(m18_color, macros_transparency)
m19_color := color.new(m19_color, macros_transparency)
m20_color := color.new(m20_color, macros_transparency)
m21_color := color.new(m21_color, macros_transparency)
m22_color := color.new(m22_color, macros_transparency)
m23_color := color.new(m23_color, macros_transparency)
m24_color := color.new(m24_color, macros_transparency)
m25_color := color.new(m25_color, macros_transparency)
m26_color := color.new(m26_color, macros_transparency)

var m1_line = array.new_line()
var m2_line = array.new_line()
var m3_line = array.new_line()
var m4_line = array.new_line()
var m5_line = array.new_line()
var m6_line = array.new_line()
var m7_line = array.new_line()
var m8_line = array.new_line()
var m9_line = array.new_line()
var m10_line = array.new_line()
var m11_line = array.new_line()
var m12_line = array.new_line()
var m13_line = array.new_line()
var m14_line = array.new_line()
var m15_line = array.new_line()
var m16_line = array.new_line()
var m17_line = array.new_line()
var m18_line = array.new_line()
var m19_line = array.new_line()
var m20_line = array.new_line()
var m21_line = array.new_line()
var m22_line = array.new_line()
var m23_line = array.new_line()
var m24_line = array.new_line()
var m25_line = array.new_line()
var m26_line = array.new_line()
// Var& Const

// funtions
get_time_text(_session) =>
    startHour = str.substring(_session, 0, 2)
    startMin = str.substring(_session, 2, 4)
    endHour = str.substring(_session, 5, 7)
    endMin = str.substring(_session, 7, 9)
    startHour + ':' + startMin + '\n' + endHour + ':' + endMin

m1_text := get_time_text(m1)
m2_text := get_time_text(m2)
m3_text := get_time_text(m3)
m4_text := get_time_text(m4)
m5_text := get_time_text(m5)
m6_text := get_time_text(m6)
m7_text := get_time_text(m7)
m8_text := get_time_text(m8)
m9_text := get_time_text(m9)
m10_text := get_time_text(m10)
m11_text := get_time_text(m11)
m12_text := get_time_text(m12)
m13_text := get_time_text(m13)
m14_text := get_time_text(m14)
m15_text := get_time_text(m15)
m16_text := get_time_text(m16)
m17_text := get_time_text(m17)
m18_text := get_time_text(m18)
m19_text := get_time_text(m19)
m20_text := get_time_text(m20)
m21_text := get_time_text(m21)
m22_text := get_time_text(m22)
m23_text := get_time_text(m23)
m24_text := get_time_text(m24)
m25_text := get_time_text(m25)
m26_text := get_time_text(m26)


adjust(_box) =>
    _box.set_right(bar_index)
    _top = _box.get_top()
    _bot = _box.get_bottom()

    if high > _top
        _box.set_top(high)

    if low < _bot
        _box.set_bottom(low)

check_array(_arr) =>
    if _arr.size() > max_days
        _arr.pop().delete()

// funtions
// Core Logic
if timeframe.in_seconds('') <= timeframe.in_seconds(max_timeframe)
    // Macro 1
    if use_m1
        if m1_time and not m1_time[1]

            if show_macros
                m1_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m1_color, bgcolor = m1_color, text = show_macros_text ? m1_text : na, text_color = m1_color))

            if line_show
                m1_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m1_time
            if show_macros
                adjust(m1_box.get(0))

            if line_show
                line.set_x2(m1_line.get(0), bar_index)

    // Macro 2
    if use_m2
        if m2_time and not m2_time[1]

            if show_macros
                m2_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m2_color, bgcolor = m2_color, text = show_macros_text ? m2_text : na, text_color = m2_color))

            if line_show
                m2_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m2_time
            if show_macros
                adjust(m2_box.get(0))

            if line_show
                line.set_x2(m2_line.get(0), bar_index)

    // Macro 3
    if use_m3
        if m3_time and not m3_time[1]

            if show_macros
                m3_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m3_color, bgcolor = m3_color, text = show_macros_text ? m3_text : na, text_color = m3_color))

            if line_show
                m3_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m3_time
            if show_macros
                adjust(m3_box.get(0))

            if line_show
                line.set_x2(m3_line.get(0), bar_index)

    // Macro 4
    if use_m4
        if m4_time and not m4_time[1]

            if show_macros
                m4_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m4_color, bgcolor = m4_color, text = show_macros_text ? m4_text : na, text_color = m4_color))

            if line_show
                m4_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m4_time
            if show_macros
                adjust(m4_box.get(0))

            if line_show
                line.set_x2(m4_line.get(0), bar_index)

    // Macro 5
    if use_m5
        if m5_time and not m5_time[1]

            if show_macros
                m5_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m5_color, bgcolor = m5_color, text = show_macros_text ? m5_text : na, text_color = m5_color))

            if line_show
                m5_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m5_time
            if show_macros
                adjust(m5_box.get(0))

            if line_show
                line.set_x2(m5_line.get(0), bar_index)

    // Macro 6
    if use_m6
        if m6_time and not m6_time[1]

            if show_macros
                m6_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m6_color, bgcolor = m6_color, text = show_macros_text ? m6_text : na, text_color = m6_color))

            if line_show
                m6_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m6_time
            if show_macros
                adjust(m6_box.get(0))

            if line_show
                line.set_x2(m6_line.get(0), bar_index)

    // Macro 7
    if use_m7
        if m7_time and not m7_time[1]

            if show_macros
                m7_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m7_color, bgcolor = m7_color, text = show_macros_text ? m7_text : na, text_color = m7_color))

            if line_show
                m7_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m7_time
            if show_macros
                adjust(m7_box.get(0))

            if line_show
                line.set_x2(m7_line.get(0), bar_index)

    // Macro 8
    if use_m8
        if m8_time and not m8_time[1]

            if show_macros
                m8_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m8_color, bgcolor = m8_color, text = show_macros_text ? m8_text : na, text_color = m8_color))

            if line_show
                m8_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m8_time
            if show_macros
                adjust(m8_box.get(0))

            if line_show
                line.set_x2(m8_line.get(0), bar_index)

    // Macro 9
    if use_m9
        if m9_time and not m9_time[1]

            if show_macros
                m9_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m9_color, bgcolor = m9_color, text = show_macros_text ? m9_text : na, text_color = m9_color))

            if line_show
                m9_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m9_time
            if show_macros
                adjust(m9_box.get(0))

            if line_show
                line.set_x2(m9_line.get(0), bar_index)

    // Macro 10
    if use_m10
        if m10_time and not m10_time[1]

            if show_macros
                m10_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m10_color, bgcolor = m10_color, text = show_macros_text ? m10_text : na, text_color = m10_color))

            if line_show
                m10_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m10_time
            if show_macros
                adjust(m10_box.get(0))

            if line_show
                line.set_x2(m10_line.get(0), bar_index)

    // Macro 11
    if use_m11
        if m11_time and not m11_time[1]

            if show_macros
                m11_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m11_color, bgcolor = m11_color, text = show_macros_text ? m11_text : na, text_color = m11_color))

            if line_show
                m11_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m11_time
            if show_macros
                adjust(m11_box.get(0))

            if line_show
                line.set_x2(m11_line.get(0), bar_index)

    // Macro 12
    if use_m12
        if m12_time and not m12_time[1]

            if show_macros
                m12_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m12_color, bgcolor = m12_color, text = show_macros_text ? m12_text : na, text_color = m12_color))

            if line_show
                m12_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m12_time
            if show_macros
                adjust(m12_box.get(0))

            if line_show
                line.set_x2(m12_line.get(0), bar_index)

    // Macro 13
    if use_m13
        if m13_time and not m13_time[1]

            if show_macros
                m13_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m13_color, bgcolor = m13_color, text = show_macros_text ? m13_text : na, text_color = m13_color))

            if line_show
                m13_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m13_time
            if show_macros
                adjust(m13_box.get(0))

            if line_show
                line.set_x2(m13_line.get(0), bar_index)

    // Macro 14
    if use_m14
        if m14_time and not m14_time[1]

            if show_macros
                m14_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m14_color, bgcolor = m14_color, text = show_macros_text ? m14_text : na, text_color = m14_color))

            if line_show
                m14_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m14_time
            if show_macros
                adjust(m14_box.get(0))

            if line_show
                line.set_x2(m14_line.get(0), bar_index)

    // Macro 15
    if use_m15
        if m15_time and not m15_time[1]

            if show_macros
                m15_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m15_color, bgcolor = m15_color, text = show_macros_text ? m15_text : na, text_color = m15_color))

            if line_show
                m15_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m15_time
            if show_macros
                adjust(m15_box.get(0))

            if line_show
                line.set_x2(m15_line.get(0), bar_index)

    // Macro 16
    if use_m16
        if m16_time and not m16_time[1]

            if show_macros
                m16_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m16_color, bgcolor = m16_color, text = show_macros_text ? m16_text : na, text_color = m16_color))

            if line_show
                m16_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m16_time
            if show_macros
                adjust(m16_box.get(0))

            if line_show
                line.set_x2(m16_line.get(0), bar_index)

    // Macro 17
    if use_m17
        if m17_time and not m17_time[1]

            if show_macros
                m17_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m17_color, bgcolor = m17_color, text = show_macros_text ? m17_text : na, text_color = m17_color))

            if line_show
                m17_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m17_time
            if show_macros
                adjust(m17_box.get(0))

            if line_show
                line.set_x2(m17_line.get(0), bar_index)

    // Macro 18
    if use_m18
        if m18_time and not m18_time[1]

            if show_macros
                m18_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m18_color, bgcolor = m18_color, text = show_macros_text ? m18_text : na, text_color = m18_color))

            if line_show
                m18_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m18_time
            if show_macros
                adjust(m18_box.get(0))

            if line_show
                line.set_x2(m18_line.get(0), bar_index)

    // Macro 19
    if use_m19
        if m19_time and not m19_time[1]

            if show_macros
                m19_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m19_color, bgcolor = m19_color, text = show_macros_text ? m19_text : na, text_color = m19_color))

            if line_show
                m19_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m19_time
            if show_macros
                adjust(m19_box.get(0))

            if line_show
                line.set_x2(m19_line.get(0), bar_index)

    // Macro 20
    if use_m20
        if m20_time and not m20_time[1]

            if show_macros
                m20_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m20_color, bgcolor = m20_color, text = show_macros_text ? m20_text : na, text_color = m20_color))

            if line_show
                m20_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m20_time
            if show_macros
                adjust(m20_box.get(0))

            if line_show
                line.set_x2(m20_line.get(0), bar_index)

    // Macro 21
    if use_m21
        if m21_time and not m21_time[1]

            if show_macros
                m21_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m21_color, bgcolor = m21_color, text = show_macros_text ? m21_text : na, text_color = m21_color))

            if line_show
                m21_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m21_time
            if show_macros
                adjust(m21_box.get(0))

            if line_show
                line.set_x2(m21_line.get(0), bar_index)

    // Macro 22
    if use_m22
        if m22_time and not m22_time[1]

            if show_macros
                m22_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m22_color, bgcolor = m22_color, text = show_macros_text ? m22_text : na, text_color = m22_color))

            if line_show
                m22_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m22_time
            if show_macros
                adjust(m22_box.get(0))

            if line_show
                line.set_x2(m22_line.get(0), bar_index)

    // Macro 23
    if use_m23
        if m23_time and not m23_time[1]

            if show_macros
                m23_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m23_color, bgcolor = m23_color, text = show_macros_text ? m23_text : na, text_color = m23_color))

            if line_show
                m23_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m23_time
            if show_macros
                adjust(m23_box.get(0))

            if line_show
                line.set_x2(m23_line.get(0), bar_index)

    // Macro 24
    if use_m24
        if m24_time and not m24_time[1]

            if show_macros
                m24_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m24_color, bgcolor = m24_color, text = show_macros_text ? m24_text : na, text_color = m24_color))

            if line_show
                m24_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m24_time
            if show_macros
                adjust(m24_box.get(0))

            if line_show
                line.set_x2(m24_line.get(0), bar_index)

    // Macro 25
    if use_m25
        if m25_time and not m25_time[1]

            if show_macros
                m25_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m25_color, bgcolor = m25_color, text = show_macros_text ? m25_text : na, text_color = m25_color))

            if line_show
                m25_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m25_time
            if show_macros
                adjust(m25_box.get(0))

            if line_show
                line.set_x2(m25_line.get(0), bar_index)

    // Macro 26
    if use_m26
        if m26_time and not m26_time[1]

            if show_macros
                m26_box.unshift(box.new(bar_index, high, bar_index, low, border_color = m26_color, bgcolor = m26_color, text = show_macros_text ? m26_text : na, text_color = m26_color))

            if line_show
                m26_line.unshift(line.new(bar_index, open, bar_index + 1, open, color = line_color, width = line_width, style = line_style_val))

        else if m26_time
            if show_macros
                adjust(m26_box.get(0))

            if line_show
                line.set_x2(m26_line.get(0), bar_index)


check_array(m1_box)
check_array(m2_box)
check_array(m3_box)
check_array(m4_box)
check_array(m5_box)
check_array(m6_box)
check_array(m7_box)
check_array(m8_box)
check_array(m9_box)
check_array(m10_box)
check_array(m11_box)
check_array(m12_box)
check_array(m13_box)
check_array(m14_box)
check_array(m15_box)
check_array(m16_box)
check_array(m17_box)
check_array(m18_box)
check_array(m19_box)
check_array(m20_box)
check_array(m21_box)
check_array(m22_box)
check_array(m23_box)
check_array(m24_box)
check_array(m25_box)
check_array(m26_box)
// Core Logic
// Marcos
````
