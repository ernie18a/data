# AetherEdge - Q-Learning Regime Agent

- url: https://www.tradingview.com/script/j6hnLjfP/
- type: indicator
- pine_id: PUB;a51bf998afa54e53a72f58a4ccb6d1d4
- version: 1.0

## Description

🖊️ Overview

AE-QRA is a reinforcement-learning agent that learns its policy from experience, right on your chart. It discretizes the market into 27 regimes (Trend × Momentum × Volatility) and learns which action to take in each — Short, Flat, or Long — by maximizing reward through tabular Q-learning. No instructions, no labels: the agent relies on reward alone, sharpening its judgment as it shifts from exploration to exploitation.

🔶 Key Features

A real Q-learning engine — the TD(0) update Q(s,a) ← Q(s,a) + α[r + γ·maxQ(s',a') − Q(s,a)] runs every bar, updating a value table over states × actions.
Reward function — reward = position × next-bar return − turnover cost. Profitable decisions are reinforced; needless trading is penalized.
Exploration–exploitation, made real — an ε-greedy policy whose ε decays over time, automatically shifting from random exploration to exploiting the learned policy.
Policy heatmap — the learned policy across 27 regimes, visualized as a 9-cell color grid at the live volatility slice; the cell for the current regime glows.
Regime coloring — bars and background are tinted by the agent's current stance, growing more saturated with conviction.
Action-flip markers — triangle markers mark switches to Long or Short.
Live statistics panel — action, conviction, exploration rate ε, cumulative reward (policy P&L), regime coverage, and the current state.
Fully deterministic, non-repainting design — the exploration RNG is seed-fixed; learning and decisions occur on confirmed bars only, on a one-bar lag.

🧠 Technical Architecture

The state space is built from three discrete features — ATR-unit trend deviation (↓/·/↑), RSI momentum (↓/·/↑), and volatility percentile rank (low/mid/high). Their product gives 27 states, with three actions (Short = −1 / Flat = 0 / Long = +1). The value table Q is persisted as a var matrix (27 × 3).
On each confirmed bar, the agent first observes the reward of its previous action (position × realized return − switching cost), then updates that value via TD(0) using the maximum Q at the next state. It then selects the next action ε-greedily. ε decays as ε = ε_min + (ε_start − ε_min)·exp(−step/decay) — exploratory early on (frequent random actions), exploiting the learned policy as it matures. Conviction is computed as the separation of the three Q-values at the current state and feeds both the background tint and the panel. Because the RNG is a deterministic LCG, the policy is reproducible under identical settings.

🎯 Three design choices stand out. First, embedding a switching cost in the reward suppresses over-trading at the learning level and makes Flat a meaningful choice. Second, confining learning and decisions to confirmed bars on a one-bar lag eliminates future leakage. Third, the deliberately compact 27-state design helps the policy converge even on shorter histories.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): α = 0.10, γ = 0.95, ε-Start = 0.90, ε-Decay = 500, switching cost 3 bps; this yields clean trend adaptation. High-volatility names (SOL, XRP): raise switching cost to 5–8 bps to curb trade frequency, and shorten ε-Decay toward 300 so the agent reaches the exploitation phase faster through the noise.
Per parameter: Learning rate α sets adaptation speed — 0.15–0.25 in fast-rotating regimes, 0.05–0.10 in stable ones. Discount γ sets foresight — higher weights long-run reward (0.95–0.99 for swings, 0.85–0.92 for scalps). ε-Decay sets the length of the exploration phase — larger explores longer and learns more cautiously. Switching cost doubles as a direct knob on trade frequency.

💡 How to Use in Practice

The core read is the agent's stance × conviction. A flip to Long (triangle marker) with high conviction and a rising cumulative reward reads as a tailwind for buying dips. The policy heatmap is a powerful context tool: by reading the colors of the cells adjacent to the current regime (the glowing cell), you can anticipate how the agent will act if the market shifts slightly. When ε is still high, the policy is undecided, so treat signals as informational only.
For multi-timeframe work, confirm the macro bias from the higher-timeframe stance (1D), then execute aligned flips on a lower timeframe (1H–4H). Layered over market structure (S/R, order blocks) or volume, it adds which regime, and with what conviction, the agent chooses to go long — useful confirmation context.

⚠️ Important Notes

Until the warmup period (default 300 bars) and the exploration phase pass, actions are largely exploratory (random). Reloading the indicator, or changing settings/seed, makes the agent relearn across the entire history from scratch — learning state is not persisted. The panel's "Policy P&L" is an in-sample, while-learning metric that does not fully account for switching cost or fill slippage; it is not a backtest or forward result. The 27-state tabular design is intentionally coarse — it learns a regime policy, not fine price structure. Decisions update on confirmed bars, and the agent's stance is not a direct buy/sell instruction.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Q-Learning Regime Agent   ( AE-QRA )
// ----------------------------------------------------------------------------
//  A self-evolving reinforcement-learning agent that lives on your chart.
//  It discretizes the market into regimes (Trend x Momentum x Volatility),
//  chooses an action {Short, Flat, Long} for each regime, and learns a Q-value
//  policy purely from experience via tabular Q-learning (TD(0)):
//      Q(s,a) <- Q(s,a) + alpha * ( r + gamma * max_a' Q(s',a') - Q(s,a) )
//  Reward r = position * next-bar return - turnover cost. Actions are chosen
//  with an epsilon-greedy rule whose epsilon DECAYS over time, so the agent
//  shifts from exploration to exploitation as it learns. Learning and decisions
//  happen on CONFIRMED bars only, on a strict 1-bar lag (no look-ahead), and
//  the exploration RNG is seed-deterministic (reproducible, non-repainting).
// ============================================================================
indicator("AetherEdge - Q-Learning Regime Agent", "AE-QRA", overlay = true, max_labels_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Reinforcement-learning core ---
var string gRL = "Reinforcement Learning Core"
alpha    = input.float(0.10, "Learning Rate (alpha)", minval = 0.01, maxval = 1.00, step = 0.01, group = gRL, tooltip = "TD update step size. Higher = faster but noisier learning.")
gamma    = input.float(0.95, "Discount (gamma)",      minval = 0.00, maxval = 0.999, step = 0.005, group = gRL, tooltip = "How much future reward matters. Higher = more far-sighted policy.")
epsStart = input.float(0.90, "Epsilon Start",         minval = 0.00, maxval = 1.00, step = 0.05, group = gRL, tooltip = "Initial exploration rate (probability of a random action).")
epsMin   = input.float(0.02, "Epsilon Min",           minval = 0.00, maxval = 1.00, step = 0.01, group = gRL, tooltip = "Floor exploration rate after decay.")
epsDecay = input.float(500,  "Epsilon Decay (bars)",  minval = 10, group = gRL, tooltip = "Time constant of exploration decay. Larger = explores for longer.")
tcostBps = input.float(3.0,  "Turnover Cost (bps)",   minval = 0.0, group = gRL, tooltip = "Cost charged in the reward whenever the agent changes action (models friction).")
seed     = input.int(1337,   "Random Seed",           minval = 1, group = gRL, tooltip = "Deterministic exploration RNG. Same seed = reproducible policy.")

//  --- State discretization ---
var string gST = "State Discretization"
emaLen      = input.int(50,  "Trend EMA Length", minval = 5, group = gST)
atrLen      = input.int(14,  "ATR Length",       minval = 2, group = gST)
rsiLen      = input.int(14,  "RSI Length",       minval = 2, group = gST)
trendTh     = input.float(0.5, "Trend Threshold (ATR units)", minval = 0.1, step = 0.1, group = gST, tooltip = "Deadband around the EMA, in ATR, separating Up / Flat / Down.")
rsiUpper    = input.float(60, "RSI Upper",       minval = 50, maxval = 90, group = gST)
rsiLower    = input.float(40, "RSI Lower",       minval = 10, maxval = 50, group = gST)
volLookback = input.int(100, "Volatility Lookback", minval = 20, group = gST)
volHiPct    = input.float(66, "Vol High Pctile", minval = 50, maxval = 95, group = gST)
volLoPct    = input.float(33, "Vol Low Pctile",  minval = 5,  maxval = 50, group = gST)

//  --- Display ---
var string gDS = "Display"
warmup    = input.int(300, "Warmup Bars", minval = 50, group = gDS, tooltip = "Bars the agent learns before signals are displayed.")
longCol   = input.color(#26ffe6, "Long",  group = gDS)
shortCol  = input.color(#ff2e88, "Short", group = gDS)
flatCol   = input.color(#8892b0, "Flat",  group = gDS)
explCol   = input.color(#ffcf5c, "Exploration", group = gDS)
showBars  = input.bool(true, "Color Bars by Regime", group = gDS)
showTint  = input.bool(true, "Background Conviction Tint", group = gDS)
showFlips = input.bool(true, "Action-Flip Markers", group = gDS)
showGrid  = input.bool(true, "Policy Heatmap", group = gDS)
gridPos   = input.string("Bottom Right", "Heatmap Position", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left", "Middle Right"], group = gDS)
showDash  = input.bool(true, "Dashboard", group = gDS)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDS)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
NS  = 27   // states = 3 (trend) x 3 (momentum) x 3 (volatility)
NA  = 3    // actions = Short(0) / Flat(1) / Long(2)  ->  position = action - 1
EPS = 1e-10

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.bottom_right

// ----------------------------------------------------------------------------
//  STATE DISCRETIZATION  (computed every bar)
// ----------------------------------------------------------------------------
ret  = math.log(close / close[1])
emaV = ta.ema(close, emaLen)
atrV = ta.atr(atrLen)
rsiV = ta.rsi(close, rsiLen)
volP = ta.percentrank(atrV, volLookback)

trRaw = (close - emaV) / (atrV + EPS)
trB = trRaw >  trendTh ? 2 : trRaw < -trendTh ? 0 : 1
moB = rsiV  >  rsiUpper ? 2 : rsiV  <  rsiLower ? 0 : 1
voB = volP  >  volHiPct ? 2 : volP  <  volLoPct ? 0 : 1
sCur = voB * 9 + trB * 3 + moB

tcost = tcostBps / 10000.0

ready  = bar_index > math.max(math.max(emaLen, atrLen), math.max(rsiLen, volLookback)) + 2 and not na(rsiV) and not na(atrV) and not na(volP)
active = ready and bar_index > warmup

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (the agent's memory)
// ----------------------------------------------------------------------------
var matrix<float> Q       = matrix.new<float>(NS, NA, 0.0)
var array<bool>   visited = array.new<bool>(NS, false)
var int   aPrev    = 1     // action held over the previous bar
var int   aPrev2   = 1     // action before that (for flip / cost detection)
var int   sPrev    = -1    // previous state
var int   aNow     = 1     // action selected for the coming bar
var float conv     = 0.0   // policy conviction in [0,1]
var float eps      = 1.0   // current exploration rate
var float cumRew   = 0.0   // cumulative reward (the agent's learned return stream)
var int   trainStep = 0
var int   rng      = seed

// ----------------------------------------------------------------------------
//  AGENT STEP  (learn + act, once per CLOSED bar, on a 1-bar lag)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    // 1) Realize reward of the PREVIOUS action and run the TD update
    if sPrev >= 0
        float posPrev = aPrev - 1
        float flip    = aPrev != aPrev2 ? 1.0 : 0.0
        float reward  = posPrev * ret - tcost * flip
        float maxNext = math.max(matrix.get(Q, sCur, 0), math.max(matrix.get(Q, sCur, 1), matrix.get(Q, sCur, 2)))
        float oldQ    = matrix.get(Q, sPrev, aPrev)
        matrix.set(Q, sPrev, aPrev, oldQ + alpha * (reward + gamma * maxNext - oldQ))
        cumRew := cumRew + reward

    // 2) Decay exploration (explore -> exploit over time)
    trainStep := trainStep + 1
    eps := epsMin + (epsStart - epsMin) * math.exp(-trainStep / epsDecay)

    // 3) Epsilon-greedy action selection for the coming bar (deterministic RNG)
    rng := (rng * 1103515245 + 12345) % 2147483647
    float u = rng / 2147483647.0
    int chosen = 1
    if u < eps
        rng := (rng * 1103515245 + 12345) % 2147483647
        float u2 = rng / 2147483647.0
        chosen := math.min(int(u2 * 3.0), 2)
    else
        float q0 = matrix.get(Q, sCur, 0)
        float q1 = matrix.get(Q, sCur, 1)
        float q2 = matrix.get(Q, sCur, 2)
        chosen := q0 >= q1 ? (q0 >= q2 ? 0 : 2) : (q1 >= q2 ? 1 : 2)

    // 4) Policy conviction = how separated the Q-values are at this state
    float qa  = matrix.get(Q, sCur, chosen)
    float qmn = math.min(matrix.get(Q, sCur, 0), math.min(matrix.get(Q, sCur, 1), matrix.get(Q, sCur, 2)))
    float qmx = math.max(matrix.get(Q, sCur, 0), math.max(matrix.get(Q, sCur, 1), matrix.get(Q, sCur, 2)))
    conv := (qmx - qmn) > EPS ? (qa - qmn) / (qmx - qmn) : 0.0

    // 5) Bookkeeping
    if not array.get(visited, sCur)
        array.set(visited, sCur, true)
    aPrev2 := aPrev
    aPrev  := chosen
    sPrev  := sCur
    aNow   := chosen

// ----------------------------------------------------------------------------
//  DISPLAY STATE
// ----------------------------------------------------------------------------
int   actPos = aNow - 1
color actCol = actPos > 0 ? longCol : actPos < 0 ? shortCol : flatCol

flipLong = active and aNow == 2 and aNow[1] != 2
flipShort = active and aNow == 0 and aNow[1] != 0
flipFlat = active and aNow == 1 and aNow[1] != 1

// ----------------------------------------------------------------------------
//  PASSIVE VISUALS
// ----------------------------------------------------------------------------
int tintTransp = 93 - int(conv * 8.0)
bgcolor(showTint and active ? color.new(actCol, tintTransp) : na)
barcolor(showBars and active ? color.new(actCol, 25) : na)

plotshape(showFlips and flipLong,  "Go Long",  shape.triangleup,   location.belowbar, color = longCol,  size = size.tiny)
plotshape(showFlips and flipShort, "Go Short", shape.triangledown, location.abovebar, color = shortCol, size = size.tiny)

// ----------------------------------------------------------------------------
//  POLICY HEATMAP + DASHBOARD
// ----------------------------------------------------------------------------
var table grid = table.new(position = f_pos(gridPos), columns = 4, rows = 5, bgcolor = color.new(#0b0e16, 10), frame_color = color.new(longCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 9, bgcolor = color.new(#0b0e16, 20), frame_color = color.new(longCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast
    // ----- Policy heatmap: greedy action per regime, sliced at the live volatility bucket -----
    if showGrid
        // pass 1: maximum decisiveness across the 9 cells (for intensity scaling)
        float maxRange = EPS
        for tr = 0 to 2
            for mo = 0 to 2
                st = voB * 9 + tr * 3 + mo
                r0 = matrix.get(Q, st, 0)
                r1 = matrix.get(Q, st, 1)
                r2 = matrix.get(Q, st, 2)
                maxRange := math.max(maxRange, math.max(r0, math.max(r1, r2)) - math.min(r0, math.min(r1, r2)))
        // header
        table.cell(grid, 0, 0, "QRA", text_color = #e6f1ff, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        table.cell(grid, 1, 0, "M↓",  text_color = #8892b0, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        table.cell(grid, 2, 0, "M·",  text_color = #8892b0, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        table.cell(grid, 3, 0, "M↑",  text_color = #8892b0, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        // trend rows (Up on top -> Down at bottom)
        for ri = 1 to 3
            tv = 3 - ri
            table.cell(grid, 0, ri, tv == 2 ? "T↑" : tv == 1 ? "T·" : "T↓", text_color = #8892b0, bgcolor = color.new(#11151f, 10), text_size = size.small, text_halign = text.align_center)
            for mo = 0 to 2
                st = voB * 9 + tv * 3 + mo
                q0 = matrix.get(Q, st, 0)
                q1 = matrix.get(Q, st, 1)
                q2 = matrix.get(Q, st, 2)
                ag = q0 >= q1 ? (q0 >= q2 ? 0 : 2) : (q1 >= q2 ? 1 : 2)
                rge = math.max(q0, math.max(q1, q2)) - math.min(q0, math.min(q1, q2))
                inten = rge / maxRange
                glyph = ag == 2 ? "▲" : ag == 0 ? "▼" : "◆"
                aCol  = ag == 2 ? longCol : ag == 0 ? shortCol : flatCol
                isCur = tv == trB and mo == moB
                int al = 88 - int(inten * 53.0)
                bg  = isCur ? color.new(aCol, 12) : color.new(aCol, al)
                txt = isCur ? color.rgb(255, 255, 255) : aCol
                table.cell(grid, mo + 1, ri, (isCur ? "◉" : "") + glyph, text_color = txt, bgcolor = bg, text_size = isCur ? size.normal : size.small, text_halign = text.align_center)
        // footer: live volatility slice + exploration rate
        table.cell(grid, 0, 4, "Vol", text_color = #8892b0, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        table.cell(grid, 1, 4, voB == 2 ? "HI" : voB == 1 ? "MID" : "LO", text_color = #e6f1ff, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        table.cell(grid, 2, 4, "ε", text_color = #8892b0, bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)
        table.cell(grid, 3, 4, str.tostring(eps * 100, "#") + "%", text_color = color.from_gradient(eps, 0.0, 0.5, #6ee7ff, explCol), bgcolor = #0b0e16, text_size = size.small, text_halign = text.align_center)

    // ----- Dashboard -----
    if showDash
        int cov = 0
        for i = 0 to NS - 1
            cov += array.get(visited, i) ? 1 : 0
        float pnl = (math.exp(cumRew) - 1.0) * 100.0
        color hdrBg = #0b0e16
        color rowBg = color.new(#11151f, 10)
        string stat = active ? "● ACTIVE" : "◌ LEARNING"
        color  statCol = active ? longCol : flatCol
        string act = actPos > 0 ? "▲ LONG" : actPos < 0 ? "▼ SHORT" : "◆ FLAT"
        string stl = (trB == 2 ? "T↑" : trB == 1 ? "T·" : "T↓") + " " + (moB == 2 ? "M↑" : moB == 1 ? "M·" : "M↓") + " " + (voB == 2 ? "Vhi" : voB == 1 ? "Vmd" : "Vlo")
        table.cell(dash, 0, 0, "AE · QRA",     text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
        table.cell(dash, 1, 0, stat,           text_color = statCol, bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 1, "Action",       text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 1, act,            text_color = actCol,  bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 2, "Conviction",   text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 2, str.tostring(conv * 100, "#") + "%", text_color = color.from_gradient(conv, 0.0, 1.0, flatCol, longCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Exploration ε", text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 3, str.tostring(eps * 100, "#") + "%", text_color = color.from_gradient(eps, 0.0, 0.5, #6ee7ff, explCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 4, "Policy P&L",   text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 4, (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.#") + "%", text_color = pnl >= 0 ? longCol : shortCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Coverage",     text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 5, str.tostring(cov) + "/" + str.tostring(NS), text_color = color.from_gradient(cov, 0, NS, flatCol, longCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 6, "State",        text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 6, stl,            text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 7, "Learn α / γ",  text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 7, str.tostring(alpha, "#.##") + " / " + str.tostring(gamma, "#.##"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 8, "Cum. Reward",  text_color = #8892b0, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 8, str.tostring(cumRew, "#.####"), text_color = cumRew >= 0 ? longCol : shortCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(flipLong,  "Agent went Long",  "AE-QRA: agent switched to LONG")
alertcondition(flipShort, "Agent went Short", "AE-QRA: agent switched to SHORT")
alertcondition(flipFlat,  "Agent went Flat",  "AE-QRA: agent switched to FLAT")
````
