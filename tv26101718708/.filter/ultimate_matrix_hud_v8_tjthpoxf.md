# Ultimate Matrix HUD v8

- url: https://www.tradingview.com/script/tjThpoxF-Ultimate-Matrix-HUD-v8/
- type: indicator
- pine_id: PUB;cd1857bc0e5946abab52b22ca114a0cc
- version: 2.0

## Description

🎯 Ultimate Matrix HUD — Multi-Symbol Direction + Sector Rotation Dashboard
What it is: An all-in-one heads-up display that answers three questions at a glance — Which way is my stock going? How much conviction is behind it? And is the money flowing into its sector? It scans up to 6 tickers of your choice plus ranks all 11 market sectors, right on your chart. Built for desktop and phone.

📊 What You're Looking At
The HUD has two panels:

1️⃣ Watchlist Panel — your 6 chosen tickers, one row each:

Column	Meaning
TICKER	The symbol being scanned
BIAS	Direction + conviction: 🟢 LONG / 🔴 SHORT (strong, ≥70%), 🟡 WEAK L/S (building, 40–69%), ⚪ NEUTRAL
REGIME	Market character: ⚡ DAY (volatile/intraday), 🌊 SWING (calm/trending), ➖ RANGE (chop)
TREND	A mini score-history sparkline (▁▂▃▄▅▆▇█) with an arrow — ↗ = conviction strengthening, → = flat/fading
SECTOR	The ticker's sector, its live rotation quadrant color, and rank (e.g. Tech 🟢#2)
2️⃣ Sector Rotation Panel — all 11 sectors ranked by relative strength:

Column	Meaning
SECTOR	Short label (Tech, Fin, Enrgy, Hlth, etc.)
QUADRANT	🟢 Leading, 🟡 Weakening, 🔴 Lagging, 🔵 Improving
STR/MOM	The two RRG axes — Strength / Momentum
RANK	Position 1–11, with 🥇🥈🥉 for the top three
🧠 How the Bias Score Works
Each ticker is graded 0–100% on four pillars:

Macro Trend (40 pts) — Higher-timeframe EMA structure (fast vs slow) confirms the big-picture direction.
Momentum (30 pts) — RSI in the healthy trend zone (not overextended).
Volume Confirmation (30 pts) — A volume spike in the direction of the move = real participation.
A score of ≥70% lights up 🟢 LONG or 🔴 SHORT. Between 40–69% it's a building 🟡 WEAK signal. Below that, ⚪ NEUTRAL.

🔄 How Sector Rotation Works (RRG Model)
Every sector is measured against a benchmark (default SPY, fully customizable) on two axes:

Strength — is it outperforming the benchmark over the long window?
Momentum — is that outperformance accelerating or fading?
Those two combine into the classic Relative Rotation Graph quadrants:

Quadrant	Meaning	Play
🟢 Leading	Strong and accelerating	Prime hunting ground for longs
🟡 Weakening	Strong but losing steam	Take profits / tighten stops
🔴 Lagging	Weak and still falling	Avoid longs / short candidates
🔵 Improving	Weak but turning up	Early rotation — watchlist for entries
Money typically rotates clockwise: Improving → Leading → Weakening → Lagging.

The STR/MOM column shows the two raw axes (e.g. 3.2 / 1.1 = outperforming and accelerating). Classic rotation flow is clockwise: Improving → Leading → Weakening → Lagging.

✅ The A+ Setup — Reading a Row in One Glance
The whole point is confluence. Your strongest trade lines up all three:

text
Copy
🟢 LONG (100%)  +  ▇█ ↗  +  Tech 🟢#1
    direction     conviction   money flow
That's a strong signal, still strengthening, in the #1 leading sector. Conversely, a 🟢 LONG whose sector reads 🔴#10 is a red flag — you'd be fighting the rotation.

⚙️ Setup (One-Time, ~2 Minutes)
Watchlist: Enter your 6 tickers and pick each one's sector from the dropdown. Set crypto/forex to None (their sector tag will show —).
Benchmark: Default SPY. Swap to QQQ (tech-relative), IWM (small-cap), or any symbol.
Mode: Choose Watchlist, Sector Rotation, or Both.
Display: Position, text size, transparency, colors, borders, and toggle any column on/off.
⚠️ Sector assignment is manual — Pine Script can't reliably auto-detect a stock's sector for scanned symbols. It's a 30-second, one-time setup and gives you 100% accurate, self-controlled tagging.

🔔 Discord Alerts (Optional)
The HUD can push formatted alerts to Discord on two events:

Bias Flip — a ticker crosses into 🟢 LONG or 🔴 SHORT
Momentum Strengthening — conviction starts accelerating (↗)
Each alert includes the ticker, bias, regime, trend, and its sector context:

text
Copy
NASDAQ:AAPL
Bias: 🟢 LONG (100%)
Regime: ⚡ DAY
Trend: ▇█ ↗
Sector: Tech 🟢#2
To wire it up:

In Discord: Server Settings → Integrations → Webhooks → New Webhook, copy the URL.
In TradingView: click the alarm clock ⏰ → Create Alert on this indicator.
Set Condition = Ultimate Matrix HUD, and under Notifications → Webhook URL, paste your Discord webhook.
Set the alert message to {{plot}} or leave default — the indicator sends its own JSON payload.
Alerts fire on bar close for reliability (no repaint-driven false pings).

📱 Mobile Tips
Set Text Size = Tiny/Small and bump Panel Transparency so price stays visible.
Hide columns you don't need (Regime, Trend, or Sector) to slim the panel.
Use Watchlist-only mode on phone for the cleanest view; switch to Both on desktop.
⚠️ Important Notes & Limitations
Live-bar values are provisional. All scores, ranks, and quadrants settle on bar close — treat the forming bar as an estimate.
Not financial advice. This is a decision-support dashboard, not a signal-to-blindly-trade. Always confirm with your own analysis and risk management.
Sector features are equity-focused. Set non-equity symbols (crypto/forex) to None.
Best on liquid symbols with real volume data — thinly traded names may give noisy volume/regime reads.
Timeframe: Works on any, but shines on 15m–4H for swing/intraday. Benchmark & windows are fully tunable in settings.

## Source Code

````pine
//@version=6
indicator("Ultimate Matrix HUD v9.2", overlay=true, max_bars_back=500)

// =====================================================================
//  SECTOR CHEAT-SHEET FOR DEFAULT TICKERS  (set these in Watchlist inputs)
//  ---------------------------------------------------------------------
//   AAPL  -> Technology          TSLA  -> Consumer Disc.
//   NVDA  -> Technology          MSFT  -> Technology
//   BTCUSD-> None (crypto)       SPY   -> None (index/ETF)
//  ---------------------------------------------------------------------
//  Handy map for common swaps:
//   AMZN/HD/NKE/MCD -> Consumer Disc.   | JPM/BAC/GS/V/MA -> Financials
//   XOM/CVX/COP     -> Energy           | UNH/JNJ/LLY/PFE -> Health Care
//   GOOGL/META/NFLX/DIS -> Communications | CAT/BA/GE/UPS -> Industrials
//   PG/KO/PEP/COST  -> Consumer Staples | LIN/FCX/NEM    -> Materials
//   NEE/DUK/SO      -> Utilities        | PLD/AMT/O      -> Real Estate
//   Crypto / Forex / broad index ETFs   -> None  (shows "—")
// =====================================================================

// ============ MODE ============
grp_m = "Mode"
mode_in = input.string("Both", title="Dashboard Mode", options=["Watchlist","Sector Rotation","Both"], group=grp_m, tooltip="QUICK START\n• Watchlist = 6-ticker directional HUD (price, bias, regime, trend, sector).\n• Sector Rotation = 11 SPDR ETFs ranked by RRG quadrant vs benchmark.\n• Both = stacked (~24 data requests, under the 40 cap).\n\nBIAS: 🟢 LONG ≥70% / 🔴 SHORT ≥70% / 🟡 WEAK 40-69% / ⚪ NEUTRAL.\nA+ read = strong Bias + matching sector quadrant + ↗ strengthening.\nLive bar is provisional; values settle on bar close.")
show_wl  = mode_in == "Watchlist" or mode_in == "Both"
show_rot = mode_in == "Sector Rotation" or mode_in == "Both"

// ============ WATCHLIST INPUTS ============
grp_t = "Watchlist (6 slots)"
sym1 = input.symbol("NASDAQ:AAPL",    title="Ticker 1", group=grp_t, inline="1")
sc1  = input.string("Technology",     title="", options=["None","Technology","Financials","Energy","Health Care","Consumer Disc.","Consumer Staples","Industrials","Materials","Utilities","Real Estate","Communications"], group=grp_t, inline="1", tooltip="Manual sector for this ticker (Pine can't auto-detect it for external symbols). Links this row to the rotation panel's quadrant + rank. Use 'None' for crypto/forex/broad index ETFs → shows '—'. See the cheat-sheet comment at the top of the script.")
sym2 = input.symbol("NASDAQ:TSLA",    title="Ticker 2", group=grp_t, inline="2")
sc2  = input.string("Consumer Disc.", title="", options=["None","Technology","Financials","Energy","Health Care","Consumer Disc.","Consumer Staples","Industrials","Materials","Utilities","Real Estate","Communications"], group=grp_t, inline="2")
sym3 = input.symbol("BINANCE:BTCUSD", title="Ticker 3", group=grp_t, inline="3")
sc3  = input.string("None",           title="", options=["None","Technology","Financials","Energy","Health Care","Consumer Disc.","Consumer Staples","Industrials","Materials","Utilities","Real Estate","Communications"], group=grp_t, inline="3")
sym4 = input.symbol("NASDAQ:NVDA",    title="Ticker 4", group=grp_t, inline="4")
sc4  = input.string("Technology",     title="", options=["None","Technology","Financials","Energy","Health Care","Consumer Disc.","Consumer Staples","Industrials","Materials","Utilities","Real Estate","Communications"], group=grp_t, inline="4")
sym5 = input.symbol("NASDAQ:MSFT",    title="Ticker 5", group=grp_t, inline="5")
sc5  = input.string("Technology",     title="", options=["None","Technology","Financials","Energy","Health Care","Consumer Disc.","Consumer Staples","Industrials","Materials","Utilities","Real Estate","Communications"], group=grp_t, inline="5")
sym6 = input.symbol("AMEX:SPY",       title="Ticker 6", group=grp_t, inline="6")
sc6  = input.string("None",           title="", options=["None","Technology","Financials","Energy","Health Care","Consumer Disc.","Consumer Staples","Industrials","Materials","Utilities","Real Estate","Communications"], group=grp_t, inline="6")

// ============ ENGINE INPUTS ============
grp_s = "Engine Parameters"
htf_res  = input.timeframe("240", title="Macro Timeframe (HTF)", group=grp_s, tooltip="Higher timeframe for the trend pillar (EMA fast/slow). Drives the 40-pt trend weight in the bias score. Keep well above your chart TF for clean macro context.")
ema_fast = input.int(50,  title="Fast EMA", group=grp_s)
ema_slow = input.int(200, title="Slow EMA", group=grp_s)
vol_mult = input.float(1.5, title="Volume Spike Multiplier", group=grp_s)
spark_len= input.int(16, title="Sparkline History (bars)", minval=6, maxval=40, group=grp_s, tooltip="How many bars of net-score history the TREND column plots as block glyphs. The ↗ arrow means recent |score| momentum is building vs the first half of the window; → means flat/fading.")

// ============ SECTOR ROTATION INPUTS ============
grp_r = "Sector Rotation"
bench   = input.symbol("AMEX:SPY", title="Benchmark", group=grp_r)
rs_long = input.int(60, title="Strength Window (RS-Ratio)", minval=10, group=grp_r, tooltip="Long lookback for RS-Ratio (X-axis / STRENGTH). Higher = smoother, slower rotation reads.")
rs_short= input.int(20, title="Momentum Window (RS-Mom)",  minval=5,  group=grp_r, tooltip="Short lookback for RS-Momentum (Y-axis / MOMENTUM). Quadrant = sign of Strength × Momentum: 🟢 Leading / 🟡 Weakening / 🔴 Lagging / 🔵 Improving.")
rot_tf = input.timeframe("D", title="Rotation Timeframe", group=grp_r, tooltip="Locks the sector rotation scan to a fixed timeframe, independent of your chart. Default 'D' (Daily). Leave blank to follow the chart timeframe like before.")
sec1 = input.symbol("AMEX:XLK",  title="Technology",       group=grp_r)
sec2 = input.symbol("AMEX:XLF",  title="Financials",       group=grp_r)
sec3 = input.symbol("AMEX:XLE",  title="Energy",           group=grp_r)
sec4 = input.symbol("AMEX:XLV",  title="Health Care",      group=grp_r)
sec5 = input.symbol("AMEX:XLY",  title="Consumer Disc.",   group=grp_r)
sec6 = input.symbol("AMEX:XLP",  title="Consumer Staples", group=grp_r)
sec7 = input.symbol("AMEX:XLI",  title="Industrials",      group=grp_r)
sec8 = input.symbol("AMEX:XLB",  title="Materials",        group=grp_r)
sec9 = input.symbol("AMEX:XLU",  title="Utilities",        group=grp_r)
sec10= input.symbol("AMEX:XLRE", title="Real Estate",      group=grp_r)
sec11= input.symbol("AMEX:XLC",  title="Communications",   group=grp_r)

// ============ ALERTS ============
grp_a = "Alerts"
alrt_flip     = input.bool(true, title="Alert on Bias Flip (LONG/SHORT)", group=grp_a)
alrt_str      = input.bool(true, title="Alert on Momentum Strengthening (↗)", group=grp_a)
alrt_cooldown = input.int(0, title="Alert Cooldown (bars, 0 = off)", minval=0, group=grp_a, tooltip="Minimum bars between alerts per ticker. Stops choppy names from spamming the webhook.")

// ============ DISPLAY ============
grp_d = "Display"
compact  = input.bool(false, title="Compact Mode (mobile / tiny)", group=grp_d, tooltip="Forces tiny text and shows only Ticker + Price + Bias, hiding Regime/Trend/Sector columns.")
pos_in   = input.string("Top Right", title="Position", options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=grp_d)
size_in  = input.string("Small", title="Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grp_d)
panel_t  = input.int(10, title="Panel Transparency", minval=0, maxval=100, group=grp_d)
cell_t   = input.int(60, title="Cell Transparency", minval=0, maxval=100, group=grp_d)
hdr_col  = input.color(color.blue, title="Header Color", group=grp_d)
txt_col  = input.color(color.white, title="Text Color", group=grp_d)
show_frame  = input.bool(true, title="Show Borders", group=grp_d)
show_price  = input.bool(true, title="Show Price Column (WL)", group=grp_d)
show_chg    = input.bool(true, title="Show % Change next to Price (WL)", group=grp_d)
chg_mode = input.string("Bar", title="% Change Basis", options=["Bar","Day"], group=grp_d, tooltip="Bar = change vs the previous bar close on the chart timeframe (no extra data). Day = true session change vs the prior daily close (adds 6 data requests, only while Day is selected).")
show_regime = input.bool(true, title="Show Regime Column (WL)", group=grp_d)
show_spark  = input.bool(true, title="Show Score Trend Column (WL)", group=grp_d)
show_ctx    = input.bool(true, title="Show Sector Context Column (WL)", group=grp_d)

f_pos(p) =>
    p == "Top Right" ? position.top_right : p == "Top Center" ? position.top_center : p == "Top Left" ? position.top_left : p == "Middle Right" ? position.middle_right : p == "Middle Center" ? position.middle_center : p == "Middle Left" ? position.middle_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Center" ? position.bottom_center : position.bottom_left
f_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

// ---- Compact override: collapse to essentials + force tiny ----
eff_price  = show_price
eff_chg    = show_chg and not compact
eff_regime = show_regime and not compact
eff_spark  = show_spark  and not compact
eff_ctx    = show_ctx    and show_wl and not compact

t_size  = compact ? size.tiny : f_size(size_in)
brd_w   = show_frame ? 1 : 0
brd_col = show_frame ? color.new(color.gray, 80) : color.new(color.gray, 100)
ctx_on  = eff_ctx

// ============ STATE ============
var array<string> symbols  = array.from(sym1, sym2, sym3, sym4, sym5, sym6)
var array<string> secNames = array.from(sc1, sc2, sc3, sc4, sc5, sc6)
var array<string> sectors  = array.from(sec1,sec2,sec3,sec4,sec5,sec6,sec7,sec8,sec9,sec10,sec11)
var array<string> secLbls  = array.from("Tech","Fin","Enrgy","Hlth","Cons D","Cons S","Indus","Matls","Util","R.Est","Comms")
var array<string> blocks   = array.from("▁","▂","▃","▄","▅","▆","▇","█")
int numSyms = array.size(symbols)
int numSec  = array.size(sectors)
int rsCols  = rs_long + 2

var matrix<float> hist   = matrix.new<float>(numSyms, spark_len, 0.0)
var matrix<float> rsHist = matrix.new<float>(numSec, rsCols, na)
var array<int>   prevSide= array.new<int>(numSyms, 0)
var array<bool>  prevStr = array.new<bool>(numSyms, false)
var array<int>   lastAlertBar = array.new<int>(numSyms, -1000000)
var array<int>    secRank = array.new<int>(numSec, 0)
var array<string> secQuad = array.new<string>(numSec, "—")
var array<color>  secQCol = array.new<color>(numSec, color.new(color.gray, cell_t))

nameToIdx(nm) =>
    nm == "Technology" ? 0 : nm == "Financials" ? 1 : nm == "Energy" ? 2 : nm == "Health Care" ? 3 : nm == "Consumer Disc." ? 4 : nm == "Consumer Staples" ? 5 : nm == "Industrials" ? 6 : nm == "Materials" ? 7 : nm == "Utilities" ? 8 : nm == "Real Estate" ? 9 : nm == "Communications" ? 10 : -1

// price formatter: adapts precision to magnitude
fmtPrice(p) =>
    na(p) ? "—" : p >= 1000 ? str.tostring(p, "#,###.0") : p >= 1 ? str.tostring(p, "#,##0.00") : str.tostring(p, "0.#####")

// ============ RAW DATA FUNCTIONS (NO security inside) ============
calcChart() =>
    r   = ta.rsi(close, 14)
    av  = ta.sma(volume, 20)
    vs  = volume > av * vol_mult
    a_s = ta.atr(5)
    a_l = ta.atr(20)
    [close, open, r, vs, a_s, a_l, close[1]]

calcHTF() =>
    [ta.ema(close, ema_fast), ta.ema(close, ema_slow)]

// ============ WATCHLIST HELPERS ============
score(c, o, r, vs, a_s, a_l, hf, hs) =>
    bull_trend = hf > hs and c > hf
    bear_trend = hf < hs and c < hf
    bull_mom   = r > 50 and r < 70
    bear_mom   = r < 50 and r > 30
    b = (bull_trend ? 40 : 0) + (bull_mom ? 30 : 0) + (vs and c > o ? 30 : 0)
    s = (bear_trend ? 40 : 0) + (bear_mom ? 30 : 0) + (vs and c < o ? 30 : 0)
    reg = a_s > a_l * 1.1 ? "⚡ DAY" : a_s < a_l * 0.9 ? "🌊 SWING" : "➖ RANGE"
    [b, s, reg]

getBias(b, s) =>
    txt = "⚪ NEUTRAL"
    col = color.new(color.gray, cell_t)
    if b >= 70
        txt := "🟢 LONG ("  + str.tostring(b) + "%)"
        col := color.new(color.green, cell_t)
    else if s >= 70
        txt := "🔴 SHORT (" + str.tostring(s) + "%)"
        col := color.new(color.red, cell_t)
    else if b >= 40 or s >= 40
        txt := (b > s ? "🟡 WEAK L (" + str.tostring(b) : "🟡 WEAK S (" + str.tostring(s)) + "%)"
        col := color.new(color.orange, math.min(cell_t + 10, 100))
    [txt, col]

isStrengthening(rowIdx, len) =>
    float sumOld = 0.0
    float sumNew = 0.0
    int   half   = len / 2
    for col = 0 to len - 1
        v = math.max(math.min(matrix.get(hist, rowIdx, col), 100.0), -100.0)
        if col < half
            sumOld := sumOld + math.abs(v)
        else
            sumNew := sumNew + math.abs(v)
    (sumNew / math.max(len - half, 1)) > (sumOld / math.max(half, 1)) + 5

buildSpark(rowIdx, len) =>
    string sp = ""
    for col = 0 to len - 1
        vc  = math.max(math.min(matrix.get(hist, rowIdx, col), 100.0), -100.0)
        idx = int(math.round((vc + 100.0) / 200.0 * 7.0))
        sp := sp + array.get(blocks, idx)
    arrow  = isStrengthening(rowIdx, len) ? " ↗" : " →"
    latest = matrix.get(hist, rowIdx, len - 1)
    scol   = latest > 5 ? color.lime : latest < -5 ? color.red : color.gray
    [sp + arrow, scol]

discordMsg(sym, price, biasTxt, reg, spark, sectorTag) =>
    '{"content": "**' + sym + '**\\n' +
      'Price: ' + price + '\\n' +
      'Bias: ' + biasTxt + '\\n' +
      'Regime: ' + reg + '\\n' +
      'Trend: ' + spark + '\\n' +
      'Sector: ' + sectorTag + '"}'

// ============ SECTOR RRG HELPERS ============
quadrant(strn, mom) =>
    q  = "—"
    qc = color.new(color.gray, cell_t)
    if strn >= 0 and mom >= 0
        q  := "🟢 Leading"
        qc := color.new(color.green, cell_t)
    else if strn >= 0 and mom < 0
        q  := "🟡 Weakening"
        qc := color.new(color.orange, cell_t)
    else if strn < 0 and mom < 0
        q  := "🔴 Lagging"
        qc := color.new(color.red, cell_t)
    else
        q  := "🔵 Improving"
        qc := color.new(color.blue, cell_t)
    [q, qc]

quadEmoji(q) =>
    str.contains(q, "Leading") ? "🟢" : str.contains(q, "Weakening") ? "🟡" : str.contains(q, "Lagging") ? "🔴" : str.contains(q, "Improving") ? "🔵" : "⚪"

// ============ DYNAMIC LAYOUT (Watchlist) ============
int col_price  = eff_price ? 1 : -1
int col_bias   = 1 + (eff_price ? 1 : 0)
int col_regime = eff_regime ? (col_bias + 1) : -1
int col_spark  = eff_spark ? (col_bias + 1 + (eff_regime ? 1 : 0)) : -1
int col_ctx    = eff_ctx ? (col_bias + 1 + (eff_regime ? 1 : 0) + (eff_spark ? 1 : 0)) : -1
int nColsWL    = 2 + (eff_price ? 1 : 0) + (eff_regime ? 1 : 0) + (eff_spark ? 1 : 0) + (eff_ctx ? 1 : 0)

// ============ TABLES ============
var table hud = table.new(f_pos(pos_in), nColsWL, numSyms + 1, bgcolor=color.new(color.black, panel_t), border_width=brd_w, border_color=brd_col)
rot_pos = f_pos(pos_in) == position.top_right ? position.bottom_right : position.top_left
var table rot = table.new(rot_pos, 4, numSec + 1, bgcolor=color.new(color.black, panel_t), border_width=brd_w, border_color=brd_col)

if barstate.islast and show_wl
    table.cell(hud, 0, 0, "TICKER",      text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    if eff_price
        table.cell(hud, col_price, 0, "PRICE", text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    table.cell(hud, col_bias, 0, "BIAS", text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    if eff_regime
        table.cell(hud, col_regime, 0, "REGIME", text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    if eff_spark
        table.cell(hud, col_spark, 0, "TREND", text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    if eff_ctx
        table.cell(hud, col_ctx, 0, "SECTOR", text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))

if barstate.islast and show_rot
    table.cell(rot, 0, 0, "SECTOR",   text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    table.cell(rot, 1, 0, "QUADRANT", text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    table.cell(rot, 2, 0, "STR/MOM",  text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))
    table.cell(rot, 3, 0, "RANK",     text_color=txt_col, text_size=t_size, bgcolor=color.new(hdr_col, 70))

// ============ SECTOR ROTATION SCAN (runs first so context tag can read it) ============
string rot_tf_eff = rot_tf == "" ? timeframe.period : rot_tf
bool   newRotBar  = timeframe.change(rot_tf_eff)
if show_rot or ctx_on
    float benchClose = request.security(bench, rot_tf_eff, close, lookahead=barmerge.lookahead_off)
    var array<float> strArr   = array.new<float>(numSec, na)
    var array<float> momArr   = array.new<float>(numSec, na)
    var array<float> scoreArr = array.new<float>(numSec, na)

    for i = 0 to numSec - 1
        string sec = array.get(sectors, i)
        float secClose = request.security(sec, rot_tf_eff, close, lookahead=barmerge.lookahead_off)
        float ratio = (na(benchClose) or benchClose == 0) ? na : secClose / benchClose
        if newRotBar
            for col = 0 to rsCols - 2
                matrix.set(rsHist, i, col, matrix.get(rsHist, i, col + 1))
            matrix.set(rsHist, i, rsCols - 1, ratio)

        float rNow   = matrix.get(rsHist, i, rsCols - 1)
        float rLong  = matrix.get(rsHist, i, rsCols - 1 - rs_long)
        float rShort = matrix.get(rsHist, i, rsCols - 1 - rs_short)
        float strn = (na(rLong)  or rLong  == 0) ? 0.0 : (rNow / rLong  - 1.0) * 100.0
        float mom  = (na(rShort) or rShort == 0) ? 0.0 : (rNow / rShort - 1.0) * 100.0
        array.set(strArr,  i, strn)
        array.set(momArr,  i, mom)
        array.set(scoreArr,i, strn + mom)

    if barstate.islast
        idxSorted = array.sort_indices(scoreArr, order.descending)
        for r = 0 to numSec - 1
            int i = array.get(idxSorted, r)
            float strn = array.get(strArr, i)
            float mom  = array.get(momArr, i)
            [q, qc] = quadrant(strn, mom)
            array.set(secRank, i, r + 1)
            array.set(secQuad, i, q)
            array.set(secQCol, i, qc)
            if show_rot
                string medal = r == 0 ? "🥇 " : r == 1 ? "🥈 " : r == 2 ? "🥉 " : str.tostring(r + 1) + "  "
                string sm = str.tostring(strn, "#.0") + " / " + str.tostring(mom, "#.0")
                int row = r + 1
                table.cell(rot, 0, row, array.get(secLbls, i), text_color=txt_col, text_size=t_size)
                table.cell(rot, 1, row, q,  text_color=txt_col, text_size=t_size, bgcolor=qc)
                table.cell(rot, 2, row, sm, text_color=txt_col, text_size=t_size)
                table.cell(rot, 3, row, medal, text_color=txt_col, text_size=t_size)

// ============ WATCHLIST SCAN ============
if show_wl
    for i = 0 to numSyms - 1
        string sym = array.get(symbols, i)
        [c, o, r, vs, a_s, a_l, pc] = request.security(sym, timeframe.period, calcChart(), lookahead=barmerge.lookahead_off)
        [hf, hs]                    = request.security(sym, htf_res,          calcHTF(),   lookahead=barmerge.lookahead_off)
        float prevDayClose = chg_mode == "Day" ? request.security(sym, "D", close[1], lookahead=barmerge.lookahead_off) : na

        [b, s, reg] = score(nz(c), nz(o), nz(r), vs, nz(a_s), nz(a_l), nz(hf), nz(hs))
        float net   = b - s
        for col = 0 to spark_len - 2
            matrix.set(hist, i, col, matrix.get(hist, i, col + 1))
        matrix.set(hist, i, spark_len - 1, net)

        int side    = b >= 70 ? 1 : s >= 70 ? -1 : 0
        bool strong = isStrengthening(i, spark_len)
        [biasTxt, biasCol] = getBias(b, s)
        [spark, scol]      = buildSpark(i, spark_len)

        // ---- price + % change (Bar or Day basis) ----
        float basisClose = chg_mode == "Day" ? prevDayClose : pc
        float chgPct     = (na(c) or na(basisClose) or basisClose == 0) ? na : (c - basisClose) / basisClose * 100.0
        string priceTxt = fmtPrice(c)
        color  priceCol = na(chgPct) ? txt_col : chgPct >= 0 ? color.lime : color.red
        if eff_chg and not na(chgPct)
            priceTxt := priceTxt + " (" + (chgPct >= 0 ? "+" : "") + str.tostring(chgPct, "#.0") + "%)"

        int sIdxA = nameToIdx(array.get(secNames, i))
        string sectorTag = sIdxA >= 0 ? array.get(secLbls, sIdxA) + " " + quadEmoji(array.get(secQuad, sIdxA)) + "#" + str.tostring(array.get(secRank, sIdxA)) : "N/A"

        if barstate.isconfirmed
            bool flipEvent = alrt_flip and side != 0 and side != array.get(prevSide, i)
            bool strEvent  = alrt_str  and strong and not array.get(prevStr, i) and side != 0
            bool coolOK    = alrt_cooldown == 0 or (bar_index - array.get(lastAlertBar, i)) >= alrt_cooldown
            if (flipEvent or strEvent) and coolOK
                alert(discordMsg(sym, priceTxt, biasTxt, reg, spark, sectorTag), alert.freq_once_per_bar_close)
                array.set(lastAlertBar, i, bar_index)
            array.set(prevSide, i, side)
            array.set(prevStr,  i, strong)

        if barstate.islast
            int row = i + 1
            table.cell(hud, 0, row, sym, text_color=txt_col, text_size=t_size)
            if eff_price
                table.cell(hud, col_price, row, priceTxt, text_color=priceCol, text_size=t_size)
            table.cell(hud, col_bias, row, biasTxt, text_color=txt_col, text_size=t_size, bgcolor=biasCol)
            if eff_regime
                table.cell(hud, col_regime, row, reg, text_color=txt_col, text_size=t_size)
            if eff_spark
                table.cell(hud, col_spark, row, spark, text_color=scol, text_size=t_size)
            if eff_ctx
                int sIdx = nameToIdx(array.get(secNames, i))
                string ctxTxt = "—"
                color  ctxCol = color.new(color.gray, cell_t)
                if sIdx >= 0
                    ctxTxt := array.get(secLbls, sIdx) + " " + quadEmoji(array.get(secQuad, sIdx)) + "#" + str.tostring(array.get(secRank, sIdx))
                    ctxCol := array.get(secQCol, sIdx)
                table.cell(hud, col_ctx, row, ctxTxt, text_color=txt_col, text_size=t_size, bgcolor=ctxCol)
````
