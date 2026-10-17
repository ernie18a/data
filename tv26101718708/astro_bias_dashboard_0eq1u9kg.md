# Astro Bias Dashboard 

- url: https://www.tradingview.com/script/0eQ1U9kg-Astro-Bias-Dashboard/
- type: indicator
- pine_id: PUB;702bfaee876f46f29938f4be37fcf34e
- version: 2.0

## Description

🧭 ASTRO BIAS DASHBOARD

A one-glance morning dashboard that combines five classical astronomical cycles into a single daily bias score — and then checks that bias against live price action before suggesting anything.

━━━ HOW IT WORKS ━━━

The script computes real astronomical values using mean-longitude formulas (J2000 epoch):

- Moon phase — waxing or waning, with illumination percent
- Sun-Moon angle — harmony (trine/sextile), tension (square/opposition), or neutral
- Mercury retrograde — approximated from the 115.88-day synodic cycle
- Eclipse season — Sun's proximity to the lunar nodes
- Planetary hour (hora) — Chaldean sequence from a user-set sunrise time

The first four factors are captured once at the start of each session and stay FIXED for the whole day (score out of 4). This is deliberate: a daily bias that flickers intrabar is useless. Only the hora row updates hourly, because it is a timing tool by design — and it is intentionally excluded from the score.

The dashboard then adds a live reality check: price versus EMA 50. A final Verdict row compares the fixed astro bias with the live trend:

- ALIGNED — astro bias and price agree
- CONFLICT — price is moving against the bias. Price always wins; the dashboard tells you to stand aside.

━━━ HOW TO USE ━━━

1. Check the dashboard once at market open — the bias is fixed for the day.
2. Trade only in the Verdict row's direction. On CONFLICT, reduce size or stay flat.
3. Use the hora row for entry timing: benefic horas (Moon, Mercury, Venus, Jupiter) are preferred entry windows.
4. Combine with your own levels and setups — this is a context filter, not an entry signal.

Alerts included: daily bias bullish/caution, hora change, astro-price conflict, astro-price alignment.

━━━ SETTINGS ━━━

Sunrise hour, dashboard position (8 placements), text size, EMA 50 plot toggle and color, trade-plan rows toggle.

━━━ NOTES & ORIGINALITY ━━━

All astronomical values are computed from scratch inside Pine using mean-longitude approximations — no external data, no libraries, no reused code. Accuracy is well within the tolerance needed for cycle-timing work, though exact panchang timings may differ by a few hours.

This tool treats astronomical cycles strictly as a timing reference. It does not predict market direction, and nothing here is financial advice. Always confirm with price action and manage risk.

## Source Code

````pine
// Radhe Radhe 🙏 @darshakssc
//@version=6
indicator("Astro Bias Dashboard 🧭 [darshakssc]", "AstroBias", overlay = true)

// ─── Inputs ───────────────────────────────────────────────
srH = input.int(6, "Sunrise hour (exchange time)", minval = 0, maxval = 23, group = "Settings")
pos = input.string("Bottom right", "Dashboard position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = "Display")
txSize  = input.string("Small", "Text size", options = ["Normal", "Medium", "Small", "Tiny"], group = "Display", tooltip = "Small/Tiny recommended for mobile screens")
showPlan = input.bool(true, "Show trade plan rows", group = "Display")
showEma = input.bool(true, "Plot EMA 50 on chart", group = "Display")
cEma = input.color(color.new(#2962FF, 0), "EMA 50 color", group = "Display")

// ─── Astro math ───────────────────────────────────────────
J2000 = timestamp("GMT", 2000, 1, 1, 12, 0, 0)
d = (time - J2000) / 86400000.0
norm360(float x) =>
    r = x % 360.0
    r < 0 ? r + 360.0 : r
angDiff(float a, float b) =>
    dd = math.abs(norm360(a) - norm360(b))
    dd > 180 ? 360 - dd : dd

sunL  = norm360(280.460 + 0.98564736 * d)
moonL = norm360(218.316 + 13.17639648 * d)
nodeL = norm360(125.045 - 0.05295377 * d)
elong = norm360(moonL - sunL)

// ─── DAY-ANCHORED bias factors (captured once per day, FIXED all day) ─
newDay = ta.change(time("D")) != 0

var bool  dWax   = false
var float dPhase = 0.0
var float dElong = 0.0
var bool  dHarm  = false
var bool  dTense = false
var bool  dRetro = false
var bool  dEcl   = false

mercEp = timestamp("GMT", 2024, 12, 6, 0, 0, 0)
mCyc = 115.877
mPosR = ((time - mercEp) / 86400000.0) % mCyc
mPos = mPosR < 0 ? mPosR + mCyc : mPosR
distNode = math.min(angDiff(sunL, nodeL), angDiff(sunL, nodeL + 180))

if newDay or barstate.isfirst
    dWax   := elong < 180
    dPhase := (1.0 - math.cos(math.toradians(elong))) / 2.0 * 100.0
    dElong := elong
    dHarm  := angDiff(elong, 120) <= 8 or angDiff(elong, 240) <= 8 or angDiff(elong, 60) <= 8 or angDiff(elong, 300) <= 8
    dTense := angDiff(elong, 90) <= 8 or angDiff(elong, 270) <= 8 or angDiff(elong, 180) <= 8
    dRetro := mPos < 11.5 or mPos > mCyc - 11.5
    dEcl   := distNode <= 15

// Score out of 4 — STABLE for the entire session
score = (dWax ? 1 : 0) + (dHarm ? 1 : dTense ? 0 : 1) + (dRetro ? 0 : 1) + (dEcl ? 0 : 1)
bias  = score == 4 ? "BULLISH" : score == 3 ? "MILD BULLISH" : score == 2 ? "NEUTRAL" : score == 1 ? "CAUTION" : "AVOID"

// ─── Hora (live by design — timing row only, NOT in score) ─
var string[] hNames = array.from("☉ Sun", "♀ Venus", "☿ Mercury", "☾ Moon", "♄ Saturn", "♃ Jupiter", "♂ Mars")
var bool[]   hBene  = array.from(false, true, true, true, false, true, false)
var int[] dayLord = array.from(0, 3, 6, 2, 5, 1, 4)
msr = hour * 60 + minute - srH * 60
msrA = msr < 0 ? msr + 1440 : msr
lordIdx = array.get(dayLord, msr < 0 ? (dayofweek - 1 + 6) % 7 : dayofweek - 1)
horaIdx = (lordIdx + int(math.floor(msrA / 60.0))) % 7
horaName = array.get(hNames, horaIdx)
horaGood = array.get(hBene, horaIdx)

// ─── LIVE price reality check (price > astro, always) ─────
ema50 = ta.ema(close, 50)
trendUp = close > ema50
plot(showEma ? ema50 : na, "EMA 50", color = cEma, linewidth = 2)
verdict = score >= 3 and trendUp     ? "ALIGNED ✓ — trade longs" :
          score >= 3 and not trendUp ? "CONFLICT — price wins, NO longs" :
          score <= 1 and not trendUp ? "ALIGNED ✓ — shorts / stay out" :
          score <= 1 and trendUp     ? "CONFLICT — price wins, no shorts" :
                                       "Follow price action normally"
vGood = (score >= 3 and trendUp) or (score <= 1 and not trendUp)
vConf = (score >= 3 and not trendUp) or (score <= 1 and trendUp)

// ─── Trade plan per bias ──────────────────────────────────
plan1 = score == 4 ? "Prefer LONGS · buy dips at support" : score == 3 ? "Longs with confirmation · normal size" : score == 2 ? "Both sides OK · wait for clean setups" :score == 1 ? "Reduce size · quick profit booking" :
                     "Avoid fresh trades · protect capital"
plan2 = horaGood ? "Hora ✓ favourable — good entry window now" : "Hora ✕ malefic — wait for next hora to enter"

// ─── Dashboard (dark premium) ─────────────────────────────
tPos = pos == "Top left" ? position.top_left : pos == "Top center" ? position.top_center : pos == "Top right" ? position.top_right : pos == "Middle left" ? position.middle_left : pos == "Middle right" ? position.middle_right : pos == "Bottom left" ? position.bottom_left : pos == "Bottom center" ? position.bottom_center : position.bottom_right
tS = txSize == "Normal" ? size.small : txSize == "Medium" ? size.small : txSize == "Small" ? size.tiny : size.tiny
tH = txSize == "Normal" ? size.normal : txSize == "Medium" ? size.small : txSize == "Small" ? size.small : size.tiny

pBg   = color.new(#131722, 2)
pBrd  = color.new(#363A45, 0)
tMain = color.new(#F8F9FD, 0)
tMut  = color.new(#B2B5BE, 0)
tGood = color.new(#26C281, 0)
tBad  = color.new(#FF6B6B, 0)
tNeu  = color.new(#B2B5BE, 0)
bCol  = score >= 3 ? tGood : score == 2 ? tNeu : tBad
bBg   = score >= 3 ? color.new(#0F6E56, 45) : score <= 1 ? color.new(#993C1D, 45) : color.new(#363A45, 25)

var table tb = table.new(tPos, 2, 11, bgcolor = pBg, border_width = 2, border_color = pBrd, frame_width = 3, frame_color = pBrd)
if barstate.islast
    table.clear(tb, 0, 0, 1, 10)
    table.cell(tb, 0, 0, "🧭 ASTRO BIAS", text_size = tH, text_color = tMain)
    table.cell(tb, 1, 0, "fixed for today", text_size = size.tiny, text_color = tMut)
    table.cell(tb, 0, 1, "Moon", text_size = tS, text_color = tMut)
    table.cell(tb, 1, 1, (dWax ? "Waxing " : "Waning ") + str.tostring(dPhase, "#") + "%", text_size = tS, text_color = dWax ? tGood : tBad)
    table.cell(tb, 0, 2, "Sun-Moon", text_size = tS, text_color = tMut)
    table.cell(tb, 1, 2, str.tostring(dElong, "#") + "° " + (dHarm ? "harmony ✓" : dTense ? "tension ✕" : "neutral"), text_size = tS, text_color = dHarm ? tGood : dTense ? tBad : tNeu)
    table.cell(tb, 0, 3, "☿ Retro", text_size = tS, text_color = tMut)
    table.cell(tb, 1, 3, dRetro ? "Active ⚠" : "None ✓", text_size = tS, text_color = dRetro ? tBad : tGood)
    table.cell(tb, 0, 4, "Eclipse", text_size = tS, text_color = tMut)
    table.cell(tb, 1, 4, dEcl ? "Season ⚠" : "Clear ✓", text_size = tS, text_color = dEcl ? tBad : tGood)
    table.cell(tb, 0, 5, bias, text_size = tH, text_color = bCol, bgcolor = bBg)
    table.cell(tb, 1, 5, "score " + str.tostring(score) + "/4", text_size = tS, text_color = bCol, bgcolor = bBg)
    table.cell(tb, 0, 6, "Hora now", text_size = tS, text_color = tMut)
    table.cell(tb, 1, 6, horaName + (horaGood ? "  ✓" : "  ✕") + " (hourly)", text_size = tS, text_color = horaGood ? tGood : tBad)
    table.cell(tb, 0, 7, "Price trend", text_size = tS, text_color = tMut)
    table.cell(tb, 1, 7, trendUp ? "Above EMA50 ↑ (live)" : "Below EMA50 ↓ (live)", text_size = tS, text_color = trendUp ? tGood : tBad)
    table.cell(tb, 0, 8, "⚖ Verdict", text_size = tS, text_color = tMain, bgcolor = vConf ? color.new(#7A5C13, 40) : vGood ? color.new(#0F6E56, 45) : color.new(#363A45, 25))
    table.cell(tb, 1, 8, verdict, text_size = tS, text_color = vConf ? color.new(#FFD166, 0) : vGood ? tGood : tNeu, bgcolor = vConf ? color.new(#7A5C13, 40) : vGood ? color.new(#0F6E56, 45) : color.new(#363A45, 25), text_halign = text.align_left)
    if showPlan
        table.cell(tb, 0, 9, "📋 Plan", text_size = tS, text_color = tMain)
        table.cell(tb, 1, 9, plan1, text_size = tS, text_color = tMain, text_halign = text.align_left)
        table.cell(tb, 0, 10, "", text_size = tS)
        table.cell(tb, 1, 10, plan2, text_size = tS, text_color = horaGood ? tGood : tMut, text_halign = text.align_left)

// ─── Alerts ───────────────────────────────────────────────
dayBiasUp = newDay and score >= 3 and score[1] < 3
dayBiasDn = newDay and score <= 1 and score[1] > 1
horaChange = horaIdx != horaIdx[1]
alertcondition(dayBiasUp,  "Day bias bullish",  "Astro Bias: today's fixed bias is BULLISH on {{ticker}} — prefer longs at supports")
alertcondition(dayBiasDn,  "Day bias caution",  "Astro Bias: today's fixed bias is CAUTION on {{ticker}} — reduce size")
alertcondition(horaChange, "Hora change", "Astro Bias: planetary hour changed on {{ticker}} — check entry window")
alertcondition(vConf and not vConf[1], "Astro-price CONFLICT", "Astro Bias: price is moving AGAINST today's astro bias on {{ticker}} — price wins, stand aside")
alertcondition(vGood and not vGood[1], "Astro-price ALIGNED", "Astro Bias: price and astro bias are ALIGNED on {{ticker}} — best conditions to trade")
````
