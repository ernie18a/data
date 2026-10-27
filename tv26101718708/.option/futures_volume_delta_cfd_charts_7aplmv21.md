# Futures Volume + Delta - CFD Charts

- url: https://www.tradingview.com/script/7aPLMv21/
- type: indicator
- pine_id: PUB;a1f77602e0e642759fac285a68939a09
- version: 1.0

## Description

A volume pane for CFD and cash-index charts that shows the REAL traded volume
of the matching futures contract — plus an estimated buy/sell delta and
absorption flags for effort-without-result bars.

What makes it original: CFD "volume" is broker tick count, not market
participation. This pane never uses it — every column is the exchange volume
of the auto-detected futures contract. The delta column is built from the
futures contract's own lower-timeframe candles (up-candle volume counts as
buying, down-candle volume as selling): the volume is real, only the side
attribution is an estimate, and it is labeled as such. Absorption flags then
combine both axes — volume percentile high while the price range percentile is
low — the candle-data footprint that hidden passive interest (iceberg-style
execution) leaves behind. Pine has no order book, so this is explicitly a
footprint proxy, not order-book detection.

How it works:
- The futures contract is auto-detected from the chart symbol (DAX/GER40 ->
  FDAX, NAS100 -> NQ, US30 -> YM, UK100 -> Z, US500 -> ES), or set manually.
- Histogram = futures volume per chart bar; columns tint with bar direction,
  a configurable MA marks the average.
- Delta = buy-minus-sell futures volume from 1/5/15-minute intrabars
  (auto-selected by chart timeframe, manual override). Lower-timeframe
  history is limited, so the delta reaches less far back than the histogram.
- Absorption flag (orange diamond + alert): volume percentile >= X and range
  percentile <= Y over a rolling lookback — both thresholds adjustable.
- A status label confirms the active source and the delta resolution.

How to use it: read it like a footprint-lite. Rising price on rising futures
volume = participation confirms the move. An absorption diamond after an
extended run — heavy contracts traded, no price progress — marks where passive
interest is absorbing the aggression; combined with a one-sided delta it is a
common exhaustion/iceberg footprint. Delayed futures feeds confirm bars a few
minutes late; the historical picture is complete.

*This script is part of a consistent set of open-source session, range and
volume tools — the companions are on my profile.*

## Source Code

````pine
//@version=6
// FUTURES VOLUME + DELTA — real futures contract volume under a CFD chart.
// The chart's broker tick volume is NEVER used (no silent fallback): every
// number in this pane is the volume of the auto-detected futures contract
// (request.security / request.security_lower_tf). Delta = buy-minus-sell
// volume approximated from the futures contract's own lower-timeframe
// candles (candle direction assigns the side — a tape-less approximation;
// the VOLUME itself is real exchange volume).
// Absorption flags mark effort-without-result bars: futures volume in the
// top percentile while the price range is in the bottom percentile —
// the candle-data footprint that hidden passive interest (iceberg-style
// execution) leaves behind. Pine has no order book, so this is a proxy,
// not order-book detection — and it is labeled accordingly.
// Sibling tools: future_volume_profile / vwap_stdev_futurevol / twap_futurevol.
indicator("Futures Volume + Delta — CFD Charts", shorttitle = "Fut Vol Delta", overlay = false)

volMode  = input.string("Futures symbol", "Volume source",
     options = ["Chart (native)", "Futures symbol"], group = "Volume",
     tooltip = "Futures = real exchange volume via request.security. Chart = this chart's own volume (only sensible on a native futures chart, where chart volume IS exchange volume).")
autoFut  = input.bool(true, "Auto-detect futures symbol", group = "Volume")
futMan   = input.symbol("EUREX:FDAX1!", "…manual otherwise", group = "Volume")

showDelta = input.bool(true, "Show volume delta (lower-TF estimate)", group = "Delta",
     tooltip = "Buy-minus-sell volume of the FUTURES contract, estimated from its lower-timeframe candles (up-candle volume = buy side). Real contract volume, approximated side. Lower-TF history is limited, so the delta column reaches less far back than the volume histogram.")
ltfMode  = input.string("Auto", "Delta resolution",
     options = ["Auto", "1 minute", "5 minutes", "15 minutes"], group = "Delta")

flagAbs  = input.bool(true, "Flag absorption bars (effort vs result)", group = "Absorption",
     tooltip = "Futures volume percentile high AND price range percentile low. High effort without price progress = passive absorption footprint (iceberg-style proxy — Pine has no order book).")
lookback = input.int(200, "Percentile lookback (bars)", minval = 50, group = "Absorption")
volPct   = input.float(85, "Volume percentile >=", minval = 50, maxval = 100, group = "Absorption")
rngPct   = input.float(30, "Range percentile <=", minval = 0, maxval = 50, group = "Absorption")

lenMA = input.int(50, "Volume MA length", minval = 1, group = "Display")

f_detectFut() =>
    s = str.lower(syminfo.ticker) + " " + str.lower(syminfo.prefix) + " " + str.lower(syminfo.description)
    isNQ  = str.contains(s, "nas") or str.contains(s, "ndx") or str.contains(s, "us100") or str.contains(s, "ustec") or str.contains(s, "tech100") or str.contains(s, "nq1") or str.contains(s, "nq!")
    isYM  = str.contains(s, "dow") or str.contains(s, "us30") or str.contains(s, "dji") or str.contains(s, "ym1") or str.contains(s, "ym!") or str.contains(s, "wall street")
    isDAX = str.contains(s, "dax") or str.contains(s, "ger40") or str.contains(s, "de40") or str.contains(s, "german")
    isFTSE = str.contains(s, "ftse") or str.contains(s, "uk100") or str.contains(s, "ukx")
    isES  = str.contains(s, "us500") or str.contains(s, "sp500") or str.contains(s, "spx") or str.contains(s, "s&p") or str.contains(s, "es1") or str.contains(s, "es!")
    isDAX ? "EUREX:FDAX1!" : isFTSE ? "ICEEUR:Z1!" : isNQ ? "CME_MINI:NQ1!" :
     isYM ? "CBOT_MINI:YM1!" : isES ? "CME_MINI:ES1!" : syminfo.tickerid

futSym = autoFut ? f_detectFut() : futMan
useFut = volMode == "Futures symbol"

// --- real futures volume per chart bar ---
futVol = request.security(futSym, timeframe.period, volume, ignore_invalid_symbol = true)
vol    = useFut ? futVol : volume

// --- delta from the futures contract's lower-timeframe candles ---
autoLtf = timeframe.isintraday and timeframe.multiplier <= 5 ? "1" :
     timeframe.isintraday and timeframe.multiplier <= 60 ? "5" : "15"
ltf = ltfMode == "1 minute" ? "1" : ltfMode == "5 minutes" ? "5" :
     ltfMode == "15 minutes" ? "15" : autoLtf
[ltfO, ltfC, ltfV] = request.security_lower_tf(useFut ? futSym : syminfo.tickerid,
     ltf, [open, close, volume], ignore_invalid_symbol = true)

float delta = na
if showDelta and not na(ltfV) and ltfV.size() > 0
    d = 0.0
    for i = 0 to ltfV.size() - 1
        v_i = nz(ltfV.get(i))
        d += nz(ltfC.get(i)) >= nz(ltfO.get(i)) ? v_i : -v_i
    delta := d

// --- absorption: effort (futures volume) vs result (price range of THIS chart) ---
rng = high - low
volRank = ta.percentrank(nz(vol), lookback)
rngRank = ta.percentrank(rng, lookback)
absorb = flagAbs and nz(vol) > 0 and volRank >= volPct and rngRank <= rngPct

// --- plots ---
volMA = ta.sma(nz(vol), lenMA)
colVol = absorb ? color.new(color.orange, 0) :
     close >= open ? color.new(color.teal, 55) : color.new(color.red, 55)
plot(nz(vol), "Futures volume", style = plot.style_columns, color = colVol)
plot(volMA, "Volume MA", color = color.new(color.gray, 30))
plot(showDelta ? delta : na, "Volume delta (est.)", style = plot.style_columns,
     color = delta >= 0 ? color.new(color.teal, 0) : color.new(color.red, 0))
plotshape(absorb ? nz(vol) : na, "Absorption", style = shape.diamond,
     location = location.absolute, color = color.orange, size = size.tiny)
hline(0, "Zero", color = color.new(color.gray, 70))

alertcondition(absorb, "Absorption bar",
     "High futures volume with small range (absorption footprint)")

// --- status label ---
if barstate.islast
    txt = (useFut ? "Futures volume: " + futSym + (na(futVol) ? " (NO DATA)" : " ✓")
                  : "Chart volume (native)")
         + (showDelta ? "\nDelta: " + ltf + "-min candles of the future (side estimated, volume real)"
              + (na(delta) ? " — no lower-TF data here" : "") : "")
         + "\nDelayed feeds confirm bars late; history is complete."
    label.new(bar_index, nz(vol), txt, style = label.style_label_left,
         color = color.new(color.black, 20), textcolor = color.white, size = size.small)
````
