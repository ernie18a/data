# Strong Risk Heatmap Terminal | ProjectSyndicate

- url: https://www.tradingview.com/script/DZDV0AuV-Strong-Risk-Heatmap-Terminal-ProjectSyndicate/
- type: indicator
- pine_id: PUB;c7a13807dd8c4d19ab387a5ab8f2aa15
- version: 1.0

## Description

◾Strong Risk Heatmap Terminal takes the four numbers that decide whether a trading account survives — win rate, payoff (R:R), risk per trade and number of trades — and turns them into three large, side-by-side risk heatmaps plus a full scenario desk, all on one screen in a compact Bloomberg amber terminal.

◾Max Drawdown, Risk of Ruin and Win-Rate confidence are each mapped as a 9×9 grid around your own numbers, your exact position is lit up as a white cell, and every map is backed by closed-form probability math validated against a 40,000-path Monte Carlo. The whole tool runs on one idea: a win rate means nothing on its own — but when you can see the drawdown it produces at every size, the probability it ruins you within N trades, and whether your sample is even large enough to prove it, position sizing stops being a guess and becomes a number.

◾This is a risk-of-ruin and position-sizing terminal, not a signal generator. It tells you how deep your drawdowns will realistically go, how close you are to the ruin cliff, what the largest safe risk per trade is, and whether your measured edge is real or just noise — on any symbol, any timeframe, for any strategy you feed it.

🟢🔴 Summary how to use this, more details below, read entire guide. Two clean reads: size it, then prove it. Use the Risk Budget line to find the largest risk per trade that keeps both ruin probability and expected drawdown inside your limits — if your current risk is above SAFE, cut size. Then check the Win-Rate map — if your cell is red, your sample is too small to call it an edge yet, no matter how good the win rate looks. The Scenario Desk shows what happens to all of it when your edge degrades. Runs on any chart and any timeframe.

⚠️ YOUR STRATEGY vs THE BUILT-IN SAMPLER — By default the heatmaps are calibrated by a built-in Chart Sampler: a simple Donchian breakout with an ATR stop and a fixed R:R target, run on the current chart. It exists to give the terminal a real, honestly-measured win rate out of the box — it is NOT your strategy. To analyse your own system, switch Calibration Source to Manual and type in your own win rate, sample size and average R:R from your journal or backtest. Until the sampler has closed the minimum number of trades (30 by default) the terminal automatically uses your manual inputs.

🧱 The Math Engine — closed-form, Monte-Carlo-checked — Every cell is computed, not estimated by eye. Each trade is modelled as a log-return under fixed-fractional sizing (win: ln(1+f·R), loss: ln(1−f)), which gives a per-trade drift μ and variance σ². From there:
▪️ Expected Max Drawdown — the Magdon-Ismail expected-maximum-drawdown law for a random walk with drift, using simulated Q-functions, with a discrete-trade correction (−0.583σ, Broadie-Glasserman-Kou).
▪️ Risk of Ruin — the exact Brownian first-passage probability of touching your ruin floor within N trades: Φ((−B−μN)/σ√N) + e^(−2μB/σ²)·Φ((−B+μN)/σ√N), with the barrier shifted for discrete trades. Finite horizon, so it works for negative-edge systems too.
▪️ Win-Rate floor — the Wilson score lower bound of your true win rate at 90%, 95% or 99% confidence.
▪️ Losing streaks — the Schilling longest-run law with a Poisson tail for the 1-in-20 (P95) streak.
▪️ Kelly — f* = p − q/R.
Validated offline against a 40,000-path discrete-trade Monte Carlo: risk of ruin within ~1.4 percentage points, P95 losing streak exact, and expected max drawdown deliberately conservative — it never understates drawdown, and overstates it by 0–7 points at the most extreme size and payoff combinations.

📐 Three Heatmaps · One Screen — Each map is a 9×9 grid. Rows are win rates centred on your base win rate (5-point steps by default, highest at the top). Your cell burns white so you find yourself instantly, the matching row and column headers light up amber, and every cell has a hover tooltip with the full breakdown.

◆ ① MAX DRAWDOWN — rows: win rate · columns: risk per trade 0.25% → 5.00% · R:R fixed. Each cell is the expected peak-to-trough drawdown over your N-trade horizon. Amber sits exactly at your Max-DD tolerance; the scale runs red at twice it. Bottom-right is the drawdown cliff: low win rate plus big size.
◆ ② RISK OF RUIN — rows: win rate · columns: payoff R:R 0.50 → 4.00 · risk fixed. Each cell is the probability your equity falls X% below its starting value within N trades. Log-scaled heat, with the amber ridge at your acceptable RoR target. Left of the ridge is survivable payoff; right of it is mathematically doomed.
◆ ③ WIN RATE — rows: observed win rate · columns: trades in sample 20 → 600. Each cell is the worst plausible TRUE win rate given what you measured (Wilson lower bound), coloured against breakeven 1/(1+R:R). Amber = even the worst plausible case beats breakeven, so the edge is statistically proven. Red = the sample is too small, and the edge is not yet distinguishable from noise.

Every map carries a KEY bar along the bottom so you can read the colour scale directly in percent.

XAUUSD 1D snapshot

🏷️ The Scenario Desk — One panel under the heatmaps stress-tests your system across eight rows:
▪️ BASE CASE — your numbers as they are.
▪️ OPTIMISTIC +5 — win rate up 5 points.
▪️ DEGRADED −5 — win rate down 5 points.
▪️ STRESS −10 ×0.85 — win rate down 10 points and payoff cut to 85%.
▪️ REGIME −15 ×0.70 — win rate down 15 points and payoff cut to 70%: the edge-decay scenario.
▪️ HALF-KELLY — what half-Kelly sizing would actually do to drawdown and ruin.
▪️ SAFE BUDGET — your system at the largest size that meets both your limits.
▪️ STRESS @ SAFE — does that safe size still survive a stress regime?
Every row recomputes the full stack: win rate, R:R, risk %, expectancy in R, Kelly %, expected Max DD, the 1-in-20 losing streak and the drawdown it alone causes, risk of ruin, median ending equity, probability of being in profit after N trades, and a grade. All shocks are adjustable in settings.

🔥 The Grade Engine — Every scenario is auto-graded:
▪️ A DEPLOY — ruin below your target and expected drawdown inside your tolerance.
▪️ B SIZE ↓ — close, but size should come down.
▪️ C FRAGILE — ruin under 15%: survivable, not robust.
▪️ D DANGER — ruin under 40%.
▪️ F RUIN / F NO EDGE — ruin is likely, or the expectancy is zero or negative.
A burns amber, F burns red. You read the health of every scenario with your peripheral vision before you read a single number.

💰 The Risk Budget Line — The single most important line on the screen. It solves for the largest risk per trade that keeps risk of ruin under your target, the largest that keeps expected drawdown inside your tolerance, takes the stricter of the two as SAFE, shows your Kelly fraction, and tells you how your current risk compares: "YOU 1.00% = 0.31× SAFE". The line turns red the moment you are sizing above SAFE.

XAUUSD / NQ / BTC snapshot

📒 The Sampler Ledger — honest stats — When the Chart Sampler is active, the bottom line reports its full record: trades closed, wins and losses, win rate, net R, realized max drawdown in R and in % at your risk setting, longest losing streak, and live drawdown. Every closed trade is counted and drawn — wins and losses — with no filtering of fast stop-outs. If a bar touches both the stop and the target, it is booked as a loss. Trades are only evaluated on confirmed bars.

📈 On the Price Chart — Sampler entries (amber triangles), W / L exit markers on every closed trade, the active stop and target as live lines, and an optional drawdown-regime shading that warms the background as the sampler's live drawdown approaches your tolerance.

📋 Bloomberg Amber Terminal — Black terminal background, amber headline strips, bold monospaced figures, gradient heat from calm brown through amber and orange to red, white cursor cell for your position, and tile gutters that match your chart background automatically. All three heatmaps sit across the top of the chart and the scenario desk across the bottom, with price still visible in between. Every table is rebuilt on every update so nothing drifts or clips on a live market.

🔔 Native Alerts —
▪️ Sampler Stop Hit — a sampler trade stopped out (−1R).
▪️ Sampler Target Hit — a sampler trade reached its target.
▪️ Drawdown Tolerance Breached — the sampler's live drawdown crossed your Max-DD tolerance.

🔧 Fully Customizable — Calibration source (Chart Sampler / Manual), manual win rate and sample size, payoff R:R, risk per trade, horizon N, ruin threshold, Max-DD tolerance, acceptable RoR, confidence level (90 / 95 / 99%); sampler breakout length, ATR length and stop multiple, EMA trend filter, minimum trades to calibrate; win-rate row step; every scenario shock; and full display sizing — heatmap cell width and height, heatmap and panel text size, top offset (keeps the symbol legend clear), bottom offset, panel width and row height, and gutter colour.

🎯 Why this is different — Most risk-of-ruin tools give you one number from one formula with no context, or a spreadsheet you have to fill in by hand. This one maps drawdown, ruin and statistical confidence across 81 combinations each, puts you on all three maps at once, stress-tests eight scenarios, solves your safe size automatically, and checks its own math against Monte Carlo. The chart does the filtering — you see instantly whether you are oversized, under-proven, or ready to deploy.

🚀 Apply on any chart and any timeframe. In Manual mode the terminal is independent of the chart, so load it anywhere and enter your own strategy's numbers. In Chart Sampler mode it measures the symbol and timeframe you are on.

🎯 How To Use It — Two Approaches

Everything hinges on the Risk Budget line and your white cell. A great win rate on a red Win-Rate cell, or a risk setting above SAFE, is where the real information sits.

◾ 1 SIZE IT — find the largest safe risk
This is the core read. Your edge is what it is; the only thing you fully control is size.
▪️ Setup: enter your win rate, average R:R and planned horizon (Manual mode), then set your ruin threshold, Max-DD tolerance and acceptable RoR to match your account or prop-firm rules.
▪️ Read: the Risk Budget line gives SAFE. On the Max Drawdown map, your white cell should sit left of the amber column; on the Risk of Ruin map it should sit left of the amber ridge.
▪️ Action: if YOU is above 1.00× SAFE, cut risk per trade until the line turns amber. Check that STRESS @ SAFE still grades A or B — if it doesn't, size lower still.
▪️ Never: size at full Kelly. The HALF-KELLY row shows you why.

⚖️ The cleanest version: BASE CASE grades A DEPLOY, STRESS @ SAFE grades A or B, your Max DD cell is calm brown, and your Risk of Ruin cell reads <0.1. That is a sized, survivable system.

◾ 2 PROVE IT — check the edge is real before you scale
The mirror case, and the one that matters before you increase size.
▪️ Setup: enter your observed win rate and the number of trades it was measured on.
▪️ Read: find your cell on the Win-Rate map. Amber means the worst plausible true win rate still beats breakeven — the edge is statistically proven at your chosen confidence. Red means it isn't yet.
▪️ Action: if your cell is red, keep size small and keep collecting trades. Move along the row to the right to see how many trades you need before the cell turns amber.
▪️ Then: watch the DEGRADED and REGIME rows. If one modest drop in win rate turns the grade to D or F, your edge is thin and your size must reflect that.

⚖️ Watch the Win-Rate map before the other two. A 65% win rate over 20 trades is a coin you have not finished flipping; the same 65% over 250 trades is an edge.
Rule of thumb: ⭐ Risk Budget amber and BASE graded A → you are sized correctly. ⭐ Risk Budget red → cut size to SAFE before anything else. ⭐ Win-Rate cell red → the edge is unproven, trade smaller and collect more data. ⭐ Expectancy ≤ 0 (F NO EDGE) → no size is safe, fix the strategy first.

⚠️ IMPORTANT NOTICE: Strong Risk Heatmap Terminal [Bloomberg] is a risk-modelling and position-sizing tool. Its heatmaps, scenario grades and risk budget are probability estimates from an idealised model: fixed-fractional sizing, independent trades, and a fixed payoff of +R per win and −1R per loss. Real trading adds variable trade outcomes, correlated losing streaks, slippage, fees, gaps and regime changes, so real drawdowns can exceed the model. The built-in Chart Sampler is a calibration model, not a recommended strategy; its statistics describe that model on the current chart only. The Max Drawdown figures are conservative by design, but no figure here is a guarantee. This is decision support, not a trade trigger or financial advice. Always combine it with your own strategy, testing and risk management. Past results do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Risk Heatmap Terminal", overlay = true)

// ───────────────────────────── INPUTS ─────────────────────────────
G_CAL = "═══ CALIBRATION ═══"
calSrc   = input.string("Chart Sampler", "Calibration Source", options = ["Chart Sampler", "Manual"], group = G_CAL, tooltip = "Chart Sampler measures win rate on this chart with a simple breakout model. Falls back to Manual until the minimum trade count is reached.")
manWR    = input.float(50.0, "Manual Win Rate %", minval = 5, maxval = 95, step = 0.5, group = G_CAL)
manN     = input.int(100, "Manual Sample Size (trades)", minval = 5, group = G_CAL, tooltip = "How many trades the manual win rate was measured on. Drives the highlight in the Win-Rate heatmap.")
rrIn     = input.float(2.0, "Payoff R:R (avg win ÷ avg loss)", minval = 0.25, maxval = 10, step = 0.05, group = G_CAL)
riskPct  = input.float(1.0, "Risk per Trade %", minval = 0.05, maxval = 20, step = 0.05, group = G_CAL)
horizon  = input.int(200, "Horizon N (trades)", minval = 10, maxval = 5000, group = G_CAL)
ruinPct  = input.float(30.0, "Ruin Threshold (% loss from start)", minval = 5, maxval = 95, step = 1, group = G_CAL)
ddTarget = input.float(20.0, "Max-DD Tolerance %", minval = 2, maxval = 90, step = 1, group = G_CAL, tooltip = "Amber mid-point of the drawdown heat scale and the DD budget solver.")
rorTgt   = input.float(1.0, "Acceptable Risk of Ruin %", minval = 0.01, maxval = 50, step = 0.1, group = G_CAL, tooltip = "Amber mid-point of the RoR heat scale and the risk-budget solver.")
confIn   = input.string("95%", "Confidence Level", options = ["90%", "95%", "99%"], group = G_CAL)

G_SMP = "═══ CHART SAMPLER ═══"
sLen     = input.int(20, "Donchian Breakout Length", minval = 5, group = G_SMP)
atrLen   = input.int(14, "ATR Length", minval = 2, group = G_SMP)
slMult   = input.float(1.5, "Stop = ATR ×", minval = 0.2, step = 0.1, group = G_SMP)
useTrend = input.bool(true, "Trend Filter (EMA)", inline = "tr", group = G_SMP)
emaLen   = input.int(200, "", minval = 10, inline = "tr", group = G_SMP)
minTr    = input.int(30, "Min Trades to Calibrate", minval = 5, group = G_SMP)
showMk   = input.bool(true, "Show Sampler Entries / Exits", group = G_SMP)
showLvl  = input.bool(true, "Show Active Stop / Target", group = G_SMP)
showDDbg = input.bool(true, "Drawdown Regime Shading", group = G_SMP, tooltip = "Background heat as the sampler's live drawdown approaches the Max-DD tolerance.")

G_AX = "═══ HEATMAP AXES ═══"
wrStep   = input.float(5.0, "Win-Rate Row Step (pp)", minval = 1, maxval = 10, step = 0.5, group = G_AX)

G_SC = "═══ SCENARIO SHOCKS ═══"
shUp     = input.float(5.0, "Optimistic: WR +pp", minval = 0, step = 0.5, group = G_SC)
shDn1    = input.float(5.0, "Degraded: WR −pp", minval = 0, step = 0.5, group = G_SC)
shDn2    = input.float(10.0, "Stress: WR −pp", minval = 0, step = 0.5, inline = "s2", group = G_SC)
shRR2    = input.float(0.85, "R:R ×", minval = 0.1, maxval = 1.5, step = 0.05, inline = "s2", group = G_SC)
shDn3    = input.float(15.0, "Regime Break: WR −pp", minval = 0, step = 0.5, inline = "s3", group = G_SC)
shRR3    = input.float(0.70, "R:R ×", minval = 0.1, maxval = 1.5, step = 0.05, inline = "s3", group = G_SC)

G_UI = "═══ DISPLAY / SIZING ═══"
hmW      = input.float(3.1, "Heatmap Cell Width %", minval = 1.0, maxval = 6.0, step = 0.1, group = G_UI, tooltip = "Each heatmap is 10 columns wide. 3.1% → each map ≈ 31% of the chart width. Lower it (or the text size) on small screens if numbers look clipped.")
hmH      = input.float(3.0, "Heatmap Cell Height %", minval = 1.0, maxval = 8.0, step = 0.1, group = G_UI, tooltip = "Each heatmap is 13 rows tall (plus the top offset). 3.0% → each map ≈ 39% of the chart height.")
hmTxt    = input.int(14, "Heatmap Text Size", minval = 6, maxval = 24, group = G_UI)
topOff   = input.float(12.0, "Top Offset % (clears symbol legend)", minval = 0, maxval = 30, step = 0.5, group = G_UI, tooltip = "Transparent space above the heatmaps so the symbol / indicator legend and chart buttons never cover the titles. Raise it if you run many indicators.")
showPnl  = input.bool(true, "Show Scenario / Logic Panel", group = G_UI)
pnlW     = input.float(96.0, "Panel Width %", minval = 50, maxval = 100, step = 1, group = G_UI)
pnlH     = input.float(2.5, "Panel Row Height %", minval = 1.0, maxval = 6.0, step = 0.1, group = G_UI, tooltip = "The panel is 12 rows tall. 2.5% → ≈ 30% of the chart height.")
pnlTxt   = input.int(11, "Panel Text Size", minval = 6, maxval = 16, group = G_UI)
botOff   = input.float(4.0, "Bottom Offset % (clears TV logo)", minval = 0, maxval = 15, step = 0.5, group = G_UI)
gutAuto  = input.bool(true, "Gutters = Chart Background", inline = "gut", group = G_UI)
gutCol   = input.color(#000000, "else", inline = "gut", group = G_UI)

Z    = confIn == "90%" ? 1.6449 : confIn == "99%" ? 2.5758 : 1.9600
capT = math.max(6, hmTxt - 2)

// ───────────────────────── BLOOMBERG AMBER THEME ─────────────────────────
C_BG     = #0A0A0A
C_FRAME  = #3A2A0E
C_HDR_BG = #2A1C06
C_HEAD   = #FFC24D
C_AMBER  = #FFB000
C_SOFT   = #EBD3A2
C_DIM    = #D9B870
C_ROW_A  = #0E0B05
C_ROW_B  = #17110A
C_WHITE  = #F2F2F2
C_BLACK  = #0A0A0A
C_GUT    = gutAuto ? chart.bg_color : gutCol
C_NONE   = color.new(#000000, 100)
C_RED    = #FF3B30
C_GOLD   = #FFD23F
H0 = #120D05
H1 = #3A2608
H2 = #8C5A00
H3 = #FF8C00
H4 = #E0221A

f_riskBg(float t) =>
    tt = math.max(0.0, math.min(1.0, t))
    tt < 0.25 ? color.from_gradient(tt, 0.0, 0.25, H0, H1) : tt < 0.5 ? color.from_gradient(tt, 0.25, 0.5, H1, H2) : tt < 0.75 ? color.from_gradient(tt, 0.5, 0.75, H2, H3) : color.from_gradient(tt, 0.75, 1.0, H3, H4)

f_riskTx(float t) =>
    t < 0.3 ? C_AMBER : t < 0.56 ? #FFF2D6 : C_BLACK

f_divBg(float m) =>
    m < 0 ? color.from_gradient(m, -0.15, 0.0, #D61F1F, #1E1408) : color.from_gradient(m, 0.0, 0.15, #1E1408, C_AMBER)

f_divTx(float m) =>
    m > 0.08 ? C_BLACK : m < -0.09 ? C_WHITE : #F5D58A

// ───────────────────────── AXIS LADDERS ─────────────────────────
var array<float> RISKS = array.from(0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0)
var array<float> RRS   = array.from(0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.0)
var array<int>   NS    = array.from(20, 30, 50, 75, 100, 150, 250, 400, 600)

// Magdon-Ismail Q-functions on a UNIFORM log grid x_k = 0.001·10^(k/4), k = 0..16
// (simulated, √dt-extrapolated). Uniform grid → loop-free O(1) lookup.
var array<float> QPV = array.from(0.0278, 0.03656, 0.04891, 0.06379, 0.08471, 0.11217, 0.14553, 0.18977, 0.24281, 0.3121, 0.39029, 0.4788, 0.58864, 0.70498, 0.82486, 0.95175, 1.09182)
var array<float> QNV = array.from(0.02843, 0.03837, 0.05102, 0.06906, 0.09222, 0.12649, 0.17124, 0.23847, 0.32632, 0.45809, 0.65791, 0.95692, 1.42098, 2.27148, 3.63091, 6.09865, 10.50319)
QX0   = 0.001
QXN   = 10.0
QDLN  = math.log(10.0) / 4.0
GAMMA = 0.626657
BGK   = 0.5826

// ───────────────────────── RISK MATH LIBRARY ─────────────────────────
f_clampP(float p) => math.max(0.01, math.min(0.99, p))

// per-trade log-return drift and variance under fixed-fractional sizing
f_mu(float p, float w, float f) =>
    p * math.log(1.0 + f * w) + (1.0 - p) * math.log(1.0 - f)

f_s2(float p, float w, float f) =>
    d = math.log(1.0 + f * w) - math.log(1.0 - f)
    p * (1.0 - p) * d * d

// loop-free Q lookup (log-linear interpolation, asymptotes outside the grid)
f_qint(float x, bool pos) =>
    float q = 0.0
    last = array.size(QPV) - 1
    if x <= QX0
        q := GAMMA * math.sqrt(2.0 * x)
    else if x >= QXN
        q := pos ? array.get(QPV, last) + 0.25 * math.log(x / QXN) : array.get(QNV, last) + (x - QXN)
    else
        u  = math.log(x / QX0) / QDLN
        i  = math.max(0, math.min(int(math.floor(u)), last - 1))
        t  = u - i
        v0 = pos ? array.get(QPV, i) : array.get(QNV, i)
        v1 = pos ? array.get(QPV, i + 1) : array.get(QNV, i + 1)
        q := v0 + t * (v1 - v0)
    q

// ① expected maximum drawdown (fraction of peak equity) over n trades
f_emdd(float p, float w, float f, int n) =>
    mu = f_mu(p, w, f)
    s2 = f_s2(p, w, f)
    s  = math.sqrt(s2)
    x  = mu * mu * n / (2.0 * s2)
    float d = 0.0
    if math.abs(mu) < 1e-12
        d := 1.2533 * s * math.sqrt(n)
    else if mu > 0
        d := 2.0 * s2 / mu * f_qint(x, true)
    else
        d := 2.0 * s2 / (-mu) * f_qint(x, false)
    d := math.max(0.0, d - BGK * s)
    1.0 - math.exp(-d)

// log Φ(z) via the Numerical-Recipes erfc (relative error < 1.2e-7, tail-safe)
f_logPhi(float z) =>
    u  = -z / math.sqrt(2.0)
    au = math.abs(u)
    t  = 1.0 / (1.0 + 0.5 * au)
    poly = -au * au - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.18628806 + t * (0.27886807 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277))))))))
    float r = 0.0
    if u >= 0
        r := math.log(0.5) + math.log(t) + poly
    else
        r := math.log(0.5 * (2.0 - t * math.exp(poly)))
    r

f_phi(float z) => math.exp(f_logPhi(z))

// ② finite-horizon risk of ruin: Brownian first passage, BGK-shifted barrier
f_ror(float p, float w, float f, int n, float ruin) =>
    mu = f_mu(p, w, f)
    s2 = f_s2(p, w, f)
    s  = math.sqrt(s2)
    b  = -math.log(1.0 - ruin) + BGK * s
    sq = s * math.sqrt(n)
    t1 = f_phi((-b - mu * n) / sq)
    t2 = math.exp(math.min(-2.0 * mu * b / s2 + f_logPhi((-b + mu * n) / sq), 0.0))
    math.min(1.0, t1 + t2)

// ③ Wilson score interval + probability the true edge is positive
f_wilson(float ph, int n, float z, float sgn) =>
    z2 = z * z
    (ph + z2 / (2.0 * n) + sgn * z * math.sqrt(ph * (1.0 - ph) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)

f_pEdge(float ph, int n, float be) =>
    se = math.sqrt(math.max(ph * (1.0 - ph), 1e-6) / n)
    f_phi((ph - be) / se)

// losing-streak laws (Schilling longest run; Poisson tail, 95th percentile)
f_streakE(float p, int n) =>
    lq = math.log(1.0 / (1.0 - p))
    math.max(1.0, math.log(n * p) / lq + 0.5772 / lq - 0.5)

f_streak95(float p, int n) =>
    lq = math.log(1.0 / (1.0 - p))
    math.max(1, int(math.ceil(math.log(n * p / 0.051293) / lq)) - 1)

f_kelly(float p, float w) => p - (1.0 - p) / w

// metric selector for the budget solver: 0 = RoR, 1 = E[MaxDD]
f_metric(int kind, float p, float w, float f, int n, float ruin) =>
    kind == 0 ? f_ror(p, w, f, n, ruin) : f_emdd(p, w, f, n)

// largest risk/trade with metric ≤ target. Two-pass geometric scan: every trial size is
// derived from the LOOP INDEX (same pattern as the heatmap grids), never from loop-carried
// bounds — Pine can evaluate a loop-carried-argument call only once, freezing a bisection.
f_budget(int kind, float p, float w, int n, float ruin, float tgt) =>
    float lastOk   = 0.0
    float firstBad = 0.0
    // pass 1: 60 sizes from 0.05% to 25% (×1.111 per step)
    for k = 0 to 59
        fk = 0.0005 * math.pow(500.0, k / 59.0)
        vk = f_metric(kind, p, w, fk, n, ruin)
        okk = vk <= tgt
        lastOk   := okk and firstBad == 0.0 ? fk : lastOk
        firstBad := not okk and firstBad == 0.0 ? fk : firstBad
    float res = lastOk
    // pass 2: 40 sizes inside the bracket (resolution ≈ 0.3 % relative)
    if lastOk > 0.0 and firstBad > 0.0
        for j = 0 to 39
            fj = lastOk * math.pow(firstBad / lastOk, j / 39.0)
            vj = f_metric(kind, p, w, fj, n, ruin)
            res := vj <= tgt ? math.max(res, fj) : res
    res

// formatting
f_pct1(float v) => str.tostring(v * 100.0, "0.0")
f_rorTxt(float v) => v < 0.001 ? "<0.1" : v > 0.999 ? "99+" : v < 0.1 ? str.tostring(v * 100.0, "0.0") : str.tostring(v * 100.0, "0")
// ≤ 4 characters so every heatmap value fits its cell at any sane chart width
f_ddTxt(float v) => v >= 0.9995 ? "100" : f_pct1(v)
f_eqTxt(float v) => v > 9.99 ? ">+999" : (v >= 0 ? "+" : "") + str.tostring(v * 100.0, "0.0")

// ───────────────────────── CHART SAMPLER (honest stats) ─────────────────────────
atr  = ta.atr(atrLen)
hiN  = ta.highest(high, sLen)[1]
loN  = ta.lowest(low, sLen)[1]
ema  = ta.ema(close, emaLen)

var int   tDir    = 0
var float tSL     = na
var float tTP     = na
var int   nW      = 0
var int   nL      = 0
var float eqR     = 0.0
var float pkR     = 0.0
var float mddR    = 0.0
var int   curLS   = 0
var int   maxLS   = 0
var float eqP     = 1.0
var float pkP     = 1.0
var float mddP    = 0.0

bool exitWin   = false
bool exitLoss  = false
bool goLong    = false
bool goShort   = false
fSim = riskPct / 100.0

if barstate.isconfirmed
    // 1) manage the open trade — SL checked FIRST (pessimistic same-bar resolution)
    if tDir != 0
        hitSL = tDir == 1 ? low <= tSL : high >= tSL
        hitTP = tDir == 1 ? high >= tTP : low <= tTP
        if hitSL
            exitLoss := true
        else if hitTP
            exitWin := true
        if exitLoss or exitWin
            if exitWin
                nW    += 1
                eqR   += rrIn
                eqP   *= (1.0 + fSim * rrIn)
                curLS := 0
            else
                nL    += 1
                eqR   -= 1.0
                eqP   *= (1.0 - fSim)
                curLS += 1
                maxLS := math.max(maxLS, curLS)
            pkR  := math.max(pkR, eqR)
            mddR := math.max(mddR, pkR - eqR)
            pkP  := math.max(pkP, eqP)
            mddP := math.max(mddP, 1.0 - eqP / pkP)
            tDir := 0
            tSL  := na
            tTP  := na
    // 2) look for a fresh entry only when flat at bar start
    else if not na(hiN) and not na(atr) and atr > 0
        trendUp = not useTrend or close > ema
        trendDn = not useTrend or close < ema
        if close > hiN and trendUp
            goLong := true
            tDir   := 1
            tSL    := close - atr * slMult
            tTP    := close + atr * slMult * rrIn
        else if close < loN and trendDn
            goShort := true
            tDir    := -1
            tSL     := close + atr * slMult
            tTP     := close - atr * slMult * rrIn

nT     = nW + nL
curDDP = 1.0 - eqP / pkP

// chart visuals — every closed trade stays drawn (wins AND losses)
plotshape(showMk and goLong,  "Sampler Long",  shape.triangleup,   location.belowbar, color.new(C_AMBER, 0), size = size.tiny)
plotshape(showMk and goShort, "Sampler Short", shape.triangledown, location.abovebar, color.new(C_AMBER, 0), size = size.tiny)
plotshape(showMk and exitWin,  "Sampler Win",  shape.circle, location.abovebar, color.new(C_GOLD, 0), size = size.tiny, text = "W", textcolor = C_GOLD)
plotshape(showMk and exitLoss, "Sampler Loss", shape.xcross, location.belowbar, color.new(C_RED, 0),  size = size.tiny, text = "L", textcolor = C_RED)
plot(showLvl and tDir != 0 ? tSL : na, "Active Stop",   color.new(C_RED, 20),   2, plot.style_linebr)
plot(showLvl and tDir != 0 ? tTP : na, "Active Target", color.new(C_AMBER, 20), 2, plot.style_linebr)
ddHeat = math.min(1.0, curDDP / (ddTarget / 100.0))
bgcolor(showDDbg and nT > 0 and curDDP > 0.0005 ? color.new(color.from_gradient(ddHeat, 0.0, 1.0, H2, H4), 96 - int(ddHeat * 12)) : na, title = "Drawdown Regime")

// ───────────────────────── BASE PARAMETERS ─────────────────────────
useCal = calSrc == "Chart Sampler" and nT >= minTr
pBase  = f_clampP(useCal ? float(nW) / nT : manWR / 100.0)
nObs   = useCal ? nT : manN
wBase  = rrIn
fBase  = riskPct / 100.0
ruinF  = ruinPct / 100.0
ddTol  = ddTarget / 100.0
rorT   = rorTgt / 100.0
beWR   = 1.0 / (1.0 + wBase)

// win-rate rows centred on the base, top row = highest WR
centreRaw = math.round(pBase * 100.0 / wrStep) * wrStep
centre    = math.max(math.min(centreRaw, 99.0 - 4.0 * wrStep), 1.0 + 4.0 * wrStep)
f_rowWR(int i) => (centre + (4 - i) * wrStep) / 100.0

f_nearRow() =>
    int best = 0
    float bd = 1e9
    for i = 0 to 8
        d = math.abs(f_rowWR(i) - pBase)
        best := d < bd ? i : best
        bd   := math.min(d, bd)
    best

f_nearF(array<float> a, float v) =>
    int best = 0
    float bd = 1e9
    for i = 0 to 8
        d = math.abs(array.get(a, i) - v)
        best := d < bd ? i : best
        bd   := math.min(d, bd)
    best

f_nearI(array<int> a, int v) =>
    int best = 0
    float bd = 1e9
    for i = 0 to 8
        d = math.abs(math.log(array.get(a, i)) - math.log(v))
        best := d < bd ? i : best
        bd   := math.min(d, bd)
    best

// heat position 0..1 for each map (amber mid-point = your tolerance / target)
f_tDD(float v)  => v / (2.0 * ddTol)
f_tRoR(float v) => v <= 1e-6 ? 0.0 : 0.5 + 0.25 * (math.log10(v) - math.log10(rorT))

// ───────────────────────── TABLES ─────────────────────────
// TradingView rolls table state back on every realtime tick, so a "merge once" guard
// leaves un-merged, half-defined cells. Robust pattern used here: on EVERY last-bar
// execution the four tables are deleted and rebuilt from scratch, every cell is fully
// defined (width, height, font, size, alignment), and merges are applied to the fresh
// table after its cells exist. Old tables are wiped via table.all, so no stale or
// duplicate table can survive regardless of how the ids were rolled back.
var table tDD = na
var table tRR = na
var table tWR = na
var table tP  = na

// heatmap cell: fixed width / height so the grid stays square and large
f_hc(table tb, int c, int r, string tx, color fg, color bg, string tip, int sz) =>
    table.cell(tb, c, r, tx, width = hmW, height = hmH, text_color = fg, bgcolor = bg, text_size = sz, text_halign = text.align_center, tooltip = tip, text_font_family = font.family_monospace, text_formatting = text.format_bold)

// panel column widths (fractions of the panel width): 0 name · 1-11 values · 12 grade · 13 spacer · 14-17 logic
f_pw(int c) =>
    c == 0 ? 0.085 : c <= 11 ? 0.040 : c == 12 ? 0.064 : c == 13 ? 0.005 : 0.1015

f_pc(int c, int r, string tx, color fg, color bg, string al) =>
    table.cell(tP, c, r, tx, width = pnlW * f_pw(c), height = pnlH, text_color = fg, bgcolor = bg, text_size = pnlTxt, text_halign = al, text_font_family = font.family_monospace, text_formatting = text.format_bold)

// ── one heatmap · rows: 0 top offset, 1 title, 2 caption, 3 axis, 4-12 grid, 13 scale ──
f_heat(table tb, int kind) =>
    hr = f_nearRow()
    hc = kind == 0 ? f_nearF(RISKS, riskPct) : kind == 1 ? f_nearF(RRS, wBase) : f_nearI(NS, nObs)
    // row 0 — transparent offset: keeps the symbol legend / chart buttons off the titles
    for j = 0 to 9
        table.cell(tb, j, 0, " ", width = hmW, height = topOff, text_color = C_NONE, bgcolor = C_NONE, text_size = 6)
    ttl = kind == 0 ? "① MAX DRAWDOWN · E[MaxDD] %" : kind == 1 ? "② RISK OF RUIN · P(−" + str.tostring(ruinPct, "0") + "%) %" : "③ WIN RATE · " + confIn + " FLOOR %"
    cap = kind == 0 ? "N " + str.tostring(horizon) + " · R:R " + str.tostring(wBase, "0.00") + " · WR ↓  RISK/TRADE % →" : kind == 1 ? "N " + str.tostring(horizon) + " · RISK " + str.tostring(riskPct, "0.00") + "% · WR ↓  PAYOFF R:R →" : "BREAKEVEN " + f_pct1(beWR) + "% · WR ↓  TRADES n →"
    f_hc(tb, 0, 1, ttl, C_BLACK, C_AMBER, "", hmTxt)
    f_hc(tb, 0, 2, cap, C_DIM, C_HDR_BG, "", capT)
    f_hc(tb, 0, 3, "WR %", C_HEAD, C_HDR_BG, "", capT)
    for j = 0 to 8
        hdr = kind == 0 ? str.tostring(array.get(RISKS, j), "0.00") : kind == 1 ? str.tostring(array.get(RRS, j), "0.00") : str.tostring(array.get(NS, j))
        f_hc(tb, 1 + j, 3, hdr, j == hc ? C_BLACK : C_HEAD, j == hc ? C_AMBER : C_HDR_BG, "", capT)
    for i = 0 to 8
        p = f_clampP(f_rowWR(i))
        f_hc(tb, 0, 4 + i, str.tostring(p * 100.0, "0.#"), i == hr ? C_BLACK : C_AMBER, i == hr ? C_AMBER : C_HDR_BG, "", hmTxt)
        for j = 0 to 8
            string tx  = ""
            string tip = ""
            color  bg  = C_BG
            color  fg  = C_AMBER
            if kind == 0
                f   = array.get(RISKS, j) / 100.0
                v   = f_emdd(p, wBase, f, horizon)
                k95 = f_streak95(p, horizon)
                t   = f_tDD(v)
                tx  := f_ddTxt(v)
                bg  := f_riskBg(t)
                fg  := f_riskTx(t)
                tip := "WR " + f_pct1(p) + "% · risk " + str.tostring(f * 100, "0.00") + "% · R:R " + str.tostring(wBase, "0.00") + "\nE[MaxDD] " + f_pct1(v) + "% over " + str.tostring(horizon) + " trades\nP95 losing streak " + str.tostring(k95) + " → " + f_pct1(1.0 - math.pow(1.0 - f, k95)) + "% drop\nedge " + str.tostring(p * wBase - (1 - p), "0.000") + "R/trade · median growth " + f_eqTxt(math.exp(f_mu(p, wBase, f) * horizon) - 1.0) + "%"
            else if kind == 1
                w   = array.get(RRS, j)
                v   = f_ror(p, w, fBase, horizon, ruinF)
                t   = f_tRoR(v)
                tx  := f_rorTxt(v)
                bg  := f_riskBg(t)
                fg  := f_riskTx(t)
                kl  = f_kelly(p, w)
                tip := "WR " + f_pct1(p) + "% · R:R " + str.tostring(w, "0.00") + " · risk " + str.tostring(riskPct, "0.00") + "%\nP(ruin −" + str.tostring(ruinPct, "0") + "% within " + str.tostring(horizon) + ") = " + f_rorTxt(v) + "%\nbreakeven WR " + f_pct1(1.0 / (1.0 + w)) + "% · edge " + str.tostring(p * w - (1 - p), "0.000") + "R\nKelly f* " + (kl > 0 ? f_pct1(kl) + "%" : "none")
            else
                n   = array.get(NS, j)
                lo  = f_wilson(p, n, Z, -1.0)
                hi  = f_wilson(p, n, Z, 1.0)
                m   = lo - beWR
                tx  := f_ddTxt(lo)
                bg  := f_divBg(m)
                fg  := f_divTx(m)
                tip := "observed WR " + f_pct1(p) + "% over " + str.tostring(n) + " trades\n" + confIn + " range " + f_pct1(lo) + "% … " + f_pct1(hi) + "%\nbreakeven " + f_pct1(beWR) + "% · floor margin " + str.tostring(m * 100.0, "+0.0;-0.0") + " pp\nP(true edge > 0) " + f_pct1(f_pEdge(p, n, beWR)) + "%"
            if i == hr and j == hc
                bg  := C_WHITE
                fg  := C_BLACK
                tip := "◉ YOUR POSITION\n" + tip
            f_hc(tb, 1 + j, 4 + i, tx, fg, bg, tip, hmTxt)
    // row 13 — colour-scale bar
    f_hc(tb, 0, 13, "KEY", C_DIM, C_HDR_BG, "", capT)
    for k = 0 to 8
        t = k / 8.0
        string lab = ""
        color  sbg = C_BG
        color  sfg = C_AMBER
        if kind == 0
            v   = t * 2.0 * ddTarget
            lab := (k == 8 ? "≥" : "") + str.tostring(v, "0")
            sbg := f_riskBg(t)
            sfg := f_riskTx(t)
        else if kind == 1
            v   = rorTgt * math.pow(10.0, (t - 0.5) * 4.0)
            lab := (k == 8 ? "≥" : "") + str.tostring(math.min(v, 100.0), v < 0.1 ? "0.00" : v < 10 ? "0.0" : "0")
            sbg := f_riskBg(t)
            sfg := f_riskTx(t)
        else
            m   = (t - 0.5) * 0.30
            lab := k == 4 ? "BE" : str.tostring(m * 100.0, "+0;-0")
            sbg := f_divBg(m)
            sfg := f_divTx(m)
        f_hc(tb, 1 + k, 13, lab, sfg, sbg, kind == 2 ? "Wilson floor minus breakeven, in pp" : kind == 0 ? "E[MaxDD] % — amber = your tolerance" : "RoR % — amber = your target", capT)
    // merges on the freshly built table (title + caption span all 10 width-anchored columns)
    table.merge_cells(tb, 0, 1, 9, 1)
    table.merge_cells(tb, 0, 2, 9, 2)

// ── one scenario row of the panel ──
f_scn(int r, string name, float p0, float w, float f, bool hl) =>
    p   = f_clampP(p0)
    rb  = hl ? #2A1C06 : (r % 2 == 0 ? C_ROW_A : C_ROW_B)
    ex  = p * w - (1.0 - p)
    kel = f_kelly(p, w)
    f_pc(0, r, name, hl ? C_GOLD : C_AMBER, rb, text.align_left)
    f_pc(1, r, f_pct1(p), C_SOFT, rb, text.align_center)
    f_pc(2, r, str.tostring(w, "0.00"), C_SOFT, rb, text.align_center)
    f_pc(4, r, (ex >= 0 ? "+" : "") + str.tostring(ex, "0.000"), ex > 0 ? C_GOLD : C_RED, rb, text.align_center)
    f_pc(5, r, kel > 0 ? f_pct1(kel) : "NONE", kel > 0 ? C_SOFT : C_RED, rb, text.align_center)
    if f <= 0.0
        f_pc(3, r, "0.00", C_RED, rb, text.align_center)
        for c = 6 to 11
            f_pc(c, r, "—", C_DIM, rb, text.align_center)
        f_pc(12, r, "F NO EDGE", C_BLACK, H4, text.align_center)
    else
        dd  = f_emdd(p, w, f, horizon)
        k95 = f_streak95(p, horizon)
        sdd = 1.0 - math.pow(1.0 - f, k95)
        ror = f_ror(p, w, f, horizon, ruinF)
        mu  = f_mu(p, w, f)
        s2  = f_s2(p, w, f)
        med = math.exp(mu * horizon) - 1.0
        ppf = f_phi(mu * horizon / math.sqrt(s2 * horizon))
        f_pc(3, r, str.tostring(f * 100.0, "0.00"), C_SOFT, rb, text.align_center)
        f_pc(6, r, f_pct1(dd), f_riskTx(f_tDD(dd)), f_riskBg(f_tDD(dd)), text.align_center)
        f_pc(7, r, str.tostring(k95), C_SOFT, rb, text.align_center)
        f_pc(8, r, f_pct1(sdd), f_riskTx(f_tDD(sdd)), f_riskBg(f_tDD(sdd)), text.align_center)
        f_pc(9, r, f_rorTxt(ror), f_riskTx(f_tRoR(ror)), f_riskBg(f_tRoR(ror)), text.align_center)
        f_pc(10, r, f_eqTxt(med), med >= 0 ? C_GOLD : C_RED, rb, text.align_center)
        f_pc(11, r, f_pct1(ppf), ppf >= 0.5 ? C_SOFT : C_RED, rb, text.align_center)
        grade = ex <= 0 ? "F NO EDGE" : ror < rorT and dd <= ddTol ? "A DEPLOY" : ror < 5.0 * rorT and dd <= 1.5 * ddTol ? "B SIZE ↓" : ror < 0.15 ? "C FRAGILE" : ror < 0.40 ? "D DANGER" : "F RUIN"
        gbg = str.startswith(grade, "A") ? C_AMBER : str.startswith(grade, "B") ? #C98A00 : str.startswith(grade, "C") ? H3 : str.startswith(grade, "D") ? #E0551E : H4
        f_pc(12, r, grade, C_BLACK, gbg, text.align_center)


// ───────────────────────── RENDER (last bar only, rebuilt every execution) ─────────────────────────
if barstate.islast
    // wipe EVERY table this script owns (table.all), whatever the rollback state of the ids
    oldTabs = array.copy(table.all)
    for tb in oldTabs
        table.delete(tb)
    tDD := table.new(position.top_left,   10, 14, C_NONE, C_GUT, 0, C_GUT, 2)
    tRR := table.new(position.top_center, 10, 14, C_NONE, C_GUT, 0, C_GUT, 2)
    tWR := table.new(position.top_right,  10, 14, C_NONE, C_GUT, 0, C_GUT, 2)
    f_heat(tDD, 0)
    f_heat(tRR, 1)
    f_heat(tWR, 2)

    if showPnl
        tP := table.new(position.bottom_center, 18, 13, C_NONE, C_GUT, 0, C_GUT, 1)
        // row 12 — transparent bottom offset; also the ONLY non-merged row that touches
        // columns 15-17, so it anchors every column width of the panel
        for c = 0 to 17
            table.cell(tP, c, 12, " ", width = pnlW * f_pw(c), height = botOff, text_color = C_NONE, bgcolor = C_NONE, text_size = 6)
        // row 0 — terminal header strip (merged 0..17)
        srcTxt = useCal ? "CHART SAMPLER n=" + str.tostring(nT) + " WR " + f_pct1(pBase) + "%" : calSrc == "Chart Sampler" ? "MANUAL (sampler " + str.tostring(nT) + "/" + str.tostring(minTr) + ") WR " + f_pct1(pBase) + "%" : "MANUAL WR " + f_pct1(pBase) + "% n=" + str.tostring(manN)
        f_pc(0, 0, "◆ STRONG RISK HEATMAP TERMINAL │ " + syminfo.ticker + " · " + timeframe.period + " │ CAL " + srcTxt + " │ R:R " + str.tostring(wBase, "0.00") + " │ RISK " + str.tostring(riskPct, "0.00") + "% │ N " + str.tostring(horizon) + " │ RUIN −" + str.tostring(ruinPct, "0") + "% │ DD TOL " + str.tostring(ddTarget, "0") + "% │ RoR TGT " + str.tostring(rorTgt, "0.0#") + "% │ BE WR " + f_pct1(beWR) + "%", C_BLACK, C_AMBER, text.align_left)
        // row 1 — column headers
        heads = array.from("④ SCENARIO", "WR %", "R:R", "RISK %", "EXP R", "KELLY", "MAX DD", "STRK95", "STK DD", "RoR %", "MED EQ", "P PROF", "GRADE")
        for c = 0 to 12
            f_pc(c, 1, array.get(heads, c), C_HEAD, C_HDR_BG, c == 0 ? text.align_left : text.align_center)
        for r = 1 to 10
            f_pc(13, r, "", C_BG, C_BG, text.align_center)
        f_pc(14, 1, "CORE LOGIC", C_HEAD, C_HDR_BG, text.align_left)
        // rows 2-9 — scenarios
        kB    = f_kelly(pBase, wBase)
        fBud  = f_budget(0, pBase, wBase, horizon, ruinF, rorT)
        fDDb  = f_budget(1, pBase, wBase, horizon, ruinF, ddTol)
        fSafe = math.min(fBud, fDDb)
        f_scn(2, "BASE CASE", pBase, wBase, fBase, true)
        f_scn(3, "OPTIMISTIC +" + str.tostring(shUp, "0.#"), pBase + shUp / 100.0, wBase, fBase, false)
        f_scn(4, "DEGRADED −" + str.tostring(shDn1, "0.#"), pBase - shDn1 / 100.0, wBase, fBase, false)
        f_scn(5, "STRESS −" + str.tostring(shDn2, "0.#") + "×" + str.tostring(shRR2, "0.00"), pBase - shDn2 / 100.0, wBase * shRR2, fBase, false)
        f_scn(6, "REGIME −" + str.tostring(shDn3, "0.#") + "×" + str.tostring(shRR3, "0.00"), pBase - shDn3 / 100.0, wBase * shRR3, fBase, false)
        f_scn(7, "HALF-KELLY", pBase, wBase, math.max(kB / 2.0, 0.0), false)
        f_scn(8, "SAFE BUDGET", pBase, wBase, fSafe, false)
        f_scn(9, "STRESS @ SAFE", pBase - shDn2 / 100.0, wBase * shRR2, fSafe, false)
        // core logic column (rows 2-9, each merged 14..17) — every line ≤ 85 characters
        f_pc(14, 2, "① MAX DD ▸ log-return per trade: win ln(1+f·R), loss ln(1−f) → μ, σ²", C_AMBER, C_BG, text.align_left)
        f_pc(14, 3, "   E[MaxDD] = (2σ²/μ)·Q(μ²N/2σ²) − 0.583σ · Magdon-Ismail, conservative", C_SOFT, C_BG, text.align_left)
        f_pc(14, 4, "② RUIN ▸ P(equity hits start×(1−X%) within N) · Brownian first passage", C_AMBER, C_BG, text.align_left)
        f_pc(14, 5, "   Φ((−B−μN)/σ√N) + e^(−2μB/σ²)·Φ((−B+μN)/σ√N) · B = −ln(1−X)+0.583σ", C_SOFT, C_BG, text.align_left)
        f_pc(14, 6, "③ WIN RATE ▸ " + confIn + " Wilson floor of true WR · row = observed WR, col = n", C_AMBER, C_BG, text.align_left)
        f_pc(14, 7, "   amber = floor beats breakeven 1/(1+R:R) → edge proven · red = noise", C_SOFT, C_BG, text.align_left)
        f_pc(14, 8, "④ SCENARIOS ▸ shock WR + payoff per row, recompute all · Kelly f* = p−q/R", C_AMBER, C_BG, text.align_left)
        f_pc(14, 9, "   SAFE = max risk meeting RoR target AND DD tolerance · STRK95 = 1-in-20", C_SOFT, C_BG, text.align_left)
        // row 10 — risk budget (merged 0..12) + grade key (merged 14..17)
        budTxt = "RISK BUDGET ▸ RoR≤" + str.tostring(rorTgt, "0.0#") + "%: " + str.tostring(fBud * 100.0, "0.00") + "% │ DD≤" + str.tostring(ddTarget, "0") + "%: " + str.tostring(fDDb * 100.0, "0.00") + "% │ SAFE " + str.tostring(fSafe * 100.0, "0.00") + "% │ KELLY " + (kB > 0 ? f_pct1(kB) + "%" : "NONE") + " │ YOU " + str.tostring(riskPct, "0.00") + "% = " + (fSafe > 0 ? str.tostring(fBase / fSafe, "0.00") + "× SAFE" : "NO EDGE")
        f_pc(0, 10, budTxt, C_BLACK, fSafe > 0 and fBase <= fSafe ? C_AMBER : H4, text.align_left)
        f_pc(14, 10, "GRADE ▸ A deploy · B size↓ · C fragile · D danger · F ruin/no edge · ◉ you", C_DIM, C_HDR_BG, text.align_left)
        // row 11 — honest sampler ledger (merged 0..17)
        obsTxt = nT > 0 ? "SAMPLER LEDGER ▸ " + str.tostring(nT) + " closed · " + str.tostring(nW) + "W / " + str.tostring(nL) + "L · all trades counted, SL-first │ WR " + f_pct1(float(nW) / math.max(nT, 1)) + "% │ net " + str.tostring(eqR, "+0.0;-0.0") + "R │ realized MaxDD " + str.tostring(mddR, "0.0") + "R = " + f_pct1(mddP) + "% @ " + str.tostring(riskPct, "0.00") + "% │ max loss streak " + str.tostring(maxLS) + " │ live DD " + f_pct1(curDDP) + "%" : "SAMPLER LEDGER ▸ no closed sampler trades yet on this chart"
        f_pc(0, 11, obsTxt, C_SOFT, C_HDR_BG, text.align_left)
        // merges on the freshly built panel
        table.merge_cells(tP, 0, 0, 17, 0)
        for r = 1 to 10
            table.merge_cells(tP, 14, r, 17, r)
        table.merge_cells(tP, 0, 10, 12, 10)
        table.merge_cells(tP, 0, 11, 17, 11)

// ───────────────────────── ALERTS ─────────────────────────
alertcondition(exitLoss, "Sampler Stop Hit", "RISK HEAT: sampler trade stopped out (−1R)")
alertcondition(exitWin,  "Sampler Target Hit", "RISK HEAT: sampler trade hit target")
alertcondition(curDDP >= ddTarget / 100.0 and curDDP[1] < ddTarget / 100.0, "Drawdown Tolerance Breached", "RISK HEAT: sampler drawdown crossed the Max-DD tolerance")
````
