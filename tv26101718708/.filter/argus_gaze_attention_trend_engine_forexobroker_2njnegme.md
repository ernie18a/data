# Argus Gaze: Attention Trend Engine [forexobroker]

- url: https://www.tradingview.com/script/2njnEGME-Argus-Gaze-Attention-Trend-Engine-forexobroker/
- type: indicator
- pine_id: PUB;f40c20b3eb2a423581e85b53f8ea311a
- version: 1.0

## Description

# Argus Gaze: Attention Trend Engine [forexobroker]

🔶 OVERVIEW

Argus Gaze brings the attention mechanism — the core idea behind modern transformer models — onto your chart. Instead of asking "what does an indicator formula say about this bar?", it asks a different question: "when did the market last LOOK like this, and what happened next?"

Every bar is encoded as a compact, ATR/z-normalized state vector. A soft-attention head then compares today's state against the last N historical states, weights each one by similarity (softmax over negative distance), and blends their KNOWN follow-up returns into a single forward-looking Trend Score. Because every feature is volatility-normalized, the same settings behave consistently across forex, indices, futures, and crypto.

What makes it different from pattern-matching scripts: attention is SOFT. It never picks one "best match" — it weighs all N analogues at once, and it tells you how focused that weighting is. The attention entropy becomes a conviction gauge: when attention collapses onto a handful of strongly similar past states, conviction is high; when attention is spread thin, the engine is honest about its uncertainty.

The second half of the script is a full prop-firm risk engine: FTMO / Topstep / Apex presets, ATR-based position sizing, simulated R tracking, daily-loss lockout, trailing max-drawdown breach detection, a consistency cap on signals per day, plus session and news-blackout filters. The chart literally tints orange and the dashboard reads STAND DOWN when you should not be clicking buttons.

🔶 ALGORITHM

1. State encoding — each bar becomes a 3-feature vector, all volatility-normalized:
   • f1 = (close − close[1]) / ATR(14) — directional thrust
   • f2 = (high − low) / ATR(14) − 1 — range expansion vs. average
   • f3 = volume z-score over a 50-bar window (guarded when stdev = 0)
2. Similarity — for each lag k = 1..N (default 64), the squared Euclidean distance d²ₖ between today's vector and the vector k bars ago is computed.
3. Attention logits — simₖ = −d²ₖ / temperature. Temperature controls sharpness: low = spiky attention on the closest analogues, high = smooth blending.
4. Stable softmax — a first pass finds the maximum logit; a second pass computes wₖ = exp(simₖ − maxSim) so the exponentials can never overflow.
5. Known outcomes — each historical state carries the ATR-normalized return that followed it: outₖ = (close[k−1] − close[k]) / ATR(14)[k].
6. Forecast — the attention-weighted average Σ(wₖ · outₖ) / Σwₖ, i.e. "what the market did the last times it looked like this", in ATR units.
7. Trend Score — an EMA (default 5) of the forecast.
8. Conviction — attention entropy −Σ pₖ·ln(pₖ), normalized by ln(N) to [0,1]; conviction = 1 − entropy. The Attention Focus label shows the top-3 lags the head is "looking at" plus the effective number of analogues (1/Σp²).

🔶 SIGNAL LOGIC

• BUY — Trend Score crosses above +threshold (default 0.08) with conviction above the floor.
• SELL — Trend Score crosses below −threshold with the same conviction requirement.
• Every signal must additionally pass: signal cooldown (default 5 bars), position-state filter (no stacked same-direction signals), optional HTF EMA(21) trend confirm (last confirmed HTF bar, lookahead off — non-repainting), session filter, news blackout, prop-firm lockout, and the max-signals-per-day consistency cap.
• All signals are evaluated on confirmed bars only (barstate.isconfirmed) — no repainting.
• On each signal the script draws the entry (gold), stop (dashed) and target (dashed) lines with size, SL and TP labels; the last 3 trade line-sets are kept on chart (configurable).

🔶 PROP FIRM ENGINE

Presets load the firm's headline limits; your Risk per Trade % input always rules sizing.

| Preset  | Daily Loss | Max Drawdown    | Suggested Risk |
|---------|-----------|------------------|----------------|
| FTMO    | 5.0%      | 10.0%            | 1.0%           |
| Topstep | 2.0%      | 4.0%             | 0.5%           |
| Apex    | 2.5%      | 5.0% (trailing)  | 0.5%           |
| Custom  | your input | your input      | your input     |

• Sizing — risk$ = account × risk%. SL distance = ATR(14) × multiplier (default 1.5). Contracts = risk$ / (SL distance × point value); forex symbols are converted to standard lots, futures/stocks shown as whole contracts.
• Simulated R tracking — one simulated trade at a time at the signal price; each confirmed bar checks SL before TP (conservative). A loss books −1R, a win books +R:R (default +2R) into the daily ledger.
• Daily lockout — when daily R reaches −(daily loss % / risk per trade %), signals stop and the chart background turns orange until the next session day.
• Trailing DD breach — cumulative R is tracked against its peak; if the drawdown in R exceeds the preset's max-drawdown budget, status flips to DD BREACH and signals stop.
• Consistency cap — Max Signals / Day (default 5); the counter resets on each new session day.

🔶 INPUTS

• Algorithm — Attention Lookback N (16–200), Softmax Temperature, Score Smoothing EMA, Volume Z-Score Window.
• Signal Logic — Score Threshold, Conviction Floor, Signal Cooldown Bars, HTF Trend Confirm + HTF Timeframe.
• Prop Firm Rules — Preset (FTMO/Topstep/Apex/Custom), Account Size $, Risk per Trade %, three Custom limit inputs, Max Signals / Day.
• Sessions & News — Session Filter (Off/London/New York/RTH Futures/Custom), Custom Session, News Blackout toggle + two news windows.
• Trade Management — Stop Loss ATR multiple, Reward:Risk, Trade Line Length, Keep Last N Trade Drawings.
• Visual — Dashboard, 3-Layer Signal Glow, Trend Baseline Ribbon, Attention Focus Label, and all colors.

🔶 ALERTS

Webhook-ready alert() JSON fires on every buy/sell close with action, ticker, price, SL, TP, size and daily R. Ten named alert conditions:

1. AGZ Buy
2. AGZ Sell
3. AGZ Any Signal
4. AGZ Regime Bull (score crosses above zero)
5. AGZ Regime Bear (score crosses below zero)
6. AGZ High Conviction (conviction exceeds 50%)
7. AGZ Lockout (daily-loss or drawdown limit hit)
8. AGZ Session Open
9. AGZ Daily Reset
10. AGZ Webhook JSON (placeholder-based JSON payload)

🔶 LIMITATIONS

• Attention finds analogues, not certainties. "What happened after similar states" is a statistical tendency — it is NOT a prediction guarantee, and regimes with no good historical analogue produce low-conviction, low-quality readings.
• The simulated R ledger is indicative only: it fills at the signal close, ignores spread, slippage, commissions and gaps, and resolves SL-before-TP inside a bar. It is a discipline gauge, not broker P&L — your real account ledger always rules.
• Position sizing relies on syminfo.pointvalue; for CFDs and some exotic symbols verify the suggested size against your broker's contract specification before trading.
• Session and news windows use the chart symbol's exchange timezone; adjust the windows when trading symbols on other exchanges.
• On very short lookbacks or illiquid symbols the volume z-score feature degrades (stdev guard returns 0); the engine still works on the two price features.
• Signals are confirmed-bar only by design, so they appear at the close of the signal bar, never intrabar.
• This is an analysis tool, not financial advice. Past behavior of similar market states does not guarantee future results.

🔶 RELEASE NOTES

v1.0 — Initial release. Soft-attention trend engine (stable softmax, entropy-based conviction, top-3 attention focus readout), prop-firm risk engine with FTMO/Topstep/Apex/Custom presets, simulated R ledger with daily lockout and trailing DD breach, session + news filters, HTF confirm, trade line-sets, 12-row dashboard, webhook JSON alerts and 10 alert conditions.

#ftmo

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Argus Gaze applies transformer-style soft attention to the chart's own history.
// Each bar is encoded as a 3-feature state vector, fully ATR/z-normalized so the engine is
// symbol- and timeframe-agnostic: (1) directional thrust = 1-bar close change / ATR(14),
// (2) range expansion = (high-low)/ATR(14) - 1, (3) volume z-score over 50 bars.
// For every lag k in 1..N the squared Euclidean distance between TODAY's state and the state
// k bars ago becomes an attention logit sim_k = -d2_k / temperature. A numerically stable
// softmax (max-subtraction) turns logits into weights w_k. Every historical state carries a
// KNOWN outcome: the ATR-normalized return that followed it. The attention-weighted average
// of those outcomes is the forecast — "what happened last time the market looked like this".
// An EMA of the forecast is the Trend Score. Attention entropy (normalized by ln N) measures
// how FOCUSED the attention is: low entropy = few strongly similar analogues = high conviction.
// Signals fire when the score crosses a threshold with sufficient conviction, then pass through
// a full prop-firm risk engine (daily loss lockout, trailing DD, sizing, session/news filters).
indicator("Argus Gaze: Attention Trend Engine [forexobroker]", shorttitle="AGZ [fob]", overlay=true, max_bars_back=500, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════════
//  INPUT GROUPS
// ════════════════════════════════════════════════════════════════════════════════
string g_algo   = "Algorithm"
string g_signal = "Signal Logic"
string g_prop   = "Prop Firm Rules"
string g_sess   = "Sessions & News"
string g_trade  = "Trade Management"
string g_visual = "Visual"

// ── Algorithm ──────────────────────────────────────────────────────────────────
int   i_lookback = input.int(64, "Attention Lookback (N)", minval=16, maxval=200, group=g_algo, tooltip="How many historical states the attention head compares against the current bar. Larger N = richer memory but slower regime adaptation.")
float i_temp     = input.float(1.0, "Softmax Temperature", minval=0.1, maxval=10.0, step=0.1, group=g_algo, tooltip="Controls attention sharpness. Low temperature = attention collapses onto the few closest analogues (spiky). High temperature = attention spreads across many states (smooth).")
int   i_smooth   = input.int(5, "Score Smoothing (EMA)", minval=1, maxval=50, group=g_algo, tooltip="EMA length applied to the raw attention forecast to produce the Trend Score.")
int   i_volLen   = input.int(50, "Volume Z-Score Window", minval=10, maxval=200, group=g_algo, tooltip="Window for the volume mean/stdev used in feature 3 of the state vector.")

// ── Signal Logic ───────────────────────────────────────────────────────────────
float i_scoreThr  = input.float(0.08, "Score Threshold", minval=0.01, maxval=1.0, step=0.01, group=g_signal, tooltip="Trend Score must cross above +threshold (buy) or below -threshold (sell). Units are ATR-normalized expected return.")
float i_convFloor = input.float(0.05, "Conviction Floor", minval=0.0, maxval=0.9, step=0.05, group=g_signal, tooltip="Minimum attention conviction (1 - normalized entropy) required for a signal. Keep low/permissive; raise to demand sharply focused attention.")
int   i_cooldown  = input.int(5, "Signal Cooldown Bars", minval=1, maxval=100, group=g_signal, tooltip="Minimum bars between consecutive signals.")
bool  i_useMtf    = input.bool(false, "HTF Trend Confirm", group=g_signal, tooltip="Require price to be on the correct side of a higher-timeframe EMA(21). Uses the last CONFIRMED HTF value (lookahead off, offset 1) — non-repainting.")
string i_mtfTf    = input.timeframe("240", "HTF Timeframe", group=g_signal)

// ── Prop Firm Rules ────────────────────────────────────────────────────────────
string i_firm     = input.string("FTMO", "Prop Firm Preset", options=["FTMO", "Topstep", "Apex", "Custom"], group=g_prop, tooltip="Loads daily-loss and max-drawdown limits for the selected firm. Apex uses a trailing drawdown. Custom reads the three inputs below.")
float i_acct      = input.float(100000, "Account Size $", minval=1000, group=g_prop)
float i_riskPct   = input.float(1.0, "Risk per Trade %", minval=0.1, maxval=5.0, step=0.1, group=g_prop, tooltip="Percent of account risked per trade. Presets SUGGEST a value (FTMO 1.0 / Topstep 0.5 / Apex 0.5) but this input always rules.")
float i_dailyCust = input.float(4.0, "Custom: Daily Loss %", minval=0.5, maxval=20.0, step=0.5, group=g_prop, tooltip="Only used when Preset = Custom.")
float i_ddCust    = input.float(8.0, "Custom: Max Drawdown %", minval=1.0, maxval=50.0, step=0.5, group=g_prop, tooltip="Only used when Preset = Custom.")
float i_riskCust  = input.float(1.0, "Custom: Suggested Risk %", minval=0.1, maxval=5.0, step=0.1, group=g_prop, tooltip="Only used when Preset = Custom. Informational — shown on the dashboard.")
int   i_maxSignalsDay = input.int(5, "Max Signals / Day", minval=1, maxval=50, group=g_prop, tooltip="Consistency rule: no further signals after this many in one session day.")
bool  i_ddLock    = input.bool(false, "Lock Signals on Max DD Breach", group=g_prop, tooltip="OFF (default): a max-drawdown breach of the simulated R curve only shows DD BREACH on the dashboard. ON: it also suppresses signals until you reset the indicator. The daily-loss lockout always gates signals and auto-resets each day.")

// ── Sessions & News ────────────────────────────────────────────────────────────
string i_sessMode = input.string("Off", "Session Filter", options=["Off", "London", "New York", "RTH Futures", "Custom"], group=g_sess, tooltip="Restrict signals to a trading session (exchange timezone of the chart symbol).")
string i_sessCust = input.session("0800-1700", "Custom Session", group=g_sess)
bool   i_useNews  = input.bool(false, "Enable News Blackout", group=g_sess, tooltip="Block signals inside the two news windows below (e.g. CPI 08:30, FOMC 14:00 ET).")
string i_news1    = input.session("0825-0845", "News Window 1", group=g_sess)
string i_news2    = input.session("1355-1415", "News Window 2", group=g_sess)

// ── Trade Management ───────────────────────────────────────────────────────────
float i_slAtr     = input.float(1.5, "Stop Loss (ATR mult)", minval=0.5, maxval=10.0, step=0.1, group=g_trade, tooltip="SL distance = this multiple of ATR(14) from entry.")
float i_rr        = input.float(2.0, "Reward : Risk", minval=0.5, maxval=10.0, step=0.1, group=g_trade, tooltip="TP distance = SL distance x this ratio. Default 2.0 = 1:2 R:R.")
int   i_lineBars  = input.int(20, "Trade Line Length (bars)", minval=5, maxval=200, group=g_trade)
int   i_maxTrades = input.int(3, "Keep Last N Trade Drawings", minval=1, maxval=20, group=g_trade)

// ── Visual ─────────────────────────────────────────────────────────────────────
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool  i_showBase  = input.bool(true, "Show Trend Baseline Ribbon", group=g_visual)
bool  i_showAttn  = input.bool(true, "Show Attention Focus Label", group=g_visual, tooltip="Floating label showing WHERE the attention head is looking: the top-3 most similar historical lags, their weights, and the effective sample size.")
color i_buyColor  = input.color(#4ade80, "Buy Color", group=g_visual)
color i_sellColor = input.color(#f472b6, "Sell Color", group=g_visual)
color i_accent    = input.color(#22d3ee, "Accent (Cyan)", group=g_visual)
color i_gold      = input.color(#fbbf24, "Entry Line (Gold)", group=g_visual)
color c_white     = #ffffff
color c_orange    = #fb923c

// ════════════════════════════════════════════════════════════════════════════════
//  STATE VECTOR — 3 ATR/Z-NORMALIZED FEATURES PER BAR
// ════════════════════════════════════════════════════════════════════════════════
float atr14   = ta.atr(14)
float volMean = ta.sma(volume, i_volLen)
float volStd  = ta.stdev(volume, i_volLen)
float f1 = atr14 > 0 ? (close - nz(close[1], close)) / atr14 : 0.0
float f2 = atr14 > 0 ? (high - low) / atr14 - 1.0 : 0.0
float f3 = volStd > 0 ? (nz(volume) - volMean) / volStd : 0.0

// ════════════════════════════════════════════════════════════════════════════════
//  SOFT ATTENTION OVER HISTORICAL STATES
//  Pass 1: logits sim_k = -d2_k / T, track maxSim for numerical stability.
//  Pass 2: stable softmax weights, attention-weighted outcome, entropy, top-3 focus.
// ════════════════════════════════════════════════════════════════════════════════
int   N = i_lookback
float rawForecast = 0.0
float entropyNorm = 1.0
float effN  = 0.0
float topW1 = 0.0
float topW2 = 0.0
float topW3 = 0.0
int   topL1 = 0
int   topL2 = 0
int   topL3 = 0
if bar_index >= N + 2
    float[] sims = array.new_float()
    float[] outs = array.new_float()
    float maxSim = -1.0e18
    for k = 1 to N
        float df1 = f1 - nz(f1[k])
        float df2 = f2 - nz(f2[k])
        float df3 = f3 - nz(f3[k])
        float d2  = df1 * df1 + df2 * df2 + df3 * df3
        float simK = -d2 / i_temp
        // outcome that FOLLOWED state k: ATR-normalized return from bar k to bar k-1
        // (for k=1 this is the most recent completed return)
        float atrK = nz(atr14[k])
        float outK = atrK > 0 ? (nz(close[k - 1]) - nz(close[k])) / atrK : 0.0
        array.push(sims, simK)
        array.push(outs, outK)
        if simK > maxSim
            maxSim := simK
    // pass 2a: stable softmax denominator + weighted outcome
    float sumW = 0.0
    float wOut = 0.0
    int nS = array.size(sims)
    if nS > 0
        for j = 0 to nS - 1
            float wJ = math.exp(array.get(sims, j) - maxSim)
            sumW += wJ
            wOut += wJ * array.get(outs, j)
    // pass 2b: entropy, effective sample size, top-3 attention focus
    if sumW > 0 and nS > 0
        rawForecast := wOut / sumW
        float entAcc = 0.0
        float sumP2  = 0.0
        for j = 0 to nS - 1
            float pJ = math.exp(array.get(sims, j) - maxSim) / sumW
            sumP2 += pJ * pJ
            if pJ > 1.0e-12
                entAcc -= pJ * math.log(pJ)
            if pJ > topW1
                topW3 := topW2
                topL3 := topL2
                topW2 := topW1
                topL2 := topL1
                topW1 := pJ
                topL1 := j + 1
            else if pJ > topW2
                topW3 := topW2
                topL3 := topL2
                topW2 := pJ
                topL2 := j + 1
            else if pJ > topW3
                topW3 := pJ
                topL3 := j + 1
        entropyNorm := entAcc / math.log(N)
        effN := sumP2 > 0 ? 1.0 / sumP2 : 0.0

// Trend Score + Conviction — both at global scope so plots/alerts stay legal
float score      = ta.ema(rawForecast, i_smooth)
float conviction = math.max(0.0, math.min(1.0, 1.0 - entropyNorm))
int   regime     = score > i_scoreThr ? 1 : score < -i_scoreThr ? -1 : 0

// Raw triggers — every ta.* cross call lives at top level, assigned to a bool
bool scoreCrossUp = ta.crossover(score, i_scoreThr)
bool scoreCrossDn = ta.crossunder(score, -i_scoreThr)
bool regimeBullX  = ta.crossover(score, 0.0)
bool regimeBearX  = ta.crossunder(score, 0.0)
bool buyTrigger   = scoreCrossUp and conviction > i_convFloor
bool sellTrigger  = scoreCrossDn and conviction > i_convFloor

// ── HTF trend confirm (optional, non-repainting: confirmed HTF bar, lookahead off)
float ema21   = ta.ema(close, 21)
float htfEma  = request.security(syminfo.tickerid, i_mtfTf, ema21[1], lookahead=barmerge.lookahead_off)
bool mtfBullOk = not i_useMtf or close > nz(htfEma, close)
bool mtfBearOk = not i_useMtf or close < nz(htfEma, close)

// ════════════════════════════════════════════════════════════════════════════════
//  PROP-FIRM RISK ENGINE
// ════════════════════════════════════════════════════════════════════════════════
// Preset limits — switch arms are single-typed, evaluated at top level
float p_daily = switch i_firm
    "FTMO"    => 5.0
    "Topstep" => 2.0
    "Apex"    => 2.5
    => i_dailyCust
float p_maxDD = switch i_firm
    "FTMO"    => 10.0
    "Topstep" => 4.0
    "Apex"    => 5.0
    => i_ddCust
float p_riskSuggest = switch i_firm
    "FTMO"    => 1.0
    "Topstep" => 0.5
    "Apex"    => 0.5
    => i_riskCust

// ── Position sizing ────────────────────────────────────────────────────────────
float atrSafe     = math.max(nz(atr14, syminfo.mintick), syminfo.mintick)
float slDist      = i_slAtr * atrSafe
float riskDollars = i_acct * i_riskPct / 100.0
bool  isForex     = syminfo.type == "forex"
float perUnitRisk = slDist * syminfo.pointvalue
float contracts   = riskDollars / math.max(perUnitRisk, 1.0e-10)
float lots        = contracts / 100000.0
int   wholeCts    = math.max(math.floor(contracts), 0)
string sizeStr    = isForex ? str.tostring(lots, "#.##") + " lots" : str.tostring(wholeCts) + " contracts"

// ── Daily reset ────────────────────────────────────────────────────────────────
bool newDay = ta.change(time("D")) != 0
var float dailyR      = 0.0
var int   winsToday   = 0
var int   lossesToday = 0
var int   signalsToday = 0
if newDay
    dailyR := 0.0
    winsToday := 0
    lossesToday := 0
    signalsToday := 0

// ── Simulated R tracking — one open sim trade at a time, SL checked before TP ──
var float simEntry = na
var float simSL = na
var float simTP = na
var int   simDir = 0
var float cumR  = 0.0
var float peakR = 0.0
bool confirmed = barstate.isconfirmed
if simDir != 0 and confirmed
    if simDir == 1
        if low <= simSL
            dailyR -= 1.0
            cumR -= 1.0
            lossesToday += 1
            simDir := 0
        else if high >= simTP
            dailyR += i_rr
            cumR += i_rr
            winsToday += 1
            simDir := 0
    else
        if high >= simSL
            dailyR -= 1.0
            cumR -= 1.0
            lossesToday += 1
            simDir := 0
        else if low <= simTP
            dailyR += i_rr
            cumR += i_rr
            winsToday += 1
            simDir := 0
if cumR > peakR
    peakR := cumR

// ── Lockout logic: daily loss limit + max drawdown (trailing, in R units) ──────
float dailyLimitR = -(p_daily / i_riskPct)
float maxDDLimitR = p_maxDD / i_riskPct
float ddR = peakR - cumR
bool dayLocked   = dailyR <= dailyLimitR
bool ddLocked    = ddR >= maxDDLimitR
// Daily lockout always gates (auto-resets each day). DD breach gates only if the user opts in —
// a permanent all-history lock would otherwise silence the indicator forever once hit.
bool lockedOut   = dayLocked or (i_ddLock and ddLocked)
bool consistencyOk = signalsToday < i_maxSignalsDay

// ════════════════════════════════════════════════════════════════════════════════
//  SESSIONS & NEWS
// ════════════════════════════════════════════════════════════════════════════════
string sessStr = switch i_sessMode
    "London"      => "0300-1200"
    "New York"    => "0800-1700"
    "RTH Futures" => "0930-1600"
    "Custom"      => i_sessCust
    => "0000-2400"
int sessTime  = time(timeframe.period, sessStr)
int news1Time = time(timeframe.period, i_news1)
int news2Time = time(timeframe.period, i_news2)
bool inSession = i_sessMode == "Off" or not na(sessTime)
bool inNews    = i_useNews and (not na(news1Time) or not na(news2Time))

// ════════════════════════════════════════════════════════════════════════════════
//  SIGNAL ASSEMBLY
// ════════════════════════════════════════════════════════════════════════════════
var int posState = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool buySignal  = buyTrigger and mtfBullOk and inSession and not inNews and not lockedOut and consistencyOk and posState <= 0 and cooldownOk and confirmed
bool sellSignal = sellTrigger and mtfBearOk and inSession and not inNews and not lockedOut and consistencyOk and posState >= 0 and cooldownOk and confirmed

// Last-signal levels for dashboard + alerts
var float lastEntry = na
var float lastSL = na
var float lastTP = na
var int   lastDir = 0

// ════════════════════════════════════════════════════════════════════════════════
//  TRADE VISUALS — entry / SL / TP line sets, capped at last N trades
// ════════════════════════════════════════════════════════════════════════════════
var line[]  tradeLines  = array.new_line()
var label[] tradeLabels = array.new_label()

if buySignal or sellSignal
    int dir = buySignal ? 1 : -1
    float entryPx = close
    float slPx = dir == 1 ? entryPx - slDist : entryPx + slDist
    float tpPx = dir == 1 ? entryPx + slDist * i_rr : entryPx - slDist * i_rr
    // bookkeeping
    posState := dir
    lastSignalBar := bar_index
    signalsToday += 1
    lastEntry := entryPx
    lastSL := slPx
    lastTP := tpPx
    lastDir := dir
    // open simulated trade (only when flat)
    if simDir == 0
        simEntry := entryPx
        simSL := slPx
        simTP := tpPx
        simDir := dir
    // draw the trade line set
    color dirCol = dir == 1 ? i_buyColor : i_sellColor
    color oppCol = dir == 1 ? i_sellColor : i_buyColor
    line entryLn = line.new(bar_index, entryPx, bar_index + i_lineBars, entryPx, color=i_gold, width=2, style=line.style_solid)
    line slLn    = line.new(bar_index, slPx, bar_index + i_lineBars, slPx, color=oppCol, width=1, style=line.style_dashed)
    line tpLn    = line.new(bar_index, tpPx, bar_index + i_lineBars, tpPx, color=dirCol, width=1, style=line.style_dashed)
    array.push(tradeLines, entryLn)
    array.push(tradeLines, slLn)
    array.push(tradeLines, tpLn)
    string dirTxt = dir == 1 ? "LONG " : "SHORT "
    label entryLb = label.new(bar_index + i_lineBars, entryPx, dirTxt + sizeStr, style=label.style_label_left, color=color.new(i_gold, 20), textcolor=#000000, size=size.small)
    label tpLb    = label.new(bar_index + i_lineBars, tpPx, "TP " + str.tostring(i_rr, "#.#") + "R · " + str.tostring(tpPx, format.mintick), style=label.style_label_left, color=color.new(dirCol, 30), textcolor=c_white, size=size.small)
    label slLb    = label.new(bar_index + i_lineBars, slPx, "SL · " + str.tostring(slPx, format.mintick), style=label.style_label_left, color=color.new(oppCol, 30), textcolor=c_white, size=size.small)
    array.push(tradeLabels, entryLb)
    array.push(tradeLabels, tpLb)
    array.push(tradeLabels, slLb)
    // trim to last N trade drawings — while-loops self-guard against empty arrays
    while array.size(tradeLines) > i_maxTrades * 3
        line.delete(array.shift(tradeLines))
    while array.size(tradeLabels) > i_maxTrades * 3
        label.delete(array.shift(tradeLabels))

// ════════════════════════════════════════════════════════════════════════════════
//  ATTENTION FOCUS LABEL — where is the attention head looking right now?
// ════════════════════════════════════════════════════════════════════════════════
var label attnLabel = na
if i_showAttn and barstate.islast
    if not na(attnLabel)
        label.delete(attnLabel)
    string row1 = "ATTENTION FOCUS"
    string row2 = "\n#1  k=" + str.tostring(topL1) + " bars ago  (" + str.tostring(topW1 * 100, "#.#") + "%)"
    string row3 = "\n#2  k=" + str.tostring(topL2) + " bars ago  (" + str.tostring(topW2 * 100, "#.#") + "%)"
    string row4 = "\n#3  k=" + str.tostring(topL3) + " bars ago  (" + str.tostring(topW3 * 100, "#.#") + "%)"
    string row5 = "\nEff. analogues: " + str.tostring(effN, "#.#") + " / " + str.tostring(N)
    attnLabel := label.new(bar_index + 3, close, row1 + row2 + row3 + row4 + row5, style=label.style_label_left, color=color.new(#0b1220, 15), textcolor=i_accent, size=size.small)
else if not na(attnLabel)
    label.delete(attnLabel)
    attnLabel := na

// ════════════════════════════════════════════════════════════════════════════════
//  PLOTS — baseline ribbon, glow markers, bar/background tints (all global scope)
// ════════════════════════════════════════════════════════════════════════════════
color baseCol = score > 0 ? i_buyColor : i_sellColor
plot(i_showBase ? ema21 : na, "Trend Baseline Glow", color.new(baseCol, 75), 5)
plot(i_showBase ? ema21 : na, "Trend Baseline", color.new(baseCol, 0), 2)

plotshape(i_showGlow and buySignal, "Buy Glow Outer", shape.triangleup, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal, "Buy Glow Mid", shape.triangleup, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal, "Buy Signal", shape.triangleup, location.belowbar, color.new(i_buyColor, 0), size=size.normal, text="AGZ", textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow Outer", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow Mid", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal, "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0), size=size.normal, text="AGZ", textcolor=color.white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
color bgCol = lockedOut ? color.new(c_orange, 75) : score > i_scoreThr ? color.new(i_buyColor, 92) : score < -i_scoreThr ? color.new(i_sellColor, 92) : na
bgcolor(bgCol)

// ════════════════════════════════════════════════════════════════════════════════
//  DASHBOARD — 2 x 12, top right
// ════════════════════════════════════════════════════════════════════════════════
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 12, bgcolor=color.new(#0b1220, 15), border_color=color.new(c_white, 85), border_width=1)
    string regimeStr = regime == 1 ? "BULL" : regime == -1 ? "BEAR" : "NEUTRAL"
    color regimeCol = regime == 1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    string sessStat = inNews ? "NEWS" : inSession ? "ACTIVE" : "OFF"
    color sessCol = inNews ? c_orange : inSession ? i_buyColor : color.gray
    string statusStr = dayLocked ? "STAND DOWN" : i_ddLock and ddLocked ? "DD LOCKED" : ddLocked ? "DD WARN" : "TRADING"
    color statusCol = lockedOut ? #ff5252 : ddLocked ? c_orange : i_buyColor
    string slTpStr = na(lastSL) ? "—" : str.tostring(lastSL, format.mintick) + " / " + str.tostring(lastTP, format.mintick)
    color dailyRCol = dailyR >= 0 ? i_buyColor : i_sellColor
    table.cell(dash, 0, 0, "Argus Gaze", text_color=i_accent, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]", text_color=color.gray, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 1, "Regime", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeStr, text_color=regimeCol, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Trend Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(score, "#.###"), text_color=score >= 0 ? i_buyColor : i_sellColor, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Conviction", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(conviction * 100, "#.#") + "%", text_color=conviction > 0.5 ? i_accent : c_white, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Position Size", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, sizeStr, text_color=i_gold, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Risk / Trade", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, "$" + str.tostring(riskDollars, "#,###") + "  (" + i_firm + " sugg. " + str.tostring(p_riskSuggest, "#.#") + "%)", text_color=c_white, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 6, "Last SL / TP", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, slTpStr, text_color=c_white, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 7, "Daily R", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(dailyR, "#.##") + "R  (limit " + str.tostring(dailyLimitR, "#.#") + "R)", text_color=dailyRCol, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 8, "W / L Today", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(winsToday) + " / " + str.tostring(lossesToday), text_color=c_white, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 9, "Signals Today", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(signalsToday) + " / " + str.tostring(i_maxSignalsDay), text_color=consistencyOk ? c_white : c_orange, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 10, "Session", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, sessStat, text_color=sessCol, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 11, "Status", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 11, statusStr, text_color=statusCol, text_size=size.small, text_halign=text.align_right)

// ════════════════════════════════════════════════════════════════════════════════
//  ALERTS — webhook JSON on signal close + named alertconditions
// ════════════════════════════════════════════════════════════════════════════════
if buySignal
    string buyJson = '{"action":"BUY","indicator":"AGZ","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"sl":' + str.tostring(lastSL) + ',"tp":' + str.tostring(lastTP) + ',"size":"' + sizeStr + '","dailyR":' + str.tostring(dailyR, "#.##") + '}'
    alert(buyJson, alert.freq_once_per_bar_close)
if sellSignal
    string sellJson = '{"action":"SELL","indicator":"AGZ","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"sl":' + str.tostring(lastSL) + ',"tp":' + str.tostring(lastTP) + ',"size":"' + sizeStr + '","dailyR":' + str.tostring(dailyR, "#.##") + '}'
    alert(sellJson, alert.freq_once_per_bar_close)

// Event bools for state-change alerts (computed at top level)
bool highConvEvent  = conviction > 0.5 and nz(conviction[1]) <= 0.5
bool lockoutEvent   = lockedOut and not lockedOut[1]
bool sessionOpenEvt = inSession and not inSession[1]

alertcondition(buySignal, "AGZ Buy", "Argus Gaze bullish attention signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal, "AGZ Sell", "Argus Gaze bearish attention signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal, "AGZ Any Signal", "Argus Gaze signal (either direction) on {{ticker}} {{interval}} at {{close}}")
alertcondition(regimeBullX, "AGZ Regime Bull", "Argus Gaze trend score crossed above zero on {{ticker}} {{interval}} — bullish regime")
alertcondition(regimeBearX, "AGZ Regime Bear", "Argus Gaze trend score crossed below zero on {{ticker}} {{interval}} — bearish regime")
alertcondition(highConvEvent, "AGZ High Conviction", "Argus Gaze attention conviction exceeded 50% on {{ticker}} {{interval}} — attention is sharply focused")
alertcondition(lockoutEvent, "AGZ Lockout", "Argus Gaze prop-firm lockout engaged on {{ticker}} — daily loss or max drawdown limit hit, stand down")
alertcondition(sessionOpenEvt, "AGZ Session Open", "Argus Gaze session filter is now ACTIVE on {{ticker}} {{interval}}")
alertcondition(newDay, "AGZ Daily Reset", "Argus Gaze daily risk counters reset on {{ticker}} — new trading day")
alertcondition(buySignal or sellSignal, "AGZ Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"AGZ\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
