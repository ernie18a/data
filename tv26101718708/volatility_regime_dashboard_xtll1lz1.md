# Volatility Regime Dashboard

- url: https://www.tradingview.com/script/XtLL1lZ1/
- type: indicator
- pine_id: PUB;d781f55da45a4aafb84febad38705d04
- version: 4.0

## Description

## Overview
Volatility Regime Dashboard is a context and visualization tool that classifies the
current volatility state of any symbol as **Compressed**, **Normal**, or **Expanded**.
Instead of plotting a single raw volatility line, it combines two independent
normalized measures and only changes the displayed state when both of them agree.
A compact table reports the underlying numbers and how many bars the current regime
has lasted.

This script is a visualization and context tool. It does not generate buy or sell
signals. It does not provide financial advice and makes no performance, accuracy,
or future-result claims.

## What it visualizes
- A line in its own pane showing the **percentile rank of price-normalized ATR**
  (0-100), with dashed guides at the compressed and expanded thresholds and a
  dotted midline.
- A **regime background shade** (optional) coloring the pane by the current state.
- A **context table** with the regime name, the ATR percentile value, the
  Fast/Slow ATR compression ratio, whether the two measures currently agree, the
  regime persistence in bars, and the ATR length in use.

## How it works
Two measures are computed independently:
1. **Price-normalized ATR percentile.** ATR is divided by price (so the measure is
   comparable across symbols and price levels), then ranked as a percentile over a
   user-defined lookback (default 252 bars). A high percentile means current ATR is
   large relative to its own recent history; a low percentile means it is small.
2. **Fast/Slow ATR compression ratio.** A fast-window ATR is divided by a
   slow-window ATR. A ratio above 1 means range is expanding relative to its
   baseline; below 1 means it is compressing.

Each measure is classified into Compressed (-1), Normal (0), or Expanded (+1) using
its own thresholds. The displayed regime uses **hysteresis**: it flips to Expanded
or Compressed only when **both** measures agree on that direction, returns to Normal
only when both measures sit in their middle bands, and otherwise **holds** the prior
regime while the two measures disagree. This reduces flicker compared with reacting
to either measure alone. A persistence counter tracks how many consecutive bars the
current regime has held.

## How to use it
- Read the regime as **situational context** about how active the market currently
  is relative to its own recent behavior, not as an instruction to act.
- Watch the percentile line approach the dashed thresholds to anticipate when a
  regime change may be confirmed by both measures.
- Use the persistence counter to gauge whether a regime is freshly established or
  well established.
- Adjust the lookback and thresholds to match the symbol and timeframe you study;
  the defaults suit daily charts and are a starting point, not an optimized set.

## What makes it original
Most volatility tools plot a single raw or smoothed value. This dashboard derives a
**single discrete regime from the agreement of two structurally different measures**
- a within-history percentile rank and a fast-versus-slow ratio - and gates state
changes with hysteresis so the regime persists through brief disagreement. It then
surfaces the **persistence duration** of the current regime. The combination of
cross-measure agreement, hysteresis, and persistence reporting is the contribution;
it is not a re-skin of a built-in ATR, Bollinger, or standard-deviation indicator.

## What it does not do
- Does not generate buy/sell signals.
- Does not give entry/exit, target-level, or position-sizing instructions.
- Does not predict price or forecast performance.
- Does not run a strategy or backtest.
- Does not place or manage orders for you.

## Limitations
- Volatility regime is **descriptive context**, not a forecast; an Expanded or
  Compressed state can persist or reverse at any time.
- The percentile rank depends on the lookback window; very small lookbacks make the
  state noisy and very large ones make it slow to update.
- On symbols or timeframes with sparse history, the percentile may be unstable until
  enough bars are available.
- ATR divided by price assumes price is positive and non-zero; exotic data feeds may
  behave unexpectedly.
- Default thresholds are reasonable starting values, not values tuned for any
  particular market.

## Suggested chart setup
- Use a liquid, recognizable symbol on a daily timeframe so the percentile lookback
  has enough history.
- Keep the chart clean: this indicator opens in its own pane, so remove unrelated
  indicators and let the percentile line, threshold guides, regime background, and
  table be clearly visible.
- Make sure the indicator name, symbol, and timeframe are visible in any published
  screenshot.

---

## Japanese notes / 日本語補足
このスクリプトはボラティリティの状態を「Compressed（収縮）」「Normal（通常）」
「Expanded（拡大）」として表示する、コンテキスト把握用の可視化ツールです。価格で
正規化したATRのパーセンタイル順位と、ファスト／スロー期間のATR比率という2つの独立
した指標を用い、両者が一致したときだけ状態を変更するヒステリシス方式を採用していま
す。表には各指標の数値と、現在の状態が何本のバー継続しているかを表示します。

これは相場の状況を把握するための可視化ツールであり、売買の指示は行いません。投資
助言ではなく、将来の値動きや運用成績に関する主張も一切行いません。新規の建玉や手
仕舞い、ポジションサイズの提案も行いません。しきい値やルックバックは銘柄や時間足に
合わせて調整してください（初期値は最適化されたものではありません）。

## Source Code

````pine
//@version=6
// Volatility Regime Dashboard
// Purpose: classify the current volatility state as Compressed, Normal, or
// Expanded from two independent normalized measures (a rolling percentile rank of
// price-normalized ATR, and a fast-versus-slow ATR compression ratio). The state
// only changes when both measures agree (hysteresis), and the panel reports how
// long the current regime has persisted.
// This is a context/visualization tool only. It does NOT generate buy/sell
// signals, entries, exits, or targets, and makes no performance or future-result
// claims. Not financial advice.
indicator("Volatility Regime Dashboard", shorttitle="Vol Regime", overlay=false)
// ----- Inputs: measures -----
grpM = "Measures"
atrLen   = input.int(14,  "ATR length",            minval=2,  maxval=200, group=grpM, tooltip="ATR used for the price-normalized volatility measure.")
rankLen  = input.int(252, "Percentile lookback",   minval=20, maxval=2000, group=grpM, tooltip="How many bars define the percentile rank of normalized ATR. ~252 ~ one trading year on daily bars.")
fastLen  = input.int(5,   "Fast ATR length",       minval=1,  maxval=100, group=grpM, tooltip="Fast-window ATR for the compression ratio.")
slowLen  = input.int(20,  "Slow ATR length",       minval=2,  maxval=300, group=grpM, tooltip="Slow-window ATR for the compression ratio. The ratio is Fast ATR / Slow ATR.")
// ----- Inputs: classification thresholds -----
grpT = "Thresholds"
prLow    = input.float(25.0, "Percentile: compressed below", minval=0.0,  maxval=100.0, step=1.0, group=grpT)
prHigh   = input.float(75.0, "Percentile: expanded above",   minval=0.0,  maxval=100.0, step=1.0, group=grpT)
ratLow   = input.float(0.90, "Ratio: compressed below",      minval=0.10, maxval=1.00,  step=0.01, group=grpT, tooltip="Fast/Slow ATR ratio under this counts as compressing.")
ratHigh  = input.float(1.10, "Ratio: expanded above",        minval=1.00, maxval=3.00,  step=0.01, group=grpT, tooltip="Fast/Slow ATR ratio over this counts as expanding.")
// ----- Inputs: display -----
grpUI = "Display"
tablePos    = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpUI)
showTable   = input.bool(true,  "Show context table", group=grpUI)
compactMode = input.bool(false, "Compact table", group=grpUI, tooltip="Hide 'Measures agree' and 'ATR length' for a smaller panel.")
tblText     = input.string("Large", "Table text size", options=["Small", "Normal", "Large", "Huge"], group=grpUI, tooltip="Font size of the context table. Increase if the panel is hard to read on your screen.")
txtCol      = input.color(color.white, "Table text color",       group=grpUI, tooltip="Use a dark color if you prefer a light panel.")
labelBg     = input.color(#1e222d,     "Table label background", group=grpUI)
valueBg     = input.color(#2a2e39,     "Table value background", group=grpUI)
shadeBg     = input.bool(true, "Shade pane background by regime", group=grpUI)
compCol     = input.color(color.new(color.blue,  0), "Compressed color", group=grpUI)
normCol     = input.color(color.new(color.gray,  0), "Normal color",     group=grpUI)
expCol      = input.color(color.new(color.orange,0), "Expanded color",   group=grpUI)
// ----- Inputs: alerts -----
grpA = "Alerts"
alertOnClose = input.bool(true, "Alert only on bar close", group=grpA, tooltip="When on, a regime-change alert fires only after the bar closes, so it cannot flicker intrabar and then revert.")
// ----- Input sanity checks: stop with a clear message on misconfiguration -----
if prLow >= prHigh
    runtime.error("Percentile thresholds: 'compressed below' must be less than 'expanded above'.")
if ratLow >= ratHigh
    runtime.error("Ratio thresholds: 'compressed below' must be less than 'expanded above'.")
if fastLen >= slowLen
    runtime.error("ATR lengths: 'Fast ATR length' must be less than 'Slow ATR length'.")
// ----- Measure 1: rolling percentile rank of price-normalized ATR -----
atrPct = close != 0 ? ta.atr(atrLen) / close * 100.0 : na
pr     = ta.percentrank(atrPct, rankLen)            // 0..100, share of lookback at/below now
// ----- Measure 2: fast vs slow ATR compression ratio -----
slowAtr = ta.atr(slowLen)
ratio   = slowAtr != 0 ? ta.atr(fastLen) / slowAtr : na
// ----- Per-measure state: +1 expanded, -1 compressed, 0 middle band -----
prState  = pr    >= prHigh  ? 1 : pr    <= prLow  ? -1 : 0
ratState = ratio >= ratHigh ? 1 : ratio <= ratLow ? -1 : 0
// Strong agreement only when both measures point the same non-neutral way.
agree = (prState == ratState and prState != 0) ? prState : 0
// ----- Hysteresis regime: flips only on agreement; returns to Normal only when
// both measures sit in the middle band; otherwise holds the prior regime. -----
var int regime = 0
if agree != 0
    regime := agree
else if prState == 0 and ratState == 0
    regime := 0
// else: hold previous regime (disagreement does not flip the state)
// ----- Persistence: how many consecutive bars in the current regime -----
var int regimeBars = 0
regimeBars := (na(regime[1]) or regime != regime[1]) ? 1 : regimeBars + 1
// dataReady: both measures have enough history to be meaningful.
dataReady  = not na(pr) and not na(ratio)
regimeCol  = regime == 1 ? expCol : regime == -1 ? compCol : normCol
regimeName = not dataReady ? "Warming up" : regime == 1 ? "Expanded" : regime == -1 ? "Compressed" : "Normal"
// ----- Plot: percentile rank with threshold guides and regime background -----
plot(pr, "ATR Percentile Rank", color=regimeCol, linewidth=2)
hline(prHigh, "Expanded threshold", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(prLow,  "Compressed threshold", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(50,     "Midline", color=color.new(color.gray, 80), linestyle=hline.style_dotted)
bgcolor(shadeBg ? color.new(regimeCol, 90) : na, title="Regime background")
// ----- Context table -----
posMap(p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right
stateWord(s) => s == 1 ? "Expanded" : s == -1 ? "Compressed" : "Normal"
// Map the text-size dropdown to a Pine size constant.
sizeMap(s) => s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Huge" ? size.huge : size.large
tSize = sizeMap(tblText)
var table tbl = table.new(posMap(tablePos), 2, compactMode ? 4 : 6, border_width=1, frame_width=2, frame_color=color.new(color.gray, 40))
if barstate.islast and showTable
    // Guard strings so warmup / low-history bars show a dash instead of "NaN".
    prCell    = na(pr)    ? "—" : str.tostring(pr,    "#.#")  + "  (" + stateWord(prState)  + ")"
    ratioCell = na(ratio) ? "—" : str.tostring(ratio, "#.##") + "  (" + stateWord(ratState) + ")"
    persCell  = dataReady ? str.tostring(regimeBars) + " bars" : "—"
    // Status row (shown in both modes)
    table.cell(tbl, 0, 0, "Volatility Regime", text_size=tSize, text_color=txtCol,      bgcolor=labelBg)
    table.cell(tbl, 1, 0, regimeName,          text_size=tSize, text_color=color.white, bgcolor=color.new(regimeCol, 0))
    // Measure rows (shown in both modes)
    table.cell(tbl, 0, 1, compactMode ? "ATR %ile" : "ATR %ile rank", text_size=tSize, text_color=txtCol, bgcolor=labelBg)
    table.cell(tbl, 1, 1, prCell,              text_size=tSize, text_color=txtCol, bgcolor=valueBg)
    table.cell(tbl, 0, 2, "Fast/Slow ATR",     text_size=tSize, text_color=txtCol, bgcolor=labelBg)
    table.cell(tbl, 1, 2, ratioCell,           text_size=tSize, text_color=txtCol, bgcolor=valueBg)
    if compactMode
        table.cell(tbl, 0, 3, "Persistence",   text_size=tSize, text_color=txtCol, bgcolor=labelBg)
        table.cell(tbl, 1, 3, persCell,        text_size=tSize, text_color=txtCol, bgcolor=valueBg)
    else
        table.cell(tbl, 0, 3, "Measures agree", text_size=tSize, text_color=txtCol, bgcolor=labelBg)
        table.cell(tbl, 1, 3, agree != 0 ? "Yes" : "No", text_size=tSize, text_color=txtCol, bgcolor=valueBg)
        table.cell(tbl, 0, 4, "Persistence",    text_size=tSize, text_color=txtCol, bgcolor=labelBg)
        table.cell(tbl, 1, 4, persCell,         text_size=tSize, text_color=txtCol, bgcolor=valueBg)
        table.cell(tbl, 0, 5, "ATR length",     text_size=tSize, text_color=txtCol, bgcolor=labelBg)
        table.cell(tbl, 1, 5, str.tostring(atrLen), text_size=tSize, text_color=txtCol, bgcolor=valueBg)
// ----- Alert: state change only (never a trade instruction) -----
regimeChanged = ta.change(regime) != 0
alertcondition(alertOnClose ? (regimeChanged and barstate.isconfirmed) : regimeChanged, title="Volatility regime changed", message="Volatility regime changed")
````
