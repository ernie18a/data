# Strong Prop Challenge Sim | ProjectSyndicate

- url: https://www.tradingview.com/script/9mSBpDjC-Strong-Prop-Challenge-Sim-ProjectSyndicate/
- type: indicator
- pine_id: PUB;3ac383e515ef45228364f09cd94a5850
- version: 1.0

## Description

Strong Challenge Sim answers the one question every prop-firm trader pays to find out the hard way: with the edge you actually have, what are the odds you pass — and what kills you when you don't. Instead of a single pass/fail formula, it runs thousands of complete evaluations trade-by-trade and day-by-day, enforcing your firm's real rule set the way the firm enforces it: profit target, daily loss limit, maximum drawdown, minimum days, deadline, and consistency. Every simulated run is counted into exactly one outcome — passed, killed by the daily limit, killed by max drawdown, voided by the consistency rule, or out of time — so the buckets always sum to 100% and no losing run is hidden. The result is drawn as real equity curves on a real balance axis in its own pane, ranked on a two-panel dashboard, priced out in expected value, and audited against a pre-flight checklist — so you can see how the challenge behaves on your numbers before you pay a fee.

[image]https://www.tradingview.com/x/p50Qu6tk/[/image]

🎲 Monte-Carlo Core — the core idea, expressed as a lifecycle: EDGE ▸ TRADES ▸ DAYS ▸ RULES ▸ VERDICT. Your edge is defined per trade — win rate, reward:risk, average loss in R, risk basis and size, trades per day. The engine plays that edge forward one trade at a time, accumulates each day, and after every single trade it checks the rule stack in the same order a firm's risk system does: has equity touched the maximum-drawdown floor, has the day's loss breached the daily limit, has the profit target been reached, and have the minimum trading days been served. The drawdown floor itself is modelled three ways — Static from your starting balance, Trailing from the equity peak, or Trailing → locks once the floor reaches your starting balance — because that single rule changes the answer more than almost anything else. Phase 1, Phase 2, or both back-to-back. A deterministic seed makes every result reproducible; change it to draw a different sample.

📈 Equity Simulator — the whole point is to watch the runs, so the indicator lives in its own pane on a true balance axis rather than fighting your price scale. Up to eight complete simulated challenges are drawn as full equity curves, stretched across an adjustable width, each coloured by how it actually ended: green passed, orange died on the daily loss limit, red blew the maximum drawdown, blue passed the target but was voided by the consistency rule, grey ran out of time. Every curve prints its ending balance and outcome at its right edge, and the Target, Start, and Max-DD reference lines are labelled with their real money values — so you read the balances directly instead of guessing at the scale.

🧮 Edge Analytics — the deterministic maths behind the simulation, stated plainly: expectancy per trade in R and as a percentage of equity, theoretical profit factor, break-even win rate, your margin above or below it, the Kelly-optimal risk with a verdict on the risk you actually chose (conservative / aggressive / OVER-BET), and the estimated number of trades to reach target alongside the average the simulation really needed. If the edge is negative, this is where it shows up first — no number of simulations fixes maths that doesn't work.

⚙️ Execution Reality — the section most calculators pretend doesn't exist, and the reason backtests flatter you. Two costs are modelled explicitly. Spread and slippage are charged on every single trade in R, shrinking every winner and deepening every loser, because clean mid-price backtesting overstates performance. Execution Rate captures the gap between the strategy and the operator: the share of setups you actually take by the rules, with the remainder taken as marginal, late, off-rule entries at a degraded win rate. The panel then shows your Backtest WR → Real WR and the exact R your edge loses to costs and execution. Improving execution is frequently worth more than optimising the strategy.

🧠 Loss-Streak Anchor — the psychological instrument. The engine records the longest run of consecutive losers in every simulation and reports the typical and worst streak you should expect, then converts the worst one into what it actually costs as a percentage of your account. This is the number that stops you revenge-trading on loss four when your own data says six is normal — and it is also a hard risk test: if your worst plausible streak costs more than the maximum drawdown, the challenge is unsurvivable at that risk size no matter how good the headline pass probability looks.

[image]https://www.tradingview.com/x/D5uPKnLx/[/image]

💰 Challenge Economics — a challenge is a purchase, so it gets priced like one. Enter the fee, whether it's refunded on first payout, your profit split, the profit you expect per payout cycle, and how many cycles you realistically expect to collect. The panel returns the expected number of attempts to pass, the total fees you should expect to spend getting there, your expected payouts, the net expected value of the whole venture, and the ROI on fees — flagged +EV or −EV. A 99% pass probability and a −EV verdict can coexist; this is where you find out.

📅 Profit Calendar — a day-by-day heat map of one sample run, up to thirty trading days, green for up days and red for down days with the intensity scaled to the size of the move and the P/L printed in each cell, plus that run's final outcome. It turns an abstract probability into a story you can read: where the drawdown hit, which day carried the account, and whether one outsized day is quietly setting up a consistency-rule violation.

⚖️ Rule-Profile Comparison — your identical edge run against six different rule sets side by side, showing target, daily limit, maximum drawdown and the resulting pass probability, with your own rules marked. Profiles are labelled by their actual numbers and drawdown type rather than by brand, because firm terms change and the rules are what the maths responds to. The same trader can be comfortably profitable under one rule set and mathematically doomed under another — this makes that visible before you choose.

🔥 Sensitivity Grid — an optional 5×5 heat grid re-running the simulation across a range of win rates and reward:risk ratios around your inputs, colour-graded by pass probability with your base case marked. It shows how fragile or robust your pass odds are: whether you sit on a plateau where a small slip still passes, or on a cliff edge where two points of win rate is the difference between funded and refunded.

✅ Readiness Checklist — the pre-flight audit, scored out of eight, every box ✓ before you pay: the edge is positive after costs, the sample behind your numbers is at least 100 trades, risk sits at or below half-Kelly, pass probability clears 50%, the worst loss streak is survivable inside the maximum drawdown, spread and slippage are actually modelled, execution rate is at least 85%, and the average drawdown per run stays inside the limit. Each item shows the value it was judged on, so a ✗ tells you exactly what to fix.

📊 Two-Panel Dashboard — the read-out is split into two panels so it fits on a normal screen. Panel A — Results carries the verdict with a pass-probability bar and a plain-language rating, the full failure breakdown by cause, time to pass as median / fastest 10% / average / slowest 10% with the average ending balance and net P/L, the loss-streak anchor, day extremes (average up day, average down day, gain/loss ratio, best and worst day), and your setup summary. Panel B — Edge & Economics carries edge analytics, execution reality, challenge economics, and the readiness checklist. Both panels, the calendar, the comparison and the grid can each be placed in any of nine screen slots at three text sizes, so nothing overlaps whatever else you run.

🎚️ Discipline & Behaviour Controls — rules you impose on yourself, tested rather than assumed. A daily profit lock stops the day after +X R; a circuit breaker stops it after −Y R. Tilt / revenge sizing models the classic killer: after a chosen number of consecutive losses, risk is multiplied — switch it on and watch the daily-loss failure rate climb. The consistency rule caps how much of total profit a single day may carry and voids passes that breach it, exactly as firms do. Variable R randomises win and loss sizes around your averages for extra realism.

🔔 Alerts — fires on a positive edge (expectancy above 0R after costs) and on a negative edge, the latter being the one that matters: it means the challenge maths does not work at your current inputs, regardless of how the curves happen to look.

🔧 Fully Customizable — every component is exposed: account size, currency symbol and phase; both profit targets, daily and maximum drawdown, drawdown type, minimum days, deadline, and the consistency rule with its threshold; win rate, reward:risk, average loss in R, risk basis (current equity / starting balance / fixed amount), risk size, trades per day, and the sample size behind your numbers; spread and slippage in R, execution rate, off-rule win rate, and tilt with its trigger and multiplier; the profit lock and circuit breaker; fee, refund, split, payout percentage and payout count; simulation count, seed, and R randomisation; curve count, curve width, reference lines and balance labels; and every panel, module, position and text size.

[image]https://www.tradingview.com/x/GrhCPjzn/[/image]

🎯 Why this is different — a pass-probability calculator gives you one number from a formula and stops. This runs the entire evaluation thousands of times under the firm's real rule stack, tells you not just whether you pass but precisely what kills you when you don't, charges you for spread and for the trades you don't take properly, hands you the loss streak you must be able to sit through, prices the attempt in expected value rather than hope, checks your readiness against eight objective boxes, and draws the whole thing as honest equity curves where every stop-out is counted. It is built to talk you out of a bad challenge, not into one.

🚀 Where to use it — the simulator is symbol- and timeframe-agnostic: it models your trading edge and your firm's rules, not the chart it sits on, so you can leave it on any instrument on any timeframe and the answer is the same. Load the chart you actually intend to trade for context, feed it the win rate and reward:risk from your own backtest or journal on that market, and set the rule inputs to your specific target firm — different firms' rules produce materially different answers from the identical edge.

🎯 How to use it

Enter your firm's rules exactly — target, daily limit, maximum drawdown, and above all the correct drawdown type, since Static, Trailing and Trailing → Lock are not interchangeable.
Enter your real edge from a real sample — win rate, reward:risk, average loss in R, risk per trade and trades per day — and set the sample size honestly. Under 100 trades, the checklist will flag your numbers as statistically meaningless, and it is right.
Set the execution reality before you believe anything — put your true spread and slippage in R, and set your execution rate to what you actually achieve, not what you intend. Watch Backtest WR → Real WR.

Read the verdict, then read why runs fail — the failure breakdown tells you what to fix. Daily-limit failures mean size or tilt; max-drawdown failures mean the edge or the risk; timeouts mean the target is out of reach in the time allowed.
Check the loss-streak anchor and the checklist before the pass probability — a 99% pass probability with an unsurvivable worst streak is a tail risk, not a green light.

Price it in Panel B — if the net expected value is negative, the challenge is a bad purchase however good the odds look.
Tune risk with the Kelly verdict and the sensitivity grid, and re-check the calendar for consistency-rule exposure if your firm enforces one.

⚠️ Important — this is a planning and decision-support tool, not a trading system, and it makes no performance guarantees. Every output is a probabilistic estimate derived entirely from the inputs you provide: the simulation cannot know your real edge, and garbage in is garbage out with three decimal places. Real markets are not independent coin flips — they cluster, trend, gap and change regime, while the model assumes each trade is an independent draw from your stated win rate, so treat the results as the mathematical shape of your challenge rather than a forecast of it. Pass probability is the headline and the least useful number on its own; weigh it against the failure breakdown, the loss-streak anchor, average drawdown and expected value. Rule sets vary between firms and change over time — verify every rule against your firm's current terms, particularly the drawdown type and any consistency requirement. No simulation, however honest, is a substitute for a tested edge and your own risk management.

## Source Code

````pine
//@version=6
indicator("Strong Prop Challenge Sim", overlay=false, max_bars_back=10, max_labels_count=30, format=format.price, precision=0)

gA = "① ACCOUNT & FIRM"
i_balance = input.float(100000, "Account Size", group=gA, minval=100, step=1000, tooltip="Starting evaluation balance.")
i_curSel  = input.string("$ USD", "Currency", options=["$ USD","€ EUR","£ GBP","¥ JPY","₮ USDT","₿ BTC"], group=gA)
i_phaseLb = input.string("Phase 1", "Simulate Phase", options=["Phase 1","Phase 2","Both Phases (combined)"], group=gA, tooltip="Which stage(s) to simulate. 'Both' requires passing Phase 1 then Phase 2 back-to-back.")

gR = "② FIRM RULES"
i_tgt1   = input.float(8.0, "Phase 1 Profit Target %", group=gR, minval=0.1, step=0.5)
i_tgt2   = input.float(5.0, "Phase 2 Profit Target %", group=gR, minval=0.1, step=0.5)
i_ddDay  = input.float(5.0, "Daily Loss Limit %",      group=gR, minval=0.1, step=0.5, tooltip="Max loss from the day's starting balance.")
i_ddMax  = input.float(10.0,"Max Overall Drawdown %",  group=gR, minval=0.1, step=0.5)
i_ddType = input.string("Static (from start)", "Drawdown Type", options=["Static (from start)","Trailing (from peak)","Trailing → locks at start"], group=gR, tooltip="Static: fixed floor at start-maxDD.\nTrailing: floor follows equity peak.\nLocks: trails the peak until the floor reaches the starting balance, then freezes.")
i_minDay = input.int(3,  "Minimum Trading Days", group=gR, minval=0, maxval=60)
i_maxDay = input.int(30, "Deadline — Max Days (0 = unlimited)", group=gR, minval=0, maxval=200, tooltip="Trading-day deadline. 0 treats the challenge as unlimited (capped at 200 for the sim).")
i_useCons= input.bool(false, "Consistency Rule", group=gR, tooltip="Many firms void a pass if one day carries too much of the total profit. Checked at the moment the target is hit.")
i_consPct= input.float(40.0, "Best Day ≤ % of Total Profit", group=gR, minval=5, maxval=100, step=5)

gE = "③ TRADER EDGE (per trade)"
i_win    = input.float(50.0, "Win Rate %",            group=gE, minval=1, maxval=99, step=1)
i_rr     = input.float(2.0,  "Avg Reward : Risk (R)", group=gE, minval=0.1, step=0.1, tooltip="Average winner size in R (risk units).")
i_lossR  = input.float(1.0,  "Avg Loss (R)",          group=gE, minval=0.1, step=0.1, tooltip="Average loser size in R. >1 models slippage / stop overruns.")
i_riskB  = input.string("% of current equity", "Risk Basis", options=["% of current equity","% of starting balance","Fixed amount"], group=gE)
i_riskP  = input.float(1.0,  "Risk per Trade %",      group=gE, minval=0.01, step=0.1)
i_riskF  = input.float(1000, "Fixed Risk Amount",     group=gE, minval=0, step=50)
i_tpd    = input.int(4,      "Trades per Day",         group=gE, minval=1, maxval=30)
i_sample = input.int(100, "Backtested Sample Size (trades)", group=gE, minval=1, maxval=5000, step=10, tooltip="How many trades your win-rate/RR came from. Under ~100 trades the numbers are statistically meaningless — the checklist flags this.")

gX = "④ EXECUTION REALITY (what kills most backtests)"
i_spreadR = input.float(0.05, "Spread + Slippage (R per trade)", group=gX, minval=0.0, maxval=1.0, step=0.01, tooltip="Cost applied to EVERY trade, in risk units. Backtesting on clean mid-price data overstates performance. Winners shrink by this, losers grow by this.")
i_exec    = input.float(100.0, "Execution Rate %", group=gX, minval=1, maxval=100, step=1, tooltip="Share of setups you actually take by the rules (A-grade). The rest become marginal/late entries at a degraded win rate. Your live win rate is almost always below your backtest win rate because of this gap.")
i_cWin    = input.float(30.0, "Off-Rule (C-grade) Win Rate %", group=gX, minval=1, maxval=99, step=1, tooltip="Win rate on the trades you take that break your rules.")
i_useTilt = input.bool(false, "Tilt / Revenge Sizing", group=gX, tooltip="After a losing streak, size up — the classic account killer.")
i_tiltAft = input.int(3, "Tilt After N Consecutive Losses", group=gX, minval=1, maxval=10)
i_tiltMlt = input.float(2.0, "Tilt Risk Multiplier", group=gX, minval=1.0, maxval=10.0, step=0.5)

gD = "⑤ DISCIPLINE (optional)"
i_useLock = input.bool(false, "Stop day after +X R (profit lock)", group=gD)
i_lockR   = input.float(3.0,  "Daily Profit Lock (R)", group=gD, minval=0.1, step=0.5)
i_useStop = input.bool(false, "Stop day after −Y R (circuit breaker)", group=gD)
i_stopR   = input.float(3.0,  "Daily Stop (R)",        group=gD, minval=0.1, step=0.5)

gC = "⑥ CHALLENGE ECONOMICS"
i_showEco = input.bool(true, "Show Economics & ROI", group=gC)
i_fee     = input.float(500, "Challenge Fee", group=gC, minval=0, step=50, tooltip="Cost per attempt. Paid every attempt until you pass.")
i_refund  = input.bool(true, "Fee Refunded on First Payout", group=gC)
i_split   = input.float(80.0, "Profit Split %", group=gC, minval=0, maxval=100, step=5)
i_payPct  = input.float(4.0, "Expected Profit % per Payout Cycle", group=gC, minval=0.1, maxval=50, step=0.5, tooltip="Typical profit you expect to make on the funded account per payout cycle.")
i_payN    = input.float(3.0, "Expected Payouts Before Account Loss", group=gC, minval=0.1, maxval=50, step=0.5, tooltip="Realistically, funded accounts don't last forever. How many payout cycles do you expect to collect?")

gM = "⑦ MONTE-CARLO ENGINE"
i_sims   = input.int(1000, "Simulations", group=gM, minval=100, maxval=5000, step=100, tooltip="More runs = smoother probability, slower load. 1000 is a good balance.")
i_seed   = input.int(7,    "Random Seed", group=gM, minval=1, tooltip="Fixes the sequence so results are reproducible. Change it to see another draw.")
i_varR   = input.bool(false,"Variable R (randomize win/loss size)", group=gM, tooltip="Adds spread to each trade's R around the averages for extra realism.")
i_rRand  = input.float(0.35,"R Randomness ±%", group=gM, minval=0.0, maxval=0.95, step=0.05)

gS = "⑧ EQUITY SIMULATOR (this pane)"
i_showSim  = input.bool(true, "Draw Simulated Equity Curves", group=gS, tooltip="Sample Monte-Carlo runs on a real equity axis. Green = passed · Orange = daily-loss fail · Red = max-DD fail · Blue = consistency fail · Gray = ran out of time.")
i_paths    = input.int(8, "Number of Equity Curves", group=gS, minval=1, maxval=8)
i_vizWidth = input.int(200, "Curve Width (bars)", group=gS, minval=40, maxval=480, tooltip="Each run is stretched across this many bars so it reads as a full curve.")
i_showRefs = input.bool(true, "Show Target / Start / Max-DD lines", group=gS)
i_showLbl  = input.bool(true, "Show Balance Labels on Curves", group=gS, tooltip="Prints the ending balance and outcome at the end of each run, plus the Target / Start / Max-DD balances on the reference lines.")

gV = "⑨ DASHBOARD & MODULES"
i_showDash = input.bool(true,  "Show Dashboard — Panel A (Results)", group=gV, tooltip="Verdict, failure breakdown, time to pass, streaks, day extremes, setup.")
i_showDshB = input.bool(true,  "Show Dashboard — Panel B (Edge & Economics)", group=gV, tooltip="Edge analytics, execution reality, economics, readiness checklist. Split from Panel A so it fits on a normal screen.")
i_showChk  = input.bool(true,  "  └ Include Readiness Checklist (Panel B)", group=gV, tooltip="The pre-challenge checklist — every box should be ✓ before you pay a fee.")
i_showCal  = input.bool(true,  "Show Profit Calendar", group=gV, tooltip="Day-by-day P/L of one sample run. Green = up day, red = down day.")
i_calRun   = input.int(1, "  └ Calendar Run #", group=gV, minval=1, maxval=8)
i_showCmp  = input.bool(false, "Show Rule-Profile Comparison", group=gV, tooltip="Your same edge run against different firm rule sets. Slower.")
i_cmpSims  = input.int(300, "  └ Comparison Sims", group=gV, minval=50, maxval=1000, step=50)
i_showGrid = input.bool(false, "Show Win% × R:R Sensitivity Grid", group=gV, tooltip="Re-runs a lighter Monte-Carlo across a 5×5 grid. Slowest option.")
i_gridSims = input.int(250, "  └ Grid Sims per Cell", group=gV, minval=50, maxval=1000, step=50)

gP = "⑩ POSITIONS"
i_posDash = input.string("Top Right",     "Dashboard A (Results)", options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=gP)
i_posDshB = input.string("Top Left",      "Dashboard B (Edge)",    options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=gP)
i_posCal  = input.string("Bottom Center", "Calendar",              options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=gP, tooltip="Bottom Center keeps it clear of both dashboard panels.")
i_posCmp  = input.string("Middle Center", "Comparison",            options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=gP)
i_posGrid = input.string("Bottom Left",   "Grid",                  options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=gP)
i_txt     = input.string("Small", "Text Size", options=["Tiny","Small","Normal"], group=gP)

C_BG0  = color.new(#050402, 0)
C_BG1  = color.new(#0C0A05, 0)
C_BG2  = color.new(#15110A, 0)
C_HDR  = color.new(#241803, 0)
C_BORD = color.new(#3A2A0A, 0)
C_AMB  = color.new(#FFB000, 0)
C_AMBB = color.new(#FFC83D, 0)
C_AMBD = color.new(#A8741A, 0)
C_AMBP = color.new(#FFE3AE, 0)
C_GRN  = color.new(#33D17A, 0)
C_GRND = color.new(#1F8F52, 0)
C_YEL  = color.new(#FFD23D, 0)
C_ORG  = color.new(#FF8A1A, 0)
C_RED  = color.new(#FF453A, 0)
C_REDD = color.new(#B5281F, 0)
C_BLU  = color.new(#4AA8FF, 0)
C_GRY  = color.new(#7A6A48, 0)

f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        => position.top_right
f_tsz() => i_txt == "Tiny" ? size.tiny : i_txt == "Normal" ? size.normal : size.small
curSym = i_curSel == "$ USD" ? "$" : i_curSel == "€ EUR" ? "€" : i_curSel == "£ GBP" ? "£" : i_curSel == "¥ JPY" ? "¥" : i_curSel == "₮ USDT" ? "₮" : "₿"
f_money0(x) => na(x) ? "—" : (x < 0 ? "-" : "") + curSym + str.format("{0,number,#,##0}", math.abs(x))
f_kilo(x) =>
    float a = math.abs(nz(x))
    string s = a >= 1000 ? str.tostring(a / 1000.0, "#,##0.0") + "k" : str.tostring(a, "#,##0")
    (x < 0 ? "-" : "+") + curSym + s
f_pct(x)    => na(x) ? "—" : str.tostring(x, "#,##0.0") + "%"
f_pct2(x)   => na(x) ? "—" : str.tostring(x, "#,##0.00") + "%"
f_num1(x)   => na(x) ? "—" : str.tostring(x, "#,##0.0")
f_cell(t, c, r, txt, tc, bg, al) => table.cell(t, c, r, txt, text_color=tc, bgcolor=bg, text_size=f_tsz(), text_halign=al)
f_bar(p) =>
    int n = int(math.round(math.min(math.max(nz(p), 0), 100) / 10.0))
    string s = ""
    for i = 0 to 9
        s += i < n ? "█" : "░"
    s
f_tick(bool ok) => ok ? "✓" : "✗"

int RNG_A = 1664525
int RNG_C = 1013904223
float RNG_M = 4294967296.0

start   = i_balance
tgt1Amt = start * i_tgt1 / 100.0
tgt2Amt = start * i_tgt2 / 100.0
dailyAmt= start * i_ddDay / 100.0
maxDDAmt= start * i_ddMax / 100.0
ddTypeI = i_ddType == "Static (from start)" ? 0 : i_ddType == "Trailing (from peak)" ? 1 : 2
riskModeI = i_riskB == "% of current equity" ? 0 : i_riskB == "% of starting balance" ? 1 : 2
winP    = i_win / 100.0
cWinP   = i_cWin / 100.0
execP   = i_exec / 100.0
maxDayUse = i_maxDay == 0 ? 200 : i_maxDay
phaseI  = i_phaseLb == "Phase 1" ? 0 : i_phaseLb == "Phase 2" ? 1 : 2
consFrac= i_consPct / 100.0

f_targetFor(ph) => ph == 1 ? tgt2Amt : tgt1Amt

effWR     = execP * winP + (1.0 - execP) * cWinP
effRR     = math.max(i_rr - i_spreadR, 0.0)
effLoss   = i_lossR + i_spreadR
expR      = effWR * effRR - (1.0 - effWR) * effLoss
expRaw    = winP * i_rr - (1.0 - winP) * i_lossR
expPct    = i_riskP * expR
pf        = (1.0 - effWR) * effLoss > 0 ? (effWR * effRR) / ((1.0 - effWR) * effLoss) : na
beWR      = (effRR + effLoss) > 0 ? effLoss / (effRR + effLoss) * 100.0 : na
bOdds     = effLoss > 0 ? effRR / effLoss : na
kelly     = not na(bOdds) and bOdds > 0 ? (bOdds * effWR - (1.0 - effWR)) / bOdds * 100.0 : na
tradesToTgt = expPct > 0 ? math.ceil((phaseI == 1 ? i_tgt2 : i_tgt1) / expPct) : na
edgePos   = expR > 0
edgeDecay = expRaw - expR

int S_PASS = 0
int S_FD = 1
int S_FM = 2
int S_FT = 3
int S_FC = 4
int S_AVGD = 5
int S_MED = 6
int S_P10 = 7
int S_P90 = 8
int S_AVGFIN = 9
int S_WSTRK = 10
int S_MSTRK = 11
int S_AVGWD = 12
int S_AVGLD = 13
int S_BESTD = 14
int S_WORSTD = 15
int S_AVGDD = 16
int S_AVGTR = 17
int S_WINDAYS = 18
int S_N = 19

f_runMC(int seed, int nSims, float sBal, float tgtAmt, float dAmt, float mAmt, int ddT,
         int minD, int maxD, int tpd, float wp, float rr, float lr, int rMode,
         float rPct, float rFix, bool vR, float rRnd, bool uLock, float lockR, bool uStop, float stopR,
         float spR, float exP, float cwp, bool uTilt, int tiltA, float tiltM, bool uCons, float cFrac) =>
    int st = seed <= 0 ? 1 : seed
    int nPass = 0
    int nFD = 0
    int nFM = 0
    int nFT = 0
    int nFC = 0
    float sumDays = 0.0
    float sumFin = 0.0
    float sumDD = 0.0
    float sumTr = 0.0
    float sumWinDay = 0.0
    int   cntWinDay = 0
    float sumLossDay = 0.0
    int   cntLossDay = 0
    float bestD = na
    float worstD = na
    float sumWD = 0.0
    daysArr = array.new_float(0)
    strkArr = array.new_float(0)
    for s = 0 to nSims - 1
        float eq = sBal
        float peak = sBal
        int tday = 0
        int nTr = 0
        bool tgtHit = false
        int outc = -1
        int cl = 0
        int maxCl = 0
        float maxDDpc = 0.0
        float bestDayP = 0.0
        int winDays = 0
        for d = 0 to maxD - 1
            if tgtHit and tday >= minD
                outc := 0
                break
            float dayStart = eq
            float dayR = 0.0
            if not tgtHit
                for tr = 0 to tpd - 1
                    float risk = rMode == 0 ? eq * rPct / 100.0 : rMode == 1 ? sBal * rPct / 100.0 : rFix
                    risk := math.max(risk, 0.0)
                    if uTilt and cl >= tiltA
                        risk *= tiltM
                    st := (RNG_A * st + RNG_C) % 4294967296
                    float uE = st / RNG_M
                    float useWR = uE < exP ? wp : cwp
                    st := (RNG_A * st + RNG_C) % 4294967296
                    float u1 = st / RNG_M
                    nTr += 1
                    if u1 < useWR
                        float rd = rr
                        if vR
                            st := (RNG_A * st + RNG_C) % 4294967296
                            float u2 = st / RNG_M
                            rd := math.max(rr * (1.0 + (u2 - 0.5) * 2.0 * rRnd), 0.0)
                        float net = math.max(rd - spR, -5.0)
                        eq += risk * net
                        dayR += net
                        cl := 0
                    else
                        float ld = lr
                        if vR
                            st := (RNG_A * st + RNG_C) % 4294967296
                            float u3 = st / RNG_M
                            ld := math.max(lr * (1.0 + (u3 - 0.5) * 2.0 * rRnd), 0.0)
                        float net = ld + spR
                        eq -= risk * net
                        dayR -= net
                        cl += 1
                        maxCl := math.max(maxCl, cl)
                    peak := math.max(peak, eq)
                    maxDDpc := math.max(maxDDpc, peak > 0 ? (peak - eq) / peak * 100.0 : 0.0)
                    float floorMax = ddT == 0 ? sBal - mAmt : ddT == 1 ? peak - mAmt : math.min(peak - mAmt, sBal)
                    if eq <= floorMax
                        outc := 2
                        break
                    if (eq - dayStart) <= -dAmt
                        outc := 1
                        break
                    if not tgtHit and eq >= sBal + tgtAmt
                        tgtHit := true
                        break
                    if uLock and dayR >= lockR
                        break
                    if uStop and dayR <= -stopR
                        break
            float dayPL = eq - dayStart
            bestDayP := math.max(bestDayP, dayPL)
            if dayPL > 0
                sumWinDay += dayPL
                cntWinDay += 1
                winDays += 1
            else if dayPL < 0
                sumLossDay += dayPL
                cntLossDay += 1
            bestD  := na(bestD)  ? dayPL : math.max(bestD, dayPL)
            worstD := na(worstD) ? dayPL : math.min(worstD, dayPL)
            if outc == 1 or outc == 2
                break
            tday += 1
            if tgtHit and tday >= minD
                outc := 0
                break
        if outc == -1
            outc := 3
        if outc == 0 and uCons
            float totProf = eq - sBal
            if totProf > 0 and bestDayP > cFrac * totProf
                outc := 4
        if outc == 0
            nPass += 1
            sumDays += tday
            array.push(daysArr, tday)
        else if outc == 1
            nFD += 1
        else if outc == 2
            nFM += 1
        else if outc == 4
            nFC += 1
        else
            nFT += 1
        sumFin += eq
        sumDD  += maxDDpc
        sumTr  += nTr
        sumWD  += winDays
        array.push(strkArr, maxCl)
    array.sort(daysArr, order.ascending)
    array.sort(strkArr, order.ascending)
    int nP = array.size(daysArr)
    int nS = array.size(strkArr)
    out = array.new_float(S_N, na)
    array.set(out, S_PASS, nPass)
    array.set(out, S_FD, nFD)
    array.set(out, S_FM, nFM)
    array.set(out, S_FT, nFT)
    array.set(out, S_FC, nFC)
    array.set(out, S_AVGD, nPass > 0 ? sumDays / nPass : na)
    array.set(out, S_MED,  nP > 0 ? array.get(daysArr, int(math.floor((nP - 1) * 0.5))) : na)
    array.set(out, S_P10,  nP > 0 ? array.get(daysArr, int(math.floor((nP - 1) * 0.10))) : na)
    array.set(out, S_P90,  nP > 0 ? array.get(daysArr, int(math.floor((nP - 1) * 0.90))) : na)
    array.set(out, S_AVGFIN, sumFin / nSims)
    array.set(out, S_WSTRK, nS > 0 ? array.get(strkArr, nS - 1) : na)
    array.set(out, S_MSTRK, nS > 0 ? array.get(strkArr, int(math.floor((nS - 1) * 0.5))) : na)
    array.set(out, S_AVGWD, cntWinDay > 0 ? sumWinDay / cntWinDay : na)
    array.set(out, S_AVGLD, cntLossDay > 0 ? sumLossDay / cntLossDay : na)
    array.set(out, S_BESTD, bestD)
    array.set(out, S_WORSTD, worstD)
    array.set(out, S_AVGDD, sumDD / nSims)
    array.set(out, S_AVGTR, sumTr / nSims)
    array.set(out, S_WINDAYS, sumWD / nSims)
    out

f_run(int seed, int nSims, float tgtAmt, float dAmt, float mAmt, int ddT, float wp, float rr) =>
    f_runMC(seed, nSims, start, tgtAmt, dAmt, mAmt, ddT, i_minDay, maxDayUse, i_tpd, wp, rr, i_lossR, riskModeI, i_riskP, i_riskF, i_varR, i_rRand, i_useLock, i_lockR, i_useStop, i_stopR, i_spreadR, execP, cWinP, i_useTilt, i_tiltAft, i_tiltMlt, i_useCons, consFrac)

f_passProb(int seed, int nSims) =>
    float r = na
    if phaseI == 2
        a1 = f_run(seed, nSims, tgt1Amt, dailyAmt, maxDDAmt, ddTypeI, winP, i_rr)
        a2 = f_run(seed + 101, nSims, tgt2Amt, dailyAmt, maxDDAmt, ddTypeI, winP, i_rr)
        r := (array.get(a1, S_PASS) / nSims) * (array.get(a2, S_PASS) / nSims) * 100.0
    else
        a0 = f_run(seed, nSims, f_targetFor(phaseI), dailyAmt, maxDDAmt, ddTypeI, winP, i_rr)
        r := array.get(a0, S_PASS) / nSims * 100.0
    r

f_simPaths(int seed, int nP, int maxSteps, int maxDays) =>
    m     = matrix.new<float>(nP, maxSteps, na)
    dayM  = matrix.new<float>(nP, maxDays, na)
    lenA  = array.new_int(nP, 1)
    dayCA = array.new_int(nP, 0)
    outA  = array.new_int(nP, 3)
    finA  = array.new_float(nP, start)
    int st = seed <= 0 ? 1 : seed
    float tgtAmt = f_targetFor(phaseI == 2 ? 0 : phaseI)
    for p = 0 to nP - 1
        float eq = start
        float peak = start
        bool tgtHit = false
        int outc = -1
        int step = 1
        int tday = 0
        int cl = 0
        float bestDayP = 0.0
        bool stop = false
        matrix.set(m, p, 0, start)
        for d = 0 to maxDays - 1
            if step >= maxSteps or stop
                break
            if tgtHit and tday >= i_minDay
                outc := 0
                break
            float dayStart = eq
            float dayR = 0.0
            if not tgtHit
                for tr = 0 to i_tpd - 1
                    if step >= maxSteps
                        stop := true
                        break
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
                    matrix.set(m, p, step, eq)
                    step += 1
                    float floorMax = ddTypeI == 0 ? start - maxDDAmt : ddTypeI == 1 ? peak - maxDDAmt : math.min(peak - maxDDAmt, start)
                    if eq <= floorMax
                        outc := 2
                        stop := true
                        break
                    if (eq - dayStart) <= -dailyAmt
                        outc := 1
                        stop := true
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
            if d < maxDays
                matrix.set(dayM, p, d, dayPL)
                array.set(dayCA, p, d + 1)
            if stop
                break
            tday += 1
            if tgtHit and tday >= i_minDay
                outc := 0
                break
        if outc == -1
            outc := 3
        if outc == 0 and i_useCons
            float totProf = eq - start
            if totProf > 0 and bestDayP > consFrac * totProf
                outc := 4
        array.set(outA, p, outc)
        array.set(lenA, p, step)
        array.set(finA, p, eq)
    [m, lenA, outA, finA, dayM, dayCA]

int NPLOT   = 8
int MAXSTEP = 400
int MAXDAYS = 201
var matrix<float> gEq   = matrix.new<float>(NPLOT, MAXSTEP, na)
var matrix<float> gDay  = matrix.new<float>(NPLOT, MAXDAYS, na)
var array<int>    gLen  = array.new_int(NPLOT, 1)
var array<int>    gDayC = array.new_int(NPLOT, 0)
var array<int>    gOut  = array.new_int(NPLOT, 3)
var array<float>  gFin  = array.new_float(NPLOT, na)
var float gStart  = na
var float gTarget = na
var float gFloor  = na

if barstate.isfirst
    [mm, ll, oo, ff, dm, dc] = f_simPaths(i_seed + 999, NPLOT, MAXSTEP, MAXDAYS)
    for p = 0 to NPLOT - 1
        int ln = array.get(ll, p)
        array.set(gLen, p, ln)
        array.set(gOut, p, array.get(oo, p))
        array.set(gFin, p, array.get(ff, p))
        array.set(gDayC, p, array.get(dc, p))
        for s = 0 to ln - 1
            matrix.set(gEq, p, s, matrix.get(mm, p, s))
        int dcn = array.get(dc, p)
        if dcn > 0
            for d = 0 to dcn - 1
                matrix.set(gDay, p, d, matrix.get(dm, p, d))
    gStart  := start
    gTarget := start + f_targetFor(phaseI == 2 ? 0 : phaseI)
    gFloor  := start - maxDDAmt

f_pcol(int oc) => oc == 0 ? color.new(#2ECC71, 0) : oc == 1 ? color.new(#FF9F0A, 0) : oc == 2 ? color.new(#FF453A, 0) : oc == 4 ? color.new(#4AA8FF, 0) : color.new(#9AA0A6, 5)

f_val(int p) =>
    float v = na
    if i_showSim and p < i_paths
        int off = last_bar_index - bar_index
        int W = i_vizWidth
        if off >= 0 and off <= W - 1
            int ln = array.get(gLen, p)
            if ln >= 1
                float frac = W > 1 ? 1.0 - off / (W - 1.0) : 1.0
                float fpos = frac * (ln - 1)
                int i0 = int(math.floor(fpos))
                i0 := math.min(math.max(i0, 0), ln - 1)
                int i1 = math.min(i0 + 1, ln - 1)
                float w = fpos - i0
                v := matrix.get(gEq, p, i0) * (1.0 - w) + matrix.get(gEq, p, i1) * w
    v

plot(f_val(0), "Run 1", color=f_pcol(array.get(gOut, 0)), linewidth=2)
plot(f_val(1), "Run 2", color=f_pcol(array.get(gOut, 1)), linewidth=1)
plot(f_val(2), "Run 3", color=f_pcol(array.get(gOut, 2)), linewidth=1)
plot(f_val(3), "Run 4", color=f_pcol(array.get(gOut, 3)), linewidth=1)
plot(f_val(4), "Run 5", color=f_pcol(array.get(gOut, 4)), linewidth=1)
plot(f_val(5), "Run 6", color=f_pcol(array.get(gOut, 5)), linewidth=1)
plot(f_val(6), "Run 7", color=f_pcol(array.get(gOut, 6)), linewidth=1)
plot(f_val(7), "Run 8", color=f_pcol(array.get(gOut, 7)), linewidth=1)

plot(i_showRefs ? gTarget : na, "Target", color=color.new(#2ECC71, 30), linewidth=1)
plot(i_showRefs ? gStart  : na, "Start",  color=color.new(#9A8A5A, 45), linewidth=1)
plot(i_showRefs ? gFloor  : na, "Max DD", color=color.new(#FF453A, 30), linewidth=1)

var array<label> gLab = array.new<label>(0)
if barstate.isfirst
    for i = 0 to 10
        array.push(gLab, label.new(bar_index, na, "", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#0C0A05, 20), textcolor=C_AMBP, size=size.small))

f_outTxt(int oc) => oc == 0 ? "PASS" : oc == 1 ? "DAILY" : oc == 2 ? "MAX-DD" : oc == 4 ? "CONSIST" : "TIMEOUT"

if barstate.islast and array.size(gLab) == 11
    int xEnd  = last_bar_index
    int xLeft = math.max(last_bar_index - i_vizWidth + 1, 0)
    for p = 0 to NPLOT - 1
        lb = array.get(gLab, p)
        if i_showSim and i_showLbl and p < i_paths
            int ln = array.get(gLen, p)
            float fv = matrix.get(gEq, p, math.max(ln - 1, 0))
            int oc = array.get(gOut, p)
            label.set_xy(lb, xEnd, fv)
            label.set_text(lb, f_money0(fv) + " · " + f_outTxt(oc))
            label.set_textcolor(lb, f_pcol(oc))
            label.set_size(lb, f_tsz())
        else
            label.set_xy(lb, xEnd, na)
            label.set_text(lb, "")
    lbT = array.get(gLab, 8)
    lbS = array.get(gLab, 9)
    lbF = array.get(gLab, 10)
    if i_showRefs and i_showLbl
        label.set_xy(lbT, xLeft, gTarget)
        label.set_text(lbT, "TARGET  " + f_money0(gTarget))
        label.set_textcolor(lbT, C_GRN)
        label.set_size(lbT, f_tsz())
        label.set_xy(lbS, xLeft, gStart)
        label.set_text(lbS, "START  " + f_money0(gStart))
        label.set_textcolor(lbS, C_AMBP)
        label.set_size(lbS, f_tsz())
        label.set_xy(lbF, xLeft, gFloor)
        label.set_text(lbF, "MAX DD  " + f_money0(gFloor))
        label.set_textcolor(lbF, C_RED)
        label.set_size(lbF, f_tsz())
    else
        label.set_xy(lbT, xLeft, na)
        label.set_text(lbT, "")
        label.set_xy(lbS, xLeft, na)
        label.set_text(lbS, "")
        label.set_xy(lbF, xLeft, na)
        label.set_text(lbF, "")

var table DASH = table.new(f_pos(i_posDash), 2, 30, bgcolor=C_BG0, border_width=1, border_color=C_BORD, frame_width=1, frame_color=C_BORD)
var table DSHB = table.new(f_pos(i_posDshB), 2, 32, bgcolor=C_BG0, border_width=1, border_color=C_BORD, frame_width=1, frame_color=C_BORD)
var table TCAL = table.new(f_pos(i_posCal),  6, 8,  bgcolor=C_BG0, border_width=1, border_color=C_BORD, frame_width=1, frame_color=C_BORD)
var table TCMP = table.new(f_pos(i_posCmp),  5, 7,  bgcolor=C_BG0, border_width=1, border_color=C_BORD, frame_width=1, frame_color=C_BORD)
var table TGRD = table.new(f_pos(i_posGrid), 6, 8,  bgcolor=C_BG0, border_width=1, border_color=C_BORD, frame_width=1, frame_color=C_BORD)

f_row(table t, int r, string a, string b, color ca, color cb, color bg) =>
    f_cell(t, 0, r, a, ca, bg, text.align_left)
    f_cell(t, 1, r, b, cb, bg, text.align_right)

f_sec(table t, int r, string title, string tag, color tagc) =>
    f_cell(t, 0, r, title, C_AMBB, C_HDR, text.align_left)
    f_cell(t, 1, r, tag,   tagc,  C_HDR, text.align_right)

if barstate.islast and (i_showDash or i_showDshB)
    float tgtMain = f_targetFor(phaseI == 2 ? 0 : phaseI)
    res = f_run(i_seed, i_sims, tgtMain, dailyAmt, maxDDAmt, ddTypeI, winP, i_rr)
    float nPass = array.get(res, S_PASS)
    float passPct = phaseI == 2 ? f_passProb(i_seed, i_sims) : nPass / i_sims * 100.0
    float fdPct = array.get(res, S_FD) / i_sims * 100.0
    float fmPct = array.get(res, S_FM) / i_sims * 100.0
    float ftPct = array.get(res, S_FT) / i_sims * 100.0
    float fcPct = array.get(res, S_FC) / i_sims * 100.0
    float avgFin = array.get(res, S_AVGFIN)
    float wStrk  = array.get(res, S_WSTRK)
    float mStrk  = array.get(res, S_MSTRK)
    float avgWD  = array.get(res, S_AVGWD)
    float avgLD  = array.get(res, S_AVGLD)
    float bestD  = array.get(res, S_BESTD)
    float worstD = array.get(res, S_WORSTD)
    float avgDD  = array.get(res, S_AVGDD)
    float avgTr  = array.get(res, S_AVGTR)
    color passCol = passPct >= 70 ? C_GRN : passPct >= 45 ? C_AMBB : C_RED
    string verdict = passPct >= 70 ? "STRONG EDGE" : passPct >= 45 ? "COIN-FLIP" : passPct >= 20 ? "WEAK" : "UNLIKELY"
    color eCol = edgePos ? C_GRN : C_RED
    float strkCost = nz(wStrk) * i_riskP

    if i_showDash
        int r = 0
        f_sec(DASH, r, "🎯 CHALLENGE VERDICT", i_phaseLb, C_AMB)
        r += 1
        f_row(DASH, r, "PASS PROBABILITY", f_pct(passPct), passCol, passCol, C_BG2)
        r += 1
        f_row(DASH, r, f_bar(passPct), verdict, passCol, passCol, C_BG1)
        r += 1

        f_sec(DASH, r, "── WHY RUNS FAIL ──", str.tostring(i_sims, "#,##0") + " sims", C_AMBD)
        r += 1
        f_row(DASH, r, "⛔ Daily Loss Limit", f_pct(fdPct), C_AMBD, fdPct > 20 ? C_RED : C_AMBP, C_BG2)
        r += 1
        f_row(DASH, r, "📉 Max Drawdown", f_pct(fmPct), C_AMBD, fmPct > 20 ? C_RED : C_AMBP, C_BG1)
        r += 1
        f_row(DASH, r, "⏳ Ran Out of Time", f_pct(ftPct), C_AMBD, ftPct > 20 ? C_ORG : C_AMBP, C_BG2)
        r += 1
        if i_useCons
            f_row(DASH, r, "⚖ Consistency Rule", f_pct(fcPct), C_AMBD, fcPct > 10 ? C_BLU : C_AMBP, C_BG1)
            r += 1

        f_sec(DASH, r, "── TIME TO PASS (days) ──", phaseI == 2 ? "P1 only" : "", C_AMBD)
        r += 1
        f_row(DASH, r, "Median · Fastest 10%", f_num1(array.get(res, S_MED)) + " · " + f_num1(array.get(res, S_P10)), C_AMBD, C_AMBP, C_BG2)
        r += 1
        f_row(DASH, r, "Average · Slowest 10%", f_num1(array.get(res, S_AVGD)) + " · " + f_num1(array.get(res, S_P90)), C_AMBD, C_AMBP, C_BG1)
        r += 1
        f_row(DASH, r, "Avg End · Net P/L", f_money0(avgFin) + " · " + f_kilo(avgFin - start), C_AMBD, avgFin >= start ? C_GRN : C_RED, C_BG2)
        r += 1

        f_sec(DASH, r, "🧠 LOSS-STREAK ANCHOR", "expect it", C_AMBD)
        r += 1
        f_row(DASH, r, "Typical · Worst streak", f_num1(mStrk) + " · " + f_num1(wStrk) + " losses", C_AMBD, C_AMBP, C_BG1)
        r += 1
        f_row(DASH, r, "Worst streak costs", f_pct(strkCost) + " of account", C_AMBD, strkCost > i_ddMax ? C_RED : strkCost > i_ddDay ? C_AMBB : C_GRN, C_BG2)
        r += 1

        f_sec(DASH, r, "📊 DAY EXTREMES", "per day", C_AMBD)
        r += 1
        f_row(DASH, r, "Avg Up · Avg Down day", f_kilo(avgWD) + " · " + f_kilo(avgLD), C_AMBD, C_AMBP, C_BG1)
        r += 1
        float glr = not na(avgWD) and not na(avgLD) and avgLD != 0 ? avgWD / math.abs(avgLD) : na
        f_row(DASH, r, "Gain / Loss Ratio", na(glr) ? "—" : f_num1(glr), C_AMBD, na(glr) ? C_AMBP : glr >= 1 ? C_GRN : C_RED, C_BG2)
        r += 1
        f_row(DASH, r, "Best · Worst day", f_kilo(bestD) + " · " + f_kilo(worstD), C_AMBD, C_AMBP, C_BG1)
        r += 1

        f_sec(DASH, r, "🛡 SETUP", f_money0(start), C_AMB)
        r += 1
        f_row(DASH, r, "Target · Daily · Max", f_money0(tgtMain) + " · -" + f_money0(dailyAmt) + " · -" + f_money0(maxDDAmt), C_AMBD, C_AMBP, C_BG2)
        r += 1
        f_row(DASH, r, "DD Type · Days", (ddTypeI == 0 ? "Static" : ddTypeI == 1 ? "Trailing" : "Trail→Lock") + " · " + str.tostring(i_minDay) + "-" + (i_maxDay == 0 ? "∞" : str.tostring(i_maxDay)), C_AMBD, C_AMBP, C_BG1)
        r += 1
        f_row(DASH, r, "Win · R:R · Risk", f_pct(i_win) + " · 1:" + f_num1(i_rr) + " · " + (riskModeI == 2 ? f_money0(i_riskF) : f_pct(i_riskP)), C_AMBD, C_AMBP, C_BG2)
        r += 1
        f_cell(DASH, 0, r, "Estimates from your inputs — not a guarantee.", C_GRY, C_BG0, text.align_left)
        f_cell(DASH, 1, r, "", C_GRY, C_BG0, text.align_right)

    if i_showDshB
        int q = 0
        f_sec(DSHB, q, "🧮 EDGE ANALYTICS", edgePos ? "POSITIVE" : "NEGATIVE", eCol)
        q += 1
        f_row(DSHB, q, "Expectancy / trade", f_num1(expR) + "R  (" + f_pct2(expPct) + ")", C_AMBD, eCol, C_BG1)
        q += 1
        f_row(DSHB, q, "Profit Factor", na(pf) ? "—" : f_num1(pf), C_AMBD, na(pf) ? C_AMBP : pf >= 1.5 ? C_GRN : pf >= 1.0 ? C_AMBB : C_RED, C_BG2)
        q += 1
        f_row(DSHB, q, "Break-even WR · Margin", f_pct(beWR) + " · " + f_pct(effWR * 100 - nz(beWR)), C_AMBD, (effWR * 100 - nz(beWR)) > 0 ? C_GRN : C_RED, C_BG1)
        q += 1
        string kv = na(kelly) or kelly <= 0 ? "no edge" : i_riskP > kelly ? "OVER-BET" : i_riskP > kelly * 0.5 ? "aggressive" : "conservative"
        color kvc = na(kelly) or kelly <= 0 ? C_RED : i_riskP > kelly ? C_RED : i_riskP > kelly * 0.5 ? C_AMBB : C_GRN
        f_row(DSHB, q, "Kelly Risk · You", (na(kelly) ? "—" : f_pct(kelly)) + " · " + kv, C_AMBD, kvc, C_BG2)
        q += 1
        f_row(DSHB, q, "Trades to Target · Avg", (na(tradesToTgt) ? "∞" : str.tostring(tradesToTgt, "#,##0")) + " · " + f_num1(avgTr), C_AMBD, na(tradesToTgt) ? C_RED : C_AMBP, C_BG1)
        q += 1

        f_sec(DSHB, q, "⚙ EXECUTION REALITY", i_exec >= 100 and i_spreadR <= 0 ? "IDEALISED" : "MODELLED", i_exec >= 100 and i_spreadR <= 0 ? C_ORG : C_GRN)
        q += 1
        f_row(DSHB, q, "Backtest WR → Real WR", f_pct(i_win) + " → " + f_pct(effWR * 100), C_AMBD, effWR * 100 >= nz(beWR) ? C_GRN : C_RED, C_BG2)
        q += 1
        f_row(DSHB, q, "Edge lost to costs/exec", f_num1(edgeDecay) + "R  (" + f_num1(expRaw) + "R → " + f_num1(expR) + "R)", C_AMBD, edgeDecay > 0.15 ? C_RED : edgeDecay > 0.05 ? C_AMBB : C_GRN, C_BG1)
        q += 1
        f_row(DSHB, q, "Avg Max DD per run", f_pct(avgDD), C_AMBD, avgDD > i_ddMax * 0.8 ? C_RED : C_AMBP, C_BG2)
        q += 1

        if i_showEco
            float p = passPct / 100.0
            float attempts = p > 0.001 ? 1.0 / p : na
            float totalFees = na(attempts) ? na : i_fee * attempts
            float grossPay = start * i_payPct / 100.0 * i_payN * i_split / 100.0
            float refundAmt = i_refund ? i_fee : 0.0
            float netEV = na(totalFees) ? na : grossPay + refundAmt - totalFees
            float roi = na(netEV) or na(totalFees) or totalFees <= 0 ? na : netEV / totalFees * 100.0
            f_sec(DSHB, q, "💰 CHALLENGE ECONOMICS", na(netEV) ? "—" : netEV > 0 ? "+EV" : "−EV", na(netEV) ? C_AMBP : netEV > 0 ? C_GRN : C_RED)
            q += 1
            f_row(DSHB, q, "Expected attempts to pass", na(attempts) ? "∞" : f_num1(attempts), C_AMBD, na(attempts) ? C_RED : attempts > 3 ? C_RED : attempts > 1.7 ? C_AMBB : C_GRN, C_BG1)
            q += 1
            f_row(DSHB, q, "Expected fees spent", na(totalFees) ? "—" : f_money0(totalFees), C_AMBD, C_AMBP, C_BG2)
            q += 1
            f_row(DSHB, q, "Expected payouts (your split)", f_money0(grossPay), C_AMBD, C_AMBP, C_BG1)
            q += 1
            f_row(DSHB, q, "NET EXPECTED VALUE", na(netEV) ? "—" : f_kilo(netEV), C_AMBB, na(netEV) ? C_AMBP : netEV > 0 ? C_GRN : C_RED, C_BG2)
            q += 1
            f_row(DSHB, q, "ROI on fees", na(roi) ? "—" : f_pct(roi), C_AMBD, na(roi) ? C_AMBP : roi > 0 ? C_GRN : C_RED, C_BG1)
            q += 1

        if i_showChk
            bool c1 = edgePos
            bool c2 = i_sample >= 100
            bool c3 = not na(kelly) and kelly > 0 and i_riskP <= kelly * 0.5
            bool c4 = passPct >= 50
            bool c5 = strkCost < i_ddMax
            bool c6 = i_spreadR > 0
            bool c7 = i_exec >= 85
            bool c8 = avgDD < i_ddMax
            int nOk = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) + (c5 ? 1 : 0) + (c6 ? 1 : 0) + (c7 ? 1 : 0) + (c8 ? 1 : 0)
            f_sec(DSHB, q, "✅ READINESS CHECKLIST", str.tostring(nOk) + " / 8", nOk >= 7 ? C_GRN : nOk >= 5 ? C_AMBB : C_RED)
            q += 1
            f_row(DSHB, q, f_tick(c1) + " Edge is positive after costs", f_num1(expR) + "R", c1 ? C_GRN : C_RED, C_AMBD, C_BG2)
            q += 1
            f_row(DSHB, q, f_tick(c2) + " Sample ≥ 100 trades", str.tostring(i_sample), c2 ? C_GRN : C_RED, C_AMBD, C_BG1)
            q += 1
            f_row(DSHB, q, f_tick(c3) + " Risk ≤ half-Kelly", f_pct(i_riskP), c3 ? C_GRN : C_RED, C_AMBD, C_BG2)
            q += 1
            f_row(DSHB, q, f_tick(c4) + " Pass probability ≥ 50%", f_pct(passPct), c4 ? C_GRN : C_RED, C_AMBD, C_BG1)
            q += 1
            f_row(DSHB, q, f_tick(c5) + " Worst streak survivable", f_pct(strkCost), c5 ? C_GRN : C_RED, C_AMBD, C_BG2)
            q += 1
            f_row(DSHB, q, f_tick(c6) + " Spread/slippage modelled", f_num1(i_spreadR) + "R", c6 ? C_GRN : C_RED, C_AMBD, C_BG1)
            q += 1
            f_row(DSHB, q, f_tick(c7) + " Execution rate ≥ 85%", f_pct(i_exec), c7 ? C_GRN : C_RED, C_AMBD, C_BG2)
            q += 1
            f_row(DSHB, q, f_tick(c8) + " Avg DD inside limit", f_pct(avgDD), c8 ? C_GRN : C_RED, C_AMBD, C_BG1)
            q += 1
if barstate.islast and i_showCal
    int pIdx = math.min(i_calRun - 1, NPLOT - 1)
    int dcn  = array.get(gDayC, pIdx)
    int oc   = array.get(gOut, pIdx)
    string ocTxt = oc == 0 ? "PASSED" : oc == 1 ? "DAILY-LOSS FAIL" : oc == 2 ? "MAX-DD FAIL" : oc == 4 ? "CONSISTENCY FAIL" : "TIMED OUT"
    f_cell(TCAL, 0, 0, "📅 PROFIT CALENDAR · Run " + str.tostring(i_calRun), C_AMBB, C_HDR, text.align_left)
    for c = 1 to 4
        f_cell(TCAL, c, 0, "", C_AMBB, C_HDR, text.align_center)
    f_cell(TCAL, 5, 0, ocTxt, f_pcol(oc), C_HDR, text.align_right)
    float mx = 1.0
    if dcn > 0
        for d = 0 to math.min(dcn, 30) - 1
            mx := math.max(mx, math.abs(nz(matrix.get(gDay, pIdx, d))))
    for slot = 0 to 29
        int rr2 = slot / 6 + 1
        int cc2 = slot % 6
        if slot < dcn
            float pl = nz(matrix.get(gDay, pIdx, slot))
            float inten = math.min(math.abs(pl) / mx, 1.0)
            color bg = pl > 0 ? color.new(#1F8F52, int(80 - 55 * inten)) : pl < 0 ? color.new(#B5281F, int(80 - 55 * inten)) : C_BG1
            color tc = pl > 0 ? C_GRN : pl < 0 ? C_RED : C_GRY
            f_cell(TCAL, cc2, rr2, "D" + str.tostring(slot + 1) + "\n" + f_kilo(pl), tc, bg, text.align_center)
        else
            f_cell(TCAL, cc2, rr2, "", C_GRY, C_BG0, text.align_center)

if barstate.islast and i_showCmp
    f_cell(TCMP, 0, 0, "⚖ RULE PROFILE", C_AMBB, C_HDR, text.align_left)
    f_cell(TCMP, 1, 0, "TGT",   C_AMBB, C_HDR, text.align_center)
    f_cell(TCMP, 2, 0, "DAILY", C_AMBB, C_HDR, text.align_center)
    f_cell(TCMP, 3, 0, "MAX",   C_AMBB, C_HDR, text.align_center)
    f_cell(TCMP, 4, 0, "PASS%", C_AMBB, C_HDR, text.align_center)
    array<string> pfN = array.from("Your Rules", "8 / 5 / 10 Static", "10 / 5 / 10 Static", "6 / 4 / 8 Static", "10 / 5 / 6 Trail→Lock", "9 / 5 / 10 Trailing")
    array<float>  pfT = array.from(i_tgt1, 8.0, 10.0, 6.0, 10.0, 9.0)
    array<float>  pfD = array.from(i_ddDay, 5.0, 5.0, 4.0, 5.0, 5.0)
    array<float>  pfM = array.from(i_ddMax, 10.0, 10.0, 8.0, 6.0, 10.0)
    array<int>    pfY = array.from(ddTypeI, 0, 0, 0, 2, 1)
    for k = 0 to 5
        float tA = start * array.get(pfT, k) / 100.0
        float dA = start * array.get(pfD, k) / 100.0
        float mA = start * array.get(pfM, k) / 100.0
        rk = f_run(i_seed + 31 * k, i_cmpSims, tA, dA, mA, array.get(pfY, k), winP, i_rr)
        float pp = array.get(rk, S_PASS) / i_cmpSims * 100.0
        bool isYou = k == 0
        color rowBg = isYou ? C_BG2 : (k % 2 == 0 ? C_BG1 : C_BG0)
        color ppc = pp >= 70 ? C_GRN : pp >= 45 ? C_AMBB : C_RED
        f_cell(TCMP, 0, k + 1, (isYou ? "▶ " : "") + array.get(pfN, k), isYou ? C_YEL : C_AMBP, rowBg, text.align_left)
        f_cell(TCMP, 1, k + 1, f_pct(array.get(pfT, k)), C_AMBD, rowBg, text.align_center)
        f_cell(TCMP, 2, k + 1, f_pct(array.get(pfD, k)), C_AMBD, rowBg, text.align_center)
        f_cell(TCMP, 3, k + 1, f_pct(array.get(pfM, k)), C_AMBD, rowBg, text.align_center)
        f_cell(TCMP, 4, k + 1, f_pct(pp), ppc, rowBg, text.align_center)

if barstate.islast and i_showGrid
    f_cell(TGRD, 0, 0, "WIN% \\ R:R", C_AMBB, C_HDR, text.align_center)
    array<float> rrMults = array.from(0.6, 0.8, 1.0, 1.2, 1.4)
    for c = 0 to 4
        float rrv = i_rr * array.get(rrMults, c)
        f_cell(TGRD, c + 1, 0, "1:" + str.tostring(rrv, "#.0"), C_AMBB, C_HDR, text.align_center)
    for rIdx = 0 to 4
        float wv = math.min(math.max(i_win + (rIdx - 2) * 4.0, 1.0), 99.0)
        f_cell(TGRD, 0, rIdx + 1, str.tostring(wv, "#.0") + "%", C_AMBB, C_BG2, text.align_center)
        for c = 0 to 4
            float rrv = i_rr * array.get(rrMults, c)
            gres = f_run(i_seed + rIdx * 7 + c, i_gridSims, f_targetFor(phaseI == 2 ? 0 : phaseI), dailyAmt, maxDDAmt, ddTypeI, wv / 100.0, rrv)
            float gpct = array.get(gres, S_PASS) / i_gridSims * 100.0
            bool isBase = rIdx == 2 and c == 2
            color gbg = gpct >= 70 ? C_GRND : gpct >= 50 ? color.new(#7A5A10, 0) : gpct >= 30 ? color.new(#5A3A0A, 0) : C_REDD
            color gtc = isBase ? C_YEL : C_AMBP
            f_cell(TGRD, c + 1, rIdx + 1, (isBase ? "▶" : "") + str.tostring(gpct, "#") + "%", gtc, gbg, text.align_center)

alertcondition(edgePos and expR > 0, "Positive Edge", "Strong Challenge Sim: trader edge is positive after costs (expectancy > 0R).")
alertcondition(not edgePos, "Negative Edge", "Strong Challenge Sim: trader edge is NEGATIVE after costs — the challenge math does not work.")
````
