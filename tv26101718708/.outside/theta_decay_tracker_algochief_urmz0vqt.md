# Theta Decay Tracker [AlgoChief]

- url: https://www.tradingview.com/script/urMz0VQT-Theta-Decay-Tracker-AlgoChief/
- type: indicator
- pine_id: PUB;c29c3cbb4e6a464cbf1df357f4e25ad3
- version: 1.0

## Description

Theta Decay Tracker [AlgoChief]

What This Indicator Does

When you're holding an option and the underlying index moves, the option's premium doesn't always move the way you'd expect. Part of the gap is Delta (how much the option should move per point of index movement), and part of it is Theta (time decay) eating into your premium — even when the index hasn't reversed.

This indicator separates those two effects on every candle, so you can see exactly how many points you lost purely to time decay, independent of index direction.

How It Works (Logic)


Fetches the underlying index price (NIFTY, BANKNIFTY, FINNIFTY, MIDCPNIFTY, SENSEX, or any custom symbol) alongside your option chart, using request.security on the same timeframe (no repainting, no lookahead).
Solves Implied Volatility live from the option's own closing price using a Newton-Raphson iteration on the Black-Scholes formula — no need to manually check the option chain for IV.
Calculates real-time Delta and Theta using the standard Black-Scholes model (Strike, Time-to-Expiry, IV, Risk-Free Rate).
Compares actual vs expected move, every candle:

Expected Option Move = Delta × Index Move
Decay = Actual Option Move − Expected Move


If Decay is negative while the index barely moved, that gap is mostly time decay (plus minor vega/gamma effects).
Tracks cumulative decay over a configurable lookback window (e.g., last 15 candles) and fires an alert when decay crosses your threshold while the index stays flat/no reversal — this is the clearest signal of pure theta bleed.


How to Use It


Add the indicator to your option's chart (not the index chart).
In settings, pick your Index Preset (NIFTY/BANKNIFTY/FINNIFTY/MIDCPNIFTY/SENSEX) or choose Custom and enter your own symbol.
Enter the Strike Price, Option Type (CE/PE), and Expiry Date & Time.
Leave "Auto-solve IV" ON (recommended) — it reads IV directly from the option's live price.
Adjust the Decay Alert settings:

Lookback (bars) — the time window to check
Decay Threshold — how many points of unexplained loss triggers an alert
Flat Threshold — how much index movement still counts as "no reversal"



Set a TradingView alert on "Theta Decay Threshold Hit" to get notified in real time.


What It Helps With


Knowing whether your option is losing value because the index moved against you, or purely because of time decay — critical for deciding whether to hold, exit, or roll a position.
Spotting theta acceleration near expiry, especially during range-bound/sideways sessions.
Avoiding the common mistake of blaming "index isn't moving enough" when the real issue is decay eating the premium regardless.
Works on any NSE/BSE index option (or global index options via Custom symbol).


Panel Elements


Green/Red columns: Decay per candle (green = option outperformed delta expectation, red = decayed more than expected)
Orange line: Theoretical Black-Scholes theta/day, for reference
Purple line: Cumulative decay over your lookback window
Red background zone: Marks bars where the decay alert condition is active
Table (top-right): Live IV, Delta, Theta/day, Index move, Expected move, Decay, and Cumulative decay


Important Notes / Disclaimer


This is a Black-Scholes approximation, not a live options-chain feed. The "Decay" value bundles theta with minor vega/gamma effects — it is not a pure isolated theta number.
IV is solved from the option's own price using Newton-Raphson; in illiquid/wide-spread strikes, solved IV can be noisy on individual ticks — use candle-close values for reliability.
This tool is for educational and analytical purposes only. It does not predict future price movement and is not financial advice. Always do your own due diligence before making trading decisions.
Works best on liquid strikes (near or at-the-money) where bid-ask spreads are tight and Black-Scholes assumptions hold reasonably well.

## Source Code

````pine
//@version=6
indicator("Theta Decay Tracker [AlgoChief]", overlay=false, precision=2)

// ============ INPUTS ============
grp1 = "Underlying / Option Setup"
indexPreset   = input.string("NIFTY", "Index Preset", options=["NIFTY","BANKNIFTY","FINNIFTY","MIDCPNIFTY","SENSEX","Custom"], group=grp1)
customSym     = input.symbol("NSE:NIFTY", "Custom Symbol (only used if preset = Custom)", group=grp1)
strike        = input.float(24500, "Strike Price", step=50, group=grp1)
optType       = input.string("CE", "Option Type", options=["CE","PE"], group=grp1)
expiryTime    = input.time(timestamp("2026-07-28T15:30:00+05:30"), "Expiry Date & Time (15:30 IST)", group=grp1)

underlyingSym = switch indexPreset
    "NIFTY"      => "NSE:NIFTY"
    "BANKNIFTY"  => "NSE:BANKNIFTY"
    "FINNIFTY"   => "NSE:FINNIFTY"
    "MIDCPNIFTY" => "NSE:MIDCPNIFTY"
    "SENSEX"     => "BSE:SENSEX"
    => customSym

grp2 = "Black-Scholes Assumptions"
useLiveIV = input.bool(true, "Auto-solve IV from option's own price (recommended)", group=grp2)
ivInput   = input.float(15.0, "Manual IV (%) - used only if auto-solve is OFF", step=0.5, group=grp2) / 100
rateInput = input.float(6.5, "Risk-Free Rate (%)", step=0.25, group=grp2) / 100

grp3 = "Display"
showTable = input.bool(true, "Show Live Greeks Table", group=grp3)

grp4 = "Decay Alert"
lookbackBars   = input.int(15, "Lookback (bars) - e.g. 15 bars on 1min = 15min window", minval=1, group=grp4)
decayThreshold = input.float(5.0, "Alert if cumulative decay exceeds (pts)", step=0.5, group=grp4)
flatThreshold  = input.float(10.0, "Treat index as 'no reversal' if abs move <= (pts)", step=1, group=grp4)

// ============ FETCH INDEX PRICE ============
indexClose = request.security(underlyingSym, timeframe.period, close)
indexOpen  = request.security(underlyingSym, timeframe.period, open)

// ============ TIME TO EXPIRY (years) ============
T = math.max((expiryTime - time) / (1000.0 * 60 * 60 * 24 * 365.0), 0.0002) // floor to avoid div/0 near expiry

// ============ NORMAL CDF (Abramowitz-Stegun approx) ============
f_ncdf(x) =>
    L = math.abs(x)
    k = 1 / (1 + 0.2316419 * L)
    w = 1 - (1 / math.sqrt(2 * math.pi)) * math.exp(-L * L / 2) *
         (0.319381530*k - 0.356563782*k*k + 1.781477937*math.pow(k,3) -
          1.821255978*math.pow(k,4) + 1.330274429*math.pow(k,5))
    x >= 0 ? w : 1 - w

f_npdf(x) =>
    (1 / math.sqrt(2 * math.pi)) * math.exp(-x * x / 2)

// ============ BLACK-SCHOLES PRICE (for IV solver) ============
f_bsPrice(S, K, T, r, sigma, isCall) =>
    d1 = (math.log(S / K) + (r + (sigma * sigma) / 2) * T) / (sigma * math.sqrt(T))
    d2 = d1 - sigma * math.sqrt(T)
    isCall ? S * f_ncdf(d1) - K * math.exp(-r * T) * f_ncdf(d2) : K * math.exp(-r * T) * f_ncdf(-d2) - S * f_ncdf(-d1)

f_vega(S, K, T, r, sigma) =>
    d1 = (math.log(S / K) + (r + (sigma * sigma) / 2) * T) / (sigma * math.sqrt(T))
    S * f_npdf(d1) * math.sqrt(T)

// ============ IMPLIED VOL SOLVER (Newton-Raphson, fallback bisection safe) ============
f_impliedVol(S, K, T, r, marketPrice, isCall) =>
    float sigma = 0.20
    for i = 0 to 39
        price = f_bsPrice(S, K, T, r, sigma, isCall)
        vegaVal = f_vega(S, K, T, r, sigma)
        diff = price - marketPrice
        sigma := vegaVal > 1e-6 ? math.max(math.min(sigma - diff / vegaVal, 3.0), 0.01) : sigma
    sigma

// ============ BLACK-SCHOLES D1 / D2 ============
S = indexClose
K = strike
r = rateInput
solvedIV = f_impliedVol(S, K, T, rateInput, close, optType == "CE")
iv = useLiveIV ? solvedIV : ivInput

d1 = (math.log(S / K) + (r + (iv * iv) / 2) * T) / (iv * math.sqrt(T))
d2 = d1 - iv * math.sqrt(T)

Nd1  = f_ncdf(d1)
Nd2  = f_ncdf(d2)
Nnd1 = f_ncdf(-d1)
Nnd2 = f_ncdf(-d2)
nd1  = f_npdf(d1)

delta = optType == "CE" ? Nd1 : (Nd1 - 1)

thetaPerDay = optType == "CE" ?
     (-(S * nd1 * iv) / (2 * math.sqrt(T)) - r * K * math.exp(-r * T) * Nd2) / 365 :
     (-(S * nd1 * iv) / (2 * math.sqrt(T)) + r * K * math.exp(-r * T) * Nnd2) / 365

// ============ CANDLE-WISE MOVE COMPARISON ============
indexMove   = indexClose - indexClose[1]
optionMove  = close - close[1]
expectedMove = delta * indexMove
decay = optionMove - expectedMove   // unexplained gap = theta + vega/other greeks combined

// ============ CUMULATIVE DECAY OVER LOOKBACK WINDOW ============
cumDecay     = math.sum(decay, lookbackBars)
indexCumMove = indexClose - indexClose[lookbackBars]

decayAlertCond = (cumDecay <= -decayThreshold) and (math.abs(indexCumMove) <= flatThreshold)

if decayAlertCond
    alert("AlgoChief Theta Alert: " + str.tostring(math.abs(cumDecay), "#.##") + " pts pure decay in last " +
         str.tostring(lookbackBars) + " bars while index moved only " + str.tostring(indexCumMove, "#.##") +
         " pts (Strike " + str.tostring(strike) + optType + ")", alert.freq_once_per_bar)

alertcondition(decayAlertCond, title="Theta Decay Threshold Hit",
     message="AlgoChief: Cumulative theta decay crossed threshold with flat index - check option premium bleed")

// ============ PLOTS ============
barColor = decay >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)
plot(decay, title="Decay / Unexplained Move (pts)", style=plot.style_columns, color=barColor)
hline(0, color=color.gray)
plot(thetaPerDay, title="Theoretical Theta (pts/day)", color=color.orange, linewidth=2)
plot(cumDecay, title="Cumulative Decay (lookback window)", color=color.new(color.purple, 0), linewidth=1)

bgcolor(decayAlertCond ? color.new(color.red, 75) : na, title="Decay Alert Zone")

// ============ TABLE ============
if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_width=1)
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 0, 1, useLiveIV ? "IV (auto-solved)" : "IV (manual)", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(iv * 100, "#.##") + "%", text_color=color.yellow)
    table.cell(t, 0, 2, "Delta", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(delta, "#.###"), text_color=color.white)
    table.cell(t, 0, 3, "Theta/day (pts)", text_color=color.white)
    table.cell(t, 1, 3, str.tostring(thetaPerDay, "#.##"), text_color=color.white)
    table.cell(t, 0, 4, "Index Move (candle)", text_color=color.white)
    table.cell(t, 1, 4, str.tostring(indexMove, "#.##"), text_color=color.white)
    table.cell(t, 0, 5, "Expected Opt Move", text_color=color.white)
    table.cell(t, 1, 5, str.tostring(expectedMove, "#.##"), text_color=color.white)
    table.cell(t, 0, 6, "Decay (this candle)", text_color = decay>=0 ? color.lime : color.red)
    table.cell(t, 1, 6, str.tostring(decay, "#.##"), text_color = decay>=0 ? color.lime : color.red)
    table.cell(t, 0, 7, "Cum. Decay (" + str.tostring(lookbackBars) + " bars)", text_color = cumDecay>=0 ? color.lime : color.red)
    table.cell(t, 1, 7, str.tostring(cumDecay, "#.##"), text_color = cumDecay>=0 ? color.lime : color.red)
````
