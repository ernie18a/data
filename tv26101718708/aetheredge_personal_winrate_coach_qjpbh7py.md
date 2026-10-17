# AetherEdge - Personal WinRate Coach

- url: https://www.tradingview.com/script/qjPbh7py/
- type: indicator
- pine_id: PUB;d807795996f4433b918373a04d6afad7
- version: 1.0

## Description

🖊️ Overview

AE-PWRC is a self-coaching tool that logs your past trade outcomes, learns which market regimes you tend to win in, and displays personalized advice like "You win ~70% in range / low-volatility regimes" in the HUD. Because Pine has no buttons, trades are entered as date-times in the settings. It also displays your historical win rate for the current regime in real time, helping suppress impulsive entries.

🔶 Key Features

Manual trade logging: up to 10 wins and 10 losses via date-time inputs
Auto regime categorization: 3 axes × 3 levels (trend, volatility, RSI state)
Personal win-rate learning: aggregates your actual rates per category
Auto-generated advice: surfaces the most striking category as a coaching message
"Here & now" real-time assessment: your past win rate for the current regime
Chart markers for logged trades visualizing where they occurred
Integrated HUD with overall win rate, per-category rates, and recommendations

🧠 Technical Architecture

Since Pine lacks button UIs, this tool adopts input.time date-time logging. After entering win/loss times, each bar checks time <= ts < time_close to identify the matching bar, snapshots the three-axis state (trend direction, volatility level, RSI state), and increments the win/loss bucket. Advice generation extracts, per axis, the category with the largest absolute deviation from 50% (with ≥3 samples), and the axis with the maximum deviation provides the headline. The current-regime assessment sums each axis's current-category past win rates into a "here & now" verdict.

⚙️ Recommended Settings & Tuning Guide

The key step is logging trades. In settings, paste trade date-times into Win/Loss slots: right-click a bar on the chart → "Set indicator parameters" → paste the time. Slots left at the default (2000-01-01) are ignored. Default category thresholds: High-Vol 1.2, Low-Vol 0.7. Trend EMA 20/60 sets range-detection sensitivity; lower Fast EMA for looser range classification.

💡 How to Use in Practice

Start by logging recent trades (~10 wins, ~10 losses). The HUD's COACH ADVICE then shows "you tend to win/lose in this kind of regime," objectively reflecting your trading patterns. In live trading, check HERE & NOW for your past win rate in the current regime — green (≥55%) means aggressive consideration, red (≤45%) means caution or skip. The more trades logged, the more accurate the advice. Update with fresh trades roughly monthly.

⚠️ Important Notes

This is a small-sample personal-statistics tool, not a deep ML agent. With few samples the noise is large; reliable advice needs at least 10–20 logged trades. "Log more trades for advice" in the HUD indicates insufficient samples. Pine doesn't support clickable buttons by design, so trade logging uses date-time inputs — slightly cumbersome but the most practical approach in Pine.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No win rate guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Personal WinRate Coach
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Personal WinRate Coach  ·  AE-PWRC                            │
// │                                                                            │
// │  Logs YOUR wins and losses, learns what market regimes you tend to do      │
// │  well (or badly) in, and offers light personalized advice such as          │
// │  "You win ~70% in range / low-volatility regimes — favor mean-reversion."  │
// │                                                                            │
// │  HOW TO LOG TRADES:                                                        │
// │  Pine has no clickable buttons, so wins and losses are entered as          │
// │  date-times in the settings — easiest by right-clicking the bar of your    │
// │  trade and using "Set indicator parameters" to paste the timestamp.        │
// │  Up to 10 wins and 10 losses can be entered. Anything left at default      │
// │  (the placeholder year) is ignored.                                        │
// │                                                                            │
// │  AT EACH LOGGED TRADE, the engine snapshots the market regime that bar     │
// │  occupied — Trend direction, Volatility level, RSI state — then aggregates │
// │  per-regime win rates. The coaching message picks the regime where your    │
// │  sample is largest and the rate departs most from 50%.                    │
// │                                                                            │
// │  HONEST SCOPE: this is small-sample personal statistics — not a deep ML    │
// │  agent. The "AI feel" comes from the regime breakdown and the auto-       │
// │  generated advice; it is genuinely useful only after a meaningful number  │
// │  of trades are logged.                                                    │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Personal WinRate Coach", "AE-PWRC", overlay = true,
     max_labels_count = 30)


// ============================================================================
//  ░░ INPUTS — manual trade logging ░░
//  Right-click the bar of your trade and paste the time into one of these.
//  Default (year 2000) is treated as "empty / not logged".
// ============================================================================
EMPTY = timestamp("2000-01-01")

gW = "▓ WIN TRADES (up to 10) ▓"
w1 = input.time(EMPTY, "Win 1",  group = gW)
w2 = input.time(EMPTY, "Win 2",  group = gW)
w3 = input.time(EMPTY, "Win 3",  group = gW)
w4 = input.time(EMPTY, "Win 4",  group = gW)
w5 = input.time(EMPTY, "Win 5",  group = gW)
w6 = input.time(EMPTY, "Win 6",  group = gW)
w7 = input.time(EMPTY, "Win 7",  group = gW)
w8 = input.time(EMPTY, "Win 8",  group = gW)
w9 = input.time(EMPTY, "Win 9",  group = gW)
w10= input.time(EMPTY, "Win 10", group = gW)

gL = "▓ LOSS TRADES (up to 10) ▓"
l1 = input.time(EMPTY, "Loss 1",  group = gL)
l2 = input.time(EMPTY, "Loss 2",  group = gL)
l3 = input.time(EMPTY, "Loss 3",  group = gL)
l4 = input.time(EMPTY, "Loss 4",  group = gL)
l5 = input.time(EMPTY, "Loss 5",  group = gL)
l6 = input.time(EMPTY, "Loss 6",  group = gL)
l7 = input.time(EMPTY, "Loss 7",  group = gL)
l8 = input.time(EMPTY, "Loss 8",  group = gL)
l9 = input.time(EMPTY, "Loss 9",  group = gL)
l10= input.time(EMPTY, "Loss 10", group = gL)

gR = "▓ REGIME DETECTION ▓"
rg_emaFastInp = input.int(20, "Trend EMA Fast", minval = 5, maxval = 100, group = gR)
rg_emaSlowInp = input.int(60, "Trend EMA Slow", minval = 20, maxval = 300, group = gR)
rg_atrThrInput= input.float(1.2, "High-Vol Threshold (× avg ATR)", minval = 1.0, maxval = 3.0, step = 0.1, group = gR,
     tooltip = "ATR above this multiple of its average = HIGH volatility regime.")
rg_atrLowInput= input.float(0.7, "Low-Vol Threshold (× avg ATR)", minval = 0.3, maxval = 1.0, step = 0.05, group = gR,
     tooltip = "ATR below this multiple of its average = LOW volatility regime.")

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_showMarks  = input.bool(true, "Mark Logged Trades on Chart", group = gV)
vi_hudPosInp  = input.string("Top Right", "Coach Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cWin  = na
var color cLoss = na
var color cAcc  = na
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [w, l, a] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #d4af37]
        => [#22d3ee, #f43f5e, #e879f9]   // Spectral
    [w, l, a]
[pw, pl, pa] = setPalette()
cWin  := pw
cLoss := pl
cAcc  := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ CURRENT BAR REGIME ░░
//  Three regime axes, each 3 levels: 3×3×3 = 27 cells, but we coach on each
//  axis independently to keep advice readable.
// ============================================================================
atr = ta.atr(14)
atrAvg = ta.sma(atr, 100)
atrRatio = sdiv(atr, atrAvg)

emaF = ta.ema(close, rg_emaFastInp)
emaS = ta.ema(close, rg_emaSlowInp)
trendStrength = sdiv(math.abs(emaF - emaS), atr)

// Axis A — Trend direction (3 levels): -1 bear / 0 range / +1 bull.
// Range = small EMA spread relative to ATR.
trendAxis = trendStrength < 0.3 ? 0 : emaF > emaS ? 1 : -1

// Axis B — Volatility (3 levels): -1 low / 0 normal / +1 high.
volAxis = atrRatio >= rg_atrThrInput ? 1 : atrRatio <= rg_atrLowInput ? -1 : 0

// Axis C — RSI state (3 levels): -1 oversold / 0 neutral / +1 overbought.
rsi = ta.rsi(close, 14)
rsiAxis = rsi >= 65 ? 1 : rsi <= 35 ? -1 : 0


// ============================================================================
//  ░░ TRADE LOG TABLES ░░
//  For each axis, three win/loss buckets indexed by axis value + 1 (so 0..2).
// ============================================================================
var int[] trendWins = array.new<int>(3, 0)
var int[] trendLoss = array.new<int>(3, 0)
var int[] volWins   = array.new<int>(3, 0)
var int[] volLoss   = array.new<int>(3, 0)
var int[] rsiWins   = array.new<int>(3, 0)
var int[] rsiLoss   = array.new<int>(3, 0)

// Per-trade marker tracking (so we mark each logged bar once).
var bool[] winLogged  = array.new<bool>(10, false)
var bool[] lossLogged = array.new<bool>(10, false)

logTrade(ts, isWin, slot) =>
    // Match the bar whose [time, time_close) range contains the trade time.
    if ts > EMPTY and time <= ts and ts < time_close
        already = isWin ? array.get(winLogged, slot) : array.get(lossLogged, slot)
        if not already
            tI = trendAxis + 1   // 0..2
            vI = volAxis + 1
            rI = rsiAxis + 1
            if isWin
                array.set(trendWins, tI, array.get(trendWins, tI) + 1)
                array.set(volWins,   vI, array.get(volWins,   vI) + 1)
                array.set(rsiWins,   rI, array.get(rsiWins,   rI) + 1)
                array.set(winLogged, slot, true)
            else
                array.set(trendLoss, tI, array.get(trendLoss, tI) + 1)
                array.set(volLoss,   vI, array.get(volLoss,   vI) + 1)
                array.set(rsiLoss,   rI, array.get(rsiLoss,   rI) + 1)
                array.set(lossLogged, slot, true)
            // Visual mark.
            if vi_showMarks
                yOff = isWin ? low - atr * 1.0 : high + atr * 1.0
                txt  = isWin ? "✓ WIN" : "✗ LOSS"
                col  = isWin ? cWin : cLoss
                style = isWin ? label.style_label_up : label.style_label_down
                label.new(bar_index, yOff, txt, yloc = yloc.price, color = col, textcolor = #000000, style = style, size = size.small)

if barstate.isconfirmed
    logTrade(w1, true, 0)
    logTrade(w2, true, 1)
    logTrade(w3, true, 2)
    logTrade(w4, true, 3)
    logTrade(w5, true, 4)
    logTrade(w6, true, 5)
    logTrade(w7, true, 6)
    logTrade(w8, true, 7)
    logTrade(w9, true, 8)
    logTrade(w10,true, 9)
    logTrade(l1, false, 0)
    logTrade(l2, false, 1)
    logTrade(l3, false, 2)
    logTrade(l4, false, 3)
    logTrade(l5, false, 4)
    logTrade(l6, false, 5)
    logTrade(l7, false, 6)
    logTrade(l8, false, 7)
    logTrade(l9, false, 8)
    logTrade(l10,false, 9)


// ============================================================================
//  ░░ ADVICE GENERATION ░░
//  For each axis, find the bucket with the biggest |winRate-50%| and at least
//  3 samples, and craft a sentence. Pick the strongest among the three axes
//  as the headline message.
// ============================================================================
analyzeAxis(winArr, lossArr) =>
    bestIdx = -1
    bestWR = 50.0
    bestN = 0
    bestDev = 0.0
    for i = 0 to 2
        w = array.get(winArr, i)
        l = array.get(lossArr, i)
        n = w + l
        if n >= 3
            wr = (w * 100.0) / n
            dev = math.abs(wr - 50.0)
            if dev > bestDev
                bestDev := dev
                bestWR := wr
                bestN := n
                bestIdx := i
    [bestIdx, bestWR, bestN, bestDev]

[tIdx, tWR, tN, tDev] = analyzeAxis(trendWins, trendLoss)
[vIdx, vWR, vN, vDev] = analyzeAxis(volWins,   volLoss)
[rIdx, rWR, rN, rDev] = analyzeAxis(rsiWins,   rsiLoss)

trendName(i) =>
    i == 0 ? "BEAR trend" : i == 1 ? "RANGE / chop" : "BULL trend"
volName(i) =>
    i == 0 ? "LOW volatility" : i == 1 ? "NORMAL volatility" : "HIGH volatility"
rsiName(i) =>
    i == 0 ? "OVERSOLD" : i == 1 ? "NEUTRAL" : "OVERBOUGHT"

formatLine(axisLabel, name, wr, n) =>
    verb = wr >= 60 ? "wins ~" : wr <= 40 ? "loses ~" : "performs ~"
    str.tostring(math.round(wr)) + "% in " + name + "  (n=" + str.tostring(n) + ")"

// Headline: the axis with the largest deviation from 50%.
headlineIdx = 0
headlineDev = tDev
if vDev > headlineDev
    headlineDev := vDev
    headlineIdx := 1
if rDev > headlineDev
    headlineDev := rDev
    headlineIdx := 2

headlineName = headlineIdx == 0 ? (tIdx >= 0 ? trendName(tIdx) : "—") : headlineIdx == 1 ? (vIdx >= 0 ? volName(vIdx) : "—") : (rIdx >= 0 ? rsiName(rIdx) : "—")
headlineWR   = headlineIdx == 0 ? tWR : headlineIdx == 1 ? vWR : rWR
headlineN    = headlineIdx == 0 ? tN  : headlineIdx == 1 ? vN  : rN

// Current regime headline.
curTrendName = trendName(trendAxis + 1)
curVolName   = volName(volAxis + 1)
curRsiName   = rsiName(rsiAxis + 1)


// ============================================================================
//  ░░ COACH HUD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

var table hud = na
if na(hud)
    hud := table.new(hudPos(vi_hudPosInp), 2, 10, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

// Totals.
totalWins = 0
totalLoss = 0
for i = 0 to 2
    totalWins += array.get(trendWins, i)
    totalLoss += array.get(trendLoss, i)
overallN = totalWins + totalLoss
overallWR = overallN > 0 ? (totalWins * 100.0) / overallN : na

if barstate.islast
    table.cell(hud, 0, 0, "PERSONAL WINRATE COACH", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "n=" + str.tostring(overallN), text_color = cTxtD, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_right)

    overallTxt = na(overallWR) ? "—  (no trades logged)" : str.tostring(math.round(overallWR)) + "%  (" + str.tostring(totalWins) + "W / " + str.tostring(totalLoss) + "L)"
    overallCol = na(overallWR) ? cTxtD : overallWR >= 55 ? cWin : overallWR <= 45 ? cLoss : cTxt
    table.cell(hud, 0, 1, "overall win rate", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 1, overallTxt, text_color = overallCol, text_size = size.normal, text_halign = text.align_right)

    // Personalized advice (headline).
    table.cell(hud, 0, 2, "▔ COACH ADVICE ▔", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 2, "", bgcolor = cPanelHd)

    adviceTxt = ""
    adviceCol = cTxtD
    if headlineDev >= 10 and headlineN >= 3
        verb = headlineWR >= 55 ? "You WIN ~" : headlineWR <= 45 ? "You LOSE ~" : "You're around ~"
        adviceTxt := verb + str.tostring(math.round(headlineWR)) + "% in " + headlineName
        adviceCol := headlineWR >= 55 ? cWin : headlineWR <= 45 ? cLoss : cTxt
    else if overallN < 5
        adviceTxt := "Log more trades for advice"
    else
        adviceTxt := "No standout regime yet"

    table.cell(hud, 0, 3, "→", text_color = cAcc, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 3, adviceTxt, text_color = adviceCol, text_size = size.normal, text_halign = text.align_right)

    // Now → current regime.
    table.cell(hud, 0, 4, "current regime", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 4, curTrendName, text_color = cTxt, text_size = size.normal, text_halign = text.align_right)
    table.cell(hud, 0, 5, "  volatility", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 5, curVolName, text_color = cTxt, text_size = size.normal, text_halign = text.align_right)
    table.cell(hud, 0, 6, "  RSI state", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 6, curRsiName, text_color = cTxt, text_size = size.normal, text_halign = text.align_right)

    // "Now" personalized verdict for current regime (across all 3 axes).
    curTrW = array.get(trendWins, trendAxis + 1)
    curTrL = array.get(trendLoss, trendAxis + 1)
    curVoW = array.get(volWins,   volAxis + 1)
    curVoL = array.get(volLoss,   volAxis + 1)
    curRsW = array.get(rsiWins,   rsiAxis + 1)
    curRsL = array.get(rsiLoss,   rsiAxis + 1)
    sumW = curTrW + curVoW + curRsW
    sumL = curTrL + curVoL + curRsL
    sumN = sumW + sumL
    curWR = sumN > 0 ? (sumW * 100.0) / sumN : na

    nowTxt = na(curWR) ? "—  (no data here)" : "you're ~" + str.tostring(math.round(curWR)) + "% in regimes like this"
    nowCol = na(curWR) ? cTxtD : curWR >= 55 ? cWin : curWR <= 45 ? cLoss : cTxt
    table.cell(hud, 0, 7, "▔ HERE & NOW ▔", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 7, "", bgcolor = cPanelHd)
    table.cell(hud, 0, 8, "verdict", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 8, nowTxt, text_color = nowCol, text_size = size.normal, text_halign = text.align_right)
    suggestion = na(curWR) ? "" : curWR >= 60 ? "✓ favorable conditions" : curWR <= 40 ? "✗ historically tough here" : "· neutral conditions"
    table.cell(hud, 0, 9, "suggestion", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 9, suggestion, text_color = nowCol, text_size = size.normal, text_halign = text.align_right)
````
