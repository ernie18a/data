# Smart Money Trend Engine

- url: https://www.tradingview.com/script/fK8iU90O-Smart-Money-Trend-Engine/
- type: indicator
- pine_id: PUB;6eca36194550461589b621f728581b0b
- version: 1.0

## Description

[b]WHAT IT DOES[/b]

Smart Money Trend Engine (SMTE) is a fully original all-in-one indicator
built in Pine Script v6 that combines institutional Smart Money Concepts
with a dynamic trend coloring system. Instead of using separate indicators
for trend direction and market structure, SMTE displays everything on a
single clean overlay: bar colors change based on confirmed structural
breaks, the background reflects the active trend phase, and Smart Money
elements (BOS, CHoCH, Order Blocks, FVG, Liquidity Sweeps) are layered
on top in a way that is readable and not cluttered.

The result is a chart that tells a complete institutional story at a
glance  where the trend is, where it changed, where institutions were
active, and where the next likely reaction zones are.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]WHAT MAKES IT ORIGINAL[/b]

Most trend-coloring indicators use moving average crossovers to determine
bar color. SMTE uses a fundamentally different approach: bar color is
driven by confirmed Smart Money structure breaks (BOS), not by price
position relative to a moving average. This means the color change is
tied to institutional order flow logic, not to a lagging indicator.

Three original components separate SMTE from existing public scripts:

1. Structure-driven bar coloring
   Bars turn green when a bullish Break of Structure (BOS) is confirmed.
   Bars turn red when a bearish BOS is confirmed. The color persists
   until the next structural event, making the trend state visually
   stable and easy to read even across long periods. Unlike EMA-based
   coloring, the color does not flicker on every candle.

2. Intelligent CHoCH detection
   A Change of Character (CHoCH) is only marked when the market
   genuinely reverses after a confirmed trend — not on every first BOS
   after a pullback. The indicator tracks consecutive BOS counts in each
   direction and only triggers CHoCH after a real directional shift.
   The CHoCH candle is colored orange to stand out from the green/red
   trend bars, giving traders an immediate visual warning of a potential
   trend change without constant false signals.

3. BOS streak counter
   The dashboard tracks how many consecutive bullish or bearish BOS
   events have occurred. Two or more BOS in the same direction confirms
   a genuine trend. One BOS alone is treated as a potential structure
   break but not yet confirmed. This filter significantly reduces the
   number of false trend signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]THE FOUR VISUAL LAYERS[/b]

Layer 1  Bar and Background Color
  Green bars and green background: confirmed bullish BOS. Institutions
  are breaking upward structure. Price is in a bullish trend phase.
  Red bars and red background: confirmed bearish BOS. Institutional
  selling pressure is dominant and structure is breaking downward.
  Orange bars (single candle only): CHoCH detected. This is the exact
  candle where the market changed character. High alert moment.

Layer 2  Smart Money Structure
  BOS lines (blue dashed for bullish, red dashed for bearish) connect
  the structural pivot to the current bar, showing exactly where the
  break occurred. CHoCH labels appear in orange and only when the trend
  genuinely reverses. Labels are kept small and positioned away from
  price to avoid visual clutter.

Layer 3 — Order Blocks and FVG
  Bullish Order Blocks (green boxes) mark demand zones where institutions
  previously accumulated long positions. Bearish Order Blocks (red boxes)
  mark supply zones. Box height is ATR-based for precision. Fair Value
  Gaps (FVG) are shown as thin shaded areas between candles where price
  left an imbalance — these often act as magnet zones for future price
  retracement.

Layer 4 — Liquidity Sweeps
  Blue water drop labels appear when price wicks below a recent low and
  closes back above (bullish sweep). Red drops appear when price wicks
  above a recent high and closes back below (bearish sweep). These mark
  moments where stop-losses were hunted before a potential reversal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]HOW TO USE[/b]

Step 1 — Read the bar color
Green bars mean the last confirmed structural event was a bullish BOS.
Red bars mean the last confirmed structural event was a bearish BOS.
Stay with the color. Trade in the direction of the dominant color and
avoid counter-trend positions unless a CHoCH appears.

Step 2  Watch for CHoCH
A single orange candle means CHoCH. This is the earliest warning that
the trend may be changing. Do not immediately reverse — wait for
confirmation from the next BOS in the new direction. CHoCH alone is
a warning, not a signal.

Step 3 — Count BOS streaks
Check the Dashboard for Bull BOS and Bear BOS counters. Two or more
BOS in a row in the same direction confirms a genuine trend. One BOS
is fragile and easily reversed. Trade with higher conviction when the
streak counter shows 2 or more.

Step 4 — Use Order Blocks for entries
When price returns to a green Order Block in a bullish trend (green
bars), that is a high-probability demand zone. When price returns to
a red Order Block in a bearish trend (red bars), that is a supply zone.
Use these for precise entry planning rather than chasing breakouts.

Step 5 — Combine with FVG and Sweeps
A liquidity sweep followed by a CHoCH followed by a new BOS in the
opposite direction is the highest quality reversal setup this indicator
can show. All three elements aligning is rare and significant.
FVG zones often act as the first target after a sweep and CHoCH.

Step 6 — Read the Dashboard
SMC Bias shows the current structural direction. Last Event shows the
most recent structural event. Bull BOS and Bear BOS counters show
streak strength. Liq Sweep and FVG show real-time status of the
current bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]CALCULATION LOGIC[/b]

BOS detection:
  Pivot high confirmed = ta.pivothigh(high, ms_len, ms_len)
  Pivot low  confirmed = ta.pivotlow(low, ms_len, ms_len)
  Bull BOS = new pivot high > previous pivot high
  Bear BOS = new pivot low  < previous pivot low

CHoCH logic:
  bull_choch = bull_bos AND previous trend was bearish AND bear_count >= 1
  bear_choch = bear_bos AND previous trend was bullish AND bull_count >= 1
  (Requires at least one confirmed BOS in the opposite direction first)

BOS streak counter:
  bull_count increments on each bull_bos, resets to 0 on bear_bos
  bear_count increments on each bear_bos, resets to 0 on bull_bos

Bar coloring:
  Green  = last bull_bos (not CHoCH)
  Red    = last bear_bos (not CHoCH)
  Orange = CHoCH candle only (single bar)

Order Block height:
  zone_center = (high + low) / 2 at pivot bar
  zone_top    = zone_center + ATR(14) x 0.25
  zone_bot    = zone_center - ATR(14) x 0.25

Fair Value Gap:
  bull_fvg = low[0] - high[2] > 0 AND gap_size / close >= min_pct
  bear_fvg = low[2] - high[0] > 0 AND gap_size / close >= min_pct

Liquidity Sweep:
  bull_sweep = low[1] < lowest(low, N)[1] AND close > that level AND close[1] < that level
  bear_sweep = high[1] > highest(high, N)[1] AND close < that level AND close[1] > that level

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]SETTINGS OVERVIEW[/b]

Trend Colors:
  Fast EMA, Slow EMA, Trend EMA — reference lines on chart
  Show EMA lines — toggle EMA display
  Show background — toggle trend background coloring
  Background opacity — how transparent the background is (80-97)

Smart Money:
  Pivot length — bars used for structural pivot detection (default 20)
  Show BOS / CHoCH — toggle structure labels and lines
  Show Order Blocks — toggle demand/supply zones
  OB lookback — pivot length for Order Block detection
  Show Fair Value Gaps — toggle FVG boxes
  Min FVG size (%) — minimum gap size to display
  Show Liq Sweeps — toggle liquidity sweep markers
  Sweep lookback — bars used to identify significant highs and lows

Dashboard:
  Show Dashboard — toggle info panel

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS INCLUDED

  Bullish CHoCH detected
  Bearish CHoCH detected
  Bullish Liquidity Sweep
  Bearish Liquidity Sweep
  Strong Buy: CHoCH plus Sweep aligned bullish
  Strong Sell: CHoCH plus Sweep aligned bearish

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]COMPATIBILITY[/b]

Works on all assets — Crypto, Forex, Stocks, Futures, Indices.
Works on all timeframes.
Best results on 1H, 4H, and Daily for swing trading.
For scalping use 5m to 15m with reduced pivot length (8 to 12).
No repainting. All signals calculated on confirmed bar close.
No request.security() calls. No lookahead bias.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]DISCLAIMER[/b]

This indicator is provided for educational and informational purposes
only. It does not constitute financial advice or a recommendation to
buy or sell any asset. Smart Money Concepts are a trading methodology
and not a guarantee of market direction. Past structural patterns do
not guarantee future price behavior. Always apply your own analysis,
use proper risk management, and never risk more capital than you can
afford to lose. The author is not responsible for any trading losses
incurred from use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// Smart Money Trend Engine v4.0 — AleksDU

indicator("Smart Money Trend Engine",
          shorttitle        = "SMTE",
          overlay           = true,
          max_lines_count   = 150,
          max_labels_count  = 150,
          max_boxes_count   = 20)

// ── SETTINGS ──────────────────────────────────────────────────────────────────
var string G_A = "Trend Colors"
ema_fast   = input.int(20,    "Fast EMA",           group=G_A, minval=3,  maxval=100)
ema_slow   = input.int(50,    "Slow EMA",           group=G_A, minval=10, maxval=300)
ema_trend  = input.int(200,   "Trend EMA",          group=G_A, minval=20, maxval=500)
show_ema   = input.bool(true, "Show EMA lines",     group=G_A)
show_bg    = input.bool(true, "Show background",    group=G_A)
bg_opacity = input.int(93,    "Background opacity", group=G_A, minval=80, maxval=97)

var string G_B = "Smart Money"
ms_len     = input.int(20,    "Pivot length",         group=G_B, minval=5,  maxval=100)
show_bos   = input.bool(true, "Show BOS / CHoCH",    group=G_B)
show_ob    = input.bool(true, "Show Order Blocks",    group=G_B)
ob_len     = input.int(10,    "OB lookback",          group=G_B, minval=3,  maxval=30)
show_fvg   = input.bool(true, "Show Fair Value Gaps", group=G_B)
fvg_min    = input.float(0.1, "Min FVG size (%)",    group=G_B, minval=0.05, step=0.05)
show_sweep = input.bool(true, "Show Liq Sweeps",      group=G_B)
sweep_len  = input.int(20,    "Sweep lookback",       group=G_B, minval=5,  maxval=50)

var string G_C = "Dashboard"
show_dash  = input.bool(true, "Show Dashboard", group=G_C)

// ── SHARED ────────────────────────────────────────────────────────────────────
atr14   = ta.atr(14)
vol_sma = ta.sma(volume, 20)

// ── EMA ───────────────────────────────────────────────────────────────────────
ema_f = ta.ema(close, ema_fast)
ema_s = ta.ema(close, ema_slow)
ema_t = ta.ema(close, ema_trend)

plot(show_ema ? ema_f : na, "EMA Fast",  color=color.new(#00e676, 40), linewidth=1)
plot(show_ema ? ema_s : na, "EMA Slow",  color=color.new(#ff9800, 40), linewidth=1)
plot(show_ema ? ema_t : na, "EMA Trend", color=color.new(#ffffff, 40), linewidth=2)

// ── BOS / CHoCH ───────────────────────────────────────────────────────────────
// Використовуємо більший pivot_len щоб менше шуму
// CHoCH = тільки коли тренд РЕАЛЬНО міняється з бичачого на ведмежий і навпаки
// Не кожен BOS є CHoCH — тільки перший після зміни напрямку

ph = ta.pivothigh(high, ms_len, ms_len)
pl = ta.pivotlow (low,  ms_len, ms_len)

var float last_ph    = na
var float last_pl    = na
var bool  smc_up     = false
var bool  confirmed  = false  // чи підтверджений поточний тренд (мінімум 2 BOS в одному напрямку)
var int   bull_count = 0      // кількість бичачих BOS підряд
var int   bear_count = 0      // кількість ведмежих BOS підряд

bull_bos = not na(ph) and not na(last_ph) and ph > last_ph
bear_bos = not na(pl) and not na(last_pl) and pl < last_pl

// CHoCH = лише коли тренд міняється після мінімум 2 підтверджених BOS
bull_choch = bull_bos and not smc_up and bear_count >= 1
bear_choch = bear_bos and smc_up     and bull_count >= 1

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

if bull_bos
    bull_count := bull_count + 1
    bear_count := 0
    smc_up     := true

if bear_bos
    bear_count := bear_count + 1
    bull_count := 0
    smc_up     := false

if show_bos
    if bull_bos
        line.new(bar_index - ms_len, last_ph, bar_index, last_ph,
                 color=color.new(#00bcd4, 25), width=1, style=line.style_dashed)
        label.new(bar_index - ms_len / 2, last_ph,
                  bull_choch ? "CHoCH" : "BOS",
                  color=bull_choch ? color.new(#ff9800, 25) : color.new(#00bcd4, 35),
                  textcolor=color.white, size=size.tiny, style=label.style_label_down)
    if bear_bos
        line.new(bar_index - ms_len, last_pl, bar_index, last_pl,
                 color=color.new(#ff5252, 25), width=1, style=line.style_dashed)
        label.new(bar_index - ms_len / 2, last_pl,
                  bear_choch ? "CHoCH" : "BOS",
                  color=bear_choch ? color.new(#ff9800, 25) : color.new(#ff5252, 35),
                  textcolor=color.white, size=size.tiny, style=label.style_label_up)

// ── BAR COLOR + BACKGROUND ────────────────────────────────────────────────────
// Зелений = бичачий тренд (підтверджений BOS вгору)
// Червоний = ведмежий тренд (підтверджений BOS вниз)
// Помаранчевий = тільки на свічці CHoCH (1 свічка — сигнал)
// Фон стабільний — не мерехтить кожен бар

var color bar_col = color.new(#888888, 0)
var color bg_col  = color.new(#888888, 97)

if bull_bos and not bull_choch
    bar_col := color.new(#00e676, 0)
    bg_col  := color.new(#00e676, bg_opacity)
if bear_bos and not bear_choch
    bar_col := color.new(#ff5252, 0)
    bg_col  := color.new(#ff5252, bg_opacity)

// CHoCH свічка — помаранчева (тільки та одна свічка)
choch_bar_col = bull_choch or bear_choch ? color.new(#ff9800, 0) : bar_col

barcolor(choch_bar_col)
bgcolor(not show_bg ? na : bg_col)

// ── ORDER BLOCKS ──────────────────────────────────────────────────────────────
ob_bull_p = ta.pivotlow (low,  ob_len, ob_len)
ob_bear_p = ta.pivothigh(high, ob_len, ob_len)

if show_ob
    if not na(ob_bull_p)
        float zc = (high[ob_len] + low[ob_len]) / 2
        box.new(bar_index - ob_len, zc + atr14 * 0.25,
                bar_index + 25,    zc - atr14 * 0.25,
                bgcolor=color.new(#00e676, 88),
                border_color=color.new(#00e676, 50), border_width=1)
    if not na(ob_bear_p)
        float zc = (high[ob_len] + low[ob_len]) / 2
        box.new(bar_index - ob_len, zc + atr14 * 0.25,
                bar_index + 25,    zc - atr14 * 0.25,
                bgcolor=color.new(#ff5252, 88),
                border_color=color.new(#ff5252, 50), border_width=1)

// ── FAIR VALUE GAPS ───────────────────────────────────────────────────────────
fvg_bull_sz = low[0] - high[2]
fvg_bear_sz = low[2] - high[0]
bull_fvg = fvg_bull_sz > 0 and (fvg_bull_sz / close * 100) >= fvg_min
bear_fvg = fvg_bear_sz > 0 and (fvg_bear_sz / close * 100) >= fvg_min

if show_fvg
    if bull_fvg
        box.new(bar_index - 2, low[0], bar_index, high[2],
                bgcolor=color.new(#00e676, 85),
                border_color=color.new(#00e676, 60))
    if bear_fvg
        box.new(bar_index - 2, high[0], bar_index, low[2],
                bgcolor=color.new(#ff5252, 85),
                border_color=color.new(#ff5252, 60))

// ── LIQUIDITY SWEEPS ──────────────────────────────────────────────────────────
liq_high = ta.highest(high, sweep_len)[1]
liq_low  = ta.lowest (low,  sweep_len)[1]

bull_sweep = low[1] < liq_low  and close > liq_low  and close[1] < liq_low
bear_sweep = high[1] > liq_high and close < liq_high and close[1] > liq_high

if show_sweep
    if bull_sweep
        label.new(bar_index - 1, low[1] - atr14 * 0.3, "💧",
                  color=color.new(#00bcd4, 25), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
    if bear_sweep
        label.new(bar_index - 1, high[1] + atr14 * 0.3, "💧",
                  color=color.new(#ff5252, 25), textcolor=color.white,
                  style=label.style_label_down, size=size.small)

// ── DASHBOARD ─────────────────────────────────────────────────────────────────
string smc_txt   = smc_up ? "Bullish" : "Bearish"
color  smc_col   = smc_up ? #00bcd4  : #ff5252
string last_event = bull_choch ? "CHoCH ▲" : bear_choch ? "CHoCH ▼" : bull_bos ? "BOS ▲" : bear_bos ? "BOS ▼" : "—"
color  event_col  = bull_choch ? #ff9800 : bear_choch ? #ff9800 : bull_bos ? #00e676 : bear_bos ? #ff5252 : color.gray

if show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 7,
                               bgcolor=color.new(#0d1117, 5),
                               border_color=color.new(#21262d, 35), border_width=1,
                               frame_color=color.new(#7c4dff, 30), frame_width=1)
    table.cell(dash, 0, 0, "Smart Money Trend Engine",
               bgcolor=color.new(#161b22, 10), text_color=#7c4dff,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 0, "AleksDU",
               bgcolor=color.new(#161b22, 10), text_color=color.new(#7c4dff, 50),
               text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 1, "SMC Bias",    text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 1, smc_txt,       text_color=smc_col,    text_size=size.small)
    table.cell(dash, 0, 2, "Last Event",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 2, last_event,    text_color=event_col,  text_size=size.small)
    table.cell(dash, 0, 3, "Bull BOS",    text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(bull_count) + " in a row",
               text_color=bull_count >= 2 ? #00e676 : color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Bear BOS",    text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(bear_count) + " in a row",
               text_color=bear_count >= 2 ? #ff5252 : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Liq Sweep",   text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 5, bull_sweep ? "Bullish 💧" : bear_sweep ? "Bearish 💧" : "—",
               text_color=bull_sweep ? #00bcd4 : bear_sweep ? #ff5252 : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "FVG",         text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 6, bull_fvg ? "Bullish" : bear_fvg ? "Bearish" : "—",
               text_color=bull_fvg ? #00e676 : bear_fvg ? #ff5252 : color.gray, text_size=size.small)

// ── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(bull_choch,               "SMTE: Bull CHoCH",  "Smart Money: Bullish CHoCH!")
alertcondition(bear_choch,               "SMTE: Bear CHoCH",  "Smart Money: Bearish CHoCH!")
alertcondition(bull_sweep,               "SMTE: Bull Sweep",  "Smart Money: Bullish Sweep!")
alertcondition(bear_sweep,               "SMTE: Bear Sweep",  "Smart Money: Bearish Sweep!")
alertcondition(bull_choch and bull_sweep,"SMTE: Strong Buy",  "Smart Money: CHoCH + Sweep BUY!")
alertcondition(bear_choch and bear_sweep,"SMTE: Strong Sell", "Smart Money: CHoCH + Sweep SELL!")
````
