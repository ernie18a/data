<!-- tradingview-pine-id: PUB;ca41d3393aa2450fb23a8cf21c89cf1e -->
<!-- tradingviewscripts-format: 1 -->
# Regression_Toolkit

Source: https://www.tradingview.com/script/gSLL5PC1-Regression-Toolkit/

## Description

This is toolkit/library bridges advanced regression approaches not natively  supported in Pinescript, to Pinescript. Advanced regression frameworks that can be critical to ticker data, such as Ridge, Lasso, ElasticNET,  and Logistic (normalized) regression, colinarity measuring  and quantile regression.  As well as approaches to linear based feature selection and importance  assessments. 

I hope you find it helpful! 

Library  "Regression_Toolkit"

multipleRegression(y, x1, x2, length)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    length (simple int)

ridgeRegression(y, x1, x2, x3, x4, nVars, length, lambda)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    lambda (simple float)

lassoRegression(y, x1, x2, x3, x4, nVars, length, lambda, iterations)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    lambda (simple float)
    iterations (simple int)

logisticRegression(y, x1, x2, x3, x4, nVars, length, learningRate, iterations)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    learningRate (simple float)
    iterations (simple int)

featureSelection(y, x1, x2, x3, x4, nVars, length)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)

regressionStats(y, x1, x2, x3, x4, nVars, length, b0, b1, b2, b3, b4)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    b0 (float)
    b1 (float)
    b2 (float)
    b3 (float)
    b4 (float)

elasticNetRegression(y, x1, x2, x3, x4, nVars, length, lambda, alpha, iterations)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    lambda (simple float)
    alpha (simple float)
    iterations (simple int)

huberRegression(y, x1, x2, x3, x4, nVars, length, huberK, iterations)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    huberK (simple float)
    iterations (simple int)

quantileRegression(y, x1, x2, x3, x4, nVars, length, tau, learningRate, iterations)
  Parameters:
    y (float)
    x1 (float)
    x2 (float)
    x3 (float)
    x4 (float)
    nVars (simple int)
    length (simple int)
    tau (simple float)
    learningRate (simple float)
    iterations (simple int)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6

// ============================================================================
//About 
// This is toolkit/library bridges advanced regression approaches not natively 
// supported in Pinescript, to Pinescript. 
// Advanced regression frameworks that can be critical to ticker data, such as 
// Ridge, Lasso and Logistic (normalizeD) regression, colinarity measuring 
// and quantile regression. 
// As well as approaches to linear based feature selection and importance 
// assessments. 
// 
// ============================================================================
// Advanced_Regression Toolkit [SS] 
// Rolling-window regression toolkit: OLS (2-IV), Ridge (up to 4-IV, closed
// form via matrix normal equations), Lasso (up to 4-IV, coordinate descent),
// Logistic (up to 4-IV, gradient descent, sigmoid output), linear
// feature-selection (marginal correlation + standardized partial
// coefficients), regression diagnostics (R², adjusted R², residual SE,
// coefficient t-stats/p-values), Elastic Net (L1+L2 coordinate descent),
// Huber/robust regression (IRLS with MAD-scaled weights), and Quantile
// regression (pinball-loss subgradient descent, any tau in (0,1)).
//
// All regressions retrain on every bar over the trailing `length` window.
// Cost scales with length (and iterations for lasso/logistic/elastic-net/
// huber/quantile) per bar — keep length/iterations modest (e.g. length
// 30-150, iterations 50-200) if running on a large number of bars or with
// multiple calls per script.
// ============================================================================
library("Regression_Toolkit", overlay = true)


// Internal helpers 


// Builds an array of `length` historical values of `src`, oldest first (index 0).
f_buildColumn(series float src, simple int length) =>
    arr = array.new<float>(length)
    for i = 0 to length - 1
        array.set(arr, i, src[length - 1 - i])
    arr

// Zero-mean / unit-variance standardization. Returns [standardized array, mean, stdev].
// Falls back to sd = 1.0 for a constant column so downstream division is safe.
f_standardize(float[] arr) =>
    n   = array.size(arr)
    m   = array.avg(arr)
    sd  = array.stdev(arr)
    sd := sd == 0.0 or na(sd) ? 1.0 : sd
    out = array.new<float>(n)
    for i = 0 to n - 1
        array.set(out, i, (array.get(arr, i) - m) / sd)
    [out, m, sd]

f_sigmoid(float z) =>
    1.0 / (1.0 + math.exp(-z))

// Standard normal CDF (Zelen & Severo polynomial approximation, ~7 decimal places).
// Used to turn t-stats into two-tailed p-values.
f_normCDF(float x) =>
    float ax = math.abs(x)
    float k  = 1.0 / (1.0 + 0.2316419 * ax)
    float w  = 1.0 - (1.0 / math.sqrt(2.0 * math.pi)) * math.exp(-ax * ax / 2.0) * (0.319381530 * k - 0.356563782 * k * k + 1.781477937 * k * k * k - 1.821255978 * k * k * k * k + 1.330274429 * k * k * k * k * k)
    x >= 0.0 ? w : 1.0 - w

// Builds the (length x (nVars+1)) design matrix with an intercept column of 1s.
f_designMatrix(simple int length, simple int nVars, series float x1, series float x2, series float x3, series float x4) =>
    X = matrix.new<float>(length, nVars + 1, 0.0)
    for i = 0 to length - 1
        matrix.set(X, i, 0, 1.0)
        if nVars >= 1
            matrix.set(X, i, 1, x1[length - 1 - i])
        if nVars >= 2
            matrix.set(X, i, 2, x2[length - 1 - i])
        if nVars >= 3
            matrix.set(X, i, 3, x3[length - 1 - i])
        if nVars >= 4
            matrix.set(X, i, 4, x4[length - 1 - i])
    X

f_targetVector(simple int length, series float y) =>
    Ym = matrix.new<float>(length, 1, 0.0)
    for i = 0 to length - 1
        matrix.set(Ym, i, 0, y[length - 1 - i])
    Ym

//=================================================================
// 1. Multiple regression — OLS, exactly 2 independent variables
//    Closed form: beta = (X'X)^-1 X'y

export multipleRegression(series float y, series float x1, series float x2, simple int length = 50) =>
    var float b0 = na
    var float b1 = na
    var float b2 = na
    float yhat = na
    if bar_index >= length - 1
        X   = f_designMatrix(length, 2, x1, x2, na, na)
        Ym  = f_targetVector(length, y)
        Xt  = matrix.transpose(X)
        XtX = matrix.mult(Xt, X)
        XtY = matrix.mult(Xt, Ym)
        XtXinv = matrix.inv(XtX)
        if not na(XtXinv)
            beta = matrix.mult(XtXinv, XtY)
            b0 := matrix.get(beta, 0, 0)
            b1 := matrix.get(beta, 1, 0)
            b2 := matrix.get(beta, 2, 0)
            yhat := b0 + b1 * x1 + b2 * x2
    [yhat, b0, b1, b2]

// =============================================================
// 2. Ridge regression — up to 4 independent variables
//    beta = (X'X + lambda*I)^-1 X'y, intercept left unpenalized

export ridgeRegression(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50, simple float lambda = 1.0) =>
    var float b0 = na
    var float b1 = na
    var float b2 = na
    var float b3 = na
    var float b4 = na
    float yhat = na
    if bar_index >= length - 1
        X   = f_designMatrix(length, nVars, x1, x2, x3, x4)
        Ym  = f_targetVector(length, y)
        Xt  = matrix.transpose(X)
        XtX = matrix.mult(Xt, X)
        for i = 1 to nVars
            matrix.set(XtX, i, i, matrix.get(XtX, i, i) + lambda)
        XtY = matrix.mult(Xt, Ym)
        XtXinv = matrix.inv(XtX)
        if not na(XtXinv)
            beta = matrix.mult(XtXinv, XtY)
            b0 := matrix.get(beta, 0, 0)
            b1 := matrix.get(beta, 1, 0)
            b2 := nVars >= 2 ? matrix.get(beta, 2, 0) : 0.0
            b3 := nVars >= 3 ? matrix.get(beta, 3, 0) : 0.0
            b4 := nVars >= 4 ? matrix.get(beta, 4, 0) : 0.0
            yhat := b0 + b1 * x1 + (nVars >= 2 ? b2 * x2 : 0.0) + (nVars >= 3 ? b3 * x3 : 0.0) + (nVars >= 4 ? b4 * x4 : 0.0)
    [yhat, b0, b1, b2, b3, b4]

//===========================================================================
// 3. Lasso regression — up to 4 independent variables
//    Coordinate descent on standardized features (no closed form for L1).
//    Objective per coordinate: 0.5*z*beta^2 - rho*beta + lambda*|beta|
//    => beta = SoftThreshold(rho, lambda) / z

export lassoRegression(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50, simple float lambda = 0.1, simple int iterations = 100) =>
    var float b0 = na
    var float b1 = na
    var float b2 = na
    var float b3 = na
    var float b4 = na
    float yhat = na
    if bar_index >= length - 1
        yArr  = f_buildColumn(y, length)
        x1Arr = f_buildColumn(x1, length)
        x2Arr = nVars >= 2 ? f_buildColumn(x2, length) : array.new<float>(length, 0.0)
        x3Arr = nVars >= 3 ? f_buildColumn(x3, length) : array.new<float>(length, 0.0)
        x4Arr = nVars >= 4 ? f_buildColumn(x4, length) : array.new<float>(length, 0.0)

        [ys, yMean, ySd]   = f_standardize(yArr)
        [xs1, m1, s1]      = f_standardize(x1Arr)
        [xs2, m2, s2]      = f_standardize(x2Arr)
        [xs3, m3, s3]      = f_standardize(x3Arr)
        [xs4, m4, s4]      = f_standardize(x4Arr)

        float beta1 = 0.0
        float beta2 = 0.0
        float beta3 = 0.0
        float beta4 = 0.0

        for iter = 1 to iterations
            // --- coordinate 1 ---
            float rho1 = 0.0
            float z1   = 0.0
            for i = 0 to length - 1
                float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                float resid = array.get(ys, i) - pred + beta1 * array.get(xs1, i)
                rho1 += array.get(xs1, i) * resid
                z1   += array.get(xs1, i) * array.get(xs1, i)
            beta1 := z1 == 0.0 ? 0.0 : math.sign(rho1) * math.max(math.abs(rho1) - lambda, 0.0) / z1

            // --- coordinate 2 ---
            if nVars >= 2
                float rho2 = 0.0
                float z2   = 0.0
                for i = 0 to length - 1
                    float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                    float resid = array.get(ys, i) - pred + beta2 * array.get(xs2, i)
                    rho2 += array.get(xs2, i) * resid
                    z2   += array.get(xs2, i) * array.get(xs2, i)
                beta2 := z2 == 0.0 ? 0.0 : math.sign(rho2) * math.max(math.abs(rho2) - lambda, 0.0) / z2

            // --- coordinate 3 ---
            if nVars >= 3
                float rho3 = 0.0
                float z3   = 0.0
                for i = 0 to length - 1
                    float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                    float resid = array.get(ys, i) - pred + beta3 * array.get(xs3, i)
                    rho3 += array.get(xs3, i) * resid
                    z3   += array.get(xs3, i) * array.get(xs3, i)
                beta3 := z3 == 0.0 ? 0.0 : math.sign(rho3) * math.max(math.abs(rho3) - lambda, 0.0) / z3

            // --- coordinate 4 ---
            if nVars >= 4
                float rho4 = 0.0
                float z4   = 0.0
                for i = 0 to length - 1
                    float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                    float resid = array.get(ys, i) - pred + beta4 * array.get(xs4, i)
                    rho4 += array.get(xs4, i) * resid
                    z4   += array.get(xs4, i) * array.get(xs4, i)
                beta4 := z4 == 0.0 ? 0.0 : math.sign(rho4) * math.max(math.abs(rho4) - lambda, 0.0) / z4

        // de-standardize back to raw coefficient space
        b1 := beta1 * ySd / s1
        b2 := nVars >= 2 ? beta2 * ySd / s2 : 0.0
        b3 := nVars >= 3 ? beta3 * ySd / s3 : 0.0
        b4 := nVars >= 4 ? beta4 * ySd / s4 : 0.0
        b0 := yMean - b1 * m1 - (nVars >= 2 ? b2 * m2 : 0.0) - (nVars >= 3 ? b3 * m3 : 0.0) - (nVars >= 4 ? b4 * m4 : 0.0)
        yhat := b0 + b1 * x1 + (nVars >= 2 ? b2 * x2 : 0.0) + (nVars >= 3 ? b3 * x3 : 0.0) + (nVars >= 4 ? b4 * x4 : 0.0)
    [yhat, b0, b1, b2, b3, b4]

//=============================================================================
// 4. Logistic regression — up to 4 independent variables
//    Batch gradient descent on internally standardized features; output is
//    the sigmoid probability (0-1) plus a thresholded 0/1 class at p >= 0.5.
//    `y` must be a binary series (0 or 1) over the training window.

export logisticRegression(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50, simple float learningRate = 0.1, simple int iterations = 200) =>
    var float prob = na
    var int classOut = na
    var float b0 = na
    var float b1 = na
    var float b2 = na
    var float b3 = na
    var float b4 = na
    if bar_index >= length - 1
        yArr  = f_buildColumn(y, length)
        x1Arr = f_buildColumn(x1, length)
        x2Arr = nVars >= 2 ? f_buildColumn(x2, length) : array.new<float>(length, 0.0)
        x3Arr = nVars >= 3 ? f_buildColumn(x3, length) : array.new<float>(length, 0.0)
        x4Arr = nVars >= 4 ? f_buildColumn(x4, length) : array.new<float>(length, 0.0)

        [xs1, m1, s1] = f_standardize(x1Arr)
        [xs2, m2, s2] = f_standardize(x2Arr)
        [xs3, m3, s3] = f_standardize(x3Arr)
        [xs4, m4, s4] = f_standardize(x4Arr)

        float beta0 = 0.0
        float beta1 = 0.0
        float beta2 = 0.0
        float beta3 = 0.0
        float beta4 = 0.0

        for iter = 1 to iterations
            float g0 = 0.0
            float g1 = 0.0
            float g2 = 0.0
            float g3 = 0.0
            float g4 = 0.0
            for i = 0 to length - 1
                float z = beta0 + beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                float p   = f_sigmoid(z)
                float err = p - array.get(yArr, i)
                g0 += err
                g1 += err * array.get(xs1, i)
                g2 += err * array.get(xs2, i)
                g3 += err * array.get(xs3, i)
                g4 += err * array.get(xs4, i)
            beta0 -= learningRate * g0 / length
            beta1 -= learningRate * g1 / length
            beta2 -= learningRate * g2 / length
            beta3 -= learningRate * g3 / length
            beta4 -= learningRate * g4 / length

        // un-standardize: z = beta0 + sum(beta_j * (x_j - m_j)/s_j)
        //               = (beta0 - sum(beta_j*m_j/s_j)) + sum((beta_j/s_j) * x_j)
        b1 := beta1 / s1
        b2 := nVars >= 2 ? beta2 / s2 : 0.0
        b3 := nVars >= 3 ? beta3 / s3 : 0.0
        b4 := nVars >= 4 ? beta4 / s4 : 0.0
        b0 := beta0 - b1 * m1 - (nVars >= 2 ? b2 * m2 : 0.0) - (nVars >= 3 ? b3 * m3 : 0.0) - (nVars >= 4 ? b4 * m4 : 0.0)

        float zFinal = b0 + b1 * x1 + (nVars >= 2 ? b2 * x2 : 0.0) + (nVars >= 3 ? b3 * x3 : 0.0) + (nVars >= 4 ? b4 * x4 : 0.0)
        prob := f_sigmoid(zFinal)
        classOut := prob >= 0.5 ? 1 : 0
    [prob, classOut, b0, b1, b2, b3, b4]

// ===========================================================================
// 5. Regression-based feature selection — up to 4 independent variables
//    Two complementary linear importance measures over the trailing window:
//      - marginal Pearson correlation of y with each x_j (zero-order effect)
//      - standardized partial coefficient from a stabilized joint OLS fit
//        (ridge with a tiny lambda for numerical stability), which controls
//        for the other predictors — useful for spotting collinearity where
//        a variable looks strong marginally but contributes little jointly.
//    bestIdx returns the 1-4 index of the variable with the strongest
//    marginal |correlation|.

export featureSelection(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50) =>
    float r1 = ta.correlation(y, x1, length)
    float r2 = nVars >= 2 ? ta.correlation(y, x2, length) : na
    float r3 = nVars >= 3 ? ta.correlation(y, x3, length) : na
    float r4 = nVars >= 4 ? ta.correlation(y, x4, length) : na

    [_, b0, b1, b2, b3, b4] = ridgeRegression(y, x1, x2, x3, x4, nVars, length, 0.0001)

    float sdY  = ta.stdev(y, length)
    float sdX1 = ta.stdev(x1, length)
    float sdX2 = nVars >= 2 ? ta.stdev(x2, length) : na
    float sdX3 = nVars >= 3 ? ta.stdev(x3, length) : na
    float sdX4 = nVars >= 4 ? ta.stdev(x4, length) : na

    bool sdYok = not na(sdY) and sdY != 0.0
    float stdBeta1 = sdYok ? b1 * sdX1 / sdY : na
    float stdBeta2 = nVars >= 2 and sdYok ? b2 * sdX2 / sdY : na
    float stdBeta3 = nVars >= 3 and sdYok ? b3 * sdX3 / sdY : na
    float stdBeta4 = nVars >= 4 and sdYok ? b4 * sdX4 / sdY : na

    int bestIdx = 1
    float bestAbsR = math.abs(r1)
    if nVars >= 2 and not na(r2) and math.abs(r2) > bestAbsR
        bestIdx := 2
        bestAbsR := math.abs(r2)
    if nVars >= 3 and not na(r3) and math.abs(r3) > bestAbsR
        bestIdx := 3
        bestAbsR := math.abs(r3)
    if nVars >= 4 and not na(r4) and math.abs(r4) > bestAbsR
        bestIdx := 4
        bestAbsR := math.abs(r4)

    [r1, r2, r3, r4, stdBeta1, stdBeta2, stdBeta3, stdBeta4, bestIdx]

//==============================================================================
// 6. Regression diagnostics — R², adjusted R², residual SE, per-coefficient
//    t-stats and p-values, for any fitted b0..b4 you already have (from
//    multipleRegression, ridgeRegression, lassoRegression, elasticNetRegression,
//    huberRegression, or your own).
//
//    IMPORTANT: coefficient SE/t/p use the classical OLS sampling formula
//    SE(beta_j) = sigma * sqrt(diag((X'X)^-1)). That is exact when b0..b4 came
//    from an unregularized OLS fit. For ridge/lasso/elastic-net/huber/quantile
//    coefficients (which are intentionally biased/shrunk or use a different
//    loss), these SE/t/p values are an approximation commonly reported as a
//    rough diagnostic, not a rigorous inference — treat them as directional,
//    not exact, for anything but multipleRegression.
//
//    tStats/pValues are float[] of size 5, index 0 = intercept, 1-4 = x1-x4
//    (unused slots beyond nVars are na).

export regressionStats(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars, simple int length, series float b0, series float b1, series float b2, series float b3, series float b4) =>
    var float r2 = na
    var float adjR2 = na
    var float residualSE = na
    tStats = array.new<float>(5, na)
    pValues = array.new<float>(5, na)
    if bar_index >= length - 1
        X  = f_designMatrix(length, nVars, x1, x2, x3, x4)
        Ym = f_targetVector(length, y)

        float yMean = 0.0
        for i = 0 to length - 1
            yMean += matrix.get(Ym, i, 0)
        yMean /= length

        float ssRes = 0.0
        float ssTot = 0.0
        for i = 0 to length - 1
            float actual = matrix.get(Ym, i, 0)
            float pred = b0 + b1 * matrix.get(X, i, 1)
            pred += nVars >= 2 ? b2 * matrix.get(X, i, 2) : 0.0
            pred += nVars >= 3 ? b3 * matrix.get(X, i, 3) : 0.0
            pred += nVars >= 4 ? b4 * matrix.get(X, i, 4) : 0.0
            float resid = actual - pred
            ssRes += resid * resid
            ssTot += (actual - yMean) * (actual - yMean)

        r2 := ssTot == 0.0 ? na : 1.0 - ssRes / ssTot
        int dfResid = length - nVars - 1
        adjR2 := (na(r2) or dfResid <= 0) ? na : 1.0 - (1.0 - r2) * (length - 1) / dfResid
        float sigma2 = dfResid > 0 ? ssRes / dfResid : na
        residualSE := na(sigma2) ? na : math.sqrt(sigma2)

        if not na(sigma2)
            Xt = matrix.transpose(X)
            XtX = matrix.mult(Xt, X)
            XtXinv = matrix.inv(XtX)
            if not na(XtXinv)
                coeffs = array.from(b0, b1, b2, b3, b4)
                for j = 0 to nVars
                    float seJ = math.sqrt(sigma2 * matrix.get(XtXinv, j, j))
                    float bJ  = array.get(coeffs, j)
                    float tJ  = seJ == 0.0 ? na : bJ / seJ
                    array.set(tStats, j, tJ)
                    array.set(pValues, j, na(tJ) ? na : 2.0 * (1.0 - f_normCDF(math.abs(tJ))))
    [r2, adjR2, residualSE, tStats, pValues]

//==================================================================================
// 7. Elastic Net regression — up to 4 independent variables
//    Coordinate descent, same as lassoRegression, with a mixed L1+L2 penalty:
//    beta_j = SoftThreshold(rho_j, lambda*alpha) / (z_j + lambda*(1-alpha))
//    alpha = 1.0 -> pure Lasso, alpha = 0.0 -> pure Ridge.

export elasticNetRegression(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50, simple float lambda = 0.1, simple float alpha = 0.5, simple int iterations = 100) =>
    var float b0 = na
    var float b1 = na
    var float b2 = na
    var float b3 = na
    var float b4 = na
    float yhat = na
    if bar_index >= length - 1
        yArr  = f_buildColumn(y, length)
        x1Arr = f_buildColumn(x1, length)
        x2Arr = nVars >= 2 ? f_buildColumn(x2, length) : array.new<float>(length, 0.0)
        x3Arr = nVars >= 3 ? f_buildColumn(x3, length) : array.new<float>(length, 0.0)
        x4Arr = nVars >= 4 ? f_buildColumn(x4, length) : array.new<float>(length, 0.0)

        [ys, yMean, ySd]   = f_standardize(yArr)
        [xs1, m1, s1]      = f_standardize(x1Arr)
        [xs2, m2, s2]      = f_standardize(x2Arr)
        [xs3, m3, s3]      = f_standardize(x3Arr)
        [xs4, m4, s4]      = f_standardize(x4Arr)

        float l1 = lambda * alpha
        float l2 = lambda * (1.0 - alpha)

        float beta1 = 0.0
        float beta2 = 0.0
        float beta3 = 0.0
        float beta4 = 0.0

        for iter = 1 to iterations
            // --- coordinate 1 ---
            float rho1 = 0.0
            float z1   = 0.0
            for i = 0 to length - 1
                float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                float resid = array.get(ys, i) - pred + beta1 * array.get(xs1, i)
                rho1 += array.get(xs1, i) * resid
                z1   += array.get(xs1, i) * array.get(xs1, i)
            beta1 := z1 + l2 == 0.0 ? 0.0 : math.sign(rho1) * math.max(math.abs(rho1) - l1, 0.0) / (z1 + l2)

            // --- coordinate 2 ---
            if nVars >= 2
                float rho2 = 0.0
                float z2   = 0.0
                for i = 0 to length - 1
                    float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                    float resid = array.get(ys, i) - pred + beta2 * array.get(xs2, i)
                    rho2 += array.get(xs2, i) * resid
                    z2   += array.get(xs2, i) * array.get(xs2, i)
                beta2 := z2 + l2 == 0.0 ? 0.0 : math.sign(rho2) * math.max(math.abs(rho2) - l1, 0.0) / (z2 + l2)

            // --- coordinate 3 ---
            if nVars >= 3
                float rho3 = 0.0
                float z3   = 0.0
                for i = 0 to length - 1
                    float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                    float resid = array.get(ys, i) - pred + beta3 * array.get(xs3, i)
                    rho3 += array.get(xs3, i) * resid
                    z3   += array.get(xs3, i) * array.get(xs3, i)
                beta3 := z3 + l2 == 0.0 ? 0.0 : math.sign(rho3) * math.max(math.abs(rho3) - l1, 0.0) / (z3 + l2)

            // --- coordinate 4 ---
            if nVars >= 4
                float rho4 = 0.0
                float z4   = 0.0
                for i = 0 to length - 1
                    float pred  = beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                    float resid = array.get(ys, i) - pred + beta4 * array.get(xs4, i)
                    rho4 += array.get(xs4, i) * resid
                    z4   += array.get(xs4, i) * array.get(xs4, i)
                beta4 := z4 + l2 == 0.0 ? 0.0 : math.sign(rho4) * math.max(math.abs(rho4) - l1, 0.0) / (z4 + l2)

        // de-standardize back to raw coefficient space
        b1 := beta1 * ySd / s1
        b2 := nVars >= 2 ? beta2 * ySd / s2 : 0.0
        b3 := nVars >= 3 ? beta3 * ySd / s3 : 0.0
        b4 := nVars >= 4 ? beta4 * ySd / s4 : 0.0
        b0 := yMean - b1 * m1 - (nVars >= 2 ? b2 * m2 : 0.0) - (nVars >= 3 ? b3 * m3 : 0.0) - (nVars >= 4 ? b4 * m4 : 0.0)
        yhat := b0 + b1 * x1 + (nVars >= 2 ? b2 * x2 : 0.0) + (nVars >= 3 ? b3 * x3 : 0.0) + (nVars >= 4 ? b4 * x4 : 0.0)
    [yhat, b0, b1, b2, b3, b4]

// ==============================================================================
// 8. Huber (robust) regression — up to 4 independent variables
//    Iteratively reweighted least squares (IRLS): fit OLS, compute residuals,
//    estimate robust scale via MAD, down-weight large residuals per the
//    Huber loss, re-solve weighted normal equations, repeat. Resistant to
//    outlier bars (gaps, spikes) that would otherwise dominate an OLS fit.

export huberRegression(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50, simple float huberK = 1.345, simple int iterations = 10) =>
    var float b0 = na
    var float b1 = na
    var float b2 = na
    var float b3 = na
    var float b4 = na
    float yhat = na
    if bar_index >= length - 1
        X  = f_designMatrix(length, nVars, x1, x2, x3, x4)
        Ym = f_targetVector(length, y)
        Xt  = matrix.transpose(X)
        XtX = matrix.mult(Xt, X)
        XtY = matrix.mult(Xt, Ym)

        matrix<float> beta = na
        XtXinv = matrix.inv(XtX)
        if not na(XtXinv)
            beta := matrix.mult(XtXinv, XtY)

        if not na(beta)
            for iter = 1 to iterations
                resArr = array.new<float>(length)
                for i = 0 to length - 1
                    float pred = matrix.get(beta, 0, 0)
                    for j = 1 to nVars
                        pred += matrix.get(beta, j, 0) * matrix.get(X, i, j)
                    array.set(resArr, i, matrix.get(Ym, i, 0) - pred)

                absArr = array.new<float>(length)
                for i = 0 to length - 1
                    array.set(absArr, i, math.abs(array.get(resArr, i)))
                float s = array.median(absArr) / 0.6745
                s := s == 0.0 ? 0.000001 : s

                Xw = matrix.new<float>(length, nVars + 1, 0.0)
                Yw = matrix.new<float>(length, 1, 0.0)
                for i = 0 to length - 1
                    float absr = math.abs(array.get(resArr, i)) / s
                    float w  = absr <= huberK ? 1.0 : huberK / absr
                    float sw = math.sqrt(w)
                    for j = 0 to nVars
                        matrix.set(Xw, i, j, matrix.get(X, i, j) * sw)
                    matrix.set(Yw, i, 0, matrix.get(Ym, i, 0) * sw)

                Xwt = matrix.transpose(Xw)
                XwtXw = matrix.mult(Xwt, Xw)
                XwtYw = matrix.mult(Xwt, Yw)
                XwtXwInv = matrix.inv(XwtXw)
                if not na(XwtXwInv)
                    beta := matrix.mult(XwtXwInv, XwtYw)

            b0 := matrix.get(beta, 0, 0)
            b1 := matrix.get(beta, 1, 0)
            b2 := nVars >= 2 ? matrix.get(beta, 2, 0) : 0.0
            b3 := nVars >= 3 ? matrix.get(beta, 3, 0) : 0.0
            b4 := nVars >= 4 ? matrix.get(beta, 4, 0) : 0.0
            yhat := b0 + b1 * x1 + (nVars >= 2 ? b2 * x2 : 0.0) + (nVars >= 3 ? b3 * x3 : 0.0) + (nVars >= 4 ? b4 * x4 : 0.0)
    [yhat, b0, b1, b2, b3, b4]

//==========================================================================
// 9. Quantile regression — up to 4 independent variables
//    Minimizes pinball (check function) loss via subgradient descent on
//    standardized features; no closed form for L1-type quantile loss.
//    tau = 0.5 -> median regression (robust alternative to OLS mean).
//    tau = 0.1 / 0.9 -> lower/upper bound for an asymmetric risk band.

export quantileRegression(series float y, series float x1, series float x2, series float x3, series float x4, simple int nVars = 2, simple int length = 50, simple float tau = 0.5, simple float learningRate = 0.05, simple int iterations = 300) =>
    var float b0 = na
    var float b1 = na
    var float b2 = na
    var float b3 = na
    var float b4 = na
    float yhat = na
    if bar_index >= length - 1
        yArr  = f_buildColumn(y, length)
        x1Arr = f_buildColumn(x1, length)
        x2Arr = nVars >= 2 ? f_buildColumn(x2, length) : array.new<float>(length, 0.0)
        x3Arr = nVars >= 3 ? f_buildColumn(x3, length) : array.new<float>(length, 0.0)
        x4Arr = nVars >= 4 ? f_buildColumn(x4, length) : array.new<float>(length, 0.0)

        [xs1, m1, s1] = f_standardize(x1Arr)
        [xs2, m2, s2] = f_standardize(x2Arr)
        [xs3, m3, s3] = f_standardize(x3Arr)
        [xs4, m4, s4] = f_standardize(x4Arr)

        float beta0 = array.median(yArr)
        float beta1 = 0.0
        float beta2 = 0.0
        float beta3 = 0.0
        float beta4 = 0.0

        for iter = 1 to iterations
            float g0 = 0.0
            float g1 = 0.0
            float g2 = 0.0
            float g3 = 0.0
            float g4 = 0.0
            for i = 0 to length - 1
                float pred = beta0 + beta1 * array.get(xs1, i) + beta2 * array.get(xs2, i) + beta3 * array.get(xs3, i) + beta4 * array.get(xs4, i)
                float r    = array.get(yArr, i) - pred
                float err  = r >= 0.0 ? -tau : (1.0 - tau)
                g0 += err
                g1 += err * array.get(xs1, i)
                g2 += err * array.get(xs2, i)
                g3 += err * array.get(xs3, i)
                g4 += err * array.get(xs4, i)
            beta0 -= learningRate * g0 / length
            beta1 -= learningRate * g1 / length
            beta2 -= learningRate * g2 / length
            beta3 -= learningRate * g3 / length
            beta4 -= learningRate * g4 / length

        b1 := beta1 / s1
        b2 := nVars >= 2 ? beta2 / s2 : 0.0
        b3 := nVars >= 3 ? beta3 / s3 : 0.0
        b4 := nVars >= 4 ? beta4 / s4 : 0.0
        b0 := beta0 - b1 * m1 - (nVars >= 2 ? b2 * m2 : 0.0) - (nVars >= 3 ? b3 * m3 : 0.0) - (nVars >= 4 ? b4 * m4 : 0.0)
        yhat := b0 + b1 * x1 + (nVars >= 2 ? b2 * x2 : 0.0) + (nVars >= 3 ? b3 * x3 : 0.0) + (nVars >= 4 ? b4 * x4 : 0.0)
    [yhat, b0, b1, b2, b3, b4]



//====EXAMPLE=======




length = input.int(60, "Lookback length")

// Two arbitrary predictors — swap for whatever you actually want to regress on.
x1 = volume
x2 = ta.rsi(close, 14)

// OLS fit — sensitive to outlier bars (gaps, spikes)
[yhatOLS, b0, b1, b2] = multipleRegression(close, x1, x2, length)

// Huber (robust) fit — same inputs, down-weights outlier bars via IRLS.
// Divergence between this and the OLS line flags bars where an outlier is
// dragging the plain regression around.
[yhatHuber, _, _, _, _, _] = huberRegression(close, x1, x2, na, na, 2, length, 1.345, 10)

// Median + 10/90 quantile band — an asymmetric risk band instead of a
// single point forecast.
[qMed, _, _, _, _, _] = quantileRegression(close, x1, x2, na, na, 2, length, 0.5, 0.05, 200)
[qUp,  _, _, _, _, _] = quantileRegression(close, x1, x2, na, na, 2, length, 0.9, 0.05, 200)
[qLo,  _, _, _, _, _] = quantileRegression(close, x1, x2, na, na, 2, length, 0.1, 0.05, 200)

// Diagnostics on the OLS fit
[r2, adjR2, resSE, tStats, pVals] = regressionStats(close, x1, x2, na, na, 2, length, b0, b1, b2, 0.0, 0.0)

plot(yhatOLS,   "OLS fit",          color = color.blue,   linewidth = 1)
plot(yhatHuber, "Huber (robust)",   color = color.orange, linewidth = 2)
pUp = plot(qUp, "Q90", color = color.new(color.gray, 70))
pLo = plot(qLo, "Q10", color = color.new(color.gray, 70))
plot(qMed, "Median (Q50)", color = color.new(color.gray, 30))
fill(pUp, pLo, color = color.new(color.gray, 90))

var label statsLbl = na
if barstate.islast
    label.delete(statsLbl)
    txt = "R\u00b2: "     + str.tostring(r2, "#.###") +
          "\nadj R\u00b2: " + str.tostring(adjR2, "#.###") +
          "\nres SE: "    + str.tostring(resSE, "#.##") +
          "\nt(vol): "    + str.tostring(array.get(tStats, 1), "#.##") +
          "\nt(rsi): "    + str.tostring(array.get(tStats, 2), "#.##")
    statsLbl := label.new(bar_index, high, txt, style = label.style_label_left, color = color.new(color.blue, 80), textcolor = color.white)
````
