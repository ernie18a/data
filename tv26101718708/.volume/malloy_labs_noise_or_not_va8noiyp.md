# Malloy Labs: Noise Or Not

- url: https://www.tradingview.com/script/vA8NoIYp-Malloy-Labs-Noise-Or-Not/
- type: indicator
- pine_id: PUB;f7aa272e7ccf4159b25088a60f6deb62
- version: 1.0

## Description

Higher timeframe REAL signal overrides lower timeframe setups. When timeframes conflict, the trade is flat until they align.


States:

REAL — edge > threshold. Flow outrunning price, crowd not loaded.
TRAP — edge < −threshold. Price moved without flow, crowd positioned.
NOISE — neither. No read.

Inputs:

Lookback — window for raw z-score calculation (default 50)
Normalization — window for normalizing z-scores (default 100)
State threshold — how many standard deviations to trigger a state (default 2.0)
Crowd layer — off by default. Paste a funding or premium ticker to activate.

## Source Code

````pine

//@version=6
indicator("Malloy Labs: Flow vs Crowd", "Noise or Not", overlay=false, precision=2)

// ── inputs ────────────────────────────────────────────────────────────
lookback  = input.int  (50,  "Lookback",        minval=5,  group="Settings")
normLen   = input.int  (100, "Normalization",   minval=20, group="Settings")
threshold = input.float(2.0, "State threshold", minval=0.5, step=0.5, group="Settings")

useCrowd  = input.bool (false, "Layer in crowd positioning", group="Crowd")
crowdSym  = input.symbol("",   "Funding or premium ticker",  group="Crowd",
     tooltip="Leave blank for flow-only. Otherwise paste a funding rate or perp-premium symbol.")

cReal = input.color(#AFA9EC, "Real", group="Display")
cTrap = input.color(#5F5C78, "Trap", group="Display")
cMid  = input.color(#3C3489, "Zero", group="Display")

// ── helper ────────────────────────────────────────────────────────────
zscore(src, look, norm) =>
    raw = src - ta.sma(src, look)
    (raw - ta.sma(raw, norm)) / math.max(ta.stdev(raw, norm), 1e-10)

// ── flow ──────────────────────────────────────────────────────────────
delta  = close >= open ? volume : -volume
cvd    = ta.cum(delta)
flowZ  = zscore(cvd,   lookback, normLen)
priceZ = zscore(close, lookback, normLen)
divZ   = flowZ - priceZ

// ── crowd (optional) ──────────────────────────────────────────────────
symToUse = crowdSym != "" ? crowdSym : syminfo.tickerid
fund     = request.security(symToUse, timeframe.period, close, ignore_invalid_symbol=true)
fundZ    = zscore(fund, lookback, normLen)
crowdZ   = useCrowd and crowdSym != "" and not na(fund) ? fundZ : 0.0

// ── edge ──────────────────────────────────────────────────────────────
edge = divZ - crowdZ

// ── plot ──────────────────────────────────────────────────────────────
plot(edge, "Edge", style=plot.style_columns, color=edge > 0 ? cReal : cTrap, linewidth=2)
hline(0,          "zero", color=cMid,                 linestyle=hline.style_solid)
hline( threshold, "hot",  color=color.new(cReal, 70), linestyle=hline.style_dashed)
hline(-threshold, "cold", color=color.new(cTrap, 70), linestyle=hline.style_dashed)
bgcolor(edge > threshold ? color.new(cReal, 92) : edge < -threshold ? color.new(cTrap, 92) : na)

// ── state ─────────────────────────────────────────────────────────────
state = edge > threshold ? "REAL" : edge < -threshold ? "TRAP" : "NOISE"
sCol  = edge > threshold ? cReal  : edge < -threshold ? cTrap  : color.new(cMid, 20)

var table tag = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(tag, 0, 0, " " + state + " ", text_color=sCol, text_size=size.normal)

// ── alerts ────────────────────────────────────────────────────────────
alertcondition(ta.crossover (edge,  threshold), "Real flow", "FxC entered REAL zone")
alertcondition(ta.crossunder(edge, -threshold), "Trap flow", "FxC entered TRAP zone")
````
