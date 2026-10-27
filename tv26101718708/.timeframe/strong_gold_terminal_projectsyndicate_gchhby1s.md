# Strong Gold Terminal | ProjectSyndicate

- url: https://www.tradingview.com/script/GcHHBy1S-Strong-Gold-Terminal-ProjectSyndicate/
- type: indicator
- pine_id: PUB;c504178e28a54b12896888b1f95f9f79
- version: 1.0

## Description

▪️Strong Gold Terminal is a control centre for gold traders that answers the three questions you ask on every bar — where are the levels, which way is the pressure, and what is the context — and puts the answers on the price chart itself, in one compact Bloomberg amber terminal. PDH, PDL, PWH, PWL, PMH, PML, the day / week / month opens, the daily pivots, ADR projections, session highs and lows and the round numbers are all tracked, ranked by distance, and read out with how far each one sits in ATR. "Key level" on its own is a list. This turns it into a sorted ladder that tells you which level price meets next and how much room is between here and there.

▪️Six cards sit on the chart with price still visible between them, and a strip of six gauge tiles runs across the top: price with its daily change, ADR used, the composite bull / bear pressure score, timeframe alignment, Supertrend status and the regime call. Nothing lives in a separate pane and the price scale is never touched. Every chart inside the cards is drawn from fixed-size table cells, so the terminal stays clean on a laptop and on an ultrawide monitor alike, and the whole read is rebuilt on every update so nothing drifts or clips on a live market.

▪️Most "gold dashboard" tools show you a handful of moving averages and a bias word. This one maps trend across five timeframes and six metrics at once, grades the regime, tracks all three trading sessions in New York time against the average daily range, builds a weekday profile from real history, and reads the macro backdrop — dollar, yields, equities, silver, volatility — through gold's usual relationships. It is built for XAUUSD and GC1! but works on any symbol, because every level, session and stat is computed from the chart you are on.

🎯 The Levels Ladder (the core). The first card sorts every key level by distance from price and shows the four nearest above and the four nearest below, with your current price lit white in the middle. Each row carries the level's price, its distance in dollars and its distance in ATR, so you read not just what is near but whether it is one volatility unit away or five. The pool is deep: previous day high / low / close, previous week high / low, previous month high / low, the day / week / month opens, the classic pivot set (PP, R1, R2, S1, S2), the ADR-projected high and low, the Asia / London / New York session highs and lows, and the nearest round numbers above and below. The six core levels, plus the day open, week open and pivot, are also drawn across the chart as labelled lines.

📊 The Bull / Bear Pressure Heatmap. The second card is a five-timeframe by six-metric grid that scores momentum from deep red to amber. The timeframes default to 15m, 1H, 4H, Daily and Weekly, and each one is read on six engines: Supertrend direction, how many of the 20 / 50 / 200 EMAs price sits above, RSI, the MACD histogram and its slope, ADX with DI direction, and position inside the 20-bar range. Every cell is scored from −1 to +1 and coloured by that score. The card totals each metric down the timeframes, totals each timeframe across the metrics, draws a bull bar against a bear bar, and names the strongest and weakest timeframe. Higher timeframes carry more weight in the composite by default, so a weekly flip counts for more than a 15-minute wobble.

🧭 Trend & Regime. The third card is the full trend engine on your chart timeframe. Supertrend level and distance in ATR, the EMA stack (20 / 50 / 200), ADX with DI direction, RSI, ATR with its percentile, Bollinger-band width with its percentile for squeeze detection, market structure from confirmed pivots (HH / HL / LH / LL), and 10-bar rate of change — each with a plain-English status badge. From those it calls the regime: Trend Bull, Trend Bear, Squeeze, Volatile or Range, so you know whether to trade with momentum, fade extremes, or wait for the coil to break. A footer shows the 1-day, 1-week, 1-month and 3-month changes.

🕐 Sessions & Range. The fourth card tracks Asia, London and New York in New York time: each session's high, low, range and state (pending, active or closed), plus today's live range. It shows how much of the average daily range is already spent, where price sits inside today's range, the gap at the open, the ADR projections, and a status line that names which session is live and whether there is room left to run or the day is already stretched past its ADR. All three session windows are adjustable.

📅 Weekday Stats. The fifth card builds a profile from the last 60 completed days (adjustable): for Monday through Friday it shows the average range, the up-close rate, how often the day broke the prior day's high and low, and the average open-to-close move. Today's weekday is marked, today's range is compared with its own weekday norm, and a line reports the PDH / PDL break odds, so you know before London opens whether this is historically a wide trending day or a tight one.

🌐 Macro Context. The sixth card reads the backdrop that moves gold: the Dollar Index, the US 10-year yield, the S&P 500, silver and the VIX, each with its last price, 1-day change, and 20-day return correlation to gold. Each one is tagged tailwind, headwind or neutral through its usual relationship with gold, a composite macro bar sums them into one read, and the gold / silver ratio is shown with a cheap / rich tag. The macro symbols are inputs, so you can swap any of them for the feed your plan supports.

📋 Bloomberg Amber Terminal. Black terminal background, amber headline strips, bold monospaced figures, a diverging red-through-dark-to-amber scale for the pressure and trend cells, a sequential brown-through-orange-to-red scale for range and drawdown heat, white for your current price, and gutters that match your chart background automatically. Three cards sit across the top and three across the bottom, with price in between. A top offset keeps the symbol legend clear of the titles and a bottom offset keeps the chart logo clear, both adjustable.

🔔 Native Alerts.

Break Above PDH / Break Below PDL — price closes through the previous day's high or low.
Break Above PWH / Break Below PWL — price closes through the previous week's high or low.
Supertrend Flip Up / Down — the chart-timeframe Supertrend changes direction.
Strong Bull / Bear Pressure — the composite pressure score crosses ±40.
ADR Exhausted — today's range reaches the average daily range.

🔧 Fully Customizable. Round-number step and ADR length; whether the levels and opens draw on the chart and how long the lines run; the three session windows and their time zone; the five pressure timeframes and whether higher timeframes are weighted more; Supertrend period and factor, the three EMA lengths, ADX / RSI / ATR lengths, the percentile lookback and the structure pivot strength; the weekday sample size; all five macro symbols and the correlation window; each of the six cards on or off; and full display sizing — cell width, row and KPI heights, three text sizes, top and bottom offsets, and gutter colour.

🎯 Why this is different. A levels tool draws a grid and stops. A dashboard tool prints a bias word with no evidence behind it. This one sorts every level by distance and volatility so you always know what price meets next, grades momentum across five timeframes and six metrics instead of one, separates the three sessions and measures them against the ADR, builds a real weekday profile from history, and reads the macro backdrop through gold's actual relationships — all on the chart, with the price scale untouched, rebuilt live on every bar.

🚀 Built for gold. XAUUSD and GC1! are the home market, but the round-number step, session windows, ADR length and macro symbols are all inputs, so the terminal adapts to silver, indices, FX and anything else that trades around levels and sessions. Set the round step to match the instrument (50 for gold, 1,000 for BTC, 0.01 for FX) and the rest follows.

💡 Cleanest setup: run it on a 5m–1H chart so the sessions, ADR and weekday stats have enough bars, keep all six cards on for the full control centre or switch off the ones you don't need, and give the correlation window and weekday sample a few days of history to fill. On very high timeframes raise the round-number step so single candles don't swallow several levels.

🎯 How To Use It: Two Approaches

Everything comes down to two reads: where is price relative to the levels, and is the pressure behind it or against it.

🧱 1) Trade the level with the pressure behind it

Use this when price is approaching a level from the Levels Ladder.

▪️Read the ladder. The nearest level above or below, and its distance in ATR, tells you the target and whether there is room to reach it before the next obstacle. A level less than half an ATR away is not a trade; a clear ATR of space is.
▪️Confirm the pressure. Check the Bull / Bear Pressure card and the Trend & Regime call. Price pushing into resistance with strong bull pressure across the higher timeframes and a Trend Bull regime is a continuation setup; price into support with bear pressure is the short mirror.
Trigger: the break or the rejection at the level, in the direction the pressure and regime agree on.
Target: the next level up the ladder, sized against its ATR distance.
Stand aside: when pressure and price disagree — strong bear pressure into support is a bounce to fade, not a breakout to chase.

⚡ 2) Trade the session and the range

Use this when you are timing an entry inside the day.

▪️Read the clock. The Sessions & Range card names the live session and shows how much of the ADR is already spent. Early in London with most of the ADR still available is room to run; late in New York with the range already past its ADR is mean-reversion territory, not breakout.
▪️Read the day. The Weekday Stats card tells you whether today is historically a wide trending weekday or a tight one, and today's range against its own weekday norm tells you if the move is already overextended for this day of the week.

Trigger: a session high / low break when the ADR still has room, or a fade back toward the open when the range is spent and the macro backdrop is neutral.
Watch: the macro card. A strong dollar or yield headwind on the day argues against chasing gold longs, however good the level looks.

✋ Stand down: when the terminal says wait

A Range or Squeeze regime with pressure near zero: no edge in either direction yet.
Price between levels with the nearest one more than a couple of ATR away: no level to trade against.
Most of the ADR already spent with the session late: the easy move is gone.
A macro headwind pulling against your direction: the context is fighting the setup.
Timeframes split roughly even on the pressure card: wait for alignment.

Rule of thumb: 🧱 Clear level ahead + pressure and regime agreeing + ADR room left → trade in the pressure's direction toward the next level. ⚡ Live session early + wide weekday + macro tailwind → favour continuation; late session + spent ADR + neutral macro → favour the fade. ❄️ Range regime, pressure near zero, ADR spent, or macro against you → stand down until the terminal lines up.

⚠️ IMPORTANT NOTICE: Strong Gold Terminal [Bloomberg] is an analysis and context tool, not a signal service or a promise that any level will react. The levels, pressure scores, regime calls, session stats, weekday profile and macro reads are descriptions of what price and the market have done, computed from the bars and history available on your chart and feed. They describe behaviour, not obligation. Correlations and weekday statistics need history to build and will read "—" until they have it; macro rows depend on the symbols your data plan supplies. Supertrend, structure and the pressure cells update on the live bar and a reading can change until that bar closes. This is decision support, not a trade trigger or financial advice. Always combine it with your own strategy, testing and risk management. Past behaviour does not guarantee future behaviour.

## Source Code

````pine
//@version=6

indicator("Strong Gold Terminal", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ───────────────────────────── INPUTS ─────────────────────────────
G_LV = "═══ LEVELS ═══"
i_roundStep = input.float(50.0, "Round-Number Step ($)", minval = 0.01, step = 1, group = G_LV, tooltip = "Nearest round level above and below price. 50 for gold spot, 1000 for BTC, 0.01 for FX.")
i_adrLen    = input.int(14, "ADR Length (days)", minval = 2, group = G_LV)
i_showLv    = input.bool(true, "Draw PDH / PDL / PWH / PWL / PMH / PML on the chart", group = G_LV)
i_showOp    = input.bool(true, "Draw Day / Week Open + Pivot", group = G_LV)
i_lvlBars   = input.int(60, "Line Length (bars)", minval = 5, maxval = 500, group = G_LV)

G_SE = "═══ SESSIONS (New York time) ═══"
i_tz     = input.string("America/New_York", "Session Time Zone", options = ["America/New_York", "Europe/London", "UTC", "Asia/Tokyo"], group = G_SE)
i_sAsia  = input.session("1900-0300", "Asia", group = G_SE)
i_sLon   = input.session("0300-1200", "London", group = G_SE)
i_sNY    = input.session("0800-1700", "New York", group = G_SE)

G_PR = "═══ PRESSURE HEATMAP ═══"
i_tf1 = input.timeframe("15", "Timeframe 1", group = G_PR)
i_tf2 = input.timeframe("60", "Timeframe 2", group = G_PR)
i_tf3 = input.timeframe("240", "Timeframe 3", group = G_PR)
i_tf4 = input.timeframe("D", "Timeframe 4", group = G_PR)
i_tf5 = input.timeframe("W", "Timeframe 5", group = G_PR)
i_wHi = input.bool(true, "Weight Higher Timeframes More", group = G_PR, tooltip = "Weights 1 · 1 · 1.5 · 2 · 2 for the composite pressure score. Untick for equal weights.")

G_TR = "═══ TREND ENGINE (chart timeframe) ═══"
i_stP   = input.int(10, "Supertrend ATR Period", minval = 1, inline = "st", group = G_TR)
i_stF   = input.float(3.0, "Factor", minval = 0.1, step = 0.1, inline = "st", group = G_TR)
i_ema1  = input.int(20, "EMA Fast", minval = 1, inline = "em", group = G_TR)
i_ema2  = input.int(50, "Mid", minval = 1, inline = "em", group = G_TR)
i_ema3  = input.int(200, "Slow", minval = 1, inline = "em", group = G_TR)
i_adxL  = input.int(14, "ADX / DI Length", minval = 1, group = G_TR)
i_rsiL  = input.int(14, "RSI Length", minval = 1, group = G_TR)
i_atrL  = input.int(14, "ATR Length", minval = 1, group = G_TR)
i_pctL  = input.int(100, "Percentile Lookback (bars)", minval = 20, group = G_TR, tooltip = "ATR and Bollinger-width percentiles are ranked over this many bars.")
i_pivL  = input.int(5, "Structure Pivot Strength", minval = 1, group = G_TR)

G_ST = "═══ WEEKDAY STATS ═══"
i_statDays = input.int(60, "Sample (trading days)", minval = 10, maxval = 250, group = G_ST)

G_MA = "═══ MACRO CONTEXT ═══"
i_mDXY = input.symbol("TVC:DXY", "Dollar Index", group = G_MA)
i_mTNX = input.symbol("TVC:US10Y", "US 10Y Yield", group = G_MA)
i_mSPX = input.symbol("SP:SPX", "S&P 500", group = G_MA)
i_mXAG = input.symbol("OANDA:XAGUSD", "Silver", group = G_MA)
i_mVIX = input.symbol("TVC:VIX", "VIX", group = G_MA)
i_corrN = input.int(20, "Correlation Window (days)", minval = 5, maxval = 60, group = G_MA)

G_UI = "═══ DISPLAY ═══"
i_c1 = input.bool(true, "① Levels", inline = "c1", group = G_UI)
i_c2 = input.bool(true, "② Pressure", inline = "c1", group = G_UI)
i_c3 = input.bool(true, "③ Trend", inline = "c1", group = G_UI)
i_c4 = input.bool(true, "④ Sessions", inline = "c2", group = G_UI)
i_c5 = input.bool(true, "⑤ Weekdays", inline = "c2", group = G_UI)
i_c6 = input.bool(true, "⑥ Macro", inline = "c2", group = G_UI)
i_cw     = input.float(1.55, "Cell Width %", minval = 0.8, maxval = 3.0, step = 0.05, group = G_UI, tooltip = "Every card is 20 cells wide. 1.55% → each card ≈ 31% of the chart width.")
i_h      = input.float(2.4, "Row Height %", minval = 1.2, maxval = 5.0, step = 0.1, group = G_UI)
i_hv     = input.float(4.0, "KPI Value Row Height %", minval = 2.0, maxval = 8.0, step = 0.1, group = G_UI)
i_txt    = input.int(10, "Text Size", minval = 6, maxval = 16, group = G_UI)
i_txtT   = input.int(11, "Card Title Size", minval = 6, maxval = 20, group = G_UI)
i_txtV   = input.int(18, "KPI Value Size", minval = 8, maxval = 30, group = G_UI)
i_topOff = input.float(10.0, "Top Offset % (clears symbol legend)", minval = 0, maxval = 30, step = 0.5, group = G_UI)
i_botOff = input.float(3.0, "Bottom Offset % (clears TV logo)", minval = 0, maxval = 15, step = 0.5, group = G_UI)
i_gutA   = input.bool(true, "Gutters = Chart Background", inline = "gut", group = G_UI)
i_gutC   = input.color(#000000, "else", inline = "gut", group = G_UI)

// ───────────────────────── BLOOMBERG AMBER THEME ─────────────────────────
C_BG     = #0A0A0A
C_CARD   = #0E0B05
C_ROW_B  = #17110A
C_HDR_BG = #2A1C06
C_HEAD   = #FFC24D
C_AMBER  = #FFB000
C_SOFT   = #EBD3A2
C_DIM    = #D9B870
C_WHITE  = #F2F2F2
C_BLACK  = #0A0A0A
C_GOLD   = #FFD23F
C_RED    = #FF3B30
C_TRACK  = #251A08
C_GUT    = i_gutA ? chart.bg_color : i_gutC
C_NONE   = color.new(#000000, 100)
H1 = #3A2608
H2 = #8C5A00
H3 = #FF8C00
H4 = #E0221A
// bull / bear diverging scale, s in −1..+1
f_bbBg(float s) =>
    ss = math.max(-1.0, math.min(1.0, nz(s)))
    ss < 0 ? color.from_gradient(ss, -1.0, 0.0, #D61F1F, #1E1408) : ss < 0.5 ? color.from_gradient(ss, 0.0, 0.5, #1E1408, H2) : color.from_gradient(ss, 0.5, 1.0, H2, C_AMBER)
f_bbTx(float s) => nz(s) > 0.62 ? C_BLACK : nz(s) < -0.55 ? C_WHITE : #F5D58A
f_heatBg(float t) =>                      // sequential: dark → amber → orange → red
    tt = math.max(0.0, math.min(1.0, nz(t)))
    tt < 0.33 ? color.from_gradient(tt, 0.0, 0.33, #120D05, H1) : tt < 0.66 ? color.from_gradient(tt, 0.33, 0.66, H1, H2) : color.from_gradient(tt, 0.66, 1.0, H2, H3)
f_heatTx(float t) => nz(t) < 0.45 ? C_AMBER : nz(t) < 0.8 ? #FFF2D6 : C_BLACK
f_upDn(float v) => v > 0 ? C_AMBER : v < 0 ? C_RED : C_SOFT

// ───────────────────────── FORMATTERS ─────────────────────────
PXF = syminfo.mintick >= 0.5 ? "#,##0" : syminfo.mintick >= 0.05 ? "#,##0.0" : syminfo.mintick >= 0.005 ? "#,##0.00" : syminfo.mintick >= 0.0005 ? "#,##0.000" : "#,##0.00000"
f_px(float v) => na(v) ? "—" : str.tostring(v, PXF)
f_pxK(float v) => na(v) ? "—" : str.tostring(v, PXF)
f_pc(float v) => na(v) ? "—" : str.tostring(v, "+0.00;-0.00") + "%"
f_pc1(float v) => na(v) ? "—" : str.tostring(v, "+0.0;-0.0") + "%"
f_d(float v) => na(v) ? "—" : (v >= 0 ? "+" : "-") + str.tostring(math.abs(v), "#,##0.0")
f_n0(float v) => na(v) ? "—" : str.tostring(v, "0")
f_n1(float v) => na(v) ? "—" : str.tostring(v, "0.0")
f_atrD(float v) => na(v) ? "—" : str.tostring(v, "0.0") + "×"

// ───────────────────────── HIGHER-TIMEFRAME DATA ─────────────────────────
[pdh, pdl, pdc, dOpen, dHigh, dLow, dAtr, dDow1, pdh2, pdl2, pdo1] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1], open, high, low, ta.sma(high - low, i_adrLen)[1], dayofweek[1], high[2], low[2], open[1]], lookahead = barmerge.lookahead_off)
[pwh, pwl, wOpen] = request.security(syminfo.tickerid, "W", [high[1], low[1], open], lookahead = barmerge.lookahead_off)
[pmh, pml, mOpen] = request.security(syminfo.tickerid, "M", [high[1], low[1], open], lookahead = barmerge.lookahead_off)
[dC1, dC2, dC5, dC21, dC63] = request.security(syminfo.tickerid, "D", [close[1], close[2], close[5], close[21], close[63]], lookahead = barmerge.lookahead_off)
pp  = (pdh + pdl + pdc) / 3.0
r1  = 2.0 * pp - pdl
s1  = 2.0 * pp - pdh
r2  = pp + (pdh - pdl)
s2  = pp - (pdh - pdl)
adrH = dOpen + dAtr
adrL = dOpen - dAtr
rndUp = math.ceil(close / i_roundStep) * i_roundStep
rndDn = math.floor(close / i_roundStep) * i_roundStep
rndUp := rndUp == close ? rndUp + i_roundStep : rndUp
rndDn := rndDn == close ? rndDn - i_roundStep : rndDn
newDay = ta.change(time("D")) != 0

// ───────────────────────── SESSIONS ─────────────────────────
f_sess(string s) =>
    bool on = not na(time(timeframe.period, s, i_tz))
    bool st = on and not on[1]
    var float hi = na
    var float lo = na
    var int   state = 0           // 0 pending, 1 active, 2 closed
    if st
        hi := high
        lo := low
        state := 1
    else if on
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    else if on[1] and not on
        state := 2
    if newDay and not on
        state := 0
    [hi, lo, state]
[asH, asL, asS] = f_sess(i_sAsia)
[loH, loL, loS] = f_sess(i_sLon)
[nyH, nyL, nyS] = f_sess(i_sNY)
nyHour = hour(time, i_tz)
nyMin  = minute(time, i_tz)

// ───────────────────────── CHART-TIMEFRAME TREND ENGINE ─────────────────────────
[stLine, stDir] = ta.supertrend(i_stF, i_stP)
e1  = ta.ema(close, i_ema1)
e2  = ta.ema(close, i_ema2)
e3  = ta.ema(close, i_ema3)
[diP, diM, adx] = ta.dmi(i_adxL, i_adxL)
rsi = ta.rsi(close, i_rsiL)
atr = ta.atr(i_atrL)
[bbM, bbU, bbL] = ta.bb(close, 20, 2.0)
bbw = bbM > 0 ? (bbU - bbL) / bbM : na
atrPct = ta.percentrank(atr, i_pctL)
bbwPct = ta.percentrank(bbw, i_pctL)
roc10  = ta.roc(close, 10)
var int stBars = 0
stBars := stDir != stDir[1] ? 0 : stBars + 1
// market structure from confirmed pivots
ph = ta.pivothigh(high, i_pivL, i_pivL)
pl = ta.pivotlow(low, i_pivL, i_pivL)
var float lastPH = na
var float prevPH = na
var float lastPL = na
var float prevPL = na
if not na(ph)
    prevPH := lastPH
    lastPH := ph
if not na(pl)
    prevPL := lastPL
    lastPL := pl
bool hh = not na(lastPH) and not na(prevPH) and lastPH > prevPH
bool hl = not na(lastPL) and not na(prevPL) and lastPL > prevPL
string structTx = hh and hl ? "HH · HL" : hh ? "HH · LL" : hl ? "LH · HL" : "LH · LL"
float structS = (hh ? 0.5 : -0.5) + (hl ? 0.5 : -0.5)
int emaUp = (close > e1 ? 1 : 0) + (close > e2 ? 1 : 0) + (close > e3 ? 1 : 0)
bool stackBull = e1 > e2 and e2 > e3
bool stackBear = e1 < e2 and e2 < e3
string regime = adx >= 25 and stDir < 0 ? "TREND BULL" : adx >= 25 and stDir > 0 ? "TREND BEAR" : nz(bbwPct) < 20 ? "SQUEEZE" : nz(atrPct) > 80 ? "VOLATILE" : "RANGE"
color regCol = regime == "TREND BULL" ? C_AMBER : regime == "TREND BEAR" ? C_RED : regime == "SQUEEZE" ? C_GOLD : regime == "VOLATILE" ? H3 : C_SOFT

// ───────────────────────── PRESSURE HEATMAP (5 timeframes × 6 metrics) ─────────────────────────
f_m() =>
    [stl, std] = ta.supertrend(3.0, 10)
    ea = ta.ema(close, 20)
    eb = ta.ema(close, 50)
    ec = ta.ema(close, 200)
    r  = ta.rsi(close, 14)
    [ml, ms, mh] = ta.macd(close, 12, 26, 9)
    [dp, dm, ax] = ta.dmi(14, 14)
    hh20 = ta.highest(high, 20)
    ll20 = ta.lowest(low, 20)
    pos = hh20 > ll20 ? (close - ll20) / (hh20 - ll20) * 100.0 : 50.0
    nUp = (close > ea ? 1 : 0) + (close > eb ? 1 : 0) + (close > ec ? 1 : 0)
    [std, nUp, r, mh, mh - mh[1], ax, dp - dm, pos]
[st1, eu1, rs1, mh1, ms1, ax1, dd1, ps1] = request.security(syminfo.tickerid, i_tf1, f_m(), lookahead = barmerge.lookahead_off)
[st2, eu2, rs2, mh2, ms2, ax2, dd2, ps2] = request.security(syminfo.tickerid, i_tf2, f_m(), lookahead = barmerge.lookahead_off)
[st3, eu3, rs3, mh3, ms3, ax3, dd3, ps3] = request.security(syminfo.tickerid, i_tf3, f_m(), lookahead = barmerge.lookahead_off)
[st4, eu4, rs4, mh4, ms4, ax4, dd4, ps4] = request.security(syminfo.tickerid, i_tf4, f_m(), lookahead = barmerge.lookahead_off)
[st5, eu5, rs5, mh5, ms5, ax5, dd5, ps5] = request.security(syminfo.tickerid, i_tf5, f_m(), lookahead = barmerge.lookahead_off)
f_sST(float d) => d < 0 ? 1.0 : -1.0
f_sEMA(int n) => (n - 1.5) / 1.5
f_sRSI(float r) => math.max(-1.0, math.min(1.0, (r - 50.0) / 25.0))
f_sMACD(float h, float s) => h > 0 ? (s > 0 ? 1.0 : 0.5) : (s < 0 ? -1.0 : -0.5)
f_sADX(float a, float d) => (d > 0 ? 1.0 : -1.0) * math.min(nz(a) / 40.0, 1.0)
f_sPOS(float p) => (p - 50.0) / 50.0
f_tfScore(float st, int eu, float rs, float mh, float ms, float ax, float dd, float ps) =>
    (f_sST(st) + f_sEMA(eu) + f_sRSI(rs) + f_sMACD(mh, ms) + f_sADX(ax, dd) + f_sPOS(ps)) / 6.0
sc1 = f_tfScore(st1, eu1, rs1, mh1, ms1, ax1, dd1, ps1)
sc2 = f_tfScore(st2, eu2, rs2, mh2, ms2, ax2, dd2, ps2)
sc3 = f_tfScore(st3, eu3, rs3, mh3, ms3, ax3, dd3, ps3)
sc4 = f_tfScore(st4, eu4, rs4, mh4, ms4, ax4, dd4, ps4)
sc5 = f_tfScore(st5, eu5, rs5, mh5, ms5, ax5, dd5, ps5)
w1 = 1.0
w2 = 1.0
w3 = i_wHi ? 1.5 : 1.0
w4 = i_wHi ? 2.0 : 1.0
w5 = i_wHi ? 2.0 : 1.0
pressure = (nz(sc1) * w1 + nz(sc2) * w2 + nz(sc3) * w3 + nz(sc4) * w4 + nz(sc5) * w5) / (w1 + w2 + w3 + w4 + w5) * 100.0
int nBullTF = (nz(sc1) > 0.1 ? 1 : 0) + (nz(sc2) > 0.1 ? 1 : 0) + (nz(sc3) > 0.1 ? 1 : 0) + (nz(sc4) > 0.1 ? 1 : 0) + (nz(sc5) > 0.1 ? 1 : 0)
int nBearTF = (nz(sc1) < -0.1 ? 1 : 0) + (nz(sc2) < -0.1 ? 1 : 0) + (nz(sc3) < -0.1 ? 1 : 0) + (nz(sc4) < -0.1 ? 1 : 0) + (nz(sc5) < -0.1 ? 1 : 0)

// ───────────────────────── WEEKDAY STATS (last N completed days) ─────────────────────────
var array<float> wdDow = array.new_float(0)
var array<float> wdRng = array.new_float(0)
var array<float> wdUp  = array.new_float(0)
var array<float> wdHH  = array.new_float(0)
var array<float> wdHL  = array.new_float(0)
var array<float> wdMv  = array.new_float(0)
var array<float> wdOpn = array.new_float(0)
if newDay and not na(pdh) and not na(pdl) and not na(pdh2) and pdh != pdh[1]
    array.push(wdDow, dDow1)
    array.push(wdRng, pdh - pdl)
    array.push(wdUp, pdc > pdo1 ? 1.0 : 0.0)
    array.push(wdHH, pdh > pdh2 ? 1.0 : 0.0)
    array.push(wdHL, pdl < pdl2 ? 1.0 : 0.0)
    array.push(wdMv, pdo1 > 0 ? (pdc - pdo1) / pdo1 * 100.0 : 0.0)
    if array.size(wdDow) > i_statDays
        array.shift(wdDow)
        array.shift(wdRng)
        array.shift(wdUp)
        array.shift(wdHH)
        array.shift(wdHL)
        array.shift(wdMv)

// ───────────────────────── MACRO CONTEXT ─────────────────────────
[dxyC, dxyC1, dxyC2] = request.security(i_mDXY, "D", [close, close[1], close[2]], lookahead = barmerge.lookahead_off)
[tnxC, tnxC1, tnxC2] = request.security(i_mTNX, "D", [close, close[1], close[2]], lookahead = barmerge.lookahead_off)
[spxC, spxC1, spxC2] = request.security(i_mSPX, "D", [close, close[1], close[2]], lookahead = barmerge.lookahead_off)
[xagC, xagC1, xagC2] = request.security(i_mXAG, "D", [close, close[1], close[2]], lookahead = barmerge.lookahead_off)
[vixC, vixC1, vixC2] = request.security(i_mVIX, "D", [close, close[1], close[2]], lookahead = barmerge.lookahead_off)
var array<float> rG = array.new_float(0)
var array<float> rDXY = array.new_float(0)
var array<float> rTNX = array.new_float(0)
var array<float> rSPX = array.new_float(0)
var array<float> rXAG = array.new_float(0)
var array<float> rVIX = array.new_float(0)
f_ret(float a, float b) => b > 0 ? a / b - 1.0 : 0.0
if newDay and not na(dC1) and dC1 != dC1[1]
    array.push(rG, f_ret(dC1, dC2))
    array.push(rDXY, f_ret(dxyC1, dxyC2))
    array.push(rTNX, f_ret(tnxC1, tnxC2))
    array.push(rSPX, f_ret(spxC1, spxC2))
    array.push(rXAG, f_ret(xagC1, xagC2))
    array.push(rVIX, f_ret(vixC1, vixC2))
    if array.size(rG) > i_corrN
        array.shift(rG)
        array.shift(rDXY)
        array.shift(rTNX)
        array.shift(rSPX)
        array.shift(rXAG)
        array.shift(rVIX)
f_corr(array<float> a, array<float> b) =>
    int n = math.min(array.size(a), array.size(b))
    float r = na
    if n >= 5
        float sa = array.stdev(a)
        float sb = array.stdev(b)
        if sa > 0 and sb > 0
            r := array.covariance(a, b) / (sa * sb)
    r

// ───────────────────────── CHART LEVEL LINES ─────────────────────────
var line lPDH = na
var line lPDL = na
var line lPWH = na
var line lPWL = na
var line lPMH = na
var line lPML = na
var line lDO  = na
var line lWO  = na
var line lPP  = na
var label bPDH = na
var label bPDL = na
var label bPWH = na
var label bPWL = na
var label bPMH = na
var label bPML = na
var label bDO  = na
var label bWO  = na
var label bPP  = na
f_lv(line ln, label lb, float y, string tx, color c, string sty) =>
    line  l2 = ln
    label b2 = lb
    if na(l2)
        l2 := line.new(bar_index - i_lvlBars, y, bar_index, y, color = c, style = sty, width = 1)
        b2 := label.new(bar_index, y, tx, style = label.style_label_left, color = color.new(c, 100), textcolor = c, size = size.small)
    else
        line.set_xy1(l2, bar_index - i_lvlBars, y)
        line.set_xy2(l2, bar_index, y)
        label.set_xy(b2, bar_index, y)
        label.set_text(b2, tx)
    [l2, b2]
if barstate.islast and i_showLv
    [a1, a2] = f_lv(lPDH, bPDH, pdh, "PDH " + f_px(pdh), C_AMBER, line.style_solid)
    lPDH := a1
    bPDH := a2
    [c1, c2] = f_lv(lPDL, bPDL, pdl, "PDL " + f_px(pdl), C_AMBER, line.style_solid)
    lPDL := c1
    bPDL := c2
    [d1, d2] = f_lv(lPWH, bPWH, pwh, "PWH " + f_px(pwh), C_GOLD, line.style_dashed)
    lPWH := d1
    bPWH := d2
    [e1x, e2x] = f_lv(lPWL, bPWL, pwl, "PWL " + f_px(pwl), C_GOLD, line.style_dashed)
    lPWL := e1x
    bPWL := e2x
    [f1, f2] = f_lv(lPMH, bPMH, pmh, "PMH " + f_px(pmh), H3, line.style_dotted)
    lPMH := f1
    bPMH := f2
    [g1, g2] = f_lv(lPML, bPML, pml, "PML " + f_px(pml), H3, line.style_dotted)
    lPML := g1
    bPML := g2
if barstate.islast and i_showOp
    [h1x, h2x] = f_lv(lDO, bDO, dOpen, "DO " + f_px(dOpen), C_SOFT, line.style_dotted)
    lDO := h1x
    bDO := h2x
    [k1, k2] = f_lv(lWO, bWO, wOpen, "WO " + f_px(wOpen), C_SOFT, line.style_dotted)
    lWO := k1
    bWO := k2
    [m1, m2] = f_lv(lPP, bPP, pp, "PP " + f_px(pp), C_DIM, line.style_dashed)
    lPP := m1
    bPP := m2

// ───────────────────────── CARD HELPERS (20-cell grid) ─────────────────────────
NC = 20
f_c(table tb, int c, int r, string tx, color fg, color bg, string al, int sz, float h, bool bold) =>
    table.cell(tb, c, r, tx, width = i_cw, height = h, text_color = fg, bgcolor = bg, text_size = sz, text_halign = al, text_valign = text.align_center, text_font_family = font.family_monospace, text_formatting = bold ? text.format_bold : text.format_none)
f_span(table tb, int r, int c0, int c1, string tx, color fg, color bg, string al, int sz, float h, bool bold) =>
    for c = c0 to c1
        f_c(tb, c, r, c == c0 ? tx : "", fg, bg, al, sz, h, bold)
    if c1 > c0
        table.merge_cells(tb, c0, r, c1, r)
f_gapRow(table tb, int r, float h) =>
    for c = 0 to NC - 1
        table.cell(tb, c, r, " ", width = i_cw, height = h, text_color = C_NONE, bgcolor = C_NONE, text_size = 6)
f_tile(table tb, int c0, string lab, string val, color vc, float frac, color gc) =>
    f_span(tb, 1, c0, c0 + 9, lab, C_DIM, C_CARD, text.align_left, i_txt, i_h, true)
    f_span(tb, 2, c0, c0 + 9, val, vc, C_CARD, text.align_left, i_txtV, i_hv, true)
    int k = int(math.round(math.max(0.0, math.min(1.0, nz(frac))) * 10.0))
    for i = 0 to 9
        table.cell(tb, c0 + i, 3, " ", width = i_cw, height = math.max(0.5, i_h * 0.35), text_color = C_NONE, bgcolor = i < k ? gc : C_TRACK, text_size = 6)
f_title(table tb, int r, string title, string tag) =>
    f_span(tb, r, 0, 12, title, C_BLACK, C_AMBER, text.align_left, i_txtT, i_h, true)
    f_span(tb, r, 13, NC - 1, tag, C_BLACK, C_AMBER, text.align_right, i_txt - 1, i_h, false)
f_hdr(table tb, int r, int c0, int c1, string tx, string al) =>
    f_span(tb, r, c0, c1, tx, C_HEAD, C_HDR_BG, al, i_txt - 1, i_h, true)
f_foot(table tb, int r, array<string> labs, array<string> vals, array<color> cols) =>
    for g = 0 to 3
        f_span(tb, r, g * 5, g * 5 + 4, array.get(labs, g), C_DIM, C_HDR_BG, text.align_center, i_txt - 1, i_h, true)
        f_span(tb, r + 1, g * 5, g * 5 + 4, array.get(vals, g), array.get(cols, g), C_CARD, text.align_center, i_txt, i_h, true)
// horizontal bar across cells c0..c1 with fractional fill
f_bar(table tb, int r, int c0, int c1, float frac, color fillC, color trackC) =>
    int n = c1 - c0 + 1
    for j = 0 to n - 1
        float f = math.max(0.0, math.min(1.0, nz(frac) * n - j))
        f_c(tb, c0 + j, r, " ", C_NONE, color.from_gradient(f, 0.0, 1.0, trackC, fillC), text.align_center, 6, i_h, false)

// ───────────────────────── RENDER ─────────────────────────
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
    float dChg = pdc > 0 ? (close / pdc - 1.0) * 100.0 : na
    float todayRng = dHigh - dLow
    float adrUsed = dAtr > 0 ? todayRng / dAtr : na
    float gap = pdc > 0 ? (dOpen - pdc) : na
    string clock = (nyHour < 10 ? "0" : "") + str.tostring(nyHour) + ":" + (nyMin < 10 ? "0" : "") + str.tostring(nyMin)
    string tfTx = timeframe.period

    // ══════════ ① LEVELS LADDER (top left) ══════════
    if i_c1
        t1 := table.new(position.top_left, NC, 17, C_NONE, C_GUT, 0, C_GUT, 1)
        f_gapRow(t1, 0, i_topOff)
        f_tile(t1, 0, syminfo.ticker + " · " + tfTx + " · 1D " + f_pc(dChg), f_pxK(close), nz(dChg) >= 0 ? C_AMBER : C_RED, math.abs(nz(dChg)) / 2.0, nz(dChg) >= 0 ? C_AMBER : C_RED)
        color adrC = nz(adrUsed) >= 1.0 ? C_RED : nz(adrUsed) >= 0.7 ? H3 : C_AMBER
        f_tile(t1, 10, "ADR USED · " + f_pxK(todayRng) + " of " + f_pxK(dAtr), na(adrUsed) ? "—" : str.tostring(adrUsed * 100.0, "0") + "%", adrC, adrUsed, adrC)
        f_title(t1, 4, "① Levels Ladder", "ADR " + f_pxK(dAtr))
        // build the level list
        names = array.from("PDH", "PDL", "PDC", "PWH", "PWL", "PMH", "PML", "D OPN", "W OPN", "M OPN", "PP", "R1", "S1", "R2", "S2", "ADR+", "ADR−", "ASIA H", "ASIA L", "LON H", "LON L", "NY H", "NY L", "RND+", "RND−")
        vals  = array.from(pdh, pdl, pdc, pwh, pwl, pmh, pml, dOpen, wOpen, mOpen, pp, r1, s1, r2, s2, adrH, adrL, asH, asL, loH, loL, nyH, nyL, rndUp, rndDn)
        int nL = array.size(vals)
        // four nearest above (closest first) and four nearest below
        upIdx = array.new_int(0)
        dnIdx = array.new_int(0)
        for q = 0 to 3
            int bi = -1
            float bd = 1e18
            for i = 0 to nL - 1
                float v = array.get(vals, i)
                if not na(v) and v > close and v - close < bd and not array.includes(upIdx, i)
                    bi := i
                    bd := v - close
            if bi >= 0
                array.push(upIdx, bi)
            int bj = -1
            float bdj = 1e18
            for i = 0 to nL - 1
                float v = array.get(vals, i)
                if not na(v) and v <= close and close - v < bdj and not array.includes(dnIdx, i)
                    bj := i
                    bdj := close - v
            if bj >= 0
                array.push(dnIdx, bj)
        f_hdr(t1, 5, 0, 6, "LEVEL", text.align_left)
        f_hdr(t1, 5, 7, 11, "PRICE", text.align_right)
        f_hdr(t1, 5, 12, 15, "DIST $", text.align_right)
        f_hdr(t1, 5, 16, 19, "ADR", text.align_right)
        for q = 0 to 3
            int r = 9 - q                       // 4 above: row 6 farthest … row 9 nearest
            bool has = q < array.size(upIdx)
            int i = has ? array.get(upIdx, q) : 0
            float v = has ? array.get(vals, i) : na
            float dist = v - close
            float t = dist / math.max(dAtr, 1e-9)
            color rb = q % 2 == 0 ? C_CARD : C_ROW_B
            f_span(t1, r, 0, 6, has ? array.get(names, i) : "—", C_AMBER, rb, text.align_left, i_txt, i_h, true)
            f_span(t1, r, 7, 11, f_pxK(v), C_SOFT, rb, text.align_right, i_txt, i_h, false)
            f_span(t1, r, 12, 15, f_d(dist), C_AMBER, rb, text.align_right, i_txt, i_h, false)
            f_span(t1, r, 16, 19, f_atrD(t), f_heatTx(1.0 - math.min(math.abs(nz(t)), 1.0)), f_heatBg(1.0 - math.min(math.abs(nz(t, 9.0)), 1.0)), text.align_right, i_txt, i_h, false)
        f_span(t1, 10, 0, 6, "◉ " + syminfo.ticker, C_HEAD, C_HDR_BG, text.align_left, i_txt, i_h, true)
        f_span(t1, 10, 7, 11, f_pxK(close), C_SOFT, C_HDR_BG, text.align_right, i_txt, i_h, true)
        f_span(t1, 10, 12, 15, f_pc(dChg), nz(dChg) >= 0 ? C_AMBER : C_RED, C_HDR_BG, text.align_right, i_txt, i_h, true)
        f_span(t1, 10, 16, 19, "ATR " + f_n1(atr), C_SOFT, C_HDR_BG, text.align_right, i_txt, i_h, true)
        for q = 0 to 3
            int r = 11 + q                      // 4 below: row 11 nearest … row 14 farthest
            bool has = q < array.size(dnIdx)
            int i = has ? array.get(dnIdx, q) : 0
            float v = has ? array.get(vals, i) : na
            float dist = v - close
            float t = dist / math.max(dAtr, 1e-9)
            color rb = q % 2 == 0 ? C_CARD : C_ROW_B
            f_span(t1, r, 0, 6, has ? array.get(names, i) : "—", C_RED, rb, text.align_left, i_txt, i_h, true)
            f_span(t1, r, 7, 11, f_pxK(v), C_SOFT, rb, text.align_right, i_txt, i_h, false)
            f_span(t1, r, 12, 15, f_d(dist), C_RED, rb, text.align_right, i_txt, i_h, false)
            f_span(t1, r, 16, 19, f_atrD(math.abs(t)), f_heatTx(1.0 - math.min(math.abs(nz(t)), 1.0)), f_heatBg(1.0 - math.min(math.abs(nz(t, 9.0)), 1.0)), text.align_right, i_txt, i_h, false)
        f_foot(t1, 15, array.from("PDH", "PDL", "PWH", "PWL"), array.from(f_pxK(pdh), f_pxK(pdl), f_pxK(pwh), f_pxK(pwl)), array.from(close > pdh ? C_AMBER : C_SOFT, close < pdl ? C_RED : C_SOFT, close > pwh ? C_AMBER : C_SOFT, close < pwl ? C_RED : C_SOFT))

    // ══════════ ② BULL / BEAR PRESSURE HEATMAP (top center) ══════════
    if i_c2
        t2 := table.new(position.top_center, NC, 17, C_NONE, C_GUT, 0, C_GUT, 1)
        f_gapRow(t2, 0, i_topOff)
        color pC = pressure >= 20 ? C_AMBER : pressure <= -20 ? C_RED : C_SOFT
        f_tile(t2, 0, "PRESSURE SCORE · " + (pressure >= 40 ? "STRONG BULL" : pressure >= 15 ? "BULLISH" : pressure <= -40 ? "STRONG BEAR" : pressure <= -15 ? "BEARISH" : "NEUTRAL"), str.tostring(pressure, "+0;-0"), pC, (pressure + 100.0) / 200.0, pC)
        f_tile(t2, 10, "ALIGNMENT · " + str.tostring(nBullTF) + " BULL · " + str.tostring(nBearTF) + " BEAR", str.tostring(math.max(nBullTF, nBearTF)) + "/5 " + (nBullTF >= nBearTF ? "BULL" : "BEAR"), nBullTF > nBearTF ? C_AMBER : nBearTF > nBullTF ? C_RED : C_SOFT, math.max(nBullTF, nBearTF) / 5.0, nBullTF >= nBearTF ? C_AMBER : C_RED)
        f_title(t2, 4, "② Bull / Bear Pressure", "5 TF × 6 metrics")
        f_hdr(t2, 5, 0, 1, "TF", text.align_left)
        f_hdr(t2, 5, 2, 4, "SUPER", text.align_center)
        f_hdr(t2, 5, 5, 7, "EMA", text.align_center)
        f_hdr(t2, 5, 8, 9, "RSI", text.align_center)
        f_hdr(t2, 5, 10, 12, "MACD", text.align_center)
        f_hdr(t2, 5, 13, 15, "ADX", text.align_center)
        f_hdr(t2, 5, 16, 17, "POS", text.align_center)
        f_hdr(t2, 5, 18, 19, "SCR", text.align_center)
        tfs = array.from(i_tf1, i_tf2, i_tf3, i_tf4, i_tf5)
        float cST = 0.0
        float cEM = 0.0
        float cRS = 0.0
        float cMC = 0.0
        float cAX = 0.0
        float cPS = 0.0
        for k = 0 to 4
            float st = k == 0 ? st1 : k == 1 ? st2 : k == 2 ? st3 : k == 3 ? st4 : st5
            int   eu = k == 0 ? eu1 : k == 1 ? eu2 : k == 2 ? eu3 : k == 3 ? eu4 : eu5
            float rs = k == 0 ? rs1 : k == 1 ? rs2 : k == 2 ? rs3 : k == 3 ? rs4 : rs5
            float mh = k == 0 ? mh1 : k == 1 ? mh2 : k == 2 ? mh3 : k == 3 ? mh4 : mh5
            float ms = k == 0 ? ms1 : k == 1 ? ms2 : k == 2 ? ms3 : k == 3 ? ms4 : ms5
            float ax = k == 0 ? ax1 : k == 1 ? ax2 : k == 2 ? ax3 : k == 3 ? ax4 : ax5
            float dd = k == 0 ? dd1 : k == 1 ? dd2 : k == 2 ? dd3 : k == 3 ? dd4 : dd5
            float ps = k == 0 ? ps1 : k == 1 ? ps2 : k == 2 ? ps3 : k == 3 ? ps4 : ps5
            float sc = k == 0 ? sc1 : k == 1 ? sc2 : k == 2 ? sc3 : k == 3 ? sc4 : sc5
            float sST = f_sST(st)
            float sEM = f_sEMA(eu)
            float sRS = f_sRSI(rs)
            float sMC = f_sMACD(mh, ms)
            float sAX = f_sADX(ax, dd)
            float sPS = f_sPOS(ps)
            cST += sST
            cEM += sEM
            cRS += sRS
            cMC += sMC
            cAX += sAX
            cPS += sPS
            int r = 6 + k
            bool isChart = array.get(tfs, k) == timeframe.period
            f_span(t2, r, 0, 1, array.get(tfs, k), isChart ? C_BLACK : C_HEAD, isChart ? C_AMBER : C_HDR_BG, text.align_left, i_txt - 1, i_h, true)
            f_span(t2, r, 2, 4, st < 0 ? "UP" : "DOWN", f_bbTx(sST), f_bbBg(sST), text.align_center, i_txt, i_h, true)
            f_span(t2, r, 5, 7, str.tostring(eu) + "/3", f_bbTx(sEM), f_bbBg(sEM), text.align_center, i_txt, i_h, true)
            f_span(t2, r, 8, 9, f_n0(rs), f_bbTx(sRS), f_bbBg(sRS), text.align_center, i_txt, i_h, true)
            f_span(t2, r, 10, 12, (mh > 0 ? "+" : "−") + (ms > 0 ? "▲" : "▼"), f_bbTx(sMC), f_bbBg(sMC), text.align_center, i_txt, i_h, true)
            f_span(t2, r, 13, 15, f_n0(ax) + (dd > 0 ? "▲" : "▼"), f_bbTx(sAX), f_bbBg(sAX), text.align_center, i_txt, i_h, true)
            f_span(t2, r, 16, 17, f_n0(ps), f_bbTx(sPS), f_bbBg(sPS), text.align_center, i_txt, i_h, true)
            f_span(t2, r, 18, 19, str.tostring(nz(sc) * 100.0, "+0;-0"), f_bbTx(sc), f_bbBg(sc), text.align_center, i_txt, i_h, true)
        // metric totals across timeframes
        f_span(t2, 11, 0, 1, "ALL", C_HEAD, C_HDR_BG, text.align_left, i_txt - 1, i_h, true)
        f_span(t2, 11, 2, 4, str.tostring(cST / 5.0 * 100.0, "+0;-0"), f_bbTx(cST / 5.0), f_bbBg(cST / 5.0), text.align_center, i_txt, i_h, true)
        f_span(t2, 11, 5, 7, str.tostring(cEM / 5.0 * 100.0, "+0;-0"), f_bbTx(cEM / 5.0), f_bbBg(cEM / 5.0), text.align_center, i_txt, i_h, true)
        f_span(t2, 11, 8, 9, str.tostring(cRS / 5.0 * 100.0, "+0;-0"), f_bbTx(cRS / 5.0), f_bbBg(cRS / 5.0), text.align_center, i_txt, i_h, true)
        f_span(t2, 11, 10, 12, str.tostring(cMC / 5.0 * 100.0, "+0;-0"), f_bbTx(cMC / 5.0), f_bbBg(cMC / 5.0), text.align_center, i_txt, i_h, true)
        f_span(t2, 11, 13, 15, str.tostring(cAX / 5.0 * 100.0, "+0;-0"), f_bbTx(cAX / 5.0), f_bbBg(cAX / 5.0), text.align_center, i_txt, i_h, true)
        f_span(t2, 11, 16, 17, str.tostring(cPS / 5.0 * 100.0, "+0;-0"), f_bbTx(cPS / 5.0), f_bbBg(cPS / 5.0), text.align_center, i_txt, i_h, true)
        f_span(t2, 11, 18, 19, str.tostring(pressure, "+0;-0"), f_bbTx(pressure / 100.0), f_bbBg(pressure / 100.0), text.align_center, i_txt, i_h, true)
        // bull vs bear bars
        float bullF = (pressure + 100.0) / 200.0
        f_span(t2, 12, 0, 1, "BULL", C_AMBER, C_CARD, text.align_left, i_txt - 1, i_h, true)
        f_bar(t2, 12, 2, 19, bullF, C_AMBER, C_TRACK)
        f_span(t2, 13, 0, 1, "BEAR", C_RED, C_CARD, text.align_left, i_txt - 1, i_h, true)
        f_bar(t2, 13, 2, 19, 1.0 - bullF, #D61F1F, C_TRACK)
        f_span(t2, 14, 0, 19, "SUPER=Supertrend 10/3 · EMA=closes above 20/50/200 · POS=20-bar range", C_DIM, C_CARD, text.align_left, i_txt - 2, i_h, false)
        // strongest / weakest timeframe
        int kMax = 0
        int kMin = 0
        for k = 0 to 4
            float sc = k == 0 ? sc1 : k == 1 ? sc2 : k == 2 ? sc3 : k == 3 ? sc4 : sc5
            float scM = kMax == 0 ? sc1 : kMax == 1 ? sc2 : kMax == 2 ? sc3 : kMax == 3 ? sc4 : sc5
            float scm = kMin == 0 ? sc1 : kMin == 1 ? sc2 : kMin == 2 ? sc3 : kMin == 3 ? sc4 : sc5
            kMax := nz(sc) > nz(scM) ? k : kMax
            kMin := nz(sc) < nz(scm) ? k : kMin
        f_foot(t2, 15, array.from("BULL TFs", "BEAR TFs", "STRONGEST", "WEAKEST"), array.from(str.tostring(nBullTF) + " of 5", str.tostring(nBearTF) + " of 5", array.get(tfs, kMax), array.get(tfs, kMin)), array.from(C_AMBER, C_RED, C_AMBER, C_RED))

    // ══════════ ③ TREND & REGIME (top right) ══════════
    if i_c3
        t3 := table.new(position.top_right, NC, 17, C_NONE, C_GUT, 0, C_GUT, 1)
        f_gapRow(t3, 0, i_topOff)
        float stDist = atr > 0 ? math.abs(close - stLine) / atr : na
        f_tile(t3, 0, "SUPERTREND · " + tfTx + " · " + str.tostring(stBars) + " bars", (stDir < 0 ? "UP " : "DOWN ") + f_pxK(stLine), stDir < 0 ? C_AMBER : C_RED, math.min(nz(stDist) / 3.0, 1.0), stDir < 0 ? C_AMBER : C_RED)
        f_tile(t3, 10, "REGIME · ADX " + f_n0(adx) + " · ATR P" + f_n0(atrPct), regime, regCol, nz(adx) / 50.0, regCol)
        f_title(t3, 4, "③ Trend & Regime", tfTx + " engine")
        f_hdr(t3, 5, 0, 6, "COMPONENT", text.align_left)
        f_hdr(t3, 5, 7, 13, "VALUE", text.align_right)
        f_hdr(t3, 5, 14, 19, "STATUS", text.align_center)
        array<string> lab = array.from("Supertrend", "EMA " + str.tostring(i_ema1) + " / " + str.tostring(i_ema2), "EMA " + str.tostring(i_ema3), "ADX / DI", "RSI " + str.tostring(i_rsiL), "ATR " + str.tostring(i_atrL), "BB width", "Structure", "ROC 10")
        array<string> val = array.from((stDir < 0 ? "UP · " : "DOWN · ") + f_atrD(stDist) + " ATR", f_pxK(e1) + " / " + f_pxK(e2), f_pxK(e3) + " · " + f_pc(e3 > 0 ? (close / e3 - 1.0) * 100.0 : na), f_n0(adx) + " · " + (diP > diM ? "+DI" : "−DI"), f_n1(rsi), f_pxK(atr) + " · P" + f_n0(atrPct), f_n1(nz(bbw) * 100.0) + "% · P" + f_n0(bbwPct), f_pxK(lastPH) + " / " + f_pxK(lastPL), f_pc(roc10))
        array<string> stt = array.from(stDir < 0 ? "BULL" : "BEAR", stackBull ? "BULL STACK" : stackBear ? "BEAR STACK" : "MIXED", close > e3 ? "ABOVE" : "BELOW", adx >= 25 ? "TRENDING" : adx >= 18 ? "BUILDING" : "FLAT", rsi >= 70 ? "OVERBOUGHT" : rsi <= 30 ? "OVERSOLD" : rsi > 50 ? "BULL" : "BEAR", nz(atrPct) > 80 ? "HIGH VOL" : nz(atrPct) < 20 ? "LOW VOL" : "NORMAL", nz(bbwPct) < 20 ? "SQUEEZE" : nz(bbwPct) > 80 ? "EXPANDED" : "NORMAL", structTx, roc10 > 0 ? "RISING" : "FALLING")
        array<float> sco = array.from(stDir < 0 ? 1.0 : -1.0, stackBull ? 1.0 : stackBear ? -1.0 : 0.0, close > e3 ? 0.8 : -0.8, (diP > diM ? 1.0 : -1.0) * math.min(nz(adx) / 40.0, 1.0), f_sRSI(rsi), 0.0, 0.0, structS, roc10 > 0 ? 0.6 : -0.6)
        for r = 0 to 8
            color rb = r % 2 == 0 ? C_CARD : C_ROW_B
            float s = array.get(sco, r)
            string stx = array.get(stt, r)
            color bg = r == 5 ? f_heatBg(nz(atrPct) / 100.0) : r == 6 ? f_heatBg(1.0 - nz(bbwPct) / 100.0) : f_bbBg(s)
            color fg = r == 5 ? f_heatTx(nz(atrPct) / 100.0) : r == 6 ? f_heatTx(1.0 - nz(bbwPct) / 100.0) : f_bbTx(s)
            f_span(t3, 6 + r, 0, 6, array.get(lab, r), C_AMBER, rb, text.align_left, i_txt, i_h, true)
            f_span(t3, 6 + r, 7, 13, array.get(val, r), C_SOFT, rb, text.align_right, i_txt, i_h, false)
            f_span(t3, 6 + r, 14, 19, stx, fg, bg, text.align_center, i_txt, i_h, true)
        f_foot(t3, 15, array.from("1 DAY", "1 WEEK", "1 MONTH", "3 MONTHS"), array.from(f_pc(dChg), f_pc(dC5 > 0 ? (close / dC5 - 1.0) * 100.0 : na), f_pc(dC21 > 0 ? (close / dC21 - 1.0) * 100.0 : na), f_pc(dC63 > 0 ? (close / dC63 - 1.0) * 100.0 : na)), array.from(f_upDn(nz(dChg)), f_upDn(close - dC5), f_upDn(close - dC21), f_upDn(close - dC63)))

    // ══════════ ④ SESSIONS & RANGE (bottom left) ══════════
    if i_c4
        t4 := table.new(position.bottom_left, NC, 14, C_NONE, C_GUT, 0, C_GUT, 1)
        f_title(t4, 0, "④ Sessions & Range", "NY " + clock)
        f_hdr(t4, 1, 0, 5, "SESSION", text.align_left)
        f_hdr(t4, 1, 6, 9, "HIGH", text.align_right)
        f_hdr(t4, 1, 10, 13, "LOW", text.align_right)
        f_hdr(t4, 1, 14, 16, "RANGE", text.align_right)
        f_hdr(t4, 1, 17, 19, "STATE", text.align_center)
        array<string> sn = array.from("ASIA", "LONDON", "NEW YORK", "TODAY")
        array<float> sh = array.from(asH, loH, nyH, dHigh)
        array<float> sl = array.from(asL, loL, nyL, dLow)
        array<int> ss = array.from(asS, loS, nyS, 1)
        for r = 0 to 3
            int s = array.get(ss, r)
            color rb = r % 2 == 0 ? C_CARD : C_ROW_B
            float rng = array.get(sh, r) - array.get(sl, r)
            string stx = r == 3 ? "LIVE" : s == 1 ? "ACTIVE" : s == 2 ? "CLOSED" : "PENDING"
            color sbg = s == 1 ? C_AMBER : s == 2 ? C_HDR_BG : C_CARD
            color sfg = s == 1 ? C_BLACK : C_DIM
            f_span(t4, 2 + r, 0, 5, array.get(sn, r), r == 3 ? C_GOLD : C_AMBER, rb, text.align_left, i_txt - 1, i_h, true)
            f_span(t4, 2 + r, 6, 9, f_pxK(array.get(sh, r)), C_SOFT, rb, text.align_right, i_txt, i_h, false)
            f_span(t4, 2 + r, 10, 13, f_pxK(array.get(sl, r)), C_SOFT, rb, text.align_right, i_txt, i_h, false)
            f_span(t4, 2 + r, 14, 16, f_pxK(rng), f_heatTx(rng / math.max(dAtr, 1e-9) * 0.8), f_heatBg(rng / math.max(dAtr, 1e-9) * 0.8), text.align_right, i_txt, i_h, true)
            f_span(t4, 2 + r, 17, 19, stx, sfg, sbg, text.align_center, i_txt - 1, i_h, true)
        // ADR usage bar
        f_span(t4, 6, 0, 3, "ADR USED", C_DIM, C_CARD, text.align_left, i_txt - 1, i_h, true)
        f_bar(t4, 6, 4, 16, nz(adrUsed), nz(adrUsed) >= 1.0 ? H4 : C_AMBER, C_TRACK)
        f_span(t4, 6, 17, 19, na(adrUsed) ? "—" : str.tostring(adrUsed * 100.0, "0") + "%", nz(adrUsed) >= 1.0 ? C_RED : C_AMBER, C_CARD, text.align_right, i_txt, i_h, true)
        // where price sits inside today's range
        float dPos = dHigh > dLow ? (close - dLow) / (dHigh - dLow) : 0.5
        f_span(t4, 7, 0, 3, "IN RANGE", C_DIM, C_CARD, text.align_left, i_txt - 1, i_h, true)
        f_bar(t4, 7, 4, 16, dPos, C_GOLD, C_TRACK)
        f_span(t4, 7, 17, 19, str.tostring(dPos * 100.0, "0") + "%", C_GOLD, C_CARD, text.align_right, i_txt, i_h, true)
        // text rows
        f_span(t4, 8, 0, 9, "ADR " + str.tostring(i_adrLen) + " · " + f_pxK(dAtr), C_SOFT, C_CARD, text.align_left, i_txt, i_h, false)
        f_span(t4, 8, 10, 19, "LEFT " + (na(adrUsed) ? "—" : f_pxK(math.max(dAtr - todayRng, 0.0))), nz(adrUsed) >= 1.0 ? C_RED : C_SOFT, C_CARD, text.align_right, i_txt, i_h, false)
        f_span(t4, 9, 0, 9, "GAP AT OPEN " + f_d(gap), f_upDn(nz(gap)), C_ROW_B, text.align_left, i_txt, i_h, false)
        f_span(t4, 9, 10, 19, "ADR+ " + f_pxK(adrH) + " · ADR− " + f_pxK(adrL), C_SOFT, C_ROW_B, text.align_right, i_txt, i_h, false)
        string act = nyS == 1 and loS == 1 ? "LONDON + NY OVERLAP" : nyS == 1 ? "NEW YORK SESSION" : loS == 1 ? "LONDON SESSION" : asS == 1 ? "ASIA SESSION" : "BETWEEN SESSIONS"
        f_span(t4, 10, 0, 19, "NOW ▸ " + act + " · NY " + clock + " · " + (todayRng > dAtr ? "RANGE EXPANDED PAST ADR" : todayRng > 0.7 * dAtr ? "MOST OF ADR USED" : "ROOM TO RUN"), C_BLACK, C_AMBER, text.align_left, i_txt - 1, i_h, true)
        f_foot(t4, 11, array.from("ASIA RNG", "LONDON RNG", "NY RNG", "TODAY RNG"), array.from(f_pxK(asH - asL), f_pxK(loH - loL), f_pxK(nyH - nyL), f_pxK(todayRng)), array.from(C_SOFT, C_SOFT, C_SOFT, C_GOLD))
        f_gapRow(t4, 13, i_botOff)

    // ══════════ ⑤ WEEKDAY STATS (bottom center) ══════════
    if i_c5
        t5 := table.new(position.bottom_center, NC, 14, C_NONE, C_GUT, 0, C_GUT, 1)
        int nD = array.size(wdDow)
        f_title(t5, 0, "⑤ Weekday Stats", str.tostring(nD) + " days")
        f_hdr(t5, 1, 0, 3, "DAY", text.align_left)
        f_hdr(t5, 1, 4, 7, "AVG RNG", text.align_right)
        f_hdr(t5, 1, 8, 10, "UP %", text.align_center)
        f_hdr(t5, 1, 11, 13, "PDH %", text.align_center)
        f_hdr(t5, 1, 14, 16, "PDL %", text.align_center)
        f_hdr(t5, 1, 17, 19, "MOVE", text.align_right)
        array<string> dn = array.from("MON", "TUE", "WED", "THU", "FRI")
        float bestRng = 0.0
        int bestD = -1
        float bestUp = -1.0
        int bestU = -1
        float allRng = 0.0
        float allUp = 0.0
        float allHH = 0.0
        float allHL = 0.0
        float allN = 0.0
        int todayDow = dayofweek(time, i_tz)
        for d = 0 to 4
            float n = 0.0
            float sR = 0.0
            float sU = 0.0
            float sH = 0.0
            float sL = 0.0
            float sM = 0.0
            if nD > 0
                for i = 0 to nD - 1
                    if int(array.get(wdDow, i)) == d + 2
                        n += 1.0
                        sR += array.get(wdRng, i)
                        sU += array.get(wdUp, i)
                        sH += array.get(wdHH, i)
                        sL += array.get(wdHL, i)
                        sM += array.get(wdMv, i)
            float aR = n > 0 ? sR / n : na
            float aU = n > 0 ? sU / n : na
            float aH = n > 0 ? sH / n : na
            float aL = n > 0 ? sL / n : na
            float aM = n > 0 ? sM / n : na
            allRng += sR
            allUp += sU
            allHH += sH
            allHL += sL
            allN += n
            if nz(aR) > bestRng
                bestRng := aR
                bestD := d
            if nz(aU, -1.0) > bestUp
                bestUp := aU
                bestU := d
            bool isToday = todayDow == d + 2
            color rb = isToday ? C_HDR_BG : d % 2 == 0 ? C_CARD : C_ROW_B
            f_span(t5, 2 + d, 0, 3, (isToday ? "▶ " : "") + array.get(dn, d), isToday ? C_GOLD : C_AMBER, rb, text.align_left, i_txt, i_h, true)
            f_span(t5, 2 + d, 4, 7, f_pxK(aR), f_heatTx(nz(aR) / math.max(dAtr * 1.5, 1e-9)), f_heatBg(nz(aR) / math.max(dAtr * 1.5, 1e-9)), text.align_right, i_txt, i_h, true)
            f_span(t5, 2 + d, 8, 10, na(aU) ? "—" : f_n0(aU * 100.0), f_bbTx((nz(aU) - 0.5) * 3.0), f_bbBg((nz(aU) - 0.5) * 3.0), text.align_center, i_txt, i_h, true)
            f_span(t5, 2 + d, 11, 13, na(aH) ? "—" : f_n0(aH * 100.0), f_heatTx(nz(aH)), f_heatBg(nz(aH)), text.align_center, i_txt, i_h, true)
            f_span(t5, 2 + d, 14, 16, na(aL) ? "—" : f_n0(aL * 100.0), f_heatTx(nz(aL)), f_heatBg(nz(aL)), text.align_center, i_txt, i_h, true)
            f_span(t5, 2 + d, 17, 19, f_pc1(aM), f_upDn(nz(aM)), rb, text.align_right, i_txt, i_h, true)
        f_span(t5, 7, 0, 3, "ALL", C_HEAD, C_HDR_BG, text.align_left, i_txt, i_h, true)
        f_span(t5, 7, 4, 7, allN > 0 ? f_pxK(allRng / allN) : "—", C_SOFT, C_HDR_BG, text.align_right, i_txt, i_h, true)
        f_span(t5, 7, 8, 10, allN > 0 ? f_n0(allUp / allN * 100.0) : "—", C_SOFT, C_HDR_BG, text.align_center, i_txt, i_h, true)
        f_span(t5, 7, 11, 13, allN > 0 ? f_n0(allHH / allN * 100.0) : "—", C_SOFT, C_HDR_BG, text.align_center, i_txt, i_h, true)
        f_span(t5, 7, 14, 16, allN > 0 ? f_n0(allHL / allN * 100.0) : "—", C_SOFT, C_HDR_BG, text.align_center, i_txt, i_h, true)
        f_span(t5, 7, 17, 19, "", C_SOFT, C_HDR_BG, text.align_right, i_txt, i_h, true)
        f_span(t5, 8, 0, 19, "UP%=close>open · PDH/PDL%=broke prior day high/low · MOVE=open→close", C_DIM, C_CARD, text.align_left, i_txt - 2, i_h, false)
        // today vs its weekday norm
        int tdIdx = todayDow - 2
        float normRng = na
        if tdIdx >= 0 and tdIdx <= 4 and nD > 0
            float n2 = 0.0
            float s2r = 0.0
            for i = 0 to nD - 1
                if int(array.get(wdDow, i)) == todayDow
                    n2 += 1.0
                    s2r += array.get(wdRng, i)
            normRng := n2 > 0 ? s2r / n2 : na
        f_span(t5, 9, 0, 9, "TODAY vs " + (tdIdx >= 0 and tdIdx <= 4 ? array.get(dn, tdIdx) : "—") + " NORM", C_SOFT, C_ROW_B, text.align_left, i_txt, i_h, false)
        f_span(t5, 9, 10, 19, na(normRng) ? "—" : f_pxK(todayRng) + " of " + f_pxK(normRng) + " · " + str.tostring(todayRng / normRng * 100.0, "0") + "%", todayRng > nz(normRng) ? C_RED : C_AMBER, C_ROW_B, text.align_right, i_txt, i_h, true)
        f_span(t5, 10, 0, 19, "BREAK ODDS ▸ PDH " + (allN > 0 ? f_n0(allHH / allN * 100.0) + "%" : "—") + " · PDL " + (allN > 0 ? f_n0(allHL / allN * 100.0) + "%" : "—") + " · BOTH " + (allN > 0 ? f_n0(math.max(allHH / allN + allHL / allN - 1.0, 0.0) * 100.0) + "%" : "—") + " · NEITHER " + (allN > 0 ? f_n0(math.max(1.0 - allHH / allN - allHL / allN, 0.0) * 100.0) + "%" : "—"), C_BLACK, C_AMBER, text.align_left, i_txt - 1, i_h, true)
        f_foot(t5, 11, array.from("WIDEST DAY", "MOST UP", "PDH BREAKS", "PDL BREAKS"), array.from(bestD >= 0 ? array.get(dn, bestD) + " " + f_pxK(bestRng) : "—", bestU >= 0 ? array.get(dn, bestU) + " " + f_n0(bestUp * 100.0) + "%" : "—", allN > 0 ? f_n0(allHH / allN * 100.0) + "%" : "—", allN > 0 ? f_n0(allHL / allN * 100.0) + "%" : "—"), array.from(C_AMBER, C_AMBER, C_SOFT, C_SOFT))
        f_gapRow(t5, 13, i_botOff)

    // ══════════ ⑥ MACRO CONTEXT (bottom right) ══════════
    if i_c6
        t6 := table.new(position.bottom_right, NC, 14, C_NONE, C_GUT, 0, C_GUT, 1)
        f_title(t6, 0, "⑥ Macro Context", str.tostring(i_corrN) + "D corr")
        f_hdr(t6, 1, 0, 4, "ASSET", text.align_left)
        f_hdr(t6, 1, 5, 9, "LAST", text.align_right)
        f_hdr(t6, 1, 10, 12, "1D %", text.align_right)
        f_hdr(t6, 1, 13, 15, "CORR", text.align_center)
        f_hdr(t6, 1, 16, 19, "FOR GOLD", text.align_center)
        array<string> mn = array.from("DXY", "US 10Y", "S&P 500", "SILVER", "VIX")
        array<float> mc = array.from(dxyC, tnxC, spxC, xagC, vixC)
        array<float> mp = array.from(dxyC1, tnxC1, spxC1, xagC1, vixC1)
        array<float> mr = array.from(f_corr(rG, rDXY), f_corr(rG, rTNX), f_corr(rG, rSPX), f_corr(rG, rXAG), f_corr(rG, rVIX))
        array<float> inv = array.from(-1.0, -1.0, 0.0, 1.0, 0.5)     // typical relationship to gold
        float tail = 0.0
        float tailN = 0.0
        for r = 0 to 4
            float c = array.get(mc, r)
            float p = array.get(mp, r)
            float ch = p > 0 ? (c / p - 1.0) * 100.0 : na
            float cr = array.get(mr, r)
            float rel = array.get(inv, r)
            float sig = na(ch) ? 0.0 : math.max(-1.0, math.min(1.0, ch * rel * (r == 1 ? 0.5 : r == 4 ? 0.2 : 1.5)))
            if rel != 0 and not na(ch)
                tail += sig
                tailN += 1.0
            color rb = r % 2 == 0 ? C_CARD : C_ROW_B
            f_span(t6, 2 + r, 0, 4, array.get(mn, r), C_AMBER, rb, text.align_left, i_txt, i_h, true)
            f_span(t6, 2 + r, 5, 9, na(c) ? "n/a" : str.tostring(c, r == 1 ? "0.00" : "#,##0.0"), C_SOFT, rb, text.align_right, i_txt, i_h, false)
            f_span(t6, 2 + r, 10, 12, f_pc1(ch), f_upDn(nz(ch)), rb, text.align_right, i_txt, i_h, true)
            f_span(t6, 2 + r, 13, 15, na(cr) ? "—" : str.tostring(cr, "+0.00;-0.00"), f_bbTx(nz(cr)), f_bbBg(nz(cr)), text.align_center, i_txt, i_h, true)
            f_span(t6, 2 + r, 16, 19, rel == 0 ? "RISK" : sig > 0.3 ? "TAILWIND" : sig < -0.3 ? "HEADWIND" : "NEUTRAL", f_bbTx(sig), f_bbBg(sig), text.align_center, i_txt - 1, i_h, true)
        float gsr = xagC > 0 ? close / xagC : na
        f_span(t6, 7, 0, 9, "GOLD / SILVER RATIO", C_SOFT, C_HDR_BG, text.align_left, i_txt, i_h, true)
        f_span(t6, 7, 10, 19, f_n1(gsr) + (nz(gsr) > 85 ? " · SILVER CHEAP" : nz(gsr) < 65 ? " · SILVER RICH" : " · NORMAL"), C_GOLD, C_HDR_BG, text.align_right, i_txt, i_h, true)
        float tailS = tailN > 0 ? tail / tailN : 0.0
        f_span(t6, 8, 0, 4, "MACRO", C_DIM, C_CARD, text.align_left, i_txt - 1, i_h, true)
        f_bar(t6, 8, 5, 16, (tailS + 1.0) / 2.0, tailS >= 0 ? C_AMBER : #D61F1F, C_TRACK)
        f_span(t6, 8, 17, 19, str.tostring(tailS * 100.0, "+0;-0"), f_upDn(tailS), C_CARD, text.align_right, i_txt, i_h, true)
        f_span(t6, 9, 0, 19, "CORR " + str.tostring(i_corrN) + "D return correlation · FOR GOLD: today's move, usual link", C_DIM, C_CARD, text.align_left, i_txt - 2, i_h, false)
        string macroTx = tailS > 0.3 ? "MACRO TAILWIND ▸ dollar / yields helping gold today" : tailS < -0.3 ? "MACRO HEADWIND ▸ dollar / yields weighing on gold today" : "MACRO NEUTRAL ▸ no clear push from dollar or yields"
        f_span(t6, 10, 0, 19, macroTx, C_BLACK, tailS > 0.3 ? C_AMBER : tailS < -0.3 ? H4 : C_SOFT, text.align_left, i_txt - 1, i_h, true)
        f_foot(t6, 11, array.from("DXY CORR", "10Y CORR", "SILVER CORR", "SPX CORR"), array.from(na(array.get(mr, 0)) ? "—" : str.tostring(array.get(mr, 0), "+0.00;-0.00"), na(array.get(mr, 1)) ? "—" : str.tostring(array.get(mr, 1), "+0.00;-0.00"), na(array.get(mr, 3)) ? "—" : str.tostring(array.get(mr, 3), "+0.00;-0.00"), na(array.get(mr, 2)) ? "—" : str.tostring(array.get(mr, 2), "+0.00;-0.00")), array.from(f_upDn(nz(array.get(mr, 0))), f_upDn(nz(array.get(mr, 1))), f_upDn(nz(array.get(mr, 3))), f_upDn(nz(array.get(mr, 2)))))
        f_gapRow(t6, 13, i_botOff)

// ───────────────────────── ALERTS ─────────────────────────
alertcondition(ta.crossover(close, pdh), "Break Above PDH", "GOLD TERM: price broke above the previous day high")
alertcondition(ta.crossunder(close, pdl), "Break Below PDL", "GOLD TERM: price broke below the previous day low")
alertcondition(ta.crossover(close, pwh), "Break Above PWH", "GOLD TERM: price broke above the previous week high")
alertcondition(ta.crossunder(close, pwl), "Break Below PWL", "GOLD TERM: price broke below the previous week low")
alertcondition(stDir < 0 and stDir[1] > 0, "Supertrend Flip Up", "GOLD TERM: Supertrend flipped bullish")
alertcondition(stDir > 0 and stDir[1] < 0, "Supertrend Flip Down", "GOLD TERM: Supertrend flipped bearish")
alertcondition(pressure >= 40 and pressure[1] < 40, "Strong Bull Pressure", "GOLD TERM: composite pressure crossed +40")
alertcondition(pressure <= -40 and pressure[1] > -40, "Strong Bear Pressure", "GOLD TERM: composite pressure crossed −40")
alertcondition(dHigh - dLow >= dAtr and (dHigh - dLow)[1] < dAtr, "ADR Exhausted", "GOLD TERM: today's range reached the average daily range")
````
