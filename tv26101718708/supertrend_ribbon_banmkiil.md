# SUPERTREND RIBBON

- url: https://www.tradingview.com/script/bANMKiil-SUPERTREND-RIBBON/
- type: indicator
- pine_id: PUB;852d7e0b3e58466a8640d11bb795ee67
- version: 1.0

## Description

supertrend ribbon

supertrend ribbon is a confirmed trend ribbon built from multiple supertrend bands. it is designed to show a clean, stable, and readable market direction directly on the chart.

instead of allowing each band to change color separately, the ribbon uses one master trend state. this keeps the full ribbon in one confirmed color and helps avoid visual fragmentation, false flips, and noisy mid-trend breaks.

the goal is simple: show whether the market is in a confirmed bullish or bearish trend, while keeping the chart clean and easy to read.

---

main concept

the indicator uses 8 supertrend bands with different factors.

each band can be bullish or bearish.
the script counts how many bands are aligned in the same direction.
when enough bands confirm a new direction, the full ribbon changes trend.

this creates a more stable trend filter than a single supertrend line, because the ribbon does not flip on every small price movement.

---

what the indicator shows

trend ribbon
the ribbon shows the dominant trend state.
green means confirmed bullish trend.
red means confirmed bearish trend.

band lines
the internal band lines can be displayed to see the full structure of the ribbon.

ribbon fill
the fill between the bands makes the trend easier to read visually.

core line
the core line gives a fast reference for the main trend path.

confirmed flip markers
markers appear only when a trend flip is confirmed.

trend background tint
a soft background color can be enabled to show the current trend regime.

dashboard
the dashboard shows the current trend, the number of aligned bands, flip requirements, fast core direction, and early long / short validity.

---

inputs guide

atr period
sets the atr period used by the supertrend bands.
a lower value makes the ribbon more reactive.
a higher value makes the ribbon smoother and more stable.

base factor
sets the starting supertrend factor.
a lower value keeps the ribbon closer to price.
a higher value makes the ribbon wider and more filtering.

factor step
sets the spacing between the 8 supertrend bands.
a lower value makes the bands tighter.
a higher value makes the ribbon wider.

bands to confirm a flip
sets how many bands must confirm a new direction before the ribbon changes color.
a higher value reduces false flips.
a lower value makes the ribbon faster.

confirm for n bars
sets how many bars the confirmation condition must remain valid before the trend flips.
1 is faster.
2 or 3 is stricter and can reduce whipsaws.

show band lines
shows or hides the internal ribbon lines.

show ribbon fill
shows or hides the fill between the bands.

core glow
enables a glow effect around the core line.

show core line
shows or hides the main core line.

show confirmed flip markers
shows or hides confirmed trend flip markers.

trend background tint
enables or disables the soft trend background.

show dashboard
shows or hides the dashboard.

dashboard position
sets the dashboard position on the chart.

bull
sets the bullish trend color.

bear
sets the bearish trend color.

accent / transition
sets the accent color used for dashboard and transition information.

neutral
sets the neutral text and information color.

---

how to use the indicator

the ribbon is best used as a trend filter.

when the ribbon is green, the market is in a confirmed bullish trend.
in this condition, long setups have priority.

when the ribbon is red, the market is in a confirmed bearish trend.
in this condition, short setups have priority.

the ribbon should not be used as a standalone entry signal.
its main purpose is to help avoid trading against the dominant trend.

---

beginner tutorial

1. add the indicator to the chart.

2. start with the default settings.

3. look at the ribbon color.

4. if the ribbon is green, focus mainly on long opportunities.

5. if the ribbon is red, focus mainly on short opportunities.

6. avoid buying when the ribbon is red.

7. avoid selling when the ribbon is green.

8. use confirmed flip markers to identify confirmed trend changes.

9. use the dashboard to check how many bands are aligned.

10. combine the ribbon with market structure, volume, support and resistance, order blocks, liquidity zones, and proper risk management.

---

simple usage example

if price is above the ribbon and the ribbon is green, the market is in a bullish trend.

a trader can wait for price to pull back toward the ribbon, then look for a bullish reaction before considering a long setup.

if price is below the ribbon and the ribbon is red, the market is in a bearish trend.

a trader can wait for price to pull back toward the ribbon, then look for a bearish rejection before considering a short setup.

---

order block filter example

a bullish order block is stronger when the ribbon is green.

a bearish order block is stronger when the ribbon is red.

if a long setup appears while the ribbon is red, the setup is more risky.

if a short setup appears while the ribbon is green, the setup is more risky.

the ribbon can therefore be used as a confirmation filter before taking early entries.

---

beginner settings

atr period: 10
base factor: 1.0
factor step: 0.4
bands to confirm a flip: 6
confirm for n bars: 1
show band lines: on
show ribbon fill: on
show core line: on
show confirmed flip markers: on
trend background tint: personal preference
show dashboard: on

this setup gives a balanced mix of reactivity and stability.

---

stricter settings

bands to confirm a flip: 7
confirm for n bars: 2 or 3

this setup reduces false flips, but trend changes appear later.

---

faster settings

bands to confirm a flip: 5
confirm for n bars: 1

this setup reacts faster, but it can create more false flips in choppy markets.

---

important notes

the ribbon shows a trend regime, not a guaranteed entry signal.

the best use is to trade in the direction of the ribbon.

confirmed flips are more reliable than fast color changes.

a green ribbon means long setups have better context.

a red ribbon means short setups have better context.

risk management is required on every trade.

supertrend ribbon is designed to make trend direction clear, reduce visual noise, and help traders stay aligned with the dominant market structure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("SUPERTREND RIBBON", shorttitle="ST RIBBON", overlay=true, max_labels_count=500)

gR = "═══ RIBBON ENGINE ═══"
atrP   = input.int(10,   "ATR Period",  minval=1, group=gR)
baseF  = input.float(1.0, "Base Factor", minval=0.25, step=0.25, group=gR)
stepF  = input.float(0.4, "Factor Step", minval=0.05, step=0.05, group=gR, tooltip="Spacing between the 8 supertrend bands.")

gF = "═══ CONFIRMATION (anti-cassure) ═══"
confirm     = input.int(6, "Bands to confirm a FLIP", minval=4, maxval=8, group=gF, tooltip="Flip to BULL needs ≥ this many bull bands; flip to BEAR needs ≤ (8 − this). Higher = stickier, fewer breaks. Between the two thresholds the trend HOLDS.")
confirmBars = input.int(1, "Confirm for N bars", minval=1, maxval=10, group=gF, tooltip="Require the threshold to hold this many bars before flipping. 2-3 = even fewer whipsaws.")

gX = "═══ VISUAL ═══"
showLines = input.bool(true,  "Show Band Lines", group=gX)
showFill  = input.bool(true,  "Show Ribbon Fill", group=gX)
glow      = input.bool(false,  "Core Glow", group=gX)
showCore  = input.bool(true,  "Show Core Line", group=gX)
showFlips = input.bool(true,  "Show Confirmed Flip Markers", group=gX)
showBg    = input.bool(false,  "Trend Background Tint", group=gX)
showDash  = input.bool(true,  "Show Dashboard", group=gX)
dashPos   = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gX)

gC = "═══ AESTHETICS ═══"
colBull = input.color(#00FFD1, "Bull", group=gC)
colBear = input.color(#FF3B5C, "Bear", group=gC)
colGold = input.color(color.rgb(75, 213, 231), "Accent / Transition", group=gC)
colNeu  = input.color(#9AB0C7, "Neutral", group=gC)

[st1, d1] = ta.supertrend(baseF + 0 * stepF, atrP)
[st2, d2] = ta.supertrend(baseF + 1 * stepF, atrP)
[st3, d3] = ta.supertrend(baseF + 2 * stepF, atrP)
[st4, d4] = ta.supertrend(baseF + 3 * stepF, atrP)
[st5, d5] = ta.supertrend(baseF + 4 * stepF, atrP)
[st6, d6] = ta.supertrend(baseF + 5 * stepF, atrP)
[st7, d7] = ta.supertrend(baseF + 6 * stepF, atrP)
[st8, d8] = ta.supertrend(baseF + 7 * stepF, atrP)

bcnt = (d1 < 0 ? 1 : 0) + (d2 < 0 ? 1 : 0) + (d3 < 0 ? 1 : 0) + (d4 < 0 ? 1 : 0) + (d5 < 0 ? 1 : 0) + (d6 < 0 ? 1 : 0) + (d7 < 0 ? 1 : 0) + (d8 < 0 ? 1 : 0)
scnt = 8 - bcnt
coreBull = d1 < 0

upThresh = confirm
dnThresh = 8 - confirm

var int master = 0
var int upStreak = 0
var int dnStreak = 0
upStreak := bcnt >= upThresh ? upStreak + 1 : 0
dnStreak := bcnt <= dnThresh ? dnStreak + 1 : 0

if master == 0
    master := bcnt >= 4 ? 1 : -1
if upStreak >= confirmBars
    master := 1
if dnStreak >= confirmBars
    master := -1

masterBull = master == 1
mcol = masterBull ? colBull : colBear

inHold = masterBull ? (bcnt < upThresh) : (scnt < upThresh)

lt = showLines ? 55 : 100
p1 = plot(st1, "Band 1", color=color.new(mcol, lt), linewidth=1)
p2 = plot(st2, "Band 2", color=color.new(mcol, lt), linewidth=1)
p3 = plot(st3, "Band 3", color=color.new(mcol, lt), linewidth=1)
p4 = plot(st4, "Band 4", color=color.new(mcol, lt), linewidth=1)
p5 = plot(st5, "Band 5", color=color.new(mcol, lt), linewidth=1)
p6 = plot(st6, "Band 6", color=color.new(mcol, lt), linewidth=1)
p7 = plot(st7, "Band 7", color=color.new(mcol, lt), linewidth=1)
p8 = plot(st8, "Band 8", color=color.new(mcol, lt), linewidth=1)

ft = showFill ? 0 : 100
fill(p1, p2, color=color.new(mcol, 70 + ft))
fill(p2, p3, color=color.new(mcol, 74 + ft))
fill(p3, p4, color=color.new(mcol, 78 + ft))
fill(p4, p5, color=color.new(mcol, 81 + ft))
fill(p5, p6, color=color.new(mcol, 84 + ft))
fill(p6, p7, color=color.new(mcol, 87 + ft))
fill(p7, p8, color=color.new(mcol, 90 + ft))

plot(showCore and glow ? st1 : na, "Core Glow", color=color.new(mcol, 70), linewidth=7)
plot(showCore and glow ? st1 : na, "Core Halo", color=color.new(mcol, 45), linewidth=4)
plot(showCore ? st1 : na, "Core", color=color.new(mcol, 0), linewidth=2)

bgcolor(showBg ? color.new(mcol, 95) : na)

flipBull = master == 1 and master[1] != 1
flipBear = master == -1 and master[1] != -1

bullValid = masterBull
bearValid = not masterBull

plotshape(showFlips and flipBull, "Flip Bull", shape.triangleup,   location.belowbar, color.new(colBull, 0), size=size.small, text="▲", textcolor=colBull)
plotshape(showFlips and flipBear, "Flip Bear", shape.triangledown, location.abovebar, color.new(colBear, 0), size=size.small, text="▼", textcolor=colBear)

plot(bullValid ? 1 : 0, "BullValid", display=display.none)
plot(bearValid ? 1 : 0, "BearValid", display=display.none)
plot(master,            "MasterTrend", display=display.none)
plot(bcnt,              "BullCount", display=display.none)

alertcondition(flipBull, "Confirmed Bull Flip", "RIBBON — trend confirmed BULL")
alertcondition(flipBear, "Confirmed Bear Flip", "RIBBON — trend confirmed BEAR")

bar8(int n) => str.repeat("█", math.max(0, n)) + str.repeat("░", math.max(0, 8 - n))
posSel = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.middle_right
var table dash = table.new(posSel, 2, 7, bgcolor=color.new(#0A0E14, 6), frame_color=color.new(colGold, 40), frame_width=1, border_color=color.new(#16202E, 60), border_width=1)
cell(int c, int r, string t, color tc, color bg) => table.cell(dash, c, r, t, text_color=tc, bgcolor=bg, text_size=size.small, text_halign=text.align_left)

trendTxt = masterBull ? "▲ BULL" + (inHold ? " (hold)" : "") : "▼ BEAR" + (inHold ? " (hold)" : "")
longV  = masterBull ? "✓ VALID" : "✗ AVOID"
shortV = masterBull ? "✗ AVOID" : "✓ VALID"
longC  = masterBull ? colBull : colBear
shortC = masterBull ? colBear : colBull

if showDash and barstate.islast
    cell(0, 0, "ST RIBBON", colGold, color.new(#0A0E14, 0))
    cell(1, 0, "CONFIRMED", color.new(colGold, 0), color.new(#0A0E14, 0))
    cell(0, 1, "Trend", colNeu, color.new(#101722, 20))
    cell(1, 1, trendTxt, mcol, color.new(#101722, 20))
    cell(0, 2, "Aligned", colNeu, color.new(#0D131C, 20))
    cell(1, 2, bar8(bcnt) + "  " + str.tostring(bcnt) + "/8", mcol, color.new(#0D131C, 20))
    cell(0, 3, "Flip needs", colNeu, color.new(#101722, 20))
    cell(1, 3, "≥" + str.tostring(upThresh) + "▲ / ≤" + str.tostring(dnThresh) + "▲  ×" + str.tostring(confirmBars) + "bar", #C7D3E0, color.new(#101722, 20))
    cell(0, 4, "Core (fast)", colNeu, color.new(#0D131C, 20))
    cell(1, 4, coreBull ? "▲ early bull" : "▼ early bear", coreBull ? colBull : colBear, color.new(#0D131C, 20))
    cell(0, 5, "Early LONG", colNeu, color.new(#101722, 20))
    cell(1, 5, longV, #0A0E14, color.new(longC, 10))
    cell(0, 6, "Early SHORT", colNeu, color.new(#0D131C, 20))
    cell(1, 6, shortV, #0A0E14, color.new(shortC, 10))
````
