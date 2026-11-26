# AetherEdge - Consensus Council

- url: https://www.tradingview.com/script/mOnZQiRJ/
- type: indicator
- pine_id: PUB;38bca291b9124590acdc86c0c710b697
- version: 1.0

## Description

🖊️ Overview

AE-COUNCIL is a next-generation signal system where seven specialized agents collaborate. Five entry agents (Trend, S/R, Volume, Momentum, Volatility) vote on direction, and two risk-management agents (Risk Manager, Reward Manager) dynamically compute SL and three-tier TPs. Entry arrows print alongside SL/TP1/TP2/TP3 horizontal lines, and Hit labels fire automatically on touch — a fully automated decision system.

🔶 Key Features

7-agent collaborative design: 5 entry + 2 risk-management agents
Dynamic TP/SL: auto-computed from ATR, volatility regime, structure, momentum
3-tier TP: TP1/TP2/TP3 multi-target take-profit management
Strong-signal double-lock: requires threshold + Trend/S/R agreement
Auto Hit tracking: real-time labels on SL/TP touches
Optional trailing: SL trails only while Momentum agrees
Detailed dashboard: per-agent votes, consensus score, confidence, active trade status
Optional individual-agent display for full transparency
Background tint by consensus
Per-event alerts: Strong Buy/Sell/TP Hit/SL Hit

🧠 Technical Architecture

This is a consensus system of seven independent rule-based agents. Trend votes on 3-EMA stack ordering, ADX > 20, and HH/LL breaks. S/R votes when within 0.8 ATR of a confirmed swing (Order-Block proxy). Volume votes when volume z-score ≥ 1.0 and OBV direction matches candle direction. Momentum votes on RSI / MACD-histogram / Stochastic K alignment. Volatility identifies expansion/squeeze via Bollinger band width and votes only during expansion. Risk Manager computes SL = ATR × 1.5 × volMul × structMul; Reward Manager places TP2 = SL × RR × momentumBoost, TP1 from structure, TP3 = TP2 × 1.6. The Strong condition fires only when voteSum ≥ threshold AND Trend agrees AND S/R agrees or is neutral, structurally suppressing false signals. Active trades are tracked in parallel arrays, with SL/TP checks and trailing updated per bar.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Consensus Threshold 3 (recommended) demands 3-of-5 alignment — raise to 4 for strictness or lower to 2 for laxness. Default RR Ratio 2.5 anchors TP2; choose 1.5 conservative or 4.0 aggressive. Use Trailing Stop helps in trend-following regimes but can exit early in ranges. Max TP Levels caps how many TP lines display. Show Individual Agents reveals each vote at the bottom of the chart for full transparency.

💡 How to Use in Practice

When a Strong arrow prints, read the summary bubble: "Strong BUY (4/5)" means four agents agreed, with SL/TP1/RR shown at a glance. The horizontal lines persist on the chart, so you can exit on SL approach, partial-take at TP1, hold to TP2/TP3 with intuitive staged exits. Check per-agent votes in the dashboard — if Momentum and Volume also align, conviction is higher; during a Squeeze, stand aside. The HUD's SL distance % tracks live risk on active trades.

⚠️ Important Notes

This is multi-agent-style, not true multi-agent reinforcement learning. Each agent is an independent classical rule; there is no inter-agent communication or deep-learning co-optimization. Volume Profile and Order Block are proxy implementations (volume z-score + OBV; confirmed swings as OB stand-in), not full versions. SL/TP levels are probabilistic estimates, not guaranteed touches. Trailing operates only while Momentum agrees, working best during sustained trends.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal or SL/TP level guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Multi-Agent Consensus Council with Dynamic TP/SL
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Consensus Council  ·  AE-COUNCIL                              │
// │                                                                            │
// │  A 7-AGENT decision system: 5 entry agents vote, 2 risk-management agents  │
// │  size TP/SL dynamically. Strong consensus prints a clear arrow with all    │
// │  three TP levels and an SL line drawn at the entry bar, then tracked until │
// │  hit. Optional trailing stop. A council dashboard makes every vote visible.│
// │                                                                            │
// │  ENTRY AGENTS:                                                             │
// │    1. TREND       — EMA stack, ADX direction, HH/LL                        │
// │    2. S/R         — proximity to confirmed swings (Order-Block proxy)      │
// │    3. VOLUME      — volume z-score + OBV direction                         │
// │    4. MOMENTUM    — RSI, MACD histogram, Stochastic alignment              │
// │    5. VOLATILITY  — ATR/BBwidth regime, squeeze detection                  │
// │                                                                            │
// │  RISK-MANAGER AGENTS:                                                      │
// │    6. RISK    (SL distance from ATR, structure, vol regime)                │
// │    7. REWARD  (TP1/TP2/TP3 from RR, structure, momentum)                   │
// │                                                                            │
// │  HONEST SCOPE: not multi-agent RL — each "agent" is a transparent rule     │
// │  set. The "council feel" comes from how they collectively decide entry +   │
// │  exit, weighted by the trend+S/R alignment requirement for STRONG signals. │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Consensus Council", "AE-COUNCIL", overlay = true,
     max_lines_count = 200, max_labels_count = 200, max_boxes_count = 100)


// ============================================================================
//  ░░ INPUTS (minimal, beginner-friendly) ░░
// ============================================================================
gC = "▓ COUNCIL ▓"
cs_thrInput   = input.int(3, "Consensus Threshold", minval = 1, maxval = 5, group = gC,
     tooltip = "Min |vote sum| out of 5 to trigger a strong signal. 3 = recommended (need at least one extra agreement beyond a simple majority).")
cs_lookbackInp= input.int(50, "Lookback Bars", minval = 10, maxval = 500, group = gC,
     tooltip = "Bars used to baseline agent calculations (vol, OBV, etc.).")

gRR = "▓ RISK / REWARD ▓"
rr_defaultInp = input.float(2.5, "Default RR Ratio (TP2 :SL)", minval = 0.5, maxval = 8.0, step = 0.1, group = gRR)
rr_useTrailInp= input.bool(false, "Use Trailing Stop (on strong momentum)", group = gRR,
     tooltip = "Trail SL toward price while momentum stays strong in the trade's favor.")
rr_maxTPInput = input.int(3, "Max TP Levels (1-3)", minval = 1, maxval = 3, group = gRR)

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_showAgents = input.bool(true, "Show Individual Agents", group = gV)
vi_showDash   = input.bool(true, "Show Dashboard", group = gV)
vi_bgConsensus= input.bool(true, "Background Tint by Consensus", group = gV)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBuy  = na
var color cSell = na
var color cNeut = na
var color cAcc  = na
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, n, a] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #6b7d76, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #6b7d76, #d4af37]
        => [#22d3ee, #f43f5e, #a78bfa, #e879f9]   // Spectral
    [b, s, n, a]
[pb, ps, pn, pa] = setPalette()
cBuy  := pb
cSell := ps
cNeut := pn
cAcc  := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ COMMON SERIES ░░
// ============================================================================
atr = ta.atr(14)


// ============================================================================
//  ░░ AGENT 1 — TREND ░░
//  EMA stack + simple HH/LL + ADX-like trend strength.
// ============================================================================
emaFast = ta.ema(close, 12)
emaMid  = ta.ema(close, 30)
emaSlow = ta.ema(close, 80)
upStack = emaFast > emaMid and emaMid > emaSlow
dnStack = emaFast < emaMid and emaMid < emaSlow
// Simple HH/LL: are we above the rolling high (or below the low) of the lookback?
recentHi = ta.highest(high, math.min(cs_lookbackInp, 100))[1]
recentLo = ta.lowest(low,  math.min(cs_lookbackInp, 100))[1]
brokeHi = close > recentHi
brokeLo = close < recentLo
// ADX-like via DM:
[diPlus, diMinus, adx] = ta.dmi(14, 14)
adxStrong = adx > 20
trendVote = (upStack and (brokeHi or adxStrong) ? 1 : dnStack and (brokeLo or adxStrong) ? -1 : upStack ? 1 : dnStack ? -1 : 0)


// ============================================================================
//  ░░ AGENT 2 — S/R PROXIMITY (Order-Block proxy) ░░
//  Distance to last confirmed swing high / low in ATRs. Vote bullish near a
//  confirmed support, bearish near a confirmed resistance, neutral mid-range.
// ============================================================================
ph = ta.pivothigh(high, 5, 5)
pl = ta.pivotlow(low, 5, 5)
var float lastHi = na
var float lastLo = na
if not na(ph)
    lastHi := ph
if not na(pl)
    lastLo := pl

distHi = na(lastHi) ? na : (lastHi - close) / atr   // positive when price below resistance
distLo = na(lastLo) ? na : (close - lastLo) / atr   // positive when price above support
// "Near" = within 0.5 ATR. Bullish near support, bearish near resistance.
nearSup = not na(distLo) and distLo >= 0 and distLo < 0.8
nearRes = not na(distHi) and distHi >= 0 and distHi < 0.8
srVote = nearSup and not nearRes ? 1 : nearRes and not nearSup ? -1 : 0


// ============================================================================
//  ░░ AGENT 3 — VOLUME ░░
//  Volume z + OBV direction (and candle direction).
// ============================================================================
volMean = ta.sma(volume, 20)
volStd  = ta.stdev(volume, 20)
volZ    = sdiv(volume - volMean, volStd)
obv     = ta.cum(math.sign(ta.change(close)) * volume)
obvSlope = obv - obv[10]
candleDir = close > open ? 1 : close < open ? -1 : 0
strongVol = volZ >= 1.0
volVote = strongVol and obvSlope > 0 and candleDir > 0 ? 1 : strongVol and obvSlope < 0 and candleDir < 0 ? -1 : 0


// ============================================================================
//  ░░ AGENT 4 — MOMENTUM ░░
//  RSI, MACD histogram, Stochastic K all aligned.
// ============================================================================
rsi = ta.rsi(close, 14)
[macdLine, sigLine, hist] = ta.macd(close, 12, 26, 9)
k = ta.stoch(close, high, low, 14)
kSmooth = ta.sma(k, 3)
momBull = rsi > 50 and hist > 0 and kSmooth > 50
momBear = rsi < 50 and hist < 0 and kSmooth < 50
momVote = momBull ? 1 : momBear ? -1 : 0


// ============================================================================
//  ░░ AGENT 5 — VOLATILITY REGIME ░░
//  Vote = 0 always for direction; this agent acts as a confidence MODULATOR
//  — squeeze (low vol) = neutral lean, expansion = supports direction.
//  We implement it as a vote that joins the dominant side when expansion is
//  detected, and zero during squeeze (telling the council to be cautious).
// ============================================================================
bbBasis = ta.sma(close, 20)
bbDev   = ta.stdev(close, 20) * 2
bbU = bbBasis + bbDev
bbL = bbBasis - bbDev
bbW = sdiv(bbU - bbL, bbBasis) * 100
bbWAvg = ta.sma(bbW, 50)
expansion = bbW > bbWAvg * 1.2
squeeze   = bbW < bbWAvg * 0.6
// Lean with the candle direction during expansion; neutral during squeeze.
volaVote = expansion and candleDir > 0 ? 1 : expansion and candleDir < 0 ? -1 : 0


// ============================================================================
//  ░░ COUNCIL SUM ░░
// ============================================================================
voteSum = trendVote + srVote + volVote + momVote + volaVote
buyVotes  = (trendVote == 1 ? 1 : 0) + (srVote == 1 ? 1 : 0) + (volVote == 1 ? 1 : 0) + (momVote == 1 ? 1 : 0) + (volaVote == 1 ? 1 : 0)
sellVotes = (trendVote == -1 ? 1 : 0) + (srVote == -1 ? 1 : 0) + (volVote == -1 ? 1 : 0) + (momVote == -1 ? 1 : 0) + (volaVote == -1 ? 1 : 0)

// STRONG signal: vote sum exceeds threshold AND trend & S/R align.
strongBuy  = voteSum >=  cs_thrInput and trendVote == 1  and (srVote == 1  or srVote == 0)
strongSell = voteSum <= -cs_thrInput and trendVote == -1 and (srVote == -1 or srVote == 0)

// Edge-trigger: fire only on first bar of a new strong signal.
var int lastSig = 0
fireBuy  = strongBuy  and lastSig != 1
fireSell = strongSell and lastSig != -1
if barstate.isconfirmed
    if strongBuy
        lastSig := 1
    if strongSell
        lastSig := -1
    if not strongBuy and not strongSell and lastSig != 0 and math.abs(voteSum) < cs_thrInput - 1
        lastSig := 0


// ============================================================================
//  ░░ AGENT 6 — RISK MANAGER (SL distance) ░░
//  Combine: ATR multiple, recent vol regime, distance to nearest support/res.
//  Returns the SL distance in PRICE units (positive number, away from entry).
// ============================================================================
slDistance(dirSig) =>
    // Base: 1.5 ATR.
    baseSL = atr * 1.5
    // Vol regime adjustment: high vol → wider; squeeze → tighter.
    volMul = expansion ? 1.3 : squeeze ? 0.8 : 1.0
    // Structure: if there's a nearby pivot beyond the entry in the SL direction,
    // anchor the SL there with a small buffer.
    structSL = baseSL
    if dirSig > 0 and not na(lastLo) and lastLo < close
        structSL := math.max(close - lastLo + atr * 0.2, atr * 0.6)
    if dirSig < 0 and not na(lastHi) and lastHi > close
        structSL := math.max(lastHi - close + atr * 0.2, atr * 0.6)
    // Final: blend ATR baseline with structure (whichever is larger but capped).
    raw = math.max(baseSL * volMul, math.min(structSL, baseSL * 2.5))
    clamp(raw, atr * 0.6, atr * 4.0)


// ============================================================================
//  ░░ AGENT 7 — REWARD MANAGER (TP1/TP2/TP3 distance) ░░
//  Uses RR ratio + structure pull (nearest opposite swing) + momentum boost.
//  TP2 anchors to the default RR; TP1 = 0.5×TP2 ish; TP3 = 1.6×TP2 ish.
// ============================================================================
tpDistances(dirSig, sl) =>
    // Base TP2 from RR ratio.
    tp2Base = sl * rr_defaultInp
    // Momentum boost: when momentum vote agrees with signal, extend.
    momBoost = (dirSig > 0 and momVote == 1) or (dirSig < 0 and momVote == -1) ? 1.15 : 1.0
    // Structure pull: if a nearby opposite-side pivot exists, use it for TP1.
    tp1Struct = tp2Base * 0.55
    if dirSig > 0 and not na(lastHi) and lastHi > close
        tp1Struct := math.max(lastHi - close, atr * 0.5)
    if dirSig < 0 and not na(lastLo) and lastLo < close
        tp1Struct := math.max(close - lastLo, atr * 0.5)
    tp1 = math.min(tp1Struct, tp2Base * 0.7)
    tp2 = tp2Base * momBoost
    tp3 = tp2Base * 1.6 * momBoost
    [tp1, tp2, tp3]


// ============================================================================
//  ░░ ACTIVE-SIGNAL TRACKING (parallel arrays) ░░
//  Each live signal: dir, entry bar, entry px, sl, tp1, tp2, tp3, hit flags,
//  and line/label handles for drawing.
// ============================================================================
var int[]   sgDir   = array.new<int>(0)
var int[]   sgBar   = array.new<int>(0)
var float[] sgEntry = array.new<float>(0)
var float[] sgSL    = array.new<float>(0)
var float[] sgTP1   = array.new<float>(0)
var float[] sgTP2   = array.new<float>(0)
var float[] sgTP3   = array.new<float>(0)
var int[]   sgHit1  = array.new<int>(0)
var int[]   sgHit2  = array.new<int>(0)
var int[]   sgHit3  = array.new<int>(0)
var int[]   sgClosed= array.new<int>(0)   // 1 if SL/TP3 hit
var line[]  sgLnSL  = array.new<line>(0)
var line[]  sgLnTP1 = array.new<line>(0)
var line[]  sgLnTP2 = array.new<line>(0)
var line[]  sgLnTP3 = array.new<line>(0)


// ── ARM a new signal ──
armSignal(d) =>
    sl = slDistance(d)
    slPx = d > 0 ? close - sl : close + sl
    [t1, t2, t3] = tpDistances(d, sl)
    tp1Px = d > 0 ? close + t1 : close - t1
    tp2Px = d > 0 ? close + t2 : close - t2
    tp3Px = d > 0 ? close + t3 : close - t3
    array.push(sgDir, d)
    array.push(sgBar, bar_index)
    array.push(sgEntry, close)
    array.push(sgSL, slPx)
    array.push(sgTP1, tp1Px)
    array.push(sgTP2, tp2Px)
    array.push(sgTP3, tp3Px)
    array.push(sgHit1, 0)
    array.push(sgHit2, 0)
    array.push(sgHit3, 0)
    array.push(sgClosed, 0)
    col = d > 0 ? cBuy : cSell
    array.push(sgLnSL,  line.new(bar_index, slPx,  bar_index + 50, slPx,  color = color.new(cSell, 20), style = line.style_dashed, width = 2, extend = extend.right))
    array.push(sgLnTP1, line.new(bar_index, tp1Px, bar_index + 50, tp1Px, color = color.new(cBuy, 50), style = line.style_dotted, width = 1, extend = extend.right))
    array.push(sgLnTP2, line.new(bar_index, tp2Px, bar_index + 50, tp2Px, color = color.new(cBuy, 30), style = line.style_dashed, width = 1, extend = extend.right))
    array.push(sgLnTP3, line.new(bar_index, tp3Px, bar_index + 50, tp3Px, color = color.new(cBuy, 10), style = line.style_solid,  width = 2, extend = extend.right))
    // Entry summary label.
    slPct = math.abs(close - slPx) / close * 100.0
    tp1Pct = math.abs(close - tp1Px) / close * 100.0
    rrTxt = "RR 1:" + str.tostring(rr_defaultInp, "#.0")
    txt = (d > 0 ? "Strong BUY " : "Strong SELL ") + "(" + str.tostring(d > 0 ? buyVotes : sellVotes) + "/5)\nSL: " + str.tostring(slPct, "#.0") + "%  TP1: " + str.tostring(tp1Pct, "#.0") + "%  " + rrTxt
    yOff = d > 0 ? low - atr * 1.5 : high + atr * 1.5
    style = d > 0 ? label.style_label_up : label.style_label_down
    label.new(bar_index, yOff, txt, yloc = yloc.price, color = col, textcolor = #000000, style = style, size = size.normal)

if barstate.isconfirmed and fireBuy
    armSignal(1)
if barstate.isconfirmed and fireSell
    armSignal(-1)


// ── UPDATE existing signals: check hits, optional trailing ──
if barstate.isconfirmed and array.size(sgDir) > 0
    for i = 0 to array.size(sgDir) - 1
        if array.get(sgClosed, i) == 0
            d   = array.get(sgDir, i)
            sl  = array.get(sgSL, i)
            tp1 = array.get(sgTP1, i)
            tp2 = array.get(sgTP2, i)
            tp3 = array.get(sgTP3, i)

            // SL hit?
            slHit = d > 0 ? low <= sl : high >= sl
            if slHit
                array.set(sgClosed, i, 1)
                label.new(bar_index, sl, "✗ SL Hit", yloc = yloc.price, color = cSell, textcolor = #ffffff, style = label.style_label_left, size = size.small)
            else
                // TP hits.
                if array.get(sgHit1, i) == 0 and (d > 0 ? high >= tp1 : low <= tp1)
                    array.set(sgHit1, i, 1)
                    label.new(bar_index, tp1, "✓ TP1 Hit", yloc = yloc.price, color = cBuy, textcolor = #000000, style = label.style_label_left, size = size.small)
                if array.get(sgHit2, i) == 0 and (d > 0 ? high >= tp2 : low <= tp2) and rr_maxTPInput >= 2
                    array.set(sgHit2, i, 1)
                    label.new(bar_index, tp2, "✓ TP2 Hit", yloc = yloc.price, color = cBuy, textcolor = #000000, style = label.style_label_left, size = size.small)
                if array.get(sgHit3, i) == 0 and (d > 0 ? high >= tp3 : low <= tp3) and rr_maxTPInput >= 3
                    array.set(sgHit3, i, 1)
                    array.set(sgClosed, i, 1)
                    label.new(bar_index, tp3, "★ TP3 Hit", yloc = yloc.price, color = cBuy, textcolor = #000000, style = label.style_label_left, size = size.small)
                // Trailing stop on strong momentum.
                if rr_useTrailInp and array.get(sgClosed, i) == 0
                    momAgree = (d > 0 and momVote == 1) or (d < 0 and momVote == -1)
                    if momAgree
                        newSL = d > 0 ? math.max(sl, close - atr * 1.2) : math.min(sl, close + atr * 1.2)
                        if newSL != sl
                            array.set(sgSL, i, newSL)
                            line.set_y1(array.get(sgLnSL, i), newSL)
                            line.set_y2(array.get(sgLnSL, i), newSL)

            // Extend lines to the right while the trade is alive.
            if array.get(sgClosed, i) == 0
                line.set_x2(array.get(sgLnSL, i),  bar_index + 50)
                line.set_x2(array.get(sgLnTP1, i), bar_index + 50)
                line.set_x2(array.get(sgLnTP2, i), bar_index + 50)
                line.set_x2(array.get(sgLnTP3, i), bar_index + 50)


// ============================================================================
//  ░░ VISUALS ░░
// ============================================================================
// Large arrows on STRONG consensus flips.
plotshape(fireBuy,  title = "Strong BUY",  style = shape.triangleup,   location = location.belowbar, color = cBuy,  size = size.large)
plotshape(fireSell, title = "Strong SELL", style = shape.triangledown, location = location.abovebar, color = cSell, size = size.large)

// Individual agent markers (small triangles) — optional clutter for transparency.
plotshape(vi_showAgents and trendVote ==  1, title = "Trend +",   style = shape.triangleup,   location = location.bottom, color = color.new(cBuy,  40), size = size.tiny)
plotshape(vi_showAgents and trendVote == -1, title = "Trend -",   style = shape.triangledown, location = location.bottom, color = color.new(cSell, 40), size = size.tiny)
plotshape(vi_showAgents and srVote    ==  1, title = "SR +",      style = shape.circle,       location = location.bottom, color = color.new(cBuy,  40), size = size.tiny)
plotshape(vi_showAgents and srVote    == -1, title = "SR -",      style = shape.circle,       location = location.bottom, color = color.new(cSell, 40), size = size.tiny)
plotshape(vi_showAgents and volVote   ==  1, title = "Vol +",     style = shape.square,       location = location.bottom, color = color.new(cBuy,  40), size = size.tiny)
plotshape(vi_showAgents and volVote   == -1, title = "Vol -",     style = shape.square,       location = location.bottom, color = color.new(cSell, 40), size = size.tiny)
plotshape(vi_showAgents and momVote   ==  1, title = "Mom +",     style = shape.diamond,      location = location.bottom, color = color.new(cBuy,  40), size = size.tiny)
plotshape(vi_showAgents and momVote   == -1, title = "Mom -",     style = shape.diamond,      location = location.bottom, color = color.new(cSell, 40), size = size.tiny)

// Background tint by consensus strength.
bgColMap = vi_bgConsensus ? (voteSum >= cs_thrInput ? color.new(cBuy, 93) : voteSum <= -cs_thrInput ? color.new(cSell, 93) : na) : na
bgcolor(bgColMap, editable = false)


// ============================================================================
//  ░░ DASHBOARD ░░
// ============================================================================
voteSym(v) =>
    v == 1 ? "▲" : v == -1 ? "▼" : "·"
voteCol(v) =>
    v == 1 ? cBuy : v == -1 ? cSell : cNeut

var table hud = na
if vi_showDash and na(hud)
    hud := table.new(position.top_right, 2, 12, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if vi_showDash and barstate.islast
    sz = size.normal
    confidence = clamp(math.abs(voteSum) / 5.0 * 100.0, 0.0, 100.0)
    verdict = strongBuy ? "★ STRONG BUY" : strongSell ? "★ STRONG SELL" : voteSum > 0 ? "▲ lean buy" : voteSum < 0 ? "▼ lean sell" : "· neutral"
    verdictCol = strongBuy ? cBuy : strongSell ? cSell : voteSum > 0 ? cBuy : voteSum < 0 ? cSell : cNeut

    table.cell(hud, 0, 0, "CONSENSUS COUNCIL", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "7 agents", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "verdict", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, verdict, text_color = verdictCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "consensus score", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(voteSum) + " / 5", text_color = verdictCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "confidence", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, str.tostring(math.round(confidence)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "▔ ENTRY AGENTS ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 4, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 5, "TREND",      text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, voteSym(trendVote), text_color = voteCol(trendVote), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 6, "S/R",        text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, voteSym(srVote), text_color = voteCol(srVote), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 7, "VOLUME",     text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, voteSym(volVote), text_color = voteCol(volVote), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 8, "MOMENTUM",   text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, voteSym(momVote), text_color = voteCol(momVote), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 9, "VOLATILITY", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, voteSym(volaVote) + (squeeze ? "  (squeeze)" : expansion ? "  (expansion)" : ""), text_color = voteCol(volaVote), text_size = sz, text_halign = text.align_right)

    // Active signal info if any.
    activeIdx = -1
    if array.size(sgDir) > 0
        for k = 0 to array.size(sgDir) - 1
            if array.get(sgClosed, k) == 0
                activeIdx := k
    if activeIdx >= 0
        d  = array.get(sgDir, activeIdx)
        en = array.get(sgEntry, activeIdx)
        sl = array.get(sgSL, activeIdx)
        slPct = math.abs(en - sl) / en * 100.0
        table.cell(hud, 0, 10, "active trade", text_color = cAcc, text_size = sz, text_halign = text.align_left)
        table.cell(hud, 1, 10, d > 0 ? "▲ LONG" : "▼ SHORT", text_color = d > 0 ? cBuy : cSell, text_size = sz, text_halign = text.align_right)
        table.cell(hud, 0, 11, "  SL distance", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
        table.cell(hud, 1, 11, str.tostring(slPct, "#.0") + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    else
        table.cell(hud, 0, 10, "active trade", text_color = cAcc, text_size = sz, text_halign = text.align_left)
        table.cell(hud, 1, 10, "—", text_color = cTxtD, text_size = sz, text_halign = text.align_right)
        table.cell(hud, 0, 11, "", text_color = cTxtD, text_size = sz)
        table.cell(hud, 1, 11, "", text_color = cTxtD, text_size = sz)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Strong BUY",  "AE-COUNCIL: Strong BUY consensus")
alertcondition(fireSell, "Strong SELL", "AE-COUNCIL: Strong SELL consensus")
````
