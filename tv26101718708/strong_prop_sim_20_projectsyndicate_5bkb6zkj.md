# Strong Prop Sim 2.0 | ProjectSyndicate

- url: https://www.tradingview.com/script/5Bkb6zkJ-Strong-Prop-Sim-2-0-ProjectSyndicate/
- type: indicator
- pine_id: PUB;ad804a769629421e9b505b6661de91d8
- version: 1.0

## Description

▪️Strong Prop Sim 2.0 answers the question every prop-firm trader pays to find out the hard way: with the edge you actually have, will you get funded, what will it cost you, and what kills you when you don't. Instead of a single pass/fail formula, it runs thousands of complete evaluations trade by trade and day by day, enforcing your firm's rule set the way the firm enforces it: profit target, daily loss limit, maximum drawdown, drawdown type, minimum days, deadline and consistency. Then it carries the survivors into a simulated funded account and pays them out.

▪️Every run lands in exactly one outcome (passed, killed by the daily limit, killed by max drawdown, voided by the consistency rule, or out of time), so the buckets always sum to 100% and no losing run is hidden. The whole read-out sits directly on your price chart as six dense, institutional-style cards. There are no plots and no separate pane, and your price scale stays untouched. Every chart inside the cards is drawn from fixed-size cells, so it stays clean on a laptop and on an ultrawide monitor alike.

🎲 Monte Carlo Core — the core idea, expressed as a lifecycle: EDGE ▸ TRADES ▸ DAYS ▸ RULES ▸ FUNDED ▸ PAYOUT. You define your edge per trade: win rate, reward:risk, average loss in R, risk basis and size, and trades per day. The engine plays that edge forward one trade at a time. After every single trade it checks the rule stack in the same order a firm's risk system does: has equity touched the maximum-drawdown floor, has the day's loss breached the daily limit, has the target been reached, and have the minimum trading days been served. The drawdown floor is modelled three ways: Static from your starting balance, Trailing from the equity peak, or Trailing → locks once the floor reaches your starting balance. That single rule often changes the answer more than anything else. The tool supports 1-Step and 2-Step challenges and can show Phase 1, Phase 2 or both phases combined. The full simulation runs once when the chart loads, so live ticks only redraw the cards and never recompute. A fixed seed makes every result reproducible; change it to draw a new sample.

📊 KPI Strip — six gauge tiles across the top of the screen give the verdict before you read anything else: Pass Probability, Expected Attempts until funded, Median Days to Pass, Net Expected Value until funded, Edge After Costs per trade, and a Readiness score out of 10. Each tile carries a segmented gauge coloured green, amber or red, so the state of the whole challenge reads in one glance.

🛡️ Challenge Survival — the old equity-curve chart is replaced with something far more informative: a 100% stacked survival map across the challenge calendar. At each day checkpoint it shows the share of all simulated runs that have already passed, been voided by consistency, been killed by the daily limit, blown the maximum drawdown, run out of time, or are still trading. You see when traders die and from what cause, not just the final score. The footer gives the final split: passed, daily-loss failures, max-drawdown failures and timeouts.

🌊 Balance Fan — a percentile heatmap of account balance through the challenge. The outer band is the 5th to 95th percentile, the inner band is the middle 50% of runs, and the median path is highlighted. The target row is tinted green, the drawdown floor row red and the starting balance is marked, each labelled with its real money value. You watch the distribution of balances climb toward the target or bleed toward the floor. The footer reports days to pass for the fastest 10%, the median, the average and the slowest 10% of passing runs.

✅ Readiness Checklist — the pre-flight audit, now scored out of ten, with the value each box was judged on printed beside it so a ✗ tells you exactly what to fix. It checks for a positive edge after costs, a sample of at least 100 trades behind your numbers, risk within half-Kelly, pass odds of at least 50%, a 95th-percentile losing streak that survives inside the maximum drawdown, a daily limit that holds at least three full losses, spread and slippage actually modelled, an execution rate of 85% or better, average max drawdown under 70% of the limit, and a positive expected value until funded. The footer adds full Kelly with a verdict (PRUDENT / AGGRESSIVE / OVER-BET / NO EDGE), the expected trades and days to reach target, the 95th-percentile losing streak, and the average max drawdown.

🔥 Pass Map — a 42-cell heat grid that re-runs the challenge across seven win rates (your rate ±12 points) and six reward:risk ratios (0.6× to 1.6× of yours), colour-graded from red to green by pass probability, with your own edge marked ▶. It shows whether you sit on a plateau, where a small slip still passes, or on a cliff edge, where two points of win rate decide funded or refunded. The footer gives your breakeven win rate, your cell, the best cell on the map, and the minimum win rate that still passes 50% of the time at your reward:risk.

⚖️ Rule Profiles & Phases — your identical edge run against six rule sets side by side: your own rules, a classic 2-step, a strict 2-step, a tight-budget profile, a trail-to-lock 1-step and a trailing 1-step. Each row shows target, daily limit, maximum drawdown, drawdown type, pass probability as a heat cell, and median days to pass. Profiles are labelled by their numbers and drawdown type rather than by brand, because firm terms change and the rules are what the maths responds to. Below that, Phase 1 and Phase 2 are simulated separately with their own pass rates and median days. The footer combines them into funded odds, total days, expected attempts and the expected fee cost to get funded.

🗓️ 30-Day Journey — the profit calendar now follows one simulated trader through the entire path: Phase 1, then Phase 2, then the funded account, and back to Phase 1 with a fresh fee after any breach. Each day is a heat cell sized to that day's P/L. Event days are stamped plainly: ✓ P1, ✓ P2, ✗ DAY, ✗ DD, ✗ TIME, ✗ CONS, $ PAID. A summary line states how many fees that trader paid, the day they got funded and what was paid out. It turns an abstract probability into a story you can read, including the outsized day that quietly sets up a consistency violation. Change the Journey Sample number to follow a different trader.

💰 Challenge Economics with a Funded Stage — a challenge is a purchase, so it gets priced like one, and this time the payout side is simulated instead of guessed. The funded account trades your same edge under the same rules in payout cycles. A payout is taken whenever the cycle's profit clears your minimum, your profit split is applied, and the balance resets. Any breach ends the account. The card returns the expected attempts and total fees paid until funded, the expected number of payouts and total paid to you, the probability of at least one payout, the median account life in cycles, and the net expected value and ROI on fees, with any refund on first payout weighted by its probability. Manual payout estimates remain available if you prefer to enter your own. A 90% pass probability and a negative expected value can coexist, and this is where you find out. The footer adds day extremes across all runs: average up day, average down day, best day and worst day.

⚙️ Execution Reality — the costs most calculators pretend don't exist, and the reason backtests flatter you. Spread and slippage are charged on every trade in R, shrinking every winner and deepening every loser. Execution Rate models the gap between the strategy and the operator: the share of setups you take by the rules, with the remainder taken as off-rule entries at a degraded win rate. Both feed the edge after costs, the Kelly verdict and every simulation on screen.

🎚️ Discipline & Behaviour Controls — rules you impose on yourself, tested rather than assumed. A daily profit lock stops the day after +X R, and a circuit breaker stops it after −Y R. Tilt / revenge sizing multiplies risk after a chosen number of consecutive losses; switch it on and watch the daily-loss band in the survival map swell. The consistency rule caps how much of total profit a single day may carry and voids passes that breach it. Variable R randomises win and loss sizes around your averages for extra realism.

🔔 Alerts — three conditions that matter before you pay a fee: Negative Edge (expectancy at or below 0R after costs), Pass Odds Below 50%, and Negative Challenge EV (expected payouts do not cover the fees you will spend getting funded).

🔧 Fully Customizable — every component is exposed: account size, currency symbol, challenge type (1-Step or 2-Step) and headline phase; both profit targets, daily and maximum drawdown, drawdown type, minimum days, deadline (0 = unlimited), and the consistency rule with its threshold; win rate, reward:risk, average loss in R, risk basis (current equity, starting balance or fixed amount), risk size, trades per day, and the sample size behind your numbers; spread and slippage in R, execution rate, off-rule win rate, and tilt with its trigger and multiplier; the profit lock and circuit breaker; fee, refund, split, payout cycle length, cycles simulated, minimum payout profit, and the manual payout estimates; simulation counts for the main run, pass map, rule profiles and funded stage, plus seed, R randomisation and journey sample; and the display: Midnight Pro or Bloomberg Amber theme, each card on or off, cell width, row height, KPI height, text sizes, top and bottom offsets that clear the symbol legend and chart logo, and gutters that match your chart background.

🎯 Why this is different — a pass-probability calculator gives you one number from a formula and stops. Strong Prop Sim 2.0 runs the entire evaluation thousands of times under the firm's real rule stack, shows day by day when runs die and from what cause, maps how fragile your pass odds are across 42 alternative edges, tests the same edge against six rule sets and both phases, follows a single trader from first fee to first payout, simulates the funded account instead of guessing payouts, prices the venture in expected value, and audits your readiness against ten objective checks. All of it sits on one screen, on your chart, without touching your price scale. It is built to talk you out of a bad challenge, not into one.

🚀 Where to use it — the simulator is symbol- and timeframe-agnostic. It models your trading edge and your firm's rules, not the chart it sits on, so the answer is the same on any instrument and any timeframe. Load the chart you intend to trade for context, feed it the win rate and reward:risk from your own backtest or journal on that market, and set the rule inputs to your specific target firm. Different firms' rules produce materially different answers from the identical edge, and the Rule Profiles card shows you how much.

🎯 How to use it
1. Enter your firm's rules exactly: target, daily limit, maximum drawdown, challenge type and, above all, the correct drawdown type, since Static, Trailing and Trailing → Lock are not interchangeable.
2. Enter your real edge from a real sample: win rate, reward:risk, average loss in R, risk per trade and trades per day. Set the sample size honestly; under 100 trades the checklist flags your numbers, and it is right.
3. Set the execution reality before you believe anything: your true spread and slippage in R, and the execution rate you actually achieve, not the one you intend.
4. Read the KPI strip, then read why runs fail. The Challenge Survival map tells you what to fix: a growing daily-loss band means size or tilt, a max-drawdown band means the edge or the risk, and timeouts mean the target is out of reach in the time allowed.
5. Clear the Readiness Checklist before you trust the pass probability. A high pass rate with an unsurvivable losing streak is a tail risk, not a green light.
6. Check fragility on the Pass Map, and compare the Rule Profiles before you choose a firm.
7. Price it in Journey & Economics. If the net expected value is negative, the challenge is a bad purchase however good the odds look.
8. If TradingView reports a calculation timeout, lower the simulation counts in the engine settings. The pass map is the heaviest module.

⚠️ Important — this is a planning and decision-support tool, not a trading system, and it makes no performance guarantees. Every output is a probabilistic estimate derived entirely from the inputs you provide. The simulation cannot know your real edge, and garbage in is garbage out with three decimal places. Real markets are not independent coin flips: they cluster, trend, gap and change regime, while the model treats each trade as an independent draw from your stated win rate. Treat the results as the mathematical shape of your challenge rather than a forecast of it. Pass probability is the headline and the least useful number on its own; weigh it against the failure breakdown, the losing-streak check, average drawdown and expected value. Funded-stage payouts are simulated under the same assumptions and the same rules, which real firms may apply differently. Rule sets vary between firms and change over time, so verify every rule against your firm's current terms, particularly the drawdown type, payout conditions and any consistency requirement. No simulation, however honest, is a substitute for a tested edge and your own risk management.

## Source Code

````pine
//@version=6

indicator("Strong Prop Sim 2.0", overlay = true)

// ───────────────────────────── INPUTS ─────────────────────────────
gA = "① ACCOUNT & PHASE"
i_balance = input.float(100000, "Account Size", minval = 100, step = 1000, group = gA)
i_curSel  = input.string("$ USD", "Currency", options = ["$ USD", "€ EUR", "£ GBP", "¥ JPY", "₮ USDT", "₿ BTC"], group = gA)
i_phaseLb = input.string("Phase 1", "Headline Phase", options = ["Phase 1", "Phase 2", "Both Phases (combined)"], group = gA, tooltip = "Phase used by the survival chart, balance fan and pass map. The Rule Profiles card always shows Phase 1, Phase 2 and both combined.")

gR = "② FIRM RULES"
i_steps   = input.string("2-Step (Phase 1 + Phase 2)", "Challenge Type", options = ["2-Step (Phase 1 + Phase 2)", "1-Step (Phase 1 only)"], group = gR, tooltip = "2-Step: you must pass both phases to get funded. Economics use the full path to a funded account.")
i_tgt1    = input.float(8.0, "Phase 1 Profit Target %", minval = 0.1, step = 0.5, group = gR)
i_tgt2    = input.float(5.0, "Phase 2 Profit Target %", minval = 0.1, step = 0.5, group = gR)
i_ddDay   = input.float(5.0, "Daily Loss Limit %", minval = 0.1, step = 0.5, group = gR, tooltip = "Max loss from the day's starting balance.")
i_ddMax   = input.float(10.0, "Max Overall Drawdown %", minval = 0.1, step = 0.5, group = gR)
i_ddType  = input.string("Static (from start)", "Drawdown Type", options = ["Static (from start)", "Trailing (from peak)", "Trailing → locks at start"], group = gR)
i_minDay  = input.int(3, "Minimum Trading Days", minval = 0, maxval = 60, group = gR)
i_maxDay  = input.int(30, "Deadline — Max Days (0 = unlimited)", minval = 0, maxval = 120, group = gR, tooltip = "0 treats the challenge as unlimited (simulated up to 120 days).")
i_useCons = input.bool(false, "Consistency Rule", group = gR, tooltip = "A pass is void if one day carries too much of the total profit.")
i_consPct = input.float(40.0, "Best Day ≤ % of Total Profit", minval = 5, maxval = 100, step = 5, group = gR)

gE = "③ TRADER EDGE (per trade)"
i_win     = input.float(45.0, "Win Rate %", minval = 1, maxval = 99, step = 1, group = gE)
i_rr      = input.float(1.8, "Avg Reward : Risk (R)", minval = 0.1, step = 0.1, group = gE)
i_lossR   = input.float(1.0, "Avg Loss (R)", minval = 0.1, step = 0.1, group = gE, tooltip = "Above 1 models slippage / stop overruns.")
i_riskB   = input.string("% of current equity", "Risk Basis", options = ["% of current equity", "% of starting balance", "Fixed amount"], group = gE)
i_riskP   = input.float(1.0, "Risk per Trade %", minval = 0.01, step = 0.1, group = gE)
i_riskF   = input.float(1000, "Fixed Risk Amount", minval = 0, step = 50, group = gE)
i_tpd     = input.int(3, "Trades per Day", minval = 1, maxval = 30, group = gE)
i_sample  = input.int(100, "Backtested Sample Size (trades)", minval = 1, maxval = 5000, step = 10, group = gE, tooltip = "Under ~100 trades the win rate is statistically weak; the checklist flags it.")

gX = "④ EXECUTION REALITY"
i_spreadR = input.float(0.05, "Spread + Slippage (R per trade)", minval = 0.0, maxval = 1.0, step = 0.01, group = gX, tooltip = "Winners shrink and losers grow by this, on every trade.")
i_exec    = input.float(90.0, "Execution Rate %", minval = 1, maxval = 100, step = 1, group = gX, tooltip = "Share of setups taken by the rules. The rest are off-rule trades at the degraded win rate below.")
i_cWin    = input.float(30.0, "Off-Rule (C-grade) Win Rate %", minval = 1, maxval = 99, step = 1, group = gX)
i_useTilt = input.bool(false, "Tilt / Revenge Sizing", group = gX, tooltip = "After a losing streak, size up — the classic account killer.")
i_tiltAft = input.int(3, "Tilt After N Consecutive Losses", minval = 1, maxval = 10, group = gX)
i_tiltMlt = input.float(2.0, "Tilt Risk Multiplier", minval = 1.0, maxval = 10.0, step = 0.5, group = gX)

gD = "⑤ DISCIPLINE (optional)"
i_useLock = input.bool(false, "Stop day after +X R (profit lock)", group = gD)
i_lockR   = input.float(3.0, "Daily Profit Lock (R)", minval = 0.1, step = 0.5, group = gD)
i_useStop = input.bool(false, "Stop day after −Y R (circuit breaker)", group = gD)
i_stopR   = input.float(3.0, "Daily Stop (R)", minval = 0.1, step = 0.5, group = gD)

gC = "⑥ ECONOMICS & FUNDED STAGE"
i_fee     = input.float(500, "Challenge Fee", minval = 0, step = 50, group = gC, tooltip = "Paid every attempt until you pass.")
i_refund  = input.bool(true, "Fee Refunded on First Payout", group = gC)
i_split   = input.float(80.0, "Profit Split %", minval = 0, maxval = 100, step = 5, group = gC)
i_fundSim = input.bool(true, "Simulate the Funded Stage", group = gC, tooltip = "Runs your edge on the funded account under the same rules and pays out each cycle. Untick to use the manual estimates below.")
i_cycDays = input.int(20, "Trading Days per Payout Cycle", minval = 5, maxval = 60, group = gC)
i_maxCyc  = input.int(12, "Payout Cycles Simulated", minval = 1, maxval = 24, group = gC)
i_minPay  = input.float(1.0, "Min Profit % to Request Payout", minval = 0, maxval = 20, step = 0.5, group = gC)
i_payPct  = input.float(4.0, "Manual: Profit % per Payout Cycle", minval = 0.1, maxval = 50, step = 0.5, group = gC)
i_payN    = input.float(3.0, "Manual: Payouts Before Account Loss", minval = 0.1, maxval = 50, step = 0.5, group = gC)

gM = "⑦ MONTE CARLO ENGINE"
i_sims    = input.int(800, "Main Simulations", minval = 100, maxval = 3000, step = 100, group = gM, tooltip = "Lower the Monte Carlo counts if TradingView reports a calculation timeout.")
i_seed    = input.int(7, "Random Seed", minval = 1, group = gM)
i_varR    = input.bool(false, "Variable R (randomize win/loss size)", group = gM)
i_rRand   = input.float(0.35, "R Randomness ±%", minval = 0.0, maxval = 0.95, step = 0.05, group = gM)
i_gridSims = input.int(40, "Pass Map Sims per Cell (42 cells)", minval = 20, maxval = 300, step = 10, group = gM)
i_cmpSims = input.int(150, "Rule Profile Sims per Profile", minval = 50, maxval = 600, step = 50, group = gM)
i_fundSims = input.int(100, "Funded Stage Sims", minval = 50, maxval = 1000, step = 50, group = gM)
i_calRun  = input.int(1, "Journey Sample #", minval = 1, maxval = 50, group = gM, tooltip = "Picks which simulated trader is shown in the 30-day journey calendar.")

gV = "⑧ DISPLAY"
i_theme   = input.string("Midnight Pro", "Theme", options = ["Midnight Pro", "Bloomberg Amber"], group = gV)
i_c1      = input.bool(true, "Card: Challenge Survival (top left)", group = gV)
i_c2      = input.bool(true, "Card: Balance Fan (top center)", group = gV)
i_c3      = input.bool(true, "Card: Readiness Checklist (top right)", group = gV)
i_c4      = input.bool(true, "Card: Pass Map (bottom left)", group = gV)
i_c5      = input.bool(true, "Card: Rule Profiles & Phases (bottom center)", group = gV)
i_c6      = input.bool(true, "Card: Journey & Economics (bottom right)", group = gV)
i_cw      = input.float(1.55, "Cell Width %", minval = 0.8, maxval = 3.0, step = 0.05, group = gV, tooltip = "Every card is 20 cells wide. 1.55% → each card ≈ 31% of the chart width.")
i_h       = input.float(2.4, "Row Height %", minval = 1.2, maxval = 5.0, step = 0.1, group = gV)
i_hv      = input.float(4.0, "KPI Value Row Height %", minval = 2.0, maxval = 8.0, step = 0.1, group = gV)
i_txt     = input.int(10, "Text Size", minval = 6, maxval = 16, group = gV)
i_txtT    = input.int(12, "Card Title Size", minval = 6, maxval = 20, group = gV)
i_txtV    = input.int(18, "KPI Value Size", minval = 8, maxval = 30, group = gV)
i_topOff  = input.float(10.0, "Top Offset % (clears symbol legend)", minval = 0, maxval = 30, step = 0.5, group = gV)
i_botOff  = input.float(3.0, "Bottom Offset % (clears TV logo)", minval = 0, maxval = 15, step = 0.5, group = gV)
i_gutAuto = input.bool(true, "Gutters = Chart Background", inline = "gut", group = gV)
i_gutCol  = input.color(#000000, "else", inline = "gut", group = gV)

// ───────────────────────────── THEME ─────────────────────────────
isMid   = i_theme == "Midnight Pro"
C_CARD  = isMid ? #111A2E : #0E0B05
C_PLOT  = isMid ? #0B1324 : #080705
C_TRACK = isMid ? #1C2842 : #251A08
C_TITLE = isMid ? #F1F5F9 : #FFC24D
C_TXT   = isMid ? #C9D4E5 : #EBD3A2
C_DIM   = isMid ? #7D8EAD : #A8895A
C_GRN   = isMid ? #22C55E : #33D17A
C_RED   = isMid ? #EF4444 : #FF453A
C_YEL   = isMid ? #EAB308 : #FFD23F
C_ORG   = #F97316
C_PUR   = #A855F7
C_GRY   = isMid ? #64748B : #7A6A48
C_FANO  = isMid ? #2E2A6E : #3A2608
C_FANI  = isMid ? #2F55A8 : #8C5A00
C_FANM  = isMid ? #F1F5F9 : #FFD23F
C_BLK   = #0A0A0A
C_GUT   = i_gutAuto ? chart.bg_color : i_gutCol
C_NONE  = color.new(#000000, 100)

// ───────────────────────────── DERIVED ─────────────────────────────
curSym    = i_curSel == "$ USD" ? "$" : i_curSel == "€ EUR" ? "€" : i_curSel == "£ GBP" ? "£" : i_curSel == "¥ JPY" ? "¥" : i_curSel == "₮ USDT" ? "₮" : "₿"
start     = i_balance
tgt1Amt   = start * i_tgt1 / 100.0
tgt2Amt   = start * i_tgt2 / 100.0
dailyAmt  = start * i_ddDay / 100.0
maxDDAmt  = start * i_ddMax / 100.0
ddTypeI   = i_ddType == "Static (from start)" ? 0 : i_ddType == "Trailing (from peak)" ? 1 : 2
riskModeI = i_riskB == "% of current equity" ? 0 : i_riskB == "% of starting balance" ? 1 : 2
winP      = i_win / 100.0
cWinP     = i_cWin / 100.0
execP     = i_exec / 100.0
maxD      = i_maxDay == 0 ? 120 : i_maxDay
phaseI    = i_phaseLb == "Phase 1" ? 0 : i_phaseLb == "Phase 2" ? 1 : 2
consFrac  = i_consPct / 100.0
twoStep   = i_steps == "2-Step (Phase 1 + Phase 2)"
tgtMain   = phaseI == 1 and twoStep ? tgt2Amt : tgt1Amt
mainIsP2  = phaseI == 1 and twoStep
effWR     = execP * winP + (1.0 - execP) * cWinP
effRR     = math.max(i_rr - i_spreadR, 0.0)
effLoss   = i_lossR + i_spreadR
expR      = effWR * effRR - (1.0 - effWR) * effLoss
expRaw    = winP * i_rr - (1.0 - winP) * i_lossR
riskEq    = riskModeI == 2 ? i_riskF / start * 100.0 : i_riskP          // risk as % of start for diagnostics
expPct    = riskEq * expR
pf        = (1.0 - effWR) * effLoss > 0 ? effWR * effRR / ((1.0 - effWR) * effLoss) : na
beWR      = effRR + effLoss > 0 ? effLoss / (effRR + effLoss) : na
bOdds     = effLoss > 0 ? effRR / effLoss : na
kelly     = not na(bOdds) and bOdds > 0 ? (bOdds * effWR - (1.0 - effWR)) / bOdds * 100.0 : na
edgePos   = expR > 0

// ───────────────────────────── FORMATTERS ─────────────────────────────
f_k(float x) =>
    float a = math.abs(nz(x))
    string s = a >= 1e9 ? str.tostring(a / 1e9, "0.00") + "B" : a >= 1e6 ? str.tostring(a / 1e6, "0.00") + "M" : a >= 1e4 ? str.tostring(a / 1e3, "0.0") + "k" : str.tostring(a, "#,##0")
    (nz(x) < 0 ? "-" : "") + curSym + s
f_kc(float x) =>
    float a = math.abs(nz(x))
    string s = a >= 1e6 ? str.tostring(a / 1e6, "0.00") + "M" : a >= 1e5 ? str.tostring(a / 1e3, "0") + "k" : a >= 1e3 ? str.tostring(a / 1e3, "0.0") + "k" : str.tostring(a, "0")
    (nz(x) < 0 ? "-" : "") + curSym + s
f_ks(float x) => (nz(x) >= 0 ? "+" : "") + f_k(x)
f_pc(float x) => na(x) ? "—" : str.tostring(x, "0.0") + "%"
f_n1(float x) => na(x) ? "—" : str.tostring(x, "0.0")
f_clamp(float x) => math.max(0.0, math.min(1.0, nz(x)))

// ───────────────────────────── MONTE CARLO ENGINE ─────────────────────────────
// Outcome codes: 0 pass · 1 daily-loss fail · 2 max-DD fail · 3 timeout · 4 consistency fail
// Everything inside the loops is inlined (no user-function calls with loop-carried arguments).
int RNG_A = 1664525
int RNG_C = 1013904223
float RNG_M = 4294967296.0
int NCOL = 18

f_eng(int seed, int nS, float tgtAmt, float dAmt, float mAmt, int ddT, float wp, float rr, int mxD, bool wantCP) =>
    int st = seed <= 0 ? 1 : seed
    outA  = array.new_int(nS, 3)
    endA  = array.new_int(nS, mxD)
    finA  = array.new_float(nS, start)
    ddA   = array.new_float(nS, 0.0)
    clA   = array.new_float(nS, 0.0)
    cpM   = matrix.new<float>(wantCP ? nS : 1, NCOL, na)
    dayS  = array.new_float(6, 0.0)          // sumUp, nUp, sumDn, nDn, best, worst
    day0  = array.new_float(0)               // day-by-day P/L of the first path (calendar)
    float bestD  = -1e18
    float worstD = 1e18
    for s = 0 to nS - 1
        float eq = start
        float peak = start
        int tday = 0
        bool tgtHit = false
        int outc = -1
        int cl = 0
        int maxCl = 0
        float maxDDpc = 0.0
        float bestDayP = 0.0
        int endD = mxD
        int nc = 0
        for d = 0 to mxD - 1
            if tgtHit and tday >= i_minDay
                outc := 0
                break
            float dayStart = eq
            float dayR = 0.0
            if not tgtHit
                for tr = 0 to i_tpd - 1
                    float risk = riskModeI == 0 ? eq * i_riskP / 100.0 : riskModeI == 1 ? start * i_riskP / 100.0 : i_riskF
                    risk := math.max(risk, 0.0)
                    if i_useTilt and cl >= i_tiltAft
                        risk *= i_tiltMlt
                    st := (RNG_A * st + RNG_C) % 4294967296
                    float uE = st / RNG_M
                    float useWR = uE < execP ? wp : cWinP
                    st := (RNG_A * st + RNG_C) % 4294967296
                    float u1 = st / RNG_M
                    if u1 < useWR
                        float rd = rr
                        if i_varR
                            st := (RNG_A * st + RNG_C) % 4294967296
                            rd := math.max(rr * (1.0 + (st / RNG_M - 0.5) * 2.0 * i_rRand), 0.0)
                        float net = math.max(rd - i_spreadR, -5.0)
                        eq += risk * net
                        dayR += net
                        cl := 0
                    else
                        float ld = i_lossR
                        if i_varR
                            st := (RNG_A * st + RNG_C) % 4294967296
                            ld := math.max(i_lossR * (1.0 + (st / RNG_M - 0.5) * 2.0 * i_rRand), 0.0)
                        float net = ld + i_spreadR
                        eq -= risk * net
                        dayR -= net
                        cl += 1
                        maxCl := math.max(maxCl, cl)
                    peak := math.max(peak, eq)
                    maxDDpc := math.max(maxDDpc, peak > 0 ? (peak - eq) / peak * 100.0 : 0.0)
                    float floorMax = ddT == 0 ? start - mAmt : ddT == 1 ? peak - mAmt : math.min(peak - mAmt, start)
                    if eq <= floorMax
                        outc := 2
                        break
                    if eq - dayStart <= -dAmt
                        outc := 1
                        break
                    if not tgtHit and eq >= start + tgtAmt
                        tgtHit := true
                        break
                    if i_useLock and dayR >= i_lockR
                        break
                    if i_useStop and dayR <= -i_stopR
                        break
            float dayPL = eq - dayStart
            bestDayP := math.max(bestDayP, dayPL)
            if dayPL > 0
                array.set(dayS, 0, array.get(dayS, 0) + dayPL)
                array.set(dayS, 1, array.get(dayS, 1) + 1.0)
            else if dayPL < 0
                array.set(dayS, 2, array.get(dayS, 2) + dayPL)
                array.set(dayS, 3, array.get(dayS, 3) + 1.0)
            bestD  := math.max(bestD, dayPL)
            worstD := math.min(worstD, dayPL)
            if s == 0
                array.push(day0, dayPL)
            if wantCP
                while nc < NCOL and math.round((nc + 1) * mxD / (NCOL * 1.0)) <= d + 1
                    matrix.set(cpM, s, nc, eq)
                    nc += 1
            if outc == 1 or outc == 2
                endD := d + 1
                break
            tday += 1
            if tgtHit and tday >= i_minDay
                outc := 0
                break
        if outc == -1
            outc := 3
            endD := mxD
        if outc == 0
            endD := math.max(tday, 1)
            float totProf = eq - start
            if i_useCons and totProf > 0 and bestDayP > consFrac * totProf
                outc := 4
        if wantCP
            while nc < NCOL
                matrix.set(cpM, s, nc, eq)
                nc += 1
        array.set(outA, s, outc)
        array.set(endA, s, endD)
        array.set(finA, s, eq)
        array.set(ddA, s, maxDDpc)
        array.set(clA, s, maxCl)
    array.set(dayS, 4, bestD)
    array.set(dayS, 5, worstD)
    [outA, endA, finA, ddA, clA, cpM, dayS, day0]

// share of paths with outcome code `code` (optionally ending on or before day `byDay`)
f_share(array<int> outA, array<int> endA, int code, int byDay) =>
    int n = array.size(outA)
    float c = 0.0
    for s = 0 to n - 1
        c += array.get(outA, s) == code and array.get(endA, s) <= byDay ? 1.0 : 0.0
    c / n

// FUNDED STAGE: same edge and rules on the funded account, paid out every cycle
f_fund(int seed, int nS) =>
    int st = seed <= 0 ? 1 : seed
    float sumPay = 0.0
    float sumCnt = 0.0
    float nAny   = 0.0
    float sumLife = 0.0
    float nAll   = 0.0
    lifeA = array.new_float(nS, 0.0)
    for s = 0 to nS - 1
        float eq = start
        float peak = start
        int cl = 0
        bool dead = false
        float pay = 0.0
        int cnt = 0
        int life = 0
        for c = 0 to i_maxCyc - 1
            if dead
                break
            for d = 0 to i_cycDays - 1
                if dead
                    break
                float dayStart = eq
                float dayR = 0.0
                for tr = 0 to i_tpd - 1
                    float risk = riskModeI == 0 ? eq * i_riskP / 100.0 : riskModeI == 1 ? start * i_riskP / 100.0 : i_riskF
                    risk := math.max(risk, 0.0)
                    if i_useTilt and cl >= i_tiltAft
                        risk *= i_tiltMlt
                    st := (RNG_A * st + RNG_C) % 4294967296
                    float uE = st / RNG_M
                    float useWR = uE < execP ? winP : cWinP
                    st := (RNG_A * st + RNG_C) % 4294967296
                    float u1 = st / RNG_M
                    if u1 < useWR
                        float rd = i_rr
                        if i_varR
                            st := (RNG_A * st + RNG_C) % 4294967296
                            rd := math.max(i_rr * (1.0 + (st / RNG_M - 0.5) * 2.0 * i_rRand), 0.0)
                        float net = math.max(rd - i_spreadR, -5.0)
                        eq += risk * net
                        dayR += net
                        cl := 0
                    else
                        float ld = i_lossR
                        if i_varR
                            st := (RNG_A * st + RNG_C) % 4294967296
                            ld := math.max(i_lossR * (1.0 + (st / RNG_M - 0.5) * 2.0 * i_rRand), 0.0)
                        float net = ld + i_spreadR
                        eq -= risk * net
                        dayR -= net
                        cl += 1
                    peak := math.max(peak, eq)
                    float floorMax = ddTypeI == 0 ? start - maxDDAmt : ddTypeI == 1 ? peak - maxDDAmt : math.min(peak - maxDDAmt, start)
                    if eq <= floorMax or eq - dayStart <= -dailyAmt
                        dead := true
                        break
                    if i_useLock and dayR >= i_lockR
                        break
                    if i_useStop and dayR <= -i_stopR
                        break
            if not dead
                life += 1
                float prof = eq - start
                if prof >= start * i_minPay / 100.0
                    pay += prof * i_split / 100.0
                    cnt += 1
                    eq := start
                    peak := math.max(start, math.min(peak, start))
        sumPay += pay
        sumCnt += cnt
        nAny   += cnt > 0 ? 1.0 : 0.0
        sumLife += life
        nAll   += not dead ? 1.0 : 0.0
        array.set(lifeA, s, life)
    [sumPay / nS, sumCnt / nS, nAny / nS, sumLife / nS, nAll / nS, array.percentile_linear_interpolation(lifeA, 50)]

// SAMPLE JOURNEY: one trader, day by day for `nDays` days — Phase 1 → Phase 2 → funded (payouts),
// back to Phase 1 (new fee) after any breach. Events: -1 none · 0 passed P1 · 1 passed P2 · 2 daily-loss
// breach · 3 max-DD breach · 4 timed out · 5 consistency fail · 6 payout
f_journey(int seed, int nDays) =>
    int st = seed <= 0 ? 1 : seed
    plA = array.new_float(0)
    evA = array.new_int(0)
    int stage = 0
    float eq = start
    float peak = start
    int tday = 0
    bool tgtHit = false
    float bestDayP = 0.0
    int cl = 0
    float payTot = 0.0
    int fees = 1
    int fundDay = -1
    for d = 0 to nDays - 1
        float dayStart = eq
        float dayR = 0.0
        int ev = -1
        float tgtAmt = stage == 0 ? tgt1Amt : tgt2Amt
        if not tgtHit
            for tr = 0 to i_tpd - 1
                float risk = riskModeI == 0 ? eq * i_riskP / 100.0 : riskModeI == 1 ? start * i_riskP / 100.0 : i_riskF
                risk := math.max(risk, 0.0)
                if i_useTilt and cl >= i_tiltAft
                    risk *= i_tiltMlt
                st := (RNG_A * st + RNG_C) % 4294967296
                float uE = st / RNG_M
                float useWR = uE < execP ? winP : cWinP
                st := (RNG_A * st + RNG_C) % 4294967296
                float u1 = st / RNG_M
                if u1 < useWR
                    float rd = i_rr
                    if i_varR
                        st := (RNG_A * st + RNG_C) % 4294967296
                        rd := math.max(i_rr * (1.0 + (st / RNG_M - 0.5) * 2.0 * i_rRand), 0.0)
                    float net = math.max(rd - i_spreadR, -5.0)
                    eq += risk * net
                    dayR += net
                    cl := 0
                else
                    float ld = i_lossR
                    if i_varR
                        st := (RNG_A * st + RNG_C) % 4294967296
                        ld := math.max(i_lossR * (1.0 + (st / RNG_M - 0.5) * 2.0 * i_rRand), 0.0)
                    float net = ld + i_spreadR
                    eq -= risk * net
                    dayR -= net
                    cl += 1
                peak := math.max(peak, eq)
                float floorMax = ddTypeI == 0 ? start - maxDDAmt : ddTypeI == 1 ? peak - maxDDAmt : math.min(peak - maxDDAmt, start)
                if eq <= floorMax
                    ev := 3
                    break
                if eq - dayStart <= -dailyAmt
                    ev := 2
                    break
                if stage < 2 and eq >= start + tgtAmt
                    tgtHit := true
                    break
                if i_useLock and dayR >= i_lockR
                    break
                if i_useStop and dayR <= -i_stopR
                    break
        float dayPL = eq - dayStart
        bestDayP := math.max(bestDayP, dayPL)
        tday += 1
        if ev == -1 and stage == 2 and tday % i_cycDays == 0 and eq - start >= start * i_minPay / 100.0
            ev := 6
            payTot += (eq - start) * i_split / 100.0
        if ev == -1 and stage < 2
            if tgtHit and tday >= i_minDay
                ev := i_useCons and eq - start > 0 and bestDayP > consFrac * (eq - start) ? 5 : stage
            else if tday >= maxD
                ev := 4
        array.push(plA, dayPL)
        array.push(evA, ev)
        if ev == 6
            eq := start
            peak := start
        else if ev == 0 or ev == 1
            stage := ev == 0 and twoStep ? 1 : 2
            if stage == 2 and fundDay < 0
                fundDay := d + 2
            eq := start
            peak := start
            tday := 0
            tgtHit := false
            bestDayP := 0.0
        else if ev >= 2
            stage := 0
            fees += d < nDays - 1 ? 1 : 0
            eq := start
            peak := start
            tday := 0
            tgtHit := false
            bestDayP := 0.0
    [plA, evA, payTot, fees, fundDay]

// ───────────────────────────── RUN ONCE (inputs are constant) ─────────────────────────────
// Bands for the survival chart: rows = 18 day checkpoints; cols = pass, cons, timeout, running, daily, maxDD
var matrix<float> gSurv = matrix.new<float>(18, 6, 0.0)
var array<float>  gF05  = array.new_float(0)
var array<float>  gF25  = array.new_float(0)
var array<float>  gF50  = array.new_float(0)
var array<float>  gF75  = array.new_float(0)
var array<float>  gF95  = array.new_float(0)
var array<float>  gShare = array.new_float(5, 0.0)        // outcome shares of the headline run
var array<float>  gGrid  = array.new_float(42, na)        // pass map (7 WR rows × 6 R:R cols)
var array<float>  gPrP   = array.new_float(6, na)         // rule profiles: pass
var array<float>  gPrD   = array.new_float(6, na)         // rule profiles: median days of passers
var array<float>  gDayS  = array.new_float(6, 0.0)
var array<float>  gCal   = array.new_float(0)
var array<int>    gCalEv = array.new_int(0)
var float gJPay = 0.0
var int   gJFees = 1
var int   gJFund = -1
var float gPassA = na
var float gP1 = na
var float gP2 = na
var float gD1 = na
var float gD2 = na
var float gDmed = na
var float gDavg = na
var float gD10 = na
var float gD90 = na
var float gClMed = na
var float gCl95 = na
var float gClMax = na
var float gDDavg = na
var float gDD95  = na
var float fPay = na
var float fCnt = na
var float fAny = na
var float fLife = na
var float fAll = na
var float fMedLife = na

if barstate.isfirst
    // ── headline run (phase chosen in the inputs) ──
    [oA, eA, fA, dA, cA, cpA, dsA, d0A] = f_eng(i_seed, i_sims, tgtMain, dailyAmt, maxDDAmt, ddTypeI, winP, i_rr, maxD, true)
    int nA = array.size(oA)
    passDays = array.new_float(0)
    for s = 0 to nA - 1
        int o = array.get(oA, s)
        array.set(gShare, o, array.get(gShare, o) + 1.0 / nA)
        if o == 0
            array.push(passDays, array.get(eA, s))
    gPassA := array.get(gShare, 0)
    if array.size(passDays) > 0
        gDmed := array.percentile_linear_interpolation(passDays, 50)
        gDavg := array.avg(passDays)
        gD10  := array.percentile_linear_interpolation(passDays, 10)
        gD90  := array.percentile_linear_interpolation(passDays, 90)
    gClMed := array.percentile_linear_interpolation(cA, 50)
    gCl95  := array.percentile_linear_interpolation(cA, 95)
    gClMax := array.max(cA)
    gDDavg := array.avg(dA)
    gDD95  := array.percentile_linear_interpolation(dA, 95)
    gDayS  := dsA
    // survival bands by day checkpoint
    for i = 0 to 17
        int dd = int(math.round((i + 1) * maxD / 18.0))
        float sP = 0.0
        float sC = 0.0
        float sT = 0.0
        float sD = 0.0
        float sM = 0.0
        for s = 0 to nA - 1
            int o = array.get(oA, s)
            bool done = array.get(eA, s) <= dd
            if done
                sP += o == 0 ? 1.0 : 0.0
                sC += o == 4 ? 1.0 : 0.0
                sT += o == 3 and dd >= maxD ? 1.0 : 0.0
                sD += o == 1 ? 1.0 : 0.0
                sM += o == 2 ? 1.0 : 0.0
        float run = math.max(nA - sP - sC - sT - sD - sM, 0.0)
        matrix.set(gSurv, i, 0, sP / nA)
        matrix.set(gSurv, i, 1, sC / nA)
        matrix.set(gSurv, i, 2, sT / nA)
        matrix.set(gSurv, i, 3, run / nA)
        matrix.set(gSurv, i, 4, sD / nA)
        matrix.set(gSurv, i, 5, sM / nA)
    // balance fan
    gF05 := array.new_float(18, na)
    gF25 := array.new_float(18, na)
    gF50 := array.new_float(18, na)
    gF75 := array.new_float(18, na)
    gF95 := array.new_float(18, na)
    for c = 0 to 17
        col = matrix.col(cpA, c)
        array.set(gF05, c, array.percentile_linear_interpolation(col, 5))
        array.set(gF25, c, array.percentile_linear_interpolation(col, 25))
        array.set(gF50, c, array.percentile_linear_interpolation(col, 50))
        array.set(gF75, c, array.percentile_linear_interpolation(col, 75))
        array.set(gF95, c, array.percentile_linear_interpolation(col, 95))
    // ── the other phase (half the paths) ──
    float tgtB = mainIsP2 ? tgt1Amt : tgt2Amt
    [oB, eB, fB, dB, cB, cpB, dsB, d0B] = f_eng(i_seed + 13, math.max(50, int(i_sims / 2)), tgtB, dailyAmt, maxDDAmt, ddTypeI, winP, i_rr, maxD, false)
    int nB = array.size(oB)
    float pB = 0.0
    daysB = array.new_float(0)
    for s = 0 to nB - 1
        if array.get(oB, s) == 0
            pB += 1.0 / nB
            array.push(daysB, array.get(eB, s))
    float dmB = array.size(daysB) > 0 ? array.percentile_linear_interpolation(daysB, 50) : na
    gP1 := mainIsP2 ? pB : gPassA
    gP2 := mainIsP2 ? gPassA : pB
    gD1 := mainIsP2 ? dmB : gDmed
    gD2 := mainIsP2 ? gDmed : dmB
    // ── pass map: win rate (rows, high → low) × reward:risk (cols) ──
    for g = 0 to 41
        int wi = int(math.floor(g / 6.0))
        int ri = g - wi * 6
        float wr = math.max(1.0, math.min(99.0, i_win + 12.0 - 4.0 * wi)) / 100.0
        float rr = i_rr * (0.6 + 0.2 * ri)
        [oG, eG, fG, dG, cG, cpG, dsG, d0G] = f_eng(i_seed + 31 * (g + 1), i_gridSims, tgtMain, dailyAmt, maxDDAmt, ddTypeI, wr, rr, maxD, false)
        float pg = 0.0
        for s = 0 to i_gridSims - 1
            pg += array.get(oG, s) == 0 ? 1.0 : 0.0
        array.set(gGrid, g, pg / i_gridSims)
    // ── rule profiles: same edge under six rule sets (generic, not named firms) ──
    prT = array.from(i_tgt1, 8.0, 10.0, 6.0, 10.0, 9.0)
    prD = array.from(i_ddDay, 5.0, 5.0, 4.0, 5.0, 5.0)
    prM = array.from(i_ddMax, 10.0, 10.0, 8.0, 6.0, 10.0)
    prK = array.from(ddTypeI, 0, 0, 0, 2, 1)
    for p = 0 to 5
        [oP, eP, fP, dP, cP, cpP, dsP, d0P] = f_eng(i_seed + 500 + 17 * p, i_cmpSims, start * array.get(prT, p) / 100.0, start * array.get(prD, p) / 100.0, start * array.get(prM, p) / 100.0, array.get(prK, p), winP, i_rr, maxD, false)
        float pp = 0.0
        daysP = array.new_float(0)
        for s = 0 to i_cmpSims - 1
            if array.get(oP, s) == 0
                pp += 1.0
                array.push(daysP, array.get(eP, s))
        array.set(gPrP, p, pp / i_cmpSims)
        array.set(gPrD, p, array.size(daysP) > 0 ? array.percentile_linear_interpolation(daysP, 50) : na)
    // ── funded stage ──
    if i_fundSim
        [q1, q2, q3, q4, q5, q6] = f_fund(i_seed + 777, i_fundSims)
        fPay := q1
        fCnt := q2
        fAny := q3
        fLife := q4
        fAll := q5
        fMedLife := q6
    // ── sample journey: 30 trading days, challenge → funded ──
    [jPL, jEv, jPay, jFees, jFund] = f_journey(i_seed + 1000 * i_calRun, 30)
    gCal   := jPL
    gCalEv := jEv
    gJPay  := jPay
    gJFees := jFees
    gJFund := jFund

// ───────────────────────────── HEADLINE NUMBERS (scalars, cheap) ─────────────────────────────
pFund    = twoStep ? nz(gP1) * nz(gP2) : nz(gP1)
hPass    = phaseI == 2 and twoStep ? pFund : nz(gPassA)
hLab     = phaseI == 2 and twoStep ? "BOTH PHASES" : mainIsP2 ? "PHASE 2" : "PHASE 1"
hDays    = phaseI == 2 and twoStep ? gD1 + gD2 : gDmed
attempts = pFund > 0.001 ? 1.0 / pFund : na
feeCost  = na(attempts) ? na : attempts * i_fee
payout   = i_fundSim ? fPay : start * i_payPct / 100.0 * i_split / 100.0 * i_payN
pAny     = i_fundSim ? fAny : math.min(i_payN, 1.0)
refund   = i_refund ? i_fee * nz(pAny) : 0.0
netEV    = na(feeCost) ? na : nz(payout) + refund - feeCost
roi      = not na(netEV) and feeCost > 0 ? netEV / feeCost : na
rF       = riskEq / 100.0
stCost   = na(gCl95) ? na : (riskModeI == 0 ? (1.0 - math.pow(math.max(1.0 - rF * effLoss, 0.0), gCl95)) * 100.0 : gCl95 * riskEq * effLoss)
dayRoom  = riskEq * effLoss > 0 ? i_ddDay / (riskEq * effLoss) : na
trToTgt  = expPct > 0 ? (tgtMain / start * 100.0) / expPct : na

// ───────────────────────────── CARD HELPERS (20-cell grid) ─────────────────────────────
NC = 20
f_c(table tb, int c, int r, string tx, color fg, color bg, string al, int sz, float h, bool bold) =>
    table.cell(tb, c, r, tx, width = i_cw, height = h, text_color = fg, bgcolor = bg, text_size = sz, text_halign = al, text_valign = text.align_center, text_formatting = bold ? text.format_bold : text.format_none)

// a span of cells c0..c1 in one row, text in the first, merged (table is always fresh, so merging is safe)
f_span(table tb, int r, int c0, int c1, string tx, color fg, color bg, string al, int sz, float h, bool bold) =>
    for c = c0 to c1
        f_c(tb, c, r, c == c0 ? tx : "", fg, bg, al, sz, h, bold)
    if c1 > c0
        table.merge_cells(tb, c0, r, c1, r)

f_gapRow(table tb, int r, float h) =>
    for c = 0 to NC - 1
        table.cell(tb, c, r, " ", width = i_cw, height = h, text_color = C_NONE, bgcolor = C_NONE, text_size = 6)

// KPI tile: label row, big value row, segmented gauge row (10 cells)
f_tile(table tb, int c0, string lab, string val, color vc, float frac, color gc) =>
    f_span(tb, 1, c0, c0 + 9, lab, C_DIM, C_CARD, text.align_left, i_txt, i_h, true)
    f_span(tb, 2, c0, c0 + 9, val, vc, C_CARD, text.align_left, i_txtV, i_hv, true)
    int k = int(math.round(f_clamp(frac) * 10.0))
    for i = 0 to 9
        table.cell(tb, c0 + i, 3, " ", width = i_cw, height = math.max(0.5, i_h * 0.35), text_color = C_NONE, bgcolor = i < k ? gc : C_TRACK, text_size = 6)

f_title(table tb, int r, string title, string tag) =>
    f_span(tb, r, 0, 12, title, C_TITLE, C_CARD, text.align_left, i_txtT, i_h, true)
    f_span(tb, r, 13, NC - 1, tag, C_DIM, C_CARD, text.align_right, i_txt, i_h, false)

// footer stat boxes: 4 groups of 5 cells, label row r and value row r + 1
f_foot(table tb, int r, array<string> labs, array<string> vals, array<color> cols) =>
    for g = 0 to 3
        f_span(tb, r, g * 5, g * 5 + 4, array.get(labs, g), C_DIM, C_CARD, text.align_center, i_txt, i_h, true)
        f_span(tb, r + 1, g * 5, g * 5 + 4, array.get(vals, g), array.get(cols, g), C_CARD, text.align_center, i_txt, i_h, true)

// x-axis row: three groups across the 18 data columns
f_xaxis(table tb, int r, string a, string b, string c) =>
    f_span(tb, r, 0, 1, "", C_DIM, C_CARD, text.align_right, i_txt, i_h, false)
    f_span(tb, r, 2, 7, a, C_DIM, C_CARD, text.align_left, i_txt, i_h, false)
    f_span(tb, r, 8, 13, b, C_DIM, C_CARD, text.align_center, i_txt, i_h, false)
    f_span(tb, r, 14, NC - 1, c, C_DIM, C_CARD, text.align_right, i_txt, i_h, false)

f_heatGrad(float t) =>
    tt = f_clamp(t)
    tt < 0.5 ? color.from_gradient(tt, 0.0, 0.5, C_RED, C_YEL) : color.from_gradient(tt, 0.5, 1.0, C_YEL, C_GRN)
f_pf(float x) => na(x) ? "—" : str.tostring(x * 100.0, "0.0") + "%"          // fraction → %
f_pf0(float x) => na(x) ? "—" : str.tostring(x * 100.0, "0") + "%"
f_dy(float x) => na(x) ? "—" : str.tostring(x, "0.#") + " d"
f_sh(float x) =>
    float a = math.abs(nz(x))
    string s = a >= 1e6 ? str.tostring(a / 1e6, "0.0") + "M" : a >= 1e3 ? str.tostring(a / 1e3, "0.0") + "k" : str.tostring(a, "0")
    a < 0.5 ? "0" : (x > 0 ? "+" : "-") + s

// ───────────────────────────── RENDER (all tables rebuilt every last-bar execution) ─────────────────────────────
var table t1 = na
var table t2 = na
var table t3 = na
var table t4 = na
var table t5 = na
var table t6 = na

if barstate.islast and array.size(gF50) > 0
    oldTabs = array.copy(table.all)
    for tb in oldTabs
        table.delete(tb)
    string dA = "day " + str.tostring(math.round(maxD / 18.0))
    string dB = "day " + str.tostring(math.round(maxD / 2.0))
    string dC = "day " + str.tostring(maxD) + (i_maxDay == 0 ? " (cap)" : "")
    color passCol = hPass >= 0.6 ? C_GRN : hPass >= 0.35 ? C_YEL : C_RED

    // ══════════ CARD 1 · CHALLENGE SURVIVAL (top left) ══════════
    if i_c1
        t1 := table.new(position.top_left, NC, 17, C_NONE, C_GUT, 0, C_GUT, 1)
        f_gapRow(t1, 0, i_topOff)
        f_tile(t1, 0, "PASS PROBABILITY · " + hLab, f_pf(hPass), passCol, hPass, passCol)
        f_tile(t1, 10, "EXPECTED ATTEMPTS · FUNDED", na(attempts) ? "∞" : str.tostring(attempts, "0.0") + "×", na(attempts) or attempts > 4 ? C_RED : attempts > 2 ? C_YEL : C_GRN, na(attempts) ? 0.0 : 1.0 / attempts, na(attempts) or attempts > 4 ? C_RED : attempts > 2 ? C_YEL : C_GRN)
        f_title(t1, 4, "Challenge Survival", str.tostring(i_sims) + " paths · day by day")
        array<color> bc = array.from(C_GRN, C_PUR, C_GRY, C_TRACK, C_ORG, C_RED)
        for r = 0 to 8
            float m = (8.5 - r) / 9.0
            f_span(t1, 5 + r, 0, 1, r == 0 ? "100%" : r == 4 ? "50%" : r == 8 ? "0%" : "", C_DIM, C_PLOT, text.align_right, i_txt - 1, i_h, false)
            for i = 0 to 17
                float cum = 0.0
                color bg = C_RED
                bool found = false
                for k = 0 to 5
                    cum += matrix.get(gSurv, i, k)
                    if not found and cum >= m
                        bg := array.get(bc, k)
                        found := true
                f_c(t1, 2 + i, 5 + r, " ", C_NONE, bg, text.align_center, 6, i_h, false)
        f_xaxis(t1, 14, dA, dB, dC)
        float sT = array.get(gShare, 3)
        float sC = array.get(gShare, 4)
        f_foot(t1, 15, array.from("PASSED", "DAILY LOSS", "MAX DD", i_useCons ? "TIME · CONS" : "TIMED OUT"), array.from(f_pf(array.get(gShare, 0)), f_pf(array.get(gShare, 1)), f_pf(array.get(gShare, 2)), i_useCons ? f_pf0(sT) + " · " + f_pf0(sC) : f_pf(sT)), array.from(C_GRN, C_ORG, C_RED, C_GRY))

    // ══════════ CARD 2 · BALANCE FAN (top center) ══════════
    if i_c2
        t2 := table.new(position.top_center, NC, 17, C_NONE, C_GUT, 0, C_GUT, 1)
        f_gapRow(t2, 0, i_topOff)
        color dCol = na(hDays) ? C_RED : hDays <= maxD * 0.4 ? C_GRN : hDays <= maxD * 0.7 ? C_YEL : C_RED
        f_tile(t2, 0, "MEDIAN DAYS TO PASS · " + hLab, na(hDays) ? "—" : str.tostring(hDays, "0") + " days", dCol, na(hDays) ? 0.0 : 1.0 - hDays / maxD, dCol)
        color evCol = nz(netEV) > 0 ? C_GRN : C_RED
        f_tile(t2, 10, "NET EV · UNTIL FUNDED", na(netEV) ? "—" : f_ks(netEV), evCol, nz(netEV) > 0 ? f_clamp(nz(roi) / 5.0) : 1.0, evCol)
        f_title(t2, 4, "Balance Fan", "P5 · P25-75 · median")
        float tgtLv = start + tgtMain
        float flrLv = start - maxDDAmt
        float lo = math.min(array.min(gF05), flrLv)
        float hi = math.max(array.max(gF95), tgtLv)
        float dl = math.max((hi - lo) / 9.0, 1e-6)
        for r = 0 to 8
            float top = hi - r * dl
            float bot = hi - (r + 1) * dl
            bool isT = tgtLv > bot and tgtLv <= top
            bool isF = flrLv > bot and flrLv <= top
            bool isS = start > bot and start <= top
            string ax = isT ? f_kc(tgtLv) : isF ? f_kc(flrLv) : isS ? f_kc(start) : ""
            f_span(t2, 5 + r, 0, 1, ax, isT ? C_GRN : isF ? C_RED : C_DIM, C_PLOT, text.align_right, i_txt - 1, i_h, isT or isF)
            for i = 0 to 17
                float p05 = array.get(gF05, i)
                float p25 = array.get(gF25, i)
                float p50 = array.get(gF50, i)
                float p75 = array.get(gF75, i)
                float p95 = array.get(gF95, i)
                color bg = C_PLOT
                if p50 > bot and p50 <= top
                    bg := C_FANM
                else if p75 > bot and p25 <= top
                    bg := C_FANI
                else if p95 > bot and p05 <= top
                    bg := C_FANO
                else if isT
                    bg := color.from_gradient(0.35, 0.0, 1.0, C_PLOT, C_GRN)
                else if isF
                    bg := color.from_gradient(0.35, 0.0, 1.0, C_PLOT, C_RED)
                else if isS
                    bg := C_TRACK
                f_c(t2, 2 + i, 5 + r, " ", C_NONE, bg, text.align_center, 6, i_h, false)
        f_xaxis(t2, 14, dA, dB, dC)
        f_foot(t2, 15, array.from("FASTEST 10%", "MEDIAN", "AVERAGE", "SLOWEST 10%"), array.from(f_dy(gD10), f_dy(gDmed), f_dy(gDavg), f_dy(gD90)), array.from(C_GRN, C_TITLE, C_TXT, nz(gD90) > maxD * 0.8 ? C_RED : C_YEL))

    // ══════════ CARD 3 · READINESS CHECKLIST (top right) ══════════
    if i_c3
        t3 := table.new(position.top_right, NC, 17, C_NONE, C_GUT, 0, C_GUT, 1)
        f_gapRow(t3, 0, i_topOff)
        array<string> cl = array.from("Positive edge after costs", "Sample of 100+ trades", "Risk within half Kelly", "Pass odds at least 50%", "P95 losing streak survivable", "Daily limit holds 3+ losses", "Spread / slippage modelled", "Execution rate 85%+", "Avg max DD under 70% of limit", "Positive EV until funded")
        array<string> cv = array.from(str.tostring(expR, "+0.00;-0.00") + "R", str.tostring(i_sample) + " tr", str.tostring(riskEq, "0.0#") + "% / " + (na(kelly) or kelly <= 0 ? "0" : str.tostring(kelly / 2.0, "0.0")) + "%", f_pf(hPass), (na(stCost) ? "—" : "-" + str.tostring(stCost, "0.0") + "%") + " / " + str.tostring(i_ddMax, "0.#") + "%", na(dayRoom) ? "—" : str.tostring(dayRoom, "0.0") + " losses", str.tostring(i_spreadR, "0.00") + "R", str.tostring(i_exec, "0") + "%", "-" + str.tostring(nz(gDDavg), "0.0") + "% / " + str.tostring(i_ddMax * 0.7, "0.0") + "%", na(netEV) ? "—" : f_ks(netEV))
        array<bool> ck = array.from(expR > 0, i_sample >= 100, not na(kelly) and kelly > 0 and riskEq <= kelly / 2.0, hPass >= 0.5, not na(stCost) and stCost < i_ddMax, nz(dayRoom) >= 3.0, i_spreadR > 0, i_exec >= 85, nz(gDDavg) < i_ddMax * 0.7, nz(netEV) > 0)
        int score = 0
        for j = 0 to 9
            score += array.get(ck, j) ? 1 : 0
        color sCol = score >= 8 ? C_GRN : score >= 6 ? C_YEL : C_RED
        f_tile(t3, 0, "EDGE AFTER COSTS · PER TRADE", str.tostring(expR, "+0.00;-0.00") + " R", expR > 0 ? C_GRN : C_RED, expR > 0 ? expR : 1.0, expR > 0 ? C_GRN : C_RED)
        f_tile(t3, 10, "READINESS · " + (score >= 8 ? "READY" : score >= 6 ? "BORDERLINE" : "NOT READY"), str.tostring(score) + " / 10", sCol, score / 10.0, sCol)
        f_title(t3, 4, "Readiness Checklist", "10 checks · your inputs")
        for j = 0 to 9
            bool ok = array.get(ck, j)
            f_span(t3, 5 + j, 0, 1, ok ? "✓" : "✗", C_BLK, ok ? C_GRN : C_RED, text.align_center, i_txt, i_h, true)
            f_span(t3, 5 + j, 2, 13, array.get(cl, j), ok ? C_TXT : C_TITLE, j % 2 == 0 ? C_CARD : C_PLOT, text.align_left, i_txt, i_h, false)
            f_span(t3, 5 + j, 14, NC - 1, array.get(cv, j), ok ? C_GRN : C_RED, j % 2 == 0 ? C_CARD : C_PLOT, text.align_right, i_txt, i_h, true)
        string kTag = na(kelly) or kelly <= 0 ? "NO EDGE" : riskEq > kelly ? "OVER-BET" : riskEq > kelly / 2.0 ? "AGGRESSIVE" : "PRUDENT"
        color kCol = kTag == "PRUDENT" ? C_GRN : kTag == "AGGRESSIVE" ? C_YEL : C_RED
        f_foot(t3, 15, array.from("KELLY · " + kTag, "TRADES TO TGT", "P95 L-STREAK", "AVG MAX DD"), array.from(na(kelly) ? "—" : str.tostring(kelly, "0.0") + "%", na(trToTgt) ? "never" : str.tostring(trToTgt, "0") + " · " + str.tostring(trToTgt / i_tpd, "0.0") + "d", na(gCl95) ? "—" : str.tostring(gCl95, "0") + " in a row", "-" + str.tostring(nz(gDDavg), "0.0") + "%"), array.from(kCol, na(trToTgt) ? C_RED : C_TXT, C_TXT, nz(gDDavg) < i_ddMax * 0.7 ? C_TXT : C_RED))

    // ══════════ CARD 4 · PASS MAP (bottom left) ══════════
    if i_c4
        t4 := table.new(position.bottom_left, NC, 14, C_NONE, C_GUT, 0, C_GUT, 1)
        f_title(t4, 0, "Pass Map", "win rate × R:R · " + str.tostring(i_gridSims) + "/cell")
        f_span(t4, 1, 0, 1, "WR", C_DIM, C_TRACK, text.align_center, i_txt - 1, i_h, true)
        for ri = 0 to 5
            float rr = i_rr * (0.6 + 0.2 * ri)
            f_span(t4, 1, 2 + ri * 3, 4 + ri * 3, (ri == 2 ? "▶ " : "") + str.tostring(rr, "0.0#") + "R", ri == 2 ? C_TITLE : C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        float best = -1.0
        string bestTx = "—"
        float minWr = na
        for wi = 0 to 6
            float wr = math.max(1.0, math.min(99.0, i_win + 12.0 - 4.0 * wi))
            f_span(t4, 2 + wi, 0, 1, str.tostring(wr, "0") + "%", wi == 3 ? C_TITLE : C_DIM, wi == 3 ? C_TRACK : C_PLOT, text.align_center, i_txt - 1, i_h, wi == 3)
            for ri = 0 to 5
                float v = array.get(gGrid, wi * 6 + ri)
                bool base = wi == 3 and ri == 2
                if v > best
                    best := v
                    bestTx := str.tostring(wr, "0") + "% · " + str.tostring(i_rr * (0.6 + 0.2 * ri), "0.0#") + "R"
                if ri == 2 and v >= 0.5
                    minWr := wr
                f_span(t4, 2 + wi, 2 + ri * 3, 4 + ri * 3, (base ? "▶ " : "") + f_pf0(v), C_BLK, f_heatGrad(v), text.align_center, i_txt, i_h, true)
        f_span(t4, 9, 0, 1, "", C_DIM, C_CARD, text.align_center, 6, math.max(0.5, i_h * 0.45), false)
        for j = 0 to 17
            f_c(t4, 2 + j, 9, " ", C_NONE, f_heatGrad(j / 17.0), text.align_center, 6, math.max(0.5, i_h * 0.45), false)
        f_xaxis(t4, 10, "0% pass", "50%", "100% pass")
        float baseV = array.get(gGrid, 20)
        f_foot(t4, 11, array.from("BREAKEVEN WR", "YOUR CELL", "BEST CELL", "MIN WR · 50%"), array.from(f_pf(beWR), f_pf0(baseV), bestTx, na(minWr) ? "> " + str.tostring(math.min(99.0, i_win + 12.0), "0") + "%" : str.tostring(minWr, "0") + "%"), array.from(winP > nz(beWR) ? C_GRN : C_RED, f_heatGrad(baseV), C_GRN, na(minWr) ? C_RED : minWr <= i_win ? C_GRN : C_YEL))
        f_gapRow(t4, 13, i_botOff)

    // ══════════ CARD 5 · RULE PROFILES & PHASES (bottom center) ══════════
    if i_c5
        t5 := table.new(position.bottom_center, NC, 14, C_NONE, C_GUT, 0, C_GUT, 1)
        f_title(t5, 0, "Rule Profiles & Phases", "same edge · " + str.tostring(i_cmpSims) + " sims each")
        f_span(t5, 1, 0, 5, "PROFILE", C_DIM, C_TRACK, text.align_left, i_txt, i_h, true)
        f_span(t5, 1, 6, 7, "TGT", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 1, 8, 9, "DAY", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 1, 10, 11, "MAX", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 1, 12, 14, "DD TYPE", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 1, 15, 17, "PASS", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 1, 18, 19, "DAYS", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        array<string> pn = array.from("▶ Your rules", "Classic 2-Step", "Strict 2-Step", "Tight Budget", "Lock-Trail 1-Step", "Trailing 1-Step")
        array<float> pT = array.from(i_tgt1, 8.0, 10.0, 6.0, 10.0, 9.0)
        array<float> pD = array.from(i_ddDay, 5.0, 5.0, 4.0, 5.0, 5.0)
        array<float> pM = array.from(i_ddMax, 10.0, 10.0, 8.0, 6.0, 10.0)
        array<int>   pK = array.from(ddTypeI, 0, 0, 0, 2, 1)
        for p = 0 to 5
            bool me = p == 0
            color rb = me ? C_TRACK : C_CARD
            int kk = array.get(pK, p)
            float pv = array.get(gPrP, p)
            f_span(t5, 2 + p, 0, 5, array.get(pn, p), me ? C_TITLE : C_TXT, rb, text.align_left, i_txt, i_h, me)
            f_span(t5, 2 + p, 6, 7, str.tostring(array.get(pT, p), "0.#") + "%", C_TXT, rb, text.align_center, i_txt, i_h, false)
            f_span(t5, 2 + p, 8, 9, str.tostring(array.get(pD, p), "0.#") + "%", C_TXT, rb, text.align_center, i_txt, i_h, false)
            f_span(t5, 2 + p, 10, 11, str.tostring(array.get(pM, p), "0.#") + "%", C_TXT, rb, text.align_center, i_txt, i_h, false)
            f_span(t5, 2 + p, 12, 14, kk == 0 ? "Static" : kk == 1 ? "Trailing" : "Trail-Lock", C_DIM, rb, text.align_center, i_txt, i_h, false)
            f_span(t5, 2 + p, 15, 17, f_pf0(pv), C_BLK, f_heatGrad(pv), text.align_center, i_txt, i_h, true)
            f_span(t5, 2 + p, 18, 19, f_dy(array.get(gPrD, p)), C_TXT, rb, text.align_center, i_txt, i_h, false)
        f_span(t5, 8, 0, 5, "PHASE", C_DIM, C_TRACK, text.align_left, i_txt, i_h, true)
        f_span(t5, 8, 6, 9, "TARGET", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 8, 10, 14, "PASS", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 8, 15, 19, "MEDIAN DAYS", C_DIM, C_TRACK, text.align_center, i_txt, i_h, true)
        f_span(t5, 9, 0, 5, "Phase 1", C_TXT, C_CARD, text.align_left, i_txt, i_h, true)
        f_span(t5, 9, 6, 9, "+" + str.tostring(i_tgt1, "0.#") + "%", C_TXT, C_CARD, text.align_center, i_txt, i_h, false)
        f_span(t5, 9, 10, 14, f_pf(gP1), C_BLK, f_heatGrad(gP1), text.align_center, i_txt, i_h, true)
        f_span(t5, 9, 15, 19, f_dy(gD1), C_TXT, C_CARD, text.align_center, i_txt, i_h, false)
        f_span(t5, 10, 0, 5, "Phase 2", twoStep ? C_TXT : C_DIM, C_CARD, text.align_left, i_txt, i_h, true)
        f_span(t5, 10, 6, 9, "+" + str.tostring(i_tgt2, "0.#") + "%", twoStep ? C_TXT : C_DIM, C_CARD, text.align_center, i_txt, i_h, false)
        f_span(t5, 10, 10, 14, twoStep ? f_pf(gP2) : "not used", twoStep ? C_BLK : C_DIM, twoStep ? f_heatGrad(gP2) : C_PLOT, text.align_center, i_txt, i_h, true)
        f_span(t5, 10, 15, 19, twoStep ? f_dy(gD2) : "—", twoStep ? C_TXT : C_DIM, C_CARD, text.align_center, i_txt, i_h, false)
        float totD = twoStep ? gD1 + gD2 : gD1
        f_foot(t5, 11, array.from("FUNDED ODDS", "TOTAL DAYS", "ATTEMPTS", "COST TO FUND"), array.from(f_pf(pFund), f_dy(totD), na(attempts) ? "∞" : str.tostring(attempts, "0.0") + "×", na(feeCost) ? "—" : f_k(feeCost)), array.from(f_heatGrad(pFund), C_TXT, na(attempts) or attempts > 4 ? C_RED : C_TXT, C_TXT))
        f_gapRow(t5, 13, i_botOff)

    // ══════════ CARD 6 · JOURNEY & ECONOMICS (bottom right) ══════════
    if i_c6
        t6 := table.new(position.bottom_right, NC, 14, C_NONE, C_GUT, 0, C_GUT, 1)
        f_title(t6, 0, "Journey & Economics", "trader #" + str.tostring(i_calRun) + " · 30 days")
        int nCal = array.size(gCal)
        float mxA = 1.0
        if nCal > 0
            mxA := math.max(math.abs(array.max(gCal)), math.abs(array.min(gCal)), 1.0)
        for r = 0 to 4
            f_span(t6, 1 + r, 0, 1, "D" + str.tostring(r * 6 + 1), C_DIM, C_PLOT, text.align_center, i_txt - 1, i_h, false)
            for j = 0 to 5
                int k = r * 6 + j
                string tx = " "
                color fg = C_TXT
                color bg = C_PLOT
                if k < nCal
                    float v = array.get(gCal, k)
                    int e = array.get(gCalEv, k)
                    float t = math.abs(v) / mxA
                    bg := v > 0 ? color.from_gradient(t, 0.0, 1.0, C_TRACK, C_GRN) : v < 0 ? color.from_gradient(t, 0.0, 1.0, C_TRACK, C_RED) : C_TRACK
                    fg := t > 0.55 ? C_BLK : C_TITLE
                    tx := f_sh(v)
                    if e >= 0
                        tx := e == 0 ? (twoStep ? "✓ P1" : "✓ PASS") : e == 1 ? "✓ P2" : e == 2 ? "✗ DAY" : e == 3 ? "✗ DD" : e == 4 ? "✗ TIME" : e == 5 ? "✗ CONS" : "$ PAID"
                        bg := e <= 1 or e == 6 ? C_GRN : C_RED
                        fg := C_BLK
                f_span(t6, 1 + r, 2 + j * 3, 4 + j * 3, tx, fg, bg, text.align_center, i_txt, i_h, true)
        array<string> el = array.from("Attempts", "Payouts", "≥1 payout", "Net EV", "Fees paid", "Paid to you", "Account life", "ROI on fees")
        array<string> ev = array.from(na(attempts) ? "∞" : str.tostring(attempts, "0.00"), i_fundSim ? str.tostring(nz(fCnt), "0.0") : str.tostring(i_payN, "0.0"), f_pf0(pAny), na(netEV) ? "—" : f_ks(netEV), na(feeCost) ? "—" : f_k(feeCost), f_k(payout), i_fundSim ? str.tostring(nz(fMedLife), "0") + " / " + str.tostring(i_maxCyc) + " cyc" : "manual", na(roi) ? "—" : str.tostring(roi * 100.0, "+0;-0") + "%")
        array<color> ec = array.from(C_TXT, C_TXT, nz(pAny) >= 0.5 ? C_GRN : C_YEL, nz(netEV) > 0 ? C_GRN : C_RED, C_RED, C_GRN, C_TXT, nz(roi) > 0 ? C_GRN : C_RED)
        for r = 0 to 3
            color rb = r % 2 == 0 ? C_CARD : C_PLOT
            f_span(t6, 6 + r, 0, 5, array.get(el, r), C_DIM, rb, text.align_left, i_txt, i_h, true)
            f_span(t6, 6 + r, 6, 9, array.get(ev, r), array.get(ec, r), rb, text.align_right, i_txt, i_h, true)
            f_span(t6, 6 + r, 10, 15, array.get(el, r + 4), C_DIM, rb, text.align_left, i_txt, i_h, true)
            f_span(t6, 6 + r, 16, NC - 1, array.get(ev, r + 4), array.get(ec, r + 4), rb, text.align_right, i_txt, i_h, true)
        string jTx = "Trader #" + str.tostring(i_calRun) + " · " + str.tostring(gJFees) + (gJFees == 1 ? " fee · " : " fees · ") + (gJFund > 0 ? "funded day " + str.tostring(gJFund) + " · " + f_k(gJPay) + " paid" : "not funded in 30 days")
        f_span(t6, 10, 0, NC - 1, jTx, gJFund > 0 ? C_GRN : C_YEL, C_CARD, text.align_center, i_txt, i_h, true)
        float aUp = array.get(gDayS, 1) > 0 ? array.get(gDayS, 0) / array.get(gDayS, 1) : na
        float aDn = array.get(gDayS, 3) > 0 ? array.get(gDayS, 2) / array.get(gDayS, 3) : na
        f_foot(t6, 11, array.from("AVG UP DAY", "AVG DOWN DAY", "BEST DAY", "WORST DAY"), array.from(f_ks(aUp), f_ks(aDn), f_ks(array.get(gDayS, 4)), f_ks(array.get(gDayS, 5))), array.from(C_GRN, C_RED, C_GRN, C_RED))
        f_gapRow(t6, 13, i_botOff)

// ───────────────────────────── ALERTS ─────────────────────────────
alertcondition(expR <= 0, "Negative Edge", "PROP SIM 2.0: expectancy is zero or negative after costs.")
alertcondition(hPass < 0.5, "Pass Odds Below 50%", "PROP SIM 2.0: simulated pass probability is under 50%.")
alertcondition(nz(netEV) <= 0, "Negative Challenge EV", "PROP SIM 2.0: expected payouts do not cover the fees until funded.")
````
