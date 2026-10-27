# Fair Value Gaps by DGT

- url: https://www.tradingview.com/script/Onab2fvE-Fair-Value-Gaps-by-DGT/
- type: indicator
- pine_id: PUB;bddd296a97e5457892a4f47c088cc699
- version: 4.0

## Description

[b]Fair Value Gaps[/b]
A refined, multi-timeframe Fair Value Gap (FVG) detection tool that brings institutional imbalance zones to life directly on your chart.
Designed for precision, it visualizes how price delivers into inefficiencies across chart, higher, and lower (intrabar) timeframes — offering a fluid, structural view of liquidity displacement and market flow.

The script continuously tracks unfilled, partially repaired, and fully resolved imbalances, revealing where liquidity inefficiencies concentrate and where price may seek rebalancing.
Overlapping zones naturally expose institutional footprints, potential liquidity targets, and key re-pricing regions within the broader market structure.

[b]KEY FEATURES[/b]

[b]⯌ Multi-Timeframe Detection[/b]
[quote]Detect and display FVGs from the current chart, higher timeframes (HTF), or lower timeframes (LTF)[/quote][image]https://www.tradingview.com/x/5LNx1wiy/[/image]

[b]⯌ Smart Fill Tracking[/b]
[quote]Automatic real-time monitoring of each FVG’s fill progress with live percentage updates[/quote][image]https://www.tradingview.com/x/caSKOoP4/[/image]

[b]⯌ Custom Fill Logic[/b]
[quote]Choose your preferred definition of when a gap is considered filled:[list][*]Any Touch
[*]Midpoint Reached
[*]Wick Sweep
[*]Body Beyond[/quote][/list][image]https://www.tradingview.com/x/nGbFzTGY/[/image]

[b]⯌ Dynamic Labels & Tooltips[/b]
[quote]Labels can be toggled on/off. Even when hidden, detailed tooltips remain available by hovering over the FVG midpoint.[/quote][image]https://www.tradingview.com/x/nRcR03KC/[/image]

[b]⯌ Adaptive Lower-Timeframe Mode[/b]
[quote]When set to “Auto,” the script intelligently selects the optimal lower timeframe based on the chart resolution.[/quote][image]https://www.tradingview.com/x/XpeflKh8/[/image]

[b]DISCLAIMER[/b]

This script is intended for informational and educational purposes only. It does not constitute financial, investment, or trading advice. All trading decisions made based on its output are solely the responsibility of the user.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
//# *
//# * Study       : Fair Value Gaps
//# * Author      : © dgtrd
//# *
//# * Revision History
//# *  Release    : Oct 13, 2025
//# *  Update     : Oct 01, 2026 : Inverse FVGs (iFVG) added for FVG #1 / #2
//# *
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

indicator('Fair Value Gaps by DGT', 'FVGs ☼☾', true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------//
// Settings
//---------------------------------------------------------------------------------------------------------------------//

display = display.all - display.status_line

fvgGR = 'Fair Value Gaps #1, Chart/HTF'

fvgTip1 = 'Select the timeframe from which Fair Value Gaps (FVGs) will be detected.\n' +
         '• Chart — uses the current chart timeframe.\n' +
         '• Higher timeframes — plots FVGs derived from the selected timeframe above the chart.\n\n' +
         'If a lower timeframe than the chart is selected, the script automatically defaults to the chart timeframe.'

fvgFillTip1 = 'Defines how a Fair Value Gap (FVG) is considered filled:\n' +
             '• Any Touch — when price (wick or body) touches any part of the imbalance zone.\n' +
             '• Midpoint Reached — when price trades to at least the midpoint (50%) of the zone.\n' +
             '• Wick Sweep — when a wick fully passes through the entire FVG and returns inside the zone.\n' +
             '• Body Beyond — when the candle body closes beyond the opposite edge of the FVG, confirming full repair.'

fvgLBTip1 = 'Controls the visibility of Fair Value Gap (FVG) labels.\n\n' +
             '• **Show** — displays labels directly on the chart. Each label indicates the timeframe and fill progress of the zone.\n' +
             '• **Hide** — hides on-chart labels, but tooltips remain accessible by hovering over the midpoint of each FVG zone.'

fvgSH1 = input.bool(true, 'Fair Value Gaps #1, Chart/HTF', inline = 'fvg1', group = fvgGR)
fvgTF1 = input.string('Chart', '', options = ['Chart', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day', '1 Week', '1 Month'], inline = 'fvg1', group = fvgGR, tooltip = fvgTip1, display = display)
fvgFill1 = input.string('Wick Sweep', '  FVG #1 Fill Method', options = ['Any Touch', 'Midpoint Reached', 'Wick Sweep', 'Body Beyond'], display = display, tooltip = fvgFillTip1, group = fvgGR)
fvgCb1 = input.color(#00B8D9, '  FVG #1 Zones    ', inline = 'fvg', group = fvgGR)
fvgCs1 = input.color(#FF8B00, '', inline = 'fvg', group = fvgGR)
fvgLB1 = input.string('Show', '  FVG #1 Labels', options = ['Show', 'Hide'], inline = 'REV', tooltip = fvgLBTip1, display = display, group = fvgGR)
fvgSize1 = input.string('Small', '',  group = fvgGR, display = display, inline = 'REV', options = ['Tiny', 'Small', 'Normal'])
fvgTxt1 = fvgSize1 == 'Normal' ? size.normal : fvgSize1 == 'Small' ? size.small : size.tiny

maxBars = input.int(360, '  Max Bars Back', minval = 1, step = 20, group = fvgGR, display = display, tooltip = 'This determines how far back the script will analyze for Fair Value Gaps.')

ifvgTip1 = 'Inverse FVG (IFVG) — a Fair Value Gap that has failed as support/resistance and flips polarity.\n\n' +
           '• A Bullish FVG that price closes below (beyond its bottom edge) becomes a Bearish IFVG (expected resistance).\n' +
           '• A Bearish FVG that price closes above (beyond its top edge) becomes a Bullish IFVG (expected support).\n\n' +
           'The IFVG zone keeps the original FVG boundaries. From the candles that originated the FVG until the inversion it is drawn with solid lines in the original FVG colour; ' +
           'from the inversion onwards it continues with dashed lines in the IFVG colour. ' +
           'Bullish IFVGs use the FVG bullish colour, Bearish IFVGs use the FVG bearish colour.\n\n' +
           'Inversion follows the ICT definition: a candle CLOSE beyond the far edge of the FVG, independent of the selected FVG Fill Method.\n\n' +
           'A filled FVG stops being an inversion candidate once price closes back beyond its near edge (the FVG held). ' +
           'An active IFVG is removed once price closes back through its far edge (the IFVG itself has failed).\n\n' +
           'IFVGs are independent of the FVG checkbox: untick Fair Value Gaps #1 to show IFVGs only (FVGs are still tracked in the background, just not drawn).\n\n' +
           'With labels shown, the IFVG label carries a fill percentage: how deep price has re-entered the zone since the inversion.'

ifvgSH1 = input.bool(false, 'Inverse FVGs from FVG #1', group = fvgGR, tooltip = ifvgTip1)


fvgGR2 = 'Fair Value Gaps #2, Chart/HTF'

fvgTip2 = 'Select the timeframe from which Fair Value Gaps (FVGs) will be detected.\n' +
         '• Auto — picks the smallest supported higher timeframe that is at least 4× the chart timeframe:\n' +
         '\t\t1 min\t\t→ 5 min\n' +
         '\t\t2-3 min\t→ 15 min\n' +
         '\t\t5-15 min\t→ 1 hour\n' +
         '\t\t30 min-1 hour\t→ 4 hours\n' +
         '\t\t2-4 hour\t→ 1 day\n' +
         '\t\t1 day\t\t→ 1 week\n' +
         '\t\t1 week\t\t→ 1 month\n' +
         '\t\t1 month\t→ Chart\n' +
         '• Chart — uses the current chart timeframe.\n' +
         '• Higher timeframes — plots FVGs derived from the selected timeframe above the chart.\n\n' +
         'If a lower timeframe than the chart is selected, the script automatically defaults to the chart timeframe.'

fvgSH2 = input.bool(false, 'Fair Value Gaps #2, Chart/HTF', inline = 'fvg2', group = fvgGR2)
fvgTF2 = input.string('Auto', '', options = ['Auto', 'Chart', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day', '1 Week', '1 Month'], inline = 'fvg2', group = fvgGR2, tooltip = fvgTip2, display = display)
fvgFill2 = input.string('Wick Sweep', '  FVG #2 Fill Method', options = ['Any Touch', 'Midpoint Reached', 'Wick Sweep', 'Body Beyond'], display = display, tooltip = fvgFillTip1, group = fvgGR2)
fvgCb2 = input.color(#6EE7B7, '  FVG #2 Zones    ', inline = 'fvg', group = fvgGR2)
fvgCs2 = input.color(#FF6B6B, '', inline = 'fvg', group = fvgGR2)
fvgLB2 = input.string('Hide', '  FVG #2 Labels', options = ['Show', 'Hide'], inline = 'REV', tooltip = fvgLBTip1, display = display, group = fvgGR2)
fvgSize2 = input.string('Small', '',  group = fvgGR2, display = display, inline = 'REV', options = ['Tiny', 'Small', 'Normal'])
fvgTxt2 = fvgSize2 == 'Normal' ? size.normal : fvgSize2 == 'Small' ? size.small : size.tiny

maxBars2 = input.int(360, '  Max Bars Back', minval = 1, step = 20, group = fvgGR2, display = display, tooltip = 'This determines how far back the script will analyze for Fair Value Gaps.')

ifvgTip2 = 'Same behaviour as FVG #1 IFVGs, applied to Fair Value Gaps #2. Works even when the Fair Value Gaps #2 checkbox is unticked (IFVGs only).'
ifvgSH2 = input.bool(false, 'Inverse FVGs from FVG #2', group = fvgGR2, tooltip = ifvgTip2)

fvgGR3 = 'Fair Value Gaps #3, LTF'
fvgTip3 = 'Intrabar timeframe (lower timeframe, LTF) setting option. ' +
         'When set to "Auto", the lower timeframe is determined by the following algorithm:\n' +
         '  Chart Timeframe → Lower Timeframe\n' +
         '\t\t<= 3 min\t\t→ 15 sec\n' +
         '\t\t<= 30 min\t\t→ 1 min\n' +
         '\t\t<= 2 hour\t\t→ 5 min\n' +
         '\t\t<= 4 hour\t\t→ 15 min\n' +
         '\t\t<= 1 day\t\t→ 1 hour\n' +
         '\t\t<= 1 week\t\t→ 4 hour\n' +
         '\t\t<= 1 month\t→ 1 day\n' +
         '\t\t>  1 month\t→ 1 week'

fvgSH3 = input.bool(false, 'Fair Value Gaps #3, LTF', inline = 'fvg3', group = fvgGR3)

fvgTF3 = input.string('Auto', '', 
    options = ['Auto', '1S', '5S', '10S', '15S', '30S', '1m', '3m', '5m', '15m', '30m', '45m', '1H', '2H', '3H', '4H', 'D'], inline = 'fvg3', display = display, group = fvgGR3, tooltip = fvgTip3)
fvgThTip = 'Checks the significance of the detected fair value gap compared to a fixed-length average true range. ' + 'Setting the value to 0 means that no filtering will be applied, whereas values greater than zero determine the filtering threshold value'
fvgTH3 = input.float(.7, '  FVG Filter Threshold', minval = 0, step = .1, group = fvgGR3, tooltip = fvgThTip, display = display)

fvgCb3 = input.color(#8BC34A, '  FVG #3 Zones    ', inline = 'VD', group = fvgGR3)
fvgCs3 = input.color(#E91E63, '', inline = 'VD', group = fvgGR3)

fvgLBTip3 = 'Controls the visibility of lower-timeframe Fair Value Gap (FVG) labels.\n\n' +
               '• Show — displays labels for each detected LTF FVG, indicating the source lower timeframe of the zone.\n' +
               '• Hide — hides the on-chart labels, while tooltips remain available when hovering over the midpoint of each LTF FVG zone.'
fvgLB3 = input.string('Hide', '  FVG #3 Labels', options = ['Show', 'Hide'], inline = 'REV', tooltip = fvgLBTip3, display = display, group = fvgGR3)
fvgSize3 = input.string('Small', '',  group = fvgGR3, display = display, inline = 'REV', options = ['Tiny', 'Small', 'Normal'])
fvgTxt3 = fvgSize3 == 'Normal' ? size.normal : fvgSize3 == 'Small' ? size.small : size.tiny

//---------------------------------------------------------------------------------------------------------------------//
// User Defined Types
//---------------------------------------------------------------------------------------------------------------------//

type BAR
    float open  = open
    float high  = high
    float low   = low
    float close = close
    int   index = bar_index

    float ltfHigh
    float ltfHigh1
    float ltfHigh2
    float ltfLow
    float ltfLow1
    float ltfLow2
    float ltfClose
    float ltfClose1

type HTFBar
    float price = na
    int   index = na

type HTFBarOHLC
    HTFBar open
    HTFBar high
    HTFBar low
    HTFBar close

type FVG
    label  lbTxt
    line   lnTop
    line   lnAvg
    line   lnBtm
    float  mitPrice
    float  mit
    string txt
    float  top       
    float  btm
    int    xTop      
    int    xMid
    int    xBtm

type FVGW
    float top
    float btm
    int   born
    int   xTop
    int   xMid
    int   xBtm

type IFVG
    label  lbTxt
    line   lnTop
    line   lnAvg
    line   lnBtm
    string side
    float  mit       
    string txt
    int    born      
    line   sTop     
    line   sBtm

BAR bar = BAR.new()
noColor = #00000000

//---------------------------------------------------------------------------------------------------------------------//
// Functions / Methods
//---------------------------------------------------------------------------------------------------------------------//

ltfTF(_t) =>
    str.contains(_t, 'S') or str.contains(_t, 'D') or str.contains(_t, 'W') or str.contains(_t, 'M') ? _t : 
     str.contains(_t, 'm') ? str.replace(_t, 'm', '', 0) : str.contains(_t, 'H') ? str.tostring(str.tonumber(str.replace(_t, 'H', '', 0)) * 60) : '12M'


ltfTF() =>
    int tfInMs = timeframe.in_seconds(timeframe.period)
    int mInMS = 60
    switch 
        tfInMs <= 1 * mInMS => '5S'
        tfInMs <= 3 * mInMS => '15S'
        tfInMs <= 30 * mInMS => '1'
        tfInMs <= 120 * mInMS => '5'
        tfInMs <= 240 * mInMS => '15'
        tfInMs <= 1440 * mInMS => '60'
        tfInMs <= 7 * 1440 * mInMS => '240'
        tfInMs <= 31 * 1440 * mInMS => 'D'
        => 'W'

autoHtf(_chartMin) =>
    float m = _chartMin * 4
    m <= 5 ? '5' : m <= 15 ? '15' : m <= 60 ? '60' : m <= 240 ? '240' : m <= 1440 ? 'D' : m <= 10080 ? 'W' : m <= 43200 ? 'M' : timeframe.period

htfTF(usrTF) =>
    float chartTFin = timeframe.in_seconds() / 60

    switch 
        usrTF == 'Auto' => autoHtf(chartTFin)
        usrTF == '5 Minutes' and chartTFin <= 5 => '5'
        usrTF == '15 Minutes' and chartTFin <= 15 => '15'
        usrTF == '1 Hour' and chartTFin <= 60 => '60'
        usrTF == '4 Hours' and chartTFin <= 240 => '240'
        usrTF == '1 Day' and timeframe.isintraday => 'D'
        usrTF == '1 Week' and (timeframe.isdaily or timeframe.isintraday) => 'W'
        usrTF == '1 Month' and (timeframe.isweekly or timeframe.isdaily or timeframe.isintraday) => 'M'
        => timeframe.period

updateFvg(fvgArray, fill, side, fvgLb, watchArray, ifvgOn, fvgVis) =>

    if fvgArray.size() > 0
        for i = array.size(fvgArray) - 1 to 0
            this = array.get(fvgArray, i)

            if side == "bull" ? (fill == 'Body Beyond' ? bar.close : bar.low) <= this.mitPrice : (fill == 'Body Beyond' ? bar.close : bar.high) >= this.mitPrice

                if ifvgOn
                    watchArray.unshift(FVGW.new(this.top, this.btm, bar.index, this.xTop, this.xMid, this.xBtm))

                fvgArray.remove(i)

                if fvgVis
                    this.lbTxt.delete()
                    this.lnTop.delete()
                    this.lnAvg.delete()
                    this.lnBtm.delete()
            else
                if fvgVis
                    this.lbTxt.set_x(bar.index + 1)
                    this.lnTop.set_x2(bar.index + 1)
                    this.lnAvg.set_x2(bar.index + 1)
                    this.lnBtm.set_x2(bar.index + 1)

                fillRatio = switch side
                    "bull" => (this.top - bar.low)  / (this.top - this.btm)
                    "bear" => (bar.high - this.btm) / (this.top - this.btm)
                    => 0.0

                if fillRatio > this.mit
                    this.mit := fillRatio
                    if fvgVis
                        this.lbTxt.set_text( fvgLb == 'Show' ? this.txt + str.format("{0,number,(#.#%)}", fillRatio) : '')

checkInversion(watchArray, ifvgArray, side, fvgLb, tfTxt, cBull, cBear, fvgTxt) =>

    if watchArray.size() > 0
        for i = watchArray.size() - 1 to 0
            w = watchArray.get(i)

            bool held     = side == 'bull' ? bar.close > w.top : bar.close < w.btm
            bool inverted = side == 'bull' ? bar.close < w.btm : bar.close > w.top

            if held or inverted
                watchArray.remove(i)

                if inverted

                    bool bullIfvg = side == 'bear'
                    color c       = bullIfvg ? cBull : cBear
                    float mid     = math.avg(w.top, w.btm)
                    string src    = bullIfvg ? 'Bullish IFVG (inverted Bearish FVG)' : 'Bearish IFVG (inverted Bullish FVG)'
                    string tip    = tfTxt + ' ' + src + '\n\nZone Top · ' + str.format("{0, number, #,###.##}", w.top) + '\nZone Mid · ' + str.format("{0, number, #,###.##}", mid) + '\nZone Btm · ' + str.format("{0, number, #,###.##}", w.btm)

                    color cFvg = bullIfvg ? cBear : cBull
                    line  sTop = line.new(w.xTop, w.top, bar.index, w.top, color = color.new(cFvg, side == 'bull' ? 65 : 50), width = side == 'bull' ? 1 : 2)
                    line  sBtm = line.new(w.xBtm, w.btm, bar.index, w.btm, color = color.new(cFvg, side == 'bull' ? 50 : 65), width = side == 'bull' ? 2 : 1)
                    linefill.new(sTop, sBtm, color.new(cFvg, 89))

                    ifvgArray.unshift(
                     IFVG.new(
                         label.new(bar.index + 1, mid, fvgLb == 'Show' ? tfTxt + ' iFVG' : '', xloc.bar_index, color = noColor, style = label.style_label_left, textcolor = c, size = fvgTxt, tooltip = tip),
                         line.new(bar.index, w.top, bar.index + 1, w.top, color = color.new(c, 50), style = line.style_dashed),
                         line.new(bar.index, mid,   bar.index + 1, mid,   color = color.new(c, 25), style = line.style_dotted),
                         line.new(bar.index, w.btm, bar.index + 1, w.btm, color = color.new(c, 50), style = line.style_dashed),
                         bullIfvg ? 'bull' : 'bear', 0.0, tfTxt + ' iFVG', bar.index, sTop, sBtm)
                     )

                    first = ifvgArray.first()
                    linefill.new(first.lnTop, first.lnBtm, color.new(c, 92))

                    if ifvgArray.size() > 25
                        old = ifvgArray.pop()
                        old.lbTxt.delete()
                        old.lnTop.delete()
                        old.lnAvg.delete()
                        old.lnBtm.delete()
                        old.sTop.delete()
                        old.sBtm.delete()

updateIfvg(ifvgArray, fvgLb) =>

    if ifvgArray.size() > 0
        for i = ifvgArray.size() - 1 to 0
            this = ifvgArray.get(i)

            zTop = this.lnTop.get_y1()
            zBtm = this.lnBtm.get_y1()

            if this.side == 'bull' ? bar.close < zBtm : bar.close > zTop
                ifvgArray.remove(i)

                this.lbTxt.delete()
                this.lnTop.delete()
                this.lnAvg.delete()
                this.lnBtm.delete()
                this.sTop.delete()
                this.sBtm.delete()
            else
                this.lbTxt.set_x(bar.index + 1)
                this.lnTop.set_x2(bar.index + 1)
                this.lnAvg.set_x2(bar.index + 1)
                this.lnBtm.set_x2(bar.index + 1)

                float ratio = this.side == 'bull' ? (zTop - bar.low) / (zTop - zBtm) : (bar.high - zBtm) / (zTop - zBtm)
                ratio := math.min(ratio, 1.0)

                if bar.index > this.born and ratio > this.mit
                    this.mit := ratio
                    this.lbTxt.set_text(fvgLb == 'Show' ? this.txt + str.format("{0,number,(#.#%)}", ratio) : '')

renderFvg(show, tfIn, fill, cBull, cBear, fvgLb, fvgVis, ifvgOn, fvgTxt) =>

    if show
        var array<FVG> bullFvgArray = array.new<FVG>()
        var array<FVG> bearFvgArray = array.new<FVG>()
        var array<HTFBarOHLC> barArray = array.new<HTFBarOHLC>()

        var array<FVGW> bullWatch  = array.new<FVGW>()
        var array<FVGW> bearWatch  = array.new<FVGW>()
        var array<IFVG> ifvgArray  = array.new<IFVG>()

        var HTFBar barOpen = HTFBar.new(bar.open, bar.index)
        var HTFBar barHigh = HTFBar.new(bar.high, bar.index)
        var HTFBar barLow = HTFBar.new(bar.low, bar.index)
        var HTFBar barClose = HTFBar.new(bar.close, bar.index)

        var barHist = HTFBarOHLC.new(barOpen, barHigh, barLow, barClose)

        var int bullBarIndexEnd = na
        var int bullBarIndexEnd1 = na
        var int bearBarIndexEnd = na
        var int bearBarIndexEnd1 = na

        var bool bullProcess = false
        var bool bullCondition = false
        var bool bearProcess = false
        var bool bearCondition = false

        var bool bullG = false
        var bool bearG = false

        string tf = htfTF(tfIn)
        fvgTf = tf == timeframe.period

        //log.info("yaz_kizim {0} {1}", htfATR, tf)

        if timeframe.change(tf)
            bullProcess := false
            bearProcess := false

            if barArray.size() > 2
                barArray.pop()

            barArray.unshift(barHist)

            barOpen  := HTFBar.new(bar.open, bar.index)
            barHigh  := HTFBar.new(bar.high, bar.index)
            barLow   := HTFBar.new(bar.low, bar.index)
            barClose := HTFBar.new(bar.close, bar.index)

            barHist  := HTFBarOHLC.new(barOpen, barHigh, barLow, barClose) 

            bullBarIndexEnd1 := bullBarIndexEnd
            bullBarIndexEnd  := bar.index
            bearBarIndexEnd1 := bearBarIndexEnd
            bearBarIndexEnd  := bar.index
            bearBarIndexEnd

        else
            if bar.high > barHigh.price
                barHigh.price := bar.high
                barHigh.index := bar.index
                barHigh.index

            if bar.low < barLow.price
                barLow.price := bar.low
                barLow.index := bar.index
                barLow.index

            barClose.price := bar.close
            barClose.index := bar.index

            if barArray.size() > 2
                if bar.low < barArray.get(1).high.price
                    bullBarIndexEnd := bar.index
                    bullBarIndexEnd

                if bar.high > barArray.get(1).low.price
                    bearBarIndexEnd := bar.index
                    bearBarIndexEnd

        if barArray.size() > 2
            bullG := barArray.get(0).low.price > barArray.get(1).high.price or barArray.get(1).low.price > barArray.get(2).high.price
            bullCondition := barArray.get(0).low.price > barArray.get(2).high.price and barArray.get(1).close.price > barArray.get(2).high.price and not bullG

            bearG := barArray.get(0).high.price < barArray.get(1).low.price or barArray.get(1).high.price < barArray.get(2).low.price
            bearCondition := barArray.get(0).high.price < barArray.get(2).low.price and barArray.get(1).close.price < barArray.get(2).low.price and not bearG

        if bullCondition and not bullProcess
            bullProcess := true

            float  zTop = barArray.get(0).low.price
            float  zBtm = barArray.get(2).high.price
            float  zMid = math.avg(zTop, zBtm)
            int    xTop = barArray.get(0).low.index
            int    xBtm = barArray.get(2).high.index
            int    xMid = math.ceil(math.avg(xTop, xBtm))
            string fTxt = fvgTf ? 'Chart(' + tf + ') FVG' : 'HTF(' + tf + ') FVG'

            label lb = na
            line  lT = na
            line  lM = na
            line  lB = na

            if fvgVis
                lb := label.new(bar.index + 1, zMid, fvgLb == 'Show' ? fTxt : '', xloc.bar_index, color = noColor, style = label.style_label_left, textcolor = cBull, size = fvgTxt, 
                 tooltip = (fvgTf ? 'Chart(' + tf + ') Bullish FVG' : 'HTF(' + tf + ') Bullish FVG') + '\n\nZone Top · ' + str.format("{0, number, #,###.##}", zTop) + '\nZone Mid · ' + str.format("{0, number, #,###.##}", zMid) + '\nZone Btm · ' + str.format("{0, number, #,###.##}", zBtm))
                lT := line.new(xTop, zTop, bar.index + 1, zTop, color = color.new(cBull, 65))
                lM := line.new(xMid, zMid, bar.index + 1, zMid, style = line.style_dotted, color = color.new(cBull, 25))
                lB := line.new(xBtm, zBtm, bar.index + 1, zBtm, color = color.new(cBull, 50), width = 2)
                linefill.new(lT, lB, color.new(cBull, 89))

            bullFvgArray.unshift(FVG.new(lb, lT, lM, lB, fill == 'Midpoint Reached' ? zMid : fill == 'Any Touch' ? zTop : zBtm, 0, fTxt, zTop, zBtm, xTop, xMid, xBtm))

        if bearCondition and not bearProcess
            bearProcess := true

            float  zTop = barArray.get(2).low.price
            float  zBtm = barArray.get(0).high.price
            float  zMid = math.avg(zTop, zBtm)
            int    xTop = barArray.get(2).low.index
            int    xBtm = barArray.get(0).high.index
            int    xMid = math.ceil(math.avg(xTop, xBtm))
            string fTxt = fvgTf ? 'Chart(' + tf + ') FVG' : 'HTF(' + tf + ') FVG'

            label lb = na
            line  lT = na
            line  lM = na
            line  lB = na

            if fvgVis
                lb := label.new(bar.index + 1, zMid, fvgLb == 'Show' ? fTxt : '', xloc.bar_index, color = noColor, style = label.style_label_left, textcolor = cBear, size = fvgTxt, 
                 tooltip = (fvgTf ? 'Chart(' + tf + ') Bearish FVG' : 'HTF(' + tf + ') Bearish FVG') + '\n\nZone Top · ' + str.format("{0, number, #,###.##}", zTop) + '\nZone Mid · ' + str.format("{0, number, #,###.##}", zMid) + '\nZone Btm · ' + str.format("{0, number, #,###.##}", zBtm))
                lT := line.new(xTop, zTop, bar.index + 1, zTop, color = color.new(cBear, 50), width = 2)
                lM := line.new(xMid, zMid, bar.index + 1, zMid, style = line.style_dotted, color = color.new(cBear, 25))
                lB := line.new(xBtm, zBtm, bar.index + 1, zBtm, color = color.new(cBear, 65))
                linefill.new(lT, lB, color.new(cBear, 89))

            bearFvgArray.unshift(FVG.new(lb, lT, lM, lB, fill == 'Midpoint Reached' ? zMid : fill == 'Any Touch' ? zBtm : zTop, 0, fTxt, zTop, zBtm, xTop, xMid, xBtm))


        updateFvg(bullFvgArray, fill, 'bull', fvgLb, bullWatch, ifvgOn, fvgVis)
        updateFvg(bearFvgArray, fill, 'bear', fvgLb, bearWatch, ifvgOn, fvgVis)

        if ifvgOn
            string tfTxt = fvgTf ? 'Chart(' + tf + ')' : 'HTF(' + tf + ')'
            checkInversion(bullWatch, ifvgArray, 'bull', fvgLb, tfTxt, cBull, cBear, fvgTxt)
            checkInversion(bearWatch, ifvgArray, 'bear', fvgLb, tfTxt, cBull, cBear, fvgTxt)
            updateIfvg(ifvgArray, fvgLb)


//---------------------------------------------------------------------------------------------------------------------//
// Calculations
//---------------------------------------------------------------------------------------------------------------------//

var fvgLTFbx = array.new_box()
var fvgLTFlb = array.new_label()

ltf = fvgTF3 == 'Auto' ? ltfTF() : ltfTF(fvgTF3)
[aO, aH, aL, aC, atr] = request.security_lower_tf(syminfo.tickerid, ltf, [bar.open, bar.high, bar.low, bar.close, ta.atr(13)])

if fvgSH3 and timeframe.change(timeframe.period) and array.size(aH) > 0 

    for i = 0 to aH.size() - 1 by 1

        bar.ltfClose1 := bar.ltfClose
        bar.ltfClose  := aC.get(i)

        bar.ltfHigh2  := bar.ltfHigh1
        bar.ltfHigh1  := bar.ltfHigh
        bar.ltfHigh   := aH.get(i)

        bar.ltfLow2   := bar.ltfLow1
        bar.ltfLow1   := bar.ltfLow
        bar.ltfLow    := aL.get(i)

        bull = bar.ltfLow - bar.ltfHigh2 > atr.get(i) * fvgTH3 and bar.ltfLow > bar.ltfHigh2 and bar.ltfClose1 > bar.ltfHigh2

        if bull
            fvgLTFbx.push(box.new(bar.index, bar.ltfLow, bar.index + 1, bar.ltfHigh2, color.new(fvgCb3, 73), bgcolor = color.new(fvgCb3, 73))) 
            fvgLTFlb.push(
             label.new(bar.index + 1, math.avg(bar.ltfLow, bar.ltfHigh2), fvgLB3 == 'Show' ? 'LTF(' + ltf + ') FVG' : '', xloc.bar_index, color = noColor, style = label.style_label_left, textcolor = fvgCb3, size = fvgTxt3, 
                  tooltip = 'LTF(' + ltf + ') Bullish FVG' )
             )

        bear = bar.ltfLow2 - bar.ltfHigh > atr.get(i) * fvgTH3 and bar.ltfHigh < bar.ltfLow2 and bar.ltfClose1 < bar.ltfLow2

        if bear
            fvgLTFbx.push(box.new(bar.index, bar.ltfLow2, bar.index + 1, bar.ltfHigh, color.new(fvgCs3, 73), bgcolor = color.new(fvgCs3, 73)))
            fvgLTFlb.push(
             label.new(bar.index + 1, math.avg(bar.ltfLow2, bar.ltfHigh), fvgLB3 == 'Show' ? 'LTF(' + ltf + ') FVG' : '', xloc.bar_index, color = noColor, style = label.style_label_left, textcolor = fvgCs3, size = fvgTxt3, 
                  tooltip = 'LTF(' + ltf + ') Bearish FVG' )
             )

        if fvgLTFbx.size() > 0
            qt = fvgLTFbx.size()

            for bn = qt - 1 to 0 by 1
                if bn < fvgLTFbx.size()

                    cBX = fvgLTFbx.get(bn)
                    cLB = fvgLTFlb.get(bn)
                    tBX = cBX.get_top()
                    bBX = cBX.get_bottom()

                    if bar.ltfHigh >= tBX and bar.ltfLow <= bBX
                        cBX.delete()
                        fvgLTFbx.remove(bn)
                        fvgLTFlb.remove(bn)
                        cLB.delete()
                    else
                        if bar.ltfHigh > bBX and bar.ltfHigh < tBX
                            cBX.set_bottom(bar.ltfHigh)
                            cLB.set_y(math.avg(cBX.get_top(), bar.ltfHigh))

                        if bar.ltfLow < tBX and bar.ltfLow > bBX
                            cBX.set_top(bar.ltfLow)
                            cLB.set_y(math.avg(cBX.get_bottom(), bar.ltfLow))

        if fvgLTFbx.size() > 250
            cBX = fvgLTFbx.shift()
            cLB = fvgLTFlb.shift()
            cBX.delete()
            cLB.delete()

if fvgLTFbx.size() > 0
    qt = fvgLTFbx.size()

    for bn = qt - 1 to 0 by 1
        if bn < fvgLTFbx.size()

            cBX = fvgLTFbx.get(bn)
            cLB = fvgLTFlb.get(bn)
            tBX = cBX.get_top()
            bBX = cBX.get_bottom()

            if bar.high > tBX and bar.low < bBX and bar.index > cBX.get_left()
                fvgLTFbx.remove(bn)
                cBX.delete()
                fvgLTFlb.remove(bn)
                cLB.delete()
            else
                cBX.set_right(bar.index + 1)
                cBX.set_border_color(na)
                cLB.set_x(bar.index + 1)


if last_bar_index - bar_index <= maxBars and (fvgSH1 or ifvgSH1)
    renderFvg(fvgSH1 or ifvgSH1, fvgTF1, fvgFill1, fvgCb1, fvgCs1, fvgLB1, fvgSH1, ifvgSH1, fvgTxt1)

if last_bar_index - bar_index <= maxBars2 and (fvgSH2 or ifvgSH2)
    renderFvg(fvgSH2 or ifvgSH2, fvgTF2, fvgFill2, fvgCb2, fvgCs2, fvgLB2, fvgSH2, ifvgSH2, fvgTxt2)

var table logo = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(logo, 0, 0, '☼☾  ', text_size = size.normal, text_color = color.teal, tooltip = 'SoleMare Analytics')
````
