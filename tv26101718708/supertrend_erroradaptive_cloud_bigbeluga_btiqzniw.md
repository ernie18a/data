# Supertrend Error-Adaptive Cloud [BigBeluga]

- url: https://www.tradingview.com/script/bTiQznIw-Supertrend-Error-Adaptive-Cloud-BigBeluga/
- type: indicator
- pine_id: PUB;23d7470bc9ad46f282fbe5fc151eb37c
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote][b]Supertrend Error-Adaptive Cloud [BigBeluga][/b] is a Supertrend variant that adapts its multiplier using a self-correcting error-feedback engine. It solves the problem of fixed-multiplier Supertrends getting whipsawed in changing conditions by scoring each trend's outcome and adjusting its bias over time.[/quote]


[b]🔵 HOW IT WORKS[/b]
[quote]The indicator combines a classic Supertrend core with an adaptive multiplier, a dynamic cloud, and a live error-tracking dashboard:

[b]1 — Supertrend Core[/b]
[list]
[*] [b]Volatility Range:[/b] Uses the highest high-low range over the [i]Period[/i] as the base volatility measure.
[*] [b]Band Construction:[/b] Upper and lower bands are built from the mid price plus or minus the adaptive multiplier times the volatility range.
[*] [b]Trend Direction:[/b] Flips bullish or bearish based on close crossing the active band, with the line drawn only on the active side.
[image]https://www.tradingview.com/x/teFLKpYa/[/image]
[/list]


[b]2 — Adaptive Feedback Engine[/b]
[list]
[*] [b]Error Memory:[/b] On each confirmed trend flip, the engine scores the previous trend as a win or loss and updates a running bias value.
[image]https://www.tradingview.com/x/7VSMTjcG/[/image]
[*] [b]Bias Value (0.0 – 1.0):[/b] The bias is an exponential moving average of past errors — near 0.0 means most trends were winners and the multiplier stays close to base, while near 1.0 means most trends were losers and the multiplier is scaled up to widen the bands.
[image]https://www.tradingview.com/x/VRBi2aZb/[/image]
[*] [b]Learning Rate:[/b] The [i]Learning Rate[/i] controls how quickly the bias reacts to new errors, letting the multiplier tighten or loosen adaptively.
[*] [b]Adaptive Multiplier:[/b] The base [i]Multiplier[/i] is scaled by the learned bias using [i]bmult × (1 + bias)[/i], with a floor of 0.5 to keep behavior stable.
[/list]


[b]3 — Trend Cloud & Visuals[/b]
[list]
[*] [b]Gradient Cloud:[/b] Two EMA-based candle plots form a cloud around the trend, with bar color fading based on distance from the cloud.
[image]https://www.tradingview.com/x/ZgMQgNWq/[/image]
[*] [b]Flip Markers:[/b] A colored dot with a glow highlight appears at each trend flip.
[*] [b]Bias Labels:[/b] On confirmed flips, a label displays the current bias value (0.0 – 1.0) next to the signal — a low value means the multiplier is performing well, a high value means the engine has widened the bands to compensate for recent losses.
[/list]

[b]4 — Performance Dashboard[/b]
[list]
[*] [b]History Table:[/b] Shows the last [i]Dashboard Rows[/i] trend outcomes with the error value and WIN/LOSS status for each.
[*] [b]Color Coding:[/b] Wins are highlighted in green and losses in red for quick performance review.
[image]https://www.tradingview.com/x/GJmLIprg/[/image]
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]Beyond standard Supertrend signals, the indicator can be applied in several ways:

[list=1]
[*] [b]Trade Trend Flips:[/b] Use the colored line, cloud, and flip markers as entry and exit signals.
[*] [b]Assess Adaptation Quality:[/b] Watch the dashboard WIN/LOSS rows and the bias value on flip labels — a value near 0.0 means the current multiplier is working well, while a value near 1.0 signals the engine has widened the bands to avoid repeated losses.
[*] [b]Tune Adaptiveness:[/b] Raise the [i]Learning Rate[/i] for faster adaptation or lower it for smoother, more stable behavior.
[*] [b]Read Cloud Strength:[/b] Use the cloud's color intensity as a visual cue for how far price has stretched from the trend baseline.
[*] [b]Disable Adaptation for Classic Behavior:[/b] Turn off [i]Enable Adaptive Engine[/i] to fall back to a standard fixed-multiplier Supertrend.
[/list][/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] Adds a self-correcting error-feedback layer on top of a classic Supertrend, letting the multiplier adapt to recent outcomes.
[*] Uses an EMA cloud with distance-based gradient fading to visualize trend strength, not just direction.
[*] Includes a built-in dashboard that logs each trend's error value and WIN/LOSS result for live performance review.
[*] Fully customizable multiplier, learning rate, colors, dashboard position, and text sizes.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Supertrend Error-Adaptive Cloud [BigBeluga]", "Supertrend EA Cloud [BigBeluga]", overlay = true)


// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
lngth = input.int(50, 'Period', minval = 1, group = 'Supertrend Settings', tooltip = 'Lookback period for volatility range and EMA calculations.')
mult  = input.float(1.0, 'Multiplier', minval = 0.1, step = 0.1, group = 'Supertrend Settings', tooltip = 'Base volatility multiplier scaling the Supertrend bands.')

ml_on = input.bool(true, 'Enable Adaptive Engine', group = 'Adaptive Engine', tooltip = 'Toggles the adaptive trade-outcome error feedback engine.')
lrate = input.float(0.1, 'Learning Rate', minval = 0.01, maxval = 0.5, step = 0.01, group = 'Adaptive Engine', tooltip = 'Rate at which error memory updates from past completed trends.')

maxd  = input.float(2.0, 'Max Distance', minval = 0.1, step = 0.1, group = 'Visuals & Colors', tooltip = 'Maximum distance threshold for the gradient cloud bars.')
bullc = input.color(color.rgb(0, 200, 150), 'Bull Color', group = 'Visuals & Colors', tooltip = 'Color palette used during upward trend conditions.')
bearc = input.color(color.rgb(235, 80, 100), 'Bear Color', group = 'Visuals & Colors', tooltip = 'Color palette used during downward trend conditions.')

dsho  = input.bool(true, 'Show Dashboard', group = 'Dashboard', tooltip = 'Toggles the history table showing past trend errors and outcomes.')
dloc  = input.string('Bottom Right', 'Dashboard Position', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'Dashboard', tooltip = 'Screen corner location for the history table.')
drows = input.int(10, 'Dashboard Rows', minval = 1, maxval = 25, group = 'Dashboard', tooltip = 'Number of past trend samples to display in the dashboard.')
dsize = input.string('Small', 'Dashboard Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Dashboard', tooltip = 'Text size of the dashboard table cells.')
lsize = input.string('Small', 'Label Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Labels', tooltip = 'Text size of the chart signal labels.')
// }



// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
vrng = ta.highest(high - low, lngth)

// Calculates the adjusted Supertrend line and direction based on a given multiplier factor
supt(fact) =>
    src = math.avg(close, open)
    ubnd = src + fact * vrng
    lbnd = src - fact * vrng
    uprev = nz(ubnd[1])
    lprev = nz(lbnd[1])
    lbnd := lbnd > lprev or close[1] < lprev ? lbnd : lprev
    ubnd := ubnd < uprev or close[1] > uprev ? ubnd : uprev
    int dirv = na
    float tlin = na
    pstr = tlin[1]
    if na(vrng[1])
        dirv := 1
        dirv
    else if pstr == uprev
        dirv := close > ubnd ? -1 : 1
        dirv
    else
        dirv := close < lbnd ? 1 : -1
        dirv
    tlin := dirv == -1 ? lbnd : ubnd
    [tlin, dirv]

// Arrays to store history of errors and win/loss states for the dashboard
var float[] biasArr = array.new_float(0)
var string[] statArr = array.new_string(0)

// Helper function to convert text size input to Pine script size type
getSize(string s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        => size.small

// Machine learning feedback engine that evaluates trade success on trend flips and adapts the multiplier error (locked on confirmed bars to avoid repainting)
mlegn(bool usen, float bmult, float lrt, int leng, int dirv, int maxRows) =>
    var float entcl = close
    var float ebias = 0.0
    float amult = bmult
    if bar_index > leng
        float bcalc = usen ? bmult * (1.0 + ebias) : bmult
        amult := math.max(bcalc, 0.5)
        amult
    bool flip = dirv != nz(dirv[1])
    if flip and bar_index > leng and barstate.isconfirmed
        int pdir = nz(dirv[1])
        float exitc = close[1]
        bool iswin = pdir == -1 and exitc > entcl or pdir == 1 and exitc < entcl
        float errs = iswin ? 0.0 : 1.0
        
        // Push error and outcome status to history tracking arrays dynamically capped by user input rows
        array.unshift(biasArr, ebias)
        array.unshift(statArr, iswin ? "WIN" : "LOSS")
        if array.size(biasArr) > maxRows
            array.pop(biasArr)
            array.pop(statArr)
            
        ebias := nz(ebias) + lrt * (errs - nz(ebias))
        entcl := close
        entcl
    [amult, ebias, flip]

var int prdir = 1
[amult, ebias, flip] = mlegn(ml_on, mult, lrate, lngth, prdir, drows)
[tlin, cdir] = supt(amult)
prdir := cdir

cols = cdir == 1 ? bearc : bullc
emas = ta.ema(close, int(lngth * 0.7))
emal = ta.ema(close, int(lngth * 0.7) + 10)

var float dist = 0.0
if cdir != cdir[1]
    dist := vrng * 0.5
    dist
    
emal := cdir == 1 ? emal + dist : emal - dist

if cdir == 1
    if emal > tlin
        emal := tlin
        emal
    if high > emas
        emas := high
        emas
else
    if emal < tlin
        emal := tlin
        emal
    if low < emas
        emas := low
        emas

srng = nz(vrng, 1) == 0 ? 1 : vrng
rawd = math.abs(close - emas) / srng
normd = math.min(rawd / maxd, 1.0)
tran = int(90 - normd * 100)
barcl = color.new(cols, tran)
// }



// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
plot(tlin, "Supertrend", style = plot.style_linebr, color = cdir != cdir[1] ? na : cols)
plot(tlin, "Supertrend Glow", style = plot.style_linebr, color = cdir != cdir[1] ? na : color.new(cols, 80), linewidth = 10)

plotshape(cdir != cdir[1] ? tlin : na, title = 'Dot', style = shape.circle, location = location.absolute, color = cols, size = size.tiny)
plotshape(cdir != cdir[1] ? tlin : na, title = 'Glow', style = shape.circle, location = location.absolute, color = color.new(cols, 55), size = size.small)

if flip and barstate.isconfirmed
    if cdir == -1
        label.new(bar_index-1, tlin[1], text = 'Bull\nBias: ' + str.tostring(ebias, '#.##'), color = color.new(bullc, 100), textcolor = chart.fg_color, style = label.style_label_up, size = getSize(lsize))
    else
        label.new(bar_index-1, tlin[1], text = 'Bias: ' + str.tostring(ebias, '#.##') + '\nBear', color = color.new(bearc, 100), textcolor = chart.fg_color, style = label.style_label_down, size = getSize(lsize))

plotcandle(emas, emas, emal, emas, title = 'C1', color = barcl, wickcolor = barcl, bordercolor = barcl)
plotcandle(emal, emal, emal, emal, title = 'C2', color = barcl, wickcolor = barcl, bordercolor = barcl)

// --- PREMIUM DARK DASHBOARD TABLE ---
var table dtable = table.new(dloc == 'Top Right' ? position.top_right : dloc == 'Bottom Right' ? position.bottom_right : position.bottom_left, 3, drows + 1, bgcolor = color.rgb(18, 18, 24), border_color = color.rgb(40, 40, 52), border_width = 1)
if barstate.islast and dsho
    table.cell(dtable, 0, 0, "#", text_color = color.rgb(160, 160, 175), text_size = getSize(dsize), bgcolor = color.rgb(26, 26, 36))
    table.cell(dtable, 1, 0, "Error", text_color = color.rgb(160, 160, 175), text_size = getSize(dsize), bgcolor = color.rgb(26, 26, 36))
    table.cell(dtable, 2, 0, "Result", text_color = color.rgb(160, 160, 175), text_size = getSize(dsize), bgcolor = color.rgb(26, 26, 36))
    
    int sz = math.min(array.size(biasArr), drows)
    for i = 0 to sz - 1
        float bval = array.get(biasArr, i)
        string sval = array.get(statArr, i)
        color sc = sval == "WIN" ? color.rgb(0, 200, 150, 80) : color.rgb(235, 80, 100, 80)
        
        table.cell(dtable, 0, i + 1, str.tostring(i + 1), text_color = color.rgb(200, 200, 210), text_size = getSize(dsize), bgcolor = color.rgb(22, 22, 30))
        table.cell(dtable, 1, i + 1, str.tostring(bval, "#.##"), text_color = color.rgb(240, 240, 250), text_size = getSize(dsize), bgcolor = color.rgb(22, 22, 30))
        table.cell(dtable, 2, i + 1, sval, text_color = color.white, text_size = getSize(dsize), bgcolor = sc)
// }
````
