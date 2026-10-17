# Joint-state Kalman Filter (Linear / Extended / Unscented)

- url: https://www.tradingview.com/script/keVAuPgL-Joint-state-Kalman-Filter-Linear-Extended-Unscented/
- type: indicator
- pine_id: PUB;88a84a4a2cc945d4b620a08814e9ec58
- version: 2.0

## Description

[b]Joint-state Kalman Filter (Linear / Extended / Unscented)[/b] · [i]JS Kalman[/i]

A [b]joint-state[/b] price filter — not a typical 1D random-walk smoother. It estimates coupled [level, velocity] (and optionally acceleration) in one shared covariance, so trend tracking and reversal behaviour move together.

[b]Filter types[/b]
[list]
[*][b]Linear[/b] — kinematic Kalman; less lag on trends, can overshoot at sharp reversals (more with C.Accel).
[*][b]Extended[/b] — same layout with velocity damping [b]v' = v × (1 − damping × |v|)[/b]; analytic Jacobian.
[*][b]Unscented[/b] — same nonlinearity via sigma points (falls back to Extended if the covariance square root fails).
[/list]

[b]State models[/b]
[list]
[*][b]C.Veloc[/b] — constant velocity: [level, velocity]
[*][b]C.Accel[/b] — constant acceleration: [level, velocity, acceleration] (default)
[/list]

Switching filter type reuses the same internal state (you may see a one-bar discontinuity).

[b]On the chart[/b]
[list]
[*][b]Filtered price[/b] — teal while rising, red while falling (optional).
[*][b]Candle paint[/b] — same trend colours on the bars (optional).
[/list]

[b]Settings at a glance[/b]
[list]
[*][b]Model[/b] — filter type, state model, source, velocity damping (Extended / Unscented).
[*][b]Noise[/b] — process noise per component and measurement noise.
[*][b]Unscented[/b] — alpha, beta, kappa (Unscented only).
[*][b]UI[/b] — show filtered line, paint candles.
[/list]


[b]Licence[/b]

Indicator and library © igor_sinkovec — [url=https://mozilla.org/MPL/2.0/]Mozilla Public License 2.0[/url].

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © igor_sinkovec
//
// Joint-state Kalman Filter (Linear / Extended / Unscented).
// Theory: https://en.wikipedia.org/wiki/Kalman_filter
//         https://en.wikipedia.org/wiki/Extended_Kalman_filter
//         https://en.wikipedia.org/wiki/Kalman_filter#Unscented_Kalman_filter
//
// Unlike most 1D random-walk smoothers, this estimates [level, velocity]
// (and optional acceleration) as a coupled state. Linear mode tracks trends with
// less lag but can overshoot at reversals (more with CA / n=3). Extended and
// Unscented add velocity damping v' = v*(1 - damping*|v|) so extremes decay;
// EKF linearizes via analytic Jacobian, UKF via sigma points.
//
// Jacobian of v' = v*(1 - d*|v|): dv'/dv = 1 - 2*d*|v| (1 at v=0).
// CV F = [[1, dv'/dv],[0, dv'/dv]]; CA adds accel column/row as in fNonlinear.
//
// Filter-type switches reuse the same var state (possible one-bar discontinuity).
// Filter math: library igor_sinkovec/kalman_filter.

//@version=6
indicator("Joint-state Kalman Filter (Linear / Extended / Unscented)", "JS Kalman", overlay = true, precision = 2, format = format.price)

import igor_sinkovec/kalman_filter/1 as kf


//#region ------ Constants ------------

const string GRP_MODEL = "Model"
const string GRP_NOISE = "Noise"
const string GRP_UKF   = "Unscented"
const string GRP_UI    = "UI"

//#endregion --- Constants ------------


//#region ------ Types ----------------

enum FilterType
    Linear    = "Linear"
    Extended  = "Extended"
    Unscented = "Unscented"

enum StateModel
    CVeloc = "C.Veloc"
    CAccel = "C.Accel"

//#endregion --- Types ----------------


//#region ------ Inputs ---------------

FilterType    filterTypeInput           = input.enum(FilterType.Linear, "Filter type", group = GRP_MODEL, tooltip = "Linear = joint-state KF; Extended = EKF with velocity damping; Unscented = UKF with same nonlinearity.")
StateModel    stateModelInput           = input.enum(StateModel.CAccel, "State model", group = GRP_MODEL, tooltip = "C.Veloc: constant velocity [level, velocity]. C.Accel: constant acceleration [level, velocity, acceleration].")
series float  priceSourceInput          = input.source(close, "Source", group = GRP_MODEL)
float         dampingInput              = input.float(0.01, "Velocity damping", minval = 0.0, step = 0.001, group = GRP_MODEL, active = filterTypeInput != FilterType.Linear, tooltip = "v' = v * (1 - damping * |v|). Extended and Unscented only.")

float         processNoiseLevelInput    = input.float(0.01, "Process noise (level)", minval = 0.0, step = 0.001, group = GRP_NOISE)
float         processNoiseVelocityInput = input.float(0.001, "Process noise (velocity)", minval = 0.0, step = 0.0001, group = GRP_NOISE)
float         processNoiseAccelInput    = input.float(0.0001, "Process noise (acceleration)", minval = 0.0, step = 0.00001, group = GRP_NOISE, active = stateModelInput == StateModel.CAccel)
float         measurementNoiseInput     = input.float(3.0, "Measurement noise", minval = 0.0, step = 0.1, group = GRP_NOISE)

float         alphaInput                = input.float(0.001, "Alpha", minval = 0.0001, step = 0.0001, group = GRP_UKF, active = filterTypeInput == FilterType.Unscented)
float         betaInput                 = input.float(2.0, "Beta", step = 0.1, group = GRP_UKF, active = filterTypeInput == FilterType.Unscented)
float         kappaInput                = input.float(0.0, "Kappa", step = 0.1, group = GRP_UKF, active = filterTypeInput == FilterType.Unscented)

bool          showFilterInput           = input.bool(true, "Filtered level", group = GRP_UI)
bool          paintCandlesInput         = input.bool(true, "Paint candles by trend", group = GRP_UI)

//#endregion --- Inputs ---------------


//#region ------ Calculations ---------

var float[] x     = array.new_float(3, na)
var float[] P     = array.new_float(9, 0.0)
var float[] xpred = array.new_float(3, 0.0)
var float[] Ppred = array.new_float(9, 0.0)
var float[] F     = array.new_float(9, 0.0)
var float[] Ft    = array.new_float(9, 0.0)
var float[] tmp   = array.new_float(9, 0.0)
var float[] tmp2  = array.new_float(9, 0.0)
var float[] Lchol = array.new_float(9, 0.0)
var float[] xi    = array.new_float(3, 0.0)
var float[] yi    = array.new_float(3, 0.0)
var float[] K     = array.new_float(3, 0.0)
var float[] Ysig  = array.new_float(21, 0.0)
var int     prevN = na

int   n   = stateModelInput == StateModel.CVeloc ? 2 : 3
float z   = priceSourceInput
float q0  = processNoiseLevelInput
float q1  = processNoiseVelocityInput
float q2  = processNoiseAccelInput
float R   = measurementNoiseInput
float dmp = dampingInput

bool needInit = barstate.isfirst or na(array.get(x, 0)) or na(prevN) or prevN != n
if needInit
    kf.initFilter(x, P, n, z)
    prevN := n

float filtered = switch filterTypeInput
    FilterType.Linear => kf.linearStep(x, P, n, z, q0, q1, q2, R, xpred, Ppred, F, Ft, tmp, K)
    FilterType.Extended => kf.ekfStep(x, P, n, z, dmp, q0, q1, q2, R, xpred, Ppred, F, Ft, tmp, K)
    FilterType.Unscented => kf.ukfStep(x, P, n, z, dmp, q0, q1, q2, R, alphaInput, betaInput, kappaInput, xpred, Ppred, F, Ft, tmp, tmp2, Lchol, xi, yi, K, Ysig)

var int trend = 0
if filtered > filtered[1]
    trend := 1
else if filtered < filtered[1]
    trend := -1

//#endregion --- Calculations ---------


//#region ------ Visuals --------------

color colorPos    = color.new(color.teal, 40)
color colorNeg    = color.new(color.red, 40)
color colorPosBar = color.new(color.teal, 0)
color colorNegBar = color.new(color.red, 0)
color plotColor   = trend == 1 ? colorPos : colorNeg
color barColor    = trend == 1 ? colorPosBar : colorNegBar

barcolor(paintCandlesInput ? barColor : na)
plot(showFilterInput ? filtered : na, "Kalman filter", plotColor, 2)

//#endregion --- Visuals --------------
````
