# Confluence Engine Strategy [JOAT]

- url: https://www.tradingview.com/script/4W7XgwiP-Confluence-Engine-Strategy-JOAT/
- type: strategy
- pine_id: PUB;7699be1762d94ae38d0b12fbe2a56749
- version: 1.0

## Description

[b]Confluence Engine Strategy [JOAT][/b]

[b]Overview[/b]

Confluence Engine Strategy is a fully automated Pine Script v6 strategy that combines four independent signal layers into a single numeric confluence score (0–100) before executing any trade. Entries require genuine agreement between linear regression momentum, dual EMA trend regime, ATR volatility state, and higher-timeframe bias. All exits are ATR-proportional with configurable take-profit and stop-loss multiples, plus a bar-based timeout and a trend-flip emergency exit. Commission (0.05% per side) and slippage (2 ticks) are configured for realistic backtesting.

[b]Why Require Confluence?[/b]

Single-condition strategies (e.g., "go long when RSI crosses 50") produce entries in every conceivable market environment — ranging, trending, low-volatility, high-volatility — most of which are statistically unfavourable for that signal type. Requiring multiple independent conditions to agree simultaneously filters the entry universe down to the high-probability subset where each individual indicator is operating in its most favourable context. The Confluence Engine makes this filtering explicit and auditable through a numeric score.

[image]https://www.tradingview.com/x/BXRQEkD8/[/image]

[b]Signal Layer 1 — Linear Regression Crossover[/b]

The primary entry trigger mirrors the Regression Flux Candles logic: a 21-bar linear regression of close (LR close) crossing above/below an 8-bar SMA of itself. The LR approach de-noises price before computing the crossover, significantly reducing the whipsaw rate compared to raw close-based SMA crossovers.

[b]Signal Layer 2 — Dual EMA Trend Regime[/b]

Two exponential moving averages (fast: 21-period, slow: 55-period) define the trend regime. Long entries are only considered when the fast EMA is above the slow EMA; short entries only when fast is below slow. This prevents the LR crossover from triggering counter-trend entries in established trends — one of the most common sources of false signals in momentum strategies.

[b]Signal Layer 3 — ATR Volatility State[/b]

The current 14-bar ATR is compared to a 50-bar ATR. Entries are only accepted when the current ATR is above a configurable fraction of the slow ATR (default 0.7). This volatility gate blocks trades during compression phases — low-volatility periods where breakouts frequently fail. The strategy only participates when directional energy is present.

[b]Signal Layer 4 — Higher-Timeframe Bias[/b]

A higher-timeframe linear regression direction is fetched via request.security() with lookahead_off. The HTF LR close vs. HTF LR open comparison gives a single bullish/bearish vote from the higher timeframe. Long entries receive a confluence bonus when the HTF agrees; short entries receive a bonus when the HTF is bearish. This aligns trade direction with the prevailing macro bias.

[b]Confluence Score and Threshold[/b]

Each of the four layers contributes points to the confluence score:
- LR crossover in direction: +30
- Dual EMA alignment: +25
- ATR volatility expansion: +20
- HTF bias alignment: +25

Maximum score: 100. The minimum required score to execute an entry (default 60) filters out entries where fewer than three layers agree. This threshold is adjustable — lower it for more signals, raise it for higher selectivity.

[b]Entry Logic[/b]

Long: LR crossover up AND the accumulated confluence score >= minimum AND the signal is on a confirmed bar AND warmup has elapsed AND no position is currently open AND no cooldown bars remain.

Short: LR crossover down AND confluence >= minimum AND same guards.

A configurable cooldown period (default 5 bars) prevents re-entering the same direction immediately after an exit, avoiding overtrading in choppy conditions.

[b]Exit Logic — Four Exit Conditions[/b]

1. [b]ATR Take-Profit:[/b] Long exits when close >= entry + ATR × TP multiplier (default 2.0). Short exits below entry - ATR × TP.
2. [b]ATR Stop-Loss:[/b] Long exits when close <= entry - ATR × SL multiplier (default 1.2). Short exits above entry + ATR × SL.
3. [b]Bar Timeout:[/b] If neither TP nor SL is hit within a configurable number of bars (default 20), the trade exits at market — preventing capital from being locked in stalled trades.
4. [b]Trend Flip Exit:[/b] If the dual EMA regime flips against the trade direction (fast EMA crosses slow EMA), the trade exits immediately — recognising that the structural basis for the entry has been invalidated.

[b]Strategy Properties[/b]

- Initial capital: $10,000
- Order size: 10% of equity per trade (sustainable risk allocation)
- Commission: 0.05% per side (representative of major exchange fees)
- Slippage: 2 ticks (accounts for spread and execution delay)
- Currency: USD
- Pyramiding: disabled (one position at a time)

These settings are designed to produce realistic backtesting results. Risk per trade is capped well below the 5–10% equity guideline. Commission and slippage are included to prevent overstating performance.

[b]Inputs Reference[/b]

[b]Signal Layers[/b]
- LR Length (21) — linear regression period
- Signal SMA Length (8) — crossover trigger SMA
- Fast EMA (21) / Slow EMA (55) — trend regime definition
- ATR Length (14) / ATR Slow Length (50) / ATR Threshold (0.70)
- HTF Timeframe — higher-timeframe bias source (default "D")

[b]Confluence & Filters[/b]
- Min Confluence Score (60) — minimum sum of layer scores required for entry
- Cooldown Bars (5) — bars to wait after exit before re-entering
- Max Bars in Trade (20) — timeout exit

[b]Risk Management[/b]
- TP ATR Multiple (2.0) — take-profit distance in ATR units
- SL ATR Multiple (1.2) — stop-loss distance in ATR units

[b]How to Read the Results[/b]

Apply the strategy to a liquid instrument on a 1H or 4H chart with sufficient history to generate 100+ trades. Evaluate:
- Net profit relative to max drawdown (seek ratio > 2:1)
- Win rate in context of average win vs. average loss
- Profit factor (total gross profit / total gross loss, seek > 1.3)
- Number of trades (sufficient sample size for statistical inference)

Adjust the confluence minimum score to trade off signal frequency against quality: 50 produces more trades, 75 produces fewer but higher-quality entries.

[b]Non-Repainting Design[/b]

All entries fire on strategy.entry() within barstate.isconfirmed blocks. HTF bias uses lookahead_off. No future bar data is accessed. Historical signals do not shift position.

[b]Limitations[/b]

- The strategy is designed as a general-purpose framework. It is not optimised for any specific instrument or session. Optimal parameters vary significantly across markets and timeframes.
- ATR-based exits are approximate. In gap markets (equities overnight, weekend gaps on crypto), the stop-loss may be exceeded significantly before the exit executes.
- Backtesting results are computed on historical data only and do not account for execution quality, broker-specific fees, or market impact. Past backtesting performance does not guarantee future live results.
- The bar timeout exit may prematurely close positions that would have eventually reached TP. This is a deliberate conservative design choice to limit capital lock-up, not a flaw.

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. Backtesting results presented in the strategy tester represent historical simulation and do not guarantee any future trading outcome. Past performance is not indicative of future results. Never risk capital you cannot afford to lose. Always use proper risk management and conduct independent analysis before making any trading decisions.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Confluence Engine Strategy [JOAT]", shorttitle="CES [JOAT]",
         overlay=true,
         initial_capital=10000,
         default_qty_type=strategy.percent_of_equity,
         default_qty_value=5,
         commission_type=strategy.commission.percent,
         commission_value=0.05,
         slippage=2,
         max_bars_back=500)
// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_E  = "Entry Engine"
var GRP_F  = "Filters"
var GRP_R  = "Risk Management"
var GRP_X  = "Exit Logic"
var GRP_V  = "Visual"

i_lrLen     = input.int   (9,    "LR Length",               group=GRP_E, minval=3)
i_sigLen    = input.int   (5,    "LR Signal Length",         group=GRP_E, minval=2)
i_fastEMA   = input.int   (20,   "Fast EMA",                 group=GRP_E, minval=5)
i_slowEMA   = input.int   (50,   "Slow EMA",                 group=GRP_E, minval=10)
i_atrLen    = input.int   (14,   "ATR Length",               group=GRP_E, minval=3)
i_regLen    = input.int   (50,   "Regime ATR Length",        group=GRP_E, minval=20)
i_confScore = input.int   (50,   "Min Confluence Score",     group=GRP_E, minval=0, maxval=100)
i_longs     = input.bool  (true, "Trade Long",               group=GRP_E)
i_shorts    = input.bool  (true, "Trade Short",              group=GRP_E)

i_volFilt   = input.bool  (true, "Require Volume Spike",    group=GRP_F)
i_volLen    = input.int   (20,   "Volume SMA Length",        group=GRP_F, minval=5)
i_volMult   = input.float (1.0,  "Volume Multiplier",        group=GRP_F, minval=0.5, step=0.1)
i_rsiLen    = input.int   (14,   "RSI Length",               group=GRP_F, minval=2)
i_rsiBullMax= input.int   (72,   "RSI Max for Longs",        group=GRP_F, minval=50, maxval=99)
i_rsiBearMin= input.int   (28,   "RSI Min for Shorts",       group=GRP_F, minval=1,  maxval=50)
i_cooldown  = input.int   (3,    "Cooldown Bars After Exit", group=GRP_F, minval=0)
i_regFilter = input.bool  (true, "Regime Filter (no ranging)", group=GRP_F)
i_regThresh = input.float (0.85, "Trending Regime Threshold", group=GRP_F, minval=0.5, maxval=1.5, step=0.05)

i_riskPct   = input.float (5.0,  "Risk Per Trade (%)",       group=GRP_R, minval=0.5, maxval=25, step=0.5)
i_slMult    = input.float (1.5,  "SL  (ATR x)",              group=GRP_R, minval=0.5, step=0.25)
i_tpMult    = input.float (2.5,  "TP  (ATR x)",              group=GRP_R, minval=0.5, step=0.25)
i_timeout   = input.int   (20,   "Timeout Exit (bars)",      group=GRP_X, minval=3)
i_htfTF     = input.string("60", "HTF Bias Timeframe",       group=GRP_X)

i_showSig   = input.bool  (true, "Show Signal Labels",       group=GRP_V)
i_showLvls  = input.bool  (true, "Show TP/SL Levels",        group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
C_BULL  = color.rgb(0, 245, 212)
C_BEAR  = color.rgb(255, 68, 102)
C_GOLD  = color.rgb(255, 215, 0)
C_SLATE = color.rgb(96, 112, 128)
_isDark = color.r(chart.bg_color) < 128
C_PANEL = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT   = _isDark ? color.white : color.black

// ─── HELPERS ─────────────────────────────────────────────────────────
safeDiv(float n, float d) =>
    d != 0.0 and not na(d) ? n / d : 0.0

// ─── CORE CALCULATIONS ───────────────────────────────────────────────
lr_open  = ta.linreg(open,  i_lrLen, 0)
lr_close = ta.linreg(close, i_lrLen, 0)
sigLine  = ta.sma(lr_close, i_sigLen)

fastEMA  = ta.ema(close, i_fastEMA)
slowEMA  = ta.ema(close, i_slowEMA)
trendUp  = fastEMA > slowEMA
trendDn  = fastEMA < slowEMA

atr14    = ta.atr(i_atrLen)
atrSlow  = ta.atr(i_regLen)
atrRatio = safeDiv(atr14, math.max(atrSlow, syminfo.mintick))
isTrending   = atrRatio > i_regThresh or not i_regFilter
isCompressed = atrRatio < i_regThresh * 0.75

rsiVal   = ta.rsi(close, i_rsiLen)
volSma   = ta.sma(volume, i_volLen)
volOk    = not i_volFilt or volume > volSma * i_volMult

// HTF trend bias (non-repainting)
htfClose = request.security(syminfo.tickerid, i_htfTF, close[1], lookahead=barmerge.lookahead_off)
htfEmaF  = request.security(syminfo.tickerid, i_htfTF, ta.ema(close, i_fastEMA), lookahead=barmerge.lookahead_off)
htfEmaS  = request.security(syminfo.tickerid, i_htfTF, ta.ema(close, i_slowEMA), lookahead=barmerge.lookahead_off)
htfBull  = htfEmaF > htfEmaS
htfBear  = htfEmaF < htfEmaS

WARMUP  = math.max(i_slowEMA * 2, i_regLen * 2)
isReady = bar_index >= WARMUP

// ─── CONFLUENCE SCORE ────────────────────────────────────────────────
f_scoreL() =>
    // Score for a LONG setup (0-100)
    trendS = trendUp   ? 25 : 0
    htfS   = htfBull   ? 20 : 0
    volS   = volume > volSma * 1.2 ? 20 : volume > volSma ? 10 : 0
    rsiS   = rsiVal < 50 ? math.min((55.0 - rsiVal) * 0.5, 20.0) : 0.0
    regS   = isTrending ? 15 : 0
    int(math.min(trendS + htfS + int(volS) + int(rsiS) + regS, 100))

f_scoreS() =>
    // Score for a SHORT setup (0-100)
    trendS = trendDn   ? 25 : 0
    htfS   = htfBear   ? 20 : 0
    volS   = volume > volSma * 1.2 ? 20 : volume > volSma ? 10 : 0
    rsiS   = rsiVal > 50 ? math.min((rsiVal - 45.0) * 0.5, 20.0) : 0.0
    regS   = isTrending ? 15 : 0
    int(math.min(trendS + htfS + int(volS) + int(rsiS) + regS, 100))

// ─── SIGNAL GENERATION ───────────────────────────────────────────────
lrCross  = ta.crossover (lr_close, sigLine)
lrUnder  = ta.crossunder(lr_close, sigLine)

longScore  = lrCross ? f_scoreL() : 0
shortScore = lrUnder ? f_scoreS() : 0

bullSig = lrCross and trendUp and htfBull and volOk and rsiVal < i_rsiBullMax and
          isTrending and longScore >= i_confScore and i_longs and isReady and barstate.isconfirmed

bearSig = lrUnder and trendDn and htfBear and volOk and rsiVal > i_rsiBearMin and
          isTrending and shortScore >= i_confScore and i_shorts and isReady and barstate.isconfirmed

// ─── COOLDOWN ────────────────────────────────────────────────────────
var int lastExitBar = na
cooldownOk = na(lastExitBar) or (bar_index - lastExitBar >= i_cooldown)

// ─── POSITION STATE ──────────────────────────────────────────────────
var float entryAtr    = na
var float entryTP     = na
var float entrySL     = na
var int   entryBar    = na
var bool  inLong      = false
var bool  inShort     = false

// Detect position open
if strategy.position_size > 0 and strategy.position_size[1] == 0
    inLong    := true
    inShort   := false
    entryAtr  := atr14
    entryBar  := bar_index

if strategy.position_size < 0 and strategy.position_size[1] == 0
    inShort   := true
    inLong    := false
    entryAtr  := atr14
    entryBar  := bar_index

if strategy.position_size == 0 and strategy.position_size[1] != 0
    inLong    := false
    inShort   := false
    lastExitBar := bar_index

// Calculate TP/SL
if inLong and not na(entryAtr)
    entryTP := strategy.position_avg_price + entryAtr * i_tpMult
    entrySL := strategy.position_avg_price - entryAtr * i_slMult

if inShort and not na(entryAtr)
    entryTP := strategy.position_avg_price - entryAtr * i_tpMult
    entrySL := strategy.position_avg_price + entryAtr * i_slMult

// ─── ENTRIES ─────────────────────────────────────────────────────────
if bullSig and cooldownOk and strategy.position_size == 0
    strategy.entry("Long", strategy.long,
         comment="CES L " + str.tostring(longScore))

if bearSig and cooldownOk and strategy.position_size == 0
    strategy.entry("Short", strategy.short,
         comment="CES S " + str.tostring(shortScore))

// ─── EXITS ───────────────────────────────────────────────────────────
if inLong and not na(entryTP) and not na(entrySL)
    strategy.exit("TP/SL Long", "Long", limit=entryTP, stop=entrySL)

if inShort and not na(entryTP) and not na(entrySL)
    strategy.exit("TP/SL Short", "Short", limit=entryTP, stop=entrySL)

// Timeout exit
if inLong and not na(entryBar) and bar_index - entryBar >= i_timeout
    strategy.close("Long", comment="Timeout")

if inShort and not na(entryBar) and bar_index - entryBar >= i_timeout
    strategy.close("Short", comment="Timeout")

// Trend flip exit
if inLong and trendDn and barstate.isconfirmed
    strategy.close("Long", comment="Trend Flip")

if inShort and trendUp and barstate.isconfirmed
    strategy.close("Short", comment="Trend Flip")

// ─── SIGNAL VISUALS ──────────────────────────────────────────────────
if i_showSig and bullSig
    label.new(bar_index, low, "LONG " + str.tostring(longScore),
         color=color.new(C_BULL, 55), textcolor=color.white,
         style=label.style_label_up, size=size.small)

if i_showSig and bearSig
    label.new(bar_index, high, "SHORT " + str.tostring(shortScore),
         color=color.new(C_BEAR, 55), textcolor=color.white,
         style=label.style_label_down, size=size.small)

// TP/SL level lines
var line tpLine = na
var line slLine = na

if inLong or inShort
    if not na(tpLine)
        line.delete(tpLine)
    if not na(slLine)
        line.delete(slLine)
    if i_showLvls and not na(entryTP) and not na(entrySL)
        tpLine := line.new(nz(entryBar, bar_index), entryTP, bar_index + 10, entryTP,
                   color=color.new(C_BULL, 25), width=1, style=line.style_dotted)
        slLine := line.new(nz(entryBar, bar_index), entrySL, bar_index + 10, entrySL,
                   color=color.new(C_BEAR, 25), width=1, style=line.style_dashed)

// ─── EQUITY CURVE PLOT ───────────────────────────────────────────────
plot(fastEMA, "Fast EMA", color=color.new(trendUp ? C_BULL : C_BEAR, 60), linewidth=1)
plot(slowEMA, "Slow EMA", color=color.new(trendUp ? C_BULL : C_BEAR, 40), linewidth=2)

// Regime background
regimeBg = isCompressed ? color.new(C_GOLD, 95) : na
bgcolor(regimeBg, title="Compression Regime")

// ─── DASHBOARD ───────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 10,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 55))

if barstate.islast
    pnlPct     = safeDiv(strategy.netprofit, strategy.initial_capital) * 100.0
    winRate    = strategy.wintrades + strategy.losstrades > 0 ?
                  safeDiv(float(strategy.wintrades), float(strategy.wintrades + strategy.losstrades)) * 100.0 : 0.0
    posStr     = inLong ? "LONG" : inShort ? "SHORT" : "FLAT"
    posClr     = inLong ? C_BULL : inShort ? C_BEAR : C_SLATE
    regStr     = isCompressed ? "COMPRESS" : isTrending ? "TRENDING" : "NEUTRAL"
    regClr     = isCompressed ? C_GOLD : isTrending ? C_BULL : C_SLATE
    scoreL     = f_scoreL()
    scoreS     = f_scoreS()
    htfStr     = htfBull ? "BULL" : htfBear ? "BEAR" : "NEUTRAL"
    htfClr     = htfBull ? C_BULL : htfBear ? C_BEAR : C_SLATE

    table.cell(dash, 0, 0, "CES [JOAT]",
         bgcolor=color.new(C_GOLD, 35), text_color=color.black, text_size=size.small)
    table.cell(dash, 1, 0, "JackOfAllTrades",
         bgcolor=color.new(C_GOLD, 35), text_color=color.black, text_size=size.small)
    table.cell(dash, 0, 1, "Net P&L",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 1, (pnlPct >= 0 ? "+" : "") + str.tostring(math.round(pnlPct, 1)) + "%",
         text_color=pnlPct >= 0 ? C_BULL : C_BEAR, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 2, "Win Rate", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 2, str.tostring(math.round(winRate, 1)) + "%",
         text_color=winRate >= 50 ? C_BULL : C_BEAR, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 3, "Trades",   text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 3, str.tostring(strategy.closedtrades),
         text_color=C_GOLD, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 4, "Position", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 4, posStr,     text_color=posClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 5, "Regime",   text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 5, regStr,     text_color=regClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 6, "HTF Bias", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 6, htfStr,     text_color=htfClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 7, "L Score",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 7, str.tostring(scoreL),
         text_color=scoreL >= i_confScore ? C_BULL : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 8, "S Score",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 8, str.tostring(scoreS),
         text_color=scoreS >= i_confScore ? C_BEAR : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 9, "ATR Ratio",text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 9, str.tostring(math.round(atrRatio, 3)),
         text_color=isTrending ? C_BULL : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
````
