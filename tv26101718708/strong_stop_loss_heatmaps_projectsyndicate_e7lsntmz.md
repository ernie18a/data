# Strong Stop Loss Heatmaps | ProjectSyndicate

- url: https://www.tradingview.com/script/E7lsNTMz-Strong-Stop-Loss-Heatmaps-ProjectSyndicate/
- type: indicator
- pine_id: PUB;d0c03039d5f147a68e44dc9d38c5836c
- version: 1.0

## Description

◾Strong Stop Loss Heatmaps answers the two questions that decide most of a system's results and that most traders set by habit: where should the stop go, and where should the target go. It takes the entry signals on your chart and replays every bar through 100 stop × target combinations at the same time, each one running its own one-position-at-a-time backtest, and lays the results out as four large heatmaps, an excursion study and a stop desk, all on one screen in a compact Bloomberg amber terminal.

◾Net Return, Profit Factor, Max Drawdown and a Robust Plateau are each mapped as a 10×10 grid of stop width (ATR multiples) against target size (R:R), your own setting is lit up as a white cell, the best cell burns gold, and the robust pick is marked with a diamond. The whole tool runs on one idea: a stop is a bet on how much noise the trade must survive, and a target is a bet on how far the move usually goes. Guess either one and you are trading a different system from the one you backtested. Map both and the trade-off becomes a number.

◾This is a stop-placement and exit-optimisation terminal, not a signal generator. It tells you which stop widths get hunted, which ones cut your winners before they pay, how much of your edge the spread eats at tight stops, whether the best-looking cell is a stable plateau or a lucky spike, and where the honest sweet spot sits for the entry you actually use, on any symbol, any timeframe.

🟢🔴 Summary how to use this, more details below, read entire guide. Two clean reads: find the plateau, then check the hunt. Pick the entry model you trade, set the cost to your real spread, and look at ④ Robust Plateau first, not ① Net Return. The diamond is the stop and target whose whole neighbourhood performs, which is what survives out of sample. Then read ⑤ Stop-Hunt Profile: if your stop row cuts more than a quarter of the eventual winners, your stop is inside the noise and the market is paying you to widen it. The Stop Desk puts your setting beside the best, the robust and the MAE-derived stop so you can see what you are giving up. Runs on any chart and any timeframe.

⚠️ YOUR ENTRY vs THE BUILT-IN MODELS — The heatmaps measure exits, so they need an entry to work from. Twelve built-in models are included (Supertrend flip by default) and all 100 combinations trade the identical signals, which isolates the effect of the stop and the target. To test your own system, add your indicator to the chart, pick its plot in the Custom Indicator group and switch Entry Signal to Custom Indicator. The built-in models exist to give the terminal an honest signal stream out of the box; they are not a recommendation to trade them.

🧱 The Engine — honest fills, every trade counted — Each cell is a complete backtest, not an estimate. Stops run from 0.75× to 3.00× ATR in 0.25 steps (rows, widest at the top) and targets from 1.00R to 3.25R in 0.25 steps (columns); both start points and steps are adjustable. The fill model is deliberately pessimistic:
▪️ Entry at the NEXT bar's open after a signal, never at the signal bar's close.
▪️ Stop checked before target inside the same bar. A bar that touches both is booked as a loss.
▪️ A gap through the stop or the target fills at the open, not at the level.
▪️ A time stop (50 bars by default) closes any trade still open at that bar's close.
▪️ A round-trip cost in % of price (spread + commission + slippage) is charged on every trade and converted to R, so a tight stop pays a far bigger share of it than a wide one. The Stop Desk prints the cost in R at the tightest and the widest stop side by side.
▪️ Return and drawdown compound at a fixed risk per trade (1% by default); the account can never go below zero.
Cells with fewer trades than the minimum (20 by default) show a dot and are excluded from every pick, so a thin sample can never win.

📐 Four Heatmaps · One Screen — Each map is a 10×10 grid with your stop row and target column headers lit amber, your cell burning white, and every cell carrying a hover tooltip with trades, win rate, profit factor, expectancy, cost per trade, return, max drawdown, time-stop share, average hold and longest losing streak.

◆ ① NET RETURN % — compounded return of the whole test at your risk per trade. Diverging heat: red is a losing cell, dark is flat, amber is the top of the map. Gold ★ marks the single best cell. Read the shape, not the peak: a vertical amber band means the entry wants a certain stop width whatever the target; a horizontal band means the move usually runs a certain distance.
◆ ② PROFIT FACTOR — gross wins over gross losses, net of costs. Red below 1.0, amber above 2.0. Tight-stop rows often go red here even when the return map still looks fine, because the cost in R is doing the damage.
◆ ③ MAX DRAWDOWN % — deepest peak-to-trough drawdown of each cell's equity curve. Amber sits at your drawdown tolerance (20% by default); the scale runs red at twice it. The bottom-left corner, tight stop and small target, is where drawdown lives.
◆ ④ ROBUST PLATEAU — the overfitting filter. Each cell is the average of Return ÷ Max Drawdown across itself and its eight neighbours (at least six must be valid). A lucky single cell disappears here; a true plateau survives. The ◆ diamond marks the robust pick, and that is the setting the Verdict line recommends.

Every map carries a KEY bar along the bottom so the colour scale reads directly in percent.

🎯 The Stop-Hunt Profile — MAE / MFE study — Separately from the backtests, every signal is followed for the full time-stop horizon with no stop and no target, recording its maximum adverse excursion (the worst heat it took) and maximum favourable excursion (the best it reached), both in ATR units. A signal counts as an eventual winner if it runs at least 2.0× ATR in its favour (adjustable), and its MAE before that run is stored. The card shows, for every stop width on the grid:
▪️ STOP TOUCHED % — how often price reached that distance against the entry within the horizon. This is the hunt rate.
▪️ WINNERS CUT % — what share of the eventual winners would have been stopped out at that width before they paid. Turns red above 25%.
▪️ MAE STOP — the 90th percentile of the winners' adverse excursion (adjustable): the stop just beyond the heat most winners never exceeded, lit gold on the ladder.
▪️ E-RATIO — average MFE divided by average MAE for the entry. Above 1.0 the entry has edge before any exit rule is applied; below it, no stop will save it.

🏷️ The Stop Desk — One panel compares six settings with the same columns: stop multiple, R:R, trades, win rate, profit factor, expectancy in R, max drawdown and net return.
▪️ ★ BEST RET — the top cell of the return map.
▪️ ◆ ROBUST — the plateau pick.
▪️ ◉ YOURS — your stop and target as entered.
▪️ ▲ BEST PF — the highest profit factor.
▪️ ▼ LOW DD — the smallest drawdown among profitable cells.
▪️ ✚ MAE STOP — the best target on the MAE-derived stop row.
Beneath them, four diagnostic lines:
▪️ OVERFIT — the best cell's return against the average of its eight neighbours, and how isolated it is in percent. Above 40% isolation the line turns red: the peak is a spike, not a setting.
▪️ COST — cost per trade in R at the tightest versus the widest stop.
▪️ YOUR STOP — the share of eventual winners your current stop cuts, with the MAE stop beside it for comparison. Red above 25%.
▪️ VERDICT — the robust stop and target in one line, or NO EDGE if even the plateau loses money.

🔁 Twelve Entry Models + Custom — Supertrend flip, Donchian breakout, EMA cross, MACD cross, RSI reversion, Bollinger reversion, Bollinger breakout, Stochastic cross, Parabolic SAR flip, Ichimoku Tenkan/Kijun cross, DMI/ADX cross and CCI reversion, each with its own settings, plus Long & Short, Long Only or Short Only and an optional EMA trend filter that applies to every model. The Custom Indicator group reads any script on the chart through two plot inputs and four rules: A crosses a level (oscillators and +1/−1 signal plots), price crosses A (moving averages, VWAP, bands), A crosses B (two lines), or A as the long signal and B as the short signal (arrow-style outputs), with an invert switch.

📈 On the Price Chart — Your own setting is drawn live: entry triangles, W / L markers on every closed trade, and the active stop and target as lines, so you can see the cell you are sitting in actually trade.

📋 Bloomberg Amber Terminal — Black terminal background, amber headline strips, bold monospaced figures, diverging heat from red through dark to amber for return and profit factor, sequential heat from brown through orange to red for drawdown, gold for the best cell, white for your position, and gutters that match your chart background automatically. Three maps sit across the top of the chart and the plateau, the stop-hunt profile and the stop desk across the bottom, with price still visible in between. Every table is rebuilt on every update so nothing drifts or clips on a live market, on a laptop or an ultrawide.

🔔 Native Alerts —
▪️ Your Setting: Entry — a trade opened on your stop and target.
▪️ Your Setting: Stop Hit — your setting closed at a loss.
▪️ Your Setting: Target / Win — your setting closed at a profit.

🔧 Fully Customizable — Entry signal, direction, trend filter and length; every model's parameters; ATR length, time stop, round-trip cost, risk per trade, backtest window and minimum trades per cell; stop-grid start and step, target-grid start and step, your stop and target, drawdown tolerance; winner threshold and MAE percentile for the stop-hunt study; custom-indicator plots, rule, level and invert; each card on or off; cell width, label column width, row height, cell and title text size, top offset (keeps the symbol legend clear), bottom offset, chart markers and gutter colour.

🎯 Why this is different — Most stop-loss tools give you one rule (a fixed ATR multiple, a swing low) with no evidence that it suits the entry, or an optimiser that hands you the single best cell and lets you overfit to it. This one backtests 100 stop × target combinations on your own signals with pessimistic fills and real costs, maps four metrics at once, filters the result through a neighbourhood plateau so a lucky spike cannot win, measures how often each stop width gets hunted and how many winners it would cut, derives a stop from the winners' own excursion, and puts your setting next to all of it. The chart does the filtering — you see instantly whether your stop is too tight, your target too greedy, or your best cell too lonely to trust.

🚀 Apply on any chart and any timeframe. The maps are computed from the bars you are looking at, so the answer belongs to that symbol and that timeframe. Lower the backtest window on very fast charts if your platform reports a calculation timeout.

🎯 How To Use It — Two Approaches

Everything hinges on the ◆ robust pick and the WINNERS CUT column. A gold cell with red neighbours, or a stop row that cuts a third of your winners, is where the real information sits.

◾ 1 FIND THE PLATEAU — choose a stop and target you can trust
This is the core read. The best cell is almost always too good; the plateau is what you will actually get.
▪️ Setup: select the entry model you trade (or your own indicator), set the direction and trend filter, enter your real round-trip cost, and enter your current stop and target so your cell shows white.
▪️ Read: find the ◆ diamond on ④ Robust Plateau and the ★ on ① Net Return. If they sit in the same region, the edge is stable there. If the ★ sits alone with dark or red around it, read the OVERFIT line; a high isolation figure means that cell is noise.
▪️ Action: move your stop and target toward the diamond, then confirm on ② that the profit factor there is above 1.5 and on ③ that the drawdown is inside your tolerance.
▪️ Never: pick the single best cell. The plateau map exists because the best cell does not repeat.

⚖️ The cleanest version: ★ and ◆ in the same amber region, OVERFIT under 25% isolated, your white cell on or next to the diamond, and your drawdown cell calm brown. That is a sized, repeatable exit.

◾ 2 CHECK THE HUNT — make sure the stop is outside the noise
The mirror case, and the one that explains most "right idea, stopped out anyway" trades.
▪️ Setup: set the winner threshold to the move you actually need (2× ATR by default) and the MAE percentile to how many winners you are willing to lose (90% by default).
▪️ Read: find your stop row on ⑤. STOP TOUCHED tells you how often the market reaches that distance; WINNERS CUT tells you how many of the trades that eventually paid would have died there first. Compare it with the gold MAE STOP row.
▪️ Action: if your row's WINNERS CUT is red, widen the stop toward the MAE stop and shrink size to keep risk constant. Then check the COST line: if the tight stop is paying several times the cost in R of the wide one, that is a second reason to widen.
▪️ Then: read the E-RATIO. Below 1.0 the entry itself has no edge over the horizon, and the task is a better entry, not a better stop.

⚖️ Read the Stop-Hunt Profile before you tighten anything. A 1.0× ATR stop that touches 80% of the time and cuts half the winners is not tight risk management; it is a donation.
Rule of thumb: ⭐ ★ and ◆ together, OVERFIT low → the exit is real, trade it. ⭐ ★ isolated, OVERFIT red → ignore the peak, trade the diamond. ⭐ WINNERS CUT red on your row → widen the stop to the MAE stop and size down. ⭐ E-RATIO under 1.0 or VERDICT reads NO EDGE → the entry is the problem, no stop fixes it.

⚠️ IMPORTANT NOTICE: Strong Stop Loss Heatmaps [Bloomberg] is a research and exit-optimisation tool. Every figure is a historical backtest on the bars currently loaded, under one entry model, pessimistic same-bar fills, a fixed cost assumption and fixed-fraction sizing. Real trading adds variable slippage, partial fills, session gaps, changing volatility and regime shifts, so live results will differ from the maps and can be worse. Testing 100 combinations on one sample is itself a form of data mining; the Robust Plateau and OVERFIT line reduce that risk but do not remove it, and a setting should be confirmed on other symbols, timeframes and periods before it is traded. The built-in entry models are calibration models, not recommended strategies. This is decision support, not a trade trigger or financial advice. Always combine it with your own strategy, testing and risk management. Past results do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Stop Loss Heatmaps", overlay = true)

// ───────────────────────────── INPUTS ─────────────────────────────
G_ENT = "═══ ENTRY MODEL ═══"
i_model  = input.string("Supertrend Flip", "Entry Signal", options = ["Supertrend Flip", "Donchian Breakout", "EMA Cross", "MACD Cross", "RSI Reversion", "Bollinger Reversion", "Bollinger Breakout", "Stochastic Cross", "Parabolic SAR Flip", "Ichimoku TK Cross", "DMI / ADX Cross", "CCI Reversion", "Custom Indicator"], group = G_ENT, tooltip = "The same signals feed all 100 stop × target combinations, so the maps isolate the effect of the exits. 'Custom Indicator' reads any script on this chart (see the CUSTOM INDICATOR group).")
i_dir    = input.string("Long & Short", "Direction", options = ["Long & Short", "Long Only", "Short Only"], group = G_ENT)
i_useTr  = input.bool(true, "Trend Filter (EMA)", inline = "tr", group = G_ENT, tooltip = "Longs only above the EMA, shorts only below it. Applies to every model, including Custom.")
i_emaLen = input.int(200, "", minval = 5, inline = "tr", group = G_ENT)

G_MS = "═══ MODEL SETTINGS ═══"
i_stP    = input.int(10, "Supertrend: ATR Period", minval = 1, inline = "st", group = G_MS)
i_stF    = input.float(3.0, "Factor", minval = 0.1, step = 0.1, inline = "st", group = G_MS)
i_dLen   = input.int(20, "Donchian: Length", minval = 2, group = G_MS)
i_fast   = input.int(20, "EMA Cross: Fast", minval = 2, inline = "ec", group = G_MS)
i_slow   = input.int(50, "Slow", minval = 3, inline = "ec", group = G_MS)
i_mFast  = input.int(12, "MACD: Fast", minval = 2, inline = "mc", group = G_MS)
i_mSlow  = input.int(26, "Slow", minval = 3, inline = "mc", group = G_MS)
i_mSig   = input.int(9, "Signal", minval = 1, inline = "mc", group = G_MS)
i_rsiLen = input.int(14, "RSI: Length", minval = 2, inline = "rs", group = G_MS)
i_rsiLo  = input.float(30, "Buy ↑", minval = 1, maxval = 50, inline = "rs", group = G_MS)
i_rsiHi  = input.float(70, "Sell ↓", minval = 50, maxval = 99, inline = "rs", group = G_MS)
i_bbLen  = input.int(20, "Bollinger: Length", minval = 2, inline = "bb", group = G_MS)
i_bbMul  = input.float(2.0, "StdDev", minval = 0.1, step = 0.1, inline = "bb", group = G_MS)
i_stoK   = input.int(14, "Stochastic: %K", minval = 1, inline = "so", group = G_MS)
i_stoS   = input.int(3, "Smooth", minval = 1, inline = "so", group = G_MS)
i_stoD   = input.int(3, "%D", minval = 1, inline = "so", group = G_MS)
i_stoLo  = input.float(20, "Stochastic: Buy below", minval = 1, maxval = 50, inline = "sz", group = G_MS)
i_stoHi  = input.float(80, "Sell above", minval = 50, maxval = 99, inline = "sz", group = G_MS)
i_sarS   = input.float(0.02, "Parabolic SAR: Start", minval = 0.001, step = 0.005, inline = "sr", group = G_MS)
i_sarI   = input.float(0.02, "Step", minval = 0.001, step = 0.005, inline = "sr", group = G_MS)
i_sarM   = input.float(0.2, "Max", minval = 0.01, step = 0.01, inline = "sr", group = G_MS)
i_tkT    = input.int(9, "Ichimoku: Tenkan", minval = 1, inline = "ik", group = G_MS)
i_tkK    = input.int(26, "Kijun", minval = 2, inline = "ik", group = G_MS)
i_dmiLen = input.int(14, "DMI: Length", minval = 2, inline = "dm", group = G_MS)
i_adxMin = input.float(20, "Min ADX", minval = 0, maxval = 100, inline = "dm", group = G_MS)
i_cciLen = input.int(20, "CCI: Length", minval = 2, inline = "cc", group = G_MS)
i_cciLvl = input.float(100, "± Level", minval = 10, step = 10, inline = "cc", group = G_MS)

G_CU = "═══ CUSTOM INDICATOR (any script on this chart) ═══"
i_cA     = input.source(close, "Plot A", group = G_CU, tooltip = "Add your indicator to the chart first, then pick one of its plots here (the dropdown lists every plot of every script on the chart). Select Entry Signal = Custom Indicator.")
i_cB     = input.source(close, "Plot B", group = G_CU, tooltip = "Second plot for 'A Crosses B' and for the separate long / short signal mode.")
i_cMode  = input.string("A Crosses Level", "Rule", options = ["A Crosses Level", "Price Crosses A", "A Crosses B", "A = Long Signal · B = Short Signal"], group = G_CU, tooltip = "A Crosses Level: oscillators and +1 / −1 signal plots (long when A crosses above the level, short when it crosses below).\nPrice Crosses A: line indicators such as a moving average, VWAP or a band.\nA Crosses B: two lines, e.g. fast / slow or main / signal.\nSeparate signals: A fires a long and B fires a short whenever the plot turns non-zero (works with plotshape / arrow signal series).")
i_cLvl   = input.float(0.0, "Level", step = 0.5, group = G_CU)
i_cInv   = input.bool(false, "Invert (swap long / short)", group = G_CU)

G_EX = "═══ EXITS · COSTS · WINDOW ═══"
i_atrLen = input.int(14, "ATR Length", minval = 2, group = G_EX)
i_maxBar = input.int(50, "Time Stop (bars)", minval = 2, maxval = 1000, group = G_EX, tooltip = "Trades still open after this many bars close at the bar's close. Also the horizon of the excursion study.")
i_cost   = input.float(0.03, "Round-Trip Cost (% of price)", minval = 0, maxval = 2, step = 0.005, group = G_EX, tooltip = "Spread + commission + slippage. Charged in R, so a tight stop pays a bigger share of it than a wide one.")
i_risk   = input.float(1.0, "Risk per Trade % (for Return / DD)", minval = 0.05, maxval = 10, step = 0.05, group = G_EX)
i_win    = input.int(5000, "Backtest Window (bars, 0 = all)", minval = 0, group = G_EX, tooltip = "Only the last N bars are tested. Lower it if TradingView reports a calculation timeout.")
i_minTr  = input.int(20, "Min Trades per Cell", minval = 3, group = G_EX, tooltip = "Cells with fewer closed trades show a dot and are excluded from the best / robust picks.")

G_GR = "═══ GRID & YOUR SETTING ═══"
i_slSt   = input.float(0.75, "Stop Grid: Start (ATR ×)", minval = 0.1, step = 0.05, inline = "sg", group = G_GR)
i_slStep = input.float(0.25, "Step", minval = 0.05, step = 0.05, inline = "sg", group = G_GR)
i_rrSt   = input.float(1.0, "Target Grid: Start (R:R)", minval = 0.1, step = 0.05, inline = "rg", group = G_GR)
i_rrStep = input.float(0.25, "Step", minval = 0.05, step = 0.05, inline = "rg", group = G_GR)
i_mySL   = input.float(1.5, "Your Stop (ATR ×)", minval = 0.1, step = 0.05, group = G_GR, tooltip = "Marked white (◉) on every map; snaps to the nearest grid cell.")
i_myRR   = input.float(2.0, "Your Target (R:R)", minval = 0.1, step = 0.05, group = G_GR)
i_ddTol  = input.float(20.0, "Max-DD Tolerance %", minval = 1, maxval = 90, step = 1, group = G_GR, tooltip = "Amber mid-point of the drawdown map.")

G_MAE = "═══ STOP-HUNT STUDY (MAE / MFE) ═══"
i_winTh  = input.float(2.0, "Winner = Price Runs (ATR ×)", minval = 0.25, step = 0.25, group = G_MAE, tooltip = "A signal counts as an eventual winner if price moves this far in its favour within the time stop. Its MAE is the heat it took BEFORE getting there.")
i_maePct = input.float(90, "MAE Stop = Winners' MAE Percentile", minval = 50, maxval = 99, step = 1, group = G_MAE, tooltip = "Sweeney's rule: put the stop just beyond the adverse excursion that most eventual winners never exceed.")

G_UI = "═══ DISPLAY ═══"
i_c1     = input.bool(true, "① Net Return", inline = "c1", group = G_UI)
i_c2     = input.bool(true, "② Profit Factor", inline = "c1", group = G_UI)
i_c3     = input.bool(true, "③ Max Drawdown", inline = "c1", group = G_UI)
i_c4     = input.bool(true, "④ Robust Plateau", inline = "c2", group = G_UI)
i_c5     = input.bool(true, "⑤ Stop-Hunt", inline = "c2", group = G_UI)
i_c6     = input.bool(true, "⑥ Stop Desk", inline = "c2", group = G_UI)
i_cw     = input.float(2.8, "Cell Width %", minval = 1.0, maxval = 5.0, step = 0.1, group = G_UI, tooltip = "Each card is 1 label column + 10 cells. 2.8% → each card ≈ 31% of the chart width.")
i_cw0    = input.float(3.4, "Label Column Width %", minval = 1.0, maxval = 6.0, step = 0.1, group = G_UI)
i_h      = input.float(2.5, "Row Height %", minval = 1.0, maxval = 5.0, step = 0.1, group = G_UI)
i_txt    = input.int(10, "Cell Text Size", minval = 6, maxval = 20, group = G_UI)
i_txtT   = input.int(11, "Title Text Size", minval = 6, maxval = 20, group = G_UI)
i_topOff = input.float(10.0, "Top Offset % (clears symbol legend)", minval = 0, maxval = 30, step = 0.5, group = G_UI)
i_botOff = input.float(3.0, "Bottom Offset % (clears TV logo)", minval = 0, maxval = 15, step = 0.5, group = G_UI)
i_showLv = input.bool(true, "Show Your Active Stop / Target", group = G_UI)
i_showMk = input.bool(true, "Show Your Entries / Exits", group = G_UI)
i_gutA   = input.bool(true, "Gutters = Chart Background", inline = "gut", group = G_UI)
i_gutC   = input.color(#000000, "else", inline = "gut", group = G_UI)

// ───────────────────────── BLOOMBERG AMBER THEME ─────────────────────────
C_BG     = #0A0A0A
C_HDR_BG = #2A1C06
C_HEAD   = #FFC24D
C_AMBER  = #FFB000
C_SOFT   = #EBD3A2
C_DIM    = #D9B870
C_ROW_A  = #0E0B05
C_ROW_B  = #17110A
C_WHITE  = #F2F2F2
C_BLACK  = #0A0A0A
C_GOLD   = #FFD23F
C_RED    = #FF3B30
C_GUT    = i_gutA ? chart.bg_color : i_gutC
C_NONE   = color.new(#000000, 100)
H0 = #120D05
H1 = #3A2608
H2 = #8C5A00
H3 = #FF8C00
H4 = #E0221A
capT = math.max(6, i_txt - 1)

// sequential risk scale (dark → amber → orange → red): higher = worse
f_riskBg(float t) =>
    tt = math.max(0.0, math.min(1.0, t))
    tt < 0.25 ? color.from_gradient(tt, 0.0, 0.25, H0, H1) : tt < 0.5 ? color.from_gradient(tt, 0.25, 0.5, H1, H2) : tt < 0.75 ? color.from_gradient(tt, 0.5, 0.75, H2, H3) : color.from_gradient(tt, 0.75, 1.0, H3, H4)
f_riskTx(float t) => t < 0.3 ? C_AMBER : t < 0.56 ? #FFF2D6 : C_BLACK
// diverging scale (red ← dark → amber), t in −1..+1: higher = better
f_divBg(float t) =>
    tt = math.max(-1.0, math.min(1.0, t))
    tt < 0 ? color.from_gradient(tt, -1.0, 0.0, #D61F1F, #1E1408) : tt < 0.5 ? color.from_gradient(tt, 0.0, 0.5, #1E1408, H2) : color.from_gradient(tt, 0.5, 1.0, H2, C_AMBER)
f_divTx(float t) => t > 0.62 ? C_BLACK : t < -0.55 ? C_WHITE : #F5D58A

// ───────────────────────── GRID ─────────────────────────
NR = 10                       // stop rows (top = widest stop)
NK = 10                       // target columns
K  = 100
f_slAt(int i) => i_slSt + (NR - 1 - i) * i_slStep
f_rrAt(int j) => i_rrSt + j * i_rrStep
f_nearSL(float v) =>
    int best = 0
    float bd = 1e9
    for i = 0 to NR - 1
        d = math.abs(f_slAt(i) - v)
        best := d < bd ? i : best
        bd := math.min(d, bd)
    best
f_nearRR(float v) =>
    int best = 0
    float bd = 1e9
    for j = 0 to NK - 1
        d = math.abs(f_rrAt(j) - v)
        best := d < bd ? j : best
        bd := math.min(d, bd)
    best
myRow = f_nearSL(i_mySL)
myCol = f_nearRR(i_myRR)
myK   = myRow * NK + myCol

// ───────────────────────── SIGNALS (shared by all 100 combinations) ─────────────────────────
atr   = ta.atr(i_atrLen)
emaT  = ta.ema(close, i_emaLen)
hiN   = ta.highest(high, i_dLen)[1]
loN   = ta.lowest(low, i_dLen)[1]
// every indicator is computed on every bar (Pine requires ta.* calls outside conditional branches)
[stLine, stDir] = ta.supertrend(i_stF, i_stP)
emaF  = ta.ema(close, i_fast)
emaS  = ta.ema(close, i_slow)
[mLine, mSig, mHist] = ta.macd(close, i_mFast, i_mSlow, i_mSig)
rsi   = ta.rsi(close, i_rsiLen)
[bbM, bbU, bbL] = ta.bb(close, i_bbLen, i_bbMul)
stoHH = ta.highest(high, i_stoK)
stoLL = ta.lowest(low, i_stoK)
stoK  = ta.sma(stoHH - stoLL > 0 ? 100.0 * (close - stoLL) / (stoHH - stoLL) : 50.0, i_stoS)
stoD  = ta.sma(stoK, i_stoD)
sar   = ta.sar(i_sarS, i_sarI, i_sarM)
tenk  = math.avg(ta.highest(high, i_tkT), ta.lowest(low, i_tkT))
kijn  = math.avg(ta.highest(high, i_tkK), ta.lowest(low, i_tkK))
[diP, diM, adx] = ta.dmi(i_dmiLen, i_dmiLen)
cci   = ta.cci(close, i_cciLen)
xStU  = stDir < 0 and stDir[1] > 0
xStD  = stDir > 0 and stDir[1] < 0
xEmU  = ta.crossover(emaF, emaS)
xEmD  = ta.crossunder(emaF, emaS)
xMcU  = ta.crossover(mLine, mSig)
xMcD  = ta.crossunder(mLine, mSig)
xRsU  = ta.crossover(rsi, i_rsiLo)
xRsD  = ta.crossunder(rsi, i_rsiHi)
xBrU  = ta.crossover(close, bbL)
xBrD  = ta.crossunder(close, bbU)
xBbU  = ta.crossover(close, bbU)
xBbD  = ta.crossunder(close, bbL)
xSoU  = ta.crossover(stoK, stoD) and stoD < i_stoLo
xSoD  = ta.crossunder(stoK, stoD) and stoD > i_stoHi
xSaU  = close > sar and close[1] <= sar[1]
xSaD  = close < sar and close[1] >= sar[1]
xTkU  = ta.crossover(tenk, kijn)
xTkD  = ta.crossunder(tenk, kijn)
xDmU  = ta.crossover(diP, diM) and adx >= i_adxMin
xDmD  = ta.crossunder(diP, diM) and adx >= i_adxMin
xCcU  = ta.crossover(cci, -i_cciLvl)
xCcD  = ta.crossunder(cci, i_cciLvl)
// custom indicator rules
c1U   = ta.crossover(i_cA, i_cLvl)
c1D   = ta.crossunder(i_cA, i_cLvl)
c2U   = ta.crossover(close, i_cA)
c2D   = ta.crossunder(close, i_cA)
c3U   = ta.crossover(i_cA, i_cB)
c3D   = ta.crossunder(i_cA, i_cB)
c4U   = not na(i_cA) and i_cA != 0 and (na(i_cA[1]) or i_cA[1] == 0)
c4D   = not na(i_cB) and i_cB != 0 and (na(i_cB[1]) or i_cB[1] == 0)
cuU   = i_cMode == "A Crosses Level" ? c1U : i_cMode == "Price Crosses A" ? c2U : i_cMode == "A Crosses B" ? c3U : c4U
cuD   = i_cMode == "A Crosses Level" ? c1D : i_cMode == "Price Crosses A" ? c2D : i_cMode == "A Crosses B" ? c3D : c4D
cusL  = i_cInv ? cuD : cuU
cusS  = i_cInv ? cuU : cuD
trUp  = not i_useTr or close > emaT
trDn  = not i_useTr or close < emaT
bool rawL = switch i_model
    "Supertrend Flip"     => xStU
    "Donchian Breakout"   => close > hiN
    "EMA Cross"           => xEmU
    "MACD Cross"          => xMcU
    "RSI Reversion"       => xRsU
    "Bollinger Reversion" => xBrU
    "Bollinger Breakout"  => xBbU
    "Stochastic Cross"    => xSoU
    "Parabolic SAR Flip"  => xSaU
    "Ichimoku TK Cross"   => xTkU
    "DMI / ADX Cross"     => xDmU
    "CCI Reversion"       => xCcU
    => cusL
bool rawS = switch i_model
    "Supertrend Flip"     => xStD
    "Donchian Breakout"   => close < loN
    "EMA Cross"           => xEmD
    "MACD Cross"          => xMcD
    "RSI Reversion"       => xRsD
    "Bollinger Reversion" => xBrD
    "Bollinger Breakout"  => xBbD
    "Stochastic Cross"    => xSoD
    "Parabolic SAR Flip"  => xSaD
    "Ichimoku TK Cross"   => xTkD
    "DMI / ADX Cross"     => xDmD
    "CCI Reversion"       => xCcD
    => cusS
sigL  = rawL and trUp and i_dir != "Short Only"
sigS  = rawS and trDn and i_dir != "Long Only" and not sigL
inWin = i_win == 0 or bar_index >= last_bar_index - i_win

// ───────────────────────── ENGINE STATE ─────────────────────────
var array<int>   aDir  = array.new_int(K, 0)
var array<float> aEnt  = array.new_float(K, na)
var array<float> aSL   = array.new_float(K, na)
var array<float> aTP   = array.new_float(K, na)
var array<float> aDist = array.new_float(K, na)
var array<int>   aEB   = array.new_int(K, 0)
var array<float> aN    = array.new_float(K, 0.0)
var array<float> aW    = array.new_float(K, 0.0)
var array<float> aTO   = array.new_float(K, 0.0)
var array<float> aSum  = array.new_float(K, 0.0)
var array<float> aGW   = array.new_float(K, 0.0)
var array<float> aGL   = array.new_float(K, 0.0)
var array<float> aEqP  = array.new_float(K, 1.0)
var array<float> aPkP  = array.new_float(K, 1.0)
var array<float> aMdd  = array.new_float(K, 0.0)
var array<float> aBars = array.new_float(K, 0.0)
var array<float> aCLS  = array.new_float(K, 0.0)
var array<float> aMLS  = array.new_float(K, 0.0)
var array<float> aCost = array.new_float(K, 0.0)
var int   pendDir = 0
var float pendAtr = na
var int   nSig    = 0
var int   winBars = 0
// excursion study (one per signal, no stop, no target, followed for the time-stop horizon)
var array<int>   sDir = array.new_int(0)
var array<float> sEnt = array.new_float(0)
var array<float> sAtr = array.new_float(0)
var array<int>   sEB  = array.new_int(0)
var array<float> sMAE = array.new_float(0)
var array<float> sMFE = array.new_float(0)
var array<float> sWM  = array.new_float(0)
var array<float> xMAE = array.new_float(0)        // finished studies: MAE (ATR units)
var array<float> xMFE = array.new_float(0)        // finished studies: MFE (ATR units)
var array<float> xWM  = array.new_float(0)        // eventual winners: MAE before the run

bool myIn   = false
int  myInD  = 0
bool myWin  = false
bool myLoss = false
rf = i_risk / 100.0

if barstate.isconfirmed and inWin
    winBars += 1
    for k = 0 to K - 1
        int d = array.get(aDir, k)
        // 1) enter at THIS bar's open on the previous bar's signal
        if d == 0 and pendDir != 0 and pendAtr > 0
            int ri = int(math.floor(k / NK))
            int cj = k - ri * NK
            float dist = pendAtr * f_slAt(ri)
            d := pendDir
            array.set(aDir, k, d)
            array.set(aEnt, k, open)
            array.set(aDist, k, dist)
            array.set(aSL, k, open - d * dist)
            array.set(aTP, k, open + d * dist * f_rrAt(cj))
            array.set(aEB, k, bar_index)
            if k == myK
                myIn := true
                myInD := d
        // 2) manage: gap → stop (SL-first) → gap → target → time stop
        if d != 0
            float sl = array.get(aSL, k)
            float tp = array.get(aTP, k)
            float en = array.get(aEnt, k)
            float ds = array.get(aDist, k)
            int   eb = array.get(aEB, k)
            bool  fresh = eb == bar_index
            float R = na
            bool  isTO = false
            if d == 1
                if not fresh and open <= sl
                    R := (open - en) / ds
                else if low <= sl
                    R := -1.0
                else if not fresh and open >= tp
                    R := (open - en) / ds
                else if high >= tp
                    R := (tp - en) / ds
            else
                if not fresh and open >= sl
                    R := (en - open) / ds
                else if high >= sl
                    R := -1.0
                else if not fresh and open <= tp
                    R := (en - open) / ds
                else if low <= tp
                    R := (en - tp) / ds
            if na(R) and bar_index - eb >= i_maxBar
                R := d * (close - en) / ds
                isTO := true
            if not na(R)
                float cR  = en * i_cost / 100.0 / ds
                float net = R - cR
                array.set(aN, k, array.get(aN, k) + 1.0)
                array.set(aSum, k, array.get(aSum, k) + net)
                array.set(aCost, k, array.get(aCost, k) + cR)
                array.set(aBars, k, array.get(aBars, k) + (bar_index - eb))
                if isTO
                    array.set(aTO, k, array.get(aTO, k) + 1.0)
                if net > 0
                    array.set(aW, k, array.get(aW, k) + 1.0)
                    array.set(aGW, k, array.get(aGW, k) + net)
                    array.set(aCLS, k, 0.0)
                else
                    array.set(aGL, k, array.get(aGL, k) - net)
                    float cl = array.get(aCLS, k) + 1.0
                    array.set(aCLS, k, cl)
                    array.set(aMLS, k, math.max(array.get(aMLS, k), cl))
                float eq = array.get(aEqP, k) * math.max(1.0 + rf * net, 0.0001)
                float pk = math.max(array.get(aPkP, k), eq)
                array.set(aEqP, k, eq)
                array.set(aPkP, k, pk)
                array.set(aMdd, k, math.max(array.get(aMdd, k), 1.0 - eq / pk))
                array.set(aDir, k, 0)
                if k == myK
                    myWin := net > 0
                    myLoss := net <= 0
    // 3) excursion study: open one per signal, update all, close at the horizon
    if pendDir != 0 and pendAtr > 0 and array.size(sDir) < 300
        nSig += 1
        array.push(sDir, pendDir)
        array.push(sEnt, open)
        array.push(sAtr, pendAtr)
        array.push(sEB, bar_index)
        array.push(sMAE, 0.0)
        array.push(sMFE, 0.0)
        array.push(sWM, na)
    int nS = array.size(sDir)
    if nS > 0
        for i = nS - 1 to 0
            int   sd = array.get(sDir, i)
            float se = array.get(sEnt, i)
            float sa = array.get(sAtr, i)
            float adv = sd == 1 ? (se - low) / sa : (high - se) / sa
            float fav = sd == 1 ? (high - se) / sa : (se - low) / sa
            float mae = math.max(array.get(sMAE, i), adv)          // adverse first: conservative
            float mfe = math.max(array.get(sMFE, i), fav)
            array.set(sMAE, i, mae)
            array.set(sMFE, i, mfe)
            if mfe >= i_winTh and na(array.get(sWM, i))
                array.set(sWM, i, mae)
            if bar_index - array.get(sEB, i) >= i_maxBar
                array.push(xMAE, mae)
                array.push(xMFE, mfe)
                float wm = array.get(sWM, i)
                if not na(wm)
                    array.push(xWM, wm)
                array.remove(sDir, i)
                array.remove(sEnt, i)
                array.remove(sAtr, i)
                array.remove(sEB, i)
                array.remove(sMAE, i)
                array.remove(sMFE, i)
                array.remove(sWM, i)
    if array.size(xMAE) > 4000
        array.shift(xMAE)
        array.shift(xMFE)
    if array.size(xWM) > 4000
        array.shift(xWM)
    // 4) arm the next bar's entry
    pendDir := sigL ? 1 : sigS ? -1 : 0
    pendAtr := atr

// your setting on the chart
myDir = array.get(aDir, myK)
plot(i_showLv and myDir != 0 ? array.get(aSL, myK) : na, "Your Active Stop", color.new(C_RED, 15), 2, plot.style_linebr)
plot(i_showLv and myDir != 0 ? array.get(aTP, myK) : na, "Your Active Target", color.new(C_AMBER, 15), 2, plot.style_linebr)
plotshape(i_showMk and myIn and myInD == 1, "Your Long Entry", shape.triangleup, location.belowbar, C_AMBER, size = size.tiny)
plotshape(i_showMk and myIn and myInD == -1, "Your Short Entry", shape.triangledown, location.abovebar, C_AMBER, size = size.tiny)
plotshape(i_showMk and myWin, "Your Win", shape.circle, location.abovebar, C_GOLD, size = size.tiny, text = "W", textcolor = C_GOLD)
plotshape(i_showMk and myLoss, "Your Loss", shape.xcross, location.belowbar, C_RED, size = size.tiny, text = "L", textcolor = C_RED)

// ───────────────────────── FORMATTERS ─────────────────────────
// ≤ 4 characters so every value fits its cell
f_c4(float v) =>
    float a = math.abs(v)
    string s = a >= 9999.5 ? str.tostring(a / 1000.0, "0") + "k" : a >= 999.5 ? str.tostring(a / 1000.0, "0.0") + "k" : a >= 9.95 ? str.tostring(a, "0") : str.tostring(a, "0.0")
    (v < 0 and a >= 0.05 ? "-" : "") + s
f_r1(float v) => math.abs(v) < 0.05 ? "0.0" : str.tostring(v, "0.0")
f_pf4(float v) => na(v) ? "∞" : v >= 99.5 ? "99+" : v >= 9.95 ? str.tostring(v, "0") : str.tostring(v, "0.00")
f_x2(float v) => str.tostring(v, "0.00")
f_ex4(float v) => math.abs(v) >= 9.95 ? str.tostring(v, "+0;-0") : str.tostring(v, "+0.0;-0.0")
f_sgn(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "0.0")

// ───────────────────────── CARD HELPERS (1 label column + 10 cells) ─────────────────────────
NC = 11
f_cell(table tb, int c, int r, string tx, color fg, color bg, int sz, string tip, string al) =>
    table.cell(tb, c, r, tx, width = c == 0 ? i_cw0 : i_cw, height = i_h, text_color = fg, bgcolor = bg, text_size = sz, text_halign = al, text_valign = text.align_center, tooltip = tip, text_font_family = font.family_monospace, text_formatting = text.format_bold)

f_row(table tb, int r, int c0, int c1, string tx, color fg, color bg, int sz, string al) =>
    for c = c0 to c1
        f_cell(tb, c, r, c == c0 ? tx : "", fg, bg, sz, "", al)
    if c1 > c0
        table.merge_cells(tb, c0, r, c1, r)

f_off(table tb, int r, float h) =>
    for c = 0 to NC - 1
        table.cell(tb, c, r, " ", width = c == 0 ? i_cw0 : i_cw, height = h, text_color = C_NONE, bgcolor = C_NONE, text_size = 6)

f_head(table tb, int r, string title, string cap) =>
    f_row(tb, r, 0, NC - 1, title, C_BLACK, C_AMBER, i_txtT, text.align_left)
    f_row(tb, r + 1, 0, NC - 1, cap, C_DIM, C_HDR_BG, capT, text.align_left)

// axis header: stop / target labels, your row / column lit amber
f_axisRow(table tb, int r) =>
    f_cell(tb, 0, r, "SL\\RR", C_HEAD, C_HDR_BG, capT, "rows: stop = ATR × m · columns: target = stop × R:R", text.align_center)
    for j = 0 to NK - 1
        f_cell(tb, 1 + j, r, f_x2(f_rrAt(j)), j == myCol ? C_BLACK : C_HEAD, j == myCol ? C_AMBER : C_HDR_BG, capT, "", text.align_center)

// ───────────────────────── RENDER (last bar only, rebuilt every execution) ─────────────────────────
var table t1 = na
var table t2 = na
var table t3 = na
var table t4 = na
var table t5 = na
var table t6 = na

if barstate.islast
    oldTabs = array.copy(table.all)
    for tb in oldTabs
        table.delete(tb)
    // ── per-cell metrics ──
    mN   = array.new_float(K, 0.0)
    mRet = array.new_float(K, na)
    mPF  = array.new_float(K, na)
    mDD  = array.new_float(K, na)
    mWR  = array.new_float(K, na)
    mEx  = array.new_float(K, na)
    mMar = array.new_float(K, na)
    mRob = array.new_float(K, na)
    float maxRet = 1e-9
    float maxMar = 1e-9
    for k = 0 to K - 1
        float n = array.get(aN, k)
        array.set(mN, k, n)
        if n >= i_minTr
            float ret = (array.get(aEqP, k) - 1.0) * 100.0
            float dd  = array.get(aMdd, k) * 100.0
            float gl  = array.get(aGL, k)
            array.set(mRet, k, ret)
            array.set(mDD, k, dd)
            array.set(mPF, k, gl > 0 ? array.get(aGW, k) / gl : na)
            array.set(mWR, k, array.get(aW, k) / n * 100.0)
            array.set(mEx, k, array.get(aSum, k) / n)
            float mar = ret / math.max(dd, 0.5)
            array.set(mMar, k, mar)
            maxRet := math.max(maxRet, math.abs(ret))
    // robust plateau: 3×3 mean of Return ÷ MaxDD over valid neighbours (needs ≥ 6 of 9)
    for k = 0 to K - 1
        int ri = int(math.floor(k / NK))
        int cj = k - ri * NK
        float s = 0.0
        float c = 0.0
        for dr = -1 to 1
            for dc = -1 to 1
                int rr = ri + dr
                int cc = cj + dc
                if rr >= 0 and rr < NR and cc >= 0 and cc < NK
                    float v = array.get(mMar, rr * NK + cc)
                    if not na(v)
                        s += v
                        c += 1.0
        if c >= 6 and not na(array.get(mMar, k))
            array.set(mRob, k, s / c)
            maxMar := math.max(maxMar, math.abs(s / c))
    // picks
    int kBest = -1
    int kRob  = -1
    int kPF   = -1
    int kDD   = -1
    for k = 0 to K - 1
        float r0 = array.get(mRet, k)
        if not na(r0)
            if kBest < 0 or r0 > array.get(mRet, kBest)
                kBest := k
            float pf0 = nz(array.get(mPF, k), 999.0)
            if kPF < 0 or pf0 > nz(array.get(mPF, kPF), 999.0)
                kPF := k
            if r0 > 0 and (kDD < 0 or array.get(mDD, k) < array.get(mDD, kDD))
                kDD := k
        float rb = array.get(mRob, k)
        if not na(rb) and (kRob < 0 or rb > array.get(mRob, kRob))
            kRob := k
    // stop-hunt study
    int nX  = array.size(xMAE)
    int nXW = array.size(xWM)
    float recSL  = nXW >= 5 ? array.percentile_linear_interpolation(xWM, i_maePct) : na
    float eRatio = nX > 0 and array.avg(xMAE) > 0 ? array.avg(xMFE) / array.avg(xMAE) : na
    int recRow = na(recSL) ? -1 : f_nearSL(recSL)
    int kMae = -1
    if recRow >= 0
        for j = 0 to NK - 1
            float v = array.get(mRet, recRow * NK + j)
            if not na(v) and (kMae < 0 or v > array.get(mRet, kMae))
                kMae := recRow * NK + j
    string sigTxt = str.tostring(nSig) + " signals · " + str.tostring(winBars) + " bars"

    // ══════════ ①②③④ HEATMAPS ══════════
    for m = 0 to 3
        bool on = m == 0 ? i_c1 : m == 1 ? i_c2 : m == 2 ? i_c3 : i_c4
        if on
            table tb = table.new(m == 0 ? position.top_left : m == 1 ? position.top_center : m == 2 ? position.top_right : position.bottom_left, NC, 15, C_NONE, C_GUT, 0, C_GUT, 1)
            int r0 = m < 3 ? 1 : 0
            if m < 3
                f_off(tb, 0, i_topOff)
            else
                f_off(tb, 14, i_botOff)
            string ttl = m == 0 ? "① NET RETURN % · " + str.tostring(i_risk, "0.0#") + "% RISK" : m == 1 ? "② PROFIT FACTOR · NET OF COSTS" : m == 2 ? "③ MAX DRAWDOWN % · TOL " + str.tostring(i_ddTol, "0") + "%" : "④ ROBUST PLATEAU · 3×3 RET÷DD"
            string cap = m == 3 ? "◆ robust pick · smooths away lucky single peaks" : sigTxt + " · gold ★ best · white ◉ you"
            f_head(tb, r0, ttl, cap)
            f_axisRow(tb, r0 + 2)
            for i = 0 to NR - 1
                f_cell(tb, 0, r0 + 3 + i, f_x2(f_slAt(i)) + "×", i == myRow ? C_BLACK : C_AMBER, i == myRow ? C_AMBER : C_HDR_BG, capT, "", text.align_center)
                for j = 0 to NK - 1
                    int k = i * NK + j
                    float n = array.get(mN, k)
                    string tx = "·"
                    color bg = C_BG
                    color fg = C_DIM
                    float v = m == 0 ? array.get(mRet, k) : m == 1 ? array.get(mPF, k) : m == 2 ? array.get(mDD, k) : array.get(mRob, k)
                    bool valid = n >= i_minTr and (m == 1 or not na(v))
                    if valid
                        if m == 0
                            float t = v / maxRet
                            tx := f_c4(v)
                            bg := f_divBg(t)
                            fg := f_divTx(t)
                        else if m == 1
                            float t = na(v) ? 1.0 : v < 1.0 ? (v - 1.0) / 0.5 : (v - 1.0) / 1.0
                            tx := f_pf4(v)
                            bg := f_divBg(t)
                            fg := f_divTx(t)
                        else if m == 2
                            float t = v / (2.0 * i_ddTol)
                            tx := f_c4(v)
                            bg := f_riskBg(t)
                            fg := f_riskTx(t)
                        else
                            float t = v / maxMar
                            bool mk = k == kRob
                            tx := (mk ? "◆" : "") + (math.abs(v) >= 9.95 or (mk and v <= -1.0) ? str.tostring(v, "0") : mk and v <= -0.05 ? str.tostring(v, "#.0") : f_r1(v))
                            bg := f_divBg(t)
                            fg := f_divTx(t)
                    if valid and ((m < 3 and k == kBest) or (m == 3 and k == kRob))
                        bg := C_GOLD
                        fg := C_BLACK
                    if k == myK
                        bg := C_WHITE
                        fg := C_BLACK
                    string tip = n < 1 ? "no closed trades" : "SL " + f_x2(f_slAt(i)) + "× ATR · TP " + f_x2(f_rrAt(j)) + "R\n" + str.tostring(n, "0") + " trades · WR " + str.tostring(array.get(aW, k) / n * 100.0, "0.0") + "% · PF " + f_pf4(array.get(aGL, k) > 0 ? array.get(aGW, k) / array.get(aGL, k) : na) + "\nexp " + str.tostring(array.get(aSum, k) / n, "+0.000;-0.000") + "R · cost " + str.tostring(array.get(aCost, k) / n, "0.000") + "R/trade\nreturn " + f_sgn((array.get(aEqP, k) - 1.0) * 100.0) + "% · max DD " + str.tostring(array.get(aMdd, k) * 100.0, "0.0") + "%\ntime stops " + str.tostring(array.get(aTO, k) / n * 100.0, "0") + "% · avg hold " + str.tostring(array.get(aBars, k) / n, "0") + " bars · max L-streak " + str.tostring(array.get(aMLS, k), "0") + (k == myK ? "\n◉ YOUR SETTING" : "") + (k == kBest ? "\n★ BEST RETURN" : "") + (k == kRob ? "\n◆ ROBUST PICK" : "")
                    f_cell(tb, 1 + j, r0 + 3 + i, tx, fg, bg, i_txt, tip, text.align_center)
            // key row
            f_cell(tb, 0, r0 + 13, "KEY", C_DIM, C_HDR_BG, capT, "", text.align_center)
            for q = 0 to NK - 1
                string lab = ""
                color sbg = C_BG
                color sfg = C_AMBER
                if m == 0 or m == 3
                    float tt = q < 5 ? (q - 5) / 5.0 : (q - 5) / 4.0
                    float sc = m == 0 ? maxRet : maxMar
                    lab := q == 0 or q == 9 ? f_c4(tt * sc) : q == 5 ? "0" : ""
                    sbg := f_divBg(tt)
                    sfg := f_divTx(tt)
                else if m == 1
                    float tt = q < 5 ? (q - 5) / 5.0 : (q - 5) / 4.0
                    float pf = tt < 0 ? 1.0 + tt * 0.5 : 1.0 + tt
                    lab := q == 0 or q == 5 or q == 9 ? str.tostring(pf, "0.0") : ""
                    sbg := f_divBg(tt)
                    sfg := f_divTx(tt)
                else
                    float tt = q < 5 ? q / 10.0 : 0.5 + (q - 5) / 8.0
                    lab := q == 0 or q == 5 or q == 9 ? (q == 9 ? "≥" : "") + str.tostring(tt * 2.0 * i_ddTol, "0") : ""
                    sbg := f_riskBg(tt)
                    sfg := f_riskTx(tt)
                f_cell(tb, 1 + q, r0 + 13, lab, sfg, sbg, capT, "", text.align_center)
            if m == 0
                t1 := tb
            else if m == 1
                t2 := tb
            else if m == 2
                t3 := tb
            else
                t4 := tb

    // ══════════ ⑤ STOP-HUNT PROFILE (bottom center) ══════════
    if i_c5
        t5 := table.new(position.bottom_center, NC, 15, C_NONE, C_GUT, 0, C_GUT, 1)
        f_off(t5, 14, i_botOff)
        f_head(t5, 0, "⑤ STOP-HUNT PROFILE · MAE / MFE", str.tostring(nX) + " studies · " + str.tostring(i_maxBar) + " bars · winner = runs " + str.tostring(i_winTh, "0.0#") + "× ATR")
        f_cell(t5, 0, 2, "ATR×", C_HEAD, C_HDR_BG, capT, "", text.align_center)
        f_row(t5, 2, 1, 5, "STOP TOUCHED %", C_HEAD, C_HDR_BG, capT, text.align_center)
        f_row(t5, 2, 6, 10, "WINNERS CUT %", C_HEAD, C_HDR_BG, capT, text.align_center)
        for i = 0 to NR - 1
            float sl = f_slAt(i)
            float hit = 0.0
            float cut = 0.0
            if nX > 0
                for q = 0 to nX - 1
                    hit += array.get(xMAE, q) >= sl ? 1.0 : 0.0
            if nXW > 0
                for q = 0 to nXW - 1
                    cut += array.get(xWM, q) >= sl ? 1.0 : 0.0
            hit := nX > 0 ? hit / nX : na
            cut := nXW > 0 ? cut / nXW : na
            bool isRec = i == recRow
            f_cell(t5, 0, 3 + i, f_x2(sl) + "×", isRec ? C_BLACK : i == myRow ? C_BLACK : C_AMBER, isRec ? C_GOLD : i == myRow ? C_WHITE : C_HDR_BG, capT, isRec ? "MAE stop: " + str.tostring(recSL, "0.00") + "× ATR" : "", text.align_center)
            for b = 0 to 3
                float fh = math.max(0.0, math.min(1.0, nz(hit) * 4.0 - b))
                float fc = math.max(0.0, math.min(1.0, nz(cut) * 4.0 - b))
                f_cell(t5, 1 + b, 3 + i, " ", C_NONE, color.from_gradient(fh, 0.0, 1.0, C_ROW_B, H3), 6, "", text.align_center)
                f_cell(t5, 6 + b, 3 + i, " ", C_NONE, color.from_gradient(fc, 0.0, 1.0, C_ROW_B, H4), 6, "", text.align_center)
            f_cell(t5, 5, 3 + i, na(hit) ? "—" : str.tostring(hit * 100.0, "0"), C_SOFT, C_BG, i_txt, "P(price touches a " + f_x2(sl) + "× ATR stop within " + str.tostring(i_maxBar) + " bars)", text.align_center)
            f_cell(t5, 10, 3 + i, na(cut) ? "—" : str.tostring(cut * 100.0, "0"), nz(cut) > 0.25 ? C_RED : C_SOFT, C_BG, i_txt, "share of eventual winners whose heat before the run reached " + f_x2(sl) + "× ATR", text.align_center)
        string keyTx = "E-RATIO " + (na(eRatio) ? "—" : str.tostring(eRatio, "0.00")) + " · MAE STOP " + (na(recSL) ? "—" : str.tostring(recSL, "0.00") + "×") + " (P" + str.tostring(i_maePct, "0") + " of " + str.tostring(nXW) + " winners)"
        f_row(t5, 13, 0, NC - 1, keyTx, C_BLACK, nz(eRatio) >= 1.0 ? C_AMBER : H3, capT, text.align_left)

    // ══════════ ⑥ STOP DESK (bottom right) ══════════
    if i_c6
        t6 := table.new(position.bottom_right, NC, 15, C_NONE, C_GUT, 0, C_GUT, 1)
        f_off(t6, 14, i_botOff)
        string modTx = switch i_model
            "Supertrend Flip"     => "SUPERTREND " + str.tostring(i_stP) + "/" + str.tostring(i_stF, "0.0#")
            "Donchian Breakout"   => "DONCHIAN " + str.tostring(i_dLen)
            "EMA Cross"           => "EMA " + str.tostring(i_fast) + "/" + str.tostring(i_slow)
            "MACD Cross"          => "MACD " + str.tostring(i_mFast) + "/" + str.tostring(i_mSlow) + "/" + str.tostring(i_mSig)
            "RSI Reversion"       => "RSI " + str.tostring(i_rsiLen) + " " + str.tostring(i_rsiLo, "0") + "/" + str.tostring(i_rsiHi, "0")
            "Bollinger Reversion" => "BB REV " + str.tostring(i_bbLen) + "/" + str.tostring(i_bbMul, "0.0#")
            "Bollinger Breakout"  => "BB BRK " + str.tostring(i_bbLen) + "/" + str.tostring(i_bbMul, "0.0#")
            "Stochastic Cross"    => "STOCH " + str.tostring(i_stoK) + "/" + str.tostring(i_stoS) + "/" + str.tostring(i_stoD)
            "Parabolic SAR Flip"  => "PSAR " + str.tostring(i_sarS, "0.0##") + "/" + str.tostring(i_sarM, "0.0#")
            "Ichimoku TK Cross"   => "ICHIMOKU TK " + str.tostring(i_tkT) + "/" + str.tostring(i_tkK)
            "DMI / ADX Cross"     => "DMI " + str.tostring(i_dmiLen) + " ADX≥" + str.tostring(i_adxMin, "0")
            "CCI Reversion"       => "CCI " + str.tostring(i_cciLen) + " ±" + str.tostring(i_cciLvl, "0")
            => "CUSTOM · " + (i_cMode == "A Crosses Level" ? "A×" + str.tostring(i_cLvl, "0.##") : i_cMode == "Price Crosses A" ? "PRICE×A" : i_cMode == "A Crosses B" ? "A×B" : "A/B SIG") + (i_cInv ? " INV" : "")
        f_head(t6, 0, "⑥ STOP DESK · " + syminfo.ticker + " " + timeframe.period, modTx + (i_useTr ? " · EMA" + str.tostring(i_emaLen) + " filter" : "") + " · " + (i_dir == "Long & Short" ? "L+S" : i_dir == "Long Only" ? "LONG" : "SHORT") + " · cost " + str.tostring(i_cost, "0.0##") + "%")
        array<string> hd = array.from("SL×", "RR", "TRD", "WR", "PF", "EXP", "DD", "RET")
        f_row(t6, 2, 0, 2, "PICK", C_HEAD, C_HDR_BG, capT, text.align_left)
        for c = 0 to 7
            f_cell(t6, 3 + c, 2, array.get(hd, c), C_HEAD, C_HDR_BG, capT, "", text.align_center)
        array<string> nm = array.from("★ BEST RET", "◆ ROBUST", "◉ YOURS", "▲ BEST PF", "▼ LOW DD", "✚ MAE STOP")
        array<int>    ks = array.from(kBest, kRob, myK, kPF, kDD, kMae)
        for r = 0 to 5
            int k = array.get(ks, r)
            color rb = r == 1 ? C_HDR_BG : r % 2 == 0 ? C_ROW_A : C_ROW_B
            f_row(t6, 3 + r, 0, 2, array.get(nm, r), r == 1 ? C_GOLD : C_AMBER, rb, i_txt, text.align_left)
            if k < 0 or array.get(aN, k) < 1
                for c = 3 to 10
                    f_cell(t6, c, 3 + r, "—", C_DIM, rb, i_txt, "", text.align_center)
            else
                int ri = int(math.floor(k / NK))
                int cj = k - ri * NK
                float n = array.get(aN, k)
                float ret = (array.get(aEqP, k) - 1.0) * 100.0
                float dd = array.get(aMdd, k) * 100.0
                float gl = array.get(aGL, k)
                float pf = gl > 0 ? array.get(aGW, k) / gl : na
                float ex = array.get(aSum, k) / n
                f_cell(t6, 3, 3 + r, f_x2(f_slAt(ri)), C_SOFT, rb, i_txt, "", text.align_center)
                f_cell(t6, 4, 3 + r, f_x2(f_rrAt(cj)), C_SOFT, rb, i_txt, "", text.align_center)
                f_cell(t6, 5, 3 + r, f_c4(n), n >= i_minTr ? C_SOFT : C_RED, rb, i_txt, "", text.align_center)
                f_cell(t6, 6, 3 + r, str.tostring(array.get(aW, k) / n * 100.0, "0"), C_SOFT, rb, i_txt, "", text.align_center)
                f_cell(t6, 7, 3 + r, f_pf4(pf), nz(pf, 9.0) >= 1.0 ? C_GOLD : C_RED, rb, i_txt, "", text.align_center)
                f_cell(t6, 8, 3 + r, f_ex4(ex), ex > 0 ? C_GOLD : C_RED, rb, i_txt, "", text.align_center)
                f_cell(t6, 9, 3 + r, f_c4(dd), f_riskTx(dd / (2.0 * i_ddTol)), f_riskBg(dd / (2.0 * i_ddTol)), i_txt, "", text.align_center)
                f_cell(t6, 10, 3 + r, f_c4(ret), ret >= 0 ? C_BLACK : C_WHITE, ret >= 0 ? C_AMBER : #D61F1F, i_txt, "", text.align_center)
        // diagnostics
        float ring = 0.0
        float nr = 0.0
        if kBest >= 0
            int bi = int(math.floor(kBest / NK))
            int bj = kBest - bi * NK
            for dr = -1 to 1
                for dc = -1 to 1
                    int rr = bi + dr
                    int cc = bj + dc
                    if (dr != 0 or dc != 0) and rr >= 0 and rr < NR and cc >= 0 and cc < NK
                        float v = array.get(mRet, rr * NK + cc)
                        if not na(v)
                            ring += v
                            nr += 1.0
        float bestR = kBest >= 0 ? array.get(mRet, kBest) : na
        float ringR = nr > 0 ? ring / nr : na
        float iso = not na(bestR) and bestR > 0 and not na(ringR) ? math.max(0.0, math.min(1.0, 1.0 - ringR / bestR)) : na
        f_row(t6, 9, 0, NC - 1, "OVERFIT ▸ ★ " + (na(bestR) ? "—" : f_sgn(bestR)) + "% vs ring " + (na(ringR) ? "—" : f_sgn(ringR)) + "% · " + (na(iso) ? "—" : str.tostring(iso * 100.0, "0") + "% isolated"), nz(iso) > 0.4 ? C_RED : C_SOFT, C_ROW_A, capT, text.align_left)
        float cTight = array.get(aN, (NR - 1) * NK) > 0 ? array.get(aCost, (NR - 1) * NK) / array.get(aN, (NR - 1) * NK) : na
        float cWide  = array.get(aN, 0) > 0 ? array.get(aCost, 0) / array.get(aN, 0) : na
        f_row(t6, 10, 0, NC - 1, "COST ▸ " + (na(cTight) ? "—" : str.tostring(cTight, "0.00") + "R") + " per trade @" + f_x2(f_slAt(NR - 1)) + "× vs " + (na(cWide) ? "—" : str.tostring(cWide, "0.00") + "R") + " @" + f_x2(f_slAt(0)) + "×", C_SOFT, C_ROW_B, capT, text.align_left)
        float myCut = 0.0
        if nXW > 0
            for q = 0 to nXW - 1
                myCut += array.get(xWM, q) >= f_slAt(myRow) ? 1.0 : 0.0
            myCut := myCut / nXW
        f_row(t6, 11, 0, NC - 1, "YOUR STOP ▸ " + f_x2(f_slAt(myRow)) + "× cuts " + (nXW > 0 ? str.tostring(myCut * 100.0, "0") + "%" : "—") + " of winners · MAE stop " + (na(recSL) ? "—" : str.tostring(recSL, "0.00") + "×"), nXW > 0 and myCut > 0.25 ? C_RED : C_SOFT, C_ROW_A, capT, text.align_left)
        f_row(t6, 12, 0, NC - 1, "TEST ▸ " + sigTxt + " · " + str.tostring(i_maxBar) + "-bar stop · next-open fill", C_DIM, C_ROW_B, capT, text.align_left)
        string vTx = kRob >= 0 ? "VERDICT ▸ ◆ " + f_x2(f_slAt(int(math.floor(kRob / NK)))) + "× ATR stop · " + f_x2(f_rrAt(kRob - int(math.floor(kRob / NK)) * NK)) + "R target" + (array.get(mRet, kRob) > 0 ? "" : " · NO EDGE") : "VERDICT ▸ not enough trades · widen window"
        f_row(t6, 13, 0, NC - 1, vTx, C_BLACK, kRob >= 0 and nz(array.get(mRet, math.max(kRob, 0))) > 0 ? C_AMBER : H4, i_txt, text.align_left)

// ───────────────────────── ALERTS ─────────────────────────
alertcondition(myIn, "Your Setting: Entry", "SL HEAT: entry on your stop / target setting")
alertcondition(myLoss, "Your Setting: Stop Hit", "SL HEAT: your setting closed at a loss")
alertcondition(myWin, "Your Setting: Target / Win", "SL HEAT: your setting closed at a profit")
````
