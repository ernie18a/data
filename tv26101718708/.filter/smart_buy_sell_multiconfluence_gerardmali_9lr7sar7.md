#  Smart Buy Sell  MultiConfluence  GerardMali

- url: https://www.tradingview.com/script/9Lr7SaR7-Smart-Buy-Sell-MultiConfluence-GerardMali/
- type: indicator
- pine_id: PUB;aa4018ee89b44dfe9a44fb3408b47544
- version: 2.0

## Description

⚡ Smart Buy/Sell — Multi-Indicator Confluence System
A high-confluence buy and sell signal indicator that combines seven of the most reliable technical indicators into a single, easy-to-read system. Instead of relying on one indicator alone — which produces too many false signals — this script requires multiple conditions to align simultaneously before triggering a signal. The result is fewer signals, but with significantly higher probability.
How It Works
Every bar, each indicator casts a vote — bullish or bearish. The votes are tallied into a score out of 7. A buy or sell signal only fires when the score meets your minimum threshold AND a crossover event (MACD, Stochastic, EMA, or RSI) acts as the trigger. This two-step requirement — background setup + timing trigger — filters out noise and keeps you out of choppy, low-conviction conditions.
Indicators Used

EMA Alignment (9 / 21 / 50 / 200) — trend direction and stack confirmation
RSI (14) — momentum and overbought/oversold zones
MACD (12, 26, 9) — trend momentum and crossover trigger
Stochastic (14, 3, 3) — entry timing from overbought/oversold levels
ADX (14) — trend strength filter
Bollinger Bands (20, 2) — price position relative to volatility range
Volume — confirms conviction behind each move

What You See on the Chart
🟢 Green triangle = BUY signal with score (e.g. "BUY 6/7")
🔴 Red triangle = SELL signal with score (e.g. "SELL 5/7")
Dashed lines = ATR-based Stop Loss and two Take Profit levels (auto-calculated from the most recent signal)
Background shading = green during bullish EMA alignment, red during bearish alignment
Top-right table = live dashboard showing the real-time status of every indicator
Settings
All indicator lengths are fully customizable. The key setting is Min Score to Trigger — set it to 4 for balanced signals, 5–6 for high-quality setups only, or 3 for more frequent entries. Stop loss and take profit distances are set using ATR multipliers, making them adaptive to current volatility on any timeframe.
Works on any timeframe and any instrument — indices, forex, crypto, commodities, and stocks.

Disclaimer: This indicator is for educational and informational purposes only. It does not constitute financial advice. Always use proper risk management and do your own research before trading.

## Source Code

````pine
//@version=6
indicator("⚡ Smart Buy/Sell PRO v2 — Precision | Claude",
          overlay = true,
          max_labels_count = 500,
          max_lines_count  = 50)

// ════════════════════════════════════════════════════════════════════════
//  ⚡ SMART BUY/SELL — PRO EDITION v2
//  Rebuilt by Claude as Expert Trader / Chartist
//
//  WHY v1 FAILED:
//  ✗ EMA stack lagged — stayed "bullish" while price fell
//  ✗ Stochastic/MACD fired from mid-range, not reversal zones
//  ✗ No candle confirmation — bearish close could trigger buy
//  ✗ No overextension check — bought at peaks
//  ✗ No ADX gate — fired in ranging/choppy markets
//  ✗ No cooldown — repeated signals in same direction
//
//  HOW v2 FIXES IT:
//  ✅ REQUIRED GATES — 6 conditions ALL must pass or signal blocked
//  ✅ EMA SLOPE — EMAs must be actively rising/falling, not just aligned
//  ✅ MACD HISTOGRAM MOMENTUM — histogram must be growing (not just crossing)
//  ✅ CANDLE BODY — bar must close in direction of signal
//  ✅ STOCHASTIC FROM ZONE — cross only valid from OB/OS territory
//  ✅ RSI DIVERGENCE VETO — price/RSI divergence blocks wrong-direction signals
//  ✅ OVEREXTENSION VETO — no buy when price is far above trend EMA
//  ✅ ADX GATE — no signals in choppy/ranging markets
//  ✅ SIGNAL COOLDOWN — prevents clustering of same-direction signals
//  ✅ BONUS CONFLUENCE SCORE — additional confirmation on top of gates
// ════════════════════════════════════════════════════════════════════════

// ── EMA SETTINGS ──────────────────────────────────────────────────────────
var string GE = "📈 EMA Settings"
ema1_len  = input.int(9,   "EMA Fast (9)",   minval = 1, group = GE)
ema2_len  = input.int(21,  "EMA Mid (21)",   minval = 1, group = GE)
ema3_len  = input.int(50,  "EMA Slow (50)",  minval = 1, group = GE)
ema4_len  = input.int(200, "EMA Trend (200)",minval = 1, group = GE)
show_emas = input.bool(true, "Show EMAs",    group = GE)

// ── RSI SETTINGS ──────────────────────────────────────────────────────────
var string GR = "📊 RSI Settings"
rsi_len = input.int(14, "RSI Length", minval = 1, group = GR)

// ── MACD SETTINGS ─────────────────────────────────────────────────────────
var string GM = "📉 MACD Settings"
macd_f = input.int(12, "Fast",   minval = 1, group = GM)
macd_s = input.int(26, "Slow",   minval = 1, group = GM)
macd_g = input.int(9,  "Signal", minval = 1, group = GM)

// ── STOCHASTIC SETTINGS ───────────────────────────────────────────────────
var string GK = "🔄 Stochastic Settings"
stk_k  = input.int(14, "%K",      minval = 1, group = GK)
stk_d  = input.int(3,  "%D",      minval = 1, group = GK)
stk_sm = input.int(3,  "Smooth",  minval = 1, group = GK)

// ── SIGNAL SETTINGS ───────────────────────────────────────────────────────
var string GS = "⚡ Signal Settings"
min_bonus  = input.int(3,    "Min Bonus Score (1-6)", minval=1, maxval=6, group=GS,
             tooltip="Required conditions must ALL pass first. This is the extra confirmation needed.")
adx_min    = input.int(18,   "Min ADX (blocks signals below)", minval=10, maxval=40, group=GS,
             tooltip="ADX below this = ranging market. Signals blocked. Recommended: 18-22.")
ext_pct    = input.float(9.0,"Overextension % veto", minval=1.0, step=0.5, group=GS,
             tooltip="Blocks buy signals when price is this % above EMA200 (overextended). For indices: 8-12%.")
cooldown   = input.int(5,    "Signal cooldown (bars)", minval=1, maxval=30, group=GS,
             tooltip="Min bars before same-direction signal can fire again.")
atr_len    = input.int(14,   "ATR Length (SL/TP)", minval=1, group=GS)
sl_mult    = input.float(1.5, "SL ATR multiplier", minval=0.1, step=0.1, group=GS)
tp1_mult   = input.float(2.5, "TP1 ATR multiplier", minval=0.1, step=0.1, group=GS)
tp2_mult   = input.float(4.5, "TP2 ATR multiplier", minval=0.1, step=0.1, group=GS)
show_sltp  = input.bool(true, "Show SL / TP",  group=GS)


// ════════════════════════════════════════════════════════════════════════
//  CALCULATIONS
// ════════════════════════════════════════════════════════════════════════

// EMAs
e1 = ta.ema(close, ema1_len)
e2 = ta.ema(close, ema2_len)
e3 = ta.ema(close, ema3_len)
e4 = ta.ema(close, ema4_len)

// EMA slopes (is each EMA actively rising or falling?)
e1_rising  = e1 > e1[2]
e1_falling = e1 < e1[2]
e2_rising  = e2 > e2[2]
e2_falling = e2 < e2[2]

// RSI
rsi_val  = ta.rsi(close, rsi_len)
rsi_up   = rsi_val > rsi_val[2]  // RSI trending up
rsi_down = rsi_val < rsi_val[2]  // RSI trending down

// MACD
[macd_line, sig_line, macd_hist] = ta.macd(close, macd_f, macd_s, macd_g)
hist_growing_bull = macd_hist > macd_hist[1] and macd_hist > macd_hist[2]  // Histogram accelerating bullish
hist_growing_bear = macd_hist < macd_hist[1] and macd_hist < macd_hist[2]  // Histogram accelerating bearish

// Stochastic
stk_K = ta.sma(ta.stoch(close, high, low, stk_k), stk_sm)
stk_D = ta.sma(stk_K, stk_d)

// ADX + DI
[di_plus, di_minus, adx_val] = ta.dmi(14, 14)

// ATR & Volume
atr     = ta.atr(atr_len)
vol_avg = ta.sma(volume, 20)

// Candle properties
upper_close = close >= (low + (high - low) * 0.45)   // Closed in upper 55%+ of range
lower_close = close <= (high - (high - low) * 0.45)  // Closed in lower 55%+ of range

// Overextension from EMA200
dist_from_200 = math.abs(close - e4) / e4 * 100
overextended_up   = close > e4 and dist_from_200 > ext_pct   // Too far above EMA200 (don't buy)
overextended_down = close < e4 and dist_from_200 > ext_pct   // Too far below EMA200 (don't sell)

// Simple RSI Divergence (14-bar lookback)
// Bearish div: price higher than 14 bars ago, but RSI lower → weakness, veto buys
// Bullish div: price lower than 14 bars ago, but RSI higher → strength, veto sells
bearish_div = close > close[14] and rsi_val < rsi_val[14] and rsi_val > 55
bullish_div = close < close[14] and rsi_val > rsi_val[14] and rsi_val < 45


// ════════════════════════════════════════════════════════════════════════
//  REQUIRED CONDITIONS (ALL must pass — acts as a hard gate)
//  Any single failure = NO SIGNAL regardless of score
// ════════════════════════════════════════════════════════════════════════

// ── BUY GATES ─────────────────────────────────────────────────────────────
bool G1_bull = adx_val > adx_min                     // Market is trending (not choppy)
bool G2_bull = e1_rising and e2_rising               // EMA fast & mid actively rising
bool G3_bull = rsi_val > 38 and rsi_val < 72         // RSI in valid buy zone (not OB/OS)
bool G4_bull = hist_growing_bull                     // MACD momentum accelerating bullish
bool G5_bull = upper_close                           // Candle closed in upper range (bullish)
bool G6_bull = not overextended_up                   // Price not overextended above EMA200
bool G7_bull = not bearish_div                       // No bearish RSI divergence present

bool buy_gates = G1_bull and G2_bull and G3_bull and G4_bull and G5_bull and G6_bull and G7_bull

// ── SELL GATES ────────────────────────────────────────────────────────────
bool G1_bear = adx_val > adx_min                     // Market is trending
bool G2_bear = e1_falling and e2_falling             // EMA fast & mid actively falling
bool G3_bear = rsi_val < 62 and rsi_val > 28         // RSI in valid sell zone
bool G4_bear = hist_growing_bear                     // MACD momentum accelerating bearish
bool G5_bear = lower_close                           // Candle closed in lower range (bearish)
bool G6_bear = not overextended_down                 // Price not overextended below EMA200
bool G7_bear = not bullish_div                       // No bullish RSI divergence present

bool sell_gates = G1_bear and G2_bear and G3_bear and G4_bear and G5_bear and G6_bear and G7_bear


// ════════════════════════════════════════════════════════════════════════
//  BONUS CONFLUENCE SCORE (extra confirmation)
//  Gates pass first — bonus score adds quality filter on top
// ════════════════════════════════════════════════════════════════════════

// BUY bonus (max 6)
int bull_bonus = 0
if e1 > e2 and e2 > e3
    bull_bonus += 2   // EMA stack bullish aligned
if close > e4
    bull_bonus += 1   // Price above major trend EMA
if rsi_val > 50 and rsi_up
    bull_bonus += 1   // RSI above 50 and rising
if stk_K > stk_D and stk_K[3] < 40
    bull_bonus += 1   // Stoch crossover from low territory
if di_plus > di_minus
    bull_bonus += 1   // Directional movement confirming upward

// SELL bonus (max 6)
int bear_bonus = 0
if e1 < e2 and e2 < e3
    bear_bonus += 2   // EMA stack bearish aligned
if close < e4
    bear_bonus += 1   // Price below major trend EMA
if rsi_val < 50 and rsi_down
    bear_bonus += 1   // RSI below 50 and falling
if stk_K < stk_D and stk_K[3] > 60
    bear_bonus += 1   // Stoch crossover from high territory
if di_minus > di_plus
    bear_bonus += 1   // Directional movement confirming downward


// ════════════════════════════════════════════════════════════════════════
//  PRECISION TRIGGERS (entry timing — must be a meaningful crossover)
// ════════════════════════════════════════════════════════════════════════

// BUY triggers — only fire from valid zones
bool T1_bull = ta.crossover(macd_line, sig_line) and macd_hist[1] < 0           // MACD cross from negative hist
bool T2_bull = ta.crossover(stk_K, stk_D) and stk_K[1] < 35                    // Stoch cross from oversold (<35)
bool T3_bull = ta.crossover(rsi_val, 50) and rsi_val[2] < 44                   // RSI cross 50 from clearly below
bool T4_bull = ta.crossover(e1, e2) and e2_rising and adx_val > 22             // EMA cross in rising trend

bool buy_trigger = T1_bull or T2_bull or T3_bull or T4_bull

// SELL triggers — only fire from valid zones
bool T1_bear = ta.crossunder(macd_line, sig_line) and macd_hist[1] > 0         // MACD cross from positive hist
bool T2_bear = ta.crossunder(stk_K, stk_D) and stk_K[1] > 65                  // Stoch cross from overbought (>65)
bool T3_bear = ta.crossunder(rsi_val, 50) and rsi_val[2] > 56                  // RSI cross 50 from clearly above
bool T4_bear = ta.crossunder(e1, e2) and e2_falling and adx_val > 22           // EMA cross in falling trend

bool sell_trigger = T1_bear or T2_bear or T3_bear or T4_bear


// ════════════════════════════════════════════════════════════════════════
//  COOLDOWN — prevents signal clustering
// ════════════════════════════════════════════════════════════════════════
var int last_buy_bar  = -999
var int last_sell_bar = -999

bool buy_cooled  = (bar_index - last_buy_bar)  > cooldown
bool sell_cooled = (bar_index - last_sell_bar) > cooldown


// ════════════════════════════════════════════════════════════════════════
//  FINAL SIGNALS
//  All layers must pass: Gates → Bonus Score → Trigger → Cooldown
// ════════════════════════════════════════════════════════════════════════
bool buy_signal  = buy_gates  and bull_bonus >= min_bonus and buy_trigger  and buy_cooled
bool sell_signal = sell_gates and bear_bonus >= min_bonus and sell_trigger and sell_cooled

// Update cooldown
if buy_signal
    last_buy_bar := bar_index
if sell_signal
    last_sell_bar := bar_index

// Signal strength label
strength_bull = bull_bonus >= 5 ? "STRONG BUY" : "BUY"
strength_bear = bear_bonus >= 5 ? "STRONG SELL" : "SELL"


// ════════════════════════════════════════════════════════════════════════
//  PLOT EMAs
// ════════════════════════════════════════════════════════════════════════
plot(show_emas ? e1 : na, "EMA 9",   color.new(color.aqua,   0), 1)
plot(show_emas ? e2 : na, "EMA 21",  color.new(color.white, 40), 1)
plot(show_emas ? e3 : na, "EMA 50",  color.new(color.orange, 0), 2)
plot(show_emas ? e4 : na, "EMA 200", color.new(color.red,    0), 2)


// ════════════════════════════════════════════════════════════════════════
//  BUY / SELL ARROWS + LABELS
// ════════════════════════════════════════════════════════════════════════
plotshape(buy_signal,  "BUY",  shape.triangleup,   location.belowbar, color.lime, size = size.normal)
plotshape(sell_signal, "SELL", shape.triangledown,  location.abovebar, color.red,  size = size.normal)

if buy_signal
    label.new(bar_index, low - atr * 0.7,
              strength_bull + "  " + str.tostring(bull_bonus) + "/6",
              style = label.style_label_up,
              color = bull_bonus >= 5 ? color.new(color.lime, 0) : color.new(color.lime, 20),
              textcolor = color.black, size = size.small)

if sell_signal
    label.new(bar_index, high + atr * 0.7,
              strength_bear + "  " + str.tostring(bear_bonus) + "/6",
              style = label.style_label_down,
              color = bear_bonus >= 5 ? color.new(color.red, 0) : color.new(color.red, 20),
              textcolor = color.white, size = size.small)


// ════════════════════════════════════════════════════════════════════════
//  SL / TP LINES (last signal only, auto-updated)
// ════════════════════════════════════════════════════════════════════════
var line  ln_sl  = na
var line  ln_tp1 = na
var line  ln_tp2 = na
var label lb_sl  = na
var label lb_tp1 = na
var label lb_tp2 = na

if (buy_signal or sell_signal) and show_sltp
    line.delete(ln_sl)
    line.delete(ln_tp1)
    line.delete(ln_tp2)
    label.delete(lb_sl)
    label.delete(lb_tp1)
    label.delete(lb_tp2)

    float sl_p  = buy_signal ? close - atr * sl_mult   : close + atr * sl_mult
    float tp1_p = buy_signal ? close + atr * tp1_mult  : close - atr * tp1_mult
    float tp2_p = buy_signal ? close + atr * tp2_mult  : close - atr * tp2_mult

    ln_sl  := line.new(bar_index, sl_p,  bar_index+1, sl_p,  extend=extend.right, color=color.red,               width=1, style=line.style_dashed)
    ln_tp1 := line.new(bar_index, tp1_p, bar_index+1, tp1_p, extend=extend.right, color=color.new(color.lime,20), width=2, style=line.style_dashed)
    ln_tp2 := line.new(bar_index, tp2_p, bar_index+1, tp2_p, extend=extend.right, color=color.new(color.lime,45), width=1, style=line.style_dashed)

    lb_sl  := label.new(bar_index+2, sl_p,  "🛑 SL   " + str.tostring(math.round(sl_p,  1)), style=label.style_label_right, color=color.red,               textcolor=color.white, size=size.tiny)
    lb_tp1 := label.new(bar_index+2, tp1_p, "🎯 TP1  " + str.tostring(math.round(tp1_p, 1)), style=label.style_label_right, color=color.new(color.lime,20), textcolor=color.black, size=size.tiny)
    lb_tp2 := label.new(bar_index+2, tp2_p, "🎯 TP2  " + str.tostring(math.round(tp2_p, 1)), style=label.style_label_right, color=color.new(color.lime,45), textcolor=color.black, size=size.tiny)


// ════════════════════════════════════════════════════════════════════════
//  BACKGROUND: EMA SLOPE TREND (more honest than stack alignment)
// ════════════════════════════════════════════════════════════════════════
bgcolor(e1_rising  and e2_rising  ? color.new(color.green, 95) : na, title="EMAs Rising (Bull)")
bgcolor(e1_falling and e2_falling ? color.new(color.red,   95) : na, title="EMAs Falling (Bear)")


// ════════════════════════════════════════════════════════════════════════
//  LIVE DASHBOARD — includes gate status so you see WHY signals fire/block
// ════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 3, 14,
  bgcolor      = color.new(color.black, 10),
  border_color = color.new(color.gray,  55),
  border_width = 1,
  frame_color  = color.new(color.gray,  55),
  frame_width  = 1)

if barstate.islast
    color GN   = color.new(color.lime,  40)
    color RD   = color.new(color.red,   40)
    color GY   = color.new(color.gray,  55)
    color HD   = color.new(color.navy,  10)
    color WH   = color.white
    color BK   = color.black

    // Header
    table.cell(dash, 0, 0, "  CONDITION",   text_color=WH, text_size=size.small, bgcolor=HD)
    table.cell(dash, 1, 0, "  BUY GATE",    text_color=WH, text_size=size.small, bgcolor=HD)
    table.cell(dash, 2, 0, "  SELL GATE",   text_color=WH, text_size=size.small, bgcolor=HD)

    // Gate 1: ADX
    table.cell(dash, 0, 1, "  ADX > " + str.tostring(adx_min) + "  (" + str.tostring(math.round(adx_val,1)) + ")", text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 1, G1_bull ? "✅ PASS" : "❌ FAIL", text_color=WH, text_size=size.small, bgcolor=G1_bull ? GN : RD)
    table.cell(dash, 2, 1, G1_bear ? "✅ PASS" : "❌ FAIL", text_color=WH, text_size=size.small, bgcolor=G1_bear ? GN : RD)

    // Gate 2: EMA Slope
    table.cell(dash, 0, 2, "  EMA Slope",   text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 2, G2_bull ? "✅ RISING" : "❌ FLAT/DN", text_color=WH, text_size=size.small, bgcolor=G2_bull ? GN : RD)
    table.cell(dash, 2, 2, G2_bear ? "✅ FALLING" : "❌ FLAT/UP", text_color=WH, text_size=size.small, bgcolor=G2_bear ? GN : RD)

    // Gate 3: RSI zone
    table.cell(dash, 0, 3, "  RSI Zone  (" + str.tostring(math.round(rsi_val,1)) + ")", text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 3, G3_bull ? "✅ PASS" : "❌ OB/OS",  text_color=WH, text_size=size.small, bgcolor=G3_bull ? GN : RD)
    table.cell(dash, 2, 3, G3_bear ? "✅ PASS" : "❌ OB/OS",  text_color=WH, text_size=size.small, bgcolor=G3_bear ? GN : RD)

    // Gate 4: MACD Hist Momentum
    table.cell(dash, 0, 4, "  MACD Momentum",  text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 4, G4_bull ? "✅ ACCEL ↑" : "❌ WEAK",   text_color=WH, text_size=size.small, bgcolor=G4_bull ? GN : RD)
    table.cell(dash, 2, 4, G4_bear ? "✅ ACCEL ↓" : "❌ WEAK",   text_color=WH, text_size=size.small, bgcolor=G4_bear ? GN : RD)

    // Gate 5: Candle
    table.cell(dash, 0, 5, "  Candle Close",   text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 5, G5_bull ? "✅ BULLISH" : "❌ BEARISH", text_color=WH, text_size=size.small, bgcolor=G5_bull ? GN : RD)
    table.cell(dash, 2, 5, G5_bear ? "✅ BEARISH" : "❌ BULLISH", text_color=WH, text_size=size.small, bgcolor=G5_bear ? GN : RD)

    // Gate 6: Overextension
    table.cell(dash, 0, 6, "  Overextension",  text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 6, G6_bull ? "✅ CLEAR" : "❌ EXTENDED", text_color=WH, text_size=size.small, bgcolor=G6_bull ? GN : RD)
    table.cell(dash, 2, 6, G6_bear ? "✅ CLEAR" : "❌ EXTENDED", text_color=WH, text_size=size.small, bgcolor=G6_bear ? GN : RD)

    // Gate 7: Divergence
    table.cell(dash, 0, 7, "  Divergence",     text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 7, G7_bull ? "✅ NONE" : "❌ BEAR DIV",  text_color=WH, text_size=size.small, bgcolor=G7_bull ? GN : RD)
    table.cell(dash, 2, 7, G7_bear ? "✅ NONE" : "❌ BULL DIV",  text_color=WH, text_size=size.small, bgcolor=G7_bear ? GN : RD)

    // Separator
    table.cell(dash, 0, 8, "  ── BONUS ──",    text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 8, "  BULL",           text_color=WH,         text_size=size.small, bgcolor=color.new(color.navy,30))
    table.cell(dash, 2, 8, "  BEAR",           text_color=WH,         text_size=size.small, bgcolor=color.new(color.navy,30))

    // Bonus scores
    table.cell(dash, 0, 9, "  EMA Stack",      text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1, 9, e1>e2 and e2>e3 ? "✅ +2" : "— 0",  text_color=WH, text_size=size.small, bgcolor=e1>e2 and e2>e3 ? GN : GY)
    table.cell(dash, 2, 9, e1<e2 and e2<e3 ? "✅ +2" : "— 0",  text_color=WH, text_size=size.small, bgcolor=e1<e2 and e2<e3 ? GN : GY)

    table.cell(dash, 0,10, "  RSI + Stoch",    text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    bool rs_bull = (rsi_val>50 and rsi_up) or (stk_K>stk_D and stk_K[3]<40)
    bool rs_bear = (rsi_val<50 and rsi_down) or (stk_K<stk_D and stk_K[3]>60)
    table.cell(dash, 1,10, rs_bull ? "✅ +1/2" : "— 0",         text_color=WH, text_size=size.small, bgcolor=rs_bull ? GN : GY)
    table.cell(dash, 2,10, rs_bear ? "✅ +1/2" : "— 0",         text_color=WH, text_size=size.small, bgcolor=rs_bear ? GN : GY)

    // Total bonus
    table.cell(dash, 0,11, "  BONUS TOTAL",    text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1,11, str.tostring(bull_bonus) + " / 6",   text_color=WH, text_size=size.small, bgcolor=bull_bonus>=min_bonus ? GN : GY)
    table.cell(dash, 2,11, str.tostring(bear_bonus) + " / 6",   text_color=WH, text_size=size.small, bgcolor=bear_bonus>=min_bonus ? RD : GY)

    // Trigger
    table.cell(dash, 0,12, "  TRIGGER",        text_color=WH, text_size=size.small, bgcolor=color.new(color.black,55))
    table.cell(dash, 1,12, buy_trigger  ? "✅ FIRED" : "⏳ WAITING",  text_color=WH, text_size=size.small, bgcolor=buy_trigger  ? GN : GY)
    table.cell(dash, 2,12, sell_trigger ? "✅ FIRED" : "⏳ WAITING",  text_color=WH, text_size=size.small, bgcolor=sell_trigger ? RD : GY)

    // Final status
    string stat    = buy_signal  ? "⚡ BUY SIGNAL"   : sell_signal  ? "⚡ SELL SIGNAL"  :
                     buy_gates   ? "🟡 BUY SETUP"    : sell_gates   ? "🟡 SELL SETUP"   :
                     e1_rising   ? "  BULL BIAS"     : e1_falling   ? "  BEAR BIAS"     : "  NEUTRAL"
    color  statcol = buy_signal  ? color.new(color.lime,15) : sell_signal ? color.new(color.red,15) :
                     buy_gates   ? color.new(color.yellow,40) : sell_gates ? color.new(color.orange,40) :
                     color.new(color.gray,45)

    table.cell(dash, 0,13, "  STATUS",         text_color=WH, text_size=size.small, bgcolor=HD)
    table.cell(dash, 1,13, stat,               text_color=WH, text_size=size.small, bgcolor=statcol)
    table.cell(dash, 2,13, stat,               text_color=WH, text_size=size.small, bgcolor=statcol)
````
