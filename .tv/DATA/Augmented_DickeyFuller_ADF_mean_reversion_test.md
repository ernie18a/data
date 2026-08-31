<!-- tradingview-pine-id: PUB;fc8bf3ab198242d1b1393ee6110de982 -->
<!-- tradingviewscripts-format: 1 -->
# Augmented Dickey–Fuller (ADF) mean reversion test

Source: https://www.tradingview.com/script/KjD8ByIQ-Augmented-Dickey-Fuller-ADF-mean-reversion-test/

## Description

The [augmented Dickey-Fuller test](https://en.wikipedia.org/wiki/Augmented_Dickey%E2%80%93Fuller_test) (ADF) is a statistical test for the tendency of a price series sample to mean revert.

The current price of a mean-reverting series may tell us something about the next move (as opposed, for example, to a geometric Brownian motion). Thus, the ADF test allows us to spot market inefficiencies and potentially exploit this information in a trading strategy.

Mathematically, the mean reversion property means that the price change in the next time period is proportional to the difference between the average price and the current price. The purpose of the ADF test is to check if this proportionality constant is zero. Accordingly, the ADF test statistic is defined as the estimated proportionality constant divided by the corresponding standard error.

In this script, the ADF test is applied in a rolling window with a user-defined lookback length. The calculated values ​​of the ADF test statistic are plotted as a time series. The more negative the test statistic, the stronger the rejection of the hypothesis that there is no mean reversion. If the calculated test statistic is less than the critical value calculated at a certain confidence level (90%, 95%, or 99%), then the hypothesis of a mean reversion is accepted (strictly speaking, the opposite hypothesis is rejected).

Input parameters:

[*] Source - The source of the time series being tested.
[*] Length - The number of points in the rolling lookback window. The larger sample length makes the ADF test results more reliable.
[*] Maximum lag - The maximum lag included in the test, that defines the order of an autoregressive process being implied in the model. Generally, a non-zero lag allows taking into account the serial correlation of price changes. When dealing with price data, a good starting point is lag 0 or lag 1.
[*] Confidence level - The probability level at which the critical value of the ADF test statistic is calculated. If the test statistic is below the critical value, it is concluded that the sample of the price series is mean-reverting. Confidence level is calculated based on [MacKinnon (2010)](https://ideas.repec.org/p/qed/wpaper/1227.html).
[*]Show Infobox - If True, the results calculated for the last price bar are displayed in a table on the left.

More formal background:
Formally, the ADF test is a test for a [unit root](https://en.wikipedia.org/wiki/Unit_root) in an autoregressive process. The model implemented in this script involves a non-zero constant and zero time trend. The zero lag corresponds to the simple case of the AR(1) process, while higher order autoregressive processes AR(p) can be approached by setting the maximum lag of p. The null hypothesis is that there is a unit root, with the alternative that there is no unit root. The presence of unit roots in an autoregressive time series is characteristic for a non-stationary process. Thus, if there is no unit root, the time series sample can be concluded to be stationary, i.e., manifesting the mean-reverting property. 

A few more comments:

[*]It should be noted that the ADF test tells us only about the properties of the price series now and in the past. It does not directly say whether the mean-reverting behavior will retain in the future.
[*]The ADF test results don't directly reveal the direction of the next price move. It only tells wether or not a mean-reverting trading strategy can be potentially applicable at the given moment of time. 
[*]The ADF test is related to another statistical test, the Hurst exponent. The latter is available on TradingView as implemented by [balipour](https://www.tradingview.com/script/vTloluai-Hurst-Exponent-Detrended-Fluctuation-Analysis-pig/), [QuantNomad](https://www.tradingview.com/script/QibYVT4J-Hurst-Exponent/) and [DonovanWall](https://www.tradingview.com/script/UR16Q7VB-Hurst-Exponent-Market-Phases-DW/).
[*]The ADF test statistics is a negative number. However, it can take positive values, which usually corresponds to trending markets (even though there is no statistical test for this case).
[*]Rigorously, the hypothesis about the mean reversion is accepted at a given confidence level when the value of the test statistic is below the critical value. However, for practical trading applications, the values which are low enough - but still a bit higher than the critical one - can be still used in making decisions.

Examples:
The VIX volatility index is known to exhibit mean reversion properties (volatility spikes tend to fade out quickly). Accordingly, the statistics of the ADF test tend to stay below the critical value of 90% for long time periods.
[image]https://www.tradingview.com/x/TGn4FbmI/[/image]

The opposite case is presented by BTCUSD. During the same time range, the bitcoin price showed strong momentum - the moves away from the mean did not follow by the counter-move immediately, even vice versa. This is reflected by the ADF test statistic that consistently stayed above the critical value (and even above 0). Thus, using a mean reversion strategy would likely lead to losses.
[image]https://www.tradingview.com/x/1XeQfEqt/[/image]

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tbiktag

// The augmented Dickey–Fuller (ADF) test is a test of the tendency of a price series sample to mean revert. 
// In this script, the ADF test is applied in a rolling window with a user-defined lookback length. 
// The computed values of the ADF test statistic are plotted as a time series. 
// If the calculated test statistic is smaller than the critical value calculated at the certain confidence 
// level (90%, 95% or 99%), then the hypothesis about the mean reversion is accepted (strictly speaking, 
// the opposite hypothesis is rejected).

//@version=5
indicator('Augmented Dickey–Fuller (ADF) mean reversion test', shorttitle='ADF', overlay=false, max_bars_back=5000, max_lines_count=500)

src       = input.source(title='Source',            defval=close)
lookback  = input.int(title='Length',               defval=100, minval = 2, tooltip = 'The test is applied in a moving window. Length defines the number of points in the sample.')
nLag      = input.int(title='Maximum lag',          defval=0,   minval = 0, tooltip = 'Maximum lag which is included in test. Generally, lags allow taking into account serial correlation of price changes.')
conf      = input.string(title='Confidence Level',  defval="90%", options = ['90%', '95%', '99%'], tooltip = 'Defines at which confidence level the critical value of the ADF test statistic is calculated. If the test statistic is below the critical value, the time series sample is concluded to be mean-reverting.')
isInfobox = input.bool(title='Show infobox',        defval=true)

// --- functions ---
// To-do: transfer some linear algebra to a separate library, or use public libraries

matrix_get(A, i, j, nrows) =>
    // @function: Get the value of the element of an implied 2d matrix
    // @parameters: 
    // A     :: float[] array: pseudo 2d matrix _A = [[column_0],[column_1],...,[column_(n-1)]]
    // i     :: integer: row number
    // j     :: integer: column number
    // nrows :: integer: number of rows in the implied 2d matrix
    array.get(A, i + nrows * j)

matrix_set(A, value, i, j, nrows) =>
    // @function: Set a value to the element of an implied 2d matrix
    // @parameters: 
    // A     :: float[] array, changed on output: pseudo 2d matrix _A = [[column_0],[column_1],...,[column_(n-1)]]
    // value :: float: the new value to be set
    // i     :: integer: row number
    // j     :: integer: column number
    // nrows :: integer: number of rows in the implied 2d matrix
    array.set(A, i + nrows * j, value)
    A

transpose(A, nrows, ncolumns) =>
    // @function: Transpose an implied 2d matrix
    // @parameters: 
    // A        :: float[] array: pseudo 2d matrix A = [[column_0],[column_1],...,[column_(n-1)]]
    // nrows    :: integer: number of rows in A
    // ncolumns :: integer: number of columns in A
    // @returns: 
    // AT       :: float[] array: pseudo 2d matrix with implied dimensions: ncolums x nrows
    float[]  AT = array.new_float(nrows * ncolumns, 0)
    for i = 0 to nrows - 1
        for j = 0 to ncolumns - 1
            matrix_set(AT, matrix_get(A, i, j, nrows), j, i, ncolumns)
    AT

multiply(A, B, nrowsA, ncolumnsA, ncolumnsB) =>
    // @function: Calculate scalar product of two matrices
    // @parameters: 
    // A         :: float[] array: pseudo 2d matrix
    // B         :: float[] array: pseudo 2d matrix
    // nrowsA    :: integer: number of rows in A
    // ncolumnsA :: integer: number of columns in A
    // ncolumnsB :: integer: number of columns in B
    // @returns: 
    // C         :: float[] array: pseudo 2d matrix with implied dimensions _nrowsA x _ncolumnsB
    float[]      C = array.new_float(nrowsA * ncolumnsB, 0)
    int     nrowsB = ncolumnsA
    float elementC = 0.0
    for i = 0 to nrowsA - 1
        for j = 0 to ncolumnsB - 1
            elementC := 0
            for k = 0 to ncolumnsA - 1
                elementC += matrix_get(A, i, k, nrowsA) * matrix_get(B, k, j, nrowsB)
            matrix_set(C, elementC, i, j, nrowsA)
    C

vnorm(X) =>
    // @function: Square norm of vector X with size n
    // @parameters: 
    // X        :: float[] array, vector 
    // @returns :
    // norm     :: float, square norm of X
    int   n    = array.size(X)
    float norm = 0.0
    for i = 0 to n - 1
        norm += math.pow(array.get(X, i), 2)
    math.sqrt(norm)

qr_diag(A, nrows, ncolumns) =>
    // @function: QR Decomposition with Modified Gram-Schmidt Algorithm (Column-Oriented)
    // @parameters: 
    // A        :: float[] array: pseudo 2d matrix A = [[column_0],[column_1],...,[column_(n-1)]]
    // nrows    :: integer: number of rows in A
    // ncolumns :: integer: number of columns in A
    // @returns: 
    // Q        :: float[] array, unitary matrix, implied dimenstions nrows x ncolumns
    // R        :: float[] array, upper triangular matrix, implied dimansions ncolumns x ncolumns
    float[] Q = array.new_float(nrows * ncolumns, 0)
    float[] R = array.new_float(ncolumns * ncolumns, 0)
    float[] a = array.new_float(nrows, 0)
    float[] q = array.new_float(nrows, 0)
    float   r = 0.0
    float aux = 0.0
    //get first column of _A and its norm:
    for i = 0 to nrows - 1
        array.set(a, i, matrix_get(A, i, 0, nrows))
    r := vnorm(a)
    //assign first diagonal element of R and first column of Q
    matrix_set(R, r, 0, 0, ncolumns)
    for i = 0 to nrows - 1
        matrix_set(Q, array.get(a, i) / r, i, 0, nrows)
    if ncolumns != 1
        //repeat for the rest of the columns
        for k = 1 to ncolumns - 1
            for i = 0 to nrows - 1
                array.set(a, i, matrix_get(A, i, k, nrows))
            for j = 0 to k - 1 by 1
                //get R_jk as scalar product of Q_j column and A_k column:
                r := 0
                for i = 0 to nrows - 1
                    r += matrix_get(Q, i, j, nrows) * array.get(a, i)
                matrix_set(R, r, j, k, ncolumns)
                //update vector _a
                for i = 0 to nrows - 1
                    aux := array.get(a, i) - r * matrix_get(Q, i, j, nrows)
                    array.set(a, i, aux)
            //get diagonal R_kk and Q_k column
            r := vnorm(a)
            matrix_set(R, r, k, k, ncolumns)
            for i = 0 to nrows - 1
                matrix_set(Q, array.get(a, i) / r, i, k, nrows)
    [Q, R]

pinv(A, nrows, ncolumns) =>
    // @function: Pseudoinverse of matrix A calculated using QR decomposition
    // @parameters: 
    // A        :: float[] array: implied as a (nrows x ncolumns) matrix A = [[column_0],[column_1],...,[column_(_ncolumns-1)]]
    // nrows    :: integer: number of rows in A
    // ncolumns :: integer: number of columns in A
    // @returns: 
    // Ainv     :: float[] array implied as a (ncolumns x nrows)  matrix A = [[row_0],[row_1],...,[row_(_nrows-1)]]
    // 
    // First find the QR factorization of A: A = QR, where R is upper triangular matrix. Then do Ainv = R^-1*Q^T.
    [Q, R]     = qr_diag(A, nrows, ncolumns)
    float[] QT = transpose(Q, nrows, ncolumns)
    // Calculate Rinv:
    var   Rinv = array.new_float(ncolumns * ncolumns, 0)
    float    r = 0.0
    matrix_set(Rinv, 1 / matrix_get(R, 0, 0, ncolumns), 0, 0, ncolumns)
    if ncolumns != 1
        for j = 1 to ncolumns - 1
            for i = 0 to j - 1
                r := 0.0
                for k = i to j - 1
                    r += matrix_get(Rinv, i, k, ncolumns) * matrix_get(R, k, j, ncolumns)
                matrix_set(Rinv, r, i, j, ncolumns)
            for k = 0 to j - 1
                matrix_set(Rinv, -matrix_get(Rinv, k, j, ncolumns) / matrix_get(R, j, j, ncolumns), k, j, ncolumns)
            matrix_set(Rinv, 1 / matrix_get(R, j, j, ncolumns), j, j, ncolumns)
    //
    float[] Ainv = multiply(Rinv, QT, ncolumns, ncolumns, nrows)
    Ainv

adftest(a, nLag, conf) =>
    // @function: Augmented Dickey-Fuller unit root test.
    // @parameters: 
    // a          :: float[], array containing the data series to test
    // Lag        :: int, maximum lag included in test
    // @returns: 
    // adf        :: float, the test statistic
    // crit       :: float, critical value for the test statistic at the 10 % levels
    // nobs       :: int, the number of observations used for the ADF regression and calculation of the critical values
    if nLag >= array.size(a)/2 - 2
        runtime.error("ADF: Maximum lag must be less than (Length/2 - 2)")
    int   nobs = array.size(a)-nLag-1
    //
    float[]  y = array.new_float(na)
    float[]  x = array.new_float(na)
    float[] x0 = array.new_float(na)
    //
    for i = 0 to nobs-1
        array.push( y, array.get(a,i)-array.get(a,i+1))             // current difference, dependent variable
        array.push( x, array.get(a,i+1))                            // previous-bar value, predictor (related to tauADF)
        array.push(x0, 1.0)                                         // constant, predictor
    //
    float[] X = array.copy(x)
    int     M = 2
    X := array.concat(X, x0)
    //
    // introduce lags
    if nLag > 0
        for n = 1 to nLag
            float[] xl = array.new_float(na)
            for i = 0 to nobs-1
                array.push(xl, array.get(a,i+n)-array.get(a,i+n+1))  // lag-n difference, predictor
            X   := array.concat(X, xl)
            M   += 1
    //
    // Regression
    float[] c      = pinv(X, nobs, M)
    float[] coeff  = multiply(c, y, M, nobs, 1)
    //
    // Standard error
    float[] Yhat   = multiply(X,coeff,nobs,M,1)
    float   meanX  = array.avg(x)
    float   sum1   = 0.0            // mean square error (MSE) of regression
    float   sum2   = 0.0            //
    for i = 0 to nobs-1
        sum1  += math.pow(array.get(y,i) - array.get(Yhat,i), 2)/(nobs-M)
        sum2  += math.pow(array.get(x,i) - meanX, 2)
    float   SE = math.sqrt(sum1/sum2)
    //
    // The test statistic 
    float  adf = array.get(coeff,0) /SE
    //
    // Critical value of the ADF test statistic (90%, model1: constant, no trend)
    // MacKinnon, J.G. 2010. “Critical Values for Cointegration Tests.” Queen”s University, Dept of Economics, Working Papers. 
    float crit  = switch
        conf == "90%" => -2.56677 - 1.5384/nobs -  2.809/nobs/nobs
        conf == "95%" => -2.86154 - 2.8903/nobs -  4.234/nobs/nobs - 40.040/nobs/nobs/nobs
        conf == "99%" => -3.43035 - 6.5393/nobs - 16.786/nobs/nobs - 79.433/nobs/nobs/nobs
    //
    // output
    [adf, crit, nobs]


// --- main ---

// load data from a moving window into an array
float[] a = array.new_float(na)
for i = 0 to lookback-1
    array.push(a,src[i])

// perform the ADF test 
[tauADF, crit, nobs] = adftest(a, nLag, conf)

// plot
color    tauColor =  switch
    tauADF < crit => #7AF54D
    tauADF > crit => color.from_gradient(math.abs(tauADF), 0.0, math.abs(crit), color.white, #F5DF4D)//#939597, #F5DF4D)

bgcolor(#64416b)
plot(0.0,    color = #939597,   title = "Zero")
plot(crit,   color = #c84df5,   title = "Critical value")
plot(tauADF, color = tauColor,  title = "Test statistic",     style = plot.style_cross, linewidth = 2)



if barstate.islast and isInfobox
    infobox = table.new("bottom_left", 2, 3, bgcolor = #faedf5, frame_color = (tauADF < crit)?#7AF54D:#C84DF5, frame_width = 1)
    table.cell(infobox, 0, 0, text = "Test Statistic",   text_color = color.black, text_size = size.small)
    table.cell(infobox, 0, 1, text = conf+" Critical Value",    text_color = color.black, text_size = size.small)
    table.cell(infobox, 0, 2, text = "Mean Reverting?",   text_color = color.black, text_size = size.small)
    table.cell(infobox, 1, 0, text = str.format("{0, number, #.####}",tauADF),   text_color = color.black, text_size = size.small)
    table.cell(infobox, 1, 1, text = str.format("{0, number, #.####}",crit),     text_color = color.black, text_size = size.small)
    table.cell(infobox, 1, 2, text = (tauADF < crit)?"Yes":"No",   text_color = color.black, text_size = size.small)
````
