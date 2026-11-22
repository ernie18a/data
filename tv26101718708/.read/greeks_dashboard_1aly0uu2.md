# Greeks Dashboard

- url: https://www.tradingview.com/script/1aLY0uU2-Greeks-Dashboard/
- type: indicator
- pine_id: PUB;d9a350c2374e4043bdd2dd36dec28a55
- version: 1.0

## Description

Monitor your option position in real time directly on the price chart. Enter your strike, expiry, and implied volatility — the indicator calculates all five Greeks, the theoretical price, break-even, and a ±1σ P&L estimate that updates bar by bar as the underlying moves.

How to use

Add the indicator to any chart of the underlying asset (stock, index, futures, forex)
Set your option parameters in the settings:
Type — Call or Put
Strike (K) — your option's strike price
Days to Expiry — calendar days remaining until expiration
Implied Vol (%) — the IV of your option (check your broker or options chain)
Risk-Free Rate (%) — use current short-term rate (e.g. 5.25% for US options)
Optionally enter the Market Price to compare against the BS theoretical value
Read the dashboard table (top-right) — it updates on every bar
What each row means

Spot — current underlying price and % distance from the strike (moneyness)

BS Price — theoretical fair value calculated by Black-Scholes. If your broker quotes a higher price, the option is rich (overpriced). Lower = cheap.

Δ Delta — how much the option's value changes for every 1-point move in the underlying. A Call with Delta 0.50 gains $0.50 per contract for every $1 the stock rises. Ranges 0 → 1 for calls, -1 → 0 for puts. Also interpreted as the approximate probability the option expires ITM.

Γ Gamma — rate of change of Delta per 1-point move. High gamma means Delta is shifting fast — useful near expiry or near the strike. Gamma is highest ATM and explodes as DTE approaches zero (gamma risk).

Θ Theta — daily time decay. A Theta of -2.50 means you lose $2.50 per contract per day just from time passing, all else equal. Option buyers pay theta every day; sellers collect it.

ν Vega — how much the option gains or loses for every 1% increase in implied volatility. Long options benefit from rising IV (earnings, events). Short options get hurt. Vega is highest for longer-dated options.

ρ Rho — sensitivity to interest rate changes. A Rho of 0.15 means the option gains $0.15 if rates rise 1%. Matters most for longer-dated options and currencies.

Break-Even — the underlying price the asset must reach at expiration for the position to be profitable (Strike + Premium for calls, Strike - Premium for puts). The % shown is how far the current price is from that level.

1σ to exp — expected 1 standard deviation price range from now to expiry, derived from IV and DTE. This is the range the market prices as ~68% probable. If you're selling options, this is the zone you're betting the price stays inside.

1σ range — the actual price levels (low and high) of that 1σ band

P&L +1σ / -1σ — estimated gain or loss if the underlying moves exactly +1σ or -1σ by expiry, using the Delta-Gamma approximation: ΔS × Δ + ½ × ΔS² × Γ. This is a second-order estimate — more accurate than Delta-only for large moves.

The panel line

The blue line plots Delta in real time as the underlying price moves. Watch it approach 1.0 (deep ITM) or 0.0 (deep OTM). The orange shaded area shows Gamma scaled ×1000 — spikes in gamma indicate high sensitivity zones where small price moves produce large Delta changes (pin risk, gamma squeeze setups).

Reference dashed lines at ±0.50 Delta (at-the-money) and ±1.0 (deep ITM boundaries).

Inputs

Input Description
Type Call or Put
Strike (K) Option strike price
Days to Expiry Calendar days to expiration
Implied Vol (%) Current IV of the option
Risk-Free Rate (%) Annual risk-free rate (T-bill rate)
Market Price Optional — enter broker quote to compare vs BS theoretical
Show ±1σ P&L estimate Toggle P&L rows
Plot Gamma exposure Toggle gamma area plot
Alerts included

Low Delta (<10Δ) — option approaching deep OTM, rapidly losing sensitivity
Deep ITM (>90Δ) — option behaving like the underlying, consider rolling or exercising
Gamma Spike — gamma increased >50% in one bar, elevated pin risk or near-expiry sensitivity
Notes

All calculations use the standard Black-Scholes-Merton model with the Abramowitz & Stegun normal CDF approximation (max error < 7.5×10⁻⁸)
The model assumes European-style options and continuous dividends of zero. For dividend-paying stocks adjust the risk-free rate down by the dividend yield.
This is an educational and analytical tool — not financial advice. Always verify Greeks against your broker's calculations.
Works on any symbol and timeframe. Best used on a chart of the exact underlying of your option.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © EVLabs —
//@version=6
indicator("Greeks Dashboard", overlay=false, max_lines_count=5)

grp_opt = "── Option ──"
opt_type = input.string("Call", "Type",              group=grp_opt, options=["Call","Put"])
strike   = input.float(4500.0,  "Strike (K)",         group=grp_opt, minval=0.01, step=1.0)
dte      = input.int(30,        "Days to Expiry",     group=grp_opt, minval=1, maxval=730)
iv       = input.float(15.0,    "Implied Vol (%)",    group=grp_opt, minval=0.1, maxval=500.0, step=0.1)
rfr      = input.float(5.0,     "Risk-Free Rate (%)", group=grp_opt, minval=0.0, maxval=20.0, step=0.25)

grp_disp = "── Display ──"
mkt_price = input.float(0.0,  "Market Price (0=auto)", group=grp_disp, minval=0.0)
show_pnl  = input.bool(true,  "Show ±1σ P&L estimate", group=grp_disp)
show_gex  = input.bool(true,  "Plot Gamma exposure",   group=grp_disp)

// ── Normal distribution functions ──
_npdf(x) =>
    math.exp(-0.5 * x * x) / math.sqrt(2.0 * math.pi)

_ncdf(x) =>
    a1 =  0.319381530
    a2 = -0.356563782
    a3 =  1.781477937
    a4 = -1.821255978
    a5 =  1.330274429
    p  =  0.2316419
    k  = 1.0 / (1.0 + p * math.abs(x))
    k2 = k * k
    k3 = k2 * k
    k4 = k3 * k
    k5 = k4 * k
    poly = a1 * k + a2 * k2 + a3 * k3 + a4 * k4 + a5 * k5
    approx = 1.0 - _npdf(x) * poly
    x >= 0.0 ? approx : 1.0 - approx

// ── Black-Scholes ──
S     = close
K     = strike
T     = dte / 365.0
sig   = iv  / 100.0
r     = rfr / 100.0
sqrtT = math.sqrt(T)

d1 = (math.log(S / K) + (r + 0.5 * sig * sig) * T) / (sig * sqrtT)
d2 = d1 - sig * sqrtT

Nd1  = _ncdf(d1)
Nd2  = _ncdf(d2)
Nnd1 = _ncdf(-d1)
Nnd2 = _ncdf(-d2)
npd1 = _npdf(d1)
eRT  = math.exp(-r * T)

is_call = opt_type == "Call"

bs_call  = S * Nd1  - K * eRT * Nd2
bs_put   = K * eRT  * Nnd2 - S * Nnd1
bs_price = is_call ? bs_call : bs_put

delta = is_call ? Nd1 : Nd1 - 1.0
gamma = npd1 / (S * sig * sqrtT)

theta_c = (-(S * npd1 * sig) / (2.0 * sqrtT) - r * K * eRT * Nd2)  / 365.0
theta_p = (-(S * npd1 * sig) / (2.0 * sqrtT) + r * K * eRT * Nnd2) / 365.0
theta   = is_call ? theta_c : theta_p

vega    = S * sqrtT * npd1 / 100.0

rho_c   = K * T * eRT *  Nd2  / 100.0
rho_p   = K * T * eRT * (-Nnd2) / 100.0
rho     = is_call ? rho_c : rho_p

// ── Derived ──
moneyness  = (S - K) / K * 100.0
itm        = is_call ? S > K : S < K
be         = is_call ? K + bs_price : K - bs_price
be_pct     = (be - S) / S * 100.0
one_sigma  = S * sig * sqrtT
pnl_up     = delta * one_sigma  + 0.5 * gamma * one_sigma * one_sigma
pnl_down   = delta * (-one_sigma) + 0.5 * gamma * one_sigma * one_sigma

// ── Plots ──
delta_col = delta >= 0 ? color.new(#2962ff, 0) : color.new(#ff1744, 0)
plot(delta, "Delta Δ", color=delta_col, linewidth=2)
plot(show_gex ? gamma * 1000 : na, "Gamma ×1000", color=color.new(#ff6d00, 40), linewidth=1, style=plot.style_area)

hline(0,    "Zero",     color=color.new(#787b86, 50), linestyle=hline.style_solid)
hline(0.5,  "0.5Δ",     color=color.new(#2962ff, 70), linestyle=hline.style_dashed)
hline(-0.5, "-0.5Δ",    color=color.new(#ff1744, 70), linestyle=hline.style_dashed)
hline(1.0,  "Deep ITM", color=color.new(#00c853, 80), linestyle=hline.style_dotted)
hline(-1.0, "Deep ITM", color=color.new(#00c853, 80), linestyle=hline.style_dotted)

// ── Table ──
var table tbl = na

_fmt4(v) => str.tostring(v, "#.####")
_fmt2(v) => str.tostring(v, "#.##")
_pct(v)  => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"
_sign(v) => v >= 0 ? "+" : ""

if barstate.islast
    if not na(tbl)
        table.delete(tbl)

    nrows = show_pnl ? 13 : 11
    tbl := table.new(position.top_right, 3, nrows,
         bgcolor=color.new(#1e222d, 0),
         border_width=1, border_color=color.new(#434651, 30),
         frame_width=1,  frame_color=color.new(#434651, 20))

    _c0 = color.new(#1e222d, 0)
    _ct = color.new(#9598a1, 0)
    _cw = color.white
    _cg = color.new(#00c853, 0)
    _cr = color.new(#ff1744, 0)
    _cy = color.new(#ffd600, 0)
    _cb = color.new(#2962ff, 0)
    _co = color.new(#ff6d00, 0)
    _cp = color.new(#aa00ff, 0)

    itm_str = itm ? "ITM" : "OTM"
    itm_bg  = itm ? color.new(#00c853, 60) : color.new(#ff1744, 60)

    // Row 0 — header
    hdr = opt_type + "  K=" + str.tostring(K, format.mintick) + "  " + str.tostring(dte) + "d  IV=" + str.tostring(iv, "#.#") + "%"
    table.cell(tbl, 0, 0, hdr,     bgcolor=color.new(#2962ff, 70), text_color=_cw,  text_size=size.small)
    table.cell(tbl, 1, 0, "",      bgcolor=color.new(#2962ff, 70), text_color=_cw,  text_size=size.small)
    table.cell(tbl, 2, 0, itm_str, bgcolor=itm_bg,                 text_color=_cw,  text_size=size.small)

    // Row 1 — underlying
    table.cell(tbl, 0, 1, "Spot",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(S, format.mintick), bgcolor=_c0, text_color=_cw, text_size=size.small)
    mono_col = moneyness >= 0 ? _cg : _cr
    table.cell(tbl, 2, 1, _pct(moneyness), bgcolor=_c0, text_color=mono_col, text_size=size.small)

    // Row 2 — BS price
    disp_mkt = mkt_price > 0 ? "Mkt " + _fmt4(mkt_price) : "—"
    table.cell(tbl, 0, 2, "BS Price", bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 2, _fmt4(bs_price), bgcolor=_c0, text_color=_cy, text_size=size.small)
    table.cell(tbl, 2, 2, disp_mkt,        bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 3 — Delta
    d_col = delta >= 0 ? _cg : _cr
    table.cell(tbl, 0, 3, "Δ  Delta",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 3, _fmt4(delta), bgcolor=_c0, text_color=d_col, text_size=size.small)
    table.cell(tbl, 2, 3, _fmt2(delta * 100) + "¢/pt", bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 4 — Gamma
    table.cell(tbl, 0, 4, "Γ  Gamma",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 4, _fmt4(gamma), bgcolor=_c0, text_color=_cb, text_size=size.small)
    table.cell(tbl, 2, 4, "Δ/pt",      bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 5 — Theta
    th_col = theta < 0 ? _cr : _cg
    table.cell(tbl, 0, 5, "Θ  Theta",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 5, _fmt4(theta), bgcolor=_c0, text_color=th_col, text_size=size.small)
    table.cell(tbl, 2, 5, "/day",       bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 6 — Vega
    table.cell(tbl, 0, 6, "ν  Vega",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 6, _fmt4(vega), bgcolor=_c0, text_color=_co, text_size=size.small)
    table.cell(tbl, 2, 6, "/1% IV",    bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 7 — Rho
    table.cell(tbl, 0, 7, "ρ  Rho",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 7, _fmt4(rho), bgcolor=_c0, text_color=_cp, text_size=size.small)
    table.cell(tbl, 2, 7, "/1% rate", bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 8 — Break-even
    be_col = math.abs(be_pct) < 2.0 ? _cy : _ct
    table.cell(tbl, 0, 8, "Break-Even",             bgcolor=_c0, text_color=_ct,   text_size=size.small)
    table.cell(tbl, 1, 8, str.tostring(be, format.mintick), bgcolor=_c0, text_color=be_col, text_size=size.small)
    table.cell(tbl, 2, 8, _pct(be_pct),             bgcolor=_c0, text_color=be_col, text_size=size.small)

    // Row 9 — 1σ move
    table.cell(tbl, 0, 9, "1σ  to exp",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 9, "±" + str.tostring(one_sigma, format.mintick), bgcolor=_c0, text_color=_cy, text_size=size.small)
    table.cell(tbl, 2, 9, _fmt2(sig * sqrtT * 100.0) + "%", bgcolor=_c0, text_color=_ct, text_size=size.small)

    // Row 10 — 1σ zones
    lo = S - one_sigma
    hi = S + one_sigma
    table.cell(tbl, 0, 10, "1σ  range",  bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(tbl, 1, 10, str.tostring(lo, format.mintick) + " – " + str.tostring(hi, format.mintick), bgcolor=_c0, text_color=_cy, text_size=size.small)
    table.cell(tbl, 2, 10, "",            bgcolor=_c0, text_color=_ct, text_size=size.small)

    if show_pnl
        // Row 11 — P&L +1σ
        u_col = pnl_up > 0 ? _cg : _cr
        table.cell(tbl, 0, 11, "P&L  +1σ est",  bgcolor=_c0, text_color=_ct, text_size=size.small)
        table.cell(tbl, 1, 11, _sign(pnl_up) + _fmt2(pnl_up), bgcolor=_c0, text_color=u_col, text_size=size.small)
        table.cell(tbl, 2, 11, "Δ + ½Γ",         bgcolor=_c0, text_color=_ct, text_size=size.small)

        // Row 12 — P&L -1σ
        d_c2 = pnl_down > 0 ? _cg : _cr
        table.cell(tbl, 0, 12, "P&L  -1σ est",   bgcolor=_c0, text_color=_ct, text_size=size.small)
        table.cell(tbl, 1, 12, _sign(pnl_down) + _fmt2(pnl_down), bgcolor=_c0, text_color=d_c2, text_size=size.small)
        table.cell(tbl, 2, 12, "Δ + ½Γ",          bgcolor=_c0, text_color=_ct, text_size=size.small)

// ── Alerts ──
alertcondition(math.abs(delta) < 0.10, "EV Greeks: Low Delta (<10Δ)",  "Option approaching OTM — delta below 10")
alertcondition(math.abs(delta) > 0.90, "EV Greeks: Deep ITM (>90Δ)",   "Option deep ITM — delta above 90")
alertcondition(gamma > gamma[1] * 1.5, "EV Greeks: Gamma Spike",        "Gamma increased >50% — elevated pin risk")
````
