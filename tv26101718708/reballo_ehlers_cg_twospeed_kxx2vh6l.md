# Reballo Ehlers CG - Two-Speed

- url: https://www.tradingview.com/script/kxx2VH6l-Reballo-Ehlers-CG-Two-Speed/
- type: indicator
- pine_id: PUB;52624a5729604618a2c56471d82c466a
- version: 1.0

## Description

[b]What it is[/b]

John Ehlers' Center of Gravity oscillator, normalised to a ±1 range and run at two very different speeds at once. Most CG scripts run one length around 10-20 bars and use it for swing entries. This one runs [b]128 and 256 bars[/b] and averages them. That turns it from an entry tool into a [b]"how deep in the hole are we" gauge[/b].

[b]How it's built[/b]

[list]
[*]Center of Gravity = the weighted mean position of price inside the window. Price sitting near the recent highs pulls the CG one way, price near the lows pulls it the other.
[*]The CG is rescaled against its own highest / lowest over the same window, so it lives in [0, 1] regardless of the instrument.
[*]A short 4-bar FIR smooth (4, 3, 2, 1 weights) takes out the jitter, then it's mapped to [-1, +1].
[*]Run that twice (fast and slow), then average. The [b]white line[/b] is the average. The grey lines are the two inputs.
[/list]

[b]Reading it[/b]

[list]
[*][b]Below -0.8 (red zone):[/b] both the medium and slow view agree that price is pinned to the bottom of its range. "Washed out."
[*][b]Above +0.8 (green zone):[/b] the opposite. "Stretched."
[*][b]In between:[/b] nothing to see. That's most of the time on purpose.
[/list]

Because the two speeds have to [i]agree[/i], the zones fire rarely. On SPY daily you'll typically see a handful of red episodes per decade: 2008, Mar 2020, Oct 2022 and the like.

[b]How I use it[/b]

Not for entries. As a [b]risk gate[/b]: when the average is washed out and other breadth / internals are also ugly, that's a "stop adding risk" flag, not a "buy the

## Source Code

````pine
// Reballo Ehlers CG - Two-Speed
// Free / open-source component of the Reballo Forecast Stack
//@version=6
indicator('Reballo Ehlers CG - Two-Speed', shorttitle = 'Reballo CG x2', overlay = false, precision = 2)

//=============================================================================
// WHAT THIS DOES
//-----------------------------------------------------------------------------
// John Ehlers' Center of Gravity oscillator, normalised to a ±1 range and run
// at two very different speeds (128 / 256 bars by default). The AVERAGE of the
// two is the line that matters: when both a medium and a slow view of price
// agree that we are pinned to the bottom of the recent range, the market is
// "washed out". Used as a risk gate, not as an entry signal.
//=============================================================================

//-----------------------------------------------------------------------------
// INPUTS
//-----------------------------------------------------------------------------
GRP_SRC = 'Source'
src = input.source(hl2, 'Source', group = GRP_SRC)

GRP_LEN = 'Speeds (bars)'
lenFast = input.int(128, 'Fast Length', minval = 8, maxval = 500, group = GRP_LEN)
lenSlow = input.int(256, 'Slow Length', minval = 8, maxval = 1000, group = GRP_LEN)

GRP_LVL = 'Levels'
badLvl  = input.float(0.8, 'Washed-out Level (avg below -x)', minval = 0.1, maxval = 1.0, step = 0.05, group = GRP_LVL)
showBg  = input.bool(true, 'Shade Zones', group = GRP_LVL)
showRaw = input.bool(true, 'Show Fast / Slow Lines', group = GRP_LVL)

//-----------------------------------------------------------------------------
// EHLERS CENTER OF GRAVITY, NORMALISED TO ±1
//   1. CG = weighted mean position of price inside the window
//   2. Rescale to [0,1] against its own highest/lowest over the window
//   3. 4-bar FIR smooth (4,3,2,1) then map to [-1, +1]
//-----------------------------------------------------------------------------
f_cg(float _src, int _len) =>
    float num = 0.0
    float den = 0.0
    for i = 0 to _len - 1
        num += (1 + i) * _src[i]
        den += _src[i]
    cg   = den != 0 ? -num / den + (_len + 1) / 2.0 : 0.0
    hi   = ta.highest(cg, _len)
    lo   = ta.lowest(cg, _len)
    v1   = hi != lo ? (cg - lo) / (hi - lo) : 0.0
    v2   = (4 * v1 + 3 * v1[1] + 2 * v1[2] + v1[3]) / 10.0
    2 * (v2 - 0.5)

cgFast = f_cg(src, lenFast)
cgSlow = f_cg(src, lenSlow)
cgAvg  = math.avg(cgFast, cgSlow)

//-----------------------------------------------------------------------------
// STATES
//-----------------------------------------------------------------------------
isWashedOut = cgAvg < -math.abs(badLvl)
isStretched = cgAvg >  math.abs(badLvl)

//-----------------------------------------------------------------------------
// PLOTS
//-----------------------------------------------------------------------------
cDown = color.rgb(242, 54, 69)
cUp   = color.rgb(8, 153, 129)
cMid  = color.rgb(150, 150, 150)

avgColor = isWashedOut ? cDown : isStretched ? cUp : color.white

plot(showRaw ? cgFast : na, 'CG Fast', color = color.new(cMid, 40), linewidth = 1)
plot(showRaw ? cgSlow : na, 'CG Slow', color = color.new(cMid, 70), linewidth = 1)
plot(cgAvg,                 'CG Average', color = avgColor, linewidth = 2)

hline( math.abs(badLvl), 'Upper Level', color = color.new(cUp, 50),   linestyle = hline.style_dotted)
hline( 0.0,              'Zero',        color = cMid,                 linestyle = hline.style_dashed)
hline(-math.abs(badLvl), 'Lower Level', color = color.new(cDown, 50), linestyle = hline.style_dotted)

bgcolor(showBg ? (isWashedOut ? color.new(cDown, 88) : isStretched ? color.new(cUp, 90) : na) : na, title = 'Zone Shading')

//-----------------------------------------------------------------------------
// ALERTS
//-----------------------------------------------------------------------------
alertcondition(isWashedOut and not isWashedOut[1], 'Entered Washed-out Zone', 'Ehlers CG x2: average dropped below lower level')
alertcondition(not isWashedOut and isWashedOut[1], 'Left Washed-out Zone',    'Ehlers CG x2: average recovered above lower level')
````
