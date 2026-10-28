# Expected Move Bands

- url: https://www.tradingview.com/script/PjYGgG1p-Expected-Move-Bands/
- type: indicator
- pine_id: PUB;a717db6ee569427c9ce73f1432945f8a
- version: 1.0

## Description

Every options desk opens the week with the same question: how far is this thing supposed to travel by Friday? The answer is already priced. Implied vol is the market's own estimate of the coming move, and you can read it straight off the chart instead of running the math in your head.

This draws that estimate as bands around price. It anchors to the open of each week, or month, and holds the bands flat across the period, the way a desk marks its expected range on Monday morning and watches price work inside it.

The inner band is one standard deviation. If the market's vol read is right, price closes inside it about two times out of three. The wider band is two sigma, the tail. When price breaks the one-sigma band and holds out there, that is range expansion, the move getting repriced while it happens.

The bands are fed by whichever volatility index belongs to the instrument you are charting -- GVZ if it is gold, OVX for crude, VXN on the Nasdaq, DVOL on bitcoin, VIX on the S&P. The dashboard names the one it picked. That is the only case where implied vol is actually observed.

Where no such index exists, the bands are derived instead: a reference index scaled by the ratio of this instrument's realized vol to the reference's. The level and the event risk still come from a real options series and only the ratio is estimated, and the dashboard marks it DERIVED. It cannot see risk specific to one instrument, such as a single name going into its own earnings.
Where neither is possible nothing is drawn and the dashboard says why. There is no realized-vol fallback, deliberately: a backward-looking estimate diverges from traded implied vol exactly in the regimes you would open this for. Into a known event, implied rises while realized is still asleep. After a shock, realized stays elevated while implied mean-reverts. A band I cannot stand behind does not get drawn.

The dashboard shows the IV source and which tier it came from, the live IV, the expected move in points and percent, and the exact levels. Labels print the prices on the chart. Alerts fire when price closes outside one sigma or tags two.

Read the band correctly: an expected move is a probability statement, not a boundary. Price closing outside the one-sigma band roughly a third of the time is the model working, not failing. The realized-vol ratio behind derived mode is measured on daily bars, so it does not shift when you change chart timeframe.

## Source Code

````pine
// This Pine Script(tm) v6 indicator is subject to the Terms of Use:
// https://www.tradingview.com/pine-script-reference/v6/
// Expected Move Bands v1.2
// v1.2: THREE-TIER IV RESOLUTION. The realized-vol ("est") fallback is removed.
//       Previously every non-crypto symbol was scored against CBOE:VIX, i.e. the
//       implied vol of the S&P 500 rather than of the instrument on the chart,
//       which made the bands systematically too narrow on every single name.
//       See the IV RESOLUTION block below for what replaced it.
// v1.1: movable dashboard (corner picker), table text-size input, higher-contrast
//       table colors. Default position moved to bottom right so the table stays
//       clear of the chart's pane controls.
// Plots the options-implied expected move (+/-1 sigma / +/-2 sigma) around price,
// anchored to the open of each week/month and held flat across the period.

//@version=6
indicator("Expected Move Bands", overlay = true, precision = 2)

// ── Inputs ──────────────────────────────────────────────────────────────────
grp_anchor = "Horizon / Anchor"
anchorTF   = input.timeframe("W", "Anchor timeframe (bands reset each)", group = grp_anchor)
dteInput   = input.float(0,   "Days to horizon (0 = auto from anchor)", minval = 0, group = grp_anchor)
yearDays   = input.float(365, "Calendar days/year for IV scaling",      minval = 1, group = grp_anchor)

grp_iv     = "Implied volatility source"
ivMode     = input.string("Auto", "IV source", options = ["Auto", "Custom"], group = grp_iv)
customIV   = input.string("CBOE:VIX", "Custom IV symbol (Custom mode only)", group = grp_iv)
ivSmooth   = input.int(1, "IV smoothing (EMA)", minval = 1, maxval = 10, group = grp_iv)
allowDeriv = input.bool(true, "Allow derived IV (tier 2)", group = grp_iv, tooltip = "When this symbol has no volatility index of its own, derive one from a reference index scaled by the realized-vol ratio. Level and event risk still come from a real options series. It cannot see risk specific to this instrument, such as a single name into its own earnings. Turn off to show bands ONLY where implied vol is directly observed.")
refIVEq    = input.string("CBOE:VIX",     "Tier-2 reference IV (non-crypto)",         group = grp_iv)
refPxEq    = input.string("SP:SPX",       "Tier-2 reference underlying (non-crypto)", group = grp_iv)
refIVCr    = input.string("DERIBIT:DVOL", "Tier-2 reference IV (crypto)",             group = grp_iv)
refPxCr    = input.string("INDEX:BTCUSD", "Tier-2 reference underlying (crypto)",     group = grp_iv)
ratioLen   = input.int(90, "Tier-2 RV ratio window (daily bars)", minval = 30, maxval = 250, group = grp_iv, tooltip = "Long by design. A short window lets one gap inflate the ratio for weeks after the move that caused it.")
ratioCap   = input.float(4.0, "Tier-2 ratio cap", minval = 1.0, step = 0.5, group = grp_iv)
annFactor  = input.float(365, "RV annualization (365 crypto, 252 other)", minval = 1, group = grp_iv)

grp_disp   = "Display"
show2      = input.bool(true,  "Show +/-2 sigma band",   group = grp_disp)
showMid    = input.bool(true,  "Show anchor (mid) line", group = grp_disp)
showLabels = input.bool(true,  "Show price labels",    group = grp_disp)
showTable  = input.bool(true,  "Show dashboard table", group = grp_disp)
tblPosIn   = input.string("Bottom right", "Table position", options = ["Top right", "Top left", "Top center", "Middle right", "Middle left", "Bottom right", "Bottom left", "Bottom center"], group = grp_disp)
tblSizeIn  = input.string("Normal", "Table text size", options = ["Tiny", "Small", "Normal", "Large"], group = grp_disp)

tblPos = tblPosIn == "Top right" ? position.top_right : tblPosIn == "Top left" ? position.top_left : tblPosIn == "Top center" ? position.top_center : tblPosIn == "Middle right" ? position.middle_right : tblPosIn == "Middle left" ? position.middle_left : tblPosIn == "Bottom left" ? position.bottom_left : tblPosIn == "Bottom center" ? position.bottom_center : position.bottom_right
tblSize = tblSizeIn == "Tiny" ? size.tiny : tblSizeIn == "Small" ? size.small : tblSizeIn == "Large" ? size.large : size.normal

// ── Detect asset class ──────────────────────────────────────────────────────
isCrypto = (str.contains(str.lower(syminfo.type), "crypto") or (str.contains(str.lower(syminfo.currency), "usd") and (str.contains(str.lower(syminfo.basecurrency), "btc") or str.contains(str.lower(syminfo.basecurrency), "eth") or str.contains(str.lower(syminfo.basecurrency), "sol"))))
annDays  = isCrypto ? 365.0 : 252.0
actAnn   = annFactor != 365 ? annFactor : annDays

// ═══════════════════════════════════════════════════════════════════════════
//  IV RESOLUTION  — shared block, kept identical in Vol Premium Gauge.
//  Edit both files together.
//
//  TIER 1  REAL   this symbol has its own published volatility index. Used
//                 as-is. The only tier where implied vol is actually observed.
//  TIER 2  DERIV  no vol index for this symbol, but a defensible reference
//                 exists. IV = referenceIV * (RV_symbol / RV_reference).
//                 The level and the event risk come from a real options
//                 series; only the cross-sectional ratio is estimated. It
//                 CANNOT see risk specific to this instrument, so it is
//                 labelled DERIV everywhere it appears.
//  TIER 3  NONE   neither. Nothing is plotted and the dashboard says why.
//
//  WHY NO REALIZED-VOL FALLBACK ANY MORE: a Parkinson or close-to-close
//  estimate is backward-looking and diverges from traded IV exactly in the
//  regimes this tool gets opened for. Into a known event, IV rises while RV is
//  still asleep and the estimate understates badly; after a shock, RV stays
//  elevated while IV mean-reverts and it overstates. The old code also
//  hardcoded a 1.15 variance-risk-premium multiplier, which is not a constant.
//  A band we cannot stand behind is worse than no band, so tier 3 refuses.
//
//  ⚠ ignore_invalid_symbol = true means a wrong or delisted vol ticker returns
//  na SILENTLY. That is precisely what produced the original defect: CBOE:VIX
//  always resolves, so the na-check that would have caught it never fired. So
//  every tier below checks for na and DROPS A TIER rather than substituting a
//  number. Verify any ticker you add to the map actually resolves.
// ═══════════════════════════════════════════════════════════════════════════

_sym = str.upper(syminfo.ticker)

// Tier 1 map. Inlined as a ternary chain (not a function) so the result stays a
// simple string, which is what request.security requires for its symbol arg.
_volIdx = str.contains(_sym, "BTC") or str.contains(_sym, "XBT")                          ? "DERIBIT:DVOL" :
   _sym == "SPX" or _sym == "SPY" or _sym == "US500" or _sym == "SPXUSD" or str.contains(_sym, "ES1!") ? "CBOE:VIX"  :
   _sym == "NDX" or _sym == "QQQ" or _sym == "US100" or str.contains(_sym, "NQ1!")        ? "CBOE:VXN"  :
   _sym == "RUT" or _sym == "IWM" or _sym == "US2000" or str.contains(_sym, "RTY1!")      ? "CBOE:RVX"  :
   _sym == "DJI" or _sym == "DIA" or _sym == "US30" or str.contains(_sym, "YM1!")         ? "CBOE:VXD"  :
   _sym == "XAUUSD" or _sym == "GOLD" or _sym == "GLD" or str.contains(_sym, "GC1!")      ? "CBOE:GVZ"  :
   _sym == "USOIL" or _sym == "WTIUSD" or _sym == "USO" or _sym == "WTICOUSD" or str.contains(_sym, "CL1!") ? "CBOE:OVX" :
   _sym == "EURUSD" or _sym == "FXE" or str.contains(_sym, "6E1!")                        ? "CBOE:EVZ"  : ""

t1SymRaw = ivMode == "Custom" ? customIV : _volIdx
t1Sym    = t1SymRaw == "" ? "NO_VOL_INDEX_FOR_THIS_SYMBOL" : t1SymRaw   // sentinel resolves to na
t1Raw    = request.security(t1Sym, "D", close, ignore_invalid_symbol = true)
t1Smooth = ta.ema(t1Raw, ivSmooth)
t1IV     = (t1SymRaw == "" or na(t1Raw)) ? na : t1Smooth

// Tier 2. Both realized vols are measured on DAILY bars via request.security so
// the ratio is independent of the chart timeframe, and the annualization factor
// cancels out of the ratio as long as both legs use the same one.
refIVSym = isCrypto ? refIVCr : refIVEq
refPxSym = isCrypto ? refPxCr : refPxEq

_rvExpr  = ta.stdev(math.log(close / close[1]), ratioLen) * math.sqrt(actAnn) * 100
symRVd   = request.security(syminfo.tickerid, "D", _rvExpr, ignore_invalid_symbol = true)
refRVd   = request.security(refPxSym,         "D", _rvExpr, ignore_invalid_symbol = true)
refIVRaw = request.security(refIVSym,         "D", close,   ignore_invalid_symbol = true)
refIVs   = ta.ema(refIVRaw, ivSmooth)

_ratioRaw = (na(symRVd) or na(refRVd) or refRVd <= 0) ? na : symRVd / refRVd
ratio     = na(_ratioRaw) ? na : math.min(_ratioRaw, ratioCap)
t2IV      = (not allowDeriv or na(refIVRaw) or na(ratio)) ? na : refIVs * ratio

ivFinal = not na(t1IV) ? t1IV : t2IV
ivTier  = not na(t1IV) ? "REAL" : not na(t2IV) ? "DERIV" : "NONE"
ivSrc   = not na(t1IV) ? t1Sym  : not na(t2IV) ? refIVSym + " x RV ratio" : "none"
// ═══════════════════════════════════════════════════════════════════════════

// ── Horizon (days to expiry) ────────────────────────────────────────────────
autoDte = str.contains(anchorTF, "W") ? 7.0 : str.contains(anchorTF, "M") ? 30.0 : str.contains(anchorTF, "D") ? 1.0 : 7.0
dte     = dteInput > 0 ? dteInput : autoDte

// ── Expected move, frozen at each new anchor period ─────────────────────────
// 1 sigma move as a fraction of price: IV (annualized %) scaled to the horizon.
// na when tier 3, which propagates to the bands so nothing is drawn.
emFrac = ivFinal / 100.0 * math.sqrt(dte / yearDays)

var float anchorPx = na
var float em1      = na
newPeriod = timeframe.change(anchorTF)
if newPeriod or na(anchorPx)
    anchorPx := open
    em1      := open * emFrac

up1 = anchorPx + em1
dn1 = anchorPx - em1
up2 = anchorPx + em1 * 2.0
dn2 = anchorPx - em1 * 2.0

// ── Plots (stepline so bands stay flat then jump at each new period) ─────────
mid = plot(showMid ? anchorPx : na, "Anchor",  color = color.new(color.gray, 30),   linewidth = 1, style = plot.style_stepline)
p1u = plot(up1, "+1 sigma", color = color.new(color.teal, 0),   linewidth = 1, style = plot.style_stepline)
p1d = plot(dn1, "-1 sigma", color = color.new(color.teal, 0),   linewidth = 1, style = plot.style_stepline)
p2u = plot(show2 ? up2 : na, "+2 sigma", color = color.new(color.maroon, 0), linewidth = 1, style = plot.style_stepline)
p2d = plot(show2 ? dn2 : na, "-2 sigma", color = color.new(color.maroon, 0), linewidth = 1, style = plot.style_stepline)

fill(p1u, p1d, color = color.new(color.teal, 90),   title = "+/-1 sigma zone")
fill(p2u, p1u, color = color.new(color.maroon, 93), title = "Upper tail")
fill(p1d, p2d, color = color.new(color.maroon, 93), title = "Lower tail")

// ── Price labels at last bar ────────────────────────────────────────────────
var label luOne = na
var label ldOne = na
var label luTwo = na
var label ldTwo = na
if showLabels and barstate.islast and not na(em1)
    label.delete(luOne)
    label.delete(ldOne)
    label.delete(luTwo)
    label.delete(ldTwo)
    luOne := label.new(bar_index, up1, "+1s " + str.tostring(up1, format.mintick), style = label.style_label_left, color = color.new(color.teal, 20),   textcolor = color.white, size = size.small)
    ldOne := label.new(bar_index, dn1, "-1s " + str.tostring(dn1, format.mintick), style = label.style_label_left, color = color.new(color.teal, 20),   textcolor = color.white, size = size.small)
    if show2
        luTwo := label.new(bar_index, up2, "+2s " + str.tostring(up2, format.mintick), style = label.style_label_left, color = color.new(color.maroon, 20), textcolor = color.white, size = size.small)
        ldTwo := label.new(bar_index, dn2, "-2s " + str.tostring(dn2, format.mintick), style = label.style_label_left, color = color.new(color.maroon, 20), textcolor = color.white, size = size.small)

// ── Dashboard table ─────────────────────────────────────────────────────────
tierCol = ivTier == "REAL" ? color.new(color.teal, 0) : ivTier == "DERIV" ? color.new(color.orange, 0) : color.new(color.maroon, 0)

if showTable and barstate.islast
    var table t = table.new(tblPos, 2, 7, border_width = 1, bgcolor = color.new(color.black, 10), border_color = color.new(color.gray, 60))
    table.cell(t, 0, 0, "EXPECTED MOVE", text_color = color.white, text_size = tblSize, bgcolor = tierCol)
    table.cell(t, 1, 0, na(ivFinal) ? "no IV" : str.tostring(dte, "#.#") + "d", text_color = color.white, text_size = tblSize, bgcolor = tierCol)

    table.cell(t, 0, 1, "IV source", text_color = color.silver, text_size = tblSize)
    table.cell(t, 1, 1, ivTier == "REAL" ? ivSrc : ivTier == "DERIV" ? "DERIVED" : "none", text_color = ivTier == "REAL" ? color.white : ivTier == "DERIV" ? color.orange : color.red, text_size = tblSize)

    if na(ivFinal)
        table.cell(t, 0, 2, "Bands", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 2, "unavailable", text_color = color.red, text_size = tblSize)
        table.cell(t, 0, 3, "Why", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 3, "no implied vol series", text_color = color.silver, text_size = tblSize)
        table.cell(t, 0, 4, "", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 4, "for this symbol", text_color = color.silver, text_size = tblSize)
        table.cell(t, 0, 5, "", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 5, "", text_color = color.silver, text_size = tblSize)
        table.cell(t, 0, 6, "", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 6, "", text_color = color.silver, text_size = tblSize)
    else
        table.cell(t, 0, 2, ivTier == "DERIV" ? "IV (derived)" : "IV", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 2, str.tostring(ivFinal, "#.#") + "%", text_color = color.yellow, text_size = tblSize)

        table.cell(t, 0, 3, "Move 1 sigma", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 3, str.tostring(em1, format.mintick) + " (" + str.tostring(emFrac * 100, "#.#") + "%)", text_color = color.white, text_size = tblSize)

        table.cell(t, 0, 4, "+1s / -1s", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 4, str.tostring(up1, format.mintick) + " / " + str.tostring(dn1, format.mintick), text_color = #26c6da, text_size = tblSize)

        table.cell(t, 0, 5, "+2s / -2s", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 5, str.tostring(up2, format.mintick) + " / " + str.tostring(dn2, format.mintick), text_color = #ff6e6e, text_size = tblSize)

        table.cell(t, 0, 6, "Anchor", text_color = color.silver, text_size = tblSize)
        table.cell(t, 1, 6, str.tostring(anchorPx, format.mintick), text_color = color.white, text_size = tblSize)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(close, up1),  "Above +1 sigma", "Expected Move: price closed above +1 sigma (range expansion up)")
alertcondition(ta.crossunder(close, dn1), "Below -1 sigma", "Expected Move: price closed below -1 sigma (range expansion down)")
alertcondition(ta.crossover(close, up2),  "Tagged +2 sigma", "Expected Move: price tagged the +2 sigma tail")
alertcondition(ta.crossunder(close, dn2), "Tagged -2 sigma", "Expected Move: price tagged the -2 sigma tail")
````
