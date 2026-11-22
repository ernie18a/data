# Black-Litterman Allocator [BackQuant]

- url: https://www.tradingview.com/script/B3pSI5nH-Black-Litterman-Allocator-BackQuant/
- type: indicator
- pine_id: PUB;eb76a870d8dd4c6d84a4f06f11202930
- version: 1.0

## Description

# Black-Litterman Allocator [BackQuant]

[b]IMPORTANT: Concept / Educational Implementation[/b]
[b]Black-Litterman Allocator is a research and educational concept that implements a practical version of the Black-Litterman portfolio-allocation framework inside TradingView and Pine Script.[/b]

It is intended to demonstrate how equilibrium priors, covariance estimates, subjective investor views, view confidence, mean-variance optimization, portfolio constraints, volatility targeting and portfolio backtesting can be combined into one visual allocation model.

It should [b]not[/b] be interpreted as an institutional-grade portfolio optimizer, automated investment product, portfolio recommendation, or guarantee that the resulting allocation is optimal.

The outputs depend heavily on:
[list]
[*]The selected asset universe.
[*]The chart timeframe.
[*]The covariance lookback.
[*]The quality and synchronization of TradingView price data.
[*]The chosen prior-weight scheme.
[*]Risk-aversion assumptions.
[*]The investor views entered by the user.
[*]The confidence attached to those views.
[*]Portfolio constraints.
[*]Volatility-target settings.
[*]Transaction-cost assumptions.
[*]The optional regime filter.
[/list]

The default universe and default views are examples for demonstrating the framework. They are not investment recommendations.

The script is best treated as a [b]portfolio-allocation laboratory[/b]: a way to study how changing assumptions about equilibrium, risk, correlations and expected returns can propagate through a Black-Litterman-style allocation process.

[b]Overview[/b]
Black-Litterman Allocator is a 15-asset cross-asset portfolio model that starts with a neutral portfolio prior, reverse-engineers the expected returns implied by that prior, optionally incorporates up to five investor views, solves for a new posterior allocation, applies portfolio constraints and volatility targeting, and then simulates the resulting portfolio through time.

The model follows a broad sequence:

[list=1]
[*]Collect return history for the selected 15-asset universe.
[*]Estimate an annualized covariance matrix.
[*]Stabilize that matrix using diagonal covariance shrinkage.
[*]Construct a prior portfolio.
[*]Estimate the market risk-aversion parameter.
[*]Reverse-optimize the prior into implied equilibrium returns.
[*]Convert investor views into the Black-Litterman P, Q and uncertainty structure.
[*]Blend the prior with those views to obtain posterior expected returns.
[*]Optionally calculate posterior covariance.
[*]Solve a mean-variance portfolio from the posterior.
[*]Apply availability, short-selling, gross exposure and position-size constraints.
[*]Target a desired portfolio volatility.
[*]Apply additional leverage and gross-exposure caps.
[*]Rebalance periodically.
[*]Track the resulting equity curve and portfolio statistics.
[/list]

The script also provides detailed visualizations showing:
[list]
[*]Prior versus final active weights.
[*]Equilibrium versus posterior expected returns.
[*]The impact of individual views.
[*]Current gross and net exposure.
[*]Portfolio volatility and scaling.
[*]Turnover.
[*]Portfolio equity versus a benchmark.
[*]Drawdown and daily returns.
[*]A broad set of performance and risk statistics.
[/list]

[b]Why Black-Litterman exists[/b]
Traditional mean-variance optimization has an important practical weakness.

The optimizer is extremely sensitive to expected-return estimates.

Suppose several assets have similar volatility and correlation characteristics, but one asset is assigned an expected return only slightly higher than the others.

A mathematical optimizer can interpret that small difference very aggressively and allocate an unrealistic amount of capital to that asset.

Small estimation errors in expected returns can therefore produce very large changes in portfolio weights.

This is one reason unconstrained mean-variance portfolios often produce allocations that appear unstable or unintuitive.

The Black-Litterman framework was developed by Fischer Black and Robert Litterman as a way of approaching the problem from the opposite direction.

Instead of beginning with a set of independently estimated expected returns, the framework begins with an equilibrium portfolio and asks:

[b]What expected returns would make this portfolio mathematically optimal?[/b]

Those implied returns become the prior.

Investor views are then introduced as controlled deviations from that equilibrium rather than replacing the equilibrium assumptions entirely.

This creates a useful distinction:

[list]
[*][b]Prior[/b] = what the portfolio implies before the investor expresses a view.
[*][b]Views[/b] = where the investor believes equilibrium is wrong.
[*][b]Posterior[/b] = the combined result after balancing both sources of information.
[/list]

That is the central idea behind this indicator.

[b]Important distinction: the prior in this script[/b]
In textbook Black-Litterman, the equilibrium portfolio is often represented using market-capitalization weights.

This script is intentionally more flexible.

It provides three different prior schemes:
[list]
[*]Equal Weight.
[*]Inverse Volatility.
[*]Manual Weights.
[/list]

For that reason, the word [b]equilibrium[/b] should be interpreted carefully.

If Equal Weight or Inverse Volatility is selected, the prior is a [b]user-selected equilibrium proxy[/b], not necessarily the true global market portfolio.

If Manual Weights is selected and the user enters representative market-cap or benchmark weights, the prior can be made closer to the traditional Black-Litterman interpretation.

This flexibility is intentional because TradingView users may want to study Black-Litterman mechanics without first sourcing a complete set of institutional market-cap weights.

[b]Asset universe[/b]
The allocator supports fifteen simultaneously selected assets.

The default universe is designed as a broad cross-asset example containing:
[list]
[*]Cryptocurrency.
[*]US equities.
[*]International equities.
[*]Precious metals.
[*]Energy.
[*]The US dollar.
[*]Long-duration Treasury exposure.
[/list]

The default list includes assets such as Bitcoin, Ethereum, Solana, major equity indices, gold, silver, oil, DXY and TLT.

Every symbol can be replaced by the user.

This allows the framework to be adapted to:
[list]
[*]Global macro portfolios.
[*]Equity-sector portfolios.
[*]Cryptocurrency portfolios.
[*]ETF portfolios.
[*]Multi-asset portfolios.
[/list]

However, all assets should represent [b]actual price series[/b].

Market-capitalization series, synthetic quantities or unrelated non-price data should not be inserted as if they were tradable asset prices, because the resulting returns would contaminate the covariance matrix and portfolio calculations.

[b]Data availability protection[/b]
A multi-asset allocator has a specific problem when some assets have shorter histories than others.

Suppose fourteen assets have ten years of data but the fifteenth asset was only listed six months ago.

If missing values are simply converted into zeros, the new asset may appear to have:
[list]
[*]Almost no volatility.
[*]Artificially stable returns.
[*]Artificial correlations.
[/list]

This is especially dangerous when using inverse-volatility weighting, because an asset with incorrectly measured near-zero volatility could receive a very large prior allocation.

The script protects against this by maintaining a separate data-availability state for every asset.

An asset is only admitted into the active universe once it has accumulated at least one complete covariance lookback of valid price history.

Until then:
[list]
[*]Its active mask remains disabled.
[*]It receives no prior weight.
[*]It receives no optimized weight.
[*]Views referencing it are ignored.
[*]The allocation table displays it as having no usable data.
[/list]

This makes the universe dynamic.

A newly listed asset can eventually become active once enough genuine history has accumulated.

[b]Return calculations[/b]
The allocator uses two forms of return data for different purposes.

[b]Log returns[/b]
Log returns are used for covariance estimation:

[list]
[*]Log Return = ln(Price / Previous Price)
[/list]

These are stored in a rolling history matrix.

[b]Simple returns[/b]
Simple returns are used when compounding the simulated portfolio:

[list]
[*]Simple Return = Price / Previous Price - 1
[/list]

This distinction is deliberate.

Log returns are convenient for statistical covariance calculations, while simple returns are appropriate for directly multiplying portfolio wealth through time.

[b]Rolling return-history matrix[/b]
The script maintains a rolling matrix containing return history for all fifteen assets.

Each row represents a historical bar and each column represents one asset.

Once the requested covariance lookback has been collected, the matrix acts as the input for the covariance engine.

Rather than recalculating years of historical data from scratch on every bar, the script operates the history as a rolling buffer.

The full Black-Litterman calculation is also performed only on rebalance events rather than continuously.

This is important because:
[list]
[*]Covariance estimation is computationally expensive.
[*]Matrix multiplication is expensive.
[*]Matrix inversion is expensive.
[*]TradingView imposes execution limits.
[/list]

The indicator therefore approximates how a real asset-allocation process is normally operated: weights remain relatively stable between scheduled portfolio reviews and are recomputed at discrete intervals.

[b]Covariance matrix[/b]
The covariance matrix is one of the central inputs to the entire model.

For N assets, covariance produces an N × N matrix.

The diagonal contains the variance of each asset.

The off-diagonal entries contain covariance between pairs of assets.

Conceptually:

[list]
[*]Positive covariance means two assets tend to move in the same direction.
[*]Negative covariance means they tend to move in opposing directions.
[*]Covariance near zero suggests weaker linear co-movement.
[/list]

The portfolio does not consider the risk of each asset independently.

Instead, portfolio risk depends on:

[list]
[*]Individual asset volatility.
[*]Portfolio weights.
[*]The covariance relationships between every pair of assets.
[/list]

This is why diversification cannot be measured simply by counting positions.

Ten highly correlated assets may behave more like one large risk exposure than ten independent exposures.

[b]Covariance Lookback[/b]
The Covariance Lookback controls how many bars are used to estimate the covariance matrix.

Shorter windows:
[list]
[*]Adapt more quickly.
[*]Reflect recent correlation changes.
[*]Contain fewer observations.
[*]Produce noisier covariance estimates.
[/list]

Longer windows:
[list]
[*]Provide more observations.
[*]Create more statistically stable estimates.
[*]Adapt more slowly when correlations change.
[/list]

This parameter is particularly important when the number of assets is large relative to the number of observations.

With fifteen assets, an extremely short covariance window can create a poorly conditioned or nearly singular matrix.

That can make matrix inversion unstable and produce extreme portfolio weights.

[b]Annualization[/b]
The covariance matrix is annualized using the Trading Days per Year input.

The script supports:
[list]
[*]252 days.
[*]365 days.
[/list]

252 is generally appropriate for traditional financial markets operating primarily on weekdays.

365 may be more appropriate for a crypto-only daily portfolio.

Mixed universes require judgement because crypto trades continuously while many traditional markets do not.

The annualization setting affects:
[list]
[*]Covariance.
[*]Volatility.
[*]Return statistics.
[*]Risk-aversion estimates.
[/list]

It should therefore be selected consistently with the universe and timeframe being studied.

[b]Covariance shrinkage[/b]
Raw sample covariance matrices can be noisy.

This is particularly problematic when:
[list]
[*]The lookback is short.
[*]There are many assets.
[*]Several assets are highly correlated.
[*]Market relationships change rapidly.
[/list]

The script applies a simple fixed-coefficient shrinkage toward a diagonal covariance target.

The diagonal variances are retained.

The off-diagonal covariance terms are multiplied by:

[list]
[*]1 - Shrinkage
[/list]

Therefore:

[b]Shrinkage = 0[/b]
leaves the sample covariance relationships largely unchanged.

[b]Shrinkage = 1[/b]
removes the off-diagonal covariance terms and effectively treats the assets as uncorrelated for optimization purposes.

Intermediate values partially reduce estimated correlations.

This is best described as [b]Ledoit-Wolf-style diagonal shrinkage[/b], not as a full automatic Ledoit-Wolf estimator.

A true Ledoit-Wolf implementation estimates an optimal shrinkage intensity statistically.

Here, the user directly controls the shrinkage coefficient.

[b]Why shrinkage can help[/b]
Portfolio optimization involves matrix inversion.

If covariance estimates are noisy, the inverse matrix can amplify those errors dramatically.

Shrinkage intentionally sacrifices some estimated correlation detail in exchange for greater numerical stability.

A moderate amount of shrinkage can therefore:
[list]
[*]Reduce unstable allocations.
[*]Reduce sensitivity to short-term correlation noise.
[*]Improve matrix conditioning.
[/list]

Too much shrinkage can also remove genuine diversification information.

The parameter is a bias-versus-variance trade-off.

[b]Safe matrix inversion[/b]
Black-Litterman requires several matrix inversions.

Matrices can become singular or nearly singular when:
[list]
[*]Assets are highly correlated.
[*]Lookbacks are too short.
[*]Data is incomplete.
[/list]

The script checks whether the matrix is square and sufficiently non-singular before using a standard inverse.

When necessary, it falls back to a pseudo-inverse.

This does not magically make poor data reliable, but it prevents a singular matrix from immediately destroying the calculation.

A pseudo-inverse should still be interpreted cautiously because the underlying portfolio problem may be poorly conditioned.

[b]Prior portfolio[/b]
Before Black-Litterman can estimate equilibrium returns, it requires a prior portfolio.

Three schemes are provided.

[b]Equal Weight[/b]
Every active asset receives an equal allocation:

[list]
[*]Weight = 1 / Number of Active Assets
[/list]

This is the simplest prior.

It expresses no preference based on:
[list]
[*]Market capitalization.
[*]Volatility.
[*]Expected return.
[/list]

Its strength is simplicity.

Its weakness is that it assumes every asset deserves the same capital allocation regardless of risk.

[b]Inverse Volatility[/b]
Inverse Volatility gives greater prior weight to assets with lower historical volatility.

Conceptually:

[list]
[*]Raw Weight ∝ 1 / Volatility
[/list]

The weights are then normalized.

This produces a risk-oriented prior rather than a capital-oriented prior.

Lower-volatility assets receive more weight.

Higher-volatility assets receive less.

This can be useful for diversified macro portfolios, but it has an important implication:

[b]the quietest asset may dominate the prior.[/b]

For example, a bond or currency exposure may receive much more prior weight than cryptocurrency simply because its realized volatility is lower.

This is not a bug.

It is the direct consequence of using inverse volatility as the prior definition.

[b]Manual Weights[/b]
Manual mode allows the user to enter fifteen raw numbers corresponding to the fifteen selected assets.

The entries are normalized automatically.

This means the values do not need to sum to 100.

The user can enter:
[list]
[*]Percentages.
[*]Market capitalizations.
[*]Benchmark weights.
[*]Relative notional values.
[/list]

Only their proportions matter.

If the intention is to approximate traditional Black-Litterman market equilibrium, Manual Weights can be used to supply actual or approximate market-cap weights.

[b]Reverse optimization[/b]
Once the prior weights are known, the model derives the returns that would make those weights consistent with mean-variance equilibrium.

The implied equilibrium excess-return vector is:

[list]
[*]Pi = Delta × Sigma × Wprior
[/list]

where:

[list]
[*][b]Pi[/b] = implied equilibrium excess returns.
[*][b]Delta[/b] = risk-aversion coefficient.
[*][b]Sigma[/b] = covariance matrix.
[*][b]Wprior[/b] = prior portfolio weights.
[/list]

This is called [b]reverse optimization[/b].

Normal portfolio optimization asks:

[b]Given expected returns, what weights should I own?[/b]

Reverse optimization asks:

[b]Given the portfolio weights, what expected returns would justify owning them?[/b]

That reversal is one of the key ideas behind Black-Litterman.

[b]Why implied returns matter[/b]
Expected returns are difficult to estimate directly.

Historical averages are noisy.

Forecast models disagree.

Small errors can create enormous portfolio changes.

Black-Litterman instead begins from a portfolio that the user considers a reasonable neutral starting point.

The model then backs out the expected returns consistent with that portfolio.

These implied returns become the equilibrium prior against which investor opinions are expressed.

[b]Risk aversion: Delta[/b]
Delta controls the relationship between expected return and risk.

Higher Delta means:
[list]
[*]Greater assumed aversion to risk.
[*]A larger equilibrium return requirement for a given covariance structure and prior.
[/list]

Lower Delta implies less risk aversion.

The script provides:

[list]
[*]Auto (Implied).
[*]Manual.
[/list]

[b]Manual Delta[/b]
Manual mode allows the user to directly select the risk-aversion coefficient.

This is useful when:
[list]
[*]A stable assumption is preferred.
[*]The user is reproducing an external Black-Litterman study.
[*]The portfolio prior is known but a particular Delta is desired.
[/list]

[b]Auto Delta[/b]
Auto mode estimates Delta from the current prior portfolio.

The script estimates:
[list]
[*]Prior portfolio variance.
[*]An annualized return estimate over the covariance horizon.
[*]The selected risk-free rate.
[/list]

It then forms an implied risk-aversion estimate from excess return relative to variance.

The value is constrained to a practical range to prevent extreme estimates from destabilizing the optimizer.

This Auto mode is a practical implementation choice for the concept.

It should not be interpreted as a uniquely correct market risk-aversion estimate.

[b]Tau: uncertainty in the prior[/b]
Tau is one of the most important Black-Litterman parameters.

It scales uncertainty in the equilibrium prior.

Conceptually:

[list]
[*]Prior Uncertainty = Tau × Sigma
[/list]

A smaller Tau implies stronger confidence in the equilibrium-return prior.

A larger Tau gives the model more freedom to move away from the prior when investor views are introduced.

In practical terms:

[b]Smaller Tau[/b]
[list]
[*]Makes the prior harder to move.
[*]Reduces the effect of views.
[/list]

[b]Larger Tau[/b]
[list]
[*]Increases prior uncertainty.
[*]Allows views to exert more influence.
[/list]

Tau should not be interpreted in isolation.

Its effect interacts with:
[list]
[*]The covariance matrix.
[*]View confidence.
[*]View direction.
[*]The number of views.
[/list]

[b]Investor views[/b]
The script supports up to five simultaneous investor views.

Each view contains:
[list]
[*]A view type.
[*]Asset A.
[*]Optional Asset B.
[*]Expected return Q.
[*]Confidence.
[/list]

Each view can be:
[list]
[*]Off.
[*]Absolute.
[*]Relative.
[/list]

The expected-return input is interpreted as an [b]annualized expected return or annualized relative return[/b].

[b]Absolute views[/b]
An absolute view expresses an opinion about one asset.

For example:

[b]“Asset A will return 10% annually.”[/b]

In matrix notation, the corresponding row of the P matrix contains:
[list]
[*]+1 for Asset A.
[*]0 for all other assets.
[/list]

Q then contains:

[list]
[*]0.10
[/list]

for a 10% annual view.

[b]Relative views[/b]
A relative view expresses one asset relative to another.

For example:

[b]“Asset A will outperform Asset B by 5% annually.”[/b]

The corresponding P row contains:
[list]
[*]+1 for Asset A.
[*]-1 for Asset B.
[*]0 elsewhere.
[/list]

Q becomes:

[list]
[*]0.05
[/list]

This does not necessarily mean Asset A itself must return +5%.

It means:

[list]
[*]Expected Return A - Expected Return B = 5%
[/list]

Relative views are one of the most useful features of Black-Litterman because investors are often more confident about relative relationships than exact absolute returns.

It may be easier to hold the view:

[b]“Gold will outperform equities.”[/b]

than:

[b]“Gold will return exactly 12.4%.”[/b]

[b]P matrix[/b]
The P matrix describes which assets each investor view references.

Each row corresponds to one active view.

Each column corresponds to one of the fifteen assets.

An absolute view creates one non-zero exposure.

A relative view creates a long-versus-short pair.

P therefore translates a verbal market opinion into portfolio mathematics.

[b]Q vector[/b]
Q contains the expected return associated with each view.

For absolute views:

[list]
[*]Q = expected annual asset return.
[/list]

For relative views:

[list]
[*]Q = expected annual outperformance of A relative to B.
[/list]

The relationship:

[list]
[*]P × Returns = Q
[/list]

defines what the investor believes.

[b]View confidence[/b]
Black-Litterman does not require every opinion to be treated as equally reliable.

Each view therefore receives a confidence value.

Confidence controls its uncertainty.

The basic principle is:

[list]
[*]Low confidence = large view uncertainty.
[*]High confidence = small view uncertainty.
[/list]

The script converts intuitive percentage confidence into an Omega uncertainty term using a confidence mapping related to the Idzorek-style approach to expressing subjective confidence. User-specified confidence was developed precisely to make the otherwise difficult view-uncertainty input more interpretable.

[b]Omega[/b]
Omega represents uncertainty in the views.

For each active view, the script first measures the variance of the corresponding view portfolio using:

[list]
[*]P × TauSigma × P'
[/list]

It then scales that variance according to confidence:

[list]
[*]Omega = ((1 - Confidence) / Confidence) × View Variance
[/list]

This has intuitive behaviour.

[b]High confidence[/b]
If confidence approaches 100%:
[list]
[*](1 - c) / c approaches zero.
[*]Omega becomes small.
[*]The view receives substantial influence.
[/list]

[b]Low confidence[/b]
If confidence approaches zero:
[list]
[*](1 - c) / c becomes very large.
[*]Omega becomes large.
[*]The view has little effect.
[/list]

The script bounds confidence away from exactly zero and one for numerical stability.

[b]Why confidence matters[/b]
Suppose two investors both believe Bitcoin will outperform gold by 10%.

Investor A has 90% confidence.

Investor B has 20% confidence.

Their view Q is identical.

But their portfolio allocations should not necessarily be identical.

The confidence parameter allows the same directional opinion to produce very different posterior tilts.

This is one of the most useful parts of Black-Litterman.

It separates:

[list]
[*]What you believe.
[*]How strongly you believe it.
[/list]

[b]View disagreement: Q - PΠ[/b]
The Views table displays:

[list]
[*]Q - PΠ
[/list]

This measures how far the investor view differs from the equilibrium prior.

Suppose equilibrium already implies that Asset A will outperform Asset B by 8%.

If the user enters a relative view of 9%, the disagreement is only 1%.

The posterior may therefore change only slightly.

If the user instead enters 20%, the disagreement with equilibrium is much larger.

The same confidence level will then produce a much larger posterior adjustment.

This quantity is extremely useful because it shows that the impact of a view depends not only on the view itself, but on how different it is from what the prior already expects.

[b]Posterior expected returns[/b]
Once P, Q and Omega have been constructed, the script calculates the Black-Litterman posterior expected-return vector.

Conceptually:

[list]
[*]Posterior = Prior + Confidence-Weighted Adjustment
[/list]

The full adjustment depends on:
[list]
[*]Tau.
[*]Sigma.
[*]P.
[*]Q.
[*]Omega.
[*]The disagreement Q - PΠ.
[/list]

The model therefore does not simply overwrite the expected return of the named asset.

The adjustment can propagate across the entire asset universe through covariance relationships.

This is a fundamental feature of Black-Litterman.

If two assets are strongly related, a view about one may alter the posterior expectation of the other even if that second asset was not explicitly named.

[b]Why views propagate[/b]
Suppose the user enters a strong bullish view on one equity index.

If several other equity indices are highly correlated with it, the covariance matrix tells the model that those assets are economically related.

The posterior adjustment therefore does not exist in isolation.

This means:
[list]
[*]Views influence related assets.
[*]Portfolio effects depend on covariance.
[*]The same view can produce different tilts under different correlation regimes.
[/list]

That behaviour is intentional.

[b]No active views[/b]
If no usable views are active:
[list]
[*]Posterior expected returns remain equal to the equilibrium prior returns.
[/list]

The allocation is then driven by:
[list]
[*]The prior.
[*]Covariance.
[*]Risk aversion.
[*]Portfolio constraints.
[*]Volatility targeting.
[/list]

This makes the script useful even without discretionary views.

It can be used to study how the prior portfolio behaves under the optimization and risk-management layers by itself.

[b]Posterior covariance[/b]
The script can optionally include the Black-Litterman posterior covariance adjustment.

Investor views introduce uncertainty about expected returns.

The posterior covariance calculation incorporates additional uncertainty associated with combining the prior and the views.

When enabled, the optimizer uses this adjusted covariance matrix.

When disabled, optimization uses the original covariance estimate.

The practical effect is usually more subtle than changing the expected-return vector, but it can affect:
[list]
[*]Position sizes.
[*]Diversification.
[*]Volatility estimates.
[*]View-driven tilts.
[/list]

[b]Portfolio optimization[/b]
After calculating posterior expected returns, the script solves a mean-variance allocation.

The unconstrained portfolio is conceptually:

[list]
[*]w* = (Delta × SigmaPosterior)^-1 × PiPosterior
[/list]

This converts posterior return expectations and covariance into portfolio weights.

If:
[list]
[*]There are no views.
[*]The prior and covariance are internally consistent.
[*]No constraints alter the result.
[/list]

the solution tends toward the prior portfolio.

Views create deviations away from that starting point.

[b]Why unconstrained weights can be extreme[/b]
Mean-variance optimization can produce very large positive or negative positions.

This happens because matrix inversion magnifies differences between:
[list]
[*]Expected returns.
[*]Volatility.
[*]Correlations.
[/list]

If two assets are highly correlated but have slightly different expected returns, the optimizer may create a large long position in one and a large short position in the other.

Mathematically this can be valid.

Practically it may be unusable.

The script therefore applies several layers of portfolio constraints after the raw solution.

[b]Data mask[/b]
Assets without sufficient price history receive zero weight regardless of what the raw optimizer produces.

This prevents incomplete covariance columns from entering the live portfolio.

[b]Long-only mode[/b]
When Allow Short Weights is disabled:

[list]
[*]All negative optimizer weights are clipped to zero.
[/list]

The remaining positive positions are then normalized.

This converts the portfolio into a long-only allocation.

The result is no longer the exact unconstrained analytical Black-Litterman solution.

That is expected.

Real portfolios frequently require constraints that alter the theoretical optimum.

[b]Short-enabled mode[/b]
When shorting is enabled, negative posterior weights are permitted.

This allows:
[list]
[*]Long-short portfolios.
[*]Relative-value expressions.
[*]Negative allocations to assets receiving sufficiently weak posterior expectations.
[/list]

Gross exposure becomes especially important in this mode because a portfolio can have low net exposure while still carrying substantial absolute risk.

For example:

[list]
[*]+150% long.
[*]-50% short.
[*]= 100% net exposure.
[*]= 200% gross exposure.
[/list]

[b]Gross Exposure[/b]
The Gross Exposure input controls the target sum of absolute portfolio weights before volatility targeting.

Gross exposure is:

[list]
[*]Gross = Sum of |Weight|
[/list]

This differs from net exposure:

[list]
[*]Net = Sum of Weight
[/list]

For long-only portfolios, gross and net are normally similar.

For long-short portfolios, they can differ significantly.

[b]Volatility targeting[/b]
After the portfolio has been normalized, the script estimates total portfolio volatility using:

[list]
[*]Portfolio Variance = w' × Sigma × w
[*]Portfolio Volatility = sqrt(Portfolio Variance)
[/list]

This is a full covariance-aware portfolio volatility calculation.

It does not simply average asset volatility.

The model then calculates a volatility scaling factor:

[list]
[*]Volatility Scale = Target Volatility / Estimated Portfolio Volatility
[/list]

subject to minimum and maximum limits.

If estimated portfolio volatility is below target:
[list]
[*]Exposure can increase.
[/list]

If estimated volatility is above target:
[list]
[*]Exposure is reduced.
[/list]

[b]Why portfolio volatility matters[/b]
Suppose two assets each have 20% volatility.

A 50/50 portfolio does not necessarily have 20% volatility.

If the assets are weakly correlated, portfolio volatility may be much lower.

If they are highly correlated, it may remain close to 20%.

Using:

[list]
[*]sqrt(w'Σw)
[/list]

allows the volatility target to account for diversification.

[b]Target Volatility[/b]
Target Volatility defines the desired annualized risk level of the portfolio before later hard caps are considered.

Examples might conceptually include:
[list]
[*]A lower target for a defensive multi-asset portfolio.
[*]A higher target for a crypto-focused portfolio.
[/list]

The setting is not automatically appropriate simply because the portfolio reaches it.

A volatility target does not account for:
[list]
[*]Tail risk.
[*]Liquidity.
[*]Gap risk.
[*]Regime changes.
[*]Nonlinear derivatives.
[/list]

It is one risk-control dimension.

[b]Maximum volatility-target leverage[/b]
A very low-volatility portfolio can theoretically require enormous leverage to reach a high volatility target.

The Max Vol-Target Leverage setting prevents this.

For example, if the mathematical scaling factor is 6× but the maximum leverage is 3×:

[list]
[*]The model uses no more than 3×.
[/list]

This protects against explosive leverage during unusually quiet covariance estimates.

[b]Maximum weight per asset[/b]
After volatility targeting, every individual position is subjected to a hard position-size cap.

This ordering is important.

If the position cap were applied before leverage scaling, the volatility scaler could simply increase the capped position again.

Applying the cap afterward ensures the final position magnitude cannot exceed the selected maximum.

For example:

[list]
[*]Max Weight = 30%
[/list]

means no individual position can remain above 30% after the volatility scaling stage.

[b]Maximum gross exposure after volatility targeting[/b]
After individual caps are applied, the portfolio is also checked against a maximum total gross exposure.

If gross exposure exceeds that maximum, every position is scaled downward proportionally.

This provides a second portfolio-level safeguard.

The result is a hierarchy:

[list=1]
[*]Generate raw Black-Litterman weights.
[*]Apply long/short rules.
[*]Normalize initial gross exposure.
[*]Apply volatility targeting.
[*]Cap individual positions.
[*]Cap final gross exposure.
[/list]

[b]Why the target may not be reached[/b]
The volatility target is not guaranteed to be achieved exactly.

Suppose the model wants to increase portfolio exposure enough to reach 15% volatility.

If doing so would violate:
[list]
[*]Maximum leverage.
[*]Maximum asset weight.
[*]Maximum gross exposure.
[/list]

the constraints take priority.

The resulting portfolio may therefore have volatility below the requested target.

This is intentional.

Risk limits are allowed to override the target.

[b]Rebalancing[/b]
The complete optimizer does not run on every bar.

The user selects a Rebalance Every N Bars interval.

For a daily chart:
[list]
[*]Approximately 21 bars corresponds roughly to one trading month.
[/list]

Longer rebalance intervals:
[list]
[*]Reduce turnover.
[*]Reduce computation.
[*]Allow allocations to persist longer.
[/list]

Shorter intervals:
[list]
[*]React faster to new covariance and view conditions.
[*]Increase turnover.
[*]Increase computational load.
[/list]

The covariance matrix and Black-Litterman solve run only on rebalance events.

[b]Forced rebalances[/b]
Two events can trigger a solve outside the normal schedule:

[list]
[*]The regime filter changes from CASH back to ACTIVE.
[*]The number of assets with sufficient history changes.
[/list]

This prevents the portfolio from waiting many bars before responding to a material change in state.

[b]Regime filter[/b]
The script includes an optional regime filter based on the chart symbol.

The filter compares:
[list]
[*]A fast EMA.
[*]A slow EMA.
[/list]

When the fast EMA is above the slow EMA:

[list]
[*]Regime = ACTIVE
[/list]

When the fast EMA is not above the slow EMA:

[list]
[*]Regime = CASH
[/list]

This filter applies to the [b]chart symbol[/b], not individually to the fifteen assets.

That distinction is important.

If the indicator is placed on SPX, the regime filter reflects SPX.

If it is placed on Bitcoin, it reflects Bitcoin.

The regime state therefore acts as a global risk-on/risk-off switch for the entire portfolio.

[b]CASH regime[/b]
When the regime filter turns off:
[list]
[*]The live asset weights are flattened to zero.
[*]The strategy stops compounding asset returns while the regime remains inactive.
[/list]

When the filter turns ACTIVE again:
[list]
[*]A new Black-Litterman solve is forced immediately.
[/list]

The user should therefore choose the chart symbol intentionally if the regime filter is enabled.

[b]Regime filter limitation[/b]
A single chart-symbol EMA regime is an intentionally simple overlay on a much more sophisticated cross-asset model.

It should not be confused with a multi-asset economic-regime model.

It answers only:

[b]Is the fast trend of the chart symbol above its slower trend?[/b]

The regime layer can have a very large impact on historical results.

Backtests with and without it are therefore testing materially different systems.

[b]Transaction costs[/b]
The script calculates turnover on each committed rebalance:

[list]
[*]Turnover = Sum of |New Weight - Previous Weight|
[/list]

The selected transaction-fee rate is then applied to that turnover.

This is more realistic than assuming rebalancing is free.

However, the cost model remains simplified.

It does not separately model:
[list]
[*]Bid-ask spread.
[*]Slippage.
[*]Market impact.
[*]Short borrow fees.
[*]Financing costs.
[*]Taxes.
[*]Different fee schedules by asset.
[/list]

The fee input should therefore be treated as an approximate portfolio-level trading-cost assumption.

[b]Important backtest implementation note[/b]
The current implementation charges transaction fees when a new active portfolio is committed during a rebalance.

The transition that flattens the portfolio when the regime filter enters CASH is not separately charged an explicit turnover fee in the current code.

Therefore, backtests using the regime filter may slightly understate transaction costs associated with risk-off exits.

This is one reason the script should be treated as a concept rather than a production execution simulator.

[b]No-lookahead portfolio return handling[/b]
The portfolio return for the current bar is calculated using the weights that were already active before the current rebalance solve.

Only after that return has been calculated does a new set of weights become active.

This prevents the optimizer from using newly calculated current-bar weights to capture a return that occurred before those weights could have existed.

This ordering is essential for a meaningful historical simulation.

[b]Prior versus posterior weight chart[/b]
One of the main visual components is the paired horizontal weight chart.

Each asset receives two bars:
[list]
[*]Prior weight.
[*]Final active portfolio weight.
[/list]

The prior represents the selected equilibrium starting allocation.

The active portfolio reflects the portfolio after:
[list]
[*]Views.
[*]Optimization.
[*]Short constraints.
[*]Gross normalization.
[*]Volatility targeting.
[*]Position caps.
[*]Final gross caps.
[/list]

Therefore, the visible gap between the bars represents more than the mathematical Black-Litterman posterior alone.

It represents the [b]complete practical allocation change from prior to final active book[/b].

If the regime filter is currently in CASH, the live active weights may be zero.

This distinction is important when interpreting the chart.

[b]Allocation table[/b]
The Allocation Table shows each of the fifteen assets with:
[list]
[*]Prior Weight.
[*]Post Weight.
[*]Delta Weight.
[*]Equilibrium Expected Return.
[*]Posterior Expected Return.
[/list]

[b]Prior Weight[/b]
The allocation before investor views and final portfolio construction.

[b]Post Weight[/b]
The current active portfolio weight after the complete optimization and risk-control process.

[b]Delta Weight[/b]
The difference between the active weight and prior weight.

Positive values indicate the asset has been increased relative to the prior.

Negative values indicate it has been reduced.

[b]Equilibrium E[R][/b]
The implied return derived through reverse optimization.

[b]Posterior E[R][/b]
The expected return after the active investor views have been incorporated.

Comparing equilibrium and posterior expected return is often more informative than looking only at weights.

A return expectation can change substantially while the final weight changes only modestly because:
[list]
[*]The asset is highly volatile.
[*]It is highly correlated with another holding.
[*]The maximum-weight constraint binds.
[*]Portfolio volatility limits exposure.
[/list]

[b]Views table[/b]
The Views Table shows each active view and includes:
[list]
[*]View description.
[*]Q.
[*]Confidence.
[*]Omega.
[*]Q - PΠ.
[/list]

This allows the user to inspect not only what the view says, but how strongly it conflicts with equilibrium and how uncertain it is.

Two views with identical Q values may have very different portfolio effects if:
[list]
[*]Confidence differs.
[*]Covariance differs.
[*]Equilibrium expectations differ.
[/list]

[b]Current Book table[/b]
The Current Book table provides a compact summary of the active portfolio.

It includes:
[list]
[*]ACTIVE or CASH regime.
[*]Prior scheme.
[*]Number of active views.
[*]Number of rebalances.
[*]Gross exposure.
[*]Net exposure.
[*]Number of live assets.
[*]Turnover.
[*]Risk-aversion Delta.
[*]Tau.
[*]Estimated portfolio volatility.
[*]Volatility scaling factor.
[/list]

This table is useful for diagnosing why the allocator currently looks the way it does.

For example:

[b]Large view changes but small weights[/b]
may be explained by a tight volatility target or maximum-weight constraint.

[b]Large gross but low net[/b]
may indicate significant long-short exposure.

[b]Few live assets[/b]
means part of the universe has not yet accumulated sufficient historical data.

[b]Equity curve[/b]
The script maintains a simulated portfolio equity curve beginning from the selected Initial Capital.

Initial Capital affects only the scale of the equity curve.

It does not affect:
[list]
[*]Weights.
[*]Sharpe ratio.
[*]Volatility.
[*]Portfolio optimization.
[/list]

The equity curve compounds the historical portfolio returns generated by the active weights.

The line changes colour according to whether equity increased or decreased from the previous bar.

[b]Benchmark Buy & Hold[/b]
A benchmark equity curve can be displayed beside the portfolio.

Both curves begin from the same nominal capital.

The benchmark is also used in:
[list]
[*]Beta.
[*]Alpha.
[/list]

The benchmark can be changed independently from the fifteen-asset universe.

For meaningful interpretation, the benchmark should be relevant to the portfolio being studied.

A broad global macro portfolio compared only with SPX is answering a different question from an equity portfolio compared with SPX.

[b]Daily returns[/b]
The script can optionally plot the portfolio’s per-bar percentage return.

This is useful for visually inspecting:
[list]
[*]Return clustering.
[*]Large gains.
[*]Large losses.
[*]Regime-filter cash periods.
[/list]

Because it shares the pane with the equity curve, it is generally best viewed separately.

[b]Rolling drawdown[/b]
Drawdown is measured relative to the previous portfolio-equity peak:

[list]
[*]Drawdown = (Current Equity - Peak Equity) / Peak Equity
[/list]

The result is negative while the portfolio remains below its historical high.

The visual fill becomes stronger as drawdown deepens.

The Max DD for Scaling input affects only the visual intensity scale.

It does not limit portfolio losses or modify the allocation.

[b]Performance metrics[/b]
The metrics table includes a broad range of return and risk statistics.

[b]Net Profit[/b]
Percentage change in portfolio equity from initial capital.

[b]Maximum Drawdown[/b]
Largest historical peak-to-trough decline in the simulated portfolio.

[b]Win Rate[/b]
Percentage of non-zero portfolio-return bars that were positive.

Flat CASH bars are excluded from the win/loss count.

This prevents periods where the portfolio is deliberately inactive from automatically being classified as losing periods.

[b]Annual Mean Return[/b]
Arithmetic average per-bar portfolio return multiplied by the selected annualization factor.

This is not identical to CAGR.

[b]Annual Standard Deviation[/b]
Per-bar return standard deviation scaled by the square root of the annualization factor.

[b]Variance[/b]
Square of annualized standard deviation.

[b]Sharpe Ratio[/b]
Measures annualized excess mean return relative to total return volatility using the selected risk-free rate.

[b]Sortino Ratio[/b]
Measures return relative to downside-return variability rather than total volatility.

[b]Omega Ratio[/b]
Compares the aggregate positive portfolio returns with the magnitude of aggregate negative portfolio returns.

[b]Gain-to-Pain[/b]
Compares net return with the aggregate magnitude of negative returns.

[b]CAGR[/b]
Compound annual growth rate based on beginning equity, ending equity and elapsed calendar time.

[b]Calmar Ratio[/b]
CAGR divided by absolute maximum drawdown.

[b]Beta[/b]
Measures covariance of portfolio returns with benchmark returns relative to benchmark variance.

[b]Alpha[/b]
Estimates annualized portfolio return in excess of the return implied by its benchmark Beta and selected risk-free rate.

[b]Skewness[/b]
Measures asymmetry of the historical portfolio-return distribution.

Positive skew indicates a longer or heavier positive tail.

Negative skew indicates a more pronounced negative tail.

[b]VaR 95th Percentile[/b]
The implementation reports the fifth percentile of historical portfolio returns.

It can be interpreted as the lower-tail return threshold associated with approximately the worst 5% of observations.

It is displayed as a return value rather than converting the loss into a positive number.

[b]Conditional VaR[/b]
Conditional VaR averages the returns in the lowest 5% tail.

This provides information about the average severity of outcomes beyond the VaR threshold.

Historical VaR and Conditional VaR rely entirely on the observed backtest sample.

They should not be interpreted as guarantees about future tail losses.

[b]Risk-free rate[/b]
The selected Risk-Free Rate influences:
[list]
[*]Sharpe.
[*]Alpha.
[*]Auto risk-aversion estimation.
[/list]

Changing it therefore affects both reported performance statistics and potentially the portfolio itself when Auto Delta is enabled.

[b]Understanding prior versus posterior[/b]
The most important conceptual visualization in the script is the difference between the prior and posterior state.

Suppose the prior allocation is:

[list]
[*]Asset A: 20%
[*]Asset B: 20%
[*]Asset C: 20%
[*]Asset D: 20%
[*]Asset E: 20%
[/list]

Now suppose the investor enters:

[b]Asset A will outperform Asset B by 8%, with high confidence.[/b]

Black-Litterman does not simply add 8% weight to A and remove 8% from B.

Instead, the model asks:
[list]
[*]What did equilibrium already imply about A versus B?
[*]How uncertain is the prior?
[*]How confident is the investor?
[*]What is the covariance of the A-minus-B view?
[*]How are A and B related to the rest of the portfolio?
[/list]

The resulting posterior return adjustment then passes through the optimizer.

The final weights are subsequently modified by the portfolio constraints.

This explains why Black-Litterman allocations can behave very differently from manually applying arbitrary portfolio tilts.

[b]Example: low-confidence relative view[/b]
Suppose equilibrium implies:

[list]
[*]Expected A return = 8%
[*]Expected B return = 7%
[/list]

The equilibrium difference is 1%.

The investor believes:

[list]
[*]A will outperform B by 5%
[/list]

but assigns only 20% confidence.

The view disagrees with equilibrium, but Omega is relatively large because confidence is low.

The posterior therefore moves toward the investor view without fully accepting it.

[b]Example: high-confidence relative view[/b]
Using the same equilibrium assumptions, suppose confidence is increased to 90%.

Omega becomes much smaller.

The investor view therefore carries much greater influence.

The posterior A-minus-B expected-return spread moves much closer toward the stated view.

The final weights may then shift significantly, subject to risk and portfolio constraints.

[b]Example: view already priced into equilibrium[/b]
Suppose the user believes A will outperform B by 5%.

But the equilibrium prior already implies approximately 5%.

Then:

[list]
[*]Q - PΠ ≈ 0
[/list]

There is little disagreement to resolve.

Even a high-confidence view may produce only a small posterior adjustment.

This is an important property of the model.

Black-Litterman does not reward the user simply for entering a strong opinion.

The opinion must differ from equilibrium before it meaningfully changes the posterior.

[b]Absolute versus relative confidence[/b]
Absolute views generally require greater confidence in the expected return level itself.

Relative views can be easier to interpret because the user only needs an opinion about the spread between two assets.

For example:

[list]
[*]“Equities will return 14%.”
[/list]

is a stronger forecasting statement than:

[list]
[*]“Equities will outperform bonds by 4%.”
[/list]

Neither is inherently superior.

The model supports both because portfolio managers frequently express views in both forms.

[b]Why the model is useful conceptually[/b]
The value of Black-Litterman is not that it discovers the future.

It provides a disciplined method for converting beliefs into portfolio changes.

Without a framework, an investor may say:

[list]
[*]“I like gold.”
[*]“I am bearish equities.”
[*]“Bitcoin should outperform bonds.”
[/list]

but those statements do not specify:
[list]
[*]How much the portfolio should change.
[*]How volatility should affect the position.
[*]How correlated assets should respond.
[*]How conviction should change the allocation.
[/list]

Black-Litterman forces those opinions into a structured portfolio context.

That is what this indicator is intended to demonstrate.

[b]Important implementation difference from institutional Black-Litterman[/b]
The script implements the core Black-Litterman mechanics, but several choices are intentionally simplified for TradingView.

These include:
[list]
[*]A fixed maximum universe of fifteen assets.
[*]Up to five investor views.
[*]User-selected fixed covariance shrinkage rather than automatically estimated shrinkage intensity.
[*]Equal-weight and inverse-volatility priors in addition to manual market-style priors.
[*]A simplified Auto Delta estimate.
[*]Discrete bar-based rebalancing.
[*]Simplified transaction costs.
[*]A single chart-symbol regime filter.
[*]Historical covariance from TradingView price data.
[/list]

These choices make the model practical and interpretable inside Pine Script.

They also mean that results should not be compared directly with a production institutional implementation without understanding the differences.

[b]Mixed-market data considerations[/b]
Cross-asset portfolios introduce data-alignment problems.

Cryptocurrency trades continuously.

Equities, commodities and bonds have market sessions and holidays.

Different TradingView symbols may also come from different exchanges or data providers.

The covariance matrix assumes the return observations are meaningfully aligned.

Users should therefore be careful with:
[list]
[*]Intraday mixed-asset universes.
[*]Assets from incompatible sessions.
[*]Symbols with limited historical coverage.
[*]Synthetic or non-tradable price series.
[/list]

Daily or broader timeframes are generally easier to interpret for a macro allocation concept.

[b]Backtest limitations[/b]
Historical simulation is useful for understanding behaviour, but this should not be treated as proof of future performance.

The backtest does not model every real-world implementation issue.

Examples include:
[list]
[*]Bid-ask spreads.
[*]Market impact.
[*]Execution latency.
[*]Portfolio financing.
[*]Borrow availability.
[*]Short borrow costs.
[*]Taxes.
[*]Different trading sessions.
[*]Rebalancing at exact executable prices.
[*]Changes in instrument availability.
[*]Survivorship effects in a manually selected universe.
[/list]

The model also uses historical covariance as an estimate of future covariance.

Correlations can change abruptly during stress periods.

The most diversified-looking portfolio based on historical data can become much more concentrated in risk when formerly independent assets begin moving together.

[b]No automatic investment views[/b]
The script does not create investor views for the user.

Q and confidence are deliberately manual.

This is important because Black-Litterman is a framework for [b]combining[/b] beliefs with equilibrium.

It does not tell the investor what those beliefs should be.

Views could theoretically come from:
[list]
[*]Macro analysis.
[*]Valuation models.
[*]Momentum models.
[*]Fundamental research.
[*]Quantitative forecasts.
[*]Discretionary judgement.
[/list]

The quality of the posterior cannot exceed the quality of the assumptions provided to it.

[b]Parameter interaction[/b]
Black-Litterman parameters should not be tuned independently.

Several important interactions exist.

[b]Tau + Confidence[/b]
Both influence how aggressively views move the posterior.

Higher prior uncertainty combined with high view confidence can create strong posterior changes.

[b]Covariance Lookback + Shrinkage[/b]
A short noisy covariance window may require more shrinkage for stability.

A long sample may tolerate less.

[b]Target Volatility + Leverage Caps[/b]
A high volatility target may have little effect if maximum leverage or gross exposure is restrictive.

[b]Views + Max Weight[/b]
A strong posterior preference for one asset may never appear fully in the active portfolio if the asset cap is binding.

[b]Shorts + Gross Exposure[/b]
Allowing shorts can materially increase gross exposure even when net exposure looks conservative.

[b]Rebalance Frequency + Fees[/b]
Frequent optimization allows faster adaptation but increases turnover and assumed trading cost.

[b]Prior selection[/b]
The choice of prior is not cosmetic.

It changes the equilibrium return vector itself.

The same investor views can therefore produce different posterior portfolios depending on whether the starting prior is:
[list]
[*]Equal Weight.
[*]Inverse Volatility.
[*]Market-like Manual Weights.
[/list]

Users studying the framework should therefore treat prior construction as one of the primary model assumptions.

[b]Suggested research workflow[/b]
A useful way to study the indicator is:

[list=1]
[*]Begin with no investor views.
[*]Choose a prior.
[*]Observe the implied equilibrium returns.
[*]Inspect the covariance-driven allocation.
[*]Add one low-confidence relative view.
[*]Observe Q - PΠ.
[*]Compare equilibrium and posterior returns.
[*]Increase confidence gradually.
[*]Observe how the posterior and weights respond.
[*]Add a second view.
[*]Experiment with Tau.
[*]Enable and disable posterior covariance.
[*]Compare long-only and short-enabled portfolios.
[*]Change the volatility target.
[*]Observe when position or gross caps become binding.
[/list]

This is generally more informative than immediately entering five aggressive views and trying to interpret the final result.

[b]Example research questions[/b]
The allocator can be used to study questions such as:

[list]
[*]How much does a 70% confidence view move the portfolio compared with 30% confidence?
[*]How does inverse-volatility equilibrium differ from equal-weight equilibrium?
[*]How does covariance shrinkage change portfolio concentration?
[*]How do relative views propagate into assets not explicitly named?
[*]How much does volatility targeting alter the raw optimizer?
[*]How often do hard position caps bind?
[*]How different are equilibrium expected returns from posterior expected returns?
[*]How much turnover is generated by monthly versus weekly rebalancing?
[*]How does a regime filter alter drawdown and opportunity cost?
[/list]

These are the types of questions the concept is designed to explore.

[b]Input guide[/b]
[b]Initial Capital[/b]
Controls the starting dollar value of the simulated equity curve.

It does not change portfolio weights.

[b]Trading Days/Year[/b]
Controls annualization.

Use a value consistent with the universe being studied.

[b]Target Volatility[/b]
Sets the desired annualized portfolio-volatility target before hard leverage and weight constraints.

[b]Transaction Fees[/b]
Approximate fee charged per unit of rebalance turnover.

[b]Rebalance Every N Bars[/b]
Controls how frequently the full covariance and Black-Litterman solve occurs.

[b]Allow Short Weights[/b]
Allows negative optimized weights.

[b]Max Weight per Asset[/b]
Hard cap on individual position magnitude after volatility targeting.

[b]Gross Exposure[/b]
Target absolute exposure before volatility scaling.

[b]Max Gross After Vol Target[/b]
Final portfolio-level ceiling on gross exposure.

[b]Max Vol-Target Leverage[/b]
Maximum scaling multiplier permitted by volatility targeting.

[b]Covariance Lookback[/b]
Historical window used for covariance estimation and minimum data availability.

[b]Covariance Shrinkage[/b]
Reduces off-diagonal covariance estimates toward zero.

[b]Tau[/b]
Controls uncertainty in the equilibrium prior.

[b]Use Posterior Covariance[/b]
Allows view uncertainty to modify the covariance matrix used by the optimizer.

[b]Risk Aversion[/b]
Selects automatically estimated or manually specified Delta.

[b]Prior Weight Scheme[/b]
Selects Equal Weight, Inverse Volatility or Manual Weights.

[b]Investor Views[/b]
Supports up to five annualized absolute or relative return views.

[b]Confidence[/b]
Controls the uncertainty assigned to each view.

[b]Start Date[/b]
Defines the beginning of simulated portfolio equity.

Historical data before the date may still be used to warm up covariance estimates.

[b]Risk-Free Rate[/b]
Used in portfolio statistics and Auto Delta estimation.

[b]Benchmark[/b]
Used for the buy-and-hold comparison, Alpha and Beta.

[b]Regime Filter[/b]
Optional chart-symbol fast/slow EMA filter that moves the portfolio between ACTIVE and CASH.

[b]Prior vs Posterior visualization[/b]
Displays the difference between the selected prior allocation and current final portfolio weights.

[b]Strengths[/b]
[list]
[*]Implements the central Black-Litterman prior-and-views framework directly in Pine.
[*]Supports both absolute and relative investor views.
[*]Allows confidence to directly control view uncertainty.
[*]Uses a complete cross-asset covariance matrix.
[*]Includes diagonal covariance shrinkage.
[*]Supports dynamic asset-data availability.
[*]Provides equal-weight, inverse-volatility and manual priors.
[*]Supports long-only and long-short allocation.
[*]Uses covariance-aware portfolio volatility targeting.
[*]Includes individual and portfolio-level exposure constraints.
[*]Accounts for rebalance turnover fees.
[*]Provides extensive allocation, view and portfolio diagnostics.
[*]Includes a visual prior-versus-final-weight comparison.
[*]Includes portfolio equity, benchmark and risk statistics.
[/list]

[b]Limitations[/b]
[list]
[*]This is a concept and educational implementation, not an institutional portfolio-management system.
[*]Historical covariance is only an estimate of future relationships.
[*]The 15-asset universe is fixed in size.
[*]A maximum of five views can be entered.
[*]The prior is only a true market-equilibrium proxy if the selected weights appropriately represent one.
[*]Equal Weight and Inverse Volatility are practical prior substitutes rather than literal global market-cap equilibrium.
[*]The shrinkage coefficient is user-selected rather than statistically estimated.
[*]Auto Delta is a practical approximation.
[*]Portfolio optimization remains sensitive to inputs.
[*]Poor views can produce poor posterior estimates.
[*]High-confidence incorrect views can materially damage the portfolio.
[*]Volatility targeting does not protect against all forms of risk.
[*]Historical volatility can underestimate future crisis volatility.
[*]Hard constraints mean the final portfolio may differ substantially from the analytical unconstrained Black-Litterman optimum.
[*]The final volatility target may not be reached when position, leverage or gross limits bind.
[*]The regime filter is based only on the chart symbol.
[*]The backtest uses simplified transaction costs.
[*]Regime-driven exits to CASH are not separately charged an explicit turnover fee in the current implementation.
[*]Mixed-market TradingView data can contain differing sessions and histories.
[*]Backtested performance does not establish future performance.
[/list]

[b]Historical and theoretical context[/b]
The Black-Litterman framework was developed to address practical problems encountered when applying mean-variance optimization to global portfolios.

Its central contribution is not simply another optimization equation.

It is a different way of constructing expected returns.

Instead of requiring the investor to estimate every asset’s return independently, equilibrium returns provide a coherent starting point. Investor views then alter only the parts of that equilibrium where the investor has an opinion.

This structure can be summarized as:

[list]
[*]Start neutral.
[*]Reverse-engineer equilibrium.
[*]State where you disagree.
[*]State how strongly you disagree.
[*]Let covariance propagate those beliefs.
[*]Re-optimize the portfolio.
[/list]

The original Black-Litterman work emphasized equilibrium as a neutral starting point and allowed investor opinions about absolute or relative performance to tilt that equilibrium according to confidence.

Later work on user-specified confidence made the view-uncertainty problem easier to interpret by expressing conviction in intuitive percentage terms rather than requiring users to manually specify an abstract uncertainty covariance for every view.

This indicator takes those principles and translates them into a practical TradingView research environment.

[b]Summary[/b]
Black-Litterman Allocator is an experimental portfolio-allocation framework designed to demonstrate how equilibrium, investor beliefs and portfolio risk can be combined inside TradingView.

The model begins with fifteen selectable assets and estimates their annualized covariance structure using historical log returns. A user-controlled shrinkage process reduces noisy cross-asset covariance estimates, while assets without sufficient historical data are excluded until a complete covariance window becomes available.

The user then selects an Equal Weight, Inverse Volatility or Manual prior portfolio.

That prior is reverse-optimized into implied equilibrium expected returns:

[list]
[*]Pi = Delta × Sigma × Prior Weights
[/list]

Up to five absolute or relative investor views can then be introduced.

Each view specifies:
[list]
[*]What the investor expects.
[*]Which assets the view applies to.
[*]How confident the investor is.
[/list]

Confidence is translated into view uncertainty, allowing weak opinions to create small tilts and high-confidence opinions to exert greater influence.

The Black-Litterman posterior combines those views with equilibrium while accounting for covariance relationships across the entire portfolio.

The resulting posterior expected returns are converted into an optimized allocation, after which the script applies:
[list]
[*]Data-availability rules.
[*]Optional long-only constraints.
[*]Gross-exposure normalization.
[*]Portfolio volatility targeting.
[*]Maximum leverage.
[*]Maximum position sizes.
[*]Maximum gross exposure.
[/list]

The portfolio is then rebalanced through time, transaction costs are approximated, an optional chart-level regime filter can move the book into CASH, and the resulting historical equity curve is compared with a selectable benchmark.

Extensive tables show:
[list]
[*]Prior and final weights.
[*]Equilibrium and posterior returns.
[*]View confidence and uncertainty.
[*]View disagreement with equilibrium.
[*]Gross and net exposure.
[*]Portfolio volatility.
[*]Turnover.
[*]Performance and risk statistics.
[/list]

The purpose of the script is not to claim that Black-Litterman can identify the optimal future portfolio.

Its purpose is to make the framework tangible.

It provides a way to explore how a neutral portfolio can be translated into implied expected returns, how subjective beliefs can be incorporated without completely discarding that prior, how confidence changes the strength of those beliefs, how covariance spreads their effects across the portfolio, and how practical constraints can transform a theoretical posterior into a more realistic active allocation.

[b]Treat the indicator as a concept, a research tool, and a visual implementation of portfolio-allocation theory rather than as an automated investment recommendation.[/b]

## Source Code

````pine
///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

// Black-Litterman Allocator
// 1) Estimate an annualized covariance matrix from the 15-asset universe, with shrinkage toward the diagonal
// 2) Reverse-optimize the prior (market) weights into implied equilibrium excess returns:  Pi = delta * Sigma * w_mkt
// 3) Blend Pi with up to 5 investor views (absolute or relative) weighted by confidence
// 4) Solve the posterior for optimal weights:  w* = (delta * Sigma_post)^-1 * Pi_post
// 5) Constrain, vol-target, and build an equity curve versus benchmark buy & hold

// Execution note: every piece of persistent state is written only on confirmed bars. Pine rolls back
// scalar variables on each realtime tick but does NOT roll back mutations to arrays and matrices,
// so unguarded collection writes would accumulate intraday and make live behaviour diverge from the
// backtest. Gating on barstate.isconfirmed makes realtime and historical execution identical.

//@version=6
indicator(
 "Black-Litterman Allocator [BackQuant]",
 overlay=false,
 max_boxes_count=500,
 max_labels_count=500,
 max_lines_count=500
 )

// Groups
const string settings    = "Portfolio Settings"
const string blengine    = "Black-Litterman Engine"
const string priorgrp    = "Prior / Equilibrium Weights"
const string manualgrp   = "Prior Weights (Manual Entry)"
const string viewsgrp    = "Investor Views"
const string backtesting = "Backtesting and Metrics"
const string assetsel    = "Asset Selection"
const string pv          = "Plotting and Visualizations"
const string blchart     = "Prior vs Posterior Chart"

// Portfolio Settings
int initial_cap    = input.int(10000, "Initial Capital ($)", group = settings, inline = "capital", tooltip = "Starting portfolio value in dollars. Only scales the equity curve, it does not affect weights or ratio-based metrics.")
int tradingdays    = input.int(252, "Trading Days/Year", options = [252, 365], group = settings, inline = "capital", tooltip = "Used to annualize volatility, covariance and returns.\n252 for traditional markets (stocks, indices, commodities)\n365 for crypto-only universes that trade 24/7.\nThe default universe is mixed and should be run on a weekday-session chart, so leave this at 252.")
float targetVol    = input.float(15, "Target Volatility (%)", group = settings, inline = "risk", tooltip = "Annualized volatility target for the whole book.\nPortfolio vol is measured properly as sqrt(w' * Sigma * w), which accounts for correlation between holdings, rather than scaling each asset in isolation.\n10-15% suits a macro portfolio. 40%+ suits crypto.") / 100
float fee_rate     = input.float(0.001, "Transaction Fees", group = settings, inline = "risk", step = 0.001, tooltip = "Fee per unit of turnover as a decimal (0.001 = 0.1%).\nCharged on the sum of absolute weight changes at each rebalance, so completely rotating the book costs roughly 2x this number.")
int rebal_bars     = input.int(21, "Rebalance Every N Bars", minval = 1, group = settings, inline = "timing", tooltip = "How often the full Black-Litterman solve runs.\n21 = roughly monthly on daily bars, which is the realistic use case for this model.\nLOWER VALUES ARE SLOWER. The covariance rebuild and matrix inversion only run on rebalance bars, so this is the main lever on execution time.")
bool allow_shorts  = input.bool(false, "Allow Short Weights", group = settings, inline = "constraints", tooltip = "Unchecked = long-only, negative posterior weights are clipped to zero before normalizing.\nChecked = the optimizer can short assets its views dislike, and the weight chart re-centers to show both sides.")
float max_weight   = input.float(30.0, "Max Weight per Asset (%)", minval = 5, maxval = 100, group = settings, inline = "constraints", tooltip = "Hard cap on any single position, enforced AFTER volatility targeting so the number you type is the number you get.\nUnconstrained mean-variance optimizers famously dump everything into one or two names, so this keeps the book diversified.") / 100
float gross_target = input.float(100.0, "Gross Exposure (%)", minval = 10, maxval = 300, group = settings, inline = "constraints", tooltip = "Target sum of absolute weights before volatility targeting is applied.\n100 = fully invested.\n200 = 2x gross, e.g. 150% long against 50% short. Only meaningful above 100 when shorts are enabled.") / 100
float max_gross    = input.float(150.0, "Max Gross After Vol Target (%)", minval = 10, maxval = 400, group = settings, inline = "caps", tooltip = "Absolute ceiling on total gross exposure, enforced AFTER volatility targeting.\nWithout this, a low-vol book gets levered by the vol scaler and blows straight through the Gross Exposure setting above. 150 means the book can never exceed 1.5x notional no matter what the vol target asks for.") / 100
float max_leverage = input.float(3.0, "Max Vol-Target Leverage", minval = 1.0, maxval = 5.0, step = 0.25, group = settings, inline = "caps", tooltip = "Ceiling on the volatility-targeting multiplier.\nIf realized portfolio vol comes in far below target, the engine levers up to reach it. This caps how far. Lower it if you see Vol Scale running hot in the Current Book table.")

// Black-Litterman Engine
int covLookback     = input.int(90, "Covariance Lookback", minval = 20, maxval = 500, group = blengine, inline = "cov", tooltip = "Bars used to estimate the covariance matrix.\nMUST comfortably exceed the number of assets (15) or the matrix is rank-deficient and the inverse becomes garbage.\nThis value also sets how much real history an asset needs before the allocator will trade it at all.\nCapped at 500 to stay inside the historical buffer and execution budget.")
float shrinkage     = input.float(0.20, "Covariance Shrinkage", minval = 0.0, maxval = 1.0, step = 0.05, group = blengine, inline = "cov", tooltip = "Ledoit-Wolf style shrinkage of the off-diagonal terms toward a diagonal target.\n0 = raw sample covariance, noisy and close to singular on short lookbacks\n1 = ignore all correlations entirely\n0.15-0.35 is the usual sweet spot. Raise it if weights look unstable between rebalances.")
float tau           = input.float(0.05, "Tau (Prior Uncertainty)", minval = 0.005, maxval = 1.0, step = 0.005, group = blengine, inline = "tau", tooltip = "Scales how uncertain the model is about the equilibrium prior.\nSmaller tau = more confidence in the market prior, so your views move the weights less.\nHe & Litterman use 0.025-0.05. This is the single biggest lever on how much your views matter.")
bool use_post_cov   = input.bool(true, "Use Posterior Covariance", group = blengine, inline = "tau", tooltip = "Adds the Black-Litterman posterior covariance term to Sigma before optimizing.\nThis accounts for the extra estimation error your views introduce, which slightly shrinks position sizes. Turn it off to optimize against the raw sample covariance instead.")
string delta_mode   = input.string("Auto (Implied)", "Risk Aversion", options = ["Auto (Implied)", "Manual"], group = blengine, inline = "delta", tooltip = "Auto: delta is reverse-engineered each rebalance as (prior excess return) / (prior variance), then clamped to a sane range.\nManual: pin delta yourself. Higher delta = more risk averse = smaller raw positions before normalization.")
float delta_manual  = input.float(2.5, "Manual Delta", minval = 0.1, maxval = 20.0, step = 0.1, group = blengine, inline = "delta", tooltip = "Only used when Risk Aversion is set to Manual. 2.0-3.0 is the range most of the literature uses for broad market portfolios.")

// Prior / Equilibrium Weights
string prior_scheme = input.string("Inverse Volatility", "Prior Weight Scheme", options = ["Equal Weight", "Inverse Volatility", "Manual Weights"], group = priorgrp, tooltip = "The 'market portfolio' that gets reverse-optimized into equilibrium returns. This is your starting point before any views are applied.\n\nEqual Weight: naive 1/N, simple and unopinionated\nInverse Volatility: risk-based proxy, quieter assets get more weight. Be aware this hands the largest prior weight to the calmest asset in the universe, which on a macro book is usually the dollar or bonds.\nManual Weights: enter real market cap weights yourself if you have them\n\nAssets without enough price history are excluded from every scheme automatically.")

float mw1  = input.float(6.67, "1",  minval = 0, group = manualgrp, inline = "mw1")
float mw2  = input.float(6.67, "2",  minval = 0, group = manualgrp, inline = "mw1")
float mw3  = input.float(6.67, "3",  minval = 0, group = manualgrp, inline = "mw1")
float mw4  = input.float(6.67, "4",  minval = 0, group = manualgrp, inline = "mw1")
float mw5  = input.float(6.67, "5",  minval = 0, group = manualgrp, inline = "mw1")
float mw6  = input.float(6.67, "6",  minval = 0, group = manualgrp, inline = "mw2")
float mw7  = input.float(6.67, "7",  minval = 0, group = manualgrp, inline = "mw2")
float mw8  = input.float(6.67, "8",  minval = 0, group = manualgrp, inline = "mw2")
float mw9  = input.float(6.67, "9",  minval = 0, group = manualgrp, inline = "mw2")
float mw10 = input.float(6.67, "10", minval = 0, group = manualgrp, inline = "mw2")
float mw11 = input.float(6.67, "11", minval = 0, group = manualgrp, inline = "mw3")
float mw12 = input.float(6.67, "12", minval = 0, group = manualgrp, inline = "mw3")
float mw13 = input.float(6.67, "13", minval = 0, group = manualgrp, inline = "mw3")
float mw14 = input.float(6.67, "14", minval = 0, group = manualgrp, inline = "mw3")
float mw15 = input.float(6.67, "15", minval = 0, group = manualgrp, inline = "mw3", tooltip = "Raw prior weights matching Assets 1-15 in order. They are normalized to sum to 100% automatically, so you can enter market caps in billions or any other unit and it still works.\nOnly used when Prior Weight Scheme is set to 'Manual Weights'.")

// Investor Views
string vh = input.string("", "Views are ANNUALIZED expected returns", group = viewsgrp, tooltip = "ABSOLUTE: 'Asset A will return X% per year'\nRELATIVE: 'Asset A will outperform Asset B by X% per year'\n\nConfidence drives Omega (view uncertainty) via the Idzorek method:\nomega = ((1-c)/c) * p * tau*Sigma * p'\n\nAt 99% confidence the view nearly pins the posterior. At 1% it barely tilts it. This is how you express conviction without hard-coding weights.\n\nAsset numbers 1-15 map to the Asset Selection list in order. For an Absolute view only A is used and B is ignored.\nA view is skipped automatically if it references an asset that has no price history yet.\n\nNote the posterior return adjustment propagates through the covariance structure, so high-variance assets absorb larger revisions than low-variance ones even when your view names the quiet assets directly. That is the model working, not a bug.")

string v1_type = input.string("Relative", "V1", options = ["Off", "Absolute", "Relative"], group = viewsgrp, inline = "v1", tooltip = "View 1. Off disables it entirely and removes its row from the P matrix.")
int    v1_a    = input.int(1, "A", minval = 1, maxval = 15, group = viewsgrp, inline = "v1")
int    v1_b    = input.int(5, "B", minval = 1, maxval = 15, group = viewsgrp, inline = "v1")
float  v1_q    = input.float(15.0, "E[R]%", group = viewsgrp, inline = "v1")
float  v1_c    = input.float(50.0, "Conf%", minval = 1, maxval = 99, group = viewsgrp, inline = "v1")

string v2_type = input.string("Off", "V2", options = ["Off", "Absolute", "Relative"], group = viewsgrp, inline = "v2")
int    v2_a    = input.int(11, "A", minval = 1, maxval = 15, group = viewsgrp, inline = "v2")
int    v2_b    = input.int(14, "B", minval = 1, maxval = 15, group = viewsgrp, inline = "v2")
float  v2_q    = input.float(8.0, "E[R]%", group = viewsgrp, inline = "v2")
float  v2_c    = input.float(40.0, "Conf%", minval = 1, maxval = 99, group = viewsgrp, inline = "v2")

string v3_type = input.string("Off", "V3", options = ["Off", "Absolute", "Relative"], group = viewsgrp, inline = "v3")
int    v3_a    = input.int(6, "A", minval = 1, maxval = 15, group = viewsgrp, inline = "v3")
int    v3_b    = input.int(5, "B", minval = 1, maxval = 15, group = viewsgrp, inline = "v3")
float  v3_q    = input.float(4.0, "E[R]%", group = viewsgrp, inline = "v3")
float  v3_c    = input.float(30.0, "Conf%", minval = 1, maxval = 99, group = viewsgrp, inline = "v3")

string v4_type = input.string("Off", "V4", options = ["Off", "Absolute", "Relative"], group = viewsgrp, inline = "v4")
int    v4_a    = input.int(15, "A", minval = 1, maxval = 15, group = viewsgrp, inline = "v4")
int    v4_b    = input.int(14, "B", minval = 1, maxval = 15, group = viewsgrp, inline = "v4")
float  v4_q    = input.float(-3.0, "E[R]%", group = viewsgrp, inline = "v4")
float  v4_c    = input.float(25.0, "Conf%", minval = 1, maxval = 99, group = viewsgrp, inline = "v4")

string v5_type = input.string("Off", "V5", options = ["Off", "Absolute", "Relative"], group = viewsgrp, inline = "v5")
int    v5_a    = input.int(12, "A", minval = 1, maxval = 15, group = viewsgrp, inline = "v5")
int    v5_b    = input.int(11, "B", minval = 1, maxval = 15, group = viewsgrp, inline = "v5")
float  v5_q    = input.float(6.0, "E[R]%", group = viewsgrp, inline = "v5")
float  v5_c    = input.float(20.0, "Conf%", minval = 1, maxval = 99, group = viewsgrp, inline = "v5")

// Backtesting
int startDate      = input.time(timestamp("1 Jan 2020"), "Start Date", group = backtesting, tooltip = "Portfolio backtest start date.\nThe engine still needs 'Covariance Lookback' bars of history BEFORE this date to warm up, so the first weights are set slightly after this point.")
bool show_metrics  = input.bool(true, "Metrics Table", group = backtesting, inline = "display1", tooltip = "Full performance statistics, drawn top right.")
bool show_alloc    = input.bool(true, "Allocation Table", group = backtesting, inline = "display1", tooltip = "Per-asset breakdown drawn bottom right: prior weight, posterior weight, the change between them, the equilibrium return and the posterior return.\nAssets still waiting on price history are marked 'NO DATA'.")
bool show_views_tb = input.bool(true, "Views Table", group = backtesting, inline = "display1", tooltip = "Drawn bottom left. Shows each active view, its confidence, its implied Omega, and how far it disagrees with equilibrium.")
bool show_book     = input.bool(true, "Current Book", group = backtesting, inline = "display2", tooltip = "Compact summary drawn bottom center: gross and net exposure, how many assets have usable data, turnover, and the live engine parameters.")

bool show_eq       = input.bool(true, "Portfolio Equity", group = backtesting, inline = "curves", tooltip = "Main equity curve. Set the chart to LOG scale for better visualization over long backtests.")
bool showbh        = input.bool(true, "Benchmark Buy & Hold", group = backtesting, inline = "curves", tooltip = "Buy and hold performance of the benchmark symbol below, started from the same capital on the same date.")
bool showLbl       = input.bool(true, "Curve Labels", group = backtesting, inline = "curves", tooltip = "Floating labels pinned to the right edge of each curve.")

bool show_pnl      = input.bool(false, "Daily Returns", group = backtesting, inline = "additional", tooltip = "Plots per-bar portfolio return as a percentage. This shares the pane with equity, so enable it on its own for readability.")
bool showrdd       = input.bool(false, "Rolling Drawdown", group = backtesting, inline = "additional", tooltip = "Shows portfolio drawdown from peak as a filled area, shaded darker as the drawdown deepens.")

float rfr          = input.float(4.0, "Risk-Free Rate (%)", group = backtesting, inline = "benchmark", tooltip = "Annual risk-free rate used for Sharpe, alpha, and the implied risk aversion calculation.") / 100
string bench       = input.symbol("TVC:SPX", "Benchmark", group = backtesting, inline = "benchmark", tooltip = "Index used for alpha and beta calculations and for the buy & hold comparison curve.")

bool use_regime    = input.bool(true, "Use Regime Filter", group = backtesting, inline = "regime", tooltip = "When the fast regime EMA falls below the slow one, the book flattens to CASH and stops compounding. The allocator immediately re-solves the moment the regime flips back to ACTIVE, so capital is never left idle waiting for the next scheduled rebalance.\nNote this filter reads the CHART symbol, not the universe.")
int fast_reg_len   = input.int(50, "Fast EMA (Regime)", group = backtesting, inline = "regime", tooltip = "Medium-term EMA of the chart symbol. Above the slow EMA = ACTIVE regime.")
int slow_reg_len   = input.int(200, "Slow EMA (Regime)", group = backtesting, inline = "regime", tooltip = "Long-term EMA of the chart symbol. Below this from the fast EMA = CASH regime.")

// Asset Selection
string asset_note = input.string("", "Universe notes", group = assetsel, tooltip = "Default universe is a cross-asset macro book: crypto majors, equity indices, commodities, the dollar and long bonds. Black-Litterman was built for exactly this kind of global allocation problem.\n\nUSE PROPER PRICE SYMBOLS. Do not use CRYPTOCAP: symbols here, those are market capitalization in dollars, not tradable prices, and their returns will corrupt the covariance matrix.\n\nRUN THIS ON A WEEKDAY-SESSION CHART such as SPX or QQQ. On a 24/7 crypto chart, request.security forward-fills the index and ETF symbols across weekends, which books them zero returns on Saturday and Sunday. That understates their volatility by roughly 15% and dilutes their correlation with the crypto names, and an inverse-volatility prior will then overweight them.\n\nAssets with less history than the Covariance Lookback are detected and excluded automatically until they have enough data, so newer listings will not distort the prior.")

string t1  = input.symbol("INDEX:BTCUSD", "Asset 1", group = assetsel, inline = "row1", tooltip = "Cross-exchange BTC index (Bitstamp, Coinbase, Bitfinex, Kraken). History back to 2010, which makes it far better for long backtests than any single venue.")
string t2  = input.symbol("INDEX:ETHUSD", "Asset 2", group = assetsel, inline = "row1")
string t3  = input.symbol("CRYPTO:SOLUSD", "Asset 3", group = assetsel, inline = "row1")
string t4  = input.symbol("BINANCE:ADAUSDT", "Asset 4", group = assetsel, inline = "row1", tooltip = "Cardano against Tether on Binance. If you swap in a recently listed token here, the allocator will show it as NO DATA and exclude it from the prior until it has a full Covariance Lookback window of real history.")
string t5  = input.symbol("TVC:SPX", "Asset 5", group = assetsel, inline = "row1")
string t6  = input.symbol("NASDAQ:QQQ", "Asset 6", group = assetsel, inline = "row2")
string t7  = input.symbol("TVC:DJI", "Asset 7", group = assetsel, inline = "row2")
string t8  = input.symbol("TVC:RUT", "Asset 8", group = assetsel, inline = "row2")
string t9  = input.symbol("TVC:DAX", "Asset 9", group = assetsel, inline = "row2")
string t10 = input.symbol("TVC:NI225", "Asset 10", group = assetsel, inline = "row2")
string t11 = input.symbol("TVC:GOLD", "Asset 11", group = assetsel, inline = "row3")
string t12 = input.symbol("TVC:SILVER", "Asset 12", group = assetsel, inline = "row3")
string t13 = input.symbol("TVC:USOIL", "Asset 13", group = assetsel, inline = "row3")
string t14 = input.symbol("TVC:DXY", "Asset 14", group = assetsel, inline = "row3")
string t15 = input.symbol("NASDAQ:TLT", "Asset 15", group = assetsel, inline = "row3", tooltip = "iShares 20+ Year Treasury Bond ETF. Listed on Nasdaq, so the prefix is NASDAQ and not AMEX.")

// Plotting and Visualizations
color longcol   = input.color(#00ff00, "Bullish Color", group = pv, inline = "colors", tooltip = "Color of the equity line when equity is rising.")
color shortcol  = input.color(#ff0000, "Bearish Color", group = pv, inline = "colors", tooltip = "Color of the equity line when equity is falling. Also used for negative weights and negative changes in the tables.")
color dd_col    = input.color(#ff0000, "Drawdown Color", group = pv, inline = "colors", tooltip = "Fill color of the rolling drawdown area.")
color prior_col = input.color(#3742fa, "Prior Weight Color", group = pv, inline = "blcolors", tooltip = "Color of the equilibrium (prior) weight bars and the prior column in the allocation table.")
color post_col  = input.color(#2ed573, "Posterior Weight Color", group = pv, inline = "blcolors", tooltip = "Color of the post-views (posterior) weight bars and positive changes in the tables.")

float allow_dd  = input.float(-50, "Max DD for Scaling (%)", group = pv, inline = "scaling", tooltip = "Drawdown level at which the rolling drawdown fill reaches full intensity. -50% means the shading is fully saturated once the portfolio is 50% below its peak.")

// Prior vs Posterior Chart
bool show_bl_chart  = input.bool(true, "Show Prior vs Posterior Chart", group = blchart, inline = "bl_main", tooltip = "The signature visual. Paired horizontal bars, one row per asset: the top bar is the equilibrium prior, the bottom bar is the posterior after your views are blended in. The gap between them IS the view impact.")
bool show_bl_labels = input.bool(true, "Asset & Weight Labels", group = blchart, inline = "bl_main", tooltip = "Adds the asset name on the left and the posterior weight plus its change versus prior on the right of each bar pair.")
int chart_offset    = input.int(60, "Chart Right Offset (bars)", minval = 10, maxval = 200, group = blchart, inline = "bl_pos", tooltip = "How far left of the most recent bar the chart is drawn. Increase it if the chart collides with the equity curve labels.")
int chart_width_in  = input.int(320, "Chart Width (bars)", minval = 100, maxval = 480, group = blchart, inline = "bl_pos", tooltip = "Horizontal size of the chart measured in bars.")
float chart_hgt_pct = input.float(0.45, "Chart Height (% of equity)", minval = 0.1, maxval = 2.0, step = 0.05, group = blchart, inline = "bl_pos", tooltip = "The chart is anchored to the current equity value so it stays visible on the pane regardless of how large equity has grown.\nIncrease if the 15 rows look cramped, decrease if the chart overflows the pane.")

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Define Helper Functions
const int N = 15

logrets   = array.new_float()
simrets   = array.new_float()
moms      = array.new_float()
vols      = array.new_float()
avail     = array.new_float()
ticks_arr = array.new_string()

clean(t) =>
    parts = str.split(t, ":")
    parts.size() > 1 ? parts.get(1) : t

// `avail` flags whether the symbol actually returned data on this bar. Without this, a symbol that
// has not listed yet returns na, nz() turns it into a zero return, and the asset ends up with
// near-zero variance. An inverse-vol prior would then hand the largest weight in the book to an
// asset that does not exist yet.
get_metrics(sym, tradingdays) =>
    price = request.security(sym, timeframe.period, close)
    lr = math.log(price / price[1])
    sr = price / price[1] - 1
    cr = price / price[covLookback] - 1
    vo = ta.stdev(lr, covLookback) * math.sqrt(tradingdays)
    logrets.push(nz(lr))
    simrets.push(nz(sr))
    moms.push(nz(cr))
    vols.push(na(vo) or vo <= 0 ? 0.0001 : vo)
    avail.push(na(price) or na(price[1]) or price <= 0 ? 0.0 : 1.0)

get_metrics(t1,  tradingdays), ticks_arr.push(clean(t1))
get_metrics(t2,  tradingdays), ticks_arr.push(clean(t2))
get_metrics(t3,  tradingdays), ticks_arr.push(clean(t3))
get_metrics(t4,  tradingdays), ticks_arr.push(clean(t4))
get_metrics(t5,  tradingdays), ticks_arr.push(clean(t5))
get_metrics(t6,  tradingdays), ticks_arr.push(clean(t6))
get_metrics(t7,  tradingdays), ticks_arr.push(clean(t7))
get_metrics(t8,  tradingdays), ticks_arr.push(clean(t8))
get_metrics(t9,  tradingdays), ticks_arr.push(clean(t9))
get_metrics(t10, tradingdays), ticks_arr.push(clean(t10))
get_metrics(t11, tradingdays), ticks_arr.push(clean(t11))
get_metrics(t12, tradingdays), ticks_arr.push(clean(t12))
get_metrics(t13, tradingdays), ticks_arr.push(clean(t13))
get_metrics(t14, tradingdays), ticks_arr.push(clean(t14))
get_metrics(t15, tradingdays), ticks_arr.push(clean(t15))

// Count how many bars of genuine data each asset has delivered. An asset is only tradable once it
// has at least a full covariance window, otherwise its column of the matrix is mostly padding.
// The increment is gated on barstate.isconfirmed: array mutations are NOT rolled back on realtime
// ticks, so an unguarded counter would gain hundreds of phantom bars per real bar.
var array<float> validCount = array.new<float>(N, 0.0)
activeMask = array.new<float>(N, 0.0)

for i = 0 to N - 1
    if avail.get(i) > 0.5 and barstate.isconfirmed
        validCount.set(i, validCount.get(i) + 1)
    activeMask.set(i, validCount.get(i) >= covLookback ? 1.0 : 0.0)

int liveAssets = math.round(activeMask.sum())

// Rolling return history as a ring buffer, one column per asset. Written only on confirmed bars so
// the covariance window holds closing returns, never partial intrabar values.
var matrix<float> retHist = matrix.new<float>(covLookback, N, 0.0)
var int histCount = 0

if bar_index > 0 and barstate.isconfirmed
    int rowIdx = histCount % covLookback
    for i = 0 to N - 1
        matrix.set(retHist, rowIdx, i, logrets.get(i))
    histCount += 1

bool histReady = histCount >= covLookback and liveAssets >= 2

// Annualized covariance matrix with shrinkage toward the diagonal target
// Sigma = (D' * D) / (T-1) * tradingdays, then off-diagonals scaled by (1 - shrinkage)
build_cov(matrix<float> hist, int n, int T, float shrink, int td) =>
    array<float> means = array.new<float>()
    for j = 0 to n - 1
        means.push(matrix.col(hist, j).avg())

    matrix<float> D = matrix.new<float>(T, n, 0.0)
    for t = 0 to T - 1
        for j = 0 to n - 1
            matrix.set(D, t, j, matrix.get(hist, t, j) - means.get(j))

    matrix<float> S = matrix.mult(matrix.transpose(D), D)
    S := matrix.mult(S, td / (T - 1.0))

    for a = 0 to n - 1
        for b = 0 to n - 1
            float v = matrix.get(S, a, b)
            if a != b
                matrix.set(S, a, b, v * (1.0 - shrink))
            else
                matrix.set(S, a, b, v + 0.000001)
    S

// Docs-prescribed inversion guard: use inv() only for square, non-singular matrices, else pinv()
safe_inv(matrix<float> m) =>
    float dtm = matrix.det(m)
    matrix<float> result = (matrix.is_square(m) and not na(dtm) and math.abs(dtm) > 1e-30) ? matrix.inv(m) : matrix.pinv(m)
    result

// Prior (equilibrium) weights, distributed only across assets that actually have data
manual_raw = array.from(mw1, mw2, mw3, mw4, mw5, mw6, mw7, mw8, mw9, mw10, mw11, mw12, mw13, mw14, mw15)

build_prior(string scheme, array<float> volArr, array<float> manArr, array<float> mask, int n) =>
    array<float> w = array.new<float>(n, 0.0)
    float liveN = mask.sum()
    if liveN >= 1
        if scheme == "Equal Weight"
            for i = 0 to n - 1
                w.set(i, mask.get(i) > 0.5 ? 1.0 / liveN : 0.0)
        else if scheme == "Inverse Volatility"
            float invSum = 0.0
            for i = 0 to n - 1
                if mask.get(i) > 0.5
                    invSum += 1.0 / volArr.get(i)
            for i = 0 to n - 1
                w.set(i, mask.get(i) > 0.5 and invSum > 0 ? (1.0 / volArr.get(i)) / invSum : 0.0)
        else
            float manSum = 0.0
            for i = 0 to n - 1
                if mask.get(i) > 0.5
                    manSum += manArr.get(i)
            for i = 0 to n - 1
                w.set(i, mask.get(i) > 0.5 ? (manSum > 0 ? manArr.get(i) / manSum : 1.0 / liveN) : 0.0)
    w

// View definitions collected into arrays for iteration
vTypes = array.from(v1_type, v2_type, v3_type, v4_type, v5_type)
vAs    = array.from(v1_a, v2_a, v3_a, v4_a, v5_a)
vBs    = array.from(v1_b, v2_b, v3_b, v4_b, v5_b)
vQs    = array.from(v1_q / 100, v2_q / 100, v3_q / 100, v4_q / 100, v5_q / 100)
vCs    = array.from(v1_c / 100, v2_c / 100, v3_c / 100, v4_c / 100, v5_c / 100)

// A view is only usable if every asset it references has real data behind it
viewLive = array.new<bool>(5, false)
int activeViews = 0
for i = 0 to 4
    string vt = vTypes.get(i)
    if vt != "Off"
        bool okA = activeMask.get(vAs.get(i) - 1) > 0.5
        bool okB = vt == "Absolute" ? true : activeMask.get(vBs.get(i) - 1) > 0.5
        if okA and okB
            viewLive.set(i, true)
            activeViews += 1

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Regime Filter
var bool regime_filter = true

fast_regime = ta.ema(close, fast_reg_len)
slow_regime = ta.ema(close, slow_reg_len)

if not use_regime
    regime_filter := true
else if fast_regime > slow_regime
    regime_filter := true
else
    regime_filter := false

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Black-Litterman Solve
// Persistent state carried between rebalances
var array<float> w_active   = array.new<float>(N, 0.0)   // live traded weights
var array<float> w_priorD   = array.new<float>(N, 0.0)   // prior weights, for display
var array<float> piD        = array.new<float>(N, 0.0)   // equilibrium excess returns, for display
var array<float> piPostD    = array.new<float>(N, 0.0)   // posterior excess returns, for display
var array<float> maskD      = array.new<float>(N, 0.0)   // data availability, for display
var array<float> omegaD     = array.new<float>(5, 0.0)   // per-view Omega, for display
var array<float> viewGapD   = array.new<float>(5, 0.0)   // Q - P*Pi per view, for display
var float deltaD            = 0.0
var float portVolD          = 0.0
var float volScaleD         = 1.0
var float turnoverD         = 0.0
var int   rebalCount        = 0

// Portfolio return uses the weights as they stood at the end of the previous bar.
// Computed BEFORE the rebalance block so there is no lookahead.
float port_ret = 0.0
for i = 0 to N - 1
    port_ret += w_active.get(i) * simrets.get(i)

// Equity curve construction
var float equity = na

if time >= startDate
    if na(equity)
        equity := initial_cap
    else
        if regime_filter[1]
            float netRet = port_ret
            equity := equity * (1 + netRet)
        else
            equity := equity

// Rebalance: run the full solve only every N bars to stay inside the execution budget.
// Also force a solve the moment the regime flips back to ACTIVE, otherwise the book would sit
// flat for up to `rebal_bars` bars after re-entry, and whenever a new asset comes online.
//
// barstate.isconfirmed is essential here, not cosmetic. Without it the solve reruns on every
// realtime tick: tick 1 charges the turnover fee and overwrites w_active, then tick 2 measures
// turnover against the already-updated weights, gets ~0, and charges nothing. Since `equity` is a
// scalar that DOES roll back, the committed bar would end up fee-free while every historical bar
// paid in full. Gating on confirmation makes live execution match the backtest exactly.
bool regimeFlip = regime_filter and not regime_filter[1]
bool universeChanged = liveAssets != nz(liveAssets[1], liveAssets)
bool doRebal = histReady and barstate.isconfirmed and time >= startDate and not na(equity) and ((bar_index % rebal_bars == 0) or regimeFlip or universeChanged)

if doRebal
    // 1) Covariance
    matrix<float> Sigma = build_cov(retHist, N, covLookback, shrinkage, tradingdays)

    // 2) Prior weights, live assets only
    array<float> wPrior = build_prior(prior_scheme, vols, manual_raw, activeMask, N)

    // 3) Risk aversion delta, reverse-engineered from the prior portfolio
    array<float> SwPrior = matrix.mult(Sigma, wPrior)
    float priorVar = 0.0
    float priorMu  = 0.0
    for i = 0 to N - 1
        priorVar += wPrior.get(i) * SwPrior.get(i)
        priorMu  += wPrior.get(i) * moms.get(i) * (tradingdays / (covLookback * 1.0))

    float delta = delta_manual
    if delta_mode == "Auto (Implied)"
        float dRaw = priorVar > 0 ? (priorMu - rfr) / priorVar : delta_manual
        delta := math.min(math.max(dRaw, 0.5), 15.0)

    // 4) Implied equilibrium excess returns:  Pi = delta * Sigma * w_mkt
    array<float> Pi = array.new<float>(N, 0.0)
    for i = 0 to N - 1
        Pi.set(i, delta * SwPrior.get(i))

    // 5) tau * Sigma
    matrix<float> tauS = matrix.mult(Sigma, tau)

    // 6) Build P, Q and Omega from the usable views
    array<float> PiPost   = Pi
    matrix<float> SigPost = Sigma

    if activeViews > 0
        matrix<float> P = matrix.new<float>(activeViews, N, 0.0)
        array<float>  Q = array.new<float>(activeViews, 0.0)
        array<float>  C = array.new<float>(activeViews, 0.5)

        int k = 0
        for i = 0 to 4
            if viewLive.get(i)
                int ia = vAs.get(i) - 1
                int ib = vBs.get(i) - 1
                if vTypes.get(i) == "Absolute"
                    matrix.set(P, k, ia, 1.0)
                else
                    matrix.set(P, k, ia, 1.0)
                    matrix.set(P, k, ib, matrix.get(P, k, ib) - 1.0)
                Q.set(k, vQs.get(i))
                C.set(k, math.min(math.max(vCs.get(i), 0.01), 0.99))
                k += 1

        // P * tau*Sigma  ->  k x N
        matrix<float> PtauS = matrix.mult(P, tauS)
        // (P * tau*Sigma * P') + Omega  ->  k x k
        matrix<float> A = matrix.mult(PtauS, matrix.transpose(P))

        for j = 0 to activeViews - 1
            float pvar  = matrix.get(A, j, j)
            float cj    = C.get(j)
            float omega = ((1.0 - cj) / cj) * math.max(pvar, 0.000001)
            matrix.set(A, j, j, pvar + omega)
            omegaD.set(j, omega)

        // Residual: Q - P*Pi, how far each view disagrees with equilibrium
        array<float> PPi   = matrix.mult(P, Pi)
        array<float> resid = array.new<float>(activeViews, 0.0)
        for j = 0 to activeViews - 1
            resid.set(j, Q.get(j) - PPi.get(j))
            viewGapD.set(j, resid.get(j))

        // Posterior returns:  Pi_post = Pi + tau*Sigma*P' * A^-1 * (Q - P*Pi)
        // Only a k x k inversion is required here, which is far more stable than inverting N x N
        matrix<float> Ainv    = safe_inv(A)
        array<float>  Aresid  = matrix.mult(Ainv, resid)
        array<float>  adj     = matrix.mult(matrix.transpose(PtauS), Aresid)

        array<float> tmpPost = array.new<float>(N, 0.0)
        for i = 0 to N - 1
            tmpPost.set(i, Pi.get(i) + nz(adj.get(i)))
        PiPost := tmpPost

        // Posterior covariance:  Sigma + tau*Sigma - tau*Sigma*P' * A^-1 * P*tau*Sigma
        if use_post_cov
            matrix<float> tmp = matrix.mult(matrix.mult(matrix.transpose(PtauS), Ainv), PtauS)
            matrix<float> M   = matrix.diff(tauS, tmp)
            SigPost := matrix.sum(Sigma, M)

    // 7) Optimal weights:  w* = (delta * Sigma_post)^-1 * Pi_post
    matrix<float> dSig  = matrix.mult(SigPost, delta)
    matrix<float> dInv  = safe_inv(dSig)
    array<float>  wRaw  = matrix.mult(dInv, PiPost)

    // 8) Constraints: data mask, shorts, gross normalization
    array<float> wCon = array.new<float>(N, 0.0)
    bool valid = true
    for i = 0 to N - 1
        float wi = wRaw.get(i)
        if na(wi)
            valid := false
        // Assets without a full window of real history never receive weight, regardless of
        // whatever the optimizer produced for their near-empty covariance column.
        wCon.set(i, (na(wi) or activeMask.get(i) < 0.5) ? 0.0 : wi)

    if valid
        if not allow_shorts
            for i = 0 to N - 1
                wCon.set(i, math.max(0.0, wCon.get(i)))

        float grossRaw = 0.0
        for i = 0 to N - 1
            grossRaw += math.abs(wCon.get(i))

        if grossRaw > 0
            for i = 0 to N - 1
                wCon.set(i, wCon.get(i) / grossRaw * gross_target)

            // 9) Volatility targeting on the true portfolio vol, sqrt(w' * Sigma * w)
            array<float> Sw = matrix.mult(SigPost, wCon)
            float pVar = 0.0
            for i = 0 to N - 1
                pVar += wCon.get(i) * Sw.get(i)
            float pVol = pVar > 0 ? math.sqrt(pVar) : 0.0
            float vScale = pVol > 0 ? math.min(math.max(targetVol / pVol, 0.1), max_leverage) : 1.0

            for i = 0 to N - 1
                wCon.set(i, wCon.get(i) * vScale)

            // 9b) Hard caps enforced AFTER vol targeting, so the numbers you type are the numbers
            // you get. Previously the caps were applied pre-leverage and the vol scaler multiplied
            // straight through them, producing 60% positions against a 30% cap.
            for i = 0 to N - 1
                float wi = wCon.get(i)
                wCon.set(i, math.sign(wi) * math.min(math.abs(wi), max_weight))

            float grossFinal = 0.0
            for i = 0 to N - 1
                grossFinal += math.abs(wCon.get(i))

            // Scaling every weight down by a common factor can only shrink magnitudes, so the
            // per-asset cap above cannot be re-violated by this step.
            if grossFinal > max_gross and grossFinal > 0
                for i = 0 to N - 1
                    wCon.set(i, wCon.get(i) / grossFinal * max_gross)

            portVolD  := pVol
            volScaleD := grossFinal > 0 ? vScale * math.min(1.0, max_gross / grossFinal) : vScale

            // 10) Turnover cost and commit the new book
            float turnover = 0.0
            for i = 0 to N - 1
                turnover += math.abs(wCon.get(i) - w_active.get(i))
            turnoverD := turnover

            if regime_filter and not na(equity)
                equity := equity * (1 - fee_rate * turnover)

            for i = 0 to N - 1
                w_active.set(i, wCon.get(i))
                w_priorD.set(i, wPrior.get(i))
                piD.set(i, Pi.get(i))
                piPostD.set(i, PiPost.get(i))
                maskD.set(i, activeMask.get(i))

            deltaD := delta
            rebalCount += 1

// Flatten the book when the regime filter is off
if use_regime and not regime_filter and barstate.isconfirmed
    for i = 0 to N - 1
        w_active.set(i, 0.0)

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Metrics
var float peakEq    = na
var float mdd       = 0.0
var float dd        = 0.0
var r               = array.new<float>()
var rb              = array.new<float>()
var pos_ret         = array.new<float>()
var neg_ret         = array.new<float>()
var sorted_ret      = array.new<float>()
var dds             = array.new<float>()
var cVaR            = 0.0

[benchmark, bhseries] = request.security(bench, "", [close / close[1] - 1, close])

if barstate.isconfirmed and time >= startDate and not na(equity) and not na(equity[1])
    peakEq := na(peakEq) ? equity : math.max(peakEq, equity)
    dd := (equity - peakEq) / peakEq * 100

    array.push(dds, dd)
    mdd := array.min(dds)

    float daily_r = equity / equity[1] - 1

    // Never push na into the stats arrays. On the first bar of the backtest equity[1] is na, so
    // daily_r is na. A single na propagates through skewness (na cubed poisons the running sum)
    // and makes percentile_linear_interpolation return na for the entire run. That is exactly
    // what turned Skewness and VaR 95th into NaN while Conditional VaR survived, since the
    // manual CVaR sum only touches the lowest 5% and na sorts to the END in ascending order.
    if not na(daily_r)
        r.push(daily_r)
        sorted_ret.push(daily_r)
        rb.push(nz(benchmark))

        // A flat CASH bar is neither a win nor a loss. Bucketing zero returns into neg_ret was
        // scoring every bar spent out of the market as a losing day, which is what dragged
        // Win Rate, Omega and Gain-to-Pain down.
        if daily_r > 0
            pos_ret.push(daily_r)
        else if daily_r < 0
            neg_ret.push(daily_r)

skewness(ret) =>
    n = ret.size()
    if n < 3
        na
    else
        mean_val = ret.sum() / n
        std_val = ret.stdev()
        sum_cubed = 0.0
        for i = 0 to n - 1
            dev = ret.get(i) - mean_val
            sum_cubed += math.pow(dev / std_val, 3)
        skew = (n / ((n - 1.0) * (n - 2.0))) * sum_cubed
        skew

bh_eq(float p, int start, int capital) =>
    var float eq = na
    if year(time) == year(start) and month(time) == month(start) and dayofmonth(time) == dayofmonth(start)
        eq := capital
    else if na(eq[1])
        eq := capital
    else if time >= start
        eq := eq[1] * p / p[1]
    eq

// Sorting a growing array on every bar is wasted work, and these three values only ever appear
// in the table, so they are computed once on the final bar instead.
float skew  = na
float var95 = na
if barstate.islast and r.size() > 2
    sorted_ret.sort(order.ascending)
    int nloss = math.floor(sorted_ret.size() * 0.05)
    float sumloss = 0.0
    for x = 0 to (nloss < 1 ? na : nloss - 1)
        sumloss += sorted_ret.get(x)
    cVaR  := nloss > 0 ? sumloss / nloss : na
    var95 := sorted_ret.percentile_linear_interpolation(5)
    skew  := skewness(r)

int decided = pos_ret.size() + neg_ret.size()

net_profit     =     (equity - initial_cap) / initial_cap * 100
mean           =     r.sum() / r.size()
bm_mean        =     rb.sum() / rb.size()
bm_ann_mean    =     bm_mean * tradingdays
std            =     r.stdev()
ann_mean       =     mean * tradingdays
ann_std        =     std * math.sqrt(tradingdays)
variance       =     math.pow(ann_std, 2)
ann_mean_pct   =     ann_mean * 100
ann_std_pct    =     ann_std * 100
sharpe         =     (mean - rfr / tradingdays) / std * math.sqrt(tradingdays)
sortino        =     mean / neg_ret.stdev() * math.sqrt(tradingdays)
omega          =     pos_ret.sum() / neg_ret.sum() * -1
gaintopain     =     r.sum() / (-neg_ret.sum())          //https://www.linkedin.com/pulse/what-best-way-measure-risk-part-2-jack-schwager/
cagr           =     (math.pow(equity / initial_cap, 1 / ((time - startDate) / 31536000000)) - 1) * 100
beta           =     r.covariance(rb) / rb.variance()
alpha          =     ((ann_mean - rfr) - beta * (bm_ann_mean - rfr)) * 100
pf             =     pos_ret.sum() / neg_ret.sum()
calmar         =     cagr / math.abs(mdd)
winrate        =     decided > 0 ? pos_ret.size() / (decided * 1.0) * 100 : na
bh_benchmark   =     bh_eq(bhseries, startDate, initial_cap)

labels = array.from(
 "Net Profit (%)","Max DD (%)","Win Rate","Annual Mean Returns (% p/y)","Annual Stdev Returns (% p/y)","Variance","Sortino Ratio","Sharpe Ratio",
 "Omega Ratio","Gain-to-Pain","CAGR (% p/y)","Calmar Ratio","Portfolio Alpha (% p/y)","Portfolio Beta","Skewness of Returns","VaR 95th Percentile","Conditional VaR")
values = array.from(net_profit, mdd, winrate, ann_mean_pct, ann_std_pct, variance, sortino, sharpe, omega, gaintopain, cagr, calmar, alpha, beta, skew, var95, cVaR)

if show_metrics
    var table metricTable = table.new(position.top_right, 10, array.size(labels) + 1, frame_color=color.white, frame_width=1, border_color=color.white, border_width=1)
    metricTable.cell(0, 0, "Portfolio Metrics", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    metricTable.merge_cells(0, 0, 1, 0)
    for i = 0 to array.size(labels) - 1
        s = i + 1
        lbl = labels.get(i)
        val = values.get(i)
        strVal = na(val) ? "NaN" : str.tostring(val, "#.###")
        metricTable.cell(0, s, lbl,    text_color=color.white, text_size=size.normal)
        metricTable.cell(1, s, strVal, text_color=color.white, text_size=size.normal)

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Allocation Table
if show_alloc and barstate.islast
    var table allocTable = table.new(position.bottom_right, 6, N + 2, frame_color=color.white, frame_width=1, border_color=color.white, border_width=1)
    allocTable.cell(0, 0, "Black-Litterman Allocation", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    allocTable.merge_cells(0, 0, 5, 0)

    allocTable.cell(0, 1, "Asset",      text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    allocTable.cell(1, 1, "Prior W",    text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    allocTable.cell(2, 1, "Post W",     text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    allocTable.cell(3, 1, "Delta W",    text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    allocTable.cell(4, 1, "Equil E[R]", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    allocTable.cell(5, 1, "Post E[R]",  text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)

    for i = 0 to N - 1
        int rowN = i + 2
        bool live = activeMask.get(i) > 0.5

        allocTable.cell(0, rowN, ticks_arr.get(i), text_color = live ? color.white : color.new(color.silver, 40), text_size=size.normal)

        if live
            float wp  = w_priorD.get(i) * 100
            float wq  = w_active.get(i) * 100
            float dwq = wq - wp
            float pi0 = piD.get(i) * 100
            float pi1 = piPostD.get(i) * 100

            color dwCol = dwq > 0.01 ? post_col : dwq < -0.01 ? shortcol : color.silver
            color erCol = (pi1 - pi0) > 0.01 ? post_col : (pi1 - pi0) < -0.01 ? shortcol : color.silver

            allocTable.cell(1, rowN, str.tostring(wp, "#.##") + "%",  text_color=color.new(prior_col, 0), text_size=size.normal)
            allocTable.cell(2, rowN, str.tostring(wq, "#.##") + "%",  text_color=color.white, text_size=size.normal)
            allocTable.cell(3, rowN, (dwq > 0 ? "+" : "") + str.tostring(dwq, "#.##") + "%", text_color=dwCol, text_size=size.normal)
            allocTable.cell(4, rowN, str.tostring(pi0, "#.#") + "%",  text_color=color.silver, text_size=size.normal)
            allocTable.cell(5, rowN, str.tostring(pi1, "#.#") + "%",  text_color=erCol, text_size=size.normal)
        else
            allocTable.cell(1, rowN, "NO DATA", text_color=color.new(color.silver, 40), text_size=size.normal)
            allocTable.cell(2, rowN, "-", text_color=color.new(color.silver, 40), text_size=size.normal)
            allocTable.cell(3, rowN, "-", text_color=color.new(color.silver, 40), text_size=size.normal)
            allocTable.cell(4, rowN, "-", text_color=color.new(color.silver, 40), text_size=size.normal)
            allocTable.cell(5, rowN, "-", text_color=color.new(color.silver, 40), text_size=size.normal)

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Views Table
if show_views_tb and barstate.islast
    var table viewTable = table.new(position.bottom_left, 5, 8, frame_color=color.white, frame_width=1, border_color=color.white, border_width=1)
    viewTable.cell(0, 0, "Investor Views", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    viewTable.merge_cells(0, 0, 4, 0)

    viewTable.cell(0, 1, "View",    text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    viewTable.cell(1, 1, "Q",       text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    viewTable.cell(2, 1, "Conf",    text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    viewTable.cell(3, 1, "Omega",   text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)
    viewTable.cell(4, 1, "Q - PPi", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.normal)

    int vr = 2
    for i = 0 to 4
        if viewLive.get(i)
            int ia = vAs.get(i) - 1
            int ib = vBs.get(i) - 1
            string desc = vTypes.get(i) == "Absolute" ? ticks_arr.get(ia) : ticks_arr.get(ia) + " > " + ticks_arr.get(ib)
            float gap = viewGapD.get(vr - 2) * 100

            viewTable.cell(0, vr, desc, text_color=color.white, text_size=size.normal)
            viewTable.cell(1, vr, str.tostring(vQs.get(i) * 100, "#.#") + "%", text_color=color.white, text_size=size.normal)
            viewTable.cell(2, vr, str.tostring(vCs.get(i) * 100, "#") + "%",   text_color=color.silver, text_size=size.normal)
            viewTable.cell(3, vr, str.tostring(omegaD.get(vr - 2), "#.####"),  text_color=color.silver, text_size=size.normal)
            viewTable.cell(4, vr, (gap > 0 ? "+" : "") + str.tostring(gap, "#.#") + "%", text_color=gap > 0 ? post_col : shortcol, text_size=size.normal)
            vr += 1

    if activeViews == 0
        viewTable.cell(0, 2, "No active views - posterior equals equilibrium prior", text_color=color.silver, text_size=size.normal)
        viewTable.merge_cells(0, 2, 4, 2)

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Current Book
if show_book and barstate.islast
    float grossNow = 0.0
    float netNow   = 0.0
    int   heldNow  = 0
    for i = 0 to N - 1
        float wi = w_active.get(i)
        grossNow += math.abs(wi)
        netNow   += wi
        if math.abs(wi) > 0.001
            heldNow += 1

    var table bookTable = table.new(position.bottom_center, 4, 3, frame_color=color.white, frame_width=1, border_color=color.white, border_width=1)
    bookTable.cell(0, 0, "Engine: " + (regime_filter ? "ACTIVE" : "CASH"), text_color = regime_filter ? post_col : color.silver, text_size=size.normal)
    bookTable.cell(1, 0, "Prior: " + prior_scheme, text_color=color.white, text_size=size.normal)
    bookTable.cell(2, 0, "Views: " + str.tostring(activeViews), text_color=color.white, text_size=size.normal)
    bookTable.cell(3, 0, "Rebalances: " + str.tostring(rebalCount), text_color=color.white, text_size=size.normal)

    bookTable.cell(0, 1, "Gross: " + str.tostring(grossNow * 100, "#.#") + "%", text_color=color.white, text_size=size.normal)
    bookTable.cell(1, 1, "Net: " + str.tostring(netNow * 100, "#.#") + "%", text_color=color.white, text_size=size.normal)
    bookTable.cell(2, 1, "Assets Live: " + str.tostring(liveAssets) + "/" + str.tostring(N), text_color = liveAssets < N ? #ffa500 : color.white, text_size=size.normal)
    bookTable.cell(3, 1, "Turnover: " + str.tostring(turnoverD * 100, "#.#") + "%", text_color=color.white, text_size=size.normal)

    bookTable.cell(0, 2, "Delta: " + str.tostring(deltaD, "#.##"), text_color=color.silver, text_size=size.normal)
    bookTable.cell(1, 2, "Tau: " + str.tostring(tau, "#.###"), text_color=color.silver, text_size=size.normal)
    bookTable.cell(2, 2, "Port Vol: " + str.tostring(portVolD * 100, "#.#") + "%", text_color=color.silver, text_size=size.normal)
    bookTable.cell(3, 2, "Vol Scale: " + str.tostring(volScaleD, "#.##") + "x", text_color=color.silver, text_size=size.normal)

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Plotting
equity_col = color.new(color.white, 0)

if equity > equity[1]
    equity_col := longcol
else if equity < equity[1]
    equity_col := shortcol

var float peak_plot = na
float drawdown_plot = na
float daily_return_pct = na

peak_plot := na(peak_plot) ? equity : math.max(peak_plot, equity)
drawdown_plot := (equity - peak_plot) / peak_plot * 100
daily_return_pct := not na(equity[1]) ? (equity / equity[1] - 1) * 100 : na

step = allow_dd / 20

dd_transps = 80
for i = 0 to 19
    upper = step * i
    lower = step * (i + 1)
    if drawdown_plot <= upper and drawdown_plot > lower
        dd_transps := 80 - i * 4

plot_main = plot(show_eq and not na(equity) ? equity : na, "Portfolio Equity", color=equity_col, linewidth=2)
plot_zero = plot(show_eq == false ? 0 : na, title="Zero Line", color=color.new(color.red, 100), display = display.none)

pnl_color = daily_return_pct > 0 ? color.new(longcol, 5) : color.new(shortcol, 5)

plot(showbh ? bh_benchmark : na, "Buy and Hold Equity", color.blue, linewidth = 2)
plot(show_pnl ? daily_return_pct : na, "Daily Portfolio Return", color = pnl_color)

plot_rdd = plot(showrdd and not na(equity) ? drawdown_plot : na, "Rolling Drawdown", color = color.new(dd_col, dd_transps), linewidth = 1)
fill(plot_rdd, plot_zero, color=color.new(dd_col, dd_transps))

// Equity Labels
var label bhlabel = na
var label finlabel = na

if (not na(finlabel))
    label.delete(finlabel)
if (not na(bhlabel))
    label.delete(bhlabel)

bhlabel := showbh and showLbl ? label.new(
     x=(bar_index + 5),
     y=bh_benchmark,
     text="Buy & Hold",
     color=color.blue,
     textcolor=color.black,
     size = size.normal,
     style=label.style_label_left
     ) : na

finlabel := show_eq and showLbl and not na(equity) ? label.new(
     x=(bar_index + 5),
     y=equity,
     text="Portfolio Equity",
     color=color.white,
     textcolor=color.black,
     size = size.normal,
     style=label.style_label_left
     ) : na

///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
// Prior vs Posterior Weight Chart
// Paired horizontal bars, one row per asset. Top bar is the equilibrium prior, bottom bar is the
// posterior after the views have been blended in. The gap between them IS the view impact.

// Every drawing is tracked so it can be deleted on the next redraw. barstate.islast is true on
// every realtime tick and on every new bar during replay, so without this the boxes and labels
// pile up on top of each other until the 500-object cap trims them.
var array<box>   blBoxes  = array.new<box>()
var array<label> blLabels = array.new<label>()
var array<line>  blLines  = array.new<line>()

prior_vs_posterior() =>
    if show_bl_chart and barstate.islast and not na(equity)

        for b in blBoxes
            box.delete(b)
        blBoxes.clear()
        for l in blLabels
            label.delete(l)
        blLabels.clear()
        for ln in blLines
            line.delete(ln)
        blLines.clear()

        // Anchor the chart to current equity so it stays visible on the pane
        float anchor       = equity
        float chart_top    = anchor * (1 + chart_hgt_pct)
        float chart_bottom = anchor * (1 - chart_hgt_pct)
        float chart_height = chart_top - chart_bottom

        // Clamp to the left so the chart never asks for a negative bar index on short histories
        chart_right = math.max(chart_width_in + 10, bar_index - chart_offset)
        chart_left  = chart_right - chart_width_in
        chart_width = chart_right - chart_left

        // Find the largest absolute weight for scaling
        float maxW = 0.0
        for i = 0 to N - 1
            maxW := math.max(maxW, math.abs(w_priorD.get(i)))
            maxW := math.max(maxW, math.abs(w_active.get(i)))
        if maxW <= 0
            maxW := 0.01

        // Zero line sits left for long-only, centered when shorts are permitted
        float zeroFrac = allow_shorts ? 0.42 : 0.16
        zero_x  = math.round(chart_left + chart_width * zeroFrac)
        barSpan = allow_shorts ? math.round(chart_width * 0.40) : math.round(chart_width * 0.72)

        // Background
        blBoxes.push(box.new(left=chart_left, top=chart_top, right=chart_right, bottom=chart_bottom,
                 bgcolor=color.new(#0a0a0a, 88), border_color=color.new(#404040, 60)))

        // Title
        mid_x = math.round((chart_left + chart_right) / 2)
        blLabels.push(label.new(x=mid_x, y=chart_top,
                 text="Prior vs Posterior Weights  -  " + str.tostring(activeViews) + " active view" + (activeViews == 1 ? "" : "s") + "  -  " + str.tostring(liveAssets) + "/" + str.tostring(N) + " assets live",
                 style=label.style_label_down, color=color.new(#ffffff, 20),
                 textcolor=color.black, size=size.normal))

        // Zero line
        blLines.push(line.new(x1=zero_x, y1=chart_bottom, x2=zero_x, y2=chart_top - chart_height * 0.05,
                 width=1, color=color.new(#ffffff, 40), style=line.style_solid))

        // Rows
        float rowH = (chart_height * 0.86) / N
        float barH = rowH * 0.34

        for i = 0 to N - 1
            float rowTop = chart_top - chart_height * 0.09 - (rowH * i)
            float wp = w_priorD.get(i)
            float wq = w_active.get(i)
            bool live = activeMask.get(i) > 0.5

            // Prior bar
            pxEnd = zero_x + math.round((wp / maxW) * barSpan)
            blBoxes.push(box.new(left=math.min(zero_x, pxEnd), top=rowTop, right=math.max(zero_x, pxEnd), bottom=rowTop - barH,
                     bgcolor=color.new(prior_col, 35), border_color=color.new(prior_col, 60)))

            // Posterior bar
            qxEnd = zero_x + math.round((wq / maxW) * barSpan)
            color qCol = wq >= 0 ? post_col : shortcol
            blBoxes.push(box.new(left=math.min(zero_x, qxEnd), top=rowTop - barH - (rowH * 0.06), right=math.max(zero_x, qxEnd), bottom=rowTop - (barH * 2) - (rowH * 0.06),
                     bgcolor=color.new(qCol, 25), border_color=color.new(qCol, 50)))

            if show_bl_labels
                blLabels.push(label.new(x=chart_left + 4, y=rowTop - barH,
                         text=ticks_arr.get(i), style=label.style_none,
                         textcolor = live ? color.new(color.white, 20) : color.new(color.silver, 55), size=size.small))

                float dw = (wq - wp) * 100
                string wtxt = live ? str.tostring(wq * 100, "#.#") + "%  (" + (dw > 0 ? "+" : "") + str.tostring(dw, "#.#") + ")" : "no data"
                txtX = math.max(pxEnd, qxEnd) + 6
                blLabels.push(label.new(x=txtX, y=rowTop - barH,
                         text=wtxt, style=label.style_none,
                         textcolor = not live ? color.new(color.silver, 55) : dw > 0.05 ? post_col : dw < -0.05 ? shortcol : color.new(color.silver, 30), size=size.small))

        // Legend
        legX = chart_right - 70
        blLabels.push(label.new(legX, chart_bottom + chart_height * 0.06, "Prior (Equilibrium)",
                 textcolor=prior_col, style=label.style_none, size=size.small))
        blLabels.push(label.new(legX, chart_bottom + chart_height * 0.02, "Posterior (Post-Views)",
                 textcolor=post_col, style=label.style_none, size=size.small))
prior_vs_posterior()
///////////////////////////////////////////////////////////////////////// © BackQuant /////////////////////////////////////////////////////////////////////////
````
