# EMA 30/50/100 Long Entries + MTF Trend

- url: https://www.tradingview.com/script/KmCk2x1s-EMA-30-50-100-Long-Entries-MTF-Trend/
- type: indicator
- pine_id: PUB;7b81a95c210448a28a9343127678fc22
- version: 1.0

## Description

# EMA 30/50/100 Long Entries + MTF Trend

A long-only trend-following indicator that combines a 30/50/100 EMA stack with two entry triggers (breakout and retest) and an optional higher-timeframe trend filter. It was designed with Indian equities (NSE/BSE) in mind, but it works on any symbol and timeframe.

## How it works

### 1. Setup (yellow diamond)
A setup forms on the bar where all of these become true:
- The 30 EMA is above the 50 EMA
- The 30 EMA is above the 100 EMA
- The 50 EMA is above the 100 EMA

The setup stays active until the EMA stack loses alignment. While it is active, the background is shaded green if the trend filters pass.

### 2. Entry A: Breakout (green "BO" label)
While a setup is active, a Breakout fires when the close is above the highest high of the previous N bars (default 10).

### 3. Entry B: Retest (blue "RT" label)
While a setup is active:
- A candle dips to or below any of the three EMAs but closes back above it.
- The next candle closes above that candle's high, which confirms the bounce.

Each entry type fires only once per setup, so you do not get repeated signals in the same trend. The flags reset when a new setup forms.

## Trend filters

### Higher timeframe filter (on by default)
The higher timeframe is bullish when its last completed close is above its 30 EMA and its 30 EMA is above its 50 EMA. The higher timeframe is chosen automatically:

| Chart timeframe | Higher timeframe |
|---|---|
| 1 minute or lower | 5 minutes |
| 5 minutes | 15 minutes |
| 15 minutes | 1 hour |
| 1 hour to 4 hours | Daily |
| Daily | Weekly |
| Weekly and above | Monthly |

You can override this in the settings. The filter reads the last completed higher-timeframe bar, so it does not repaint. On a Daily chart, the weekly reading can lag by up to one week.

### Current timeframe filter (off by default)
Requires price to be above a rising 100 EMA. The EMA alignment already implies most of this, so it is optional.

### New listings
If a symbol does not have enough higher-timeframe history (about 50 bars), the higher-timeframe filter passes by default so recent IPOs are not blocked. You can turn this off in the settings.

## Inputs

| Input | Default | Description |
|---|---|---|
| Breakout lookback (bars) | 10 | Number of previous bars used to find the prior high |
| Use higher timeframe filter | On | Requires a bullish higher timeframe for entries |
| Use current timeframe filter | Off | Requires price above a rising 100 EMA |
| Pass HTF filter if not enough history | On | Lets new listings through |
| Slope lookback | 5 | Bars used to measure the 100 EMA slope (current timeframe filter) |
| Higher timeframe | Auto | Auto, 5, 15, 60, D, W or M |

## Visuals
- **EMAs:** 30 (aqua), 50 (orange), 100 (red)
- **Yellow diamond:** Setup formed
- **BO / RT labels:** Breakout and Retest entries
- **Green background:** Setup active and trend filters passing
- **Status table (top right):** Current timeframe state, higher-timeframe state, and whether entries are enabled or blocked

## Alerts
Four alert conditions are available:
- Setup Happened
- Setup Happened + Trend OK
- Long Entry - Breakout
- Long Entry - Retest

Alert messages include the symbol and timeframe. For best results, set the alert trigger to "Once Per Bar Close" so signals are confirmed.

## Screening
Three plots are available in the Data Window for use as columns or filters in the Pine Screener (1 = true, 0 = false):
- Setup
- Setup + Trend OK
- Setup Active

## Suggested use
- **Swing trading:** Daily chart (Weekly filter)
- **Intraday:** 15-minute chart (1-hour filter)

## Notes and limitations
- Long entries only. There are no exit rules, stop losses or targets. Manage risk with your own plan.
- The higher-timeframe filter intentionally uses completed bars to avoid repainting, which adds some delay.
- The strategy is EMA-based and lags price. It performs best in trending markets and can produce false signals in sideways markets.
- Results depend on the symbol, timeframe and period. Test it on your own instruments before using it.

## Disclaimer
This indicator is for educational and informational purposes only and is not financial advice. Trading involves risk, and past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("EMA 30/50/100 Long Entries + MTF Trend", overlay=true)

// ── Inputs ──
lookback   = input.int(10, "Breakout lookback (bars)", minval=1)
useHtf     = input.bool(true,  "Use higher timeframe filter", group="Trend filters")
useCur     = input.bool(false, "Use current timeframe filter (price above rising 100 EMA)", group="Trend filters")
allowNoHist = input.bool(true, "Pass HTF filter if not enough history (new listings)", group="Trend filters")
slopeLen   = input.int(5, "Slope lookback for current TF filter", minval=1, group="Trend filters")
htfInput   = input.string("Auto", "Higher timeframe", options=["Auto", "5", "15", "60", "D", "W", "M"], group="Trend filters")

// ── Auto higher timeframe (tuned for Indian equities) ──
// 15m -> 1h | 1h -> Daily | Daily -> Weekly | Weekly -> Monthly
sec = timeframe.in_seconds()
autoHtf = sec <= 60 ? "5" : sec <= 300 ? "15" : sec <= 900 ? "60" : sec <= 14400 ? "D" : sec <= 86400 ? "W" : "M"
htf = htfInput == "Auto" ? autoHtf : htfInput

// ── EMAs ──
e30  = ta.ema(close, 30)
e50  = ta.ema(close, 50)
e100 = ta.ema(close, 100)

plot(e30,  "EMA 30",  color=color.aqua,   linewidth=2)
plot(e50,  "EMA 50",  color=color.orange, linewidth=2)
plot(e100, "EMA 100", color=color.red,    linewidth=2)

// ── Current timeframe filter (optional): price above a rising 100 EMA ──
trendCur = close > e100 and e100 > e100[slopeLen]

// ── Higher timeframe filter (fast): close > HTF 30 EMA and HTF 30 EMA > HTF 50 EMA ──
// Uses the last COMPLETED higher timeframe bar, so it never repaints
[hClose, hE30, hE50] = request.security(syminfo.tickerid, htf,
     [close[1], ta.ema(close, 30)[1], ta.ema(close, 50)[1]],
     lookahead=barmerge.lookahead_on)
hasHtf   = not na(hE50)
trendHtf = hasHtf ? (hClose > hE30 and hE30 > hE50) : allowNoHist

trendOK = (not useHtf or trendHtf) and (not useCur or trendCur)

// ── Condition 1: 30 above both 50 & 100, with 50 above 100 ──
aligned      = e30 > e50 and e50 > e100
setupTrigger = aligned and not aligned[1]

var bool setupActive  = false
var bool breakoutDone = false
var bool retestDone   = false

if setupTrigger
    setupActive  := true
    breakoutDone := false
    retestDone   := false
if not aligned
    setupActive := false

// ── Entry 2a: breakout of previous high ──
prevHigh = ta.highest(high, lookback)[1]
breakoutEntry = trendOK and setupActive and not setupTrigger and not breakoutDone and close > prevHigh

// ── Entry 2b: retest of any EMA, then break higher ──
touchedEma  = (low <= e30 and close > e30) or (low <= e50 and close > e50) or (low <= e100 and close > e100)
retestBar   = setupActive and touchedEma
retestEntry = trendOK and retestBar[1] and not setupTrigger[1] and setupActive and not retestDone and close > high[1]

if breakoutEntry
    breakoutDone := true
if retestEntry
    retestDone := true

// ── Setup booleans (for alerts / screening) ──
setupAny       = setupTrigger
setupWithTrend = setupTrigger and trendOK

// ── Visuals ──
bgcolor(setupActive and trendOK ? color.new(color.green, 92) : na)
plotshape(setupTrigger,  "Setup",    shape.diamond, location.belowbar, color.yellow, size=size.tiny)
plotshape(breakoutEntry, "Breakout", shape.labelup, location.belowbar, color.green, text="BO", textcolor=color.white, size=size.small)
plotshape(retestEntry,   "Retest",   shape.labelup, location.belowbar, color.blue,  text="RT", textcolor=color.white, size=size.small)

// ── Hidden plots (1 = true, 0 = false) for Pine Screener / Data Window ──
plot(setupAny ? 1 : 0,       "Setup (1/0)",            display=display.data_window)
plot(setupWithTrend ? 1 : 0, "Setup + Trend OK (1/0)", display=display.data_window)
plot(setupActive ? 1 : 0,    "Setup Active (1/0)",     display=display.data_window)

// ── Trend status table ──
var table t = table.new(position.top_right, 2, 3, border_width=1)
if barstate.islast
    table.cell(t, 0, 0, "Current TF", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 0, not useCur ? "Off" : trendCur ? "Bullish" : "Not bullish", text_color=color.white, bgcolor=not useCur ? color.gray : trendCur ? color.green : color.red)
    table.cell(t, 0, 1, "HTF (" + htf + ")", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 1, not useHtf ? "Off" : not hasHtf ? "No history" : trendHtf ? "Bullish" : "Not bullish", text_color=color.white, bgcolor=not useHtf ? color.gray : trendHtf ? color.green : color.red)
    table.cell(t, 0, 2, "Entries", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 2, trendOK ? "Enabled" : "Blocked", text_color=color.white, bgcolor=trendOK ? color.green : color.red)

// ── Alerts ──
alertcondition(setupAny,       "Setup Happened",            "{{ticker}}: EMA Setup formed ({{interval}})")
alertcondition(setupWithTrend, "Setup Happened + Trend OK", "{{ticker}}: EMA Setup formed with bullish higher timeframe ({{interval}})")
alertcondition(breakoutEntry,  "Long Entry - Breakout",     "{{ticker}}: Breakout entry ({{interval}})")
alertcondition(retestEntry,    "Long Entry - Retest",       "{{ticker}}: Retest entry ({{interval}})")
````
