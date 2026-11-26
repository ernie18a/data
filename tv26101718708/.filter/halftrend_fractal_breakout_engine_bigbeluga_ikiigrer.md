# HalfTrend Fractal Breakout Engine [BigBeluga]

- url: https://www.tradingview.com/script/IkiigrEr-HalfTrend-Fractal-Breakout-Engine-BigBeluga/
- type: indicator
- pine_id: PUB;2755dd00e2474782a5c2566e79dfa176
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote][b]HalfTrend Fractal Breakout Engine [BigBeluga][/b] is an indicator that combines the HalfTrend trend baseline with Williams fractal breakouts and volume-weighted pulse rings. It solves the problem of unqualified breakout signals by grading every fractal break with a volume multiple, a gradient color, and an expanding ring pulse — so strong breakouts visually stand out from weak ones.

[i]Credits:[/i] The HalfTrend core logic — including the Amplitude and Channel Deviation baseline, the trend state machine, and the ATR bands — is adapted from the original [b]HalfTrend[/b] indicator by [b]Everget[/b]:
[url]https://www.tradingview.com/script/U1SJ8ubc-HalfTrend-everget/[/url]

All breakout logic, volume grading, and pulse ring visuals, built on top of Everget's HalfTrend core.[/quote]


[b]🔵 HOW IT WORKS[/b]
[quote]The indicator runs a trend baseline, detects fractal breakouts, and scores each one against recent breakout volume:

[b]1 — HalfTrend Baseline[/b]
[list]
[*] [b]Amplitude Swing Detection:[/b] Uses the [i]Amplitude[/i] window to locate minor swing highs and lows that drive the trend state machine.
[*] [b]ATR Channel Deviation:[/b] Bands are built around the baseline using ATR scaled by the [i]Channel Deviation[/i] multiplier.
[*] [b]Trend Regime:[/b] A close above the upper band sets an uptrend, a close below the lower band sets a downtrend, and the dynamic band and fill recolor accordingly.
[/list]

[b]2 — Fractal Breakout Detection[/b]
[list]
[*] [b]Williams Fractals:[/b] A 5-bar fractal pattern identifies confirmed structural tops and bottoms, offset 2 bars back.
[*] [b]Breakout Trigger:[/b] In an uptrend, a close above a pending top fractal fires a bullish breakout; in a downtrend, a close below a pending bottom fractal fires a bearish breakout.
[*] [b]Level Lines & Arrows:[/b] A horizontal line is drawn at the broken fractal, with a directional arrow printed at the breakout bar.
[/list]

[b]3 — Volume Scoring[/b]
[list]
[*] [b]Rolling Window:[/b] Compares the breakout bar's volume against the max and average of the last [i]Max Breakout History[/i] breakouts (default 10) stored in the current trend leg.
[*] [b]Gradient Brightness:[/b] Color intensity scales with volume relative to the largest stored breakout, so the strongest breakouts glow brightest.
[*] [b]Label Multiplier:[/b] A label shows breakout volume as a multiple of the stored average, like [i]1.85x[/i].
[*] [b]Array Reset on Flips:[/b] Volume history resets at each trend flip so every leg builds its own baseline.
[/list]

[b]4 — Pulse Rings[/b]
[list]
[*] [b]Expanding Rings:[/b] Each breakout spawns [i]Rings per Breakout[/i] circles that bloom outward and fade over [i]Ring Duration[/i] bars.
[*] [b]Strength-Based Size:[/b] Stronger breakouts produce larger, brighter rings while weak ones stay small and faint.
[*] [b]Center Label:[/b] A centered label at each pulse cluster shows the breakout's volume multiple with a full-volume tooltip.
[/list][/quote]


[b]🔵 HOW TO READ THE "X" SCORE[/b]
[quote]The [i]x[/i] label next to each breakout measures that bar's volume against a rolling window of the last breakouts stored in the current trend leg — by default, the previous 10 breakouts, controlled by [i]Max Breakout History[/i].

[list]
[*] [b]1.00x[/b] — volume matched the average of the stored breakouts. A neutral breakout with no unusual participation.
[*] [b]1.50x[/b] — 50% above the stored average. Moderate confirmation, noticeable but not exceptional.
[*] [b]2.00x[/b] — double the stored average. A strong breakout backed by clearly above-average volume.
[*] [b]3.00x and above[/b] — exceptional participation. These breakouts typically stand out visually with bright colors and large, bold rings.
[*] [b]Below 1.00x[/b] — volume was below the stored average. A weak breakout that may be more prone to failure or fakeouts.
[/list]

[b]How the score is calculated:[/b]
[list]
[*] [b]Label (x multiple):[/b] [i]breakout volume ÷ average of stored breakouts[/i] — answers "how does this breakout compare to recent ones in this trend leg?"
[*] [b]Gradient brightness:[/b] [i]breakout volume ÷ max of stored breakouts[/i] — the largest stored breakout reaches full color intensity, and others scale down from there.
[*] [b]Ring intensity:[/b] Uses the same ratio as gradient brightness, so the strongest breakout in the window produces the biggest and brightest pulse rings.
[*] [b]Rolling Window:[/b] The stored list holds up to [i]Max Breakout History[/i] breakouts (default 10). Older entries are dropped as new ones arrive, and the entire list resets on a trend flip.
[/list]

[b]Example:[/b] If the last 10 stored breakouts averaged 1,000 volume and the current breakout prints 2,400:
[list]
[*] Label reads [b]2.40x[/b] — the breakout was 2.4 times the recent average
[*] If the largest of those 10 was 1,500, brightness and ring intensity are capped at full (2,400 ÷ 1,500 = 1.6, clamped to 1.0)
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]Beyond standard breakout signals, the indicator can be applied in several ways:

[list=1]
[*] [b]Trade Confirmed Breakouts:[/b] Enter in the direction of a fractal break once a bar closes beyond the level.
[*] [b]Grade Breakout Strength:[/b] Use the x multiple and ring brightness to compare breaks — higher values indicate stronger participation.
[*] [b]Read Trend Regime:[/b] Use the dynamic band color and fill to see whether the market is in an uptrend or downtrend.
[*] [b]Spot Weak vs Strong Breaks:[/b] Faint, small rings and low multipliers signal weak breaks that may be more prone to failure.
[*] [b]Customize the Visuals:[/b] Adjust ring count, duration, offset, and colors to match your chart style.
[/list][/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] Combines the HalfTrend baseline with Williams fractal breakouts, so signals fire at confirmed structural levels rather than arbitrary crossings.
[*] Volume is scored against a rolling window of recent breakouts in the same trend leg, keeping labels stable and avoiding self-referential distortion.
[*] Pulse rings and gradient coloring translate volume strength into an instantly readable visual — no separate panel required.
[*] Fully customizable amplitude, deviation, history window, colors, and ring behavior to match any market or timeframe.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

// ─── Credits ─────────────────────────────────────────────────────────────────────────────────────────────────────
// HalfTrend core logic (Amplitude / Channel Deviation baseline, trend state machine, ATR bands)
// is adapted from the original "HalfTrend" indicator by Everget:
//     https://www.tradingview.com/script/U1SJ8ubc-HalfTrend-everget/
// ────────────────────────────────────────────────────────────────────────────────────────────────────────────────


//@version=6
indicator('HalfTrend Fractal Breakout Engine [BigBeluga]', overlay = true, max_labels_count = 500, max_lines_count = 500, calc_bars_count = 5000)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

amp    = input.int(10, title = 'Amplitude', minval = 1, tooltip = 'Sets the lookback window for identifying minor high and low swing points.')
devMul = input.float(2.0, title = 'Channel Deviation', step = 0.1, tooltip = 'Determines the multiplier for the ATR bands tracking the baseline trend.')
maxBrk = input.int(10, title = 'Max Breakout History', minval = 1, tooltip = 'Number of previous breakouts stored to determine max volume for gradient scaling.')

// Color Picker Configurations
colBull = input.color(#04b491, title = 'Bullish Trend Color', group = 'Color Settings', tooltip = 'Visual color signature used when an active uptrend is established.')
colBear = input.color(#ff0055, title = 'Bearish Trend Color', group = 'Color Settings', tooltip = 'Visual color signature used when an active downtrend is established.')
colFrac = input.color(color.yellow, title = 'Fractal Breakout Color', group = 'Color Settings', tooltip = 'Primary color accent utilized for structural breakouts, lines, and directional arrows.')

// Pulse Ring Settings
grpRing  = 'Pulse Rings'
enRing   = input.bool(true, title = 'Enable Pulse Rings', group = grpRing, tooltip = 'Draw expanding circular rings radiating from each breakout point.')
ringCnt  = input.int(6,  title = 'Rings per Breakout', minval = 1, maxval = 6, group = grpRing)
ringDur  = input.int(200, title = 'Ring Duration (bars)', minval = 5, maxval = 1000, group = grpRing, tooltip = 'How many bars each ring pulse lives before being deleted.')
ringOff  = input.int(10,  title = 'Ring Bar Offset', minval = 0, maxval = 100, group = grpRing, tooltip = 'Shift ring bubbles to the right of the breakout bar (in bars).')

// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// ─── HalfTrend baseline state (Everget's original logic, renamed for brevity) ────────────────────────────────────

var int   trnd  = 0
var int   nxtTr = 0
var float maxLo = low
var float minHi = high
var float upLn  = 0.0
var float dnLn  = 0.0

atr2 = ta.atr(100) / 2
dev  = devMul * atr2

hiPrc = high[math.abs(ta.highestbars(amp))]
loPrc = low[math.abs(ta.lowestbars(amp))]

hiSma = ta.sma(high, amp)
loSma = ta.sma(low, amp)

// ─── HalfTrend trend state machine ──────────────────────────────────────────────────────────────────────────────

if nxtTr == 1
    maxLo := math.max(loPrc, maxLo)
    if hiSma < maxLo and close < nz(low[1], low)
        trnd  := 1
        nxtTr := 0
        minHi := hiPrc
        minHi
else
    minHi := math.min(hiPrc, minHi)
    if loSma > minHi and close > nz(high[1], high)
        trnd  := 0
        nxtTr := 1
        maxLo := loPrc
        maxLo

// ─── HalfTrend baseline & band construction ─────────────────────────────────────────────────────────────────────

if trnd == 0
    if not na(trnd[1]) and trnd[1] != 0
        upLn := na(dnLn[1]) ? dnLn : dnLn[1]
        upLn
    else
        upLn := na(upLn[1]) ? maxLo : math.max(maxLo, upLn[1])
        upLn
else
    if not na(trnd[1]) and trnd[1] != 1
        dnLn := na(upLn[1]) ? upLn : upLn[1]
        dnLn
    else
        dnLn := na(dnLn[1]) ? minHi : math.min(minHi, dnLn[1])
        dnLn

htLn = trnd == 0 ? upLn : dnLn
upBnd = htLn + dev
loBnd = htLn - dev

// ─── Direction flag: T = true means price is above the upper band (uptrend regime) ──────────────────────────────

var bool T = false

if ta.crossover(close, upBnd)
    T := true
    T
if ta.crossunder(close, loBnd)
    T := false
    T

TBnd = T ? loBnd : upBnd
TCol = T ? colBull : colBear

// ─── Williams fractals (5-bar pattern; confirms 2 bars back) ────────────────────────────────────────────────────

bool topFrc = high[2] > high[4] and high[2] > high[3] and high[2] > high[1] and high[2] > high[0]
bool botFrc = low[2] < low[4] and low[2] < low[3] and low[2] < low[1] and low[2] < low[0]

// ─── Fractal pivot record ───────────────────────────────────────────────────────────────────────────────────────

type fractal
	int   indx
	float levl

// ─── Pulse Ring Engine (label-based, non-repainting) ────────────────────────────────────────────────────────────
// Each pulse cluster = N expanding circles + 1 center label showing the breakout's volume multiple.
// All labels are re-created every bar to advance their visual state (size, alpha), then reaped
// once they exceed ringDur.
//
//   • Age (prg)         → drives WHEN rings grow and fade (timing)
//   • Strength (str)    → drives HOW BIG they grow and HOW BRIGHT they stay (intensity)

type pulseRing
	int   strBar
	float orgPrc
	int   rngIdx
	color basCol
	label lbl
	float str          // 0..1 volume strength of the spawning breakout

type ringCenter
	int   strBar
	float orgPrc
	label lbl
	color txtCol
	string ttp
	float str          // 0..1 volume strength (unused visually, kept for parity)

var array<pulseRing>  rings = array.new<pulseRing>()
var array<ringCenter> rCtrs = array.new<ringCenter>()

// Map progress (0..1) to a discrete label size tier
ringSize(float p) =>
    p < 0.05 ? size.tiny :
     p < 0.20 ? size.small :
     p < 0.30 ? size.normal :
     p < 0.40 ? size.large :
                 size.huge

// ─── Spawn a cluster of rings + one center % label at a breakout level ──────────────────────────────────────────
// strength = 0..1 volume multiple of this breakout (gradient-normalized bVol/maxV)

spawnRings(float orgPrc, bool bullish, string pctTxt, float strength) =>
    if enRing
        color basCol = bullish ? colBull : colBear
        int   ancBar = bar_index + ringOff

        for i = 0 to ringCnt - 1
            pulseRing r = pulseRing.new(bar_index, orgPrc, i, basCol, na, strength)
            array.push(rings, r)

        if pctTxt != ""
            string tip = 'Breakout volume: ' + str.tostring(volume, format.volume)
            label cLbl = label.new(
                 ancBar,
                 orgPrc,
                 pctTxt,
                 style     = label.style_label_center,
                 color     = color.new(color.black, 100),
                 textcolor = chart.fg_color,
                 size      = size.small,
                 tooltip   = tip
                 )
            ringCenter rc = ringCenter.new(bar_index, orgPrc, cLbl, chart.fg_color, tip, strength)
            array.push(rCtrs, rc)
    0

// ─── Advance every ring and center label one bar; reap expired ──────────────────────────────────────────────────

updateRings() =>
    if array.size(rings) > 0
        for i = array.size(rings) - 1 to 0
            pulseRing r = array.get(rings, i)
            int   age = bar_index - r.strBar
            float prg = age / ringDur

            if prg >= 1.0
                if not na(r.lbl)
                    label.delete(r.lbl)
                array.remove(rings, i)
            else
                // Outer rings start slightly later, creating a sequential bloom
                float stag = r.rngIdx * 0.08
                float locP = math.max(0.0, math.min(1.0, (prg - stag) / (1.0 - stag)))

                // ── Strength-weighted size and alpha ─────────────────────────────────────────
                // Weak breakouts stay small and faint; strong breakouts grow large and stay bold.
                float sizeMul = 0.5 + 0.5 * r.str
                float szP     = math.min(locP * sizeMul, 1.0)

                int startA = math.round(75 - r.str * 30)
                int fadA   = math.round(startA + locP * (100 - startA))
                // ─────────────────────────────────────────────────────────────────────────────

                color c = color.new(r.basCol, fadA)

                if not na(r.lbl)
                    label.delete(r.lbl)

                label nl = label.new(
                     bar_index + ringOff,
                     r.orgPrc,
                     '',
                     style     = label.style_circle,
                     color     = c,
                     size      = ringSize(szP),
                     textcolor = na
                     )
                r.lbl := nl
                r

    if array.size(rCtrs) > 0
        for i = array.size(rCtrs) - 1 to 0
            ringCenter rc = array.get(rCtrs, i)
            int   age = bar_index - rc.strBar
            float prg = age / ringDur

            if prg >= 1.0
                if not na(rc.lbl)
                    label.delete(rc.lbl)
                array.remove(rCtrs, i)
            else
                string txt = label.get_text(rc.lbl)

                if not na(rc.lbl)
                    label.delete(rc.lbl)

                label nc = label.new(
                     bar_index + ringOff,
                     rc.orgPrc,
                     txt,
                     style     = label.style_label_center,
                     color     = color.new(color.black, 100),
                     textcolor = rc.txtCol,
                     size      = size.small,
                     tooltip   = rc.ttp
                     )
                rc.lbl := nc
                rc
    0

// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

pht = plot(T != T[1] ? na : TBnd, color = TCol, style = plot.style_linebr, linewidth = 2, title = 'HalfTrend Dynamic Band')
pp  = plot(hl2, 'Price', editable = false, display = display.none)

fill(pht, pp, hl2, TBnd, color.new(TCol, 100), color.new(TCol, 90))

// ─── Volume Breakout Logic ──────────────────────────────────────────────────────────────────────────────────────
// Each breakout's bar volume is compared against the MAX and AVG of the previous N breakout
// volumes in the current trend. The current breakout is pushed to the array AFTER the
// comparison, so it is never measured against itself. This keeps labels stable — a big
// breakout cannot retroactively inflate the reference for its own score.
//
//   • Gradient brightness : bVol / maxV   →  largest prior breakout = full brightness
//   • Label text          : bVol / avgV   →  "how many times the average this breakout was"
//   • Ring intensity      : bVol / maxV   →  strongest breakouts get bigger, brighter rings
//   • Arrays reset on trend flip so each leg builds its own baseline.

var array<float> topVol = array.new<float>()
var array<float> botVol = array.new<float>()

// Reference price tracking (used for chart context; not for the volume metric)
var float lstTop = na
var float lstBot = na

var bool fstTop = true
var bool fstBot = true

// ─── Track the most recent opposite-type fractal (for first-breakout context) ────────────────────────────────────

var float lstBotFrc = na
var float lstTopFrc = na

if botFrc
    lstBotFrc := low[2]

if topFrc
    lstTopFrc := high[2]

// ─── Top Fractal Breakouts Processing ────────────────────────────────────────────────────────────────────────────

var fractal topF = na

// Register a new pending top fractal whenever one forms while in uptrend
if topFrc and T
    topF := fractal.new(bar_index[2], high[2])
    topF

// Reset pending state on trend flip
if T != T[1]
    topF   := na
    lstTop := na
    fstTop := true

if T and not na(topF)
    if close > topF.levl and barstate.isconfirmed

        // Volume of the breakout candle
        float bVol = volume

        // Trim array BEFORE comparison so it contains only previous breakouts
        if array.size(topVol) > maxBrk
            array.shift(topVol)

        // Reference metrics — computed from PREVIOUS breakouts only
        float maxV = array.max(topVol)
        float nrmV = maxV > 0 ? bVol / maxV : 0.0

        colG1 = color.from_gradient(nrmV, 0, 1, color.new(colFrac, 80), colFrac)
        colG2 = color.from_gradient(nrmV, 0, 1, color.new(colFrac, 80), colFrac)

        // Label text: volume as a relative multiple of the array average
        float avgV = array.avg(topVol)
        string volTxt = avgV > 0 ? str.tostring(bVol / avgV, "#.##") + 'x' : str.tostring(bVol, format.volume)

        // Level line at the broken fractal + % label + directional arrow
        line.new(topF.indx, topF.levl, bar_index, topF.levl, color = colG1)
        label.new(
             topF.indx,
             topF.levl,
             volTxt,
             color     = na,
             textcolor = colG2,
             tooltip   = 'Breakout volume: ' + str.tostring(bVol, format.volume)
             )
        label.new(bar_index, low, '▲', style = label.style_label_up, color = na, textcolor = colG1)

        // Ring cluster intensity = gradient-normalized volume strength
        spawnRings(topF.levl, true, volTxt, nrmV)

        fstTop := false
        lstTop := close

        topF := na
        topF

        // Push AFTER comparison — this bar becomes part of history for the NEXT breakout
        array.push(topVol, bVol)


// ─── Bottom Fractal Breakouts Processing ─────────────────────────────────────────────────────────────────────────

var fractal botF = na

// Register a new pending bottom fractal whenever one forms while in downtrend
if botFrc and not T
    botF := fractal.new(bar_index[2], low[2])
    botF

// Reset pending state on trend flip
if T != T[1]
    botF   := na
    lstBot := na
    fstBot := true

if not T and not na(botF)
    if close < botF.levl and barstate.isconfirmed

        // Volume of the breakout candle
        float bVol = volume

        // Trim array BEFORE comparison so it contains only previous breakouts
        if array.size(botVol) > maxBrk
            array.shift(botVol)

        // Reference metrics — computed from PREVIOUS breakouts only
        float maxV = array.max(botVol)
        float nrmV = maxV > 0 ? bVol / maxV : 0.0

        colG1 = color.from_gradient(nrmV, 0, 1, color.new(colFrac, 80), colFrac)
        colG2 = color.from_gradient(nrmV, 0, 1, color.new(colFrac, 80), colFrac)

        // Label text: volume as a relative multiple of the array average
        float avgV = array.avg(botVol)
        string volTxt = avgV > 0 ? str.tostring(bVol / avgV, "#.##") + 'x' : str.tostring(bVol, format.volume)

        // Level line at the broken fractal + % label + directional arrow
        line.new(botF.indx, botF.levl, bar_index, botF.levl, color = colG1)
        label.new(
             botF.indx,
             botF.levl,
             volTxt,
             color     = na,
             textcolor = colG2,
             style     = label.style_label_up,
             tooltip   = 'Breakout volume: ' + str.tostring(bVol, format.volume)
             )
        label.new(bar_index, high, '▼', style = label.style_label_down, color = na, textcolor = colG1)

        // Ring cluster intensity = gradient-normalized volume strength
        spawnRings(botF.levl, false, volTxt, nrmV)

        fstBot := false
        lstBot := close

        botF := na
        botF

        // Push AFTER comparison — this bar becomes part of history for the NEXT breakout
        array.push(botVol, bVol)

// ─── Update all active pulse rings + center labels every bar ────────────────────────────────────────────────────

updateRings()

// }
````
