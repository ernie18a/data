# Seasonality Tables  Stock vs Sector vs Commodity

- url: https://www.tradingview.com/script/vh0Dmcx1-Seasonality-Tables-Stock-vs-Sector-vs-Commodity/
- type: indicator
- pine_id: PUB;299286e0191348bf81f77c214a37d6a1
- version: 2.0

## Description

Seasonality Tables — Stock vs Sector vs Commodity
[b]What it does[/b]
This indicator overlays a unified, three-panel seasonality table directly on your chart, showing the historical average return for the current stock, its matched sector ETF, and its most-correlated commodity — side by side, on the same time axis (annual or monthly). Every cell is a real historical average computed bar-by-bar from the chart's full price history; nothing is precomputed or cached from an external dataset.

Three tables:

[list]
[*]Stock seasonality — average return of the symbol on your chart, broken down by month (annual view) or by trading day-of-month (monthly view).
[*]Sector seasonality — same calculation applied to the sector ETF that matches the stock's syminfo.sector. The mapping covers ASX sector indices (XEJ, XMJ, XFJ, XHJ, XNJ, XSJ, XIJ, XDJ, XTJ, XUJ, XPJ) and US SPDR sectors (XLE, XLB, XLF, XLV, XLI, XLP, XLK, XLY, XLC, XLU, XLRE, XLC), auto-selected by the stock's listed country. You can override with any ticker you want.
[*]Commodity seasonality — auto-picked from a 23-commodity basket (Gold, Silver, Crude, Copper, Iron Ore, Lithium, Uranium, Nat Gas, Wheat, etc.) by computing rolling price correlation between the stock and each commodity over the stock's full available history. The strongest correlation wins and loads automatically. You can override the pick from a dropdown if you'd rather see a specific commodity.
[/list]

[b]How it differs from other seasonality scripts[/b]
Most seasonality indicators on TradingView do one of two things: (a) show seasonality for just the symbol on the chart, or (b) hard-code an index (S&P 500, BTC) and ignore what you're actually looking at. This script is built around comparative context:

[list]
[*]Stock × Sector × Commodity in one view. You don't have to flip charts to ask "is this stock's June weakness actually a sector pattern, or is it idiosyncratic?" — both rows are on screen, aligned to the same months.
[*]Auto sector mapping. The sector ETF is resolved from syminfo.sector and syminfo.country, so flipping from BHP → CBA → MSFT automatically reloads the right ETF (XMJ → XFJ → XLK). No manual config per symbol.
[*]Correlation-driven commodity selection. Other scripts that overlay commodities make you pick one. This one measures which commodity best tracks the stock and loads it for you. For a copper miner you'll get HG; for a gold miner, GC; for an LNG name, NG. The auto-selection is shown in the commodity table title so you can see what it chose.
[*]Magnitude-scaled colour intensity. Cells aren't binary green/red. Saturation scales linearly with return magnitude up to ±5%, so a +0.3% month looks faded and a −4% month is fully red. Pattern strength is visible at a glance, not just direction.
[*]Honest about new listings. Correlation and seasonality both use a cumulative-sum approach over the stock's actual available history (gated at min 30 valid bars), rather than a fixed 252-bar window. A stock that listed 8 months ago shows 8 months of data; a 20-year stock uses 20 years. 
[*]Lookback caps per table. Independent "years to include" inputs for stock, sector, and commodity (0 = all). Useful when you want the stock on its full life but the sector ETF capped at, say, 10 years to avoid a regime that no longer applies.
[/list]

[b]How to use it[/b]

[list=1]
[*]Add to a daily chart. The commodity table uses inline accumulation over chart bars (a workaround for Pine's 40-call request.security budget), so it assumes a Daily timeframe. Weekly+ will under-sample the commodity row.
[*]Pick a scale.
[list]
[*]Annual → 12 rows (Jan–Dec), each cell is the average monthly return.
[*]Monthly → 31 rows (1–31), each cell is the average return on that trading day-of-month for the currently displayed month.
[/list]
[*]Read the columns side-by-side. Look for agreement and divergence:
[list]
[*]Stock + Sector + Commodity all green in the same month → strong seasonal tailwind, broad-based.
[*]Stock green but Sector and Commodity red → idiosyncratic; the seasonality may not survive a sector drawdown.
[*]Sector and Commodity strong but Stock weak → potential mean-reversion candidate, or a sign the stock has structural issues.
[/list]
[*]The current period is highlighted (orange) so you can immediately see "where am I right now in the seasonal cycle, and what's coming next month?"
[*]Override when needed. Toggle "Override Auto ETF" or "Override Auto Commodity" if you disagree with the mapping (e.g. a gold royalty company auto-maps to Materials/XMJ but you'd rather compare it to the Gold ETF and Silver).
[/list]

[b]The strategy behind it[/b]

Seasonality is most useful as a bias filter, not a signal. The premise of the three-table layout:

[list]
[*]A standalone seasonal pattern in a single stock is fragile — could be 3–4 random earnings dates clustered in one month.
[*]A pattern that's also present in the sector suggests a real demand/inventory/fiscal-year cycle (e.g. retailers in November, energy in winter, miners around Chinese New Year).
[*]A pattern that also shows in the correlated commodity suggests an underlying physical-market driver (e.g. gold's Q1 strength, oil's summer demand, gas's winter demand).
[/list]

When all three line up, you have a higher-conviction seasonal window. When they disagree, you've identified an idiosyncratic pattern — which can still be tradeable, but warrants closer inspection (is it earnings-driven? Index rebalance? A one-off?). The script doesn't tell you to enter or exit; it gives you the historical context to time discretionary entries, choose between candidates in the same sector, or simply avoid fighting a strong negative seasonal alignment.

Use it alongside your normal setup as a context layer, not a system or a buy/sell signal.

## Source Code

````pine
// =============================================================================
// SEASONALITY TABLES — STOCK vs SECTOR vs COMMODITY
// Pine Script v5
// Author: Nathan L
//
// v15 changes (from v14):
//   • Fixed compile error "Cannot call 'request.security' with argument
//     'symbol'='cmd_ticker_used'. An argument of 'series string' type was used
//     but a 'simple string' is expected." Root cause: in v14 the commodity
//     ticker was selected at runtime from the highest-correlation commodity
//     (best_cmd_ticker is a `var string` reassigned inside `if barstate.islast`,
//     which makes it `series string`). Pine's request.security symbol must be
//     simple/input/const — runtime selection is fundamentally not allowed.
//     Resolution: commodity ticker is now picked via input.string dropdown
//     (input string is simple-string compatible). The auto-correlation still
//     runs and the recommended commodity is shown in the commodity table title
//     so the user can apply it manually from the dropdown.
//   • Fixed "Cannot assign a variable to a tuple" — was a cascade from the
//     above; resolves with the simple-string fix.
//   • Fixed "Declared type 'array<float>' is not compatible with assigned
//     type 'array<unknown>'" on the 31-element array.from() reconstructions
//     by casting the first argument to float() so the compiler reliably
//     infers array<float>.
//   • Fixed local variable shadowing inside the annual and monthly render
//     loops (cc2/ca2 conflicted with the tuple-unpacked names from
//     request.security). Renamed all loop-local temporaries with an _
//     prefix.
//   • Replaced fixed 252-bar `ta.correlation` with a cumulative-sum
//     correlation (`calc_corr` helper) that uses the stock's actual chart
//     history rather than a fixed window. This way the correlation is bounded
//     by the stock's available data — newly-listed stocks can be analysed on
//     whatever history they have (gated at a minimum 30 valid bars), and
//     long-listed stocks aren't artificially capped at one year. Bars where
//     either series is na are excluded.
//   • Commodity dropdown now shows display names ("Gold", "Silver", "Crude
//     Oil", …) instead of raw tickers, with the ticker derived internally
//     via a ternary mapping. Added an Auto / Override toggle: by default
//     the commodity table loads the highest-correlated commodity from the
//     basket; flipping Override on uses the dropdown selection instead.
//   • Switched commodity seasonality from per-ticker request.security calls
//     to inline accumulators (`accumulate_cmd_seasonality` helper) that
//     run over each commodity's already-fetched daily close. This is what
//     makes auto-default loading possible — without it we'd need 20 × 3 =
//     60 request.security calls just for commodity seasonality, which
//     exceeds the script-wide 40-call cap. With inline accumulation we use
//     20 calls (correlation closes) + 3 (ETF) and stay well within the
//     budget. NOTE: inline accumulators use chart bar context, so this
//     script now ASSUMES a Daily chart timeframe for the commodity table.
//     Running it on Weekly+ will under-sample the commodity seasonality
//     (the ETF table still uses request.security("D", …) and is unaffected).
//
// v14 changes:
//   • Commodity auto-mapping via price correlation rather than industry
//     strings — calculates rolling correlation against a basket of
//     commodities and picks the highest correlating one (in v15 this is now
//     cumulative-sum-based over the stock's full history; see v15 note above).
//   • Colour intensity scales with return magnitude: closer to 0% = faded,
//     closer to ±5% = full saturation. Cap at 5%.
//   • Stock, sector, and commodity tables merged into one unified table for
//     consistent alignment.
//   • Updated commodity ticker list per spec.
// =============================================================================

//@version=5
indicator("Seasonality Tables Stock vs Sector vs Commodity", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// SECTOR → ETF AUTO-MAP
// ─────────────────────────────────────────────────────────────────────────────

sector_raw   = syminfo.sector
country_code = syminfo.country

asx_etf =
     sector_raw == "Energy"                     ? "ASX:XEJ" :
     sector_raw == "Energy Minerals"            ? "ASX:XEJ" :
     sector_raw == "Oil & Gas"                  ? "ASX:XEJ" :
     sector_raw == "Oil, Gas & Consumable Fuels"? "ASX:XEJ" :
     sector_raw == "Materials"                  ? "ASX:XMJ" :
     sector_raw == "Non-Energy Minerals"        ? "ASX:XMJ" :
     sector_raw == "Minerals"                   ? "ASX:XMJ" :
     sector_raw == "Mining"                     ? "ASX:XMJ" :
     sector_raw == "Metals & Mining"            ? "ASX:XMJ" :
     sector_raw == "Gold"                       ? "ASX:XMJ" :
     sector_raw == "Steel"                      ? "ASX:XMJ" :
     sector_raw == "Finance"                    ? "ASX:XFJ" :
     sector_raw == "Financials"                 ? "ASX:XFJ" :
     sector_raw == "Financial Services"         ? "ASX:XFJ" :
     sector_raw == "Banking"                    ? "ASX:XFJ" :
     sector_raw == "Banks"                      ? "ASX:XFJ" :
     sector_raw == "Insurance"                  ? "ASX:XFJ" :
     sector_raw == "Diversified Financials"     ? "ASX:XFJ" :
     sector_raw == "Investment Trusts"          ? "ASX:XFJ" :
     sector_raw == "Health Technology"          ? "ASX:XHJ" :
     sector_raw == "Health Care"                ? "ASX:XHJ" :
     sector_raw == "Healthcare"                 ? "ASX:XHJ" :
     sector_raw == "Health Services"            ? "ASX:XHJ" :
     sector_raw == "Pharmaceuticals"            ? "ASX:XHJ" :
     sector_raw == "Biotechnology"              ? "ASX:XHJ" :
     sector_raw == "Medical Equipment"          ? "ASX:XHJ" :
     sector_raw == "Industrials"                ? "ASX:XNJ" :
     sector_raw == "Industrial Services"        ? "ASX:XNJ" :
     sector_raw == "Industrial Goods"           ? "ASX:XNJ" :
     sector_raw == "Transportation"             ? "ASX:XNJ" :
     sector_raw == "Capital Goods"              ? "ASX:XNJ" :
     sector_raw == "Construction"               ? "ASX:XNJ" :
     sector_raw == "Engineering"                ? "ASX:XNJ" :
     sector_raw == "Aerospace & Defense"        ? "ASX:XNJ" :
     sector_raw == "Consumer Staples"           ? "ASX:XSJ" :
     sector_raw == "Consumer Non-Durables"      ? "ASX:XSJ" :
     sector_raw == "Food & Beverage"            ? "ASX:XSJ" :
     sector_raw == "Food & Drug Retailing"      ? "ASX:XSJ" :
     sector_raw == "Retail Trade"               ? "ASX:XSJ" :
     sector_raw == "Supermarkets"               ? "ASX:XSJ" :
     sector_raw == "Beverages"                  ? "ASX:XSJ" :
     sector_raw == "Technology"                 ? "ASX:XIJ" :
     sector_raw == "Information Technology"     ? "ASX:XIJ" :
     sector_raw == "Technology Services"        ? "ASX:XIJ" :
     sector_raw == "Electronic Technology"      ? "ASX:XIJ" :
     sector_raw == "Software"                   ? "ASX:XIJ" :
     sector_raw == "Semiconductors"             ? "ASX:XIJ" :
     sector_raw == "Consumer Discretionary"     ? "ASX:XDJ" :
     sector_raw == "Consumer Durables"          ? "ASX:XDJ" :
     sector_raw == "Consumer Services"          ? "ASX:XDJ" :
     sector_raw == "Retail"                     ? "ASX:XDJ" :
     sector_raw == "Leisure"                    ? "ASX:XDJ" :
     sector_raw == "Hotels & Entertainment"     ? "ASX:XDJ" :
     sector_raw == "Automobiles & Components"   ? "ASX:XDJ" :
     sector_raw == "Communications"             ? "ASX:XTJ" :
     sector_raw == "Communication Services"     ? "ASX:XTJ" :
     sector_raw == "Telecommunication Services" ? "ASX:XTJ" :
     sector_raw == "Telecommunications"         ? "ASX:XTJ" :
     sector_raw == "Media"                      ? "ASX:XTJ" :
     sector_raw == "Publishing"                 ? "ASX:XTJ" :
     sector_raw == "Utilities"                  ? "ASX:XUJ" :
     sector_raw == "Electric Utilities"         ? "ASX:XUJ" :
     sector_raw == "Gas Utilities"              ? "ASX:XUJ" :
     sector_raw == "Water Utilities"            ? "ASX:XUJ" :
     sector_raw == "Real Estate"                ? "ASX:XPJ" :
     sector_raw == "Property"                   ? "ASX:XPJ" :
     sector_raw == "REITs"                      ? "ASX:XPJ" :
     sector_raw == "Real Estate Investment"     ? "ASX:XPJ" :
     "ASX:XJO"

us_etf =
     sector_raw == "Energy"                     ? "XLE"  :
     sector_raw == "Energy Minerals"            ? "XLE"  :
     sector_raw == "Oil & Gas"                  ? "XLE"  :
     sector_raw == "Oil, Gas & Consumable Fuels"? "XLE"  :
     sector_raw == "Materials"                  ? "XLB"  :
     sector_raw == "Non-Energy Minerals"        ? "XLB"  :
     sector_raw == "Minerals"                   ? "XLB"  :
     sector_raw == "Mining"                     ? "XLB"  :
     sector_raw == "Metals & Mining"            ? "XLB"  :
     sector_raw == "Gold"                       ? "XLB"  :
     sector_raw == "Steel"                      ? "XLB"  :
     sector_raw == "Finance"                    ? "XLF"  :
     sector_raw == "Financials"                 ? "XLF"  :
     sector_raw == "Financial Services"         ? "XLF"  :
     sector_raw == "Banking"                    ? "XLF"  :
     sector_raw == "Banks"                      ? "XLF"  :
     sector_raw == "Insurance"                  ? "XLF"  :
     sector_raw == "Diversified Financials"     ? "XLF"  :
     sector_raw == "Health Technology"          ? "XLV"  :
     sector_raw == "Health Care"                ? "XLV"  :
     sector_raw == "Healthcare"                 ? "XLV"  :
     sector_raw == "Health Services"            ? "XLV"  :
     sector_raw == "Pharmaceuticals"            ? "XLV"  :
     sector_raw == "Biotechnology"              ? "XLV"  :
     sector_raw == "Medical Equipment"          ? "XLV"  :
     sector_raw == "Industrials"                ? "XLI"  :
     sector_raw == "Industrial Services"        ? "XLI"  :
     sector_raw == "Industrial Goods"           ? "XLI"  :
     sector_raw == "Transportation"             ? "XLI"  :
     sector_raw == "Capital Goods"              ? "XLI"  :
     sector_raw == "Construction"               ? "XLI"  :
     sector_raw == "Aerospace & Defense"        ? "XLI"  :
     sector_raw == "Consumer Staples"           ? "XLP"  :
     sector_raw == "Consumer Non-Durables"      ? "XLP"  :
     sector_raw == "Food & Beverage"            ? "XLP"  :
     sector_raw == "Food & Drug Retailing"      ? "XLP"  :
     sector_raw == "Retail Trade"               ? "XLP"  :
     sector_raw == "Beverages"                  ? "XLP"  :
     sector_raw == "Technology"                 ? "XLK"  :
     sector_raw == "Information Technology"     ? "XLK"  :
     sector_raw == "Technology Services"        ? "XLK"  :
     sector_raw == "Electronic Technology"      ? "XLK"  :
     sector_raw == "Software"                   ? "XLK"  :
     sector_raw == "Semiconductors"             ? "XLK"  :
     sector_raw == "Consumer Discretionary"     ? "XLY"  :
     sector_raw == "Consumer Durables"          ? "XLY"  :
     sector_raw == "Consumer Services"          ? "XLY"  :
     sector_raw == "Retail"                     ? "XLY"  :
     sector_raw == "Leisure"                    ? "XLY"  :
     sector_raw == "Hotels & Entertainment"     ? "XLY"  :
     sector_raw == "Automobiles & Components"   ? "XLY"  :
     sector_raw == "Communications"             ? "XLC"  :
     sector_raw == "Communication Services"     ? "XLC"  :
     sector_raw == "Telecommunication Services" ? "XLC"  :
     sector_raw == "Telecommunications"         ? "XLC"  :
     sector_raw == "Media"                      ? "XLC"  :
     sector_raw == "Utilities"                  ? "XLU"  :
     sector_raw == "Electric Utilities"         ? "XLU"  :
     sector_raw == "Gas Utilities"              ? "XLU"  :
     sector_raw == "Water Utilities"            ? "XLU"  :
     sector_raw == "Real Estate"                ? "XLRE" :
     sector_raw == "Property"                   ? "XLRE" :
     sector_raw == "REITs"                      ? "XLRE" :
     sector_raw == "Real Estate Investment"     ? "XLRE" :
     "SPY"

auto_etf = country_code == "AU" ? asx_etf : us_etf

// ─────────────────────────────────────────────────────────────────────────────
// EARLY INPUTS (declared up here so the correlation basket and accumulators
// below can short-circuit when their work isn't needed).
// ─────────────────────────────────────────────────────────────────────────────

i_scale_early = input.string("Annual", "Seasonality Scale",
     options=["Annual", "Monthly"], group="Layout",
     tooltip="Annual: avg monthly return Jan–Dec.\nMonthly: avg daily return for each day of the current month.")
is_annual_early = i_scale_early == "Annual"

i_cmd_show_early = input.bool(true, "Show Commodity Table", group="Commodity Table",
     tooltip="Shows a 3rd table for the commodity. By default the table loads the commodity with the highest correlation to this stock — flip 'Override Auto Commodity' to pick one manually from the dropdown instead.")
i_cmd_override_early = input.bool(false, "Override Auto Commodity", group="Commodity Table",
     tooltip="When off, the commodity with the highest correlation (over the stock's full chart history) is loaded automatically.\nWhen on, the commodity selected in the dropdown below is loaded instead.")

allowed_sectors_early = array.from("Energy", "Energy Minerals", "Oil & Gas", "Oil, Gas & Consumable Fuels", "Materials", "Non-Energy Minerals", "Minerals", "Mining", "Metals & Mining", "Gold", "Steel")
is_allowed_sector_early = array.includes(allowed_sectors_early, sector_raw)

// True only when we actually need the auto-recommendation correlation basket.
// When override is on, or the table is hidden, or the sector isn't allowed,
// the basket is dead weight.
corr_needed = i_cmd_show_early and is_allowed_sector_early and not i_cmd_override_early
// True only when we need commodity seasonality data at all.
cmd_needed  = i_cmd_show_early and is_allowed_sector_early

// ─────────────────────────────────────────────────────────────────────────────
// COMMODITY CORRELATION BASKET
// ─────────────────────────────────────────────────────────────────────────────
// Calculates correlation between the stock's daily return and each commodity
// in the basket using cumulative sums (see calc_corr below). The window
// spans the stock's actual chart history — for a stock with 5 years of data
// it uses 5 years; for a recently-listed stock it uses whatever it has
// (minimum 30 bars). This avoids the trap of correlating a thinly-traded
// stock against a long commodity history. The result is shown as a
// recommendation in the commodity table title — the user then picks that
// commodity from the dropdown input below to actually load its seasonality
// data. (Pine v5 requires request.security symbol to be a simple string;
// runtime selection from a series string is not supported, so the
// seasonality fetch can't be auto-driven from the correlation result.)

stk_ret = close / close[1] - 1.0

c_gold    = request.security("TVC:GOLD",          "D", close, lookahead=barmerge.lookahead_off)
c_silver  = request.security("TVC:SILVER",        "D", close, lookahead=barmerge.lookahead_off)
c_oil     = request.security("TVC:USOIL",         "D", close, lookahead=barmerge.lookahead_off)
c_gas     = request.security("MCX:NATURALGAS1!",  "D", close, lookahead=barmerge.lookahead_off)
c_iron    = request.security("SGX:FEF1!",         "D", close, lookahead=barmerge.lookahead_off)
c_copper  = request.security("COMEX:HG1!", "D", close, lookahead=barmerge.lookahead_off)
c_alum    = request.security("SHFE:AL1!",   "D", close, lookahead=barmerge.lookahead_off)
c_nickel  = request.security("SHFE:NI1!",      "D", close, lookahead=barmerge.lookahead_off)
c_zinc    = request.security("SHFE:ZN1!",        "D", close, lookahead=barmerge.lookahead_off)
c_lead    = request.security("SHFE:PB1!",        "D", close, lookahead=barmerge.lookahead_off)
c_coal    = request.security("ICEEUR:NCF1!",      "D", close, lookahead=barmerge.lookahead_off)
c_lithium = request.security("COMEX:LTH1!",       "D", close, lookahead=barmerge.lookahead_off)
c_uranium = request.security("OTC:SRUUF",         "D", close, lookahead=barmerge.lookahead_off)
c_lumber  = request.security("CME:LBR1!",         "D", close, lookahead=barmerge.lookahead_off)
c_wheat   = request.security("PEPPERSTONE:WHEAT", "D", close, lookahead=barmerge.lookahead_off)
c_corn    = request.security("PEPPERSTONE:CORN",  "D", close, lookahead=barmerge.lookahead_off)
c_sugar   = request.security("PEPPERSTONE:SUGAR", "D", close, lookahead=barmerge.lookahead_off)
c_cotton  = request.security("PEPPERSTONE:COTTON","D", close, lookahead=barmerge.lookahead_off)
c_plat    = request.security("TVC:PLATINUM",      "D", close, lookahead=barmerge.lookahead_off)
c_pall    = request.security("TVC:PALLADIUM",     "D", close, lookahead=barmerge.lookahead_off)
c_gasoline= request.security("NYMEX:RB1!",        "D", close, lookahead=barmerge.lookahead_off)
c_heatoil = request.security("NYMEX:HO1!",        "D", close, lookahead=barmerge.lookahead_off)
c_brent   = request.security("ICEEUR:BRN1!",      "D", close, lookahead=barmerge.lookahead_off)
c_remx    = request.security("AMEX:REMX",         "D", close, lookahead=barmerge.lookahead_off)
c_gdx     = request.security("AMEX:GDX",          "D", close, lookahead=barmerge.lookahead_off)
c_gdxj    = request.security("AMEX:GDXJ",         "D", close, lookahead=barmerge.lookahead_off)
c_sil     = request.security("AMEX:SIL",          "D", close, lookahead=barmerge.lookahead_off)
c_silj    = request.security("AMEX:SILJ",         "D", close, lookahead=barmerge.lookahead_off)
c_lit     = request.security("AMEX:LIT",          "D", close, lookahead=barmerge.lookahead_off)
c_copx    = request.security("AMEX:COPX",         "D", close, lookahead=barmerge.lookahead_off)
c_ura     = request.security("AMEX:URA",          "D", close, lookahead=barmerge.lookahead_off)

// Correlation helper — cumulative-sum correlation over the full chart history.
//
//   corr(X, Y) = ( E[XY] - E[X]E[Y] ) / sqrt( Var(X) * Var(Y) )
//
// OPTIMISATION: the stock-side cumulants (n, sx, sxx) are computed ONCE
// globally below and reused across all 31 commodity correlations. Each
// calc_corr call only computes its own three y-side cumulants (sy, syy, sxy).
// This drops ~93 ta.cum series. Tradeoff: na bars are treated as 0 in both
// series so all expectations share the same union sample. Commodities with
// shorter overlap with the stock will appear slightly less correlated, which
// is fine — we just want the argmax for picking the recommendation.
//
// Skip path: when corr_needed is false (override on, table hidden, or sector
// not allowed) the cumulants short-circuit and the function returns na.

stk_safe = nz(stk_ret, 0.0)
stk_n_cum   = corr_needed ? ta.cum(1.0)              : 0.0
stk_sx_cum  = corr_needed ? ta.cum(stk_safe)         : 0.0
stk_sxx_cum = corr_needed ? ta.cum(stk_safe * stk_safe) : 0.0

calc_corr(y_ret) =>
    if not corr_needed
        float(na)
    else
        _ys  = nz(y_ret, 0.0)
        _sy  = ta.cum(_ys)
        _sxy = ta.cum(stk_safe * _ys)
        _syy = ta.cum(_ys * _ys)
        _n   = stk_n_cum
        _mx  = _n > 0 ? stk_sx_cum  / _n : 0.0
        _my  = _n > 0 ? _sy         / _n : 0.0
        _vx  = _n > 0 ? stk_sxx_cum / _n - _mx * _mx : 0.0
        _vy  = _n > 0 ? _syy        / _n - _my * _my : 0.0
        _cv  = _n > 0 ? _sxy        / _n - _mx * _my : 0.0
        _n >= 30 and _vx > 0 and _vy > 0 ? _cv / math.sqrt(_vx * _vy) : float(na)

r_gold    = calc_corr(c_gold    / c_gold[1]    - 1)
r_silver  = calc_corr(c_silver  / c_silver[1]  - 1)
r_oil     = calc_corr(c_oil     / c_oil[1]     - 1)
r_gas     = calc_corr(c_gas     / c_gas[1]     - 1)
r_iron    = calc_corr(c_iron    / c_iron[1]    - 1)
r_copper  = calc_corr(c_copper  / c_copper[1]  - 1)
r_alum    = calc_corr(c_alum    / c_alum[1]    - 1)
r_nickel  = calc_corr(c_nickel  / c_nickel[1]  - 1)
r_zinc    = calc_corr(c_zinc    / c_zinc[1]    - 1)
r_lead    = calc_corr(c_lead    / c_lead[1]    - 1)
r_coal    = calc_corr(c_coal    / c_coal[1]    - 1)
r_lithium = calc_corr(c_lithium / c_lithium[1] - 1)
r_uranium = calc_corr(c_uranium / c_uranium[1] - 1)
r_lumber  = calc_corr(c_lumber  / c_lumber[1]  - 1)
r_wheat   = calc_corr(c_wheat   / c_wheat[1]   - 1)
r_corn    = calc_corr(c_corn    / c_corn[1]    - 1)
r_sugar   = calc_corr(c_sugar   / c_sugar[1]   - 1)
r_cotton  = calc_corr(c_cotton  / c_cotton[1]  - 1)
r_plat    = calc_corr(c_plat    / c_plat[1]    - 1)
r_pall    = calc_corr(c_pall    / c_pall[1]    - 1)
r_gasoline= calc_corr(c_gasoline/ c_gasoline[1]- 1)
r_heatoil = calc_corr(c_heatoil / c_heatoil[1] - 1)
r_brent   = calc_corr(c_brent   / c_brent[1]   - 1)
r_remx    = calc_corr(c_remx    / c_remx[1]    - 1)
r_gdx     = calc_corr(c_gdx     / c_gdx[1]     - 1)
r_gdxj    = calc_corr(c_gdxj    / c_gdxj[1]    - 1)
r_sil     = calc_corr(c_sil     / c_sil[1]     - 1)
r_silj    = calc_corr(c_silj    / c_silj[1]    - 1)
r_lit     = calc_corr(c_lit     / c_lit[1]     - 1)
r_copx    = calc_corr(c_copx    / c_copx[1]    - 1)
r_ura     = calc_corr(c_ura     / c_ura[1]     - 1)

// Find highest absolute correlation — resolved at barstate.islast.
// best_cmd_ticker / best_cmd_corr / best_cmd_name are series — used only for
// display in titles, never for request.security symbol.
var string best_cmd_ticker = ""
var float  best_cmd_corr   = 0.0
var string best_cmd_name   = "None"

if barstate.islast and corr_needed
    float  best_r = 0.0
    string best_t = ""
    string best_n = ""

    if math.abs(nz(r_gold,    0)) > best_r
        best_r := math.abs(nz(r_gold,    0))
        best_t := "TVC:GOLD"
        best_n := "Gold"
    if math.abs(nz(r_silver,  0)) > best_r
        best_r := math.abs(nz(r_silver,  0))
        best_t := "TVC:SILVER"
        best_n := "Silver"
    if math.abs(nz(r_oil,     0)) > best_r
        best_r := math.abs(nz(r_oil,     0))
        best_t := "TVC:USOIL"
        best_n := "Crude Oil"
    if math.abs(nz(r_gas,     0)) > best_r
        best_r := math.abs(nz(r_gas,     0))
        best_t := "MCX:NATURALGAS1!"
        best_n := "Natural Gas"
    if math.abs(nz(r_iron,    0)) > best_r
        best_r := math.abs(nz(r_iron,    0))
        best_t := "SGX:FEF1!"
        best_n := "Iron Ore"
    if math.abs(nz(r_copper,  0)) > best_r
        best_r := math.abs(nz(r_copper,  0))
        best_t := "COMEX:HG1!"
        best_n := "Copper"
    if math.abs(nz(r_alum,    0)) > best_r
        best_r := math.abs(nz(r_alum,    0))
        best_t := "SHFE:AL1!"
        best_n := "Aluminium"
    if math.abs(nz(r_nickel,  0)) > best_r
        best_r := math.abs(nz(r_nickel,  0))
        best_t := "SHFE:NI1!"
        best_n := "Nickel"
    if math.abs(nz(r_zinc,    0)) > best_r
        best_r := math.abs(nz(r_zinc,    0))
        best_t := "SHFE:ZN1!"
        best_n := "Zinc"
    if math.abs(nz(r_lead,    0)) > best_r
        best_r := math.abs(nz(r_lead,    0))
        best_t := "SHFE:PB1!"
        best_n := "Lead"
    if math.abs(nz(r_coal,    0)) > best_r
        best_r := math.abs(nz(r_coal,    0))
        best_t := "ICEEUR:NCF1!"
        best_n := "Coal"
    if math.abs(nz(r_lithium, 0)) > best_r
        best_r := math.abs(nz(r_lithium, 0))
        best_t := "COMEX:LTH1!"
        best_n := "Lithium"
    if math.abs(nz(r_uranium, 0)) > best_r
        best_r := math.abs(nz(r_uranium, 0))
        best_t := "OTC:SRUUF"
        best_n := "Uranium"
    if math.abs(nz(r_lumber,  0)) > best_r
        best_r := math.abs(nz(r_lumber,  0))
        best_t := "CME:LBR1!"
        best_n := "Lumber"
    if math.abs(nz(r_wheat,   0)) > best_r
        best_r := math.abs(nz(r_wheat,   0))
        best_t := "PEPPERSTONE:WHEAT"
        best_n := "Wheat"
    if math.abs(nz(r_corn,    0)) > best_r
        best_r := math.abs(nz(r_corn,    0))
        best_t := "PEPPERSTONE:CORN"
        best_n := "Corn"
    if math.abs(nz(r_sugar,   0)) > best_r
        best_r := math.abs(nz(r_sugar,   0))
        best_t := "PEPPERSTONE:SUGAR"
        best_n := "Sugar"
    if math.abs(nz(r_cotton,  0)) > best_r
        best_r := math.abs(nz(r_cotton,  0))
        best_t := "PEPPERSTONE:COTTON"
        best_n := "Cotton"
    if math.abs(nz(r_plat,    0)) > best_r
        best_r := math.abs(nz(r_plat,    0))
        best_t := "TVC:PLATINUM"
        best_n := "Platinum"
    if math.abs(nz(r_pall,    0)) > best_r
        best_r := math.abs(nz(r_pall,    0))
        best_t := "TVC:PALLADIUM"
        best_n := "Palladium"
    if math.abs(nz(r_gasoline,0)) > best_r
        best_r := math.abs(nz(r_gasoline,0))
        best_t := "NYMEX:RB1!"
        best_n := "Gasoline"
    if math.abs(nz(r_heatoil, 0)) > best_r
        best_r := math.abs(nz(r_heatoil, 0))
        best_t := "NYMEX:HO1!"
        best_n := "Heating Oil"
    if math.abs(nz(r_brent,   0)) > best_r
        best_r := math.abs(nz(r_brent,   0))
        best_t := "ICEEUR:BRN1!"
        best_n := "Brent Crude"
    if math.abs(nz(r_remx,    0)) > best_r
        best_r := math.abs(nz(r_remx,    0))
        best_t := "AMEX:REMX"
        best_n := "Rare Earths"
    if math.abs(nz(r_gdx,     0)) > best_r
        best_r := math.abs(nz(r_gdx,     0))
        best_t := "AMEX:GDX"
        best_n := "Gold Miners"
    if math.abs(nz(r_gdxj,    0)) > best_r
        best_r := math.abs(nz(r_gdxj,    0))
        best_t := "AMEX:GDXJ"
        best_n := "Gold Junior Miners"
    if math.abs(nz(r_sil,     0)) > best_r
        best_r := math.abs(nz(r_sil,     0))
        best_t := "AMEX:SIL"
        best_n := "Silver Miners"
    if math.abs(nz(r_silj,    0)) > best_r
        best_r := math.abs(nz(r_silj,    0))
        best_t := "AMEX:SILJ"
        best_n := "Silver Junior Miners"
    if math.abs(nz(r_lit,     0)) > best_r
        best_r := math.abs(nz(r_lit,     0))
        best_t := "AMEX:LIT"
        best_n := "Lithium Miners"
    if math.abs(nz(r_copx,    0)) > best_r
        best_r := math.abs(nz(r_copx,    0))
        best_t := "AMEX:COPX"
        best_n := "Copper Miners"
    if math.abs(nz(r_ura,     0)) > best_r
        best_r := math.abs(nz(r_ura,     0))
        best_t := "AMEX:URA"
        best_n := "Uranium Miners"

    best_cmd_ticker := best_r >= 0.15 ? best_t : ""
    best_cmd_corr   := best_r
    best_cmd_name   := best_r >= 0.15 ? best_n : "None"

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

grp_layout = "Layout"
i_alignment = input.string("Vertical", "Table Alignment",
     options=["Vertical", "Horizontal"], group=grp_layout,
     tooltip="Vertical: all tables stacked top-right.\nHorizontal: stock top-left, sector top-right.")
i_scale = i_scale_early

grp_lb = "Lookback"
i_stk_years = input.int(0, "Stock Lookback Years",      minval=0, maxval=50, group=grp_lb,
     tooltip="0 = all available history.")
i_etf_years = input.int(0, "Sector Lookback Years",     minval=0, maxval=50, group=grp_lb,
     tooltip="0 = all available history.")
i_cmd_years = input.int(0, "Commodity Lookback Years",  minval=0, maxval=50, group=grp_lb,
     tooltip="0 = all available history.")

grp_etf = "Sector ETF Override"
i_override   = input.bool(false,   "Override Auto ETF", group=grp_etf)
i_etf_manual = input.string("XLE", "Manual ETF Ticker", group=grp_etf,
     tooltip="Include exchange prefix if needed (e.g. ASX:XEJ).")

etf_ticker = i_override ? i_etf_manual : auto_etf

grp_cmd = "Commodity Table"
i_cmd_show = i_cmd_show_early
i_cmd_override = i_cmd_override_early
i_cmd_name = input.string("Gold", "Commodity (override)",
     options=["Gold", "Silver", "Crude Oil", "Brent Crude", "Natural Gas",
              "Gasoline", "Heating Oil", "Iron Ore",
              "Copper", "Aluminium", "Nickel", "Zinc", "Lead",
              "Coal", "Lithium", "Uranium", "Lumber",
              "Wheat", "Corn", "Sugar", "Cotton",
              "Platinum", "Palladium",
              "Rare Earths", "Gold Miners", "Gold Junior Miners",
              "Silver Miners", "Silver Junior Miners",
              "Lithium Miners", "Copper Miners", "Uranium Miners"],
     group=grp_cmd,
     tooltip="Used when 'Override Auto Commodity' is on. Otherwise the recommendation is shown in the table title for reference.")

// Map display name → ticker for request.security compatibility (input string is
// simple-string compatible; series strings are not).
i_cmd_ticker = switch i_cmd_name
    "Gold"        => "TVC:GOLD"
    "Silver"      => "TVC:SILVER"
    "Crude Oil"   => "TVC:USOIL"
    "Brent Crude" => "ICEEUR:BRN1!"
    "Natural Gas" => "MCX:NATURALGAS1!"
    "Gasoline"    => "NYMEX:RB1!"
    "Heating Oil" => "NYMEX:HO1!"
    "Iron Ore"    => "SGX:FEF1!"
    "Copper"      => "COMEX:HG1!"
    "Aluminium"   => "SHFE:AL1!"
    "Nickel"      => "SHFE:NI1!"
    "Zinc"        => "SHFE:ZN1!"
    "Lead"        => "SHFE:PB1!"
    "Coal"        => "ICEEUR:NCF1!"
    "Lithium"     => "COMEX:LTH1!"
    "Uranium"     => "OTC:SRUUF"
    "Lumber"      => "CME:LBR1!"
    "Wheat"       => "PEPPERSTONE:WHEAT"
    "Corn"        => "PEPPERSTONE:CORN"
    "Sugar"       => "PEPPERSTONE:SUGAR"
    "Cotton"      => "PEPPERSTONE:COTTON"
    "Platinum"    => "TVC:PLATINUM"
    "Palladium"   => "TVC:PALLADIUM"
    "Rare Earths"          => "AMEX:REMX"
    "Gold Miners"          => "AMEX:GDX"
    "Gold Junior Miners"   => "AMEX:GDXJ"
    "Silver Miners"        => "AMEX:SIL"
    "Silver Junior Miners" => "AMEX:SILJ"
    "Lithium Miners"       => "AMEX:LIT"
    "Copper Miners"        => "AMEX:COPX"
    "Uranium Miners"       => "AMEX:URA"
    => "TVC:GOLD"

grp_col = "Colours"
i_col_pos_bg  = input.color(color.new(#00C853, 0),  "Positive — Full Intensity (≥5%)", group=grp_col,
     tooltip="Colour for cells at or beyond +5%. Cells closer to 0% fade toward the header background.")
i_col_neg_bg  = input.color(color.new(#D50000, 0),  "Negative — Full Intensity (≤-5%)",group=grp_col,
     tooltip="Colour for cells at or below -5%. Cells closer to 0% fade toward the header background.")
i_col_pos_txt = input.color(color.new(#CCFF90, 0),  "Positive — Text",               group=grp_col)
i_col_neg_txt = input.color(color.new(#FF8A80, 0),  "Negative — Text",               group=grp_col)
i_col_hdr_bg  = input.color(color.new(#0D1B24, 85), "Header — Background",           group=grp_col)
i_col_hdr_fg  = input.color(color.new(#90A4AE, 0),  "Header — Text",                 group=grp_col)
i_col_ttl_bg  = input.color(color.new(#0A2233, 90), "Title — Background",            group=grp_col)
i_col_ttl_stk = input.color(color.new(#29B6F6, 0),  "Title — Stock Text",            group=grp_col)
i_col_ttl_etf = input.color(color.new(#66BB6A, 0),  "Title — ETF Text",              group=grp_col)
i_col_ttl_cmd = input.color(color.new(#CE93D8, 0),  "Title — Commodity Text",        group=grp_col)
i_col_sep     = input.color(color.new(#0A1520, 95), "Separator Row",                 group=grp_col)
i_col_cur_bg  = input.color(color.new(#F57F17, 10), "Current Period — Highlight",    group=grp_col)
i_col_cur_fg  = input.color(color.new(#FFD54F, 0),  "Current Period — Text",         group=grp_col)

// ─────────────────────────────────────────────────────────────────────────────
// DERIVED CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

MONTH_NAMES = array.from("JAN","FEB","MAR","APR","MAY","JUN",
                          "JUL","AUG","SEP","OCT","NOV","DEC")

is_annual   = i_scale     == "Annual"
is_vertical = i_alignment == "Vertical"

sector_str   = sector_raw       != "" ? sector_raw       : "Unknown Sector"
industry_str = syminfo.industry != "" ? syminfo.industry : "Unknown Industry"

cur_mo      = month
cur_mo_name = array.get(MONTH_NAMES, cur_mo - 1)
cur_dom     = dayofmonth
cur_yr      = year

stk_cutoff = i_stk_years > 0 ? cur_yr - i_stk_years : 0
etf_cutoff = i_etf_years > 0 ? cur_yr - i_etf_years : 0
cmd_cutoff = i_cmd_years > 0 ? cur_yr - i_cmd_years : 0

cur_ann_col = cur_mo  - 1
cur_mo_col  = cur_dom - 1

days_in_month(m) =>
    m == 2 ? 29 : (m == 4 or m == 6 or m == 9 or m == 11) ? 30 : 31

cur_mo_days = days_in_month(cur_mo)

// ─────────────────────────────────────────────────────────────────────────────
// FORMAT + COLOUR HELPERS
// ─────────────────────────────────────────────────────────────────────────────

f_pct(v) =>
    p = math.round(v * 10000) / 100
    (p >= 0 ? "+" : "") + str.tostring(p, "#.##") + "%"

f_pct_sm(v) =>
    p = math.round(v * 1000) / 10
    (p >= 0 ? "+" : "") + str.tostring(p, "#.#") + "%"

// Intensity-scaled background colour.
// Maps |v| from 0 → cap_pct linearly to alpha 90 → 0 (faded → full).
intensity_bg(v, pos_c, neg_c, base_c, cap_pct) =>
    intensity = math.min(math.abs(v) / cap_pct, 1.0)
    alpha     = int(math.round((1.0 - intensity) * 90))
    v >= 0 ? color.new(pos_c, alpha) : color.new(neg_c, alpha)

// ─────────────────────────────────────────────────────────────────────────────
// ACCUMULATE — STOCK
// ─────────────────────────────────────────────────────────────────────────────

isNewMonth = ta.change(time("M")) != 0
isNewDay   = ta.change(time("D")) != 0

var float[] ann_stk_total = array.new_float(12, 0.0)
var int[]   ann_stk_count = array.new_int(12, 0)
var float   ann_stk_open  = na

if isNewMonth
    if not na(ann_stk_open) and not na(close[1])
        if stk_cutoff == 0 or year[1] > stk_cutoff
            m   = month[1] - 1
            ret = (close[1] / ann_stk_open) - 1.0
            array.set(ann_stk_total, m, array.get(ann_stk_total, m) + ret)
            array.set(ann_stk_count, m, array.get(ann_stk_count, m) + 1)
    ann_stk_open := close
else
    if na(ann_stk_open)
        ann_stk_open := close

var float[] mo_stk_total = array.new_float(31, 0.0)
var int[]   mo_stk_count = array.new_int(31, 0)

if isNewDay and month[1] == cur_mo and not na(close[1]) and not na(close[2])
    if stk_cutoff == 0 or year[1] > stk_cutoff
        d_idx = dayofmonth[1] - 1
        if d_idx >= 0 and d_idx < 31
            ret = (close[1] / close[2]) - 1.0
            array.set(mo_stk_total, d_idx, array.get(mo_stk_total, d_idx) + ret)
            array.set(mo_stk_count, d_idx, array.get(mo_stk_count, d_idx) + 1)

// ─────────────────────────────────────────────────────────────────────────────
// ACCUMULATE — ETF + COMMODITY
// ─────────────────────────────────────────────────────────────────────────────

ann_acc(cutoff_yr) =>
    var float[] _tot  = array.new_float(12, 0.0)
    var int[]   _cnt  = array.new_int(12, 0)
    var float   _open = na
    // Skip per-bar work when the user is on Monthly scale — the annual table
    // isn't drawn so accumulation is dead weight.
    if is_annual_early
        _new = ta.change(time("M")) != 0
        if _new
            if not na(_open) and not na(close[1])
                if cutoff_yr == 0 or year[1] > cutoff_yr
                    _m   = month[1] - 1
                    _ret = (close[1] / _open) - 1.0
                    array.set(_tot, _m, array.get(_tot, _m) + _ret)
                    array.set(_cnt, _m, array.get(_cnt, _m) + 1)
            _open := close
        else
            if na(_open)
                _open := close
    [array.get(_tot,0), array.get(_tot,1), array.get(_tot,2), array.get(_tot,3),
     array.get(_tot,4), array.get(_tot,5), array.get(_tot,6), array.get(_tot,7),
     array.get(_tot,8), array.get(_tot,9), array.get(_tot,10),array.get(_tot,11),
     array.get(_cnt,0), array.get(_cnt,1), array.get(_cnt,2), array.get(_cnt,3),
     array.get(_cnt,4), array.get(_cnt,5), array.get(_cnt,6), array.get(_cnt,7),
     array.get(_cnt,8), array.get(_cnt,9), array.get(_cnt,10),array.get(_cnt,11)]

mo_acc(cutoff_yr) =>
    var float[] _tot  = array.new_float(31, 0.0)
    var int[]   _cnt  = array.new_int(31, 0)
    // Skip per-bar work when the user is on Annual scale.
    if not is_annual_early
        _cur_mo   = month
        _isNewDay = ta.change(time("D")) != 0
        if _isNewDay and month[1] == _cur_mo and not na(close[1]) and not na(close[2])
            if cutoff_yr == 0 or year[1] > cutoff_yr
                _d = dayofmonth[1] - 1
                if _d >= 0 and _d < 31
                    _ret = (close[1] / close[2]) - 1.0
                    array.set(_tot, _d, array.get(_tot, _d) + _ret)
                    array.set(_cnt, _d, array.get(_cnt, _d) + 1)
    [array.get(_tot,0),  array.get(_tot,1),  array.get(_tot,2),  array.get(_tot,3),
     array.get(_tot,4),  array.get(_tot,5),  array.get(_tot,6),  array.get(_tot,7),
     array.get(_tot,8),  array.get(_tot,9),  array.get(_tot,10), array.get(_tot,11),
     array.get(_tot,12), array.get(_tot,13), array.get(_tot,14), array.get(_tot,15),
     array.get(_cnt,0),  array.get(_cnt,1),  array.get(_cnt,2),  array.get(_cnt,3),
     array.get(_cnt,4),  array.get(_cnt,5),  array.get(_cnt,6),  array.get(_cnt,7),
     array.get(_cnt,8),  array.get(_cnt,9),  array.get(_cnt,10), array.get(_cnt,11),
     array.get(_cnt,12), array.get(_cnt,13), array.get(_cnt,14), array.get(_cnt,15)]

mo_acc2(cutoff_yr) =>
    var float[] _tot  = array.new_float(31, 0.0)
    var int[]   _cnt  = array.new_int(31, 0)
    if not is_annual_early
        _cur_mo   = month
        _isNewDay = ta.change(time("D")) != 0
        if _isNewDay and month[1] == _cur_mo and not na(close[1]) and not na(close[2])
            if cutoff_yr == 0 or year[1] > cutoff_yr
                _d = dayofmonth[1] - 1
                if _d >= 0 and _d < 31
                    _ret = (close[1] / close[2]) - 1.0
                    array.set(_tot, _d, array.get(_tot, _d) + _ret)
                    array.set(_cnt, _d, array.get(_cnt, _d) + 1)
    [array.get(_tot,16),array.get(_tot,17),array.get(_tot,18),array.get(_tot,19),
     array.get(_tot,20),array.get(_tot,21),array.get(_tot,22),array.get(_tot,23),
     array.get(_tot,24),array.get(_tot,25),array.get(_tot,26),array.get(_tot,27),
     array.get(_tot,28),array.get(_tot,29),array.get(_tot,30),
     array.get(_cnt,16),array.get(_cnt,17),array.get(_cnt,18),array.get(_cnt,19),
     array.get(_cnt,20),array.get(_cnt,21),array.get(_cnt,22),array.get(_cnt,23),
     array.get(_cnt,24),array.get(_cnt,25),array.get(_cnt,26),array.get(_cnt,27),
     array.get(_cnt,28),array.get(_cnt,29),array.get(_cnt,30)]

// ETF accumulators
[ea0,ea1,ea2,ea3,ea4,ea5,ea6,ea7,ea8,ea9,ea10,ea11,
 ec0,ec1,ec2,ec3,ec4,ec5,ec6,ec7,ec8,ec9,ec10,ec11] =
     request.security(etf_ticker, "D", ann_acc(i_etf_years > 0 ? year - i_etf_years : 0),
     lookahead=barmerge.lookahead_off)

[em0,em1,em2,em3,em4,em5,em6,em7,em8,em9,em10,em11,em12,em13,em14,em15,
 emc0,emc1,emc2,emc3,emc4,emc5,emc6,emc7,emc8,emc9,emc10,emc11,emc12,emc13,emc14,emc15] =
     request.security(etf_ticker, "D", mo_acc(i_etf_years > 0 ? year - i_etf_years : 0),
     lookahead=barmerge.lookahead_off)

[em16,em17,em18,em19,em20,em21,em22,em23,em24,em25,em26,em27,em28,em29,em30,
 emc16,emc17,emc18,emc19,emc20,emc21,emc22,emc23,emc24,emc25,emc26,emc27,emc28,emc29,emc30] =
     request.security(etf_ticker, "D", mo_acc2(i_etf_years > 0 ? year - i_etf_years : 0),
     lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// COMMODITY SEASONALITY — INLINE ACCUMULATORS
// ─────────────────────────────────────────────────────────────────────────────
// Per-commodity request.security calls would push us over the script-wide
// 40-call cap (20 commodities × 3 acc functions = 60). Instead we run the
// accumulator inline against each commodity's already-fetched daily close
// (c_gold, c_silver, …). Each call site has its own var arrays — Pine ties
// var state to the call site, so the 20 commodity accumulators are
// independent.
//
// IMPORTANT: this assumes the chart timeframe is Daily. The accumulator uses
// chart bar context (month, dayofmonth, year, isNewMonth/Day) so on Weekly+
// charts the commodity table will under-sample. The ETF table is unaffected
// — it still uses request.security("D", ann_acc(...)).
accumulate_cmd_seasonality(price, cutoff_yr, cur_mo_in) =>
    var float[] _ann_t = array.new_float(12, 0.0)
    var int[]   _ann_c = array.new_int(12, 0)
    var float[] _mo_t  = array.new_float(31, 0.0)
    var int[]   _mo_c  = array.new_int(31, 0)
    var float   _open  = na

    // Skip everything when the commodity table isn't needed (hidden, or
    // sector not in the allowed mining/energy list). Using the hoisted
    // global isNewMonth/isNewDay avoids 31× redundant ta.change calls.
    if cmd_needed
        if is_annual_early
            if isNewMonth
                if not na(_open) and not na(price[1])
                    if cutoff_yr == 0 or year[1] > cutoff_yr
                        _m   = month[1] - 1
                        _ret = (price[1] / _open) - 1.0
                        array.set(_ann_t, _m, array.get(_ann_t, _m) + _ret)
                        array.set(_ann_c, _m, array.get(_ann_c, _m) + 1)
                _open := price
            else
                if na(_open)
                    _open := price
        else
            if isNewDay and month[1] == cur_mo_in and not na(price[1]) and not na(price[2])
                if cutoff_yr == 0 or year[1] > cutoff_yr
                    _d = dayofmonth[1] - 1
                    if _d >= 0 and _d < 31
                        _ret = (price[1] / price[2]) - 1.0
                        array.set(_mo_t, _d, array.get(_mo_t, _d) + _ret)
                        array.set(_mo_c, _d, array.get(_mo_c, _d) + 1)

    [_ann_t, _ann_c, _mo_t, _mo_c]

// One call per commodity — each call site keeps its own var state.
[gold_ann_t,    gold_ann_c,    gold_mo_t,    gold_mo_c]    = accumulate_cmd_seasonality(c_gold,    cmd_cutoff, cur_mo)
[silver_ann_t,  silver_ann_c,  silver_mo_t,  silver_mo_c]  = accumulate_cmd_seasonality(c_silver,  cmd_cutoff, cur_mo)
[oil_ann_t,     oil_ann_c,     oil_mo_t,     oil_mo_c]     = accumulate_cmd_seasonality(c_oil,     cmd_cutoff, cur_mo)
[gas_ann_t,     gas_ann_c,     gas_mo_t,     gas_mo_c]     = accumulate_cmd_seasonality(c_gas,     cmd_cutoff, cur_mo)
[iron_ann_t,    iron_ann_c,    iron_mo_t,    iron_mo_c]    = accumulate_cmd_seasonality(c_iron,    cmd_cutoff, cur_mo)
[copper_ann_t,  copper_ann_c,  copper_mo_t,  copper_mo_c]  = accumulate_cmd_seasonality(c_copper,  cmd_cutoff, cur_mo)
[alum_ann_t,    alum_ann_c,    alum_mo_t,    alum_mo_c]    = accumulate_cmd_seasonality(c_alum,    cmd_cutoff, cur_mo)
[nickel_ann_t,  nickel_ann_c,  nickel_mo_t,  nickel_mo_c]  = accumulate_cmd_seasonality(c_nickel,  cmd_cutoff, cur_mo)
[zinc_ann_t,    zinc_ann_c,    zinc_mo_t,    zinc_mo_c]    = accumulate_cmd_seasonality(c_zinc,    cmd_cutoff, cur_mo)
[lead_ann_t,    lead_ann_c,    lead_mo_t,    lead_mo_c]    = accumulate_cmd_seasonality(c_lead,    cmd_cutoff, cur_mo)
[coal_ann_t,    coal_ann_c,    coal_mo_t,    coal_mo_c]    = accumulate_cmd_seasonality(c_coal,    cmd_cutoff, cur_mo)
[lithium_ann_t, lithium_ann_c, lithium_mo_t, lithium_mo_c] = accumulate_cmd_seasonality(c_lithium, cmd_cutoff, cur_mo)
[uranium_ann_t, uranium_ann_c, uranium_mo_t, uranium_mo_c] = accumulate_cmd_seasonality(c_uranium, cmd_cutoff, cur_mo)
[lumber_ann_t,  lumber_ann_c,  lumber_mo_t,  lumber_mo_c]  = accumulate_cmd_seasonality(c_lumber,  cmd_cutoff, cur_mo)
[wheat_ann_t,   wheat_ann_c,   wheat_mo_t,   wheat_mo_c]   = accumulate_cmd_seasonality(c_wheat,   cmd_cutoff, cur_mo)
[corn_ann_t,    corn_ann_c,    corn_mo_t,    corn_mo_c]    = accumulate_cmd_seasonality(c_corn,    cmd_cutoff, cur_mo)
[sugar_ann_t,   sugar_ann_c,   sugar_mo_t,   sugar_mo_c]   = accumulate_cmd_seasonality(c_sugar,   cmd_cutoff, cur_mo)
[cotton_ann_t,  cotton_ann_c,  cotton_mo_t,  cotton_mo_c]  = accumulate_cmd_seasonality(c_cotton,  cmd_cutoff, cur_mo)
[plat_ann_t,    plat_ann_c,    plat_mo_t,    plat_mo_c]    = accumulate_cmd_seasonality(c_plat,    cmd_cutoff, cur_mo)
[pall_ann_t,    pall_ann_c,    pall_mo_t,    pall_mo_c]    = accumulate_cmd_seasonality(c_pall,    cmd_cutoff, cur_mo)
[gaso_ann_t,    gaso_ann_c,    gaso_mo_t,    gaso_mo_c]    = accumulate_cmd_seasonality(c_gasoline,cmd_cutoff, cur_mo)
[heat_ann_t,    heat_ann_c,    heat_mo_t,    heat_mo_c]    = accumulate_cmd_seasonality(c_heatoil, cmd_cutoff, cur_mo)
[brent_ann_t,   brent_ann_c,   brent_mo_t,   brent_mo_c]   = accumulate_cmd_seasonality(c_brent,   cmd_cutoff, cur_mo)
[remx_ann_t,    remx_ann_c,    remx_mo_t,    remx_mo_c]    = accumulate_cmd_seasonality(c_remx,    cmd_cutoff, cur_mo)
[gdx_ann_t,     gdx_ann_c,     gdx_mo_t,     gdx_mo_c]     = accumulate_cmd_seasonality(c_gdx,     cmd_cutoff, cur_mo)
[gdxj_ann_t,    gdxj_ann_c,    gdxj_mo_t,    gdxj_mo_c]    = accumulate_cmd_seasonality(c_gdxj,    cmd_cutoff, cur_mo)
[sil_ann_t,     sil_ann_c,     sil_mo_t,     sil_mo_c]     = accumulate_cmd_seasonality(c_sil,     cmd_cutoff, cur_mo)
[silj_ann_t,    silj_ann_c,    silj_mo_t,    silj_mo_c]    = accumulate_cmd_seasonality(c_silj,    cmd_cutoff, cur_mo)
[lit_ann_t,     lit_ann_c,     lit_mo_t,     lit_mo_c]     = accumulate_cmd_seasonality(c_lit,     cmd_cutoff, cur_mo)
[copx_ann_t,    copx_ann_c,    copx_mo_t,    copx_mo_c]    = accumulate_cmd_seasonality(c_copx,    cmd_cutoff, cur_mo)
[ura_ann_t,     ura_ann_c,     ura_mo_t,     ura_mo_c]     = accumulate_cmd_seasonality(c_ura,     cmd_cutoff, cur_mo)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW HELPERS
// ─────────────────────────────────────────────────────────────────────────────

// Title row: single merged cell spanning the full table width so col 0 isn't
// forced wide by the title text.
draw_title_row(tbl, row, title, t_bg, t_fg, last_c) =>
    table.cell(tbl, 0, row, title,
         bgcolor=t_bg, text_color=t_fg, text_size=size.small, text_halign=text.align_center)
    for _c = 1 to last_c
        table.cell(tbl, _c, row, "", bgcolor=t_bg, text_color=t_fg, text_size=size.small)
    table.merge_cells(tbl, 0, row, last_c, row)

// Annual header row (month names)
draw_ann_hdr(tbl, row, cur_col, h_bg, h_fg, c_bg, c_fg) =>
    table.cell(tbl, 0, row, "AVG",
         bgcolor=h_bg, text_color=h_fg, text_size=size.small, text_halign=text.align_left)
    for _i = 0 to 11
        _is_cur = (_i == cur_col)
        table.cell(tbl, _i + 1, row, array.get(MONTH_NAMES, _i),
             bgcolor=_is_cur ? c_bg : h_bg,
             text_color=_is_cur ? c_fg : h_fg,
             text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 13, row, "TOTAL",
         bgcolor=h_bg, text_color=h_fg, text_size=size.small, text_halign=text.align_center)

// Annual value row with intensity-scaled colours
draw_ann_row(tbl, row, avg, tot, yrs, cur_col, pos_c, neg_c, pos_txt, neg_txt, h_bg, s_fg, c_bg, c_fg) =>
    table.cell(tbl, 0, row, str.tostring(yrs) + " yrs",
         bgcolor=h_bg, text_color=s_fg, text_size=size.small, text_halign=text.align_left)
    for _i = 0 to 11
        _v      = array.get(avg, _i)
        _is_cur = (_i == cur_col)
        _bg     = _is_cur ? c_bg : intensity_bg(_v, pos_c, neg_c, h_bg, 0.05)
        _fg     = _is_cur ? c_fg : (_v >= 0 ? pos_txt : neg_txt)
        table.cell(tbl, _i + 1, row, f_pct(_v),
             bgcolor=_bg, text_color=_fg,
             text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 13, row, f_pct(tot),
         bgcolor=intensity_bg(tot, pos_c, neg_c, h_bg, 0.05),
         text_color=tot >= 0 ? pos_txt : neg_txt,
         text_size=size.small, text_halign=text.align_center)

// Monthly title row — merged into a single cell so col 0 stays narrow.
draw_mo_title(tbl, row, title, t_bg, t_fg, lc) =>
    table.cell(tbl, 0, row, title,
         bgcolor=t_bg, text_color=t_fg, text_size=size.small, text_halign=text.align_center)
    for _c = 1 to lc
        table.cell(tbl, _c, row, "", bgcolor=t_bg, text_color=t_fg, text_size=size.small)
    table.merge_cells(tbl, 0, row, lc, row)

// Monthly header row
draw_mo_hdr(tbl, row, nc, lc, cur_col, h_bg, h_fg, c_bg, c_fg) =>
    table.cell(tbl, 0, row, "AVG",
         bgcolor=h_bg, text_color=h_fg, text_size=size.tiny, text_halign=text.align_left)
    for _d = 0 to nc - 1
        _is_cur = (_d == cur_col)
        table.cell(tbl, _d + 1, row, str.tostring(_d + 1),
             bgcolor=_is_cur ? c_bg : h_bg,
             text_color=_is_cur ? c_fg : h_fg,
             text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, lc, row, "TOT",
         bgcolor=h_bg, text_color=h_fg, text_size=size.tiny, text_halign=text.align_center)

// Monthly value row with intensity-scaled colours
draw_mo_vals(tbl, row, avg, cnt, tot, yrs, nc, lc, cur_col, pos_c, neg_c, pos_txt, neg_txt, h_bg, s_fg, d_bg, d_fg, c_bg, c_fg) =>
    table.cell(tbl, 0, row, str.tostring(yrs) + " yrs",
         bgcolor=h_bg, text_color=s_fg, text_size=size.tiny, text_halign=text.align_left)
    for _d = 0 to nc - 1
        _v      = array.get(avg, _d)
        _c      = array.get(cnt, _d)
        _is_cur = (_d == cur_col)
        _tx     = _c > 0 ? f_pct_sm(_v) : "-"
        _bg     = _is_cur ? c_bg : (_c > 0 ? intensity_bg(_v, pos_c, neg_c, h_bg, 0.05) : d_bg)
        _fg     = _is_cur ? c_fg : (_c > 0 ? (_v >= 0 ? pos_txt : neg_txt) : d_fg)
        table.cell(tbl, _d + 1, row, _tx,
             bgcolor=_bg, text_color=_fg,
             text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, lc, row, f_pct_sm(tot),
         bgcolor=intensity_bg(tot, pos_c, neg_c, h_bg, 0.05),
         text_color=tot >= 0 ? pos_txt : neg_txt,
         text_size=size.tiny, text_halign=text.align_center)

// Separator row
draw_sep(tbl, row, last_c, sep_c) =>
    for _c = 0 to last_c
        table.cell(tbl, _c, row, "", bgcolor=sep_c, text_color=sep_c, text_size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// RENDER — LAST BAR ONLY
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast

    hdr_bg   = i_col_hdr_bg
    hdr_fg   = i_col_hdr_fg
    sub_fg   = color.new(#607D8B, 0)
    ttl_bg   = i_col_ttl_bg
    dim_bg   = color.new(#0D1B24, 70)
    dim_fg   = color.new(#455A64, 0)

    stk_lb_str = i_stk_years > 0 ? str.tostring(i_stk_years) + " yr lookback" : "all history"
    etf_lb_str = i_etf_years > 0 ? str.tostring(i_etf_years) + " yr lookback" : "all history"
    cmd_lb_str = i_cmd_years > 0 ? str.tostring(i_cmd_years) + " yr lookback" : "all history"

    // ── Auto vs Override resolution ──────────────────────────────────────────
    // Default: load the highest-correlated commodity (best_cmd_ticker resolved
    // at barstate.islast). Override: load i_cmd_ticker from the dropdown.
    // If auto is on but no commodity passes the 0.15 correlation threshold,
    // fall back to the dropdown selection so the table still has data.
    rec_avail = best_cmd_ticker != ""
    sel_ticker = i_cmd_override ? i_cmd_ticker :
         rec_avail ? best_cmd_ticker : i_cmd_ticker
    sel_name = i_cmd_override ? i_cmd_name :
         rec_avail ? best_cmd_name : i_cmd_name
    mode_label = i_cmd_override ? "manual" :
         rec_avail ? "auto" : "auto-fallback"

    // Title suffix indicating mode. In manual (override) mode the
    // auto-recommendation correlation basket is skipped entirely for speed,
    // so no auto-rec tag is shown.
    rec_suffix = i_cmd_override ? "  [manual]" :
         rec_avail ? "  [auto: r=" +
              str.tostring(math.round(best_cmd_corr * 100) / 100, "#.##") + "]" :
         "  [auto-fallback; no strong correlation]"

    allowed_sectors = array.from("Energy", "Energy Minerals", "Oil & Gas", "Oil, Gas & Consumable Fuels", "Materials", "Non-Energy Minerals", "Minerals", "Mining", "Metals & Mining", "Gold", "Steel")

    is_allowed_sector = array.includes(allowed_sectors, sector_raw)

    show_cmd = i_cmd_show and is_allowed_sector

    // ── Reconstruct ETF arrays from request.security tuples ──────────────────
    // Note: float() cast on first arg forces array.from to infer array<float>
    // (without it, Pine v5 sometimes returns array<unknown> on long arg lists).

    float[] ann_etf_t = array.from(float(ea0),ea1,ea2,ea3,ea4,ea5,ea6,ea7,ea8,ea9,ea10,ea11)
    int[]   ann_etf_c = array.from(int(math.round(ec0)),int(math.round(ec1)),int(math.round(ec2)),
         int(math.round(ec3)),int(math.round(ec4)),int(math.round(ec5)),int(math.round(ec6)),
         int(math.round(ec7)),int(math.round(ec8)),int(math.round(ec9)),int(math.round(ec10)),
         int(math.round(ec11)))

    float[] mo_etf_t = array.from(float(em0),em1,em2,em3,em4,em5,em6,em7,em8,em9,em10,em11,
         em12,em13,em14,em15,em16,em17,em18,em19,em20,em21,em22,em23,em24,em25,em26,em27,em28,em29,em30)
    int[]   mo_etf_c = array.from(int(math.round(emc0)),int(math.round(emc1)),int(math.round(emc2)),
         int(math.round(emc3)),int(math.round(emc4)),int(math.round(emc5)),int(math.round(emc6)),
         int(math.round(emc7)),int(math.round(emc8)),int(math.round(emc9)),int(math.round(emc10)),
         int(math.round(emc11)),int(math.round(emc12)),int(math.round(emc13)),int(math.round(emc14)),
         int(math.round(emc15)),int(math.round(emc16)),int(math.round(emc17)),int(math.round(emc18)),
         int(math.round(emc19)),int(math.round(emc20)),int(math.round(emc21)),int(math.round(emc22)),
         int(math.round(emc23)),int(math.round(emc24)),int(math.round(emc25)),int(math.round(emc26)),
         int(math.round(emc27)),int(math.round(emc28)),int(math.round(emc29)),int(math.round(emc30)))

    // ── Pick commodity arrays from inline accumulators based on sel_ticker ──
    // Each gold_*/silver_*/… array has been accumulated inline above. Ternary
    // on array references is supported in Pine v5 — the result is whichever
    // array reference matches the resolved sel_ticker.

    ann_cmd_t = switch sel_ticker
        "TVC:GOLD"           => gold_ann_t
        "TVC:SILVER"         => silver_ann_t
        "TVC:USOIL"          => oil_ann_t
        "MCX:NATURALGAS1!"   => gas_ann_t
        "SGX:FEF1!"          => iron_ann_t
        "COMEX:HG1!"       => copper_ann_t
        "SHFE:AL1!"    => alum_ann_t
        "SHFE:NI1!"       => nickel_ann_t
        "SHFE:ZN1!"         => zinc_ann_t
        "SHFE:PB1!"         => lead_ann_t
        "ICEEUR:NCF1!"       => coal_ann_t
        "COMEX:LTH1!"        => lithium_ann_t
        "OTC:SRUUF"          => uranium_ann_t
        "CME:LBR1!"          => lumber_ann_t
        "PEPPERSTONE:WHEAT"  => wheat_ann_t
        "PEPPERSTONE:CORN"   => corn_ann_t
        "PEPPERSTONE:SUGAR"  => sugar_ann_t
        "PEPPERSTONE:COTTON" => cotton_ann_t
        "TVC:PLATINUM"       => plat_ann_t
        "TVC:PALLADIUM"      => pall_ann_t
        "NYMEX:RB1!"         => gaso_ann_t
        "NYMEX:HO1!"         => heat_ann_t
        "ICEEUR:BRN1!"       => brent_ann_t
        "AMEX:REMX"          => remx_ann_t
        "AMEX:GDX"           => gdx_ann_t
        "AMEX:GDXJ"          => gdxj_ann_t
        "AMEX:SIL"           => sil_ann_t
        "AMEX:SILJ"          => silj_ann_t
        "AMEX:LIT"           => lit_ann_t
        "AMEX:COPX"          => copx_ann_t
        "AMEX:URA"           => ura_ann_t
        => gold_ann_t

    ann_cmd_c = switch sel_ticker
        "TVC:GOLD"           => gold_ann_c
        "TVC:SILVER"         => silver_ann_c
        "TVC:USOIL"          => oil_ann_c
        "MCX:NATURALGAS1!"   => gas_ann_c
        "SGX:FEF1!"          => iron_ann_c
        "COMEX:HG1!"       => copper_ann_c
        "SHFE:AL1!"    => alum_ann_c
        "SHFE:NI1!"       => nickel_ann_c
        "SHFE:ZN1!"         => zinc_ann_c
        "SHFE:PB1!"         => lead_ann_c
        "ICEEUR:NCF1!"       => coal_ann_c
        "COMEX:LTH1!"        => lithium_ann_c
        "OTC:SRUUF"          => uranium_ann_c
        "CME:LBR1!"          => lumber_ann_c
        "PEPPERSTONE:WHEAT"  => wheat_ann_c
        "PEPPERSTONE:CORN"   => corn_ann_c
        "PEPPERSTONE:SUGAR"  => sugar_ann_c
        "PEPPERSTONE:COTTON" => cotton_ann_c
        "TVC:PLATINUM"       => plat_ann_c
        "TVC:PALLADIUM"      => pall_ann_c
        "NYMEX:RB1!"         => gaso_ann_c
        "NYMEX:HO1!"         => heat_ann_c
        "ICEEUR:BRN1!"       => brent_ann_c
        "AMEX:REMX"          => remx_ann_c
        "AMEX:GDX"           => gdx_ann_c
        "AMEX:GDXJ"          => gdxj_ann_c
        "AMEX:SIL"           => sil_ann_c
        "AMEX:SILJ"          => silj_ann_c
        "AMEX:LIT"           => lit_ann_c
        "AMEX:COPX"          => copx_ann_c
        "AMEX:URA"           => ura_ann_c
        => gold_ann_c

    mo_cmd_t  = switch sel_ticker
        "TVC:GOLD"           => gold_mo_t
        "TVC:SILVER"         => silver_mo_t
        "TVC:USOIL"          => oil_mo_t
        "MCX:NATURALGAS1!"   => gas_mo_t
        "SGX:FEF1!"          => iron_mo_t
        "COMEX:HG1!"       => copper_mo_t
        "SHFE:AL1!"    => alum_mo_t
        "SHFE:NI1!"       => nickel_mo_t
        "SHFE:ZN1!"         => zinc_mo_t
        "SHFE:PB1!"         => lead_mo_t
        "ICEEUR:NCF1!"       => coal_mo_t
        "COMEX:LTH1!"        => lithium_mo_t
        "OTC:SRUUF"          => uranium_mo_t
        "CME:LBR1!"          => lumber_mo_t
        "PEPPERSTONE:WHEAT"  => wheat_mo_t
        "PEPPERSTONE:CORN"   => corn_mo_t
        "PEPPERSTONE:SUGAR"  => sugar_mo_t
        "PEPPERSTONE:COTTON" => cotton_mo_t
        "TVC:PLATINUM"       => plat_mo_t
        "TVC:PALLADIUM"      => pall_mo_t
        "NYMEX:RB1!"         => gaso_mo_t
        "NYMEX:HO1!"         => heat_mo_t
        "ICEEUR:BRN1!"       => brent_mo_t
        "AMEX:REMX"          => remx_mo_t
        "AMEX:GDX"           => gdx_mo_t
        "AMEX:GDXJ"          => gdxj_mo_t
        "AMEX:SIL"           => sil_mo_t
        "AMEX:SILJ"          => silj_mo_t
        "AMEX:LIT"           => lit_mo_t
        "AMEX:COPX"          => copx_mo_t
        "AMEX:URA"           => ura_mo_t
        => gold_mo_t

    mo_cmd_c  = switch sel_ticker
        "TVC:GOLD"           => gold_mo_c
        "TVC:SILVER"         => silver_mo_c
        "TVC:USOIL"          => oil_mo_c
        "MCX:NATURALGAS1!"   => gas_mo_c
        "SGX:FEF1!"          => iron_mo_c
        "COMEX:HG1!"       => copper_mo_c
        "SHFE:AL1!"    => alum_mo_c
        "SHFE:NI1!"       => nickel_mo_c
        "SHFE:ZN1!"         => zinc_mo_c
        "SHFE:PB1!"         => lead_mo_c
        "ICEEUR:NCF1!"       => coal_mo_c
        "COMEX:LTH1!"        => lithium_mo_c
        "OTC:SRUUF"          => uranium_mo_c
        "CME:LBR1!"          => lumber_mo_c
        "PEPPERSTONE:WHEAT"  => wheat_mo_c
        "PEPPERSTONE:CORN"   => corn_mo_c
        "PEPPERSTONE:SUGAR"  => sugar_mo_c
        "PEPPERSTONE:COTTON" => cotton_mo_c
        "TVC:PLATINUM"       => plat_mo_c
        "TVC:PALLADIUM"      => pall_mo_c
        "NYMEX:RB1!"         => gaso_mo_c
        "NYMEX:HO1!"         => heat_mo_c
        "ICEEUR:BRN1!"       => brent_mo_c
        "AMEX:REMX"          => remx_mo_c
        "AMEX:GDX"           => gdx_mo_c
        "AMEX:GDXJ"          => gdxj_mo_c
        "AMEX:SIL"           => sil_mo_c
        "AMEX:SILJ"          => silj_mo_c
        "AMEX:LIT"           => lit_mo_c
        "AMEX:COPX"          => copx_mo_c
        "AMEX:URA"           => ura_mo_c
        => gold_mo_c

    // ══════════════════════════════════════════════════════════════════════════
    // BRANCH A — ANNUAL
    // ══════════════════════════════════════════════════════════════════════════

    if is_annual

        float[] stkAvg = array.new_float(12, 0.0)
        float[] etfAvg = array.new_float(12, 0.0)
        float[] cmdAvg = array.new_float(12, 0.0)
        int   stkYrs = 0
        int   etfYrs = 0
        int   cmdYrs = 0
        float stkTot = 0.0
        float etfTot = 0.0
        float cmdTot = 0.0

        for i = 0 to 11
            _sc = array.get(ann_stk_count, i)
            _sa = _sc > 0 ? array.get(ann_stk_total, i) / _sc : 0.0
            array.set(stkAvg, i, _sa)
            stkTot += _sa
            if _sc > stkYrs
                stkYrs := _sc

            _ec = array.get(ann_etf_c, i)
            _ea = _ec > 0 ? array.get(ann_etf_t, i) / _ec : 0.0
            array.set(etfAvg, i, _ea)
            etfTot += _ea
            if _ec > etfYrs
                etfYrs := _ec

            if show_cmd
                _cc = array.get(ann_cmd_c, i)
                _ca = _cc > 0 ? array.get(ann_cmd_t, i) / _cc : 0.0
                array.set(cmdAvg, i, _ca)
                cmdTot += _ca
                if _cc > cmdYrs
                    cmdYrs := _cc

        stk_title = "STOCK  ·  " + syminfo.ticker + "  ·  " + industry_str + "  ·  " + str.tostring(stkYrs) + " yrs  (" + stk_lb_str + ")"
        etf_title = "SECTOR  ·  " + etf_ticker + "  ·  " + sector_str + "  ·  " + str.tostring(etfYrs) + " yrs  (" + etf_lb_str + ")" + (i_override ? "  [manual]" : "  [auto]")
        cmd_title = "COMMODITY  ·  " + sel_ticker + "  ·  " + sel_name + "  ·  " + str.tostring(cmdYrs) + " yrs  (" + cmd_lb_str + ")" + rec_suffix

        n_rows_ann = show_cmd ? 11 : 7

        if is_vertical
            tbl = table.new(position.top_right, 14, n_rows_ann,
                 border_color=color.new(#1C3040, 40), border_width=1,
                 frame_color =color.new(#0A1520, 0),  frame_width =2)

            draw_title_row(tbl, 0, stk_title, ttl_bg, i_col_ttl_stk, 13)
            draw_ann_hdr(tbl, 1, cur_ann_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_ann_row(tbl, 2, stkAvg, stkTot, stkYrs, cur_ann_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, i_col_cur_bg, i_col_cur_fg)
            draw_sep(tbl, 3, 13, i_col_sep)
            draw_title_row(tbl, 4, etf_title, ttl_bg, i_col_ttl_etf, 13)
            draw_ann_hdr(tbl, 5, cur_ann_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_ann_row(tbl, 6, etfAvg, etfTot, etfYrs, cur_ann_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, i_col_cur_bg, i_col_cur_fg)

            if show_cmd
                draw_sep(tbl, 7, 13, i_col_sep)
                draw_title_row(tbl, 8, cmd_title, ttl_bg, i_col_ttl_cmd, 13)
                draw_ann_hdr(tbl, 9, cur_ann_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
                draw_ann_row(tbl, 10, cmdAvg, cmdTot, cmdYrs, cur_ann_col,
                     i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                     hdr_bg, sub_fg, i_col_cur_bg, i_col_cur_fg)

        else
            tbl_s = table.new(position.top_left, 14, 3,
                 border_color=color.new(#1C3040, 40), border_width=1,
                 frame_color =color.new(#0A1520, 0),  frame_width =2)
            draw_title_row(tbl_s, 0, stk_title, ttl_bg, i_col_ttl_stk, 13)
            draw_ann_hdr(tbl_s, 1, cur_ann_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_ann_row(tbl_s, 2, stkAvg, stkTot, stkYrs, cur_ann_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, i_col_cur_bg, i_col_cur_fg)

            tbl_e = table.new(position.top_right, 14, 3,
                 border_color=color.new(#1C3040, 40), border_width=1,
                 frame_color =color.new(#0A1520, 0),  frame_width =2)
            draw_title_row(tbl_e, 0, etf_title, ttl_bg, i_col_ttl_etf, 13)
            draw_ann_hdr(tbl_e, 1, cur_ann_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_ann_row(tbl_e, 2, etfAvg, etfTot, etfYrs, cur_ann_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, i_col_cur_bg, i_col_cur_fg)

            if show_cmd
                tbl_c = table.new(position.bottom_left, 14, 3,
                     border_color=color.new(#1C3040, 40), border_width=1,
                     frame_color =color.new(#0A1520, 0),  frame_width =2)
                draw_title_row(tbl_c, 0, cmd_title, ttl_bg, i_col_ttl_cmd, 13)
                draw_ann_hdr(tbl_c, 1, cur_ann_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
                draw_ann_row(tbl_c, 2, cmdAvg, cmdTot, cmdYrs, cur_ann_col,
                     i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                     hdr_bg, sub_fg, i_col_cur_bg, i_col_cur_fg)

    // ══════════════════════════════════════════════════════════════════════════
    // BRANCH B — MONTHLY
    // ══════════════════════════════════════════════════════════════════════════

    else
        float[] mo_stk_avg = array.new_float(31, 0.0)
        float[] mo_etf_avg = array.new_float(31, 0.0)
        float[] mo_cmd_avg = array.new_float(31, 0.0)
        int     mo_stk_yrs = 0
        int     mo_etf_yrs = 0
        int     mo_cmd_yrs = 0
        float   mo_stk_tot = 0.0
        float   mo_etf_tot = 0.0
        float   mo_cmd_tot = 0.0
        int     actual_days = 0

        for d = 0 to cur_mo_days - 1
            _sc = array.get(mo_stk_count, d)
            _sa = _sc > 0 ? array.get(mo_stk_total, d) / _sc : 0.0
            array.set(mo_stk_avg, d, _sa)
            if _sc > 0
                mo_stk_tot  += _sa
                actual_days := d + 1
            if _sc > mo_stk_yrs
                mo_stk_yrs := _sc

            _ec = array.get(mo_etf_c, d)
            _ea = _ec > 0 ? array.get(mo_etf_t, d) / _ec : 0.0
            array.set(mo_etf_avg, d, _ea)
            if _ec > 0
                mo_etf_tot += _ea
            if _ec > mo_etf_yrs
                mo_etf_yrs := _ec

            if show_cmd
                _cc = array.get(mo_cmd_c, d)
                _ca = _cc > 0 ? array.get(mo_cmd_t, d) / _cc : 0.0
                array.set(mo_cmd_avg, d, _ca)
                if _cc > 0
                    mo_cmd_tot += _ca
                if _cc > mo_cmd_yrs
                    mo_cmd_yrs := _cc

        n_cols   = math.max(actual_days, cur_mo_days)
        tot_cols = n_cols + 2
        last_col = tot_cols - 1
        n_rows_mo = show_cmd ? 11 : 7

        stk_title_mo = "STOCK  ·  " + syminfo.ticker + "  ·  " + cur_mo_name +
                       "  ·  " + str.tostring(mo_stk_yrs) + " yrs  (" + stk_lb_str + ")"
        etf_title_mo = "SECTOR  ·  " + etf_ticker + "  ·  " + sector_str +
                       "  ·  " + cur_mo_name + "  ·  " +
                       str.tostring(mo_etf_yrs) + " yrs  (" + etf_lb_str + ")" +
                       (i_override ? "  [manual]" : "  [auto]")
        cmd_title_mo = "COMMODITY  ·  " + sel_ticker + "  ·  " + sel_name +
                       "  ·  " + cur_mo_name + "  ·  " +
                       str.tostring(mo_cmd_yrs) + " yrs  (" + cmd_lb_str + ")" + rec_suffix

        if is_vertical
            tbl = table.new(position.top_right, tot_cols, n_rows_mo,
                 border_color=color.new(#1C3040, 40), border_width=1,
                 frame_color =color.new(#0A1520, 0),  frame_width =2)

            draw_mo_title(tbl, 0, stk_title_mo, ttl_bg, i_col_ttl_stk, last_col)
            draw_mo_hdr(tbl, 1, n_cols, last_col, cur_mo_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_mo_vals(tbl, 2, mo_stk_avg, mo_stk_count, mo_stk_tot, mo_stk_yrs,
                 n_cols, last_col, cur_mo_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, dim_bg, dim_fg, i_col_cur_bg, i_col_cur_fg)
            draw_sep(tbl, 3, last_col, i_col_sep)
            draw_mo_title(tbl, 4, etf_title_mo, ttl_bg, i_col_ttl_etf, last_col)
            draw_mo_hdr(tbl, 5, n_cols, last_col, cur_mo_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_mo_vals(tbl, 6, mo_etf_avg, mo_etf_c, mo_etf_tot, mo_etf_yrs,
                 n_cols, last_col, cur_mo_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, dim_bg, dim_fg, i_col_cur_bg, i_col_cur_fg)

            if show_cmd
                draw_sep(tbl, 7, last_col, i_col_sep)
                draw_mo_title(tbl, 8, cmd_title_mo, ttl_bg, i_col_ttl_cmd, last_col)
                draw_mo_hdr(tbl, 9, n_cols, last_col, cur_mo_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
                draw_mo_vals(tbl, 10, mo_cmd_avg, mo_cmd_c, mo_cmd_tot, mo_cmd_yrs,
                     n_cols, last_col, cur_mo_col,
                     i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                     hdr_bg, sub_fg, dim_bg, dim_fg, i_col_cur_bg, i_col_cur_fg)

        else
            tbl_s = table.new(position.top_left, tot_cols, 3,
                 border_color=color.new(#1C3040, 40), border_width=1,
                 frame_color =color.new(#0A1520, 0),  frame_width =2)
            draw_mo_title(tbl_s, 0, stk_title_mo, ttl_bg, i_col_ttl_stk, last_col)
            draw_mo_hdr(tbl_s, 1, n_cols, last_col, cur_mo_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_mo_vals(tbl_s, 2, mo_stk_avg, mo_stk_count, mo_stk_tot, mo_stk_yrs,
                 n_cols, last_col, cur_mo_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, dim_bg, dim_fg, i_col_cur_bg, i_col_cur_fg)

            tbl_e = table.new(position.top_right, tot_cols, 3,
                 border_color=color.new(#1C3040, 40), border_width=1,
                 frame_color =color.new(#0A1520, 0),  frame_width =2)
            draw_mo_title(tbl_e, 0, etf_title_mo, ttl_bg, i_col_ttl_etf, last_col)
            draw_mo_hdr(tbl_e, 1, n_cols, last_col, cur_mo_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
            draw_mo_vals(tbl_e, 2, mo_etf_avg, mo_etf_c, mo_etf_tot, mo_etf_yrs,
                 n_cols, last_col, cur_mo_col,
                 i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                 hdr_bg, sub_fg, dim_bg, dim_fg, i_col_cur_bg, i_col_cur_fg)

            if show_cmd
                tbl_c = table.new(position.bottom_left, tot_cols, 3,
                     border_color=color.new(#1C3040, 40), border_width=1,
                     frame_color =color.new(#0A1520, 0),  frame_width =2)
                draw_mo_title(tbl_c, 0, cmd_title_mo, ttl_bg, i_col_ttl_cmd, last_col)
                draw_mo_hdr(tbl_c, 1, n_cols, last_col, cur_mo_col, hdr_bg, hdr_fg, i_col_cur_bg, i_col_cur_fg)
                draw_mo_vals(tbl_c, 2, mo_cmd_avg, mo_cmd_c, mo_cmd_tot, mo_cmd_yrs,
                     n_cols, last_col, cur_mo_col,
                     i_col_pos_bg, i_col_neg_bg, i_col_pos_txt, i_col_neg_txt,
                     hdr_bg, sub_fg, dim_bg, dim_fg, i_col_cur_bg, i_col_cur_fg)
````
