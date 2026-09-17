<!-- tradingview-pine-id: PUB;5fea11135ecf42f5ac4f1b955f09a337 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Crossover Whipsaw Guard

Source: https://www.tradingview.com/script/QUD0WnBa/

## Description

**Crossover Whipsaw Guard**

**What it does**
Turns a moving-average crossover into a two-step state: *pending* the moment the fast MA crosses the slow one, *confirmed* once the two averages have separated by at least a minimum percentage (default 0.30 % of the slow MA). Optional extra conditions for confirmation: volume above its 20-bar average, and a higher high plus higher low over the last N bars (mirrored for bearish crosses). A confirmed state holds until the averages cross back; it is never downgraded.

**What you see**
- Both averages (defaults EMA 9 and DEMA 200; EMA, SMA and DEMA selectable for each).
- The area between them filled gray while pending, teal or red once confirmed.
- A small dot on the bar where confirmation happened.
- A table with the current separation, the threshold, active extra filters and the state.
- Alerts for each of the four transitions: bullish pending, bullish confirmed, bearish pending, bearish confirmed.

**Why I built it — the measurement behind it**
Crossovers of a fast and a slow average produce many entries that get stopped out within days. I measured which conditions at the crossover bar reduced that, on 47,013 daily bullish crossovers (EMA 9 over DEMA 200) across 1,758 US stocks, 2014–2026, including later-delisted names, each followed by the same trailing exit:

| Condition at the crossover bar | Share of crossovers kept | Share of trades ending positive | vs. the crossovers it removed |
|---|---:|---:|---:|
| none (all crossovers) | 100 % | 31.0 % | — |
| separation ≥ 0.10 % | 77 % | 31.8 % | 28.6 % |
| separation ≥ 0.30 % | 45 % | 33.1 % | 29.4 % |
| volume > 1.1 × 20-bar average | 36 % | 32.8 % | 30.1 % |
| higher high & higher low (10 bars) | 85 % | 31.5 % | 28.8 % |

All four held in the second half of the sample (from September 2020, +2.1 to +2.8 points each). The filters overlap: combining separation with volume kept 20 % of crossovers at 33.5 %, not more.

**What the measurement does not show — please read**
- The improvement is in *fewer stop-outs*, not in better returns afterwards. Measured without any exit, 20 and 60 bars after the crossover, the separation and volume conditions left the kept and removed groups within a point of each other; the higher-high/higher-low condition improved the 20-bar outcome (+3.4 points) but not the 60-bar one. This is a whipsaw filter, not a return predictor.
- The absolute hit rates (31 %) belong to one specific exit rule with a tight trailing threshold, typical for trend following. Your exit will give different absolute numbers.
- Tested on daily bars and on one pair of averages. The separation threshold is a percentage of price, so it needs adjusting for other timeframes and volatilities — the table shows the current separation to help with that.
- A confirmed state is a description of where the averages are. It is not a recommendation to do anything.

No buy or sell signals are generated, and none are implied.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BotTradeLab

//@version=6
indicator("Crossover Whipsaw Guard", "XO Guard", overlay = true)
plot(close)
// ── Inputs ────────────────────────────────────────────────────────────────────
fastType = input.string("EMA", "Fast MA type", options = ["EMA", "SMA", "DEMA"])
fastLen  = input.int(9, "Fast MA length", minval = 1)
slowType = input.string("DEMA", "Slow MA type", options = ["EMA", "SMA", "DEMA"])
slowLen  = input.int(200, "Slow MA length", minval = 2)
sepThr   = input.float(0.30, "Minimum separation (% of slow MA)", minval = 0.0, step = 0.05)
useVol   = input.bool(false, "Also require volume above its 20-bar average")
volMult  = input.float(1.1, "Volume multiple", minval = 0.5, step = 0.1)
useHhHl  = input.bool(false, "Also require higher high & higher low (bullish) / lower low & lower high (bearish)")
hhhlLen  = input.int(10, "HH/HL lookback (bars)", minval = 1)
confirmOnClose = input.bool(true, "Update state on closed bars only")
showTable = input.bool(true, "Show info table")

// ── Moving averages ───────────────────────────────────────────────────────────
// All three are computed every bar so the ta.* calls stay unconditional.
ma(float src, string kind, int len) =>
    float e = ta.ema(src, len)
    float s = ta.sma(src, len)
    float d = 2 * e - ta.ema(e, len)
    kind == "EMA" ? e : kind == "SMA" ? s : d

float fast   = ma(close, fastType, fastLen)
float slow   = ma(close, slowType, slowLen)
float sepPct = (fast - slow) / slow * 100
int   side   = fast > slow ? 1 : fast < slow ? -1 : 0

// ── Confirmation conditions ───────────────────────────────────────────────────
float volMa    = ta.sma(volume, 20)
bool  volOk    = not useVol or na(volume) or volume > volMa * volMult
bool  hhhlBull = high > high[hhhlLen] and low > low[hhhlLen]
bool  hhhlBear = high < high[hhhlLen] and low < low[hhhlLen]
bool  structOk = not useHhHl or (side == 1 ? hhhlBull : side == -1 ? hhhlBear : false)
bool  sepOk    = math.abs(sepPct) >= sepThr
bool  evalBar  = not confirmOnClose or barstate.isconfirmed

// ── State machine ─────────────────────────────────────────────────────────────
// 0 none | 1 bullish cross, pending | 2 bullish, confirmed | -1 bearish, pending | -2 bearish, confirmed
// A confirmed state holds until the MAs cross back; it is never downgraded to pending.
var int state = 0
if evalBar
    if side == 1
        if state <= 0
            state := 1
        if state == 1 and sepOk and volOk and structOk
            state := 2
    else if side == -1
        if state >= 0
            state := -1
        if state == -1 and sepOk and volOk and structOk
            state := -2
    else
        state := 0

bool bullPending   = state == 1  and state[1] != 1
bool bearPending   = state == -1 and state[1] != -1
bool bullConfirmed = state == 2  and state[1] != 2
bool bearConfirmed = state == -2 and state[1] != -2

// ── Plots ─────────────────────────────────────────────────────────────────────
pFast = plot(fast, "Fast MA", color = color.new(color.orange, 0))
pSlow = plot(slow, "Slow MA", color = color.new(color.blue, 0), linewidth = 2)
color fillCol = state == 2 ? color.new(color.teal, 80) : state == -2 ? color.new(color.red, 80) : state != 0 ? color.new(color.gray, 85) : na
fill(pFast, pSlow, color = fillCol, title = "State fill (gray = pending, colored = confirmed)")
plotshape(bullConfirmed, "Bullish cross confirmed", style = shape.circle, location = location.belowbar, color = color.teal, size = size.tiny)
plotshape(bearConfirmed, "Bearish cross confirmed", style = shape.circle, location = location.abovebar, color = color.red,  size = size.tiny)

// ── Info table ────────────────────────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 3, border_width = 1)
if showTable and barstate.islast
    color bg = color.new(color.gray, 70)
    string stateTxt = state == 2 ? "bullish, confirmed" : state == 1 ? "bullish, pending" : state == -2 ? "bearish, confirmed" : state == -1 ? "bearish, pending" : "none"
    table.cell(info, 0, 0, "Separation", text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 0, str.tostring(sepPct, "#.##") + " % (min " + str.tostring(sepThr, "#.##") + " %)", text_color = color.white, bgcolor = bg)
    table.cell(info, 0, 1, "Extra filters", text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 1, (useVol ? "volume " : "") + (useHhHl ? "HH/HL " : "") + (not useVol and not useHhHl ? "none" : ""), text_color = color.white, bgcolor = bg)
    table.cell(info, 0, 2, "State", text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 2, stateTxt, text_color = state > 0 ? color.teal : state < 0 ? color.red : color.white, bgcolor = bg)

// ── Alerts (state changes, not trade signals) ─────────────────────────────────
alertcondition(bullPending,   "Bullish crossover (pending)",   "{{ticker}}: fast MA crossed above slow MA, separation not yet reached")
alertcondition(bullConfirmed, "Bullish crossover confirmed",   "{{ticker}}: bullish crossover confirmed (separation and filters met)")
alertcondition(bearPending,   "Bearish crossover (pending)",   "{{ticker}}: fast MA crossed below slow MA, separation not yet reached")
alertcondition(bearConfirmed, "Bearish crossover confirmed",   "{{ticker}}: bearish crossover confirmed (separation and filters met)")
````
