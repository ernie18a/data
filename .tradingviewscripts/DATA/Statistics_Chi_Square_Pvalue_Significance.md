<!-- tradingview-pine-id: PUB;fff25d1fc2204733ad63617a623190f5 -->
<!-- tradingviewscripts-format: 1 -->
# Statistics • Chi Square • P-value • Significance

Source: https://www.tradingview.com/script/W0vYvqgB-Statistics-Chi-Square-P-value-Significance/

## Description

The Statistics • Chi Square • P-value • Significance publication aims to provide a tool for combining different conditions and checking whether the outcome is significant using the Chi-Square Test and P-value.

🔶 USAGE

The basic principle is to compare two or more groups and check the results of a query test, such as asking men and women whether they want to see a romantic or non-romantic movie.

[pine]
–––––––––––––––––––––––––––––––––––––––––––––
|       | ROMANTIC | NON-ROMANTIC | ⬅︎ MOVIE |
–––––––––––––––––––––––––––––––––––––––––––––
|  MEN  |     2    |       8      |    10    |
–––––––––––––––––––––––––––––––––––––––––––––
| WOMEN |     7    |       3      |    10    |
–––––––––––––––––––––––––––––––––––––––––––––
|⬆︎ SEX |    10    |      10      |    20    |
–––––––––––––––––––––––––––––––––––––––––––––
[/pine]

We calculate the Chi-Square Formula, which is:

Χ² = Σ ( (Observed Value − Expected Value)² / Expected Value )

In this publication, this is:

[pine]
    chiSquare = 0.
    for i = 0 to rows -1
        for j = 0 to colums -1

            observedValue = aBin.get(i).aFloat.get(j)
            expectedValue = math.max(1e-12, aBin.get(i).aFloat.get(colums) * aBin.get(rows).aFloat.get(j) / sumT) //Division by 0 protection

            chiSquare += math.pow(observedValue - expectedValue, 2) / expectedValue
[/pine]

Together with the 'Degree of Freedom', which is (rows − 1) × (columns − 1), the P-value can be calculated.

In this case it is P-value: 0.02462

A P-value lower than 0.05 is considered to be significant. Statistically, women tend to choose a romantic movie more, while men prefer a non-romantic one.

Users have the option to choose a P-value, calculated from a standard table or through a math.ucla.edu - Javascript-based function (see references below).

Note that the population (10 men + 10 women = 20) is small, something to consider.

Either way, this principle is applied in the script, where conditions can be chosen like rsi, close, high, ...

🔹 CONDITION

Conditions are added to the left column ('CONDITION')

For example, previous rsi values (rsi[1]) between 0-100, divided in separate groups

[image]https://www.tradingview.com/x/PWyyK8gn/[/image]

🔹 CLOSE

Then, the movement of the last close is evaluated

[*]UP when close is higher then previous close (close[1])
[*]DOWN when close is lower then previous close 
[*]EQUAL when close is equal then previous close 

It is also possible to use only 2 columns by adding EQUAL to UP or DOWN

[*]UP 
[*]DOWN/EQUAL 

or

[*]UP/EQUAL
[*]DOWN 

In other words, when previous rsi value was between 80 and 90, this resulted in:

[*]19 times a current close higher than previous close
[*]14 times a current close lower than previous close
[*] 0 times a current close equal than previous close

However, the P-value tells us it is not statistical significant.

NOTE: Always keep in mind that past behaviour gives no certainty about future behaviour.

A vertical line is drawn at the beginning of the chosen population (max 4990)

[image]https://www.tradingview.com/x/re5If5Qi/[/image]

Here, the results seem significant.

🔹 GROUPS

It is important to ensure that the groups are formed correctly. All possibilities should be present, and conditions should only be part of 1 group.

[image]https://www.tradingview.com/x/Sw8bqi8S/[/image]

In the example above, the two top situations are acceptable; close[1] against close[2] can only be higher, lower or equal.

The two examples at the bottom, however, are very poorly constructed. 

Several conditions can be placed in more than 1 group, and some conditions are not integrated into a group. Even if the results are significant, they are useless because of the group formation.

A population count is added as an aid to spot errors in group formation.

[image]https://www.tradingview.com/x/vv3VbgHS/[/image]

In this example, there is a discrepancy between the population and total count due to the absence of a condition. 

[image]https://www.tradingview.com/x/CpAfrfmo/[/image]

The results when rsi was between 5-25 are not included, resulting in unreliable results. 

🔹 PRACTICAL EXAMPLES

In this example, we have specific groups where the condition only applies to that group.
For example, the condition rsi > 55 and rsi <= 65 isn't true in another group.
Also, every possible rsi value (0 - 100) is present in 1 of the groups. 

rsi > 15 and rsi <= 25 28 times UP, 19 times DOWN and 2 times EQUAL. P-value: 0.01171

When looking in detail and examining the area 15-25 RSI, we see this:

[image]https://www.tradingview.com/x/XD8nLa9l/[/image]

The population is now not representative (only checking for RSI between 15-25; all other RSI values are not included), so we can ignore the P-value in this case. It is merely to check in detail. In this case, the RSI values 23 and 24 seem promising.

NOTE: We should check what the close price did without any condition.
If, for example, the close price had risen 100 times out of 100, this would make things very relative.

In this case (at least two conditions need to be present), we set 1 condition at 'always true' and another at 'always false' so we'll get only the close values without any condition:

[image]https://www.tradingview.com/x/0LQTHZ8H/[/image]

Changing the population or the conditions will change the P-value.

[image]https://www.tradingview.com/x/Utbiuiqi/[/image]

[image]https://www.tradingview.com/x/geJUlheI/[/image]

[image]https://www.tradingview.com/x/PWyyK8gn/[/image]

In the following example, the outcome is evaluated when:

[*]close value from 1 bar back is higher than the close value from 2 bars back
[*]close value from 1 bar back is lower/equal than the close value from 2 bars back

[image]https://www.tradingview.com/x/oGmZXO7d/[/image]

Or:

[*]close value from 1 bar back is higher than the close value from 2 bars back
[*]close value from 1 bar back is equal   than the close value from 2 bars back
[*]close value from 1 bar back is lower   than the close value from 2 bars back

[image]https://www.tradingview.com/x/xvXVsIna/[/image]

In both examples, all possibilities of close[1] against close[2] are included in the calculations. close[1] can only by higher, equal or lower than close[2]

Both examples have the results without a condition included (5 = 5 and 5 < 5) so one can compare the direction of current close.

🔶 NOTES

• Always keep in mind that:

[*] Past behaviour gives no certainty about future behaviour.
[*]Everything depends on time, cycles, events, fundamentals, technicals, ...

• This test only works for categorical data (data in categories), such as Gender {Men, Women} or color {Red, Yellow, Green, Blue} etc., but not numerical data such as height or weight. One might argue that such tests shouldn't use rsi, close, ... values.

• Consider what you're measuring 

For example rsi of the current bar will always lead to a close higher than the previous close, since this is inherent to the rsi calculations.

[image]https://www.tradingview.com/x/050rZLRC/[/image]

• Be careful; often, there are na-values at the beginning of the series, which are not included in the calculations!

[image]https://www.tradingview.com/x/qYN9AhoN/[/image]

• Always keep in mind considering what the close price did without any condition

• The numbers must be large enough. Each entry must be five or more. In other words, it is vital to make the 'population' large enough.

• The code can be developed further, for example, by splitting UP, DOWN in close UP 1-2%, close UP 2-3%, close UP 3-4%, ...

• rsi can be supplemented with stochRSI, MFI, sma, ema, ...

🔶 SETTINGS

🔹 Population

• Choose the population size; in other words, how many bars you want to go back to. If fewer bars are available than set, this will be automatically adjusted.

🔹 Inputs

At least two conditions need to be chosen.

[image]https://www.tradingview.com/x/SGBfIndJ/[/image]

• Users can add up to 11 conditions, where each condition can contain two different conditions.

🔹 RSI

• Length

🔹 Levels

• Set the used levels as desired.

🔹 Levels

• P-value: P-value retrieved using a standard table method or a function.

• Used function, derived from [Chi-Square Distribution Function; JavaScript](https://www.math.ucla.edu/~tom/distributions/chisq.html)

[pine]
LogGamma(Z) =>
	S = 1 
      + 76.18009173   / Z 
      - 86.50532033   / (Z+1)
      + 24.01409822   / (Z+2)
      - 1.231739516   / (Z+3)
      + 0.00120858003 / (Z+4)
      - 0.00000536382 / (Z+5)

	(Z-.5) * math.log(Z+4.5) - (Z+4.5) + math.log(S * 2.50662827465)

Gcf(float X, A) =>        // Good for X > A +1
	A0=0., B0=1., A1=1., B1=X, AOLD=0., N=0
	while (math.abs((A1-AOLD)/A1) > .00001) 
		AOLD := A1
		N    += 1
		A0   := A1+(N-A)*A0
		B0   := B1+(N-A)*B0
		A1   := X*A0+N*A1
		B1   := X*B0+N*B1
		A0   := A0/B1
		B0   := B0/B1
		A1   := A1/B1
		B1   := 1
	Prob      = math.exp(A * math.log(X) - X - LogGamma(A)) * A1
	1 - Prob

Gser(X, A) =>        // Good for X < A +1
	T9 = 1. / A
	G  = T9
	I  = 1
	while (T9 > G* 0.00001) 
		T9 := T9 * X / (A + I)
		G  := G + T9
		I  += 1
	
	G *= math.exp(A * math.log(X) - X - LogGamma(A))

Gammacdf(x, a) =>
	GI = 0.
	if (x<=0) 
		GI := 0
	else if (x<a+1) 
		GI := Gser(x, a)
	else 
		GI := Gcf(x, a)
	GI

compute(Z, DF) =>
    Chisqcdf  = Gammacdf(Z/2, DF/2)
	Chisqcdf := math.round(Chisqcdf * 100000) / 100000
    pValue    = 1 - Chisqcdf
[/pine]

🔶 REFERENCES

[*][mathsisfun.com, Chi-Square Test](https://www.mathsisfun.com/data/chi-square-test.html)
[*][Chi-Square Distribution Function](https://www.math.ucla.edu/~tom/distributions/chisq.html)

---

## Source Code

````pine
fi(ki)=>'ra' 
// © fikira This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/ 
// @version=5 

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------\
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------\
indicator            (                                        'Statistics • Chi Square • P-value • Significance'                                  , max_bars_back=5000)//      \
_                                                                                                                                                                                                                                                                        = '
                                                                                   Settings                                                
                                                                                 -------------                                                                                                                                                                                                 '

back   = input.int   (4000               ,                                       'Population'                 ,                                     minval=10 , maxval=4990     )

outcome= input.string('UP - DOWN - EQUAL', options=['UP - DOWN - EQUAL', 'UP - DOWN/EQUAL', 'UP/EQUAL - DOWN'])

src1_a = input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 1' )
bck1_a = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 1' )
opr1_a = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 1' )
src2_a = input.string('level 10', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 1' )
bck2_a = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 1' )
_and_a_= input.bool(false, 'and', group='Input 1')
src1_a_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 1' )
bck1_a_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 1' )
opr1_a_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 1' )
src2_a_= input.string('level 11', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 1' )
bck2_a_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 1' )
 
src1_b = input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 2' )
bck1_b = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 2' )
opr1_b = input.string('>','                          ', options=['<', '<=', '=', '>', '>=']                                                       , inline='2', group='Input 2' )
src2_b = input.string('level 9', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 2' )
bck2_b = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 2' )
_and_b_= input.bool(true, 'and', group='Input 2')
src1_b_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 2' )
bck1_b_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 2' )
opr1_b_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 2' )
src2_b_= input.string('level 10', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 2' )
bck2_b_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 2' )

tog1_c = input.bool(true , ''                                                                                                                     , inline='1', group='Input 3' )
src1_c = input.string('rsi','', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 3' )
bck1_c = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 3' )
opr1_c = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 3' )
src2_c = input.string('level 8','         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 3' )
bck2_c = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 3' )
_and_c_= input.bool(true, 'and', group='Input 3')
src1_c_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 3' )
bck1_c_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 3' )
opr1_c_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 3' )
src2_c_= input.string('level 9', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 3' )
bck2_c_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 3' )

tog1_d = input.bool(true, ''                                                                                                                      , inline='1', group='Input 4' )
src1_d = input.string('rsi','', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 4' )
bck1_d = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 4' )
opr1_d = input.string('>','                          ', options=['<', '<=', '=', '>', '>=']                                                       , inline='2', group='Input 4' )
src2_d = input.string('level 7', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 4' )
bck2_d = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 4' )
_and_d_= input.bool(true, 'and', group='Input 4')
src1_d_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 4' )
bck1_d_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 4' )
opr1_d_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 4' )
src2_d_= input.string('level 8', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 4' )
bck2_d_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 4' )

tog1_e = input.bool(true, ''                                                                                                                      , inline='1', group='Input 5' )
src1_e = input.string('rsi', '', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 5' )
bck1_e = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 5' )
opr1_e = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 5' )
src2_e = input.string('level 6', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 5' )
bck2_e = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 5' )
_and_e_= input.bool(true, 'and', group='Input 5')
src1_e_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 5' )
bck1_e_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 5' )
opr1_e_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 5' )
src2_e_= input.string('level 7', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 5' )
bck2_e_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 5' )

tog1_f = input.bool(true, ''                                                                                                                      , inline='1', group='Input 6' )
src1_f = input.string('rsi', '', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 6' )
bck1_f = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 6' )
opr1_f = input.string('>','                          ', options=['<', '<=', '=', '>', '>=']                                                       , inline='2', group='Input 6' )
src2_f = input.string('level 5', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 6' )
bck2_f = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 6' )
_and_f_= input.bool(true, 'and', group='Input 6')
src1_f_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 6' )
bck1_f_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 6' )
opr1_f_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 6' )
src2_f_= input.string('level 6', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 6' )
bck2_f_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 6' )

tog1_g = input.bool(true, ''                                                                                                                      , inline='1', group='Input 7' )
src1_g = input.string('rsi','', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 7' )
bck1_g = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 7' )
opr1_g = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 7' )
src2_g = input.string('level 4','         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 7' )
bck2_g = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 7' )
_and_g_= input.bool(true, 'and', group='Input 7')
src1_g_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 7' )
bck1_g_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 7' )
opr1_g_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 7' )
src2_g_= input.string('level 5', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 7' )
bck2_g_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 7' )

tog1_h = input.bool(true, ''                                                                                                                      , inline='1', group='Input 8' )
src1_h = input.string('rsi', '', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 8' )
bck1_h = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 8' )
opr1_h = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 8' )
src2_h = input.string('level 3', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 8' )
bck2_h = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 8' )
_and_h_= input.bool(true, 'and', group='Input 8')
src1_h_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 8' )
bck1_h_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 8' )
opr1_h_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 8' )
src2_h_= input.string('level 4', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 8' )
bck2_h_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 8' )

tog1_i = input.bool(true, ''                                                                                                                      , inline='1', group='Input 9' )
src1_i = input.string('rsi', '', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 9' )
bck1_i = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 9' )
opr1_i = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 9' )
src2_i = input.string('level 2', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 9' )
bck2_i = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 9' )
_and_i_= input.bool(true, 'and', group='Input 9')
src1_i_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 9' )
bck1_i_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 9' )
opr1_i_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 9' )
src2_i_= input.string('level 3', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 9' )
bck2_i_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 9' )

tog1_j = input.bool(true, ''                                                                                                                      , inline='1', group='Input 10')
src1_j = input.string('rsi', '', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 10')
bck1_j = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 10')
opr1_j = input.string('>', '                          ', options=['<', '<=', '=', '>', '>=']                                                      , inline='2', group='Input 10')
src2_j = input.string('level 1','         ',options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 10')
bck2_j = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 10')
_and_j_= input.bool(true, 'and', group='Input 10')
src1_j_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 10')
bck1_j_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 10')
opr1_j_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 10')
src2_j_= input.string('level 2', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 10')
bck2_j_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 10')

tog1_k = input.bool(true, ''                                                                                                                      , inline='1', group='Input 11')
src1_k = input.string('rsi', '', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='1', group='Input 11')
bck1_k = input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='1', group='Input 11')
opr1_k = input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='2', group='Input 11')
src2_k = input.string('level 1','         ',options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='3', group='Input 11')
bck2_k = input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='3', group='Input 11')
_and_k_= input.bool(false, 'and', group='Input 11')
src1_k_= input.string('rsi', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='4', group='Input 11')
bck1_k_= input.int(1, '[…]', minval=0, maxval=10                                                                                                  , inline='4', group='Input 11')
opr1_k_= input.string('<=', '                          ', options=['<', '<=', '=', '>', '>=']                                                     , inline='5', group='Input 11')
src2_k_= input.string('level 1', '         ', options=['open', 'high', 'low', 'close', 'rsi'
                     , 'level 1', 'level 2', 'level 3', 'level 4', 'level 5', 'level 6', 'level 7' , 'level 8', 'level 9', 'level 10', 'level 11'], inline='6', group='Input 11')
bck2_k_= input.int(2, '[…]', minval=0, maxval=10                                                                                                  , inline='6', group='Input 11')

len    = input.int(14, 'Length', group='RSI')

level1 = input.float(  5, 'level 1' , minval=0, step=1)
level2 = input.float( 15, 'level 2' , minval=0, step=1)
level3 = input.float( 25, 'level 3' , minval=0, step=1)
level4 = input.float( 35, 'level 4' , minval=0, step=1)
level5 = input.float( 45, 'level 5' , minval=0, step=1)
level6 = input.float( 55, 'level 6' , minval=0, step=1)
level7 = input.float( 65, 'level 7' , minval=0, step=1)
level8 = input.float( 75, 'level 8' , minval=0, step=1)
level9 = input.float( 85, 'level 9' , minval=0, step=1)
level10= input.float( 95, 'level 10', minval=0, step=1)
level11= input.float(100, 'level 11', minval=0, step=1)

iP     = input.string('function', 'method', ['function', 'table'], group='P-value')
_                                                                                                                                                                                                                                                                       = '
                                                                                          UDT                                               
                                                                                       --------                                                                                                                                                                                                '

type row 
    array<float> aFloat 
_                                                                                                                                                                                                                                                                        = '
                                                                                       Variables                                               
                                                                                      -----------                                                                                                                                                                                                '

INV   = color(na)
aBin  = array.new<row>()
count = array.from(0)
var table tb = table(na)
var tableP = array.new<row>() 

var aRSI = array.new<float>() 
rsi = ta.rsi(close, len)
aRSI.unshift(rsi)
if aRSI.size() > back + 10
    aRSI.pop() 

maxBack = array.max(array.from(bck1_a , bck1_b , bck1_c , bck1_d , bck1_e , bck1_f , bck1_g , bck1_h , bck1_i , bck1_j , bck1_k 
                             , bck1_a_, bck1_b_, bck1_c_, bck1_d_, bck1_e_, bck1_f_, bck1_g_, bck1_h_, bck1_i_, bck1_j_, bck1_k_
                             , bck2_a , bck2_b , bck2_c , bck2_d , bck2_e , bck2_f , bck2_g , bck2_h , bck2_i , bck2_j , bck2_k
                             , bck2_a_, bck2_b_, bck2_c_, bck2_d_, bck2_e_, bck2_f_, bck2_g_, bck2_h_, bck2_i_, bck2_j_, bck2_k_
                              )
                   )
_                                                                                                                                                                                                                                                                        = '
                                                                                   Methods / Functions                                               
                                                                                 -----------------------                                                                                                                                                                                                '

//P-Values
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------\
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------\
//Function Method                                                                                                                                                              \
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------\
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------\
// https://www.math.ucla.edu/~tom/distributions/chisq.html (Chi-Square Distribution Function; JavaScript)                                                                  \

LogGamma(Z) =>
	S = 1 
      + 76.18009173   / Z 
      - 86.50532033   / (Z+1)
      + 24.01409822   / (Z+2)
      - 1.231739516   / (Z+3)
      + 0.00120858003 / (Z+4)
      - 0.00000536382 / (Z+5)

	(Z-.5) * math.log(Z+4.5) - (Z+4.5) + math.log(S * 2.50662827465)

Gcf(float X, A) =>        // Good for X > A +1
	A0=0., B0=1., A1=1., B1=X, AOLD=0., N=0
	while (math.abs((A1-AOLD)/A1) > .00001) 
		AOLD := A1
		N    += 1
		A0   := A1+(N-A)*A0
		B0   := B1+(N-A)*B0
		A1   := X*A0+N*A1
		B1   := X*B0+N*B1
		A0   := A0/B1
		B0   := B0/B1
		A1   := A1/B1
		B1   := 1
	Prob      = math.exp(A * math.log(X) - X - LogGamma(A)) * A1
	1 - Prob

Gser(X, A) =>        // Good for X < A +1
	T9 = 1. / A
	G  = T9
	I  = 1
	while (T9 > G* 0.00001) 
		T9 := T9 * X / (A + I)
		G  := G + T9
		I  += 1
	
	G *= math.exp(A * math.log(X) - X - LogGamma(A))

Gammacdf(x, a) =>
	GI = 0.
	if (x<=0) 
		GI := 0
	else if (x<a+1) 
		GI := Gser(x, a)
	else 
		GI := Gcf(x, a)
	GI

compute(Z, DF) =>
    Chisqcdf  = Gammacdf(Z/2, DF/2)
	Chisqcdf := math.round(Chisqcdf * 100000) / 100000
    pValue    = 1 - Chisqcdf
//                                                                                                                                                                         /            
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------/
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------/
//Classic Table Method                                                                                                                                                  |
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------\
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------\
if barstate.isfirst                                                                                                    //                                                  \                  
    tableP.push(row.new(array.from( 1, 0.0000397, 0.000157,	 0.000982, 0.00393, 0.0158, 0.455 , 1.642 , 2.706 , 3.841 , 5.024 , 5.412 ,  6.635,  7.879,  9.550, 10.828)))
    tableP.push(row.new(array.from( 2, 0.0100   , 0.020   ,  0.051   , 0.103  , 0.211 , 1.386 , 3.219 , 4.605 , 5.991 , 7.378 , 7.824 ,  9.210, 10.597, 12.429, 13.816)))
    tableP.push(row.new(array.from( 3, 0.072    , 0.115   ,  0.216   , 0.352  , 0.584 , 2.366 , 4.642 , 6.251 , 7.815 , 9.348 , 9.837 , 11.345, 12.838, 14.796, 16.266)))
    tableP.push(row.new(array.from( 4, 0.207    , 0.297   ,  0.484   , 0.711  , 1.064 , 3.357 , 5.989 , 7.779 , 9.488 , 11.143, 11.668, 13.277, 14.860, 16.924, 18.467)))
    tableP.push(row.new(array.from( 5, 0.412    , 0.554   ,  0.831   , 1.145  , 1.610 , 4.351 , 7.289 , 9.236 , 11.070, 12.833, 13.388, 15.086, 16.750, 18.907, 20.515)))
    tableP.push(row.new(array.from( 6, 0.676    , 0.872   ,  1.237   , 1.635  , 2.204 , 5.348 , 8.558 , 10.645, 12.592, 14.449, 15.033, 16.812, 18.548, 20.791, 22.458)))
    tableP.push(row.new(array.from( 7, 0.989    , 1.239   ,  1.690   , 2.167  , 2.833 , 6.346 , 9.803 , 12.017, 14.067, 16.013, 16.622, 18.475, 20.278, 22.601, 24.322)))
    tableP.push(row.new(array.from( 8, 1.344    , 1.646   ,  2.180   , 2.733  , 3.490 , 7.344 , 11.030, 13.362, 15.507, 17.535, 18.168, 20.090, 21.955, 24.352, 26.124)))
    tableP.push(row.new(array.from( 9, 1.735    , 2.088   ,  2.700   , 3.325  , 4.168 , 8.343 , 12.242, 14.684, 16.919, 19.023, 19.679, 21.666, 23.589, 26.056, 27.877)))
    tableP.push(row.new(array.from(10, 2.156    , 2.558   ,  3.247   , 3.940  , 4.865 , 9.342 , 13.442, 15.987, 18.307, 20.483, 21.161, 23.209, 25.188, 27.722, 29.588)))
    tableP.push(row.new(array.from(11, 2.603    , 3.053   ,  3.816   , 4.575  , 5.578 , 10.341, 14.631, 17.275, 19.675, 21.920, 22.618, 24.725, 26.757, 29.354, 31.264)))
    tableP.push(row.new(array.from(12, 3.074    , 3.571   ,  4.404   , 5.226  , 6.304 , 11.340, 15.812, 18.549, 21.026, 23.337, 24.054, 26.217, 28.300, 30.957, 32.909)))
    tableP.push(row.new(array.from(13, 3.565    , 4.107   ,  5.009   , 5.892  , 7.042 , 12.340, 16.985, 19.812, 22.362, 24.736, 25.472, 27.688, 29.819, 32.535, 34.528)))
    tableP.push(row.new(array.from(14, 4.075    , 4.660   ,  5.629   , 6.571  , 7.790 , 13.339, 18.151, 21.064, 23.685, 26.119, 26.873, 29.141, 31.319, 34.091, 36.123)))
    tableP.push(row.new(array.from(15, 4.601    , 5.229   ,  6.262   , 7.261  , 8.547 , 14.339, 19.311, 22.307, 24.996, 27.488, 28.259, 30.578, 32.801, 35.628, 37.697)))
    tableP.push(row.new(array.from(16, 5.142    , 5.812   ,  6.908   , 7.962  , 9.312 , 15.338, 20.465, 23.542, 26.296, 28.845, 29.633, 32.000, 34.267, 37.146, 39.252)))
    tableP.push(row.new(array.from(17, 5.697    , 6.408   ,  7.564   , 8.672  , 10.085, 16.338, 21.615, 24.769, 27.587, 30.191, 30.995, 33.409, 35.718, 38.648, 40.790)))
    tableP.push(row.new(array.from(18, 6.265    , 7.015   ,  8.231   , 9.390  , 10.865, 17.338, 22.760, 25.989, 28.869, 31.526, 32.346, 34.805, 37.156, 40.136, 42.312)))
    tableP.push(row.new(array.from(19, 6.844    , 7.633   ,  8.907   , 10.117 , 11.651, 18.338, 23.900, 27.204, 30.144, 32.852, 33.687, 36.191, 38.582, 41.610, 43.820)))
    tableP.push(row.new(array.from(20, 7.434    , 8.260   ,  9.591   , 10.851 , 12.443, 19.337, 25.038, 28.412, 31.410, 34.170, 35.020, 37.566, 39.997, 43.072, 45.315)))
    tableP.push(row.new(array.from(21, 8.034	, 8.897	  , 10.283   , 11.591 , 13.240, 20.337, 26.171, 29.615, 32.671, 35.479, 36.343, 38.932, 41.401, 44.522, 46.797)))
    tableP.push(row.new(array.from(22, 8.643	, 9.542	  , 10.982   , 12.338 , 14.041, 21.337, 27.301, 30.813, 33.924, 36.781, 37.659, 40.289, 42.796, 45.962, 48.268)))
    tableP.push(row.new(array.from(23, 9.260	, 10.196  , 11.689   , 13.091 , 14.848, 22.337, 28.429, 32.007, 35.172, 38.076, 38.968, 41.638, 44.181, 47.391, 49.728)))
    tableP.push(row.new(array.from(24, 9.886	, 10.856  , 12.401   , 13.848 , 15.659, 23.337, 29.553, 33.196, 36.415, 39.364, 40.270, 42.980, 45.559, 48.812, 51.179)))
    tableP.push(row.new(array.from(25, 10.520   , 11.524  , 13.120   , 14.611 , 16.473, 24.337, 30.675, 34.382, 37.652, 40.646, 41.566, 44.314, 46.928, 50.223, 52.620)))
    tableP.push(row.new(array.from(26, 11.160   , 12.198  , 13.844   , 15.379 , 17.292, 25.336, 31.795, 35.563, 38.885, 41.923, 42.856, 45.642, 48.290, 51.627, 54.052)))
    tableP.push(row.new(array.from(27, 11.808   , 12.879  , 14.573   , 16.151 , 18.114, 26.336, 32.912, 36.741, 40.113, 43.195, 44.140, 46.963, 49.645, 53.023, 55.476)))
    tableP.push(row.new(array.from(28, 12.461   , 13.565  , 15.308   , 16.928 , 18.939, 27.336, 34.027, 37.916, 41.337, 44.461, 45.419, 48.278, 50.993, 54.411, 56.892)))
    tableP.push(row.new(array.from(29, 13.121   , 14.256  , 16.047   , 17.708 , 19.768, 28.336, 35.139, 39.087, 42.557, 45.722, 46.693, 49.588, 52.336, 55.792, 58.301)))
    tableP.push(row.new(array.from(30, 13.787   , 14.953  , 16.791   , 18.493 , 20.599, 29.336, 36.250, 40.256, 43.773, 46.979, 47.962, 50.892, 53.672, 57.167, 59.703)))
    tableP.push(row.new(array.from(31, 14.458   , 15.655  , 17.539   , 19.281 , 21.434, 30.336, 37.359, 41.422, 44.985, 48.232, 49.226, 52.191, 55.003, 58.536, 61.098)))
    tableP.push(row.new(array.from(32, 15.134   , 16.362  , 18.291   , 20.072 , 22.271, 31.336, 38.466, 42.585, 46.194, 49.480, 50.487, 53.486, 56.328, 59.899, 62.487)))
    tableP.push(row.new(array.from(33, 15.815   , 17.074  , 19.047   , 20.867 , 23.110, 32.336, 39.572, 43.745, 47.400, 50.725, 51.743, 54.776, 57.648, 61.256, 63.870)))
    tableP.push(row.new(array.from(34, 16.501   , 17.789  , 19.806   , 21.664 , 23.952, 33.336, 40.676, 44.903, 48.602, 51.966, 52.995, 56.061, 58.964, 62.608, 65.247)))
    tableP.push(row.new(array.from(35, 17.192   , 18.509  , 20.569   , 22.465 , 24.797, 34.336, 41.778, 46.059, 49.802, 53.203, 54.244, 57.342, 60.275, 63.955, 66.619)))
    tableP.push(row.new(array.from(36, 17.887   , 19.233  , 21.336   , 23.269 , 25.643, 35.336, 42.879, 47.212, 50.998, 54.437, 55.489, 58.619, 61.581, 65.296, 67.985)))
    tableP.push(row.new(array.from(37, 18.586   , 19.960  , 22.106   , 24.075 , 26.492, 36.336, 43.978, 48.363, 52.192, 55.668, 56.730, 59.892, 62.883, 66.633, 69.346)))
    tableP.push(row.new(array.from(38, 19.289   , 20.691  , 22.878   , 24.884 , 27.343, 37.335, 45.076, 49.513, 53.384, 56.896, 57.969, 61.162, 64.181, 67.966, 70.703)))
    tableP.push(row.new(array.from(39, 19.996   , 21.426  , 23.654   , 25.695 , 28.196, 38.335, 46.173, 50.660, 54.572, 58.120, 59.204, 62.428, 65.476, 69.294, 72.055)))
    tableP.push(row.new(array.from(40, 20.707   , 22.164  , 24.433   , 26.509 , 29.051, 39.335, 47.269, 51.805, 55.758, 59.342, 60.436, 63.691, 66.766, 70.618, 73.402)))
    tableP.push(row.new(array.from(41, 21.421   , 22.906  , 25.215   , 27.326 , 29.907, 40.335, 48.363, 52.949, 56.942, 60.561, 61.665, 64.950, 68.053, 71.938, 74.745)))
    tableP.push(row.new(array.from(42, 22.138   , 23.650  , 25.999   , 28.144 , 30.765, 41.335, 49.456, 54.090, 58.124, 61.777, 62.892, 66.206, 69.336, 73.254, 76.084)))
    tableP.push(row.new(array.from(43, 22.859   , 24.398  , 26.785   , 28.965 , 31.625, 42.335, 50.548, 55.230, 59.304, 62.990, 64.116, 67.459, 70.616, 74.566, 77.419)))
    tableP.push(row.new(array.from(44, 23.584   , 25.148  , 27.575   , 29.787 , 32.487, 43.335, 51.639, 56.369, 60.481, 64.201, 65.337, 68.710, 71.893, 75.874, 78.750)))
    tableP.push(row.new(array.from(45, 24.311   , 25.901  , 28.366   , 30.612 , 33.350, 44.335, 52.729, 57.505, 61.656, 65.410, 66.555, 69.957, 73.166, 77.179, 80.077)))
    tableP.push(row.new(array.from(46, 25.041   , 26.657  , 29.160   , 31.439 , 34.215, 45.335, 53.818, 58.641, 62.830, 66.617, 67.771, 71.201, 74.437, 78.481, 81.400)))
    tableP.push(row.new(array.from(47, 25.775   , 27.416  , 29.956   , 32.268 , 35.081, 46.335, 54.906, 59.774, 64.001, 67.821, 68.985, 72.443, 75.704, 79.780, 82.720)))
    tableP.push(row.new(array.from(48, 26.511   , 28.177  , 30.755   , 33.098 , 35.949, 47.335, 55.993, 60.907, 65.171, 69.023, 70.197, 73.683, 76.969, 81.075, 84.037)))
    tableP.push(row.new(array.from(49, 27.249   , 28.941  , 31.555   , 33.930 , 36.818, 48.335, 57.079, 62.038, 66.339, 70.222, 71.406, 74.919, 78.231, 82.367, 85.351)))
    tableP.push(row.new(array.from(50, 27.991   , 29.707  , 32.357   , 34.764 , 37.689, 49.335, 58.164, 63.167, 67.505, 71.420, 72.613, 76.154, 79.490, 83.657, 86.661)))

    tableP.push(row.new(array.from(51, 0.995    , 0.99    , 0.975    , 0.95   , 0.9   , 0.5   , 0.2   , 0.1   , 0.05   , 0.025, 0.02  , 0.01  , 0.005 , 0.002 ,  0.001)))// /
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------/
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------/  
//                                                                                                                                                                              /                                                                                                                                                                      
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------/
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------/

f_push(arr) =>
    arr.push(0.)
    aBin.push(row.new(arr)), count.set(0, count.get(0) + 1)

f_condition(src1, bck1, op, src2, bck2, i) =>
    source1 = switch src1 
        'open'    => open [bck1 + i]
        'high'    => high [bck1 + i]
        'low'     => low  [bck1 + i]
        'close'   => close[bck1 + i] 
        'rsi'     => aRSI.get(bck1 + i) 
        'level 1' => level1 
        'level 2' => level2 
        'level 3' => level3 
        'level 4' => level4 
        'level 5' => level5 
        'level 6' => level6 
        'level 7' => level7 
        'level 8' => level8 
        'level 9' => level9 
        'level 10'=> level10 
        'level 11'=> level11

    source2 = switch src2 
        'open'    => open [bck2 + i]
        'high'    => high [bck2 + i]
        'low'     => low  [bck2 + i]
        'close'   => close[bck2 + i] 
        'rsi'     => aRSI.get(bck2 + i) 
        'level 1' => level1 
        'level 2' => level2 
        'level 3' => level3 
        'level 4' => level4 
        'level 5' => level5 
        'level 6' => level6 
        'level 7' => level7 
        'level 8' => level8 
        'level 9' => level9 
        'level 10'=> level10 
        'level 11'=> level11

    out = switch op
        '<'  => source1 <  source2
        '<=' => source1 <= source2
        '='  => source1 == source2
        '>'  => source1 >  source2
        '>=' => source1 >= source2

    out
 
method f_add(array<bool>arr, tog, src1, bck1, opr1, src2, bck2, and_, src1_, bck1_, opr1_, src2_, bck2_, i) => 
    if tog
        cond1 =        f_condition(src1 , bck1 , opr1 , src2 , bck2 , i)
        cond2 = and_ ? f_condition(src1_, bck1_, opr1_, src2_, bck2_, i) : true
        arr.push(cond1 and cond2)

method f_bracket(string s, src, num) => str = str.contains(src, 'level') or num == 0  ? '' : s 

method f_level(string src) => 
    out = ''
    if str.contains(src, 'level') 
        out := switch src 
            'level 1' => str.tostring(level1 )
            'level 2' => str.tostring(level2 )
            'level 3' => str.tostring(level3 )
            'level 4' => str.tostring(level4 )
            'level 5' => str.tostring(level5 )
            'level 6' => str.tostring(level6 )
            'level 7' => str.tostring(level7 )
            'level 8' => str.tostring(level8 )
            'level 9' => str.tostring(level9 )
            'level 10'=> str.tostring(level10)
            'level 11'=> str.tostring(level11)

    else 
        out := src

method f_back(string s, src) => str = str.contains(s, 'level') or src == 0 ? '' : str.tostring(src)

method f_addToTable(table tb, bool tog, int cnt, src1, bck1, opr1, src2, bck2, and_, src1_, bck1_, opr1_, src2_, bck2_) => 
    if tog

        str1 =        str.format(     "{0}{1}{2}{3} {4} {5}{6}{7}{8}"
                     , src1 .f_level(), '['.f_bracket(src1 , bck1 ), src1 .f_back(bck1 ), ']'.f_bracket(src1 , bck1 )
                     , opr1
                     , src2 .f_level(), '['.f_bracket(src2 , bck2 ), src2 .f_back(bck2 ), ']'.f_bracket(src2 , bck2 )
                     )
        str2 = and_ ? str.format(" and {0}{1}{2}{3} {4} {5}{6}{7}{8}"
                     , src1_.f_level(), '['.f_bracket(src1_, bck1_), src1_.f_back(bck1_), ']'.f_bracket(src1_, bck1_)
                     , opr1_
                     , src2_.f_level(), '['.f_bracket(src2_, bck2_), src2_.f_back(bck2_), ']'.f_bracket(src2_, bck2_)
                     ) : ''

        tb.cell    (0, cnt, str1 + str2
                     , text_color=color.aqua)
    tog
_                                                                                                                                                                                                                                                                        = '
                                                                                   Execution                                               
                                                                                 --------------                                                                                                                                                                                                '

//------------------------------------\
//-------------------------------------\
Y = 2              //                   \
  + (tog1_c ? 1 : 0) 
  + (tog1_d ? 1 : 0) 
  + (tog1_e ? 1 : 0) 
  + (tog1_f ? 1 : 0) 
  + (tog1_g ? 1 : 0) 
  + (tog1_h ? 1 : 0) 
  + (tog1_i ? 1 : 0) 
  + (tog1_j ? 1 : 0) 
  + (tog1_k ? 1 : 0) 
X = outcome =='UP - DOWN - EQUAL' ? 3 : 2
//                                      /
//-------------------------------------/
//------------------------------------/

for i = 0 to Y -1 
    arr = array.from(0.)
    for y = 1 to X -1
        arr.push(0.)
    f_push(arr)

aBin.push(row.new(array.from(  0.)))
setSize = aBin.get(0).aFloat.size()

for i = 1 to setSize
    aBin.last().aFloat.push(0.)

rows             = count.first()
colums           = setSize -1
degreesOfFreedom = (rows - 1) * (colums - 1)

if barstate.isfirst 
    tb := table.new(position.top_right, colums+2, rows+5, color(na), color.silver, 1, color.silver, 1)
    tb.merge_cells(0, rows+2, colums+1, rows+2)
    tb.merge_cells(0, rows+3, colums+1, rows+3)
    tb.merge_cells(0, rows+4, colums+1, rows+4)

if barstate.islast
    line.new(bar_index - back, -1, bar_index - back, 1, extend=extend.both, color=color.silver)

    arrX = array.new<bool>()
    
    int pop = 0
    //Fill
    for i = 0 to back -1 
        if na(close[i+maxBack])
            break 
        else
            pop += 1
            //-------------------------------------------------------------------------------------------------------------\
            //--------------------------------------------------------------------------------------------------------------\
            arrY = array.new<bool>()//                                                                                       \
            arrY.f_add(true  , src1_a, bck1_a, opr1_a, src2_a, bck2_a, _and_a_, src1_a_, bck1_a_, opr1_a_, src2_a_, bck2_a_, i)
            arrY.f_add(true  , src1_b, bck1_b, opr1_b, src2_b, bck2_b, _and_b_, src1_b_, bck1_b_, opr1_b_, src2_b_, bck2_b_, i)
            arrY.f_add(tog1_c, src1_c, bck1_c, opr1_c, src2_c, bck2_c, _and_c_, src1_c_, bck1_c_, opr1_c_, src2_c_, bck2_c_, i)
            arrY.f_add(tog1_d, src1_d, bck1_d, opr1_d, src2_d, bck2_d, _and_d_, src1_d_, bck1_d_, opr1_d_, src2_d_, bck2_d_, i)
            arrY.f_add(tog1_e, src1_e, bck1_e, opr1_e, src2_e, bck2_e, _and_e_, src1_e_, bck1_e_, opr1_e_, src2_e_, bck2_e_, i)
            arrY.f_add(tog1_f, src1_f, bck1_f, opr1_f, src2_f, bck2_f, _and_f_, src1_f_, bck1_f_, opr1_f_, src2_f_, bck2_f_, i)
            arrY.f_add(tog1_g, src1_g, bck1_g, opr1_g, src2_g, bck2_g, _and_g_, src1_g_, bck1_g_, opr1_g_, src2_g_, bck2_g_, i)
            arrY.f_add(tog1_h, src1_h, bck1_h, opr1_h, src2_h, bck2_h, _and_h_, src1_h_, bck1_h_, opr1_h_, src2_h_, bck2_h_, i)
            arrY.f_add(tog1_i, src1_i, bck1_i, opr1_i, src2_i, bck2_i, _and_i_, src1_i_, bck1_i_, opr1_i_, src2_i_, bck2_i_, i)
            arrY.f_add(tog1_j, src1_j, bck1_j, opr1_j, src2_j, bck2_j, _and_j_, src1_j_, bck1_j_, opr1_j_, src2_j_, bck2_j_, i)
            arrY.f_add(tog1_k, src1_k, bck1_k, opr1_k, src2_k, bck2_k, _and_k_, src1_k_, bck1_k_, opr1_k_, src2_k_, bck2_k_, i)
            arrX := switch outcome
                'UP - DOWN - EQUAL' => array.from(close[i] >  close[i+1], close[i] <  close[i+1], close[i] == close[i+1])
                'UP - DOWN/EQUAL'   => array.from(close[i] >  close[i+1], close[i] <= close[i+1])
                'UP/EQUAL - DOWN'   => array.from(close[i] >= close[i+1], close[i] <  close[i+1])          //                /
            //--------------------------------------------------------------------------------------------------------------/
            //-------------------------------------------------------------------------------------------------------------/

            //aSizeY1 = arrY1.size()
            for j = 0 to arrY.size()-1 
                if arrY.get(j)
                    for k = 0 to arrX.size() -1
                        if arrX.get(k)
                            aBin.get(j).aFloat.set(k, aBin.get(j).aFloat.get(k) + 1)
                            break
                    //break 

    //sum of rows 
    for i = 0 to rows
        aBin.get(i).aFloat.set(colums, aBin.get(i).aFloat.slice(0, colums).sum())

    for i = 0 to colums
        sum = 0. 
        for j = 0 to rows 
            sum += aBin.get(j).aFloat.get(i)
        aBin.get(rows).aFloat.set(i, sum)

    sumT = aBin.get(rows).aFloat.get(colums)
    
    chiSquare = 0.
    for i = 0 to rows -1
        for j = 0 to colums -1

            observedValue = aBin.get(i).aFloat.get(j)
            expectedValue = math.max(1e-12, aBin.get(i).aFloat.get(colums) * aBin.get(rows).aFloat.get(j) / sumT) //Division by 0 protection

            chiSquare += math.pow(observedValue - expectedValue, 2) / expectedValue


    if degreesOfFreedom > 50 
        tb.cell(0, 0, '"Degrees Of Freedom" too high', text_color=#FF0000)
    else
        cnt = 1
        //-------------------------------------------------------------------------------------------\
        //--------------------------------------------------------------------------------------------\
        split = str.split(outcome, " - ")//                                                            \                                                                         
        if arrX.size() == 3
            tb.cell(cnt, 0, split.first(), text_color=color.aqua), cnt +=1                                                
            tb.cell(cnt, 0, split.get (1), text_color=color.aqua), cnt +=1
            tb.cell(cnt, 0, split.last( ), text_color=color.aqua), cnt +=1
            tb.cell(cnt, 0, '⬅︎ CLOSE', text_color=color.aqua, bgcolor= color.new(color.silver, 90))
        else 
            tb.cell(cnt, 0, split.first(), text_color=color.aqua), cnt +=1
            tb.cell(cnt, 0, split.last (), text_color=color.aqua), cnt +=1
            tb.cell(cnt, 0, '⬅︎ CLOSE', text_color=color.aqua, bgcolor= color.new(color.silver, 90))
        //                                                                                             /
        //--------------------------------------------------------------------------------------------/
        //-------------------------------------------------------------------------------------------/

        cnt := 1
        //-------------------------------------------------------------------------------------------------------------------------------------\
        //--------------------------------------------------------------------------------------------------------------------------------------\
        //                                                                                                                                       \
        cnt += tb.f_addToTable(true  , cnt, src1_a, bck1_a, opr1_a, src2_a, bck2_a, _and_a_, src1_a_, bck1_a_, opr1_a_, src2_a_, bck2_a_) ? 1 : 0
        cnt += tb.f_addToTable(true  , cnt, src1_b, bck1_b, opr1_b, src2_b, bck2_b, _and_b_, src1_b_, bck1_b_, opr1_b_, src2_b_, bck2_b_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_c, cnt, src1_c, bck1_c, opr1_c, src2_c, bck2_c, _and_c_, src1_c_, bck1_c_, opr1_c_, src2_c_, bck2_c_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_d, cnt, src1_d, bck1_d, opr1_d, src2_d, bck2_d, _and_d_, src1_d_, bck1_d_, opr1_d_, src2_d_, bck2_d_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_e, cnt, src1_e, bck1_e, opr1_e, src2_e, bck2_e, _and_e_, src1_e_, bck1_e_, opr1_e_, src2_e_, bck2_e_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_f, cnt, src1_f, bck1_f, opr1_f, src2_f, bck2_f, _and_f_, src1_f_, bck1_f_, opr1_f_, src2_f_, bck2_f_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_g, cnt, src1_g, bck1_g, opr1_g, src2_g, bck2_g, _and_g_, src1_g_, bck1_g_, opr1_g_, src2_g_, bck2_g_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_h, cnt, src1_h, bck1_h, opr1_h, src2_h, bck2_h, _and_h_, src1_h_, bck1_h_, opr1_h_, src2_h_, bck2_h_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_i, cnt, src1_i, bck1_i, opr1_i, src2_i, bck2_i, _and_i_, src1_i_, bck1_i_, opr1_i_, src2_i_, bck2_i_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_j, cnt, src1_j, bck1_j, opr1_j, src2_j, bck2_j, _and_j_, src1_j_, bck1_j_, opr1_j_, src2_j_, bck2_j_) ? 1 : 0
        cnt += tb.f_addToTable(tog1_k, cnt, src1_k, bck1_k, opr1_k, src2_k, bck2_k, _and_k_, src1_k_, bck1_k_, opr1_k_, src2_k_, bck2_k_) ? 1 : 0
        tb.cell(0,             cnt   , '⬆︎ CONDITION'     , text_color = color.aqua      , bgcolor = color.new(color.silver, 90            ) )
        //                                                                                                                                       /
        //--------------------------------------------------------------------------------------------------------------------------------------/
        //-------------------------------------------------------------------------------------------------------------------------------------/

        for i = 0 to rows
            for j = 0 to colums
                tb.cell(j+1  , i+1, str.tostring(aBin.get(i).aFloat.get(j)), text_color=color.white, bgcolor=i == rows ? color.new(color.silver, 85) : INV)
            tb.cell(colums +1, i+1, str.tostring(aBin.get(i).aFloat.get(colums)), text_color=color.white, bgcolor=color.new(color.silver, 85))


        Ptxt = switch iP

            'table' =>
                arr   = tableP.get(degreesOfFreedom -1).aFloat
                left  = math.max(1, arr.binary_search_leftmost(chiSquare))
                right = math.max(1, math.min(tableP.get(0).aFloat.size() -1, arr.binary_search_rightmost(chiSquare)))
                pVal = tableP.get(50).aFloat

                str.format(" [{0}-{1}]", pVal.get(right), pVal.get(left))
            =>  str.format(" {0,number,#.#######}", compute(chiSquare, degreesOfFreedom))

        tb.cell(0, rows+2, str.format("P-value: {0}\n(population: {1,number,#})", Ptxt, pop), text_color=color.yellow, bgcolor=color.new(color.aqua, 85))
        tb.cell(0, rows+3, str.format("Degrees Of Freedom: {0}", degreesOfFreedom), text_color=color.yellow, bgcolor=color.new(color.aqua, 85))
        tb.cell(0, rows+4, str.format("Chi-Square: {0}", chiSquare), text_color=color.yellow, bgcolor=color.new(color.aqua, 85))
//                                                                                                                                                                              /
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------/
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------/
````
