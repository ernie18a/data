# Mr Balwants Liquidity Levels

- url: https://www.tradingview.com/script/NLoLoQgZ-Mr-Balwants-Liquidity-Levels/
- type: indicator
- pine_id: PUB;d52271aa207a4c49bf6c735e60d19c27
- version: 1.0

## Description

Minimalist Liquidity Levels

A clean and lightweight liquidity indicator designed to display important Daily, Weekly, and Monthly high/low levels directly on the chart.

The indicator automatically plots:

• Previous Day High (PDH)
• Previous Day Low (PDL)
• Current Day High (CDH)
• Current Day Low (CDL)

• Previous Week High (PWH)
• Previous Week Low (PWL)
• Current Week High (CWH)
• Current Week Low (CWL)

• Previous Month High (PMH)
• Previous Month Low (PML)
• Current Month High (CMH)
• Current Month Low (CML)

Features:
• Minimalist design
• Clean horizontal ray levels
• No labels or chart clutter
• Daily, Weekly, and Monthly liquidity references
• Works across all markets and timeframes
• Lightweight and fast

This indicator helps traders identify potential liquidity pools, support and resistance zones, and important market structure reference levels while maintaining a clean chart environment.

Ideal for:
• Price Action Traders
• ICT Traders
• Smart Money Concept (SMC) Traders
• Swing Traders
• Intraday Traders

Tags:
Liquidity, PDH, PDL, PWH, PWL, PMH, PML, Market Structure, Support Resistance, ICT, SMC, Price Action

## Source Code

````pine
//@version=6
indicator("Mr Balwants Liquidity Levels", overlay=true, max_lines_count=20)

// ───── INPUTS ─────
showPD = input.bool(true,  "Previous Day")
showCD = input.bool(true,  "Current Day")
showPW = input.bool(true,  "Previous Week")
showCW = input.bool(true,  "Current Week")
showPM = input.bool(true,  "Previous Month")
showCM = input.bool(true,  "Current Month")

gold = color.rgb(212, 175, 55)

// ───── LEVELS ─────
pdh = request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
cdh = request.security(syminfo.tickerid, "D", high,     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
cdl = request.security(syminfo.tickerid, "D", low,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

pwh = request.security(syminfo.tickerid, "W", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
cwh = request.security(syminfo.tickerid, "W", high,    gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
cwl = request.security(syminfo.tickerid, "W", low,     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

pmh = request.security(syminfo.tickerid, "M", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
pml = request.security(syminfo.tickerid, "M", low[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
cmh = request.security(syminfo.tickerid, "M", high,    gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
cml = request.security(syminfo.tickerid, "M", low,     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ───── LINE STORAGE ─────
var line pdhLine = na
var line pdlLine = na
var line cdhLine = na
var line cdlLine = na

var line pwhLine = na
var line pwlLine = na
var line cwhLine = na
var line cwlLine = na

var line pmhLine = na
var line pmlLine = na
var line cmhLine = na
var line cmlLine = na

// ───── HELPER ─────
f_setLine(_line, _show, _y) =>
    line out = _line
    if _show and not na(_y)
        if na(out)
            out := line.new(bar_index, _y, bar_index + 1, _y, extend=extend.right, color=gold, width=1)
        else
            line.set_xy1(out, bar_index, _y)
            line.set_xy2(out, bar_index + 1, _y)
            line.set_color(out, gold)
            line.set_width(out, 1)
    else
        if not na(out)
            line.delete(out)
            out := na
    out

// ───── UPDATE ON LAST BAR ─────
if barstate.islast
    pdhLine := f_setLine(pdhLine, showPD, pdh)
    pdlLine := f_setLine(pdlLine, showPD, pdl)
    cdhLine := f_setLine(cdhLine, showCD, cdh)
    cdlLine := f_setLine(cdlLine, showCD, cdl)

    pwhLine := f_setLine(pwhLine, showPW, pwh)
    pwlLine := f_setLine(pwlLine, showPW, pwl)
    cwhLine := f_setLine(cwhLine, showCW, cwh)
    cwlLine := f_setLine(cwlLine, showCW, cwl)

    pmhLine := f_setLine(pmhLine, showPM, pmh)
    pmlLine := f_setLine(pmlLine, showPM, pml)
    cmhLine := f_setLine(cmhLine, showCM, cmh)
    cmlLine := f_setLine(cmlLine, showCM, cml)
````
