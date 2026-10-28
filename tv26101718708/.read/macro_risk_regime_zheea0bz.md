# Macro Risk Regime

- url: https://www.tradingview.com/script/zHEea0bz-Macro-Risk-Regime/
- type: indicator
- pine_id: PUB;71bfef8c2be343869d669e2356121516
- version: 1.0

## Description

# Macro Risk Regime — Real-Yield Momentum + Inflation Pulse

## What it does

This indicator answers one question: **is the real-rate backdrop a tailwind or a headwind for risk assets right now?**

It reads the regime off the *direction* of the 10-year real yield — arguably the single most reliable macro driver of risk-asset financial conditions — and surrounds it with a realized-inflation "pulse" that tends to lead the real yield. So you can often see a turn building in inflation before the regime itself flips.

## What it plots

- **Amber line** — the 10-year real yield (FRED: DFII10, the 10Y TIPS yield).
- **White line** — its trend (a moving average over the lookback you set).
- **Shading** — green when the real yield is *below* its trend (real rates falling = easing = **RISK-ON**); red when *above* (rising = tightening = **RISK-OFF**).

The premise: falling real yields ease financial conditions and support risk; rising real yields tighten them and pressure risk. **Direction matters more than level.** This is what captured the deeply negative, falling real yields of 2020–21 (risk-on, even as inflation rose) and the sharp real-yield spike of 2022 (risk-off) — turns that an inflation-level signal alone would have missed.

## The table ("MACRO RISK")

- **Risk Regime** — the headline. The value is the real yield's gap to its trend; the status is RISK-ON (below trend, easing) or RISK-OFF (above trend, tightening).
- **YoY CPI** — trailing headline inflation, for reference. It's the input to the rows below.
- **3m Ann** — realized inflation's last-three-month annualized pace, tagged COOLING / STEADY / HEATING versus the 12-month trend. Your near-term inflation momentum.
- **Surprise\*** — the latest month's annualized pace minus the trailing 3-month pace: UPSIDE (accelerating), DOWNSIDE (decelerating), or IN LINE. See the note below on the asterisk.
- **Real−Priced** — trailing YoY CPI minus the 10-year breakeven (FRED: T10YIE): where realized inflation sits relative to what the market has priced.
- **Trend vs Priced** — realized 3-month pace minus the breakeven: whether the recent inflation run-rate is HOT or COOL versus what's priced. This is the forward-looking tactical read — realized cooling *below* what's priced is the disinflation-confirming signal that tends to pull real yields, and the regime, lower.

## How to use it

1. **Read the shading as the regime.** Green = real-rate tailwind, red = headwind. That's your macro backdrop in one glance.
2. **Use the inflation pulse as the leading tell.** Disinflation showing up first in the pulse (COOLING, DOWNSIDE surprise, COOL vs PRICED) tends to lead real yields lower and flip the regime green; accelerating inflation does the reverse. The pulse often turns before the shading does.
3. **Mind the divergences — they're the point.** When the regime is red but your asset is rising anyway, the move is running on something *other* than real-rate easing — liquidity, flows, an idiosyncratic catalyst — which is a less macro-confirmed, more fragile advance. When the regime and price agree, that's higher conviction. The divergences are the most useful information the tool gives you, not a defect.
4. **Tune the trend length.** Shorter = more responsive and more whipsaw; longer = a smoother, slower regime. The default (100 trading days, ~5 months) is a reasonable middle. The moving average is computed on daily data, so the lookback means the same thing regardless of your chart's timeframe.

Add it to whatever symbol you're analyzing and read your asset against the macro backdrop.

## Settings

- **Risk-Regime Trend Length** — lookback for the real-yield trend (default 100 trading days).
- **Realized-vs-Priced Band** — sensitivity for the HOT / COOL vs PRICED flag (default 0.25%).
- **Surprise Band** — sensitivity for the UPSIDE / DOWNSIDE flag (default 0.5% annualized).

## Methodology and honest limitations

- **It is the real-rate slice of financial conditions plus an inflation pulse — not a full multi-factor financial-conditions index.** It deliberately leaves out credit spreads, the dollar, and equity volatility. It's strongest as the rates/inflation lens; pair it with those other inputs for a complete picture rather than treating it as a standalone everything-gauge.
- **"Surprise" is a momentum proxy, not a consensus surprise.** It compares the latest print to the recent run-rate, because there is no economist-estimate feed available in Pine. So it answers "is inflation accelerating or decelerating off its recent pace," which is related to — but not the same as — "did it beat forecasts." The asterisk in the table marks this.
- **It is a trend/momentum signal, so it can whipsaw** when real yields chop sideways around their average. In those stretches, lean on your other gauges.
- **History starts in 2003.** The real yield and everything referencing breakevens (Real−Priced, Trend vs Priced) begin when TIPS/breakeven data begins; earlier bars read n/a.

## Data

All series are pulled live from FRED via `request.security`: DFII10 (10-year TIPS real yield), T10YIE (10-year breakeven inflation), and CPIAUCSL (CPI). Nothing is hard-coded or hidden — the regime and every table value are computed from these public series.

## Disclaimer

For educational and informational purposes only. This is not investment advice or a recommendation to buy or sell any asset. Markets involve risk; do your own research.

## Source Code

````pine
//@version=6
indicator("Macro Risk Regime", overlay=false, precision=3)

// ─────────────────────────────────────────────────────────────────────────────
// Risk-on/off regime driven by 10Y real-yield momentum, with a realized-inflation
// pulse (surprise + rate-of-change vs what's priced) as leading context.
// Plotted view = the risk regime. Table = regime + inflation tactical reads.
// Note: this is the real-rate slice of "financial conditions" + an inflation pulse,
// NOT a full multi-factor FCI (no credit spreads / dollar / equity vol).
// ─────────────────────────────────────────────────────────────────────────────

// ─── INPUTS ───
grp = "Risk Regime"
risk_smooth = input.int(100, "Risk-Regime Trend Length (trading days)", minval=10, group=grp, tooltip="Lookback for the 10Y real-yield trend (SMA of DFII10, computed on daily data so it's the same regardless of chart timeframe). Real yield BELOW its trend = easing financial conditions = RISK-ON; ABOVE = tightening = RISK-OFF. Shorter = more responsive / more whipsaw; 100 ≈ 5 months.")

grp_inf = "Inflation Pulse"
vsprice_band = input.float(0.25, "Realized-vs-Priced Band (%)", group=grp_inf, tooltip="If realized inflation's recent pace sits more than this above/below the 10Y breakeven, flag HOT / COOL vs PRICED.")
surprise_band = input.float(0.5, "Surprise Band (% annualized)", group=grp_inf, tooltip="Latest month's annualized change minus the trailing 3-month annualized pace. IMPORTANT: a MOMENTUM-based proxy for surprise (freshest print vs recent run-rate), NOT a consensus-survey surprise — TradingView has no economist-estimate feed.")

// ─── DATA ───
// Risk regime: 10Y TIPS real yield (DFII10) and its trend. SMA computed inside the
// request so the length is in TRADING DAYS regardless of the chart's timeframe.
ry_real  = request.security("FRED:DFII10", "D", close)
ry_trend = request.security("FRED:DFII10", "D", ta.sma(close, risk_smooth))
ry_ok    = not na(ry_real) and not na(ry_trend)
risk_on  = ry_ok and ry_real < ry_trend   // real yield below trend = easing = risk-on

// Priced inflation (10Y breakeven)
be_10y = request.security("FRED:T10YIE", "D", close)

// Realized inflation (CPI) + lags for momentum / surprise
cpi_raw     = request.security("FRED:CPIAUCSL", "M", close)
cpi_raw_12m = request.security("FRED:CPIAUCSL", "M", close[12])
cpi_1m      = request.security("FRED:CPIAUCSL", "M", close[1])
cpi_3m      = request.security("FRED:CPIAUCSL", "M", close[3])
cpi_yoy     = (cpi_raw - cpi_raw_12m) / cpi_raw_12m * 100
cpi_mom_ann = na(cpi_1m) or cpi_1m == 0 ? na : (cpi_raw / cpi_1m - 1) * 1200            // latest month, annualized
cpi_3m_ann  = na(cpi_3m) or cpi_3m == 0 ? na : (math.pow(cpi_raw / cpi_3m, 4) - 1) * 100 // trailing 3m, annualized
mom_delta   = na(cpi_3m_ann) or na(cpi_yoy) ? na : cpi_3m_ann - cpi_yoy                  // recent pace vs 12m trend
cpi_surprise= na(cpi_mom_ann) or na(cpi_3m_ann) ? na : cpi_mom_ann - cpi_3m_ann          // surprise proxy

// Realized vs priced (na before 2003 — breakevens start then)
gap_level = na(be_10y) ? na : cpi_yoy    - be_10y   // where realized sits vs priced
gap_mom   = na(be_10y) ? na : cpi_3m_ann - be_10y   // realized recent PACE vs priced

// ─── COLORS / STATUS HELPERS (green = dovish/risk-on, red = hot/risk-off) ───
col_good = color.new(#00E676, 0)
col_bad  = color.new(#FF1744, 0)
col_mid  = color.new(#FFEB3B, 0)
col_na   = color.new(#FFFFFF, 45)

f_signed(v) => na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##")

f_vsprice_status(g) => na(g) ? "n/a"  : g >  vsprice_band ? "HOT vs PRICED" : g < -vsprice_band ? "COOL vs PRICED" : "IN LINE"
f_vsprice_color(g)  => na(g) ? col_na : g >  vsprice_band ? col_bad         : g < -vsprice_band ? col_good        : col_mid

f_surprise_status(s) => na(s) ? "n/a"  : s >  surprise_band ? "UPSIDE"  : s < -surprise_band ? "DOWNSIDE" : "IN LINE"
f_surprise_color(s)  => na(s) ? col_na : s >  surprise_band ? col_bad    : s < -surprise_band ? col_good   : col_mid

f_mom_status(d) => na(d) ? "n/a"  : d < -0.25 ? "COOLING" : d > 0.25 ? "HEATING" : "STEADY"
f_mom_color(d)  => na(d) ? col_na : d < -0.25 ? col_good  : d > 0.25 ? col_bad   : col_mid

// ─── PLOT: RISK REGIME ───
// Amber = 10Y real yield, white = its trend. Shaded GREEN when real yield is below
// trend (easing → risk-on), RED when above (tightening → risk-off).
hline(0.0, "Zero", color=color.new(#FFFFFF, 80), linestyle=hline.style_dotted)
p_ry    = plot(ry_real,  "10Y Real Yield",   color=color.new(#FFB300, 0), linewidth=2, style=plot.style_line)
p_trend = plot(ry_trend, "Real-Yield Trend", color=color.new(#E0E0E0, 0), linewidth=2, style=plot.style_line)
risk_fill = not ry_ok ? na : risk_on ? color.new(#00E676, 78) : color.new(#FF1744, 78)
fill(p_ry, p_trend, color=risk_fill, title="Risk Regime")

// ─── TABLE ───
var table panel = table.new(position.top_right, 3, 7, bgcolor=color.new(#1a1a2e, 10), border_width=1, border_color=color.new(#FFFFFF, 80))

if barstate.islast
    table.cell(panel, 0, 0, "MACRO RISK", text_color=color.new(#FF9800, 0), text_size=size.normal, bgcolor=color.new(#16213e, 0))
    table.cell(panel, 1, 0, "Value", text_color=color.white, text_size=size.normal, bgcolor=color.new(#16213e, 0))
    table.cell(panel, 2, 0, "Status", text_color=color.white, text_size=size.normal, bgcolor=color.new(#16213e, 0))

    // Risk Regime (headline): real yield vs its trend
    risk_gap = ry_ok ? ry_real - ry_trend : na
    risk_txt = not ry_ok ? "n/a" : risk_on ? "RISK-ON" : "RISK-OFF"
    risk_col = not ry_ok ? col_na : risk_on ? col_good : col_bad
    table.cell(panel, 0, 1, "Risk Regime", text_color=color.white, text_size=size.normal)
    table.cell(panel, 1, 1, f_signed(risk_gap), text_color=risk_col, text_size=size.normal)
    table.cell(panel, 2, 1, risk_txt, text_color=risk_col, text_size=size.normal)

    // Realized YoY CPI (reference)
    table.cell(panel, 0, 2, "YoY CPI", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 2, na(cpi_yoy) ? "n/a" : str.tostring(cpi_yoy, "#.##") + "%", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 2, 2, "", text_color=color.white, text_size=size.normal)

    // Realized momentum: 3m annualized pace, tagged cooling/heating vs the 12m trend
    table.cell(panel, 0, 3, "3m Ann", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 3, na(cpi_3m_ann) ? "n/a" : str.tostring(cpi_3m_ann, "#.##") + "%", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 2, 3, f_mom_status(mom_delta), text_color=f_mom_color(mom_delta), text_size=size.normal)

    // Surprise proxy (* = momentum proxy, not consensus)
    table.cell(panel, 0, 4, "Surprise*", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 4, f_signed(cpi_surprise), text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 2, 4, f_surprise_status(cpi_surprise), text_color=f_surprise_color(cpi_surprise), text_size=size.normal)

    // Realized vs priced (level)
    table.cell(panel, 0, 5, "Real−Priced", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 5, f_signed(gap_level), text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 2, 5, "", text_color=color.white, text_size=size.normal)

    // Trend vs priced (rate of change vs priced) — the headline inflation tactical read
    table.cell(panel, 0, 6, "Trend vs Priced", text_color=color.white, text_size=size.normal)
    table.cell(panel, 1, 6, f_signed(gap_mom), text_color=f_vsprice_color(gap_mom), text_size=size.normal)
    table.cell(panel, 2, 6, f_vsprice_status(gap_mom), text_color=f_vsprice_color(gap_mom), text_size=size.normal)
````
