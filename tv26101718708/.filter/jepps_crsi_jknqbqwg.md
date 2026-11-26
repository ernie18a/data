# Jepps cRSI

- url: https://www.tradingview.com/script/JknqBQWG-Jepps-cRSI/
- type: indicator
- pine_id: PUB;90219493b5564db489eb3708cdc055f3
- version: 3.0

## Description

Takes the cRSI indicator made by Lars von Thienen and adds divergence indicator and the ability to paint the background when the cRSI exceeds the upper and lower bands for easy identification

## Source Code

````pine
//@version=6
//
// Original Copyright (C) 2017 CC BY, whentotrade / Lars von Thienen
// Source:
//   Book: Decoding The Hidden Market Rhythm - Part 1: Dynamic Cycles (2017)
//   Chapter 4: Fine-tuning technical indicators - cRSI Indicator
//
// License: Creative Commons Attribution 4.0 International License (CC BY 4.0)
//
// This is a drop-in alternate of jepps_crsi.pine with the inner math swapped
// for Pine built-ins. Feature surface (MTF, wait-for-close, band-excess
// toggle) is identical. Differences vs. jepps_crsi.pine:
//
//   * crsi recursion        -> ta.ema(2*rsi - rsi[phasingLag], vibration)
//     Same EMA alpha as the manual recursion; identical past warmup.
//   * dynamic LowBand (db)  -> ta.percentile_nearest_rank(crsi, cyclicmemory, leveling) + halfstep
//   * dynamic HighBand (ub) -> ta.percentile_nearest_rank(crsi, cyclicmemory, 100 - leveling) - halfstep
//     where halfstep = (ta.highest(crsi,N) - ta.lowest(crsi,N)) / 200.
//     The half-step bias mimics the average outward bias of the original
//     100-bucket walk (which lands in (x[k], x[k]+mstep] for LB and
//     (x[k]-mstep, x[k]] for HB, mstep = (lmax-lmin)/100). Without the
//     bias the bands sit at the *inner* edge of the walk's landing zone
//     and breach less often than the standard; with it, disagreement
//     breaches drop ~10x relative to the standard cRSI on SPY 1m.
//   * Percentile-Walk Resolution input removed (no longer applicable).
//
// Intended for side-by-side comparison against jepps_crsi.pine so the
// numeric drift can be eyeballed.
//
indicator(title="Jepps cRSI Optimized", shorttitle="Jepps cRSI Opt", max_bars_back=500)

// ============================================================================
// Inputs
// ============================================================================
tf                = input.timeframe("",      title="Timeframe (blank = chart)")
waitForClose      = input.bool(false,        title="Wait for candle to close", tooltip="OFF (default): the indicator recomputes live as the selected-TF candle develops. ON: only updates once the selected-TF candle closes (no repaint).")
domcycle          = input.int(20, minval=10, title="Dominant Cycle Length")
bandExcessEnabled = input.bool(true,         title="Band Excess Signal", tooltip="Tint the pane background when CRSI moves above the HighBand or below the LowBand. Background color is configurable in the Style tab.")

// --- MA Line (moving average of CRSI, like the built-in RSI's MA) ---
grpMA   = "MA Line"
showMA    = input.bool(false, "Show MA Line", group=grpMA)
maType    = input.string("SMA", "Type",   options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"], group=grpMA)
maLen     = input.int(14, "Length", minval=1, group=grpMA)
showCross = input.bool(true, "Show MA Cross Dots", group=grpMA, tooltip="Plot a dot on the MA line where CRSI crosses it — green on a cross up, red on a cross down. Independent of the Show MA Line toggle; dot colors are editable in the Style tab.")

// --- Middle line of the dynamic bands (midpoint of HighBand and LowBand) ---
grpMid  = "Bands Middle Line"
showMid = input.bool(false, "Show Middle Line", group=grpMid)

// ============================================================================
// MA helper (matches the built-in RSI's "MA" dropdown options)
// ============================================================================
f_ma(source, length, type) =>
    switch type
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)
        => na

// ============================================================================
// Reference hlines
// ============================================================================
h1 = hline(30, color=color.silver, linestyle=hline.style_dashed)
h2 = hline(70, color=color.silver, linestyle=hline.style_dashed)
h3 = hline(50, color=color.yellow, linestyle=hline.style_dashed)

// ============================================================================
// Calculation (wrapped so it can run on the selected timeframe)
//   Returns BOTH live and previous-bar values in a single tuple, so we only
//   need one request.security call regardless of the Wait-for-close toggle.
// ============================================================================
calcAll() =>
    src            = close
    int vibration  = 10
    float leveling = 10.0
    cyclelen       = domcycle / 2
    cyclicmemory   = domcycle * 2
    int phasingLag = (vibration - 1) / 2

    up   = ta.rma(math.max(ta.change(src),  0), cyclelen)
    down = ta.rma(-math.min(ta.change(src), 0), cyclelen)
    rsi  = down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down)

    crsi = ta.ema(2 * rsi - rsi[phasingLag], vibration)

    // Half-step bias to approximate the standard bucket-walk's outward landing bias.
    // (See header for full explanation.)
    hi       = ta.highest(nz(crsi), cyclicmemory)
    lo       = ta.lowest(nz(crsi), cyclicmemory)
    halfstep = (hi - lo) / 200

    db = ta.percentile_nearest_rank(nz(crsi), cyclicmemory, leveling)       + halfstep
    ub = ta.percentile_nearest_rank(nz(crsi), cyclicmemory, 100 - leveling) - halfstep

    mid    = (ub + db) / 2
    ma_val = f_ma(crsi, maLen, maType)

    // Return live AND previous-HTF-bar values from a single call.
    // [1]-suffixed values are evaluated in HTF context, so they are the last
    // *closed* HTF bar's values — non-repainting.
    [crsi, db, ub, mid, ma_val,
     crsi[1], db[1], ub[1], mid[1], ma_val[1]]

// ----------------------------------------------------------------------------
// Resolve timeframe and run a single security call for both live + lagged.
// ----------------------------------------------------------------------------
res_tf = tf == "" ? timeframe.period : tf

[crsi_l, db_l, ub_l, mid_l, ma_l,
 crsi_c, db_c, ub_c, mid_c, ma_c] = request.security(syminfo.tickerid, res_tf, calcAll())

crsi = waitForClose ? crsi_c : crsi_l
db   = waitForClose ? db_c   : db_l
ub   = waitForClose ? ub_c   : ub_l
mid  = waitForClose ? mid_c  : mid_l
ma   = waitForClose ? ma_c   : ma_l

// ============================================================================
// Plots
// ============================================================================
lowband  = plot(db,   "LowBand",  color.aqua)
highband = plot(ub,   "HighBand", color.aqua)
plot(showMid ? mid : na, "Bands Middle", color.new(color.aqua, 30))
fill(h1,      h2,       color=color.new(color.silver, 90))
fill(lowband, highband, color=color.new(color.gray,   90))
plot(crsi, "CRSI", color.fuchsia)
plot(showMA  ? ma  : na, "CRSI MA", color.yellow)

// --- CRSI / MA cross dots (green = CRSI crosses above MA, red = below) ---
crossUp = ta.crossover(crsi, ma)
crossDn = ta.crossunder(crsi, ma)
plot(showCross and crossUp ? ma : na, "MA Cross Up",   style=plot.style_circles, linewidth=4, color=color.lime)
plot(showCross and crossDn ? ma : na, "MA Cross Down", style=plot.style_circles, linewidth=4, color=color.red)

// ============================================================================
// Band Excess Signal
// ============================================================================
highBandExcess = bandExcessEnabled and crsi > ub
lowBandExcess  = bandExcessEnabled and crsi < db
bgcolor(highBandExcess ? color.new(color.green,  70) : na, title="Band Excess - High")
bgcolor(lowBandExcess  ? color.new(color.yellow, 70) : na, title="Band Excess - Low")
````
