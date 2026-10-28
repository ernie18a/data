# AetherEdge - Mini Multi-Agent Consensus

- url: https://www.tradingview.com/script/RUjkjw2x/
- type: indicator
- pine_id: PUB;69bce4a176ae430ca5fd253d59201b4b
- version: 1.0

## Description

🖊️ Overview

AE-MMAC is a consensus signal where three independent agents — Trend, Momentum, Volume — each vote BUY/SELL/wait, and a single clear arrow prints only when a majority agrees. Every agent's verdict is shown on a dashboard, letting you trade with the "leave it to the AI" feel without losing transparency. Agents' past performance is online-learned so high-reliability agents speak louder in the consensus.

🔶 Key Features

3 independent agents voting: Trend (EMA), Momentum (RSI), Volume (z-score)
Majority consensus: fires only when 2+ agents agree; otherwise waits
Weighted voting: each agent's recent accuracy adjusts its vote weight
One-arrow design: a single BUY/SELL label on consensus flips — no clutter
Transparent dashboard: each agent's vote, weight, and recent accuracy at a glance
Optional candle coloring
Alerts on consensus signals

🧠 Technical Architecture

This tool is not a true multi-agent reinforcement-learning system but combines three independent classical rules with reliability learning. The trend agent compares short vs long EMAs, the momentum agent thresholds RSI, and the volume agent votes on the candle direction when volume z-score exceeds a threshold. Each new agent vote is buffered; after the outcome horizon, a label is generated from whether an ATR-scaled move occurred in the vote direction, updating the weight via W ← W + α(won − W). Consensus checks both the raw vote count (minimum votes) and the sign of the weighted sum, so low-reliability agents cannot distort the verdict. Signals fire only as an edge trigger on consensus flips, preventing repetition.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Defaults (Trend EMA 10/30, RSI 14 with 55/45 thresholds, Volume z 1.0) are a starting point. Min Votes = 2 (majority) is recommended; 3 (unanimous) tends to be too strict. Keep Use Learned Agent Weights on so the consensus grows smarter with experience. On high-volatility instruments, raise Volume z Threshold to 1.5 to reduce noise.

💡 How to Use in Practice

When an arrow fires, check the dashboard first. A 3-0 vote is the strongest; 2-1 means majority with dissent. Look at per-agent accuracy too — if the trend agent is at 70% and the others at 50%, the market is trend-led. Scalpers can enter immediately, day traders can wait for the first pullback. Pair with structure tools and prioritize moments where the consensus aligns with key levels.

⚠️ Important Notes

This tool is multi-agent-style, not a true multi-agent RL system. The agents are independent classical rules without inter-agent communication; the AI element is limited to learning each agent's reliability. Learning needs accumulated data, so on new instruments or short windows the agent weights stay near the initial 0.5 and the consensus collapses to simple majority. Empty or near-50% accuracy cells in the HUD signal insufficient learning data.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Mini Multi-Agent Consensus
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Mini Multi-Agent Consensus  ·  AE-MMAC                        │
// │                                                                            │
// │  Three independent agents — TREND, MOMENTUM, VOLUME — each cast a vote     │
// │  (+1 buy / 0 wait / -1 sell). When a weighted majority agrees, ONE clear   │
// │  arrow prints. A dashboard makes every agent's verdict visible, so you    │
// │  can see the reasoning behind the consensus.                              │
// │                                                                            │
// │  HONEST SCOPE: not a true multi-agent RL system. The "agents" are three    │
// │  classical rule sets; their votes are combined by a weighted majority      │
// │  where each agent's weight comes from its ONLINE-LEARNED recent accuracy  │
// │  (so well-performing agents speak louder). The "AI" feel comes from the   │
// │  consensus + reliability weighting, not from internal deep learning.      │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Mini Multi-Agent Consensus", "AE-MMAC", overlay = true,
     max_labels_count = 200)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================
gA = "▓ AGENTS ▓"
ag_trendFastInp= input.int(10, "Trend · Fast EMA",  minval = 2, maxval = 100, group = gA)
ag_trendSlowInp= input.int(30, "Trend · Slow EMA",  minval = 5, maxval = 200, group = gA)
ag_momLenInput = input.int(14, "Momentum · RSI Length", minval = 2, maxval = 100, group = gA)
ag_momOB       = input.float(55, "Momentum · Bull Threshold", minval = 50, maxval = 80, step = 1, group = gA)
ag_momOS       = input.float(45, "Momentum · Bear Threshold", minval = 20, maxval = 50, step = 1, group = gA)
ag_volLenInput = input.int(20, "Volume · Baseline Length", minval = 5, maxval = 100, group = gA)
ag_volZThr     = input.float(1.0, "Volume · Surprise Threshold (z)", minval = 0.2, maxval = 4.0, step = 0.1, group = gA)

gC = "▓ CONSENSUS ▓"
cs_minVotesInp = input.int(2, "Min Votes to Trigger", minval = 1, maxval = 3, group = gC,
     tooltip = "2 = strong majority (recommended). 3 = unanimous only. 1 = any agent fires (noisy).")
cs_useWeights  = input.bool(true, "Use Learned Agent Weights", group = gC,
     tooltip = "Weight each vote by the agent's recent accuracy. With this on, the 'min votes' counts weighted votes.")

gL = "▓ LEARNING ▓"
ai_horizonInp  = input.int(8, "Outcome Horizon (bars)", minval = 2, maxval = 40, group = gL)
ai_winInput    = input.float(0.8, "Required Move (ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = gL,
     tooltip = "Move in the voted direction within the horizon to count as a win for that agent.")
ai_rateInput   = input.float(0.15, "Learning Rate", minval = 0.02, maxval = 0.5, step = 0.01, group = gL)

gV = "▓ VISUALS ▓"
vi_themeInput  = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_colorBars   = input.bool(false, "Color Candles by Consensus", group = gV)

gH = "▓ DASHBOARD ▓"
hud_showInput  = input.bool(true, "Show Dashboard", group = gH)
hud_posInput   = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBuy  = na
var color cSell = na
var color cWait = na
var color cAcc  = na
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, w, a] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #6b7d76, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #6b7d76, #d4af37]
        => [#22d3ee, #f43f5e, #a78bfa, #e879f9]   // Spectral
    [b, s, w, a]
[pb, ps, pw, pa] = setPalette()
cBuy  := pb
cSell := ps
cWait := pw
cAcc  := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ AGENT 0 — TREND ░░
//  EMA cross with persistent vote (not flip-on-every-bar). +1 while fast > slow,
//  -1 while fast < slow.
// ============================================================================
emaFast = ta.ema(close, ag_trendFastInp)
emaSlow = ta.ema(close, ag_trendSlowInp)
trendVote = emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0


// ============================================================================
//  ░░ AGENT 1 — MOMENTUM ░░
//  RSI thresholds: bullish above bull threshold, bearish below bear threshold,
//  neutral between.
// ============================================================================
rsiVal = ta.rsi(close, ag_momLenInput)
momVote = rsiVal > ag_momOB ? 1 : rsiVal < ag_momOS ? -1 : 0


// ============================================================================
//  ░░ AGENT 2 — VOLUME ░░
//  Volume surprise direction: when volume z-score exceeds threshold AND the
//  candle has a clear body direction, vote with the candle's direction.
// ============================================================================
volMean = ta.sma(volume, ag_volLenInput)
volStd  = ta.stdev(volume, ag_volLenInput)
volZ    = sdiv(volume - volMean, volStd)
candleDir = close > open ? 1 : close < open ? -1 : 0
volVote = volZ >= ag_volZThr and candleDir != 0 ? candleDir : 0


// ============================================================================
//  ░░ AGENT WEIGHTS (online learning) ░░
//  Each agent's weight in [0,1] is its recent accuracy. Default starts at 0.5.
//  On each bar with a non-zero vote, buffer (agentIdx, dir, price). After horizon,
//  win = realized move in vote direction ≥ required ATR move. Update via EWMA.
// ============================================================================
var float[] agentW = array.new<float>(3, 0.5)
var float[] hit0   = array.new<float>(0)
var float[] hit1   = array.new<float>(0)
var float[] hit2   = array.new<float>(0)

// Pending samples per agent.
var int[]   pA   = array.new<int>(0)    // agent index
var int[]   pDir = array.new<int>(0)    // +1 / -1
var float[] pPx  = array.new<float>(0)
var int[]   pAge = array.new<int>(0)

if barstate.isconfirmed
    if trendVote != 0 and trendVote != trendVote[1]
        array.push(pA, 0)
        array.push(pDir, trendVote)
        array.push(pPx, close)
        array.push(pAge, 0)
    if momVote != 0 and momVote != momVote[1]
        array.push(pA, 1)
        array.push(pDir, momVote)
        array.push(pPx, close)
        array.push(pAge, 0)
    if volVote != 0
        array.push(pA, 2)
        array.push(pDir, volVote)
        array.push(pPx, close)
        array.push(pAge, 0)

atr14 = ta.atr(14)

if barstate.isconfirmed and array.size(pA) > 0
    i = array.size(pA) - 1
    while i >= 0
        age = array.get(pAge, i) + 1
        array.set(pAge, i, age)
        if age >= ai_horizonInp
            ag  = array.get(pA, i)
            dir = array.get(pDir, i)
            px0 = array.get(pPx, i)
            move = dir > 0 ? (close - px0) : (px0 - close)
            won = move >= ai_winInput * atr14 ? 1.0 : 0.0
            oldW = array.get(agentW, ag)
            array.set(agentW, ag, clamp(oldW + ai_rateInput * (won - oldW), 0.05, 1.0))
            if ag == 0
                array.push(hit0, won)
                if array.size(hit0) > 50
                    array.shift(hit0)
            else if ag == 1
                array.push(hit1, won)
                if array.size(hit1) > 50
                    array.shift(hit1)
            else
                array.push(hit2, won)
                if array.size(hit2) > 50
                    array.shift(hit2)
            array.remove(pA, i)
            array.remove(pDir, i)
            array.remove(pPx, i)
            array.remove(pAge, i)
        i -= 1


// ============================================================================
//  ░░ CONSENSUS VOTE ░░
//  Sum (weighted) votes; require absolute sum ≥ minVotes to trigger.
// ============================================================================
w0 = cs_useWeights ? array.get(agentW, 0) : 1.0
w1 = cs_useWeights ? array.get(agentW, 1) : 1.0
w2 = cs_useWeights ? array.get(agentW, 2) : 1.0

voteSum = trendVote * w0 + momVote * w1 + volVote * w2
buyCount  = (trendVote == 1 ? 1 : 0) + (momVote == 1 ? 1 : 0) + (volVote == 1 ? 1 : 0)
sellCount = (trendVote == -1 ? 1 : 0) + (momVote == -1 ? 1 : 0) + (volVote == -1 ? 1 : 0)

// Trigger: minimum number of agents agreeing (raw count), AND weighted sum
// in the same direction (so a weak agent can't flip the verdict).
consensusBuy  = buyCount  >= cs_minVotesInp and voteSum > 0
consensusSell = sellCount >= cs_minVotesInp and voteSum < 0

// Edge-triggered: fire only at the bar the consensus first flips this direction.
var int prevConsensus = 0
curConsensus = consensusBuy ? 1 : consensusSell ? -1 : 0
fireBuy  = curConsensus == 1  and prevConsensus != 1
fireSell = curConsensus == -1 and prevConsensus != -1
if barstate.isconfirmed
    prevConsensus := curConsensus


// ============================================================================
//  ░░ VISUALS ░░
// ============================================================================
// One clear arrow per consensus flip.
plotshape(fireBuy,  title = "Consensus BUY",  style = shape.labelup,   location = location.belowbar,
     color = cBuy,  textcolor = #04140f, text = "BUY",  size = size.normal)
plotshape(fireSell, title = "Consensus SELL", style = shape.labeldown, location = location.abovebar,
     color = cSell, textcolor = #1a0509, text = "SELL", size = size.normal)

// Optional candle coloring by consensus.
bcol = vi_colorBars ? (curConsensus == 1 ? cBuy : curConsensus == -1 ? cSell : na) : na
barcolor(bcol, editable = false)


// ============================================================================
//  ░░ DASHBOARD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

voteSymbol(v) =>
    v == 1 ? "▲ BUY" : v == -1 ? "▼ SELL" : "· wait"
voteCol(v) =>
    v == 1 ? cBuy : v == -1 ? cSell : cWait

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 10, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInput and barstate.islast
    sz = size.normal

    table.cell(hud, 0, 0, "MULTI-AGENT CONSENSUS", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, cs_useWeights ? "weighted" : "raw vote", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "verdict", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, voteSymbol(curConsensus), text_color = voteCol(curConsensus), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "vote sum", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(voteSum, "#.00"), text_color = voteSum > 0 ? cBuy : voteSum < 0 ? cSell : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "▔ AGENTS ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 3, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 4, "TREND", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, voteSymbol(trendVote) + "  " + bar10(w0), text_color = voteCol(trendVote), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "MOMENTUM", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, voteSymbol(momVote) + "  " + bar10(w1), text_color = voteCol(momVote), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "VOLUME", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, voteSymbol(volVote) + "  " + bar10(w2), text_color = voteCol(volVote), text_size = sz, text_halign = text.align_right)

    // Recent accuracy per agent.
    acc0 = array.size(hit0) > 0 ? array.avg(hit0) * 100.0 : 50.0
    acc1 = array.size(hit1) > 0 ? array.avg(hit1) * 100.0 : 50.0
    acc2 = array.size(hit2) > 0 ? array.avg(hit2) * 100.0 : 50.0
    table.cell(hud, 0, 7, "trend acc",    text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(acc0, "#") + "%  (" + str.tostring(array.size(hit0)) + ")", text_color = acc0 > 55 ? cBuy : acc0 < 45 ? cSell : cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 8, "mom acc",      text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(acc1, "#") + "%  (" + str.tostring(array.size(hit1)) + ")", text_color = acc1 > 55 ? cBuy : acc1 < 45 ? cSell : cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 9, "vol acc",      text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(acc2, "#") + "%  (" + str.tostring(array.size(hit2)) + ")", text_color = acc2 > 55 ? cBuy : acc2 < 45 ? cSell : cTxt, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Consensus BUY",  "AE-MMAC: agents agree BUY")
alertcondition(fireSell, "Consensus SELL", "AE-MMAC: agents agree SELL")
````
