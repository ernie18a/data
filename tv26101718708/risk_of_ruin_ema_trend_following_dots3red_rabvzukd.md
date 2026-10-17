# Risk of Ruin - EMA Trend Following [Dots3Red]

- url: https://www.tradingview.com/script/RabVZuKd-Risk-of-Ruin-EMA-Trend-Following-Dots3Red/
- type: indicator
- pine_id: PUB;ec99e37a0d9e49b0be0c918b157ebd2a
- version: 1.0

## Description

💰 [b]RISK OF RUIN & POSITION SIZING [Dots3Red][/b]
This indicator tests a simple EMA trend-following setup with an ATR-based stop and target on the current chart, measures its win rate from history, and uses that measured win rate to calculate the Kelly risk percentage, the approximate risk of ruin at your chosen risk per trade, and a suggested position size.

✨ [b]WHY THIS MATTERS[/b]
Traders obsess over win rate and largely ignore the number that actually determines survival: how much of the account is risked per trade, given that win rate. A 55% win rate at 1% risk per trade is a very different proposition than the same win rate at 10% risk — one is a slow path to compounding, the other has a real, calculable probability of blowing the account.

Most position-sizing tools ask you to type in a win rate and payout ratio you already have to know from somewhere else. This one measures them from the chart it's running on, so the sizing math starts from observed history instead of a guess.

⚙️ [b]HOW IT WORKS[/b]
📐 [b]The reference system[/b] — a fast EMA vs. slow EMA defines trend direction (default 20/50). Each hypothetical entry gets an ATR-based stop (default 1×ATR, defining 1R) and an ATR-based target (default 2×ATR). It exists only to produce measurable win/loss outcomes. It is not a signal generator, and every figure in the dashboard is a statement about this specific system on this chart, not about your own trading.

🎯 [b]Triple-barrier resolution[/b] — for every historical entry, the script walks forward through bars that have already closed to see whether the target or the stop was struck first, within your chosen window. If both are touched on the same bar, it counts as a stop, which is the conservative choice. Only fully resolved trades are counted.

🔒 [b]Non-repainting[/b] — every trade examined is already confirmed history when it's graded; nothing shown for the past can change after the fact.

📊 [b]Measured edge → Kelly Criterion[/b] — the measured win rate and the fixed payout ratio (target ÷ stop) combine into an edge value, then the full-Kelly and half-Kelly risk percentages for that edge.

⚠️ [b]Risk of Ruin[/b] — using your own Risk-per-Trade setting and the measured edge, a standard simplified approximation of the probability of exhausting the account at that risk level.

🧮 [b]Suggested position size[/b] — from your account size, risk percentage and the current ATR stop distance, the quantity that keeps a stop-out at exactly your chosen risk.

📈 [b]The win-rate line[/b] — the line in the lower pane is the running measured win rate of the reference system as more trades resolve. It starts jumpy with few trades and settles as the sample grows. The dashed line at 50% is a coin-flip reference. Line color, thickness and visibility are adjustable, and so is the color of the 50% line.

🖥️ [b]Dashboard on the price chart[/b] — all the figures are shown directly on the main chart so they sit next to the price action.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Wait for enough resolved trades.[/b] The dashboard shows "Collecting…" until enough entries have fully resolved for the win rate to mean something.

2️⃣ [b]Check Edge (A) first.[/b] Positive means the reference system has outperformed break-even on this chart at these settings. Negative means Kelly and the risk-of-ruin math will argue against sizing up at all. With a 2R target, break-even sits at roughly a 33% win rate, so a win rate below 50% is not automatically a bad edge.

3️⃣ [b]Compare your Risk % to Kelly.[/b] Kelly is a mathematical ceiling, not a target. If your risk setting is well above it, the Risk of Ruin reading will show it. Half-Kelly is displayed because many traders run a fraction of the full figure.

4️⃣ [b]Use Suggested Size as a starting point.[/b] It converts your risk percentage and the current ATR into a concrete quantity. Adjust it if your real stop placement differs from a pure ATR multiple.

5️⃣ [b]Set the reference system to resemble how you trade.[/b] A scalper's stop/target multiples and window look very different from a swing trader's. The statistics only describe your style if the reference system resembles it.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
The statistics need enough resolved trades to be meaningful, which makes [b]15-minute through 4-hour[/b] the most practical range. Daily charts can work on instruments with long history if you lower the minimum trades setting.

🛠️ [b]SETTINGS[/b]
📐 [b]Reference System[/b] — fast/slow EMA, ATR length, stop distance (× ATR), target distance (× ATR), max bars to resolve a trade, minimum trades before stats display

💰 [b]Position Sizing[/b] — account size, risk per trade (%)

🎨 [b]Win-Rate Line[/b] — show/hide, line color, line thickness, 50% line color

🖥️ [b]Dashboard[/b] — show/hide, position — measured win rate (n), payout ratio, edge, Kelly optimal risk (full and half), risk of ruin at your risk %, current ATR, suggested position size, resolve window

📝 [b]NOTES[/b]
The Risk of Ruin figure is a standard simplified approximation built on the measured edge and your settings. It is not a Monte Carlo simulation, and it is not a guarantee. All statistics are specific to this chart, this timeframe, the reference system and these settings, and do not transfer to other instruments or configurations.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and educational tool for position-sizing math. It does not generate trade signals and does not constitute financial advice. Historical statistics do not guarantee future performance, and no sizing formula eliminates the risk of loss.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Risk of Ruin - EMA Trend System [Dots3Red]",
          shorttitle = "Risk of Ruin - EMA [D3R]",
          overlay    = false,
          max_labels_count = 500)


// COLORS
C_TXT   = color.new(#f8fafc, 0)
C_DIM   = color.new(#94a3b8, 0)
C_BG    = color.new(#131722, 5)
C_BORD  = color.new(#334155, 0)
C_GOOD  = color.new(#00c896, 0)
C_BAD   = color.new(#ff4466, 0)
C_AMBER = color.new(#ffb700, 0)


// INPUTS
GRP_SYS  = "📐 Reference System (measures the stats)"
GRP_RISK = "💰 Position Sizing"
GRP_HUD  = "🖥️ Dashboard"
GRP_VIS  = "🎨 Win-Rate Line (pane below)"

fastLen  = input.int(20, "Fast EMA (trend direction)", minval=2, group=GRP_SYS)
slowLen  = input.int(50, "Slow EMA (trend direction)", minval=2, group=GRP_SYS)
atrLen   = input.int(14, "ATR Length", minval=2, group=GRP_SYS)
stopMult = input.float(1.0, "Stop Distance (× ATR = 1R)", minval=0.1, step=0.1, group=GRP_SYS)
tgtMult  = input.float(2.0, "Target Distance (× ATR)", minval=0.1, step=0.1, group=GRP_SYS)
horizon  = input.int(30, "Max Bars to Resolve a Trade", minval=5, maxval=200, group=GRP_SYS)
minTrade = input.int(30, "Min Trades Before Showing Stats", minval=10, group=GRP_SYS)

accountSize = input.float(10000, "Account Size", minval=1, group=GRP_RISK)
riskPct     = input.float(1.0, "Your Risk per Trade (%)", minval=0.1, maxval=25, step=0.1, group=GRP_RISK)

show_line  = input.bool(true, "Show Win-Rate Line", group=GRP_VIS,
             tooltip="The line in the lower pane is the running win rate of the reference system, graded trade by trade on this chart. The dashed line at 50% is a coin flip.")
line_col   = input.color(#f8fafc, "Line Color", group=GRP_VIS)
line_width = input.int(2, "Line Thickness", minval=1, maxval=6, group=GRP_VIS)
flip_col   = input.color(#94a3b8, "50% (Coin Flip) Line Color", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard (on price chart)", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


float ema_f = ta.ema(close, fastLen)
float ema_s = ta.ema(close, slowLen)
float atr   = ta.atr(atrLen)


var float n_trades = 0.0
var float n_wins   = 0.0

float b_ratio = tgtMult / stopMult   // payout ratio in R

if barstate.isconfirmed and bar_index >= horizon
    int   dir       = ema_f[horizon] > ema_s[horizon] ? 1 : ema_f[horizon] < ema_s[horizon] ? -1 : 0
    float entry_px  = close[horizon]
    float entry_atr = atr[horizon]

    if dir != 0 and entry_atr > 0
        float tgt_level  = dir > 0 ? entry_px + entry_atr * tgtMult  : entry_px - entry_atr * tgtMult
        float stop_level = dir > 0 ? entry_px - entry_atr * stopMult : entry_px + entry_atr * stopMult

        int   outcome = 0   
        for off = horizon - 1 to 0
            if outcome == 0
                float h = high[off]
                float l = low[off]
                bool hit_tgt  = dir > 0 ? h >= tgt_level  : l <= tgt_level
                bool hit_stop = dir > 0 ? l <= stop_level : h >= stop_level
                if hit_tgt and hit_stop                   
                    outcome := -1
                else if hit_tgt
                    outcome := 1
                else if hit_stop
                    outcome := -1

        if outcome != 0
            n_trades += 1.0
            if outcome == 1
                n_wins += 1.0


bool  enough    = n_trades >= minTrade
float win_rate  = n_trades > 0 ? n_wins / n_trades : na
float q_rate    = na(win_rate) ? na : 1.0 - win_rate
float edge_A    = na(win_rate) ? na : win_rate * b_ratio - q_rate

float kelly_full = (not na(edge_A) and b_ratio > 0) ? (win_rate * (b_ratio + 1.0) - 1.0) / b_ratio * 100.0 : na
float kelly_half = na(kelly_full) ? na : kelly_full / 2.0

float n_units = riskPct > 0 ? 100.0 / riskPct : na
float ror_raw = (not na(edge_A) and edge_A > -0.999 and edge_A < 0.999 and not na(n_units)) ?
                 math.pow((1.0 - edge_A) / (1.0 + edge_A), n_units) * 100.0 : na
float ror_pct = na(ror_raw) ? na : math.min(100.0, math.max(0.0, ror_raw))

float risk_amount   = accountSize * riskPct / 100.0
float stop_dist_px  = atr * stopMult
float suggested_qty = stop_dist_px > 0 ? risk_amount / stop_dist_px : na


f_pct(float v) => na(v) ? "—" : str.tostring(math.round(v * 10) / 10.0) + "%"
f_ror_col(float v) => na(v) ? C_DIM : v < 5 ? C_GOOD : v < 25 ? C_AMBER : C_BAD
f_kelly_col(float v) => na(v) ? C_DIM : v > 0 ? C_GOOD : C_BAD


// ═══ VISUALS (reference system context only — not a signal) ═══════════════
plot(win_rate * 100, "Measured Win Rate %", color=line_col, linewidth=line_width,
     display = show_line ? display.all : display.none)
hline(50, "Coin Flip", color=flip_col, linestyle=hline.style_dashed)


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 9,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2,
                           force_overlay=true)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "RISK OF RUIN [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Measured Win Rate", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, not enough ? "Collecting… (n=" + str.tostring(int(n_trades)) + ")" : f_pct(win_rate * 100) + " (n=" + str.tostring(int(n_trades)) + ")",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 2, "Payout Ratio (R)", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11,
               tooltip="Target distance ÷ stop distance, in ATR multiples — fixed by your settings, not measured.")
    table.cell(hud, 1, 2, str.tostring(b_ratio, "#.##") + "R",
               text_color=C_TXT, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 3, "Edge (A)", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11,
               tooltip="p×b − q. Positive means the measured system has a real statistical edge on this chart.")
    table.cell(hud, 1, 3, not enough or na(edge_A) ? "—" : str.tostring(math.round(edge_A * 1000) / 1000.0),
               text_color = not enough or na(edge_A) ? C_DIM : (edge_A > 0 ? C_GOOD : C_BAD),
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 4, "Kelly Optimal Risk", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11,
               tooltip="Full-Kelly fraction of account to risk per trade, from the measured edge. Most traders use a fraction of this (e.g. half-Kelly) for a smoother equity curve.")
    table.cell(hud, 1, 4, not enough ? "—" : f_pct(kelly_full) + " (½: " + f_pct(kelly_half) + ")",
               text_color=f_kelly_col(kelly_full), bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 5, "Risk of Ruin @ Your Risk%", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11,
               tooltip="Approximate probability of exhausting the account at your chosen Risk-per-Trade setting, given the measured edge. A standard simplified approximation, not a precise simulation.")
    table.cell(hud, 1, 5, not enough ? "—" : f_pct(ror_pct) + " @ " + str.tostring(riskPct, "#.#") + "%",
               text_color=f_ror_col(ror_pct), bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 6, "Current ATR", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 6, str.tostring(atr, format.mintick),
               text_color=C_TXT, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 7, "Suggested Size", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11,
               tooltip="Account Size × Risk% ÷ (ATR × Stop Multiple). Units in whatever your instrument is quoted in.")
    table.cell(hud, 1, 7, na(suggested_qty) ? "—" : str.tostring(suggested_qty, "#.####"),
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 8, "Resolve Window", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 8, str.tostring(horizon) + " bars max",
               text_color=C_TXT, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)
````
