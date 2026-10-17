# Streak Choppiness Index

- url: https://www.tradingview.com/script/byuffiUC-Streak-Choppiness-Index/
- type: indicator
- pine_id: PUB;91db8ada1412490ba0b20cb3ed3e8463
- version: 1.0

## Description

Streak Choppiness Index

OVERVIEW
Streak Choppiness Index measures how often candle color flips (green to red or red to green) over a rolling window. Frequent flips mean the market is choppy and mean-reverting. Long unbroken runs of one color mean it is trending. The indicator classifies each bar into a regime (Choppy, Neutral or Trendy) and flags "fade setups": a same-color streak reaching a chosen length inside a choppy regime. It works on any symbol and any timeframe.

THEORY
If candle colors were random coin flips, each candle would have a 50% chance of differing from the previous one. A flip rate near 50 is therefore the "random" baseline:
  • Above 50: colors alternate more often than chance. Streaks are short and tend to reverse (anti-persistent, mean-reverting behavior).
  • Below 50: colors repeat more often than chance. Streaks tend to extend (persistent, trending behavior).
This is the same idea as a runs test: counting color changes in a sequence reveals whether it is alternating, random or clustering. Average streak length gives the same information in candle units. Random data averages about 2 candles per streak; shorter means chop, longer means trend.

HOW IT WORKS
1. Color: a candle is green when close ≥ open, otherwise red.
2. Flip: a flip is counted when a candle's color differs from the previous candle's.
3. Chop index: flips in the window / window length × 100, smoothed with an EMA.
   100 = color flips every candle (pure chop)
     0 = one unbroken streak (pure trend)
4. Baseline: the long-run average of the raw chop index (SMA), used to judge whether current choppiness is high or low for this market.
5. Average streak: window / (flips + 1), the approximate mean streak length in candles.
6. Live streak: the current run of same-color candles, counted back up to 31 candles.
7. Regime:
   • Choppy – chop index ≥ Choppy threshold
   • Trendy – chop index ≤ Trendy threshold
   • Neutral – in between
8. Fade setup: Choppy regime AND live streak ≥ Max streak length.

PLOTS
- Chop index line – green when Choppy, yellow when Neutral, red when Trendy.
- Baseline – gray long-run average.
- Threshold lines – Choppy, Trendy and a 50 midline.
- Background – light green in Choppy, light red in Trendy, stronger green on a fade setup.
- Table – regime, chop index, value vs baseline, average streak, live streak (color × length), reversion status (ON in Choppy, OFF otherwise) and fade setup.

HOW TO USE
- Choppy regime: streaks are short and reverse often, so mean-reversion approaches (fading the current streak) have better conditions.
- Trendy regime: streaks extend, so fading tends to fail. Stand aside or trade with the direction.
- Fade setup: the current streak has reached your maximum expected length while the market is choppy. This is a candidate point for a reversal entry, not a guaranteed one.
- Use the baseline to compare current choppiness with what is normal for the symbol and timeframe.

SETTINGS
- Rolling window – number of candles used to count flips (default 5). Small windows react fast; larger windows give a steadier regime.
- Smoothing – EMA length on the chop index.
- Baseline window – length of the long-run average.
- Choppy / Trendy thresholds – regime boundaries.
- Max streak length – live streak length that triggers a fade setup in a choppy regime.
- Table, table position and regime background toggles.

NOTES
Candles with close equal to open are counted as green. With a small window the index moves in large steps (for example 0, 20, 40… for a window of 5); smoothing softens this.

This script is for analysis and education only and is not financial advice.

## Source Code

````pine
//@version=6
indicator('Streak Choppiness Index', shorttitle = 'ChopIdx', overlay = false)

// ================================================================
// STREAK CHOPPINESS INDEX
// Derived from candle-color streaks (same logic as StRange).
//   CHOP = rolling flip density: how often color changes.
//     100 = flips every candle (pure chop / sideways)
//       0 = one unbroken streak (pure trend)
//   AVG STREAK = window / (flips + 1)  → choppy when <= ~3 candles

// ================================================================

// ── INPUTS ───────────────────────────────────────────────────────
i_win = input.int(5, 'Rolling Window (candles)', minval = 1, maxval = 500)
i_smooth = input.int(2, 'Smoothing (EMA)', minval = 1, maxval = 50)
i_base = input.int(200, 'Baseline mean window', minval = 20, maxval = 2000)
i_hi = input.float(52.0, 'Choppy threshold (>=)', minval = 50, maxval = 95)
i_lo = input.float(40.0, 'Trendy threshold (<=)', minval = 5, maxval = 50)
i_maxStk = input.int(3, 'Max sideways streak (your \'1-3\' idea)', minval = 1, maxval = 10)
i_table = input.bool(true, 'Show Table')
i_bg = input.bool(true, 'Regime Background')
i_tpos = input.string('Top Right', 'Table Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Middle Right', 'Middle Left'])

// ── CORE: flip density ───────────────────────────────────────────
green = close >= open
flipF = green != green[1] ? 1.0 : 0.0 // color changed vs previous candle
flips = math.sum(flipF, i_win) // flips in window
chopRaw = flips / i_win * 100.0 // 0..100
chop = ta.ema(chopRaw, i_smooth)

avgStreak = flips > 0 ? i_win / (flips + 1.0) : i_win // approx mean streak length
baseChop = ta.sma(chopRaw, i_base) // long-run mean choppiness

// ── REGIME ───────────────────────────────────────────────────────
isChoppy = chop >= i_hi
isTrendy = chop <= i_lo
regime = isChoppy ? 2 : isTrendy ? 0 : 1 // 2=choppy 1=neutral 0=trendy

// ── LIVE STREAK (current consecutive same-color run) ─────────────
var int liveStreak = 0
if barstate.isconfirmed or barstate.isrealtime
    bool _done = false
    liveStreak := green ? 1 : -1
    for _s = 1 to 30 by 1
        if not _done
            bool _sg = close[_s] >= open[_s]
            bool _same = liveStreak > 0 and _sg or liveStreak < 0 and not _sg
            if _same
                liveStreak := liveStreak > 0 ? liveStreak + 1 : liveStreak - 1
                liveStreak
            else
                _done := true
                _done
int liveAbs = math.abs(liveStreak)

// Fade setup: choppy regime AND current streak has reached your max sideways length
fadeSetup = isChoppy and liveAbs >= i_maxStk

// ── COLORS ───────────────────────────────────────────────────────
f_regCol(r) =>
    c = color.new(#FFD740, 0) // neutral = yellow
    if r == 2
        c := color.new(#00E676, 0) // choppy = green (reversion favorable)
        c
    else if r == 0
        c := color.new(#FF1744, 0) // trendy = red (reversion unfavorable)
        c
    c

regCol = f_regCol(regime)

// ── PLOT ─────────────────────────────────────────────────────────
plot(chop, 'Choppiness', regCol, linewidth = 2)
plot(baseChop, 'Baseline', color.new(color.gray, 30), linewidth = 1)
hline(i_hi, 'Choppy', color.new(#00E676, 50), linestyle = hline.style_dashed)
hline(i_lo, 'Trendy', color.new(#FF1744, 50), linestyle = hline.style_dashed)
hline(50, 'Mid', color.new(color.gray, 70), linestyle = hline.style_dotted)

bgcolor(i_bg ? fadeSetup ? color.new(#00E676, 80) : isChoppy ? color.new(#00E676, 92) : isTrendy ? color.new(#FF1744, 92) : na : na, title = 'Regime BG')

// ── TABLE ────────────────────────────────────────────────────────
tpos = i_tpos == 'Top Right' ? position.top_right : i_tpos == 'Top Left' ? position.top_left : i_tpos == 'Bottom Right' ? position.bottom_right : i_tpos == 'Bottom Left' ? position.bottom_left : i_tpos == 'Middle Right' ? position.middle_right : position.middle_left

f_num(v, d) =>
    str.tostring(math.round(v * math.pow(10, d)) / math.pow(10, d))

var table tbl = na
if barstate.islast and i_table
    tbl := table.new(tpos, 2, 8, bgcolor = color.new(#07070F, 8), border_color = color.new(color.gray, 55), border_width = 1, frame_color = color.new(color.white, 45), frame_width = 1)

    cbg = color.new(#0C0C1A, 0)
    hbg = color.new(#12122E, 0)

    regWord = regime == 2 ? 'CHOPPY' : regime == 0 ? 'TRENDY' : 'NEUTRAL'

    table.cell(tbl, 0, 0, 'STREAK CHOP', text_color = color.white, bgcolor = hbg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 0, regWord, text_color = regCol, bgcolor = hbg, text_size = size.small, text_halign = text.align_center)

    table.cell(tbl, 0, 1, 'Chop index', text_color = color.new(color.gray, 15), bgcolor = cbg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 1, f_num(chop, 1), text_color = regCol, bgcolor = cbg, text_size = size.small, text_halign = text.align_center)

    baseCol = na(baseChop) ? color.gray : chop > baseChop ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    baseTxt = na(baseChop) ? 'n/a' : (chop > baseChop ? 'ABOVE ' : 'BELOW ') + f_num(baseChop, 1)
    table.cell(tbl, 0, 2, 'vs baseline', text_color = color.new(color.gray, 15), bgcolor = cbg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 2, baseTxt, text_color = baseCol, bgcolor = cbg, text_size = size.small, text_halign = text.align_center)

    asCol = avgStreak <= i_maxStk ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    table.cell(tbl, 0, 3, 'Avg streak', text_color = color.new(color.gray, 15), bgcolor = cbg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 3, f_num(avgStreak, 1) + 'c', text_color = asCol, bgcolor = cbg, text_size = size.small, text_halign = text.align_center)

    lsCol = green ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    table.cell(tbl, 0, 4, 'Live streak', text_color = color.new(color.gray, 15), bgcolor = cbg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 4, (green ? 'G' : 'R') + ' x' + str.tostring(liveAbs), text_color = lsCol, bgcolor = cbg, text_size = size.small, text_halign = text.align_center)

    revCol = isChoppy ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    revWord = isChoppy ? 'ON (favorable)' : 'OFF (caution)'
    table.cell(tbl, 0, 5, 'Reversion', text_color = color.new(color.gray, 15), bgcolor = cbg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 5, revWord, text_color = revCol, bgcolor = cbg, text_size = size.small, text_halign = text.align_center)

    fsBg = fadeSetup ? color.new(#00E676, 55) : color.new(#0F0F1F, 0)
    table.cell(tbl, 0, 6, 'FADE setup', text_color = color.new(#FFD740, 0), bgcolor = fsBg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 6, fadeSetup ? 'YES — fire' : 'no', text_color = fadeSetup ? color.new(#00E676, 0) : color.new(color.gray, 20), bgcolor = fsBg, text_size = size.small, text_halign = text.align_center)

    table.cell(tbl, 0, 7, 'choppy = fade short streaks | trendy = stand aside', text_color = color.new(color.gray, 45), bgcolor = color.new(#07070F, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 7, 'win ' + str.tostring(i_win), text_color = color.new(color.gray, 45), bgcolor = color.new(#07070F, 0), text_size = size.tiny, text_halign = text.align_center)
````
