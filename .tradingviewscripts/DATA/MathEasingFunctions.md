<!-- tradingview-pine-id: PUB;1b6a09a99c31491580b4f98715159a4a -->
<!-- tradingviewscripts-format: 1 -->
# MathEasingFunctions

Source: https://www.tradingview.com/script/o3oYFWcE-MathEasingFunctions/

## Description

Library  "MathEasingFunctions"
A collection of Easing functions.
Easing functions are commonly used for smoothing actions over time, They are used to smooth out the sharp edges
of a function and make it more pleasing to the eye, like for example the motion of a object through time.
Easing functions can be used in a variety of applications, including animation, video games, and scientific 
simulations. They are a powerful tool for creating realistic visual effects and can help to make your work more 
engaging and enjoyable to the eye.
---
Includes functions for ease in, ease out, and, ease in and out, for the following constructs:
sine, quadratic, cubic, quartic, quintic, exponential, elastic, circle, back, bounce.
---
Reference:
https://easings.net/#
https://learn.microsoft.com/en-us/dotnet/desktop/wpf/graphics-multimedia/easing-functions

ease_in_sine_unbound(v)
  Sinusoidal function, the position over elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_sine(v)
  Sinusoidal function, the position over elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_sine_unbound(v)
  Sinusoidal function, the position over elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_sine(v)
  Sinusoidal function, the position over elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_sine_unbound(v)
  Sinusoidal function, the position over elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_sine(v)
  Sinusoidal function, the position over elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_quad_unbound(v)
  Quadratic function, the position equals the square of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_quad(v)
  Quadratic function, the position equals the square of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_quad_unbound(v)
  Quadratic function, the position equals the square of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_quad(v)
  Quadratic function, the position equals the square of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_quad_unbound(v)
  Quadratic function, the position equals the square of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_quad(v)
  Quadratic function, the position equals the square of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_cubic_unbound(v)
  Cubic function, the position equals the cube of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_cubic(v)
  Cubic function, the position equals the cube of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_cubic_unbound(v)
  Cubic function, the position equals the cube of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_cubic(v)
  Cubic function, the position equals the cube of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_cubic_unbound(v)
  Cubic function, the position equals the cube of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_cubic(v)
  Cubic function, the position equals the cube of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_quart_unbound(v)
  Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_quart(v)
  Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_quart_unbound(v)
  Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_quart(v)
  Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_quart_unbound(v)
  Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_quart(v)
  Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_quint_unbound(v)
  Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_quint(v)
  Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_quint_unbound(v)
  Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_quint(v)
  Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_quint_unbound(v)
  Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_quint(v)
  Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_expo_unbound(v)
  Exponential function, the position equals the exponential formula of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_expo(v)
  Exponential function, the position equals the exponential formula of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_expo_unbound(v)
  Exponential function, the position equals the exponential formula of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_expo(v)
  Exponential function, the position equals the exponential formula of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_expo_unbound(v)
  Exponential function, the position equals the exponential formula of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_expo(v)
  Exponential function, the position equals the exponential formula of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_circ_unbound(v)
  Circular function, the position equals the circular formula of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_circ(v)
  Circular function, the position equals the circular formula of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_circ_unbound(v)
  Circular function, the position equals the circular formula of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_circ(v)
  Circular function, the position equals the circular formula of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_circ_unbound(v)
  Circular function, the position equals the circular formula of elapsed time (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_circ(v)
  Circular function, the position equals the circular formula of elapsed time (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_back_unbound(v)
  Back function, the position retreats a bit before resuming (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_back(v)
  Back function, the position retreats a bit before resuming (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_back_unbound(v)
  Back function, the position retreats a bit before resuming (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_back(v)
  Back function, the position retreats a bit before resuming (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_back_unbound(v)
  Back function, the position retreats a bit before resuming (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_back(v)
  Back function, the position retreats a bit before resuming (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_elastic_unbound(v)
  Elastic function, the position oscilates back and forth like a spring (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_elastic(v)
  Elastic function, the position oscilates back and forth like a spring (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_elastic_unbound(v)
  Elastic function, the position oscilates back and forth like a spring (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_elastic(v)
  Elastic function, the position oscilates back and forth like a spring (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_elastic_unbound(v)
  Elastic function, the position oscilates back and forth like a spring (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_elastic(v)
  Elastic function, the position oscilates back and forth like a spring (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_bounce_unbound(v)
  Bounce function, the position bonces from the boundery (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_bounce(v)
  Bounce function, the position bonces from the boundery (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_bounce_unbound(v)
  Bounce function, the position bonces from the boundery (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_out_bounce(v)
  Bounce function, the position bonces from the boundery (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_bounce_unbound(v)
  Bounce function, the position bonces from the boundery (unbound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

ease_in_out_bounce(v)
  Bounce function, the position bonces from the boundery (bound).
  Parameters:
    v (float): `float` Elapsed time.
  Returns: Ratio of change.

select(v, formula, effect, bounded)
  Parameters:
    v (float)
    formula (string)
    effect (string)
    bounded (bool)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RicardoSantos

//@version=6

// @description A collection of Easing functions.
// 
//	Easing functions are commonly used for smoothing actions over time, They are used to smooth out the sharp edges
// of a function and make it more pleasing to the eye, like for example the motion of a object through time.
// 	Easing functions can be used in a variety of applications, including animation, video games, and scientific 
// simulations. They are a powerful tool for creating realistic visual effects and can help to make your work more 
// engaging and enjoyable to the eye.
// ---
// 	Includes functions for ease in, ease out, and, ease in and out, for the following constructs:
// sine, quadratic, cubic, quartic, quintic, exponential, elastic, circle, back, bounce.
// ---
// Reference:
// https://easings.net/#
// https://learn.microsoft.com/en-us/dotnet/desktop/wpf/graphics-multimedia/easing-functions
library("MathEasingFunctions")



//#region	0: Variables:
//#region	0.0: Numeric Constants:
float __C1 = 1.70158
float __C2 = __C1 * 1.525
float __C3 = __C1 + 1.0
float __C4 = (2.0 * math.pi) / 3.0
float __C5 = (2.0 * math.pi) / 4.5
float __N1 = 7.5625
float __D1 = 2.75
//#endregion	0.0
//#region 	0.1: List of effect names:
string __E0 = 'Ease-in'
string __E1 = 'Ease-out'
string __E2 = 'Ease-in-out'
string __EN = str.format('[{0}, {1}, {2}]', __E0, __E1, __E2)
//#endregion	0.1
//#region	0.2: List of formula names:
string __F0 = 'Sine'
string __F1 = 'Quadratic'
string __F2 = 'Cubic'
string __F3 = 'Quartic'
string __F4 = 'Quintic'
string __F5 = 'Exponential'
string __F6 = 'Circle'
string __F7 = 'Back'
string __F8 = 'Elastic'
string __F9 = 'Bounce'
string __FN = str.format('[{0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}]', __F0, __F1, __F2, __F3, __F4, __F5, __F6, __F7, __F8, __F9)
//#endregion	0.2
//#region	0.3: Enums.

export enum Effect
	ease_in		= 'Ease-in'
	ease_out	= 'Ease-out'
	ease_in_out	= 'Ease-in-out'

export enum Formula
	sine		= 'Sine'
	quad		= 'Quadratic'
	cubic		= 'Cubic'
	quartic		= 'Quartic'
	quintic		= 'Quintic'
	exponential	= 'Exponential'
	circle		= 'Circle'
	back		= 'Back'
	elastic		= 'Elastic'
	bounce		= 'Bounce'

//#endregion
//#region	0.4: Linear value for testing:
bool restrict = input.bool(false, 'Restric testing value:')
float v = (restrict ? -50 + (bar_index % 100) : -50 + bar_index) * 0.01
if v > 1.5
	v := float(na)
plot(bar_index%3==0?v:na, 'value', style = plot.style_linebr)
//#endregion	0.4
//#endregion	0
//#region	1: Functions:
//#region	1.0: Sine:
//#region	1.0.0: Ease in:

// @function Sinusoidal function, the position over elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_sine_unbound (float v) =>
	1.0 - math.cos((v * math.pi) / 2.0)

// @function Sinusoidal function, the position over elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_sine (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>          ease_in_sine_unbound(v)

// plot(ease_in_sine(v))

//#endregion	1.0.0
//#region	1.0.1: Ease out:

// @function Sinusoidal function, the position over elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_sine_unbound (float v) =>
	math.sin((v * math.pi) / 2.0)

// @function Sinusoidal function, the position over elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_sine (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>          ease_out_sine_unbound(v)

// plot(ease_out_sine(v))

//#endregion	1.0.1
//#region	1.0.2: Ease in out:

// @function Sinusoidal function, the position over elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_sine_unbound (float v) =>
	-(math.cos(math.pi * v) - 1.0) * 0.5

// @function Sinusoidal function, the position over elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_sine (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_sine_unbound(v)

// plot(ease_in_out_sine(v))

//#endregion	1.0.2
//#endregion	1.0
//#region	1.1: Quadratic:
//#region	1.1.0: Ease in:

// @function Quadratic function, the position equals the square of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_quad_unbound (float v) =>
	math.pow(v, 2)

// @function Quadratic function, the position equals the square of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_quad (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_quad_unbound(v)

// plot(ease_in_quad_unbound(v), "Unbound", #00aaff)
// plot(ease_in_quad(v), "Bound", #0011ff)

//#endregion	1.1.0
//#region	1.1.1: Ease out:

// @function Quadratic function, the position equals the square of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_quad_unbound (float v) =>
	1.0 - math.pow(1.0 - v, 2)

// @function Quadratic function, the position equals the square of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_quad (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_quad_unbound(v)

// plot(ease_out_quad_unbound(v), "Unbound", #00aaff)
// plot(ease_out_quad(v), "Bound", #0011ff)

//#endregion	1.1.1
//#region	1.1.2: Ease in out:

// @function Quadratic function, the position equals the square of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_quad_unbound (float v) =>
	if v < 0.5
		2.0 * math.pow(v, 2)
	else
		1.0 - math.pow(-2.0 * v + 2.0, 2) * 0.5

// @function Quadratic function, the position equals the square of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_quad (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_quad_unbound(v)

// plot(ease_in_out_quad_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_quad(v), "Bound", #0011ff)

//#endregion	1.1.2
//#endregion	1.1
//#region	1.2: Cubic:
//#region	1.2.0: Ease in:

// @function Cubic function, the position equals the cube of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_cubic_unbound (float v) =>
	math.pow(v, 3)

// @function Cubic function, the position equals the cube of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_cubic (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_cubic_unbound(v)

// plot(ease_in_cubic_unbound(v), "Unbound", #00aaff)
// plot(ease_in_cubic(v), "Bound", #0011ff)

//#endregion	1.2.0
//#region	1.2.1: Ease out:

// @function Cubic function, the position equals the cube of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_cubic_unbound (float v) =>
	1.0 - math.pow(1.0 - v, 3)

// @function Cubic function, the position equals the cube of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_cubic (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_cubic_unbound(v)

// plot(ease_out_cubic_unbound(v), "Unbound", #00aaff)
// plot(ease_out_cubic(v), "Bound", #0011ff)

//#endregion	1.2.1
//#region	1.2.2: Ease in out:

// @function Cubic function, the position equals the cube of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_cubic_unbound (float v) =>
	v < 0.5 ? 4.0 * math.pow(v, 3) : 1.0 - math.pow(-2.0 * v + 2.0, 3) / 2

// @function Cubic function, the position equals the cube of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_cubic (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_cubic_unbound(v)

// plot(ease_in_out_cubic_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_cubic(v), "Bound", #0011ff)

//#endregion	1.2.2
//#endregion	1.2
//#region	1.3: Quartic:
//#region	1.3.0: Ease in:

// @function Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_quart_unbound (float v) =>
	math.pow(v, 4)

// @function Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_quart (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_quart_unbound(v)

// plot(ease_in_quart_unbound(v), "Unbound", #00aaff)
// plot(ease_in_quart(v), "Bound", #0011ff)

//#endregion	1.3.0
//#region	1.3.1: Ease out:

// @function Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_quart_unbound (float v) =>
	1.0 - math.pow(1.0 - v, 4)

// @function Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_quart (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_quart_unbound(v)

// plot(ease_out_quart_unbound(v), "Unbound", #00aaff)
// plot(ease_out_quart(v), "Bound", #0011ff)

//#endregion	1.3.1
//#region	1.3.2: Ease in out:

// @function Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_quart_unbound (float v) =>
	if v < 0.5
		8.0 * math.pow(v, 4)
	else
		1.0 - math.pow(-2.0 * v + 2.0, 4) * 0.5

// @function Quartic function, the position equals the formula `f(t)=t^4` of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_quart (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_quart_unbound(v)

// plot(ease_in_out_quart_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_quart(v), "Bound", #0011ff)

//#endregion	1.3.2
//#endregion	1.3
//#region	1.4: Quintic:
//#region	1.4.0: Ease in:

// @function Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_quint_unbound (float v) =>
	math.pow(v, 5)

// @function Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_quint (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_quint_unbound(v)

// plot(ease_in_quint_unbound(v), "Unbound", #00aaff)
// plot(ease_in_quint(v), "Bound", #0011ff)

//#endregion	1.4.0
//#region	1.4.1: Ease out:

// @function Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_quint_unbound (float v) =>
	1.0 - math.pow(1.0 - v, 5)

// @function Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_quint (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_quint_unbound(v)

// plot(ease_out_quint_unbound(v), "Unbound", #00aaff)
// plot(ease_out_quint(v), "Bound", #0011ff)

//#endregion	1.4.1
//#region	1.4.2: Ease in out:

// @function Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_quint_unbound (float v) =>
	v < 0.5 ? 16.0 * math.pow(v, 5) : 1 - math.pow(-2.0 * v + 2.0, 5) / 2.0

// @function Quintic function, the position equals the formula `f(t)=t^5` of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_quint (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_quint_unbound(v)

// plot(ease_in_out_quint_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_quint(v), "Bound", #0011ff)

//#endregion	1.4.2
//#endregion	1.4
//#region	1.5: Exponential:
//#region	1.5.0: Ease in:

// @function Exponential function, the position equals the exponential formula of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_expo_unbound (float v) =>
	if v == 0.0
		0.0
	else
		math.pow(2.0, 10.0 * v - 10.0)

// @function Exponential function, the position equals the exponential formula of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_expo (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_expo_unbound(v)

// plot(ease_in_expo_unbound(v), "Unbound", #00aaff)
// plot(ease_in_expo(v), "Bound", #0011ff)

//#endregion	1.5.0
//#region	1.5.1: Ease out:

// @function Exponential function, the position equals the exponential formula of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_expo_unbound (float v) =>
	if v == 1.0
		1.0
	else
		1.0 - math.pow(2.0, -10 * v)

// @function Exponential function, the position equals the exponential formula of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_expo (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_expo_unbound(v)

// plot(ease_out_expo_unbound(v), "Unbound", #00aaff)
// plot(ease_out_expo(v), "Bound", #0011ff)

//#endregion	1.5.1
//#region	1.5.2: Ease in out:

// @function Exponential function, the position equals the exponential formula of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_expo_unbound (float v) =>
	switch
		v == 0.0 => 0.0
		v == 1.0 => 1.0
		v < 0.5  => math.pow(2.0, 20.0 * v - 10.0) * 0.5
		=>          (2.0 - math.pow(2.0, -20 * v + 10.0)) * 0.5

// @function Exponential function, the position equals the exponential formula of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_expo (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_expo_unbound(v)

// plot(ease_in_out_expo_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_expo(v), "Bound", #0011ff)

//#endregion	1.5.2
//#endregion	1.5
//#region	1.6: Circle:
//#region	1.6.0: Ease in:

// @function Circular function, the position equals the circular formula of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_circ_unbound (float v) =>
	1.0 - math.sqrt(1.0 - math.pow(v, 2))

// @function Circular function, the position equals the circular formula of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_circ (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_circ_unbound(v)

// plot(ease_in_circ_unbound(v), "Unbound", #00aaff)
// plot(ease_in_circ(v), "Bound", #0011ff)

//#endregion	1.6.0
//#region	1.6.1: Ease out:

// @function Circular function, the position equals the circular formula of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_circ_unbound (float v) =>
	math.sqrt(1.0 - math.pow(v - 1.0, 2))

// @function Circular function, the position equals the circular formula of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_circ (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_circ_unbound(v)

// plot(ease_out_circ_unbound(v), "Unbound", #00aaff)
// plot(ease_out_circ(v), "Bound", #0011ff)

//#endregion	1.6.1
//#region	1.6.2: Ease in out:

// @function Circular function, the position equals the circular formula of elapsed time (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_circ_unbound (float v) =>
	if v < 0.5
		(1.0 - math.sqrt(1.0 - math.pow(2.0 * v, 2))) * 0.5
	else
		(math.sqrt(1.0 - math.pow(-2.0 * v + 2.0, 2)) + 1.0) * 0.5

// @function Circular function, the position equals the circular formula of elapsed time (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_circ (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_circ_unbound(v)

// plot(ease_in_out_circ_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_circ(v), "Bound", #0011ff)

//#endregion	1.6.2
//#endregion	1.6
//#region	1.7: Back:
//#region	1.7.0: Ease in:

// @function Back function, the position retreats a bit before resuming (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_back_unbound (float v) =>
	__C2 * math.pow(v, 3) - __C1 * math.pow(v, 2)

// @function Back function, the position retreats a bit before resuming (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_back (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_back_unbound(v)

// plot(ease_in_back_unbound(v), "Unbound", #00aaff)
// plot(ease_in_back(v), "Bound", #0011ff)

//#endregion	1.7.0
//#region	1.7.1: Ease out:

// @function Back function, the position retreats a bit before resuming (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_back_unbound (float v) =>
	1.0 + __C2 * math.pow(v - 1.0, 3) + __C1 * math.pow(v - 1.0, 2)

// @function Back function, the position retreats a bit before resuming (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_back (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_back_unbound(v)

// plot(ease_out_back_unbound(v), "Unbound", #00aaff)
// plot(ease_out_back(v), "Bound", #0011ff)

//#endregion	1.7.1
//#region	1.7.2: Ease in out:

// @function Back function, the position retreats a bit before resuming (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_back_unbound (float v) =>
	if v < 0.5
		(math.pow(2.0 * v, 2) * ((__C2 + 1.0) * 2.0 * v - __C2)) * 0.5
	else
		(math.pow(2.0 * v - 2.0, 2) * ((__C2 + 1.0) * (v * 2.0 - 2.0) + __C2) + 2.0) * 0.5

// @function Back function, the position retreats a bit before resuming (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_back (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_back_unbound(v)

// plot(ease_in_out_back_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_back(v), "Bound", #0011ff)

//#endregion	1.7.2
//#endregion	1.7
//#region	1.8: Elastic:
//#region	1.8.0: Ease in:

// @function Elastic function, the position oscilates back and forth like a spring (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_elastic_unbound (float v) =>
	switch
		v == 0.0 => 0.0
		v == 1.0 => 1.0
		=>          -math.pow(2.0, 10.0 * v - 10.0) * math.sin((v * 10.0 - 10.75) * __C4)

// @function Elastic function, the position oscilates back and forth like a spring (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_elastic (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_elastic_unbound(v)

// plot(ease_in_elastic_unbound(v), "Unbound", #00aaff)
// plot(ease_in_elastic(v), "Bound", #0011ff)

//#endregion	1.8.0
//#region	1.8.1: Ease out:

// @function Elastic function, the position oscilates back and forth like a spring (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_elastic_unbound (float v) =>
	switch
		v == 0.0 => 0.0
		v == 1.0 => 1.0
		=>          math.pow(2.0, -10.0 * v) * math.sin((v * 10.0 - 0.75) * __C4) + 1.0

// @function Elastic function, the position oscilates back and forth like a spring (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_elastic (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_elastic_unbound(v)

// plot(ease_out_elastic_unbound(v), "Unbound", #00aaff)
// plot(ease_out_elastic(v), "Bound", #0011ff)

//#endregion	1.8.1
//#region	1.8.2: Ease in out:

// @function Elastic function, the position oscilates back and forth like a spring (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_elastic_unbound (float v) =>
	switch
		v == 0.0 => 0.0
		v == 1.0 => 1.0
		v <  0.5 => -(math.pow(2.0, 20.0 * v - 10.0) * math.sin((20.0 * v - 11.125) * __C5)) * 0.5
		=>          (math.pow(2.0, -20.0 * v + 10.0) * math.sin((20.0 * v - 11.125) * __C5)) * 0.5 + 1

// @function Elastic function, the position oscilates back and forth like a spring (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_elastic (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_elastic_unbound(v)

// plot(ease_in_out_elastic_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_elastic(v), "Bound", #0011ff)

//#endregion	1.8.2
//#endregion	1.8
//#region	1.9: Bounce:
//#region	1.9.0: Ease in:

// @function Bounce function, the position bonces from the boundery (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_bounce_unbound (float v) =>
	float _vi = 1.0 - v
	switch
		_vi < (1.0 / __D1) => 1.0 - (__N1 * math.pow(_vi, 2))
		_vi < (2.0 / __D1) => float _v = _vi - (1.500 / __D1) , 1.0 - (__N1 * _v * _v + 0.750000)
		_vi < (2.5 / __D1) => float _v = _vi - (2.250 / __D1) , 1.0 - (__N1 * _v * _v + 0.937500)
		=>                    float _v = _vi - (2.625 / __D1) , 1.0 - (__N1 * _v * _v + 0.984375)

// @function Bounce function, the position bonces from the boundery (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_bounce (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_bounce_unbound(v)

// plot(ease_in_bounce_unbound(v), "Unbound", #00aaff)
// plot(ease_in_bounce(v), "Bound", #0011ff)

//#endregion	1.9.0
//#region	1.9.1: Ease out:

// @function Bounce function, the position bonces from the boundery (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_bounce_unbound (float v) =>
	switch
		v < (1.0 / __D1) => __N1 * math.pow(v, 2)
		v < (2.0 / __D1) => float _v = v - (1.500 / __D1) , __N1 * _v * _v + 0.75
		v < (2.5 / __D1) => float _v = v - (2.250 / __D1) , __N1 * _v * _v + 0.9375
		=>                  float _v = v - (2.625 / __D1) , __N1 * _v * _v + 0.984375

// @function Bounce function, the position bonces from the boundery (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_out_bounce (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_out_bounce_unbound(v)

// plot(ease_out_bounce_unbound(v), "Unbound", #00aaff)
// plot(ease_out_bounce(v), "Bound", #0011ff)

//#endregion	1.9.1
//#region	1.9.2: Ease in out:

// @function Bounce function, the position bonces from the boundery (unbound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_bounce_unbound (float v) =>
	if v < 0.5
		(1.0 - ease_out_bounce_unbound(1.0 - 2.0 * v)) * 0.5
	else
		(1.0 + ease_out_bounce_unbound(2.0 * v - 1.0)) * 0.5

// @function Bounce function, the position bonces from the boundery (bound).
// @param v `float` Elapsed time.
// @returns Ratio of change.
export ease_in_out_bounce (float v) =>
	switch
		v <= 0.0 => 0.0
		v >= 1.0 => 1.0
		=>			ease_in_out_bounce_unbound(v)

// plot(ease_in_out_bounce_unbound(v), "Unbound", #00aaff)
// plot(ease_in_out_bounce(v), "Bound", #0011ff)

//#endregion	1.9.2
//#endregion	1.9
//#endregion	1
//#region	2: Selection:
//#region	2.0: select ():

// @function Selects easing method.
// @param	v	Source value, expects a value with the range `[0, 1]`.
// @param	formula		Mathematical formula to use.
// @param	effect		Effect to use.
// @param	bounded		The effect is bounded at range extremes or not.
// @returns Eased value.
export select (float v, Formula formula=Formula.sine, Effect effect = Effect.ease_in, bool bounded=true) =>
	switch formula
		Formula.sine =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_sine(v)
						false => ease_in_sine_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_sine(v)
						false => ease_out_sine_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_sine(v)
						false => ease_in_out_sine_unbound(v)
		Formula.quad =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_quad(v)
						false => ease_in_quad_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_quad(v)
						false => ease_out_quad_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_quad(v)
						false => ease_in_out_quad_unbound(v)
		Formula.cubic =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_cubic(v)
						false => ease_in_cubic_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_cubic(v)
						false => ease_out_cubic_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_cubic(v)
						false => ease_in_out_cubic_unbound(v)
		Formula.quartic =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_quart(v)
						false => ease_in_quart_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_quart(v)
						false => ease_out_quart_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_quart(v)
						false => ease_in_out_quart_unbound(v)
		Formula.quintic =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_quint(v)
						false => ease_in_quint_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_quint(v)
						false => ease_out_quint_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_quint(v)
						false => ease_in_out_quint_unbound(v)
		Formula.exponential =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_expo(v)
						false => ease_in_expo_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_expo(v)
						false => ease_out_expo_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_expo(v)
						false => ease_in_out_expo_unbound(v)
		Formula.circle =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_circ(v)
						false => ease_in_circ_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_circ(v)
						false => ease_out_circ_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_circ(v)
						false => ease_in_out_circ_unbound(v)
		Formula.back =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_back(v)
						false => ease_in_back_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_back(v)
						false => ease_out_back_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_back(v)
						false => ease_in_out_back_unbound(v)
		Formula.elastic =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_elastic(v)
						false => ease_in_elastic_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_elastic(v)
						false => ease_out_elastic_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_elastic(v)
						false => ease_in_out_elastic_unbound(v)
		Formula.bounce =>
			switch effect
				Effect.ease_in =>
					switch bounded
						true  => ease_in_bounce(v)
						false => ease_in_bounce_unbound(v)
				Effect.ease_out =>
					switch bounded
						true  => ease_out_bounce(v)
						false => ease_out_bounce_unbound(v)
				Effect.ease_in_out =>
					switch bounded
						true  => ease_in_out_bounce(v)
						false => ease_in_out_bounce_unbound(v)

Formula f_ = input.enum(Formula.sine, 'Formula:')
Effect e_ = input.enum(Effect.ease_in, 'Effect:')
bool b_ = input.bool(true, 'Respect boundary:')
plot(select(v, f_, e_, b_), 'Easing Function:', #00eeff)

//#endregion	2.0
//#endregion	2
````
