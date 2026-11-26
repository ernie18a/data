# cracks in correlation (smt)

- url: https://www.tradingview.com/script/U6DdvNoB-cracks-in-correlation-smt/
- type: indicator
- pine_id: PUB;fb95d933d0b949dcbbd46197c2d52ae3
- version: 1.0

## Description

introducing what (in my opinion) might be the best open-source smt divergence indicator yet!

as you may know, an SMT divergence forms when 2 correlated pairs' structure diverges (i.e. NQ makes a higher high and ES makes a lower high). when this happens, smart money traders take advantage of the "crack in correlation" and enter positions looking for the assets to converge again. with this indicator, you will NEVER miss an smt again!

allow me to bore you with the technicals for a bit. while most smt indicators only compare 2 pivots, this one (using the amazing ZigZag library by Trendoscope), allows us to compare up to 128 different pivots at once, ensuring that every high is compared with every other high. this setting is controlled using the "memory buffer" counter inside the inputs of the indicator. raising this setting will make the indicator take more time to load, but will also show you more potential smts. using this zigzag, we're able to check whether the corresponding asset's structure is the same as the current one.

all of the other settings should be self-explanatory, but should you have any questions, you can reach out to me in the comments below.

as this indicator is open-source, feel free to reuse it as you wish, but if you are re-using significant portions of it, please credit me. it would mean a lot to me :>

thank you for using my indicator. happy trading!

## Source Code

````pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © k4sual

//@version=6
indicator('𝕜 | cracks in correlation (smt)', overlay = true, format = format.price, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)
import Trendoscope/ZigzagLite/4 as zg

const string visualG = 'Display ________________________________________________________'
const string configG = 'Configuration ________________________________________________________'
const string configSMTG = 'Configuration - SMT ________________________________________________________'

type configSMT
    int len

    bool useSymbolA
    string symbolA

    bool useSymbolB
    string symbolB

type configGen
    bool detectionShow
    string sensitivity
    int memoryBufferSize
    bool deleteInvalidated
    int activeSMTMaxAge
    int confirmedSMTKeepBars

type cssSMT
    color uLink
    color dLink
    int linkW
    string linkStyle

    bool showLbl
    color lblUclr
    color lblDclr
    string lblSize

configGen cfgGenSMT = configGen.new(
     input.bool(false, '↯ Show Detection', tooltip = 'This setting visualizes the process for detecting SMT divergences. It looks very cool in sped-up replay mode.', group = configG),
     input.string('High', 'Sens.', ['Abysmal', 'Low', 'Med.', 'High', 'Insane'], tooltip = 'This script uses a ZigZag algorithm to detect SMTs. This setting changes the zigzag\'s sensitivity to new pivots.', group = configG),
     input.int(12, 'Memory Buffer', minval = 6, maxval = 256, step = 2, group = configG),
     input.bool(true, 'Hide invalidated SMTs', group = configG),
     300, // input.int(300, 'debug_ActiveSMTMaxAgeBarCount', minval = 1, maxval = 5000, group = configG, tooltip = 'SMTs older than this many bars are no longer considered active.'),
     1000 // input.int(1000, 'debug_ConfirmedSMTKeepForBarCount', minval = 1, maxval = 5000, group = configG, tooltip = 'Confirmed SMTs older than this many bars are removed from memory.')
     )
     
configSMT cfgSMT = configSMT.new(
     10, // placeholder
     input.bool(true, '', group = configSMTG, inline = 'symA', confirm = true),
     input.symbol('CME_MINI:ES1!', '', group = configSMTG, inline = 'symA', confirm = true),
     input.bool(false, '', group = configSMTG, inline = 'symB', confirm = true),
     input.symbol('CBOT_MINI:YM1!', '', group = configSMTG, inline = 'symB', confirm = true)
     )

cssSMT cosSMT = cssSMT.new(
     input.color(color.new(#8fadff, 50), 'Link —    ', group = visualG, inline = 'link'),
     input.color(color.new(#ffffff, 50), '', group = visualG, inline = 'link'),
     input.int(1, '', group = visualG, inline = 'link'),
     input.string('solid', '', group = visualG, inline = 'link', options = ['solid', 'dashed', 'dotted']),

     input.bool(true, 'Label', group = visualG, inline = 'lbl'),
     input.color(color.new(#8fadff, 75), '', group = visualG, inline = 'lbl'),
     input.color(color.new(#ffffff, 75), '', group = visualG, inline = 'lbl'),
     input.string('tiny', '', group = visualG, inline = 'lbl', options = ['tiny', 'small', 'normal', 'large', 'huge'])
     )

sensLen = switch cfgGenSMT.sensitivity
    'Abysmal' => 72
    'Low' => 32
    'Med.' => 12
    'High' => 6
    'Insane' => 2
    => 10 //
    

var zg.Zigzag smtMainZZ = zg.Zigzag.new(sensLen, cfgGenSMT.memoryBufferSize)
smtMainZZ.calculate()

var polyline analysisPL = na
var array<label> analysisDots = array.new<label>()

smtPvtArray = smtMainZZ.zigzagPivots

if cfgGenSMT.detectionShow
    if array.size(analysisDots) > 0
        for i = 0 to array.size(analysisDots) - 1
            analysisDots.get(i).delete()
        array.clear(analysisDots)

    if array.size(smtPvtArray) > 0
        for i = 0 to array.size(smtPvtArray) - 1
            pvt = smtPvtArray.get(i)
            pvtDir = pvt.dir

            analysisDot = label.new(
                 xloc = xloc.bar_index,
                 x = pvt.point.index,
                 y = pvt.point.price, 
                 style = label.style_circle,
                 text = str.tostring(i),
                 size = size.tiny,
                 color = math.sign(pvtDir) == 1 ? cosSMT.lblDclr : cosSMT.lblUclr)

            array.push(analysisDots, analysisDot)
    
method stripPrefix(string sym) =>
    int colon = str.pos(sym, ":")
    colon != -1 ? str.substring(sym, colon + 1) : sym

externalHi  = request.security(cfgSMT.symbolA, timeframe.period, high)
externalLo  = request.security(cfgSMT.symbolA, timeframe.period, low)
externalHiB = request.security(cfgSMT.symbolB, timeframe.period, high)
externalLoB = request.security(cfgSMT.symbolB, timeframe.period, low)

isDivergenceA() =>
    smtOK = false
    zg.Pivot pvtNewest     = na
    float pvtNewestPrice   = na
    zg.Pivot pvtOlder      = na
    float pvtOlderPrice    = na
    zg.Pivot pvtIntermediate = na
    if cfgSMT.useSymbolA and smtPvtArray.size() >= 4
        for i = 2 to smtPvtArray.size() - 1 by 2
            pvtNewest      := smtPvtArray.first()
            pvtNewestPrice := pvtNewest.point.price
            pvtOlder       := smtPvtArray.get(i)
            pvtOlderPrice  := pvtOlder.point.price

            pvtIntermediate := smtPvtArray.get(1)

            float pvtNewestComparePrice = na
            float pvtOlderComparePrice = na

            if math.sign(pvtNewest.dir) != math.sign(pvtOlder.dir)
                runtime.error('logic error: pivot directions dont match')
            else if math.sign(pvtNewest.dir) == 1
                pvtNewestComparePrice := externalHi[bar_index - pvtNewest.point.index]
                pvtOlderComparePrice  := externalHi[bar_index - pvtOlder.point.index]
            else if math.sign(pvtNewest.dir) == -1
                pvtNewestComparePrice := externalLo[bar_index - pvtNewest.point.index]
                pvtOlderComparePrice  := externalLo[bar_index - pvtOlder.point.index]

            if not na(pvtNewestComparePrice) and not na(pvtOlderComparePrice)
                if ((pvtNewestPrice > pvtOlderPrice) and not (pvtNewestComparePrice > pvtOlderComparePrice)) or ((pvtNewestPrice < pvtOlderPrice) and not (pvtNewestComparePrice < pvtOlderComparePrice))
                    log.info('SMT@{0} x {1}:A :pvtNewestPrice: {2} | pvtOlderPrice: {3} and pvtNewestComparePrice: {4} | pvtOlderComparePrice: {5}', 0, i, pvtNewestPrice, pvtOlderPrice, pvtNewestComparePrice, pvtOlderComparePrice)
                    log.info('size: {0}', i / 2)
                    smtOK := true
                    if (i > 2)
                        log.info('checking invl')
                        for j = 2 to i -1 by 2
                            pvtC = smtPvtArray.get(j)
                            if math.sign(pvtNewest.dir) == 1 and (pvtC.point.price > math.min(pvtNewestPrice, pvtOlderPrice))
                                log.info('^invalidated at {0}', j)
                                smtOK := false
                                break
                            else if math.sign(pvtNewest.dir) == -1 and (pvtC.point.price < math.max(pvtNewestPrice, pvtOlderPrice))
                                log.info('^invalidated at {0}', j)
                                smtOK := false
                                break
            if smtOK
                break
    [smtOK, pvtNewest, pvtOlder, pvtIntermediate]

isDivergenceB() =>
    smtOK = false
    zg.Pivot pvtNewest     = na
    float pvtNewestPrice   = na
    zg.Pivot pvtOlder      = na
    float pvtOlderPrice    = na
    zg.Pivot pvtIntermediate = na
    if cfgSMT.useSymbolB and smtPvtArray.size() >= 4
        for i = 2 to smtPvtArray.size() - 1 by 2
            pvtNewest      := smtPvtArray.first()
            pvtNewestPrice := pvtNewest.point.price
            pvtOlder       := smtPvtArray.get(i)
            pvtOlderPrice  := pvtOlder.point.price

            pvtIntermediate := smtPvtArray.get(1)

            float pvtNewestComparePrice = na
            float pvtOlderComparePrice = na

            if math.sign(pvtNewest.dir) != math.sign(pvtOlder.dir)
                runtime.error('logic error: pivot directions dont match')
            else if math.sign(pvtNewest.dir) == 1
                pvtNewestComparePrice := externalHiB[bar_index - pvtNewest.point.index]
                pvtOlderComparePrice  := externalHiB[bar_index - pvtOlder.point.index]
            else if math.sign(pvtNewest.dir) == -1
                pvtNewestComparePrice := externalLoB[bar_index - pvtNewest.point.index]
                pvtOlderComparePrice  := externalLoB[bar_index - pvtOlder.point.index]

            if not na(pvtNewestComparePrice) and not na(pvtOlderComparePrice)
                if ((pvtNewestPrice >= pvtOlderPrice) and not (pvtNewestComparePrice >= pvtOlderComparePrice)) or ((pvtNewestPrice <= pvtOlderPrice) and not (pvtNewestComparePrice <= pvtOlderComparePrice))
                    log.info('SMT@{0} x {1}:B, :pvtNewestPrice: {2} | pvtOlderPrice: {3} and pvtNewestComparePrice: {4} | pvtOlderComparePrice: {5}', 0, i, pvtNewestPrice, pvtOlderPrice, pvtNewestComparePrice, pvtOlderComparePrice)
                    log.info('size: {0}', i / 2)
                    smtOK := true
                    if (i > 2)
                        for j = 2 to i -1 by 2
                            pvtC = smtPvtArray.get(j)
                            if math.sign(pvtNewest.dir) == 1 and (pvtC.point.price > math.min(pvtNewestPrice, pvtOlderPrice))
                                log.info('^invalidated at {0}', j)
                                smtOK := false
                                break
                            else if math.sign(pvtNewest.dir) == -1 and (pvtC.point.price < math.max(pvtNewestPrice, pvtOlderPrice))
                                log.info('^invalidated at {0}', j)
                                smtOK := false
                                break
            if smtOK
                break
    [smtOK, pvtNewest, pvtOlder, pvtIntermediate]

[isCurrentSMTA, pvtNewestA, pvtOlderA, pvtIntermediateA] = isDivergenceA()
[isCurrentSMTB, pvtNewestB, pvtOlderB, pvtIntermediateB] = isDivergenceB()

type smtLinkCalc
    chart.point anchorA
    chart.point anchorB
    chart.point anchorZ
    string symbol
    float dir

    bool invalidated
    int invalidationIndex = na
    bool validated
    int validationIndex = na

type confirmedArraySwitcher
    array<smtLinkCalc> chart 
    array<smtLinkCalc> other 

varip smtRawArrA = array.new<smtLinkCalc>()
varip smtRawArrB = array.new<smtLinkCalc>()
varip smtConfirmedArrA = confirmedArraySwitcher.new(chart = array.new<smtLinkCalc>(), other = array.new<smtLinkCalc>())
varip smtConfirmedArrB = confirmedArraySwitcher.new(chart = array.new<smtLinkCalc>(), other = array.new<smtLinkCalc>())

calcSMT(isCurrentSMT, pvtNewest, pvtOlder, pvtIntermediate, symbol, array<smtLinkCalc> smtRawArr) =>
    if isCurrentSMT and bar_index > (last_bar_index - 2500) and not na(pvtNewest) and not na(pvtOlder)
        anchorA = chart.point.new(0, pvtNewest.point.index, pvtNewest.point.price)
        anchorB = chart.point.new(0, pvtOlder.point.index, pvtOlder.point.price)
        anchorZ = chart.point.new(0, pvtIntermediate.point.index, pvtIntermediate.point.price)

        smtRawArr.push(smtLinkCalc.new(anchorA, anchorB, anchorZ, symbol, -math.sign(pvtNewest.dir)))

calcSMT(isCurrentSMTA, pvtNewestA, pvtOlderA, pvtIntermediateA, 'A', smtRawArrA)
calcSMT(isCurrentSMTB, pvtNewestB, pvtOlderB, pvtIntermediateB, 'B', smtRawArrB)

confirmSMT(array<smtLinkCalc> smtRawArr, confirmedArraySwitcher smtConfirmedArrSw) =>
    if smtRawArr.size() > 0
        rSmt = smtRawArr.last()
        rAP = rSmt.anchorA.price
        rBP = rSmt.anchorB.price
        if ((smtConfirmedArrSw.chart.size() < 1) or (smtConfirmedArrSw.other.size() < 1))
            if (rSmt.dir == 1 and rAP < rBP) or
                 (rSmt.dir == -1 and rAP > rBP) and
                 smtConfirmedArrSw.chart.size() < 1
                smtConfirmedArrSw.chart.push(rSmt)
            else if smtConfirmedArrSw.other.size() < 1
                smtConfirmedArrSw.other.push(rSmt)
            smtRawArr.clear()
        else if smtRawArr.size() > 0
            for smt in smtRawArr
                aP = smt.anchorA.price
                bP = smt.anchorB.price
                lastConfirmedSMT = (smt.dir == 1 and aP < bP) or (smt.dir == -1 and aP > bP) ? smtConfirmedArrSw.chart.last() : smtConfirmedArrSw.other.last() 
                if (smt.dir == 1 and aP < bP) or 
                     (smt.dir == -1 and aP > bP)
                    if smt.anchorB.index != lastConfirmedSMT.anchorB.index
                        log.info('{0} != {1}', smt.anchorB.index, lastConfirmedSMT.anchorB.index)
                        smtConfirmedArrSw.chart.push(smt)
                    else
                        smtConfirmedArrSw.chart.pop()
                        smtConfirmedArrSw.chart.push(smt)
                else
                    if smt.anchorB.index != lastConfirmedSMT.anchorB.index
                        log.info('{0} != {1}', smt.anchorB.index, lastConfirmedSMT.anchorB.index)
                        smtConfirmedArrSw.other.push(smt)
                    else
                        smtConfirmedArrSw.other.pop()
                        smtConfirmedArrSw.other.push(smt)
            smtRawArr.clear()

confirmSMT(smtRawArrA, smtConfirmedArrA)
confirmSMT(smtRawArrB, smtConfirmedArrB)

type smtLinkDraw
    smtLinkCalc data
    line link
    label lbl
    line linkInvalidation
    line linkValidation

var smtDrawArrA = array.new<smtLinkDraw>()
var smtDrawArrB = array.new<smtLinkDraw>()

if smtDrawArrA.size() > 0
    for i = 0 to array.size(smtDrawArrA) - 1
        smtDrawArrA.get(i).link.delete()
        smtDrawArrA.get(i).lbl.delete()
        smtDrawArrA.get(i).linkInvalidation.delete()
    array.clear(smtDrawArrA)

if smtDrawArrB.size() > 0
    for i = 0 to array.size(smtDrawArrB) - 1
        smtDrawArrB.get(i).link.delete()
        smtDrawArrB.get(i).lbl.delete()
        smtDrawArrB.get(i).linkInvalidation.delete()
    array.clear(smtDrawArrB)

drawSMT(smtLinkCalc linkCalc) =>
    if not na(linkCalc)
        string style = switch cosSMT.linkStyle
            'solid'  => line.style_solid
            'dashed' => line.style_dashed
            'dotted' => line.style_dotted
            => line.style_solid

        string size = switch cosSMT.lblSize
            'tiny'   => size.tiny
            'small'  => size.small
            'normal' => size.normal
            'large'  => size.large
            'huge'   => size.large
            => size.tiny

        string labelText = na

        if linkCalc.dir == 1
            labelText := linkCalc.symbol == 'A' ? cfgSMT.symbolA.stripPrefix() : linkCalc.symbol == 'B' ? cfgSMT.symbolB.stripPrefix() + '\n' : ''
        else if linkCalc.dir == -1
            labelText := linkCalc.symbol == 'A' ? cfgSMT.symbolA.stripPrefix() : linkCalc.symbol == 'B' ? '\n' + cfgSMT.symbolB.stripPrefix() : ''

        link = line.new(
            chart.point.from_index(linkCalc.anchorA.index, linkCalc.anchorA.price + syminfo.mintick * 5 * -math.sign(linkCalc.dir)),
            chart.point.from_index(linkCalc.anchorB.index, linkCalc.anchorB.price + syminfo.mintick * 5 * -math.sign(linkCalc.dir)),
            color = linkCalc.invalidated ? cfgGenSMT.deleteInvalidated ? color.new(color.black, 100) : color.new(color.red, 50) : linkCalc.dir == 1 ? cosSMT.uLink : cosSMT.dLink,
            width = cosSMT.linkW,
            style = style)

        aP = linkCalc.anchorA.price
        bP = linkCalc.anchorB.price
        zP = linkCalc.anchorZ.price

        invalidated = linkCalc.invalidated

        line linkInvalidation = na
        if (linkCalc.dir == 1 and aP < bP) or 
             (linkCalc.dir == -1 and aP > bP)
            linkInvalidation := line.new(
                linkCalc.anchorB,
                chart.point.from_index(invalidated ? linkCalc.invalidationIndex : linkCalc.anchorA.index + 2, linkCalc.anchorB.price),
                color = cfgGenSMT.deleteInvalidated ? color.new(color.black, 100) : color.new(color.gray, 25),
                width = cosSMT.linkW,
                style = line.style_dotted
            )

        line linkValidation = na
        if (linkCalc.dir == 1 and aP < bP) or
             (linkCalc.dir == -1 and aP > bP)
            linkValidation := line.new(
                linkCalc.anchorZ,
                chart.point.from_index(linkCalc.anchorA.index + 2, linkCalc.anchorZ.price),
                color = cfgGenSMT.deleteInvalidated ? color.new(color.black, 100): color.new(color.white, 25),
                width = cosSMT.linkW,
                style = line.style_dotted
            )
            
        lblChartPoint = chart.point.from_index((linkCalc.anchorA.index + linkCalc.anchorB.index) / 2, ((linkCalc.anchorA.price + linkCalc.anchorB.price) / 2 + syminfo.mintick * 5 * -math.sign(linkCalc.dir)))
        lbl = cosSMT.showLbl ? label.new(
            lblChartPoint,
            text = labelText,
            color = color.new(color.black, 100),
            textcolor = (cfgGenSMT.deleteInvalidated and linkCalc.invalidated) ? color.new(color.black, 100) : linkCalc.dir == 1 ? color.new(cosSMT.lblUclr, 10) : color.new(cosSMT.lblDclr, 10),
            style = linkCalc.dir == -1 ? label.style_label_down : label.style_label_up,
            size = size,
            text_font_family = font.family_monospace
        ) : na

        smtLinkDraw.new(linkCalc, link, lbl, linkInvalidation)


// log.info('smtConfirmedArrA.size() = {0} and {1}', smtConfirmedArrA.chart.size(), smtConfirmedArrA.other.size())
// log.info('smtRawArrA.size() = {0}', smtRawArrA.size())
// log.info('smtConfirmedArrB.size() = {0} and {1}', smtConfirmedArrB.chart.size(), smtConfirmedArrB.other.size())
// log.info('smtRawArrB.size() = {0}', smtRawArrB.size())

method priceHit(float this, float hi, float lo) =>
    (hi >= this and lo <= this)

method pruneConfirmedSMTArray(array<smtLinkCalc> smtArr, int keepBars) =>
    if smtArr.size() > 0
        for i = smtArr.size() - 1 to 0 by 1
            smtD = smtArr.get(i)
            newestAnchorIndex = math.max(smtD.anchorA.index, smtD.anchorB.index, smtD.anchorZ.index)
            if bar_index - newestAnchorIndex > keepBars
                smtArr.remove(i)

method checkInvalidation(array<smtLinkCalc> smtArr, symbol) =>
    if smtArr.size() > 0
        symHigh = request.security(symbol, timeframe.period, high)
        symLow = request.security(symbol, timeframe.period, low)
        for i = 0 to smtArr.size() - 1
            smtD = smtArr.get(i)
            aP = smtD.anchorA.price
            bP = smtD.anchorB.price
            topDot = math.sign(smtD.dir) == 1
            aPS = topDot ? symHigh[bar_index - smtD.anchorA.index] : symLow[bar_index - smtD.anchorA.index]
            bPS = topDot ? symHigh[bar_index - smtD.anchorB.index] : symLow[bar_index - smtD.anchorB.index]
            if ((smtD.dir == 1 and aP < bP and high > bP) or 
                 (smtD.dir == -1 and aP > bP and low < bP)) and not (smtD.invalidated or smtD.validated)
                log.info('smt invalidation')
                smtD.invalidationIndex := bar_index
                smtD.invalidated := true
            else if ((smtD.dir == 1 and aPS < bPS and symHigh > bPS) or
                 (smtD.dir == -1 and aPS > bPS and symLow < bPS)) and not (smtD.invalidated or smtD.validated)
                log.info('smt invalidation')
                smtD.invalidated := true

method checkValidation(array<smtLinkCalc> smtArr, symbol) =>
    if smtArr.size() > 0
        symHigh = request.security(symbol, timeframe.period, high)
        symLow = request.security(symbol, timeframe.period, low)
        symClose = request.security(symbol, timeframe.period, close)
        for i = 0 to smtArr.size() - 1
            smtD = smtArr.get(i)
            aP = smtD.anchorA.price
            bP = smtD.anchorB.price
            zP = smtD.anchorZ.price
            topDot = math.sign(smtD.dir) == 1
            aPS = topDot ? symHigh[bar_index - smtD.anchorA.index] : symLow[bar_index - smtD.anchorA.index]
            bPS = topDot ? symHigh[bar_index - smtD.anchorB.index] : symLow[bar_index - smtD.anchorB.index]
            zPS = topDot ? symHigh[bar_index - smtD.anchorZ.index] : symLow[bar_index - smtD.anchorZ.index]
            if ((smtD.dir == 1 and aP < bP and close < zP) or
                (smtD.dir == -1 and aP > bP and close > zP)) and not (smtD.invalidated or smtD.validated)
                log.info('smt validated')
                smtD.validationIndex := bar_index
                smtD.validated := true
            else if ((smtD.dir == 1 and aPS < bPS and symClose < zPS) or 
                (smtD.dir == -1 and aPS > bPS and symClose > zPS)) and not (smtD.invalidated or smtD.validated)
                log.info('smt validated')
                smtD.validated := true
            
smtConfirmedArrA.chart.checkInvalidation(cfgSMT.symbolA)
smtConfirmedArrA.chart.checkValidation(cfgSMT.symbolA)
smtConfirmedArrA.other.checkInvalidation(cfgSMT.symbolA)
smtConfirmedArrA.other.checkValidation(cfgSMT.symbolA)
smtConfirmedArrB.chart.checkInvalidation(cfgSMT.symbolB)
smtConfirmedArrB.chart.checkValidation(cfgSMT.symbolB)
smtConfirmedArrB.other.checkInvalidation(cfgSMT.symbolB)
smtConfirmedArrB.other.checkValidation(cfgSMT.symbolB)

smtConfirmedArrA.chart.pruneConfirmedSMTArray(cfgGenSMT.confirmedSMTKeepBars)
smtConfirmedArrA.other.pruneConfirmedSMTArray(cfgGenSMT.confirmedSMTKeepBars)
smtConfirmedArrB.chart.pruneConfirmedSMTArray(cfgGenSMT.confirmedSMTKeepBars)
smtConfirmedArrB.other.pruneConfirmedSMTArray(cfgGenSMT.confirmedSMTKeepBars)

if smtConfirmedArrA.chart.size() > 0
    for i = 0 to smtConfirmedArrA.chart.size() -1
        smtDrawArrA.push(drawSMT(smtConfirmedArrA.chart.get(i)))
if smtConfirmedArrA.other.size() > 0
    for i = 0 to smtConfirmedArrA.other.size() -1
        smtDrawArrA.push(drawSMT(smtConfirmedArrA.other.get(i)))

if smtConfirmedArrB.chart.size() > 0
    for i = 0 to smtConfirmedArrB.chart.size() -1
        smtDrawArrB.push(drawSMT(smtConfirmedArrB.chart.get(i)))
if smtConfirmedArrB.other.size() > 0
    for i = 0 to smtConfirmedArrB.other.size() -1
        smtDrawArrB.push(drawSMT(smtConfirmedArrB.other.get(i)))

type smtFlag
    int activeSMTCount
    array<smtLinkCalc> activeSMTArr

smtFlagA = smtFlag.new(0, array.new<smtLinkCalc>())
smtFlagB = smtFlag.new(0, array.new<smtLinkCalc>())

updateActiveSMTFlag(confirmedArraySwitcher smtConfirmedArrSw, smtFlag smtFlagObj) =>
    array.clear(smtFlagObj.activeSMTArr)

    if smtConfirmedArrSw.chart.size() > 0
        for smt in smtConfirmedArrSw.chart
            newestAnchorIndex = math.max(smt.anchorA.index, smt.anchorB.index, smt.anchorZ.index)
            isFresh = bar_index - newestAnchorIndex <= cfgGenSMT.activeSMTMaxAge
            if isFresh and not smt.invalidated and not smt.validated
                array.push(smtFlagObj.activeSMTArr, smt)

    if smtConfirmedArrSw.other.size() > 0
        for smt in smtConfirmedArrSw.other
            newestAnchorIndex = math.max(smt.anchorA.index, smt.anchorB.index, smt.anchorZ.index)
            isFresh = bar_index - newestAnchorIndex <= cfgGenSMT.activeSMTMaxAge
            if isFresh and not smt.invalidated and not smt.validated
                array.push(smtFlagObj.activeSMTArr, smt)

    smtFlagObj.activeSMTCount := array.size(smtFlagObj.activeSMTArr)

updateActiveSMTFlag(smtConfirmedArrA, smtFlagA)
updateActiveSMTFlag(smtConfirmedArrB, smtFlagB)
````
