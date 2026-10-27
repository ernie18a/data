# LTF FVGs (Lower Timeframe Fair Value Gaps) [D4A]

- url: https://www.tradingview.com/script/DMTCU6lN-LTF-FVGs-Lower-Timeframe-Fair-Value-Gaps-D4A/
- type: indicator
- pine_id: PUB;744bf80f650f4d598941df84fe01e703
- version: 1.0

## Description

[b]LTF FVGs - (Lower Timeframe FVGs)[/b] 

This script draws Fair Value Gaps on the chart that occured on lower timeframe, eg. 1m FVG is drawn on 5 min chart. The script uses request.security_lower_tf to get the lower timeframe data for this. There are several distinct features that make this script unique:
- the script automatically pulls FVGs from the most relevant lower timeframe (this can be manually changed at any time)
- the size of smallest FVGs can be customized based on ATR threshold
- Volume Imbalance can be included as part of FVG

This script can be useful for traders who want to be informed about any gaps created on lower timeframe without switching to lower timeframe chart.

[b]What is FVG?[/b]
FVG or Fair Value Gap is a three-candle formation where the middle candle moves so aggressively creating displacement that it leaves a gap between the wick of the prior candle and the wick of the following candle. Price often returns to fill these gaps before continuing — making them useful as targets, entry zones, or invalidation levels.

A bullish forms when the low of the current candle is above the high of two candles ago, with a bullish middle candle. A bearish FVG is the inverse.

FVGs often occur due to sudden market movements triggered by news events, changes in market sentiment, or large orders that move the price significantly. The market tend to return to these unfilled spaces, providing potential opportunities for traders. These areas may serve as either support (bullish FVG) or resistance (bearish FVG). They may also be completely filled by the price and then act as Inversion FVGs but this is outside of scope of this script. 

[b]SETTINGS[/b]
- Force Manual TF - the user can manually select lower timeframe from which the script can pull FVGs. When this option is not active, the script is pre-programmed to select lower timeframe automatically for FVG discovery which is at least one level below the current timeframe, eg. 15S when on 1m, 1m when on 5m and so on.
- FVG Fill and border transparency - customize the look of FVG boxes
- FVG threshold - set the threshold to eliminate very small gaps
- Volume Imbalance included - include Volume Imbalance as part of FVG. Enabled by default.
- Show LTF Label & Transparency - enable the label which shows from which timeframe is the FVG from
- Extend to Current Bar or by X-bars - customize how the FVG boxes are presented on the chart
- Max FVGs Displayed - how many FVGs should be kept in memory by default

When FVG is fully filled by price, the script removes it from the memory. 

Other relevant scripts that are complementary to this script: [url=https://www.tradingview.com/script/rbKoojB5-Candle-Displacement-D4A/]Candle Displacement[/url]

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator('LTF FVGs', 'FVGLTFT', overlay = true)

var g_LTFFVG = 'Lower Timeframe Fair Value Gaps'
override = input.bool(false, title = 'Force manual TF   ', inline = 'ltffvg0', group = g_LTFFVG, tooltip = 'When false, the script is pre-programmed to select lower timeframe for FVG discovery which is at least one level below the current timeframe, eg. 15S when on 1m, 1m when on 5m and so on.')
TF = input.timeframe('15', '', inline = 'ltffvg0', group = g_LTFFVG)
bull_fvg_c = input.color(color.new(color.green, 88), 'FVG Fill', inline = 'ltffvg1', group = g_LTFFVG)
bear_fvg_c = input.color(color.new(color.red, 88), '', inline = 'ltffvg1', group = g_LTFFVG)
transparency = input.int(80, 'Border Transp.', minval = 0, maxval = 100, inline = 'ltffvg1', group = g_LTFFVG)
filterLFVG = input.float(0.1, 'FVG Threshold', minval = 0, step = .1, group = g_LTFFVG, tooltip = 'Valid FVGs must have a range greater than this ATR filter')
VI_included = input.bool(true, 'Volume Imbalance Included?', group = g_LTFFVG, tooltip = 'Include Volume Imbalances between candles as part of the FVG.')
show_lbl = input.bool(true, 'Show LTF Label   ', inline = 'ltflbl1', group = g_LTFFVG)
lbl_transp = input.int(20, 'Transparency', minval = 0, maxval = 100, inline = 'ltflbl1', group = g_LTFFVG)
ext_now = input.bool(false, 'Extend To Current Bar      or By X bars', inline = 'ltffv2', group = g_LTFFVG)
extension = input.int(10, '', minval = 1, inline = 'ltffv2', group = g_LTFFVG)
max_fvg_count = input.int(12, 'Max FVGs Displayed', minval = 1, inline = 'ltffvg3', group = g_LTFFVG)

atr = nz(ta.atr(200))
filter_fvg(a, b) =>
    a - b > atr * filterLFVG

type LTF
	array<float> o
	array<float> h
	array<float> l
	array<float> c
	array<int> t

int ext = na
var ltfData = LTF.new(array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_int())
var ltfDataPrev = LTF.new(array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_int())
var array<box> bullFVGs = array.new<box>()
var array<box> bearFVGs = array.new<box>()
var bool fvg_processed = false

if timeframe.in_seconds('') == timeframe.in_seconds('1') and override == false
    TF := '15S'
    ext := 1
else if (timeframe.in_seconds('') == timeframe.in_seconds('2') or timeframe.in_seconds('') == timeframe.in_seconds('3') or timeframe.in_seconds('') == timeframe.in_seconds('4')) and override == false
    TF := '30S'
    ext := 3
else if timeframe.in_seconds('') == timeframe.in_seconds('5') and override == false
    TF := '1'
    ext := 5
else if timeframe.in_seconds('') == timeframe.in_seconds('15') and override == false
    TF := '5'
    ext := 15
else if timeframe.in_seconds('') == timeframe.in_seconds('30') and override == false
    TF := '15'
    ext := 30
else if timeframe.in_seconds('') == timeframe.in_seconds('60') and override == false
    TF := '15'
    ext := 60
else if timeframe.in_seconds('') == timeframe.in_seconds('240') and override == false
    TF := '60'
    ext := 240
else if timeframe.in_seconds('') == timeframe.in_seconds('1D') and override == false
    TF := '240'
    ext := 1440
else if timeframe.in_seconds('') == timeframe.in_seconds('1W') and override == false
    TF := '1D'
    ext := 10080
else if override == true
    ext := 60

ltfO = request.security_lower_tf(syminfo.tickerid, TF, open)
ltfH = request.security_lower_tf(syminfo.tickerid, TF, high)
ltfL = request.security_lower_tf(syminfo.tickerid, TF, low)
ltfC = request.security_lower_tf(syminfo.tickerid, TF, close)
ltfT = request.security_lower_tf(syminfo.tickerid, TF, time)

process_fvgs(ltfData) =>
    if ltfData.o.size() >= 3
        for i = 2 to ltfData.o.size() - 1 by 1
            o = array.get(ltfData.o, i)
            h = array.get(ltfData.h, i)
            l = array.get(ltfData.l, i)
            c = array.get(ltfData.c, i)
            o1 = array.get(ltfData.o, i - 1)
            h1 = array.get(ltfData.h, i - 1)
            l1 = array.get(ltfData.l, i - 1)
            c1 = array.get(ltfData.c, i - 1)
            o2 = array.get(ltfData.o, i - 2)
            h2 = array.get(ltfData.h, i - 2)
            l2 = array.get(ltfData.l, i - 2)
            c2 = array.get(ltfData.c, i - 2)
            t0 = array.get(ltfData.t, i)

            is_bull = h1 > h2 and l > h2 and l2 < l and filter_fvg(l, h2)
            is_bear = l1 < l2 and h < l2 and h2 > h and filter_fvg(l2, h)

            if is_bull
                top = VI_included and c > o and o > c1 ? o : VI_included and c < o and c > c1 ? c : l
                btm = VI_included and o2 < c2 and c2 < o1 ? c2 : h2
                boxRef = box.new(t0, top, ext_now ? time : t0 + 60 * 1000 * extension * ext, btm, xloc = xloc.bar_time, bgcolor = bull_fvg_c, border_color = color.new(bull_fvg_c, transparency), text = show_lbl ? str.tostring(TF) : na, text_color = color.new(bull_fvg_c, lbl_transp), text_size = size.small, text_halign = text.align_right)
                array.push(bullFVGs, boxRef)

            if is_bear
                top = VI_included and o2 > c2 and c2 > o1 ? c2 : l2
                btm = VI_included and o > c and o < c1 ? o : VI_included and o < c and c < c1 ? c : h
                boxRef = box.new(t0, top, ext_now ? time : t0 + 60 * 1000 * extension * ext, btm, xloc = xloc.bar_time, bgcolor = bear_fvg_c, border_color = color.new(bear_fvg_c, transparency), text = show_lbl ? str.tostring(TF) : na, text_color = color.new(bear_fvg_c, lbl_transp), text_size = size.small, text_halign = text.align_right)
                array.push(bearFVGs, boxRef)

check_cross_bar_fvgs() =>
    if ltfDataPrev.o.size() >= 2 and ltfData.o.size() >= 1
        o2 = array.get(ltfDataPrev.o, ltfDataPrev.o.size() - 2)
        h2 = array.get(ltfDataPrev.h, ltfDataPrev.o.size() - 2)
        l2 = array.get(ltfDataPrev.l, ltfDataPrev.o.size() - 2)
        c2 = array.get(ltfDataPrev.c, ltfDataPrev.o.size() - 2)

        o1 = array.get(ltfDataPrev.o, ltfDataPrev.o.size() - 1)
        h1 = array.get(ltfDataPrev.h, ltfDataPrev.o.size() - 1)
        l1 = array.get(ltfDataPrev.l, ltfDataPrev.o.size() - 1)
        c1 = array.get(ltfDataPrev.c, ltfDataPrev.o.size() - 1)
        t1 = array.get(ltfDataPrev.t, ltfDataPrev.o.size() - 1)

        o = array.get(ltfData.o, 0)
        h = array.get(ltfData.h, 0)
        l = array.get(ltfData.l, 0)
        c = array.get(ltfData.c, 0)
        t0 = array.get(ltfData.t, 0)

        is_bull = h1 > h2 and l > h2 and l2 < l and filter_fvg(l, h2)
        is_bear = l1 < l2 and h < l2 and h2 > h and filter_fvg(l2, h)

        if is_bull
            top = VI_included and c > o and o > c1 ? o : VI_included and c < o and c > c1 ? c : l
            btm = VI_included and o2 < c2 and c2 < o1 ? c2 : h2
            boxRef = box.new(t0, top, ext_now ? time : t0 + 60 * 1000 * extension * ext, btm, xloc = xloc.bar_time, bgcolor = bull_fvg_c, border_color = color.new(bull_fvg_c, transparency), text = show_lbl ? str.tostring(TF) : na, text_color = color.new(bull_fvg_c, lbl_transp), text_size = size.small, text_halign = text.align_right)
            array.push(bullFVGs, boxRef)

        if is_bear
            top = VI_included and o2 > c2 and c2 > o1 ? c2 : l2
            btm = VI_included and o > c and o < c1 ? o : VI_included and o < c and c < c1 ? c : h
            boxRef = box.new(t0, top, ext_now ? time : t0 + 60 * 1000 * extension * ext, btm, xloc = xloc.bar_time, bgcolor = bear_fvg_c, border_color = color.new(bear_fvg_c, transparency), text = show_lbl ? str.tostring(TF) : na, text_color = color.new(bear_fvg_c, lbl_transp), text_size = size.small, text_halign = text.align_right)
            array.push(bearFVGs, boxRef)

    if ltfDataPrev.o.size() >= 1 and ltfData.o.size() >= 2
        op2 = array.get(ltfDataPrev.o, ltfDataPrev.o.size() - 1)
        hp2 = array.get(ltfDataPrev.h, ltfDataPrev.o.size() - 1)
        lp2 = array.get(ltfDataPrev.l, ltfDataPrev.o.size() - 1)
        cp2 = array.get(ltfDataPrev.c, ltfDataPrev.o.size() - 1)
        tp2 = array.get(ltfDataPrev.t, ltfDataPrev.o.size() - 1)

        o1 = array.get(ltfData.o, 0)
        h1 = array.get(ltfData.h, 0)
        l1 = array.get(ltfData.l, 0)
        c1 = array.get(ltfData.c, 0)
        t1 = array.get(ltfData.t, 0)

        o = array.get(ltfData.o, 1)
        h = array.get(ltfData.h, 1)
        l = array.get(ltfData.l, 1)
        c = array.get(ltfData.c, 1)
        t0 = array.get(ltfData.t, 1)

        is_bull = h1 > hp2 and l > hp2 and lp2 < l and filter_fvg(l, hp2)
        is_bear = l1 < lp2 and h < lp2 and hp2 > h and filter_fvg(lp2, h)

        if is_bull
            top = VI_included and c > o and o > c1 ? o : VI_included and c < o and c > c1 ? c : l
            btm = VI_included and op2 < cp2 and cp2 < o1 ? cp2 : hp2
            boxRef = box.new(t0, top, ext_now ? time : t0 + 60 * 1000 * extension * ext, btm, xloc = xloc.bar_time, bgcolor = bull_fvg_c, border_color = color.new(bull_fvg_c, transparency), text = show_lbl ? str.tostring(TF) : na, text_color = color.new(bull_fvg_c, lbl_transp), text_size = size.small, text_halign = text.align_right)
            array.push(bullFVGs, boxRef)

        if is_bear
            top = VI_included and op2 > cp2 and cp2 > o1 ? cp2 : lp2
            btm = VI_included and o > c and o < c1 ? o : VI_included and o < c and c < c1 ? c : h
            boxRef = box.new(t0, top, ext_now ? time : t0 + 60 * 1000 * extension * ext, btm, xloc = xloc.bar_time, bgcolor = bear_fvg_c, border_color = color.new(bear_fvg_c, transparency), text = show_lbl ? str.tostring(TF) : na, text_color = color.new(bear_fvg_c, lbl_transp), text_size = size.small, text_halign = text.align_right)
            array.push(bearFVGs, boxRef)

if timeframe.change(timeframe.period)
    ltfDataPrev := LTF.new(array.copy(ltfData.o), array.copy(ltfData.h), array.copy(ltfData.l), array.copy(ltfData.c), array.copy(ltfData.t))

    ltfData.o := ltfO
    ltfData.h := ltfH
    ltfData.l := ltfL
    ltfData.c := ltfC
    ltfData.t := ltfT

    process_fvgs(ltfData)

    check_cross_bar_fvgs()

    fvg_processed := true

else if not fvg_processed
    process_fvgs(ltfData)

    if bar_index > 0
        check_cross_bar_fvgs()

    fvg_processed := true

cleanUp(array<box> arr, bool isBull) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0 by 1
            b = array.get(arr, i)
            top = box.get_top(b)
            btm = box.get_bottom(b)
            if isBull and close < btm or not isBull and close > top
                box.delete(b)
                array.remove(arr, i)
            if ext_now
                box.set_right(b, time + 1000 * extension * ext)

    while array.size(arr) > max_fvg_count
        box.delete(array.shift(arr))

cleanUp(bullFVGs, true)
cleanUp(bearFVGs, false)
````
