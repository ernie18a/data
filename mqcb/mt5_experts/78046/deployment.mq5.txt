//+------------------------------------------------------------------+
//|                                                   Deployment.mq5 |
//|                                                                  |
//|  Shows how to use the Newtonian Mechanics engine inside your own |
//|  Expert Advisor. Self-contained: the engine (Part 1) and the EA   |
//|  (Part 2) are both in this file. Part 2 wires the engine to       |
//|  OnInit / OnDeinit / OnTick and reads the                         |
//|  results, including DetermineEntry(), which turns the readings    |
//|  into an entry price. It places NO orders.                        |
//|                                                                  |
//|  Install: MQL5\Experts\Deployment.mq5. No include files needed.   |
//+------------------------------------------------------------------+
#property copyright   "Newtonian Mechanics"
#property version     "1.20"
#property description "Example EA: bid/ask tick kinematics, self-contained."
#property description "Reads velocity, acceleration, z-scores and market phase on every tick."
#property description "Does not trade."

//==================================================================
// PART 1 of 2 - THE ENGINE (NewtonianInit, NewtonianDeinit, NewtonianTick and everything
// they use). Part 2, the Expert Advisor itself, starts after it.
//==================================================================

//+-------------------------------------------------------------------+
//|                       Deployment.mq5                              |
//|                                                                   |
//|  Displacement, velocity and acceleration of the BID and ASK       |
//|  quote streams, measured in the broker's own clock, with honest   |
//|  error bars and an out-of-sample forecast scoreboard.             |
//|                                                                   |
//|  ------------------------------------------------------------     |
//|  THE WEIGHTING                                                    |
//|  ------------------------------------------------------------     |
//|  Weights decay per EVENT, not per millisecond. The nth most       |
//|  recent update of a side carries weight rho^n, whose effective    |
//|  sample size is                                                   |
//|                                                                   |
//|        neff = (1 + rho) / (1 - rho)                               |
//|                                                                   |
//|  exactly, and independently of arrival rate. Each rung therefore  |
//|  holds the same amount of evidence at 3am and at the London       |
//|  open: the window stretches in time when the market is quiet and  |
//|  compresses when it is busy, without being told to. Choose neff   |
//|  from the statistics, invert for rho. Nothing is chosen in units  |
//|  of time, so nothing assumes a rate.                              |
//|                                                                   |
//|  The abscissa is still real server milliseconds. Only the         |
//|  WEIGHTING is event-based, so velocity is points per second and   |
//|  dt is never fabricated.                                          |
//|                                                                   |
//|  This is not the feedback loop that wrecks adaptive windows. The  |
//|  window CONTENT is the last ~neff events regardless of anything   |
//|  measured; the measured interval is only a floating-point scale   |
//|  factor and cannot change which observations are in the fit.      |
//|                                                                   |
//|  ------------------------------------------------------------    |
//|  TWO KINDS OF UNCERTAINTY                                         |
//|  ------------------------------------------------------------    |
//|  SE(v) says how well v was ESTIMATED from the window. It does     |
//|  not say how well v DESCRIBES THE NEXT SECOND. A tight error bar  |
//|  on a velocity that reverses immediately is perfectly possible.   |
//|  So every estimate is reported with its estimation error, and a   |
//|  separate scoreboard measures forecast skill empirically:         |
//|  non-overlapping, out of sample, split by confidence, so the      |
//|  question of whether z sorts predictions by quality is answered   |
//|  with a number rather than argued about.                          |
//|                                                                   |
//|  ------------------------------------------------------------    |
//|  CONTRACT                                                         |
//|  ------------------------------------------------------------    |
//|  * Only clock: MqlTick.time_msc. No local time anywhere.          |
//|  * Only prices: bid and ask. No mid, no notional centre.          |
//|    Spread is a relation between them, never a third price.        |
//|  * Each side advances on its OWN updates only.                    |
//|  * v and a come from ONE quadratic fit. Nothing differenced twice.|
//|  * Values are always stored and always shown. Confidence is an    |
//|    annotation beside the number, never a replacement for it.      |
//|                                                                   |
//|  UNITS: position points, time seconds, v pts/s, a pts/s^2.        |
//|  Sign is direction: v = -3.2 means that side is falling at 3.2    |
//|  points per second.                                               |
//+------------------------------------------------------------------+
//| ENGINE SECTION. Same engine as NewtonianMechanics.mq5, with the    |
//| three event handlers renamed so a host EA can call them:           |
//|   NewtonianInit()   from OnInit()   - returns INIT_SUCCEEDED/INIT_FAILED |
//|   NewtonianDeinit() from OnDeinit() - clears the comment and the panel   |
//|   NewtonianTick()   from OnTick()   - updates everything, repaints       |
//| After NewtonianTick() read Tick.*, nwphase, BidSide.kin[r], AskSide.kin[r]|
//+------------------------------------------------------------------+


#define NRUNG 3     // scales in the ladder
#define NHOR  3     // forecast horizons per scale

//+------------------------------------------------------------------+
//| The only constants, and they are requirements not preferences.   |
//+------------------------------------------------------------------+

//--- Effective sample size per rung, geometric. The floor is set by
//--- the fit: three parameters, so the residual variance has neff-3
//--- degrees of freedom and is worthless until that is well above
//--- one. 16 is the smallest honest rung; the ladder spans 16x so
//--- the rungs can genuinely disagree.
const double TARGET_NEFF[NRUNG] = {16.0, 64.0, 256.0};

//--- Forecast horizons as a fraction of the rung's own current span.
//--- Scale-relative, so a rung is always asked to predict a fixed
//--- proportion of its own window ahead, whatever the pace.
const double HORIZON_FRAC[NHOR] = {0.25, 0.50, 1.00};

//--- MEASURED efficiency floors: the 95th percentile of E = |net|/path
//--- under a DRIFTLESS random walk, from 4000 simulated series per rung.
//--- E above these happens 5% of the time on pure noise, so they are
//--- false-positive thresholds, not tuning knobs. They scale as
//--- 1/sqrt(neff), which is the random-walk law and a check that the
//--- accumulator is behaving.
//---
//--- Detection power at these thresholds, also measured, for a drift of
//--- 0.25x the per-event noise:   n=16 -> 16%,  n=64 -> 51%,  n=256 -> 98%.
//--- The FAST rung is nearly blind to expansion. That is why the phase
//--- classifier below is built on the SLOW rung and not the fast one.
const double EFF_FLOOR[NRUNG] = {0.581, 0.306, 0.151};


//--- Which rung feeds the legacy Tick facade (see TickMechanics below).
//--- The old code had a single ~1 s window, so rung 0 is the nearest
//--- match. All three rungs stay available in BidSide.kin[] / AskSide.kin[].
#define LEGACY_RUNG     0

//--- Uncomment to show ONLY the legacy one-line Comment and suppress
//--- the full panel. The estimator runs either way; this is display.
//#define LEGACY_LINE_ONLY

//--- Fallback interval clock. The broker's time_msc is always
//--- preferred and is the only clock when it carries real sub-second
//--- information. Comment this out if your MQL4 build predates
//--- GetMicrosecondCount(); the system then stays server-only and
//--- warns instead of falling back.
#define USE_LOCAL_INTERVAL_CLOCK

#define CLOCK_PROBE_TICKS  200    // ticks spent judging the server clock
#define CLOCK_ROUND_FRAC   0.95   // msc%1000==0 above this = seconds*1000
#define CLOCK_TIE_FRAC     0.60   // dt==0 above this = unusable intervals

#define CLOCK_PROBING   0
#define CLOCK_SERVER    1
#define CLOCK_LOCAL     2

//--- CLOCK_RATE rebuilds sub-second timing from the TICK RATE alone:
//--- ticks are counted over a window of server seconds, the mean
//--- interval follows, and ticks inside a second are spread across it.
//--- It uses nothing but server seconds and tick counts, so it stays
//--- entirely in the broker's frame. Its assumption - that arrivals
//--- are uniform inside a second - cannot be checked from a feed that
//--- only reports seconds. See the ClockMs() header for what that
//--- costs when arrivals are bursty, which they usually are.
#define CLOCK_RATE      3

//--- Which fallback when the server stamp has no sub-second content.
//--- CLOCK_RATE keeps everything in the broker's frame.
//--- CLOCK_LOCAL measures arrival at this terminal instead, which is
//--- a different frame but a measurement rather than an assumption.
#define FALLBACK_CLOCK  CLOCK_RATE

//+------------------------------------------------------------------+
//| Market-phase state codes.                                         |
//|                                                                   |
//| These live up here with the other #defines because ResetAll()      |
//| references PHASE_WARMING and is defined well above the phase       |
//| classifier. #define is textual and only applies after the point it |
//| appears, so a define placed next to its classifier is invisible to |
//| everything earlier in the file.                                    |
//+------------------------------------------------------------------+
#define PHASE_WARMING        0
#define PHASE_CONSOLIDATION  1
#define PHASE_EXPANSION      2
#define PHASE_RETRACEMENT    3
#define PHASE_STRESSED       4
#define PHASE_UNDETERMINED   5

//--- ticks a raw state must persist before it is committed
#define PHASE_PERSIST        8

//--- spread multiple of its own baseline that counts as elevated
#define PHASE_SPREAD_X       1.5

#define WARM_FRACTION   0.80  // of asymptotic neff before solving
#define GAP_INTERVAL_X  50.0  // gap = this many mean tick intervals
#define REANCHOR_POINTS 1024.0// keeps RSS = Q - fitted from cancelling
#define CONF_Z          2.0   // splits the forecast scoreboard
#define REPORT_MS       100.0 // Comment() repaint throttle, cosmetic
#define PACE_RHO        0.98  // decay of the tick-interval estimate

//--- random-walk error-floor coefficients, calibrated by simulation
//--- against driftless walks and steady across a 5x pace change.
//--- Named rather than inline so this file and the .mq4 cannot drift
//--- apart when one of them is tuned.
#define RW_KV           1.80
#define RW_KA           1.10

//+------------------------------------------------------------------+
//| Numeric helpers                                                  |
//+------------------------------------------------------------------+
const int BINOM[5][5] =
{
   {1,0,0,0,0},
   {1,1,0,0,0},
   {1,2,1,0,0},
   {1,3,3,1,0},
   {1,4,6,4,1}
};

double NegPow(const double d, const int m)
{
   double r = 1.0;
   for(int i = 0; i < m; i++) r *= -d;
   return r;
}

double IntPow(const double f, const int m)
{
   double r = 1.0;
   for(int i = 0; i < m; i++) r *= f;
   return r;
}

//+------------------------------------------------------------------+
//| Advance a moment vector's time origin by d (internal units) and  |
//| scale its weights by g.                                          |
//|                                                                  |
//|    M'_k = g * sum_{j<=k} C(k,j) * (-d)^(k-j) * M_j               |
//|                                                                  |
//| Exact and closed: this is what removes the ring buffer and every |
//| index computation that goes with it.                             |
//|                                                                  |
//| g = rho when the side received an update; g = 1 when it did not, |
//| because no new information arrived, so the old information is    |
//| not devalued, it is merely referenced to a later instant.        |
//+------------------------------------------------------------------+
void ShiftMoments(double &M[], const int n, const double d, const double g)
{
   double out[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   for(int k = 0; k < n; k++)
   {
      double s = 0.0;
      for(int j = 0; j <= k; j++)
         s += (double)BINOM[k][j] * NegPow(d, k - j) * M[j];
      out[k] = g * s;
   }
   for(int k = 0; k < n; k++) M[k] = out[k];
}

//--- change of internal time unit: (u/new)^k = (old/new)^k * (u/old)^k
void RescaleMoments(double &M[], const int n, const double f)
{
   for(int k = 0; k < n; k++) M[k] *= IntPow(f, k);
}

bool SymInverse3(const double &M[], double &Inv[][3])
{
   double a00 = M[0], a01 = M[1], a02 = M[2];
   double a11 = M[2], a12 = M[3];
   double a22 = M[4];

   double c00 =  (a11 * a22 - a12 * a12);
   double c01 = -(a01 * a22 - a12 * a02);
   double c02 =  (a01 * a12 - a11 * a02);
   double c11 =  (a00 * a22 - a02 * a02);
   double c12 = -(a00 * a12 - a01 * a02);
   double c22 =  (a00 * a11 - a01 * a01);

   double det   = a00 * c00 + a01 * c01 + a02 * c02;
   double scale = a00 * a00 * a00;
   if(scale <= 0.0 || MathAbs(det) < 1.0e-12 * scale) return false;

   double id = 1.0 / det;
   Inv[0][0] = c00 * id; Inv[0][1] = c01 * id; Inv[0][2] = c02 * id;
   Inv[1][0] = c01 * id; Inv[1][1] = c11 * id; Inv[1][2] = c12 * id;
   Inv[2][0] = c02 * id; Inv[2][1] = c12 * id; Inv[2][2] = c22 * id;
   return true;
}

void SymFromMoments(const double &M[], double &A[][3])
{
   A[0][0] = M[0]; A[0][1] = M[1]; A[0][2] = M[2];
   A[1][0] = M[1]; A[1][1] = M[2]; A[1][2] = M[3];
   A[2][0] = M[2]; A[2][1] = M[3]; A[2][2] = M[4];
}

//--- C = A * B * A, all 3x3, A symmetric
void SandwichAt(const double &A[][3], const double &B[][3], double &C[][3])
{
   double t[3][3] = {{0,0,0},{0,0,0},{0,0,0}};
   for(int i = 0; i < 3; i++)
      for(int j = 0; j < 3; j++)
      {
         double s = 0.0;
         for(int k = 0; k < 3; k++) s += A[i][k] * B[k][j];
         t[i][j] = s;
      }
   for(int i = 0; i < 3; i++)
      for(int j = 0; j < 3; j++)
      {
         double s = 0.0;
         for(int k = 0; k < 3; k++) s += t[i][k] * A[k][j];
         C[i][j] = s;
      }
}

//+------------------------------------------------------------------+
//| KinState - what the estimator produces, stored, never discarded  |
//+------------------------------------------------------------------+
struct KinState
{
   bool   valid;
   double pos;      // fitted position, points (absolute)
   double vel;      // points / second
   double acc;      // points / second^2
   double seVel;
   double seAcc;
   double covVA;    // cov(vel, acc) - required for projection error
   double zVel;
   double zAcc;
   double neff;
   double target;   // asymptotic neff of this rung
   double spanSec;  // what this rung currently covers, in seconds
   double typSpeed; // typical step speed, for magnitude comparison
   double eff;      // |net|/path over this window, [0,1]
   double effFloor; // driftless p95 for this rung

   void Clear()
   {
      valid = false;
      pos = 0.0; vel = 0.0; acc = 0.0;
      seVel = 0.0; seAcc = 0.0; covVA = 0.0;
      zVel = 0.0; zAcc = 0.0;
      neff = 0.0; target = 0.0; spanSec = 0.0; typSpeed = 0.0;
      eff = 0.0; effFloor = 0.0;
   }

   //--- projected displacement over tau seconds, with propagated error
   //--- var = tau^2 var(v) + (1/4) tau^4 var(a) + tau^3 cov(v,a)
   void Project(const double tau, double &dx, double &sedx) const
   {
      dx = vel * tau + 0.5 * acc * tau * tau;
      double v = tau * tau * seVel * seVel
               + 0.25 * IntPow(tau, 4) * seAcc * seAcc
               + IntPow(tau, 3) * covVA;
      sedx = (v > 0.0 ? MathSqrt(v) : 0.0);
   }

   //--- seconds until velocity reaches zero, if it is heading there.
   //--- Meaningless unless v and a come from the same fit, which is
   //--- exactly why the single-quadratic structure matters.
   double TurningTime() const
   {
      if(!valid || acc == 0.0) return -1.0;
      if(vel * acc >= 0.0)     return -1.0;   // not decelerating
      double tt = -vel / acc;
      if(tt <= 0.0 || tt > spanSec * 4.0) return -1.0;
      return tt;
   }
};

//+------------------------------------------------------------------+
//| QuadFit                                                          |
//|                                                                  |
//| Event-weighted local quadratic x(u) = a + b u + c u^2, fitted     |
//| continuously against real server time. u runs backwards from the  |
//| current instant, so v = b and acceleration = 2c are evaluated AT  |
//| NOW, from the same fit over the same data with the same stencil.  |
//|                                                                  |
//| The internal time unit floats with the market's own pace purely   |
//| so u stays of order one and the 3x3 solve stays conditioned       |
//| whether ticks arrive every 4 ms or every 40 seconds.              |
//+------------------------------------------------------------------+
struct QuadFit
{
   double rho;
   double targetNeff;
   double unitMs;
   double S[5];        // sum w u^k
   double P[5];        // sum w^2 u^k   (kernel covariance sandwich)
   double T[3];        // sum w u^k x
   double Q;           // sum w x^2
   double mdtW, mdtS;  // event-weighted mean inter-update interval

   //--- event-weighted moments of the per-update price increment. These
   //--- give the scale of the random-walk component, which is what the
   //--- OLS covariance cannot see.
   double incW, incS, incS2;
   //--- incS is already the decayed SIGNED travel. pathS is the decayed
   //--- ABSOLUTE travel. Their ratio is efficiency: 1 for a straight
   //--- line, ~1/sqrt(neff) for an uncorrelated walk.
   double pathS;
   double lastObsX;
   bool   haveLastObs;

   void Init(const double neff)
   {
      targetNeff = neff;
      rho        = (neff - 1.0) / (neff + 1.0);
      Reset();
   }

   void Reset()
   {
      for(int i = 0; i < 5; i++) { S[i] = 0.0; P[i] = 0.0; }
      for(int i = 0; i < 3; i++) T[i] = 0.0;
      Q = 0.0; mdtW = 0.0; mdtS = 0.0; unitMs = 0.0;
      incW = 0.0; incS = 0.0; incS2 = 0.0; pathS = 0.0;
      lastObsX = 0.0; haveLastObs = false;
   }

   double Efficiency() const
   {
      return (pathS > 0.0 ? MathAbs(incS) / pathS : 0.0);
   }

   double SdInc() const
   {
      if(incW <= 0.0) return 0.0;
      double m = incS / incW;
      double v = incS2 / incW - m * m;
      return (v > 0.0 ? MathSqrt(v) : 0.0);
   }

   double MeanDt()  const { return (mdtW > 0.0 ? mdtS / mdtW : 0.0); }
   double SpanSec() const { return MeanDt() * targetNeff / 1000.0; }
   double Neff()    const { return (P[0] > 0.0 ? (S[0]*S[0])/P[0] : 0.0); }
   bool   Warm()    const { double n = Neff();
                            return (n >= targetNeff * WARM_FRACTION && n > 4.0); }

   //--- no update from this side: keep the origin current, keep weights
   void Carry(const double dms)
   {
      if(dms <= 0.0 || unitMs <= 0.0) return;
      double d = dms / unitMs;
      ShiftMoments(S, 5, d, 1.0);
      ShiftMoments(T, 3, d, 1.0);
      ShiftMoments(P, 5, d, 1.0);
      //--- Q carries no u dependence and is invariant under a shift
   }

   //--- genuine update. dms is the interval since THIS side last
   //--- changed, not since the last tick of any kind.
   void Update(const double x, const double dms)
   {
      //--- increment scale of this side's own stream
      if(haveLastObs)
      {
         double dx = x - lastObsX;
         incW  = rho * incW  + 1.0;
         incS  = rho * incS  + dx;
         incS2 = rho * incS2 + dx * dx;
         pathS = rho * pathS + MathAbs(dx);
      }
      lastObsX    = x;
      haveLastObs = true;

      bool haveUnit = (unitMs > 0.0);

      //--- Mean interval per EVENT, ties included. Skipping zero gaps
      //--- would measure the mean NONZERO gap instead, which on a
      //--- batched or second-resolution feed overstates the interval
      //--- by the batch size. SpanSec() is built from this, and the
      //--- random-walk error floor divides by SpanSec(), so excluding
      //--- ties made both fictitious: measured 16 s of reported span
      //--- where the real window was 0.64 s.
      mdtW = rho * mdtW + 1.0;
      mdtS = rho * mdtS + dms;

      double md      = MeanDt();
      double newUnit = (md > 0.0 ? md * targetNeff : 0.0);

      if(!haveUnit)
      {
         if(newUnit <= 0.0)
         {
            //--- no timescale yet (an unbroken run of tied stamps):
            //--- record at u = 0, no shift, no decay
            S[0] += 1.0; P[0] += 1.0; T[0] += x; Q += x * x;
            return;
         }
         //--- everything stored so far sits at u = 0, so adopting the
         //--- first unit needs no rescale
         unitMs = newUnit;
      }
      else if(newUnit > 0.0 && newUnit != unitMs)
      {
         double f = unitMs / newUnit;
         RescaleMoments(S, 5, f);
         RescaleMoments(T, 3, f);
         RescaleMoments(P, 5, f);
         unitMs = newUnit;
      }

      double d = (dms > 0.0 ? dms / unitMs : 0.0);
      ShiftMoments(S, 5, d, rho);
      ShiftMoments(T, 3, d, rho);
      ShiftMoments(P, 5, d, rho * rho);
      Q *= rho;

      S[0] += 1.0; P[0] += 1.0; T[0] += x; Q += x * x;
   }

   //--- move the position origin: x_new = x_old - delta. Exact.
   void ReAnchor(const double delta)
   {
      if(delta == 0.0) return;
      Q    = Q - 2.0 * delta * T[0] + delta * delta * S[0];
      T[0] = T[0] - delta * S[0];
      T[1] = T[1] - delta * S[1];
      T[2] = T[2] - delta * S[2];
      lastObsX -= delta;     // increments are differences, unaffected
   }

   //--- Fill a KinState. anchorPts converts the fitted intercept back
   //--- to absolute points. Returns false only when the fit cannot be
   //--- formed at all; a low-confidence fit still returns its values.
   bool Solve(KinState &k, const double anchorPts, const double typSpeed)
   {
      k.Clear();
      k.neff     = Neff();
      k.target   = targetNeff;
      k.spanSec  = SpanSec();
      k.typSpeed = typSpeed;
      k.eff      = Efficiency();

      if(!Warm() || unitMs <= 0.0) return false;

      double Inv[3][3];
      if(!SymInverse3(S, Inv)) return false;

      double a = Inv[0][0]*T[0] + Inv[0][1]*T[1] + Inv[0][2]*T[2];
      double b = Inv[1][0]*T[0] + Inv[1][1]*T[1] + Inv[1][2]*T[2];
      double c = Inv[2][0]*T[0] + Inv[2][1]*T[1] + Inv[2][2]*T[2];

      double rss = Q - (a*T[0] + b*T[1] + c*T[2]);
      if(rss < 0.0) rss = 0.0;

      double dof = k.neff - 3.0;
      if(dof <= 1.0) return false;
      double sigma2 = (rss / S[0]) * (k.neff / dof);

      double B[3][3], Cov[3][3];
      SymFromMoments(P, B);
      SandwichAt(Inv, B, Cov);

      double varB = sigma2 * Cov[1][1]; if(varB < 0.0) varB = 0.0;
      double varC = sigma2 * Cov[2][2]; if(varC < 0.0) varC = 0.0;
      double covBC= sigma2 * Cov[1][2];

      double k1 = 1000.0 / unitMs;    // internal unit -> per second
      double k2 = k1 * k1;

      k.pos   = anchorPts + a;
      k.vel   = b * k1;
      k.acc   = 2.0 * c * k2;
      k.seVel = MathSqrt(varB) * k1;
      k.seAcc = 2.0 * MathSqrt(varC) * k2;
      k.covVA = covBC * k1 * 2.0 * k2;

      //--- RANDOM-WALK ERROR FLOOR
      //--- The OLS covariance above assumes residuals independent about
      //--- the fitted curve. A price series is close to a random walk,
      //--- so residuals are strongly serially correlated, the quadratic
      //--- absorbs the wandering, and the scatter about the fit badly
      //--- understates how far the PARAMETERS can move. Measured against
      //--- simulated driftless walks it understated the true sampling
      //--- dispersion by 4x at n=16 and 18x at n=256 - worse on the
      //--- slower rungs, which is the opposite of what one would assume.
      //---
      //--- Under a random walk of per-event increment sd si, the true
      //--- dispersion scales as si*sqrt(neff)/span for velocity and
      //--- si*sqrt(neff)/span^2 for acceleration. The coefficients below
      //--- were calibrated by simulation and held steady across a 5x
      //--- change of pace; they are set on the conservative side.
      //---
      //--- Taking the larger of the two keeps the OLS figure where the
      //--- series really is smooth (a clean ramp has zero increment
      //--- variance, so the floor vanishes) and the walk figure where it
      //--- is not, which is almost always.
      double span = k.spanSec;
      double si   = SdInc();
      if(span > 0.0 && si > 0.0)
      {
         double rwVel = RW_KV * si * MathSqrt(k.neff) / span;
         double rwAcc = RW_KA * si * MathSqrt(k.neff) / (span * span);
         double fV = 1.0, fA = 1.0;
         if(rwVel > k.seVel) { fV = (k.seVel > 0.0 ? rwVel / k.seVel : 1.0); k.seVel = rwVel; }
         if(rwAcc > k.seAcc) { fA = (k.seAcc > 0.0 ? rwAcc / k.seAcc : 1.0); k.seAcc = rwAcc; }
         k.covVA *= fV * fA;   // preserve the correlation, not the scale
      }

      k.zVel  = (k.seVel > 0.0 ? k.vel / k.seVel : 0.0);
      k.zAcc  = (k.seAcc > 0.0 ? k.acc / k.seAcc : 0.0);
      k.valid = true;
      return true;
   }
};

//+------------------------------------------------------------------+
//| StepEst - fixed-displacement view                                |
//|                                                                  |
//| Rather than asking how far the quote moved in a fixed time, it    |
//| asks how long each whole-point step took, so the numerator is     |
//| exact and only the duration is measured. Decays per step, so it   |
//| also carries fixed evidence regardless of pace. Its RMS doubles   |
//| as the typical-speed scale for judging magnitude.                 |
//+------------------------------------------------------------------+
struct StepEst
{
   double rho, targetNeff;
   double lastX, lastMs;
   bool   primed;
   double wSum, w2Sum, vSum, v2Sum;

   void Init(const double neff)
   {
      targetNeff = neff;
      rho        = (neff - 1.0) / (neff + 1.0);
      Reset();
   }

   void Reset()
   {
      lastX = 0.0; lastMs = 0.0; primed = false;
      wSum = 0.0; w2Sum = 0.0; vSum = 0.0; v2Sum = 0.0;
   }

   void ReAnchor(const double delta) { lastX -= delta; }

   void Observe(const double x, const double ms)
   {
      if(!primed) { lastX = x; lastMs = ms; primed = true; return; }

      double dx = x - lastX;
      if(MathAbs(dx) < 0.999) return;        // not yet a whole-point step
      double dt = ms - lastMs;
      if(dt <= 0.0) { lastX = x; return; }   // same instant: no duration

      double v = dx * 1000.0 / dt;
      wSum  = rho * wSum  + 1.0;
      w2Sum = rho * rho * w2Sum + 1.0;
      vSum  = rho * vSum  + v;
      v2Sum = rho * v2Sum + v * v;
      lastX = x; lastMs = ms;
   }

   double Neff() const { return (w2Sum > 0.0 ? (wSum*wSum)/w2Sum : 0.0); }

   double TypicalSpeed() const
   {
      if(wSum <= 0.0) return 0.0;
      double ms2 = v2Sum / wSum;
      return (ms2 > 0.0 ? MathSqrt(ms2) : 0.0);
   }

   bool Solve(double &vel, double &seVel, double &neff)
   {
      vel = 0.0; seVel = 0.0;
      neff = Neff();
      if(wSum <= 0.0 || neff < targetNeff * WARM_FRACTION || neff <= 2.0)
         return false;
      double m  = vSum / wSum;
      double v2 = v2Sum / wSum - m * m;
      if(v2 < 0.0) v2 = 0.0;
      vel = m; seVel = MathSqrt(v2 / neff);
      return true;
   }
};

//+------------------------------------------------------------------+
//| Forecast scoring                                                 |
//|                                                                  |
//| One pending prediction per slot, so predictions never overlap:    |
//| a new one starts only when the last has matured. That keeps the   |
//| samples close to independent instead of a smear of overlapping    |
//| windows, and it needs no ring buffer.                             |
//+------------------------------------------------------------------+
struct Pending
{
   bool   active;
   double maturityMs;
   double x0;        // absolute points at prediction time
   double pred;      // predicted displacement, points
   double absZ;      // |z| of velocity when predicted

   void Clear() { active = false; maturityMs = 0.0; x0 = 0.0; pred = 0.0; absZ = 0.0; }
};

struct Score
{
   double n, dn, hits;
   double sp, sr, sp2, sr2, spr, sse;

   void Clear() { n=0; dn=0; hits=0; sp=0; sr=0; sp2=0; sr2=0; spr=0; sse=0; }

   void Add(const double p, const double r)
   {
      n   += 1.0;
      sp  += p;   sr  += r;
      sp2 += p*p; sr2 += r*r; spr += p*r;
      sse += (r-p)*(r-p);
      if(p != 0.0 && r != 0.0)
      {
         dn += 1.0;
         if(p * r > 0.0) hits += 1.0;
      }
   }

   double HitRate() const { return (dn > 0.0 ? hits / dn : 0.0); }

   //--- predictive R^2: skill against simply predicting the mean
   double R2() const
   {
      if(n < 2.0) return 0.0;
      double sst = sr2 - (sr*sr)/n;
      if(sst <= 0.0) return 0.0;
      return 1.0 - sse/sst;
   }
};

//--- forward declarations: these are called from SideState::PoolInto
//--- and from the display code, both of which appear before the
//--- definitions further down.
void   PoolScore(Score &dst, Score &src);
double PooledR2(Score &lo, Score &hi);

struct HorizonSlot
{
   Pending pend;
   Score   lo;    // |z| <  CONF_Z at prediction time
   Score   hi;    // |z| >= CONF_Z

   void ClearAll()     { pend.Clear(); lo.Clear(); hi.Clear(); }
   void ClearPending() { pend.Clear(); }
};

//+------------------------------------------------------------------+
//| SideState - one independent quote stream                         |
//+------------------------------------------------------------------+
struct SideState
{
   QuadFit     fit[NRUNG];
   StepEst     step[NRUNG];
   KinState    kin[NRUNG];
   HorizonSlot slot[NRUNG][NHOR];

   double anchor;      // points
   double lastPrice;   // absolute points
   double lastUpdMs;
   bool   primed;
   ulong  updates;

   //--- this side's OWN last event, for the legacy facade. dt is the
   //--- interval since this side previously changed - not since the
   //--- last tick of any kind, which for one side is usually shorter.
   double lastDtMs;    // ms between this side's last two updates
   double lastDxPts;   // points moved on this side's last update

   void Init()
   {
      for(int r = 0; r < NRUNG; r++)
      {
         fit[r].Init(TARGET_NEFF[r]);
         step[r].Init(TARGET_NEFF[r]);
         for(int h = 0; h < NHOR; h++) slot[r][h].ClearAll();
      }
      Reset();
   }

   //--- clears estimator state and pending predictions, but KEEPS the
   //--- accumulated scores: they are what the run has learned.
   void Reset()
   {
      for(int r = 0; r < NRUNG; r++)
      {
         fit[r].Reset();
         step[r].Reset();
         kin[r].Clear();
         for(int h = 0; h < NHOR; h++) slot[r][h].ClearPending();
      }
      anchor = 0.0; lastPrice = 0.0; lastUpdMs = 0.0;
      primed = false; updates = 0;
      lastDtMs = 0.0; lastDxPts = 0.0;
   }

   void Carry(const double dms)
   {
      for(int r = 0; r < NRUNG; r++) fit[r].Carry(dms);
   }

   void Update(const double pricePts, const double ms)
   {
      if(!primed)
      {
         anchor = pricePts; primed = true; lastUpdMs = ms;
         for(int r = 0; r < NRUNG; r++)
         {
            fit[r].Update(0.0, 0.0);
            step[r].Observe(0.0, ms);
         }
         lastPrice = pricePts; updates = 1;
         lastDtMs = 0.0; lastDxPts = 0.0;
         return;
      }

      double dms = ms - lastUpdMs;
      double x   = pricePts - anchor;

      //--- this side's own event, before anything is overwritten
      lastDtMs  = dms;
      lastDxPts = pricePts - lastPrice;

      for(int r = 0; r < NRUNG; r++)
      {
         fit[r].Update(x, dms);
         step[r].Observe(x, ms);
      }

      lastUpdMs = ms; lastPrice = pricePts; updates++;

      if(MathAbs(x) > REANCHOR_POINTS)
      {
         for(int r = 0; r < NRUNG; r++)
         {
            fit[r].ReAnchor(x);
            step[r].ReAnchor(x);
         }
         anchor += x;
      }
   }

   //--- Pool this side's forecast scores for one rung/horizon into the
   //--- caller's accumulators. The slot array is 2-D in the .mq5 and
   //--- flattened in the .mq4; keeping that difference inside this one
   //--- method lets every display path be byte-identical across both.
   void PoolInto(int r, int h, Score &lo, Score &hi)
   {
      PoolScore(lo, slot[r][h].lo);
      PoolScore(hi, slot[r][h].hi);
   }

   //--- recompute stored kinematics from the current fits
   void Refresh()
   {
      for(int r = 0; r < NRUNG; r++)
      {
         fit[r].Solve(kin[r], anchor, step[r].TypicalSpeed());
         kin[r].effFloor = EFF_FLOOR[r];   // QuadFit has no rung index
      }
   }

   //--- mature any prediction whose horizon has elapsed, then open a
   //--- new one in the freed slot
   void ScoreAndPredict(const double ms)
   {
      for(int r = 0; r < NRUNG; r++)
      {
         for(int h = 0; h < NHOR; h++)
         {
            //--- settle
            if(slot[r][h].pend.active && ms >= slot[r][h].pend.maturityMs)
            {
               double realised = lastPrice - slot[r][h].pend.x0;
               double p        = slot[r][h].pend.pred;
               if(slot[r][h].pend.absZ >= CONF_Z) slot[r][h].hi.Add(p, realised);
               else                               slot[r][h].lo.Add(p, realised);
               slot[r][h].pend.Clear();
            }

            //--- open, only if the slot is free and the fit is usable
            if(!slot[r][h].pend.active && kin[r].valid)
            {
               double tau = HORIZON_FRAC[h] * kin[r].spanSec;
               if(tau > 0.0)
               {
                  double dx, sedx;
                  kin[r].Project(tau, dx, sedx);
                  slot[r][h].pend.active     = true;
                  slot[r][h].pend.maturityMs = ms + tau * 1000.0;
                  slot[r][h].pend.x0         = lastPrice;
                  slot[r][h].pend.pred       = dx;
                  slot[r][h].pend.absZ       = MathAbs(kin[r].zVel);
               }
            }
         }
      }
   }
};

//+------------------------------------------------------------------+
//| Globals - read these from your own OnTick                        |
//+------------------------------------------------------------------+
//--- NOT named Bid/Ask: MQL4 predefines both as doubles, so those
//--- names are already taken there. Renamed in this file too so the
//--- two stay identical.
SideState BidSide, AskSide;

//--- spread channel, derived by exact subtraction. With a shared
//--- decay and both fits referenced to the same instant this identity
//--- holds at every order; its value is that its statistics differ
//--- sharply from the two sides.
KinState  Spread[NRUNG];

//--- The spread's own whole-point step stream. The spread is derived
//--- from the two sides by exact subtraction at every ORDER, but its
//--- typical SPEED is not derivable that way: bid and ask steps are
//--- correlated, so combining their RMS would be a guess. It is a real
//--- quantity, so it gets measured rather than assumed - or left at
//--- zero, which is what it was.
StepEst   SpreadStep[NRUNG];

//--- The spread's own efficiency: is it trending (widening or closing
//--- persistently) or just oscillating? Same accumulator pair as the
//--- sides use, fed the spread's per-tick increments. Measured rather
//--- than left at zero, because a field that always reads 0.0 looks
//--- like data and is not.
double    nwspEffRho[NRUNG];
double    nwspNet[NRUNG];
double    nwspPath[NRUNG];
double    nwspLastPts = 0.0;
bool      nwspEffPrimed = false;

//+------------------------------------------------------------------+
//| TickMechanics - the legacy facade                                   |
//|                                                                   |
//| Same field names as the original struct, filled from the rung     |
//| named by LEGACY_RUNG, so existing code that reads Tick.bidVelocity |
//| and friends compiles and runs unchanged. Every field is a bid or   |
//| ask pair: there is no bare Tick.velocity, because there is no      |
//| single price to take the velocity OF. A bare name would have to    |
//| mean a mid, and this system does not have one.                     |
//|                                                                   |
//| UNITS, and they differ from the original:                          |
//|   time, bid, ask, spread     as the broker gives them              |
//|   *DeltaTime                 SECONDS between that side's own two   |
//|                              most recent updates (the original     |
//|                              used a whole window and floored it    |
//|                              at 1e-4 when the clock tied; nothing  |
//|                              is floored here - a tie means that    |
//|                              side has not produced an interval yet)|
//|   *DeltaPrice                POINTS moved on that side's last      |
//|                              update (the original was in price     |
//|                              units over a window)                  |
//|   *Velocity                  POINTS PER SECOND, fitted             |
//|   *Acceleration              POINTS PER SECOND SQUARED, fitted     |
//|   *DeltaVelocity             POINTS PER SECOND: the velocity       |
//|                              change the fit implies across that    |
//|                              side's own last interval, i.e.        |
//|                              acceleration * deltaTime. The         |
//|                              original differenced two stored       |
//|                              velocities, which is the double       |
//|                              differencing that made its numbers    |
//|                              meaningless. Same name, same units,   |
//|                              same intent, one consistent fit.      |
//|                                                                   |
//| The z fields have no counterpart in the original and are the       |
//| reason the rest can be trusted: a velocity with |z| under 2 is     |
//| not distinguishable from no movement at all.                       |
//+------------------------------------------------------------------+
struct TickMechanics
{
   double time;                 // seconds (time_msc * 0.001)
   double bid;                  // broker bid
   double ask;                  // broker ask
   double spread;               // ask - bid, in price units

   double bidDeltaTime;         // seconds since the BID last changed
   double askDeltaTime;         // seconds since the ASK last changed

   double bidDeltaPrice;        // points moved on the bid's last update
   double askDeltaPrice;        // points moved on the ask's last update

   double bidVelocity;          // points / second
   double askVelocity;
   double bidAcceleration;      // points / second^2
   double askAcceleration;

   double bidDeltaVelocity;     // = bidAcceleration * bidDeltaTime
   double askDeltaVelocity;

   //--- spread stream, derived by exact subtraction from the two sides
   double spreadPts;            // ask - bid, in points
   double spreadVelocity;       // points / second
   double spreadAcceleration;   // points / second^2

   //--- confidence. Not decoration: these say whether the numbers above
   //--- are distinguishable from nothing happening.
   double bidVelocityZ,     askVelocityZ;
   double bidAccelerationZ, askAccelerationZ;
   double spreadVelocityZ,  spreadAccelerationZ;

   bool   bidReady, askReady;   // rung warm for that side

   void Clear()
   {
      time = 0.0; bid = 0.0; ask = 0.0; spread = 0.0;
      bidDeltaTime = 0.0; askDeltaTime = 0.0;
      bidDeltaPrice = 0.0; askDeltaPrice = 0.0;
      bidVelocity = 0.0; askVelocity = 0.0;
      bidAcceleration = 0.0; askAcceleration = 0.0;
      bidDeltaVelocity = 0.0; askDeltaVelocity = 0.0;
      spreadPts = 0.0; spreadVelocity = 0.0; spreadAcceleration = 0.0;
      bidVelocityZ = 0.0; askVelocityZ = 0.0;
      bidAccelerationZ = 0.0; askAccelerationZ = 0.0;
      spreadVelocityZ = 0.0; spreadAccelerationZ = 0.0;
      bidReady = false; askReady = false;
   }
};

TickMechanics Tick;

//--- legacy status string. The original switched between "Accumulating
//--- Data" and "Processing Information" on window-fill; here it reports
//--- the warm-up state of the nominated rung, which is the same idea
//--- with an actual criterion behind it.
string    reading = "";

string    nwsymbol = "";
double    nwpoint  = 0.0;
int       nwdigits = 0;

double    nwlastMs    = 0.0;
bool      nwhaveClock = false;
double    nwprevBid   = 0.0, nwprevAsk = 0.0;

double    nwpaceW = 0.0, nwpaceS = 0.0;   // tick pace, for gap detection
double    nwspW   = 0.0, nwspS   = 0.0;   // spread reference level
double    nwspRho = 0.0;

ulong     nwticks = 0, nwties = 0, nwmscRound = 0, nwresets = 0;
double    nwlastReportMs = 0.0;

//--- clock state. See the ClockMs() header for what the fallback costs.
int       nwclock        = CLOCK_PROBING;
double    nwlocalAnchorMs= 0.0;   // GetMicrosecondCount() at the anchor, ms
double    nwlocalBaseMs  = 0.0;   // server stamp at the anchor
double    nwdriftLocMs   = 0.0;   // local elapsed since the anchor
double    nwdriftSrvMs   = 0.0;   // server elapsed since the anchor
double    nwprobeRound   = 0.0;   // server msc%1000==0 fraction, frozen
double    nwprobeTie     = 0.0;   // server dt==0 fraction, frozen

//--- tick-rate clock state (CLOCK_RATE), server frame only
double    nwrateWinMs    = 60000.0;
double    nwrateTicks    = 0.0;   // decayed tick count
double    nwrateMs       = 0.0;   // decayed server ms over the same window
double    nwrateLastSrv  = 0.0;
double    nwrateSecond   = -1.0;  // server second currently being filled
double    nwrateSub      = 0.0;   // ticks seen so far inside that second
bool      nwratePrimed   = false;


//+------------------------------------------------------------------+
int NewtonianInit()
{
   nwsymbol = _Symbol;
   nwpoint  = SymbolInfoDouble(nwsymbol, SYMBOL_POINT);
   nwdigits = (int)SymbolInfoInteger(nwsymbol, SYMBOL_DIGITS);

   if(nwpoint <= 0.0)
   {
      Print("NewtonianMechanics: SYMBOL_POINT unusable for ", nwsymbol);
      return INIT_FAILED;
   }

   //--- a level needs a longer memory than a derivative does
   double spNeff = TARGET_NEFF[NRUNG-1] * 4.0;
   nwspRho = (spNeff - 1.0) / (spNeff + 1.0);

   //--- the one input, clamped to something sane
   nwrateWinMs =  60000.0;

   BidSide.Init();
   AskSide.Init();
   for(int si = 0; si < NRUNG; si++)
   {
      SpreadStep[si].Init(TARGET_NEFF[si]);
      nwspEffRho[si] = (TARGET_NEFF[si] - 1.0) / (TARGET_NEFF[si] + 1.0);
   }
   for(int r = 0; r < NRUNG; r++) Spread[r].Clear();

   ResetAll();
   nwticks = 0; nwties = 0; nwmscRound = 0; nwresets = 0;

   //--- build fingerprint: if the Experts log does not show this exact
   //--- string, MetaEditor compiled an older copy of the file.
   Print("NewtonianMechanics build 4.00  (Deployment.mq5)  "
         "phase defines at top, PooledR2 prototyped, BidSide/AskSide naming");
   Comment("NewtonianMechanics: waiting for ticks on ", nwsymbol);
   return INIT_SUCCEEDED;
}

void NewtonianDeinit()
{
   Comment("");
   PanelDestroy();
}

//+------------------------------------------------------------------+
void ResetAll()
{
   BidSide.Reset();
   AskSide.Reset();
   for(int sr = 0; sr < NRUNG; sr++)
   {
      SpreadStep[sr].Reset();
      nwspNet[sr] = 0.0; nwspPath[sr] = 0.0;
   }
   nwspLastPts = 0.0; nwspEffPrimed = false;
   for(int r = 0; r < NRUNG; r++) Spread[r].Clear();
   nwhaveClock = false;
   nwlastMs    = 0.0;
   nwprevBid   = 0.0; nwprevAsk = 0.0;
   nwpaceW     = 0.0; nwpaceS   = 0.0;
   nwspW       = 0.0; nwspS     = 0.0;
   nwlastReportMs = 0.0;
   nwphase = PHASE_WARMING; nwphaseRaw = PHASE_WARMING;
   nwphaseCount = 0; nwphaseSince = 0.0; nwlastSpPts = 0.0;
   nwrateTicks = 0.0; nwrateMs = 0.0; nwrateLastSrv = 0.0;
   nwrateSecond = -1.0; nwrateSub = 0.0; nwratePrimed = false;
}

double Pace() { return (nwpaceW > 0.0 ? nwpaceS / nwpaceW : 0.0); }

//+--------------------------------------------------------------------+
//| CLOCK_RATE: sub-second timing rebuilt from the tick rate.          |
//|                                                                    |
//| Counts ticks and server milliseconds over a 60 second Time Window  |
//| takes the mean interval, and places the kth tick of a second at    |
//| k * meanInterval past that second's start. Anchored to the server  |
//| second, so it cannot drift, and clamped so it never crosses into   |
//| the next one.                                                      |
//|                                                                   |
//| This is NOT the original code's averageticks. That rescaled its    |
//| own window by a statistic measured over that window, which is a    |
//| feedback loop. Here the averaging window is a fixed span of server |
//| seconds and nothing it measures can change it.                     |
//+------------------------------------------------------------------+
double RateStamp(const double serverMs)
{
   double dS = (nwratePrimed ? serverMs - nwrateLastSrv : 0.0);
   if(dS < 0.0) dS = 0.0;

   double rho  = MathExp(-dS / nwrateWinMs);
   nwrateTicks = rho * nwrateTicks + 1.0;
   nwrateMs    = rho * nwrateMs    + dS;
   nwrateLastSrv = serverMs;
   nwratePrimed  = true;

   if(serverMs != nwrateSecond) { nwrateSecond = serverMs; nwrateSub = 0.0; }
   else                         { nwrateSub += 1.0; }

   double mi  = (nwrateTicks > 0.0 ? nwrateMs / nwrateTicks : 0.0);
   double off = nwrateSub * mi;
   if(off > 999.0) off = 999.0;      // never cross the next boundary
   return serverMs + off;
}

//+------------------------------------------------------------------+
//| The clock                                                         |
//|                                                                   |
//| Preferred and default: MqlTick.time_msc, the broker's own stamp.   |
//| Nothing beats it, because it is the frame the quote was generated  |
//| in, and while it carries real sub-second information it is the     |
//| only clock this system touches.                                    |
//|                                                                   |
//| Some feeds - MT4 especially - fill time_msc by multiplying whole   |
//| seconds by a thousand. Every stamp then ends in three zeros,       |
//| consecutive ticks tie, and dt is exactly zero rather than merely   |
//| noisy. Simulated against a feed of that kind the estimator still   |
//| recovers velocity, but reports a span that is fiction (16 s where  |
//| the true window is 0.64 s) and error bars about an order of        |
//| magnitude too tight. Reporting a confident number for something    |
//| the feed never transmitted is the one failure this whole design    |
//| exists to prevent.                                                 |
//|                                                                   |
//| So the server clock is probed for CLOCK_PROBE_TICKS ticks. If it   |
//| carries real milliseconds, it is used and nothing else is. If it   |
//| does not, GetMicrosecondCount() supplies INTERVALS only, anchored  |
//| to the server stamp so absolute values stay in the broker's frame, |
//| and ordering, gap detection and session breaks still follow it.    |
//|                                                                   |
//| WHAT THE FALLBACK COSTS, stated plainly because the panel cannot   |
//| say it in one line: the local counter measures when a tick ARRIVED |
//| at this terminal, not when the quote changed at the broker. The    |
//| difference is network latency, and its jitter enters as noise in   |
//| the TIME axis. Least squares assumes the abscissa is exact, so     |
//| that noise is an errors-in-variables problem which the random-walk |
//| error floor does not cover: under the fallback the error bars are  |
//| optimistic by an amount this code cannot measure. The panel names  |
//| the live clock on every repaint so this is never invisible.        |
//+------------------------------------------------------------------+
double ClockMs(const double serverMs)
{
   if(nwclock == CLOCK_RATE)  return RateStamp(serverMs);
   if(nwclock != CLOCK_LOCAL) return serverMs;

#ifndef USE_LOCAL_INTERVAL_CLOCK
   return serverMs;              // counter unavailable; never selected
#else
   double lm = (double)GetMicrosecondCount() / 1000.0;

   //--- the counter runs from terminal start, so a restart sends it
   //--- backwards. Re-anchor; the returned value then jumps back to
   //--- the server stamp and the caller's gap test resets the state.
   if(lm < nwlocalAnchorMs)
   {
      nwlocalAnchorMs = lm;
      nwlocalBaseMs   = serverMs;
   }

   nwdriftLocMs = lm       - nwlocalAnchorMs;
   nwdriftSrvMs = serverMs - nwlocalBaseMs;
   return nwlocalBaseMs + nwdriftLocMs;
#endif
}

//+------------------------------------------------------------------+
//| Judge the server clock once, on the evidence of the probe.        |
//+------------------------------------------------------------------+
void DecideClock(const double serverMs)
{
   nwprobeRound = (nwticks > 0.0 ? nwmscRound / nwticks : 0.0);
   nwprobeTie   = (nwticks > 0.0 ? nwties     / nwticks : 0.0);

   bool degenerate = (nwprobeRound > CLOCK_ROUND_FRAC ||
                      nwprobeTie   > CLOCK_TIE_FRAC);

   if(degenerate)
   {
      nwclock = FALLBACK_CLOCK;

#ifdef USE_LOCAL_INTERVAL_CLOCK
      if(nwclock == CLOCK_LOCAL)
      {
         nwlocalAnchorMs = (double)GetMicrosecondCount() / 1000.0;
         nwlocalBaseMs   = serverMs;
         nwdriftLocMs    = 0.0;
         nwdriftSrvMs    = 0.0;
      }
#else
      //--- no local counter on this build, so the broker-frame clock
      //--- is the only fallback available
      if(nwclock == CLOCK_LOCAL) nwclock = CLOCK_RATE;
#endif

      ResetAll();          // anything fitted on the bad clock is void
      Print("NewtonianMechanics: server time_msc carries no sub-second ",
            "information (msc%1000==0 on ", DoubleToString(nwprobeRound*100.0,1),
            "% of ticks). Falling back to ",
            (nwclock == CLOCK_RATE ? "the tick-rate clock (broker frame; "
                                     "sub-second timing is interpolated, not "
                                     "measured, and the fast rung is unreliable "
                                     "when arrivals are bursty)"
                                   : "GetMicrosecondCount (arrival times, not "
                                     "broker generation times)"), ".");
      return;
   }


   nwclock = CLOCK_SERVER;
}


//+------------------------------------------------------------------+
void BuildSpread()
{
   for(int r = 0; r < NRUNG; r++)
   {
      Spread[r].Clear();
      Spread[r].target   = TARGET_NEFF[r];
      Spread[r].effFloor = EFF_FLOOR[r];
      if(!BidSide.kin[r].valid || !AskSide.kin[r].valid) continue;

      Spread[r].valid   = true;
      Spread[r].pos     = AskSide.kin[r].pos - BidSide.kin[r].pos;
      Spread[r].vel     = AskSide.kin[r].vel - BidSide.kin[r].vel;
      Spread[r].acc     = AskSide.kin[r].acc - BidSide.kin[r].acc;

      //--- the two sides are fitted on disjoint event streams, so
      //--- treating them as independent is the appropriate bound
      Spread[r].seVel   = MathSqrt(BidSide.kin[r].seVel*BidSide.kin[r].seVel
                                 + AskSide.kin[r].seVel*AskSide.kin[r].seVel);
      Spread[r].seAcc   = MathSqrt(BidSide.kin[r].seAcc*BidSide.kin[r].seAcc
                                 + AskSide.kin[r].seAcc*AskSide.kin[r].seAcc);
      Spread[r].covVA   = BidSide.kin[r].covVA + AskSide.kin[r].covVA;
      Spread[r].zVel    = (Spread[r].seVel > 0.0 ? Spread[r].vel/Spread[r].seVel : 0.0);
      Spread[r].zAcc    = (Spread[r].seAcc > 0.0 ? Spread[r].acc/Spread[r].seAcc : 0.0);
      Spread[r].neff    = MathMin(BidSide.kin[r].neff, AskSide.kin[r].neff);
      Spread[r].spanSec = MathMax(BidSide.kin[r].spanSec, AskSide.kin[r].spanSec);
      Spread[r].typSpeed = SpreadStep[r].TypicalSpeed();
      Spread[r].eff      = (nwspPath[r] > 0.0 ? MathAbs(nwspNet[r]) / nwspPath[r] : 0.0);
      Spread[r].effFloor = EFF_FLOOR[r];
   }
}

//+------------------------------------------------------------------+
//| Fill the legacy Tick facade from the nominated rung.              |
//|                                                                   |
//| Called once per tick, after Refresh() and BuildSpread(), so every  |
//| field is the current instant's value and the spread fields obey    |
//| spreadVelocity == askVelocity - bidVelocity exactly.               |
//+------------------------------------------------------------------+
void UpdateTickFacade(const MqlTick &t, const double ms)
{
   int r = LEGACY_RUNG;

   Tick.time   = ms * 0.001;          // server seconds, never local
   Tick.bid    = t.bid;
   Tick.ask    = t.ask;
   Tick.spread = t.ask - t.bid;
   Tick.spreadPts = Tick.spread / nwpoint;

   //--- each side's own interval and its own last move. No floor: if a
   //--- side has not yet produced a nonzero interval, deltaTime is zero
   //--- and the derived deltaVelocity is zero, which is the truth. The
   //--- original substituted 1e-4 here and every velocity downstream
   //--- became an artifact of that constant.
   Tick.bidDeltaTime  = BidSide.lastDtMs * 0.001;
   Tick.askDeltaTime  = AskSide.lastDtMs * 0.001;
   Tick.bidDeltaPrice = BidSide.lastDxPts;
   Tick.askDeltaPrice = AskSide.lastDxPts;

   Tick.bidReady = BidSide.kin[r].valid;
   Tick.askReady = AskSide.kin[r].valid;

   Tick.bidVelocity      = BidSide.kin[r].vel;
   Tick.askVelocity      = AskSide.kin[r].vel;
   Tick.bidAcceleration  = BidSide.kin[r].acc;
   Tick.askAcceleration  = AskSide.kin[r].acc;

   Tick.bidVelocityZ     = BidSide.kin[r].zVel;
   Tick.askVelocityZ     = AskSide.kin[r].zVel;
   Tick.bidAccelerationZ = BidSide.kin[r].zAcc;
   Tick.askAccelerationZ = AskSide.kin[r].zAcc;

   //--- the velocity change the fit implies over that side's own last
   //--- interval. One fit, one stencil: not a difference of differences.
   Tick.bidDeltaVelocity = Tick.bidAcceleration * Tick.bidDeltaTime;
   Tick.askDeltaVelocity = Tick.askAcceleration * Tick.askDeltaTime;

   Tick.spreadVelocity      = Spread[r].vel;
   Tick.spreadAcceleration  = Spread[r].acc;
   Tick.spreadVelocityZ     = Spread[r].zVel;
   Tick.spreadAccelerationZ = Spread[r].zAcc;
}

//+------------------------------------------------------------------+
//| The Comment line: your command, every field paired bid/ask.       |
//+------------------------------------------------------------------+
string LegacyLine()
{
   return reading +
      " | bidVelocity >> "       + DoubleToString(Tick.bidVelocity,      5) +
      "  askVelocity >> "        + DoubleToString(Tick.askVelocity,      5) +
      " || bidAcceleration >> "  + DoubleToString(Tick.bidAcceleration,  5) +
      "  askAcceleration >> "    + DoubleToString(Tick.askAcceleration,  5) +
      " | bidTimeChange >> "     + DoubleToString(Tick.bidDeltaTime,     4) +
      "  askTimeChange >> "      + DoubleToString(Tick.askDeltaTime,     4) +
      " | bidPriceChange >> "    + DoubleToString(Tick.bidDeltaPrice,    1) +
      "  askPriceChange >> "     + DoubleToString(Tick.askDeltaPrice,    1) +
      " | bidVelocityChange >> " + DoubleToString(Tick.bidDeltaVelocity, 5) +
      "  askVelocityChange >> "  + DoubleToString(Tick.askDeltaVelocity, 5);
}

//+------------------------------------------------------------------+
//| MARKET PHASE                                                      |
//|                                                                   |
//| Built on the SLOW rung, not the fast one. That is a measurement    |
//| result, not a preference: at the driftless-p95 efficiency          |
//| threshold, a drift of 0.25x the per-event noise is detected 16% of |
//| the time at n=16, 51% at n=64 and 98% at n=256. The fast rung is   |
//| nearly blind to expansion. Wanting an earlier signal does not make |
//| one available.                                                     |
//|                                                                   |
//| What each state means in terms of what was actually measured:      |
//|                                                                   |
//|  EXPANSION     both sides efficient above the driftless floor and  |
//|                moving the same way. Price is travelling, not       |
//|                churning.                                           |
//|  RETRACEMENT   the slow rung is still efficient and directional,   |
//|                but the fast rung opposes it. A pullback inside a   |
//|                larger move, not its end.                           |
//|  STRESSED      spread elevated and efficiency LOW. Lots of motion  |
//|                going nowhere: the widening is not delivering       |
//|                displacement. This is the state most easily         |
//|                mistaken for expansion, and separating them is what |
//|                efficiency is for.                                  |
//|  CONSOLIDATION efficiency below floor on both sides and speed at   |
//|                or under normal. Nothing is happening.              |
//|  UNDETERMINED  the evidence does not pick a state. Reported as     |
//|                itself rather than forced into one of the others.   |
//|                                                                   |
//| There is deliberately NO reversal state. Calling a reversal needs  |
//| the slow rung to change sign, and at tick scale from bid, ask and  |
//| time alone that is not reliably detectable. A state that misfires  |
//| is worse than an absent one.                                       |
//|                                                                   |
//| NOTE ON ATTRIBUTION: this reads your broker's quote stream. A      |
//| widening spread is that broker repricing, which reflects but is    |
//| not identical to interbank liquidity. The measurement is real; any |
//| claim about who stepped back is a model on top of it.              |
//+------------------------------------------------------------------+

int       nwphase      = PHASE_WARMING;   // committed state, read this
int       nwphaseRaw   = PHASE_WARMING;   // this tick's unfiltered read
int       nwphaseCount = 0;               // ticks the raw state has held
double    nwphaseSince = 0.0;             // server ms the state committed
double    nwlastSpPts  = 0.0;

string PhaseName(const int p)
{
   if(p == PHASE_EXPANSION)     return "EXPANSION";
   if(p == PHASE_RETRACEMENT)   return "RETRACEMENT";
   if(p == PHASE_STRESSED)      return "STRESSED";
   if(p == PHASE_CONSOLIDATION) return "CONSOLIDATION";
   if(p == PHASE_WARMING)       return "WARMING";
   return "UNDETERMINED";
}

//--- this tick's unfiltered read, before persistence is applied
int PhaseRaw()
{
   int R = NRUNG - 1;                      // the slow rung: see header
   if(!BidSide.kin[R].valid || !AskSide.kin[R].valid) return PHASE_WARMING;

   double fl  = EFF_FLOOR[R];
   bool efficient = (BidSide.kin[R].eff > fl && AskSide.kin[R].eff > fl);
   bool sameWay   = (BidSide.kin[R].vel * AskSide.kin[R].vel > 0.0);

   double spBase = (nwspW > 0.0 ? nwspS / nwspW : 0.0);
   double spRel  = (spBase > 0.0 ? nwlastSpPts / spBase : 1.0);

   double bt = BidSide.kin[R].typSpeed;
   double spd = (bt > 0.0 ? MathAbs(BidSide.kin[R].vel) / bt : 0.0);

   if(efficient && sameWay)
   {
      //--- fast rung against the slow one: a pullback inside the move
      if(BidSide.kin[0].valid && BidSide.kin[0].vel * BidSide.kin[R].vel < 0.0)
         return PHASE_RETRACEMENT;
      return PHASE_EXPANSION;
   }

   //--- motion without progress
   if(spRel > PHASE_SPREAD_X) return PHASE_STRESSED;

   if(!efficient && spd < 1.0) return PHASE_CONSOLIDATION;

   return PHASE_UNDETERMINED;
}

//--- commit only once a raw state has held for PHASE_PERSIST ticks
void UpdatePhase(const double ms)
{
   int raw = PhaseRaw();

   if(raw == nwphaseRaw) nwphaseCount++;
   else { nwphaseRaw = raw; nwphaseCount = 1; }

   if(raw != nwphase && nwphaseCount >= PHASE_PERSIST)
   {
      nwphase      = raw;
      nwphaseSince = ms;
   }
}

//+------------------------------------------------------------------+
//| DISPLAY 2 of 3 - OBJ_LABEL panel on the right half of the chart   |
//|                                                                   |
//| One label object per line, in a fixed-width font, so numeric       |
//| columns actually line up. Comment() renders in the chart's         |
//| proportional font and cannot do that, which is why this exists     |
//| alongside it rather than replacing it.                             |
//|                                                                   |
//| Anchored at half the chart width, recomputed whenever the window   |
//| is resized, so it occupies the right half at any window size.      |
//| Colour carries meaning: a value below the confidence floor is grey |
//| so the eye skips it, and the phase line takes the phase's colour.  |
//|                                                                   |
//| Objects are hidden from the object list and not selectable, so     |
//| they cannot be dragged off by accident, and every one is deleted   |
//| on OnDeinit.                                                       |
//+------------------------------------------------------------------+
#define PANEL_PREFIX    "TKPanel_"
#define PANEL_FONT      "Consolas"   // any fixed-width font; Courier New also works
#define PANEL_FONTSIZE  8
#define PANEL_LINE_PX   12           // vertical pitch, pixels
#define PANEL_TOP_PX    16
#define PANEL_GUTTER_PX 10           // gap right of the midpoint
#define PANEL_MAXLINES  80

//--- DISPLAY 3 of 3 - Experts log. Throttled far slower than the
//--- screen, and forced immediately on a phase change, so the log
//--- becomes a phase-transition journal rather than a flood. That
//--- journal is the thing worth having: it is the state SEQUENCE, which
//--- no snapshot panel can show.
#define PRINT_MS        5000.0

int    nwpanelN = 0;
string nwpanelTxt[PANEL_MAXLINES];
color  nwpanelClr[PANEL_MAXLINES];
int    nwpanelX = -1;               // cached, so position is only set on resize

double nwlastPrintMs = 0.0;
int    nwprintedPhase = -1;

//+------------------------------------------------------------------+
//| Colour helpers                                                    |
//+------------------------------------------------------------------+
color PhaseColor(int p)
{
   if(p == PHASE_EXPANSION)     return clrLime;
   if(p == PHASE_RETRACEMENT)   return clrGold;
   if(p == PHASE_STRESSED)      return clrOrangeRed;
   if(p == PHASE_CONSOLIDATION) return clrSlateGray;
   return clrGray;                            // warming / undetermined
}

//--- grey below the confidence floor: the number is shown but the eye
//--- is told not to trust it
color ZColor(double z)
{
   if(z >=  CONF_Z) return clrLime;
   if(z <= -CONF_Z) return clrTomato;
   return clrDimGray;
}

color EffColor(double e, double floorE)
{
   if(e > floorE * 2.0) return clrAqua;
   if(e > floorE)       return clrSkyBlue;
   return clrDimGray;
}

//+------------------------------------------------------------------+
//| Line accumulator                                                  |
//+------------------------------------------------------------------+
void PanelClear() { nwpanelN = 0; }

void PanelAdd(string txt, color c)
{
   if(nwpanelN >= PANEL_MAXLINES) return;
   nwpanelTxt[nwpanelN] = txt;
   nwpanelClr[nwpanelN] = c;
   nwpanelN++;
}

//+------------------------------------------------------------------+
//| Build the panel's lines. Same numbers as the Comment panel, laid   |
//| out for a fixed-width font and coloured by confidence.             |
//+------------------------------------------------------------------+
void BuildPanel(double spPts)
{
   PanelClear();

   double spBase = (nwspW > 0.0 ? nwspS / nwspW : spPts);
   double spRel  = (spBase > 0.0 ? spPts / spBase : 1.0);

   PanelAdd(StringFormat("%-10s  bid %s   ask %s",
            nwsymbol, DoubleToString(nwprevBid, nwdigits),
            DoubleToString(nwprevAsk, nwdigits)), clrWhite);

   PanelAdd(StringFormat("spread %5.1f pts   ref %5.2f   %5.2fx",
            spPts, spBase, spRel),
            (spRel > PHASE_SPREAD_X ? clrOrangeRed : clrSilver));

   PanelAdd(StringFormat("pace   %5.0f ms/tick   ticks %.0f",
            Pace(), nwticks), clrSilver);

   PanelAdd(StringFormat("PHASE  %-14s  held %6.1f s",
            PhaseName(nwphase),
            (nwphaseSince > 0.0 ? (nwlastMs - nwphaseSince)/1000.0 : 0.0)),
            PhaseColor(nwphase));

   PanelAdd("--------------------------------------------------", clrDimGray);

   for(int r = 0; r < NRUNG; r++)
   {
      PanelAdd(StringFormat("n=%-4.0f span %6.2f s   floorE %.3f",
               TARGET_NEFF[r],
               MathMax(BidSide.kin[r].spanSec, AskSide.kin[r].spanSec),
               EFF_FLOOR[r]), clrKhaki);

      if(BidSide.kin[r].valid)
         PanelAdd(StringFormat(" bid  v%+8.2f +-%6.2f z%+5.1f   a%+8.1f z%+5.1f",
                  BidSide.kin[r].vel, BidSide.kin[r].seVel, BidSide.kin[r].zVel,
                  BidSide.kin[r].acc, BidSide.kin[r].zAcc), ZColor(BidSide.kin[r].zVel));
      else
         PanelAdd(StringFormat(" bid  warming %5.0f / %.0f",
                  BidSide.kin[r].neff, BidSide.kin[r].target), clrDimGray);

      if(AskSide.kin[r].valid)
         PanelAdd(StringFormat(" ask  v%+8.2f +-%6.2f z%+5.1f   a%+8.1f z%+5.1f",
                  AskSide.kin[r].vel, AskSide.kin[r].seVel, AskSide.kin[r].zVel,
                  AskSide.kin[r].acc, AskSide.kin[r].zAcc), ZColor(AskSide.kin[r].zVel));
      else
         PanelAdd(StringFormat(" ask  warming %5.0f / %.0f",
                  AskSide.kin[r].neff, AskSide.kin[r].target), clrDimGray);

      if(Spread[r].valid)
         PanelAdd(StringFormat(" sprd v%+8.2f +-%6.2f z%+5.1f   a%+8.1f z%+5.1f",
                  Spread[r].vel, Spread[r].seVel, Spread[r].zVel,
                  Spread[r].acc, Spread[r].zAcc), ZColor(Spread[r].zVel));
      else
         PanelAdd(" sprd warming", clrDimGray);

      PanelAdd(StringFormat(" eff  bid %.3f   ask %.3f   sprd %.3f",
               BidSide.kin[r].eff, AskSide.kin[r].eff, Spread[r].eff),
               EffColor(MathMin(BidSide.kin[r].eff, AskSide.kin[r].eff), EFF_FLOOR[r]));

      double btyp = BidSide.kin[r].typSpeed, atyp = AskSide.kin[r].typSpeed;
      double btt  = BidSide.kin[r].TurningTime();
      double att  = AskSide.kin[r].TurningTime();
      PanelAdd(StringFormat(" v/typ bid %+5.2f  ask %+5.2f   turn %s / %s",
               (btyp > 0.0 ? BidSide.kin[r].vel / btyp : 0.0),
               (atyp > 0.0 ? AskSide.kin[r].vel / atyp : 0.0),
               (btt > 0.0 ? StringFormat("%4.1fs", btt) : "   -"),
               (att > 0.0 ? StringFormat("%4.1fs", att) : "   -")), clrSilver);
   }

   PanelAdd("--------------------------------------------------", clrDimGray);

   if(BidSide.kin[0].valid && BidSide.kin[NRUNG-1].valid)
      PanelAdd(StringFormat("term  bid fast %+7.2f  slow %+7.2f",
               BidSide.kin[0].vel, BidSide.kin[NRUNG-1].vel),
               (BidSide.kin[0].vel * BidSide.kin[NRUNG-1].vel > 0.0 ? clrLime : clrGold));
   if(AskSide.kin[0].valid && AskSide.kin[NRUNG-1].valid)
      PanelAdd(StringFormat("      ask fast %+7.2f  slow %+7.2f",
               AskSide.kin[0].vel, AskSide.kin[NRUNG-1].vel),
               (AskSide.kin[0].vel * AskSide.kin[NRUNG-1].vel > 0.0 ? clrLime : clrGold));

   PanelAdd("--------------------------------------------------", clrDimGray);
   PanelAdd("FORECAST SKILL  (out of sample)", clrKhaki);

   for(int r2 = 0; r2 < NRUNG; r2++)
      for(int h = 0; h < NHOR; h++)
      {
         Score lo, hi;
         lo.Clear(); hi.Clear();
         BidSide.PoolInto(r2, h, lo, hi);
         AskSide.PoolInto(r2, h, lo, hi);
         double nAll  = lo.n + hi.n;
         double dnAll = lo.dn + hi.dn;
         double hitA  = (dnAll > 0.0 ? 100.0*(lo.hits + hi.hits)/dnAll : 0.0);
         double r2All = PooledR2(lo, hi);
         PanelAdd(StringFormat(" n=%-4.0f h%.2f  n%5.0f hit%5.1f%% R2%+6.3f | hiZ n%4.0f hit%5.1f%%",
                  TARGET_NEFF[r2], HORIZON_FRAC[h], nAll, hitA, r2All,
                  hi.n, 100.0*hi.HitRate()),
                  (nAll < 30.0 ? clrDimGray : (r2All > 0.0 ? clrLime : clrTomato)));
      }

   PanelAdd("--------------------------------------------------", clrDimGray);

   //--- the clock line decides whether anything above is worth reading
   double tieFrac   = (nwticks > 0.0 ? nwties / nwticks : 0.0);
   double roundFrac = (nwticks > 0.0 ? nwmscRound / nwticks : 0.0);

   if(nwclock == CLOCK_PROBING)
      PanelAdd(StringFormat("clock PROBING  %.0f / %d ticks",
               nwticks, CLOCK_PROBE_TICKS), clrGold);
   else if(nwclock == CLOCK_SERVER)
      PanelAdd(StringFormat("clock SERVER time_msc   dt==0 %.1f%%  resets %.0f",
               tieFrac*100.0, nwresets), clrLime);
   else if(nwclock == CLOCK_RATE)
   {
      double mi = (nwrateTicks > 0.0 ? nwrateMs / nwrateTicks : 0.0);
      PanelAdd(StringFormat("clock TICK-RATE %ds  mean %.0f ms  INTERPOLATED",
               60, mi), clrOrangeRed);
      PanelAdd(" fast rung unreliable if arrivals are bursty", clrOrangeRed);
   }
   else
   {
      double ratio = (nwdriftSrvMs > 1000.0 ? nwdriftLocMs / nwdriftSrvMs : 1.0);
      PanelAdd(StringFormat("clock LOCAL intervals  drift %.4f  ARRIVAL times",
               ratio), clrOrangeRed);
      PanelAdd(" error bars do not cover latency jitter", clrOrangeRed);
   }
}

//+------------------------------------------------------------------+
//| Push the accumulated lines onto label objects.                    |
//+------------------------------------------------------------------+
void PanelPush()
{
   //--- half the chart width, so the block sits in the right half at
   //--- any window size. Recomputed each repaint; positions are only
   //--- written when it actually changed.
   int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int x = (w > 200 ? w/2 + PANEL_GUTTER_PX : 420);
   bool moved = (x != nwpanelX);
   if(moved) nwpanelX = x;

   for(int i = 0; i < PANEL_MAXLINES; i++)
   {
      string nm = PANEL_PREFIX + IntegerToString(i);

      if(i >= nwpanelN)
      {
         if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
         continue;
      }

      if(ObjectFind(0, nm) < 0)
      {
         ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, nm, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
         ObjectSetInteger(0, nm, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
         ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, nm, OBJPROP_SELECTED,   false);
         ObjectSetInteger(0, nm, OBJPROP_HIDDEN,     true);
         ObjectSetInteger(0, nm, OBJPROP_BACK,       false);
         ObjectSetInteger(0, nm, OBJPROP_FONTSIZE,   PANEL_FONTSIZE);
         ObjectSetString (0, nm, OBJPROP_FONT,       PANEL_FONT);
         ObjectSetInteger(0, nm, OBJPROP_YDISTANCE,  PANEL_TOP_PX + i*PANEL_LINE_PX);
         ObjectSetInteger(0, nm, OBJPROP_XDISTANCE,  nwpanelX);
      }
      else if(moved)
         ObjectSetInteger(0, nm, OBJPROP_XDISTANCE,  nwpanelX);

      ObjectSetInteger(0, nm, OBJPROP_COLOR, (long)nwpanelClr[i]);
      ObjectSetString (0, nm, OBJPROP_TEXT,  nwpanelTxt[i]);
   }

   ChartRedraw(0);
}

void PanelDestroy()
{
   for(int i = 0; i < PANEL_MAXLINES; i++)
   {
      string nm = PANEL_PREFIX + IntegerToString(i);
      if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| DISPLAY 3 of 3 - the log.                                         |
//|                                                                   |
//| Fires on every committed phase change, and otherwise at PRINT_MS.  |
//| The phase-change lines are tagged "TK-PHASE" so the log can be     |
//| filtered down to the transition sequence, which is what you need   |
//| to judge whether the classifier is behaving and is exactly what a  |
//| snapshot display cannot give you.                                  |
//+------------------------------------------------------------------+
void PrintState(double ms, double spPts)
{
   bool changed = (nwphase != nwprintedPhase);
   if(!changed && (ms - nwlastPrintMs) < PRINT_MS) return;

   nwlastPrintMs = ms;

   int R = NRUNG - 1;
   double spBase = (nwspW > 0.0 ? nwspS / nwspW : spPts);
   double spRel  = (spBase > 0.0 ? spPts / spBase : 1.0);

   string body = StringFormat(
      "%s bid %s ask %s | sprd %.1f (%.2fx) | n=%.0f bidV %+.2f z%+.1f askV %+.2f z%+.1f"
      " | eff b %.3f a %.3f (floor %.3f) | pace %.0fms | clock %s",
      nwsymbol,
      DoubleToString(nwprevBid, nwdigits), DoubleToString(nwprevAsk, nwdigits),
      spPts, spRel,
      TARGET_NEFF[R],
      BidSide.kin[R].vel, BidSide.kin[R].zVel, AskSide.kin[R].vel, AskSide.kin[R].zVel,
      BidSide.kin[R].eff, AskSide.kin[R].eff, EFF_FLOOR[R],
      Pace(),
      (nwclock == CLOCK_SERVER ? "server" :
       nwclock == CLOCK_RATE   ? "rate"   :
       nwclock == CLOCK_LOCAL  ? "local"  : "probing"));

   if(changed)
   {
      Print("TK-PHASE  ", PhaseName(nwprintedPhase < 0 ? PHASE_WARMING : nwprintedPhase),
            " -> ", PhaseName(nwphase), "  after ",
            DoubleToString((nwphaseSince > 0.0 ? (ms - nwphaseSince)/1000.0 : 0.0), 1),
            "s  |  ", body);
      nwprintedPhase = nwphase;
   }
   else
      Print("TK        ", PhaseName(nwphase), "  |  ", body);
}

//+------------------------------------------------------------------+
void NewtonianTick()
{
   MqlTick t;
   if(!SymbolInfoTick(nwsymbol, t)) return;
   if(t.bid <= 0.0 || t.ask <= 0.0)  return;

   double serverMs = (double)t.time_msc;

   nwticks++;
   if((t.time_msc % 1000) == 0) nwmscRound++;

   //--- judge the server clock once, on the probe's evidence, then
   //--- stay with whatever it decided
   if(nwclock == CLOCK_PROBING && nwticks >= CLOCK_PROBE_TICKS)
      DecideClock(serverMs);

   //--- the live timeline: the broker's stamp, or local intervals
   //--- anchored to it when the broker's stamp carries no sub-second
   //--- information. ClockMs() is called exactly once per tick.
   double ms = ClockMs(serverMs);

   if(!nwhaveClock)
   {
      nwhaveClock = true;
      nwlastMs    = ms;
      nwprevBid   = t.bid; nwprevAsk = t.ask;
      BidSide.Update(t.bid / nwpoint, ms);
      AskSide.Update(t.ask / nwpoint, ms);
      return;
   }

   double dms  = ms - nwlastMs;
   double pace = Pace();

   //--- Discontinuity judged against the market's own pace, never a
   //--- wall-clock constant: thirty seconds of silence is normal at
   //--- 3am and pathological at the open. Backwards time always resets.
   if(dms < 0.0 || (pace > 0.0 && dms > pace * GAP_INTERVAL_X))
   {
      ResetAll();
      nwresets++;
      nwhaveClock = true;
      nwlastMs    = ms;
      nwprevBid   = t.bid; nwprevAsk = t.ask;
      BidSide.Update(t.bid / nwpoint, ms);
      AskSide.Update(t.ask / nwpoint, ms);
      return;
   }

   if(dms == 0.0) nwties++;
   if(dms >  0.0)
   {
      nwpaceW = PACE_RHO * nwpaceW + 1.0;
      nwpaceS = PACE_RHO * nwpaceS + dms;
   }
   nwlastMs = ms;

   //--- Which side actually moved. A tick carrying a stale copy of one
   //--- side is not an observation of that side; feeding it in would
   //--- drag that side's velocity toward zero in proportion to the
   //--- other side's activity. Flags are primary, price comparison is
   //--- the fallback for feeds that do not populate them.
   bool bidMoved = ((t.flags & TICK_FLAG_BID) != 0) || (t.bid != nwprevBid);
   bool askMoved = ((t.flags & TICK_FLAG_ASK) != 0) || (t.ask != nwprevAsk);

   //--- Both sides get their origin advanced to this instant, so both
   //--- fits are evaluated at the same moment and spreadV == askV-bidV
   //--- holds exactly. Only the side that moved is decayed and observed.
   if(bidMoved) BidSide.Update(t.bid / nwpoint, ms); else BidSide.Carry(dms);
   if(askMoved) AskSide.Update(t.ask / nwpoint, ms); else AskSide.Carry(dms);

   nwprevBid = t.bid; nwprevAsk = t.ask;

   //--- the spread's own event stream. It changes when EITHER side
   //--- does, so it is observed here, before the derived channel is
   //--- assembled and while the step estimators are current.
   double spPts = (t.ask - t.bid) / nwpoint;
   if(bidMoved || askMoved)
   {
      double dsp = (nwspEffPrimed ? spPts - nwspLastPts : 0.0);
      for(int sp = 0; sp < NRUNG; sp++)
      {
         SpreadStep[sp].Observe(spPts, ms);
         if(nwspEffPrimed)
         {
            nwspNet[sp]  = nwspEffRho[sp] * nwspNet[sp]  + dsp;
            nwspPath[sp] = nwspEffRho[sp] * nwspPath[sp] + MathAbs(dsp);
         }
      }
      nwspLastPts = spPts; nwspEffPrimed = true;
   }

   //--- stored state, then the derived channel
   BidSide.Refresh();
   AskSide.Refresh();
   BuildSpread();

   //--- legacy facade: Tick.bidVelocity and friends are current from
   //--- here on, for any of your own code that reads them
   reading = (BidSide.kin[LEGACY_RUNG].valid && AskSide.kin[LEGACY_RUNG].valid)
             ? " || Processing Information =>"
             : " || Accumulating Data **";
   UpdateTickFacade(t, ms);

   //--- market phase, committed only after it has held (see header)
   nwlastSpPts = spPts;
   UpdatePhase(ms);

   //--- out-of-sample scoring
   BidSide.ScoreAndPredict(ms);
   AskSide.ScoreAndPredict(ms);

   //--- spread reference level
   nwspW = nwspRho * nwspW + 1.0;
   nwspS = nwspRho * nwspS + spPts;

   if(ms - nwlastReportMs >= REPORT_MS || nwlastReportMs == 0.0)
   {
      nwlastReportMs = ms;

      //--- DISPLAY 1: chart Comment, top-left
#ifdef LEGACY_LINE_ONLY
      Comment(LegacyLine());
#else
      Comment(LegacyLine() + "\n\n" + BuildReport(spPts));
#endif

      //--- DISPLAY 2: label panel, right half of the chart
      BuildPanel(spPts);
      PanelPush();
   }

   //--- DISPLAY 3: Experts log. Its own much slower throttle, and it
   //--- fires immediately on a phase change, so it is checked every
   //--- tick rather than inside the screen-repaint block above.
   PrintState(ms, spPts);
}

//+------------------------------------------------------------------+
//| Display. The value is ALWAYS printed; z is an annotation beside   |
//| it, never a replacement for it.                                   |
//+------------------------------------------------------------------+
string ValV(const double v, const double se, const double z)
{
   return StringFormat("%+8.2f +-%6.2f z%+5.1f", v, se, z);
}

string ValA(const double v, const double se, const double z)
{
   return StringFormat("%+9.1f +-%7.1f z%+5.1f", v, se, z);
}

string Line(const string tag, const KinState &k)
{
   if(!k.valid)
      return StringFormat("  %-4s  warming  %.0f / %.0f\n",
                          tag, k.neff, k.target);
   return "  " + tag + "  v " + ValV(k.vel, k.seVel, k.zVel) +
          "   a " + ValA(k.acc, k.seAcc, k.zAcc) + "\n";
}

string ScoreLine(Score &lo, Score &hi)
{
   string s = StringFormat("  n%5.0f  hit %5.1f%%  R2 %+6.3f   |  hiZ n%5.0f  hit %5.1f%%  R2 %+6.3f",
                           lo.n + hi.n,
                           (lo.n + hi.n > 0.0
                              ? 100.0 * (lo.hits + hi.hits) / MathMax(1.0, lo.dn + hi.dn)
                              : 0.0),
                           PooledR2(lo, hi),
                           hi.n, 100.0 * hi.HitRate(), hi.R2());
   return s;
}

double PooledR2(Score &lo, Score &hi)
{
   double n   = lo.n + hi.n;
   if(n < 2.0) return 0.0;
   double sr  = lo.sr + hi.sr;
   double sr2 = lo.sr2 + hi.sr2;
   double sse = lo.sse + hi.sse;
   double sst = sr2 - (sr*sr)/n;
   if(sst <= 0.0) return 0.0;
   return 1.0 - sse/sst;
}

//+------------------------------------------------------------------+
string BuildReport(const double spPts)
{
   double spBase = (nwspW > 0.0 ? nwspS / nwspW : spPts);
   double spRel  = (spBase > 0.0 ? spPts / spBase : 1.0);

   string s = "TICK KINEMATICS  " + nwsymbol +
              "    bid " + DoubleToString(nwprevBid, nwdigits) +
              "    ask " + DoubleToString(nwprevAsk, nwdigits) + "\n";
   s += StringFormat("spread %.1f pts (ref %.2f, %.2fx)    pace %.0f ms/tick    ticks %I64u\n",
                     spPts, spBase, spRel, Pace(), nwticks);
   s += StringFormat("phase %-14s held %.1f s   (slow rung n=%.0f, floor E=%.3f)\n",
                     PhaseName(nwphase),
                     (nwphaseSince > 0.0 ? (nwlastMs - nwphaseSince)/1000.0 : 0.0),
                     TARGET_NEFF[NRUNG-1], EFF_FLOOR[NRUNG-1]);
   s += "====================================================================\n";

   for(int r = 0; r < NRUNG; r++)
   {
      s += StringFormat("n=%-4.0f  span %.2f s   (bid upd %I64u, ask upd %I64u)\n",
                        TARGET_NEFF[r],
                        MathMax(BidSide.kin[r].spanSec, AskSide.kin[r].spanSec),
                        BidSide.updates, AskSide.updates);

      s += Line("bid ", BidSide.kin[r]);
      s += Line("ask ", AskSide.kin[r]);
      s += Line("sprd", Spread[r]);

      //--- fixed-displacement view and magnitude relative to typical
      double bsv, bsse, bsn, asv, asse, asn;
      bool okBS = BidSide.step[r].Solve(bsv, bsse, bsn);
      bool okAS = AskSide.step[r].Solve(asv, asse, asn);
      double btyp = BidSide.kin[r].typSpeed, atyp = AskSide.kin[r].typSpeed;
      double styp = Spread[r].typSpeed;
      s += StringFormat("  step  bid %s   ask %s    v/typ  bid %+5.2f  ask %+5.2f  sprd %+5.2f    eff  bid %.3f  ask %.3f  (floor %.3f)\n",
                        (okBS ? StringFormat("%+7.2f", bsv) : "   warm"),
                        (okAS ? StringFormat("%+7.2f", asv) : "   warm"),
                        (btyp > 0.0 ? BidSide.kin[r].vel / btyp : 0.0),
                        (atyp > 0.0 ? AskSide.kin[r].vel / atyp : 0.0),
                        (styp > 0.0 ? Spread[r].vel / styp : 0.0),
                        BidSide.kin[r].eff, AskSide.kin[r].eff, EFF_FLOOR[r]);

      //--- turning time and a short projection, both from the same fit
      double btt = BidSide.kin[r].TurningTime();
      double att = AskSide.kin[r].TurningTime();
      double tau = 0.25 * MathMax(BidSide.kin[r].spanSec, AskSide.kin[r].spanSec);
      double bdx = 0.0, bsd = 0.0, adx = 0.0, asd = 0.0;
      if(BidSide.kin[r].valid) BidSide.kin[r].Project(tau, bdx, bsd);
      if(AskSide.kin[r].valid) AskSide.kin[r].Project(tau, adx, asd);

      s += StringFormat("  turn  bid %s   ask %s    proj %.2fs  bid %+6.2f+-%4.2f  ask %+6.2f+-%4.2f\n",
                        (btt > 0.0 ? StringFormat("%5.2fs", btt) : "    -"),
                        (att > 0.0 ? StringFormat("%5.2fs", att) : "    -"),
                        tau, bdx, bsd, adx, asd);
      s += "--------------------------------------------------------------------\n";
   }

   //--- term structure: fast against slow, the more robust read on
   //--- whether a move is building or fading
   if(BidSide.kin[0].valid && BidSide.kin[NRUNG-1].valid &&
      AskSide.kin[0].valid && AskSide.kin[NRUNG-1].valid)
   {
      s += StringFormat("term  bid fast %+6.2f vs slow %+6.2f    ask fast %+6.2f vs slow %+6.2f\n",
                        BidSide.kin[0].vel, BidSide.kin[NRUNG-1].vel,
                        AskSide.kin[0].vel, AskSide.kin[NRUNG-1].vel);
      s += "====================================================================\n";
   }

   //--- forecast skill, out of sample, non-overlapping, bid+ask pooled
   s += "FORECAST SKILL   (out of sample, non-overlapping)\n";
   for(int r = 0; r < NRUNG; r++)
      for(int h = 0; h < NHOR; h++)
      {
         Score lo, hi;
         lo.Clear(); hi.Clear();
         PoolScore(lo, BidSide.slot[r][h].lo); PoolScore(lo, AskSide.slot[r][h].lo);
         PoolScore(hi, BidSide.slot[r][h].hi); PoolScore(hi, AskSide.slot[r][h].hi);
         s += StringFormat("  n=%-4.0f h=%.2f", TARGET_NEFF[r], HORIZON_FRAC[h])
            + ScoreLine(lo, hi) + "\n";
      }

   s += "====================================================================\n";
   double tieFrac   = (nwticks > 0 ? (double)nwties     / (double)nwticks : 0.0);
   double roundFrac = (nwticks > 0 ? (double)nwmscRound / (double)nwticks : 0.0);
   s += ClockReport(tieFrac, roundFrac);

   return s;
}

//+------------------------------------------------------------------+
//| Which clock produced every number above. Always shown, never      |
//| optional: a reader who does not know this cannot judge the rest.  |
//+------------------------------------------------------------------+
string ClockReport(const double tieFrac, const double roundFrac)
{
   if(nwclock == CLOCK_PROBING)
      return StringFormat("clock: PROBING server time_msc  %.0f / %d ticks\n",
                          (double)nwticks, CLOCK_PROBE_TICKS);

   if(nwclock == CLOCK_SERVER)
   {
      string s = StringFormat("clock: SERVER time_msc   dt==0 %.1f%%   msc%%1000==0 %.1f%%   resets %.0f\n",
                              tieFrac * 100.0, roundFrac * 100.0, (double)nwresets);
      if(tieFrac > CLOCK_TIE_FRAC)
         s += "NOTE: ties have risen since the probe (batched delivery).\n";
      return s;
   }

   //--- CLOCK_RATE
   if(nwclock == CLOCK_RATE)
   {
      double mi = (nwrateTicks > 0.0 ? nwrateMs / nwrateTicks : 0.0);
      string s = StringFormat("clock: TICK-RATE interpolation, %d s window  (server stamp was seconds*1000: msc%%1000==0 on %.1f%% of probe)\n",
                              60, nwprobeRound * 100.0);
      s += StringFormat("       mean interval %.1f ms  (%.1f ticks/s), broker frame throughout\n",
                        mi, (mi > 0.0 ? 1000.0/mi : 0.0));
      s += "       sub-second timing is INTERPOLATED from tick count, not\n";
      s += "       measured. Uniform arrival inside a second is assumed and\n";
      s += "       CANNOT be checked from a feed that reports only seconds.\n";
      s += StringFormat("       measured bias when arrivals are bursty:  n=%.0f -84%%   n=%.0f -11%%   n=%.0f -0.5%%\n",
                        TARGET_NEFF[0], TARGET_NEFF[1], TARGET_NEFF[2]);
      s += StringFormat("       treat n=%.0f as unreliable here; the slow rungs are sound.\n",
                        TARGET_NEFF[0]);
      s += StringFormat("       dt==0 %.1f%%   resets %.0f\n", tieFrac * 100.0, (double)nwresets);
      return s;
   }

   //--- CLOCK_LOCAL
   double ratio = (nwdriftSrvMs > 1000.0 ? nwdriftLocMs / nwdriftSrvMs : 1.0);
   string s = StringFormat("clock: LOCAL INTERVALS via GetMicrosecondCount  (server stamp was seconds*1000: msc%%1000==0 on %.1f%% of probe)\n",
                           nwprobeRound * 100.0);
   s += "       intervals are ARRIVAL times at this terminal, not broker\n";
   s += "       generation times. Latency jitter enters the TIME axis and\n";
   s += "       the error bars above do NOT cover it.\n";
   s += StringFormat("       drift local/server %.4f   dt==0 %.1f%%   resets %.0f\n",
                     ratio, tieFrac * 100.0, (double)nwresets);
   if(nwdriftSrvMs > 60000.0 && (ratio < 0.98 || ratio > 1.02))
      s += "WARNING: local and server clocks are diverging by more than 2%.\n";
   return s;
}

//+------------------------------------------------------------------+
void PoolScore(Score &dst, Score &src)
{
   dst.n   += src.n;   dst.dn  += src.dn;  dst.hits += src.hits;
   dst.sp  += src.sp;  dst.sr  += src.sr;
   dst.sp2 += src.sp2; dst.sr2 += src.sr2;
   dst.spr += src.spr; dst.sse += src.sse;
}
//+------------------------------------------------------------------+

//==================================================================
// PART 2 of 2 - THE EXPERT ADVISOR: inputs, OnInit, OnDeinit, OnTick,
// ReadSignal and DetermineEntry.
//==================================================================

//--- inputs
input double InpMinZ        = 2.0;   // |z| a velocity needs to count as real
input bool   InpLogSignals  = true;  // print a line when the signal changes
input int    InpEntryRung   = 1;     // window used for the entry: 0 fast, 1 middle, 2 slow
input double InpHorizonFrac = 0.5;   // look-ahead, as a fraction of that window's span
input double InpPullbackSE  = 0.0;   // 0 = enter at the current quote; >0 = limit this many
                                     // standard errors behind it
input double InpMinEdge     = 1.0;   // projected move must exceed spread by this factor

//--- signal codes returned by ReadSignal()
#define SIGNAL_NONE   0
#define SIGNAL_UP     1
#define SIGNAL_DOWN  -1

//--- result of DetermineEntry()
struct EntryPlan
{
   int    direction;     // SIGNAL_UP (buy), SIGNAL_DOWN (sell) or SIGNAL_NONE
   double price;         // entry price: ask side for a buy, bid side for a sell
   bool   isLimit;       // false = current quote, true = resting price behind it
   double projected;     // where the fit puts that side after horizonSec
   double band;          // one standard error of that projection, in price units
   double horizonSec;    // look-ahead used, seconds
   string reason;        // why this entry, or why none
};

int nwlastSignal = SIGNAL_NONE;
int nwlastPhase  = -1;

//+------------------------------------------------------------------+
//| Start the engine. Nothing else is needed here.                    |
//+------------------------------------------------------------------+
int OnInit()
{
   int rc = NewtonianInit();
   if(rc != INIT_SUCCEEDED) return rc;

   nwlastSignal = SIGNAL_NONE;
   nwlastPhase  = -1;
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Stop the engine: clears the chart comment and deletes the panel.  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   NewtonianDeinit();
}

//+------------------------------------------------------------------+
//| One call per tick updates every estimate and all three displays.  |
//| Everything read below is current as of this tick.                 |
//+------------------------------------------------------------------+
void OnTick()
{
   NewtonianTick();

   //--- 1. Wait until the fast window is warm on both sides.
   if(!Tick.bidReady || !Tick.askReady) return;

   //--- 2. The simple readings (fast window; units are points and seconds).
   double bidV = Tick.bidVelocity;        // points / second, sign = direction
   double askV = Tick.askVelocity;
   double bidA = Tick.bidAcceleration;    // points / second^2
   double askA = Tick.askAcceleration;
   double sprd = Tick.spreadPts;          // points

   //--- 3. The same readings from the slow window, with error bars.
   int R = NRUNG - 1;
   bool   slowReady = (BidSide.kin[R].valid && AskSide.kin[R].valid);
   double slowBidV  = BidSide.kin[R].vel;
   double slowBidSE = BidSide.kin[R].seVel;
   double slowBidZ  = BidSide.kin[R].zVel;

   //--- 4. React to a committed phase change.
   if(nwphase != nwlastPhase)
   {
      OnPhaseChange(nwlastPhase, nwphase);
      nwlastPhase = nwphase;
   }

   //--- 5. Turn the readings into a signal. Your trading logic goes here.
   int sig = ReadSignal();
   if(sig != nwlastSignal)
   {
      if(InpLogSignals)
         PrintFormat("Deployment: signal %s | phase %s | bidV %+.2f z%+.1f | askV %+.2f z%+.1f | "
                     "bidA %+.1f askA %+.1f | spread %.1f | slow bidV %s",
                     SignalName(sig), PhaseName(nwphase),
                     bidV, Tick.bidVelocityZ, askV, Tick.askVelocityZ,
                     bidA, askA, sprd,
                     (slowReady ? StringFormat("%+.2f +-%.2f z%+.1f", slowBidV, slowBidSE, slowBidZ)
                                : "warming"));
      nwlastSignal = sig;

      //--- 6. Ask the library where to enter.
      EntryPlan plan;
      if(DetermineEntry(plan))
      {
         if(InpLogSignals)
            PrintFormat("Deployment: ENTRY %s at %s (%s) | projected %s +-%s in %.1f s | %s",
                        SignalName(plan.direction),
                        DoubleToString(plan.price, nwdigits),
                        (plan.isLimit ? "limit" : "current quote"),
                        DoubleToString(plan.projected, nwdigits),
                        DoubleToString(plan.band, nwdigits),
                        plan.horizonSec, plan.reason);

         //--- place the order here if you build a trading EA, for example
         //--- a market order when !plan.isLimit, or a buy/sell limit at
         //--- plan.price otherwise. This example only reports the plan.
      }
      else if(InpLogSignals && sig != SIGNAL_NONE)
         Print("Deployment: no entry - ", plan.reason);
   }
}

//+------------------------------------------------------------------+
//| Example rule. UP when the market is in EXPANSION and both sides    |
//| are rising with |z| >= InpMinZ; DOWN for the mirror image.         |
//| A demonstration of reading the engine, not a tested strategy.      |
//+------------------------------------------------------------------+
int ReadSignal()
{
   if(nwphase != PHASE_EXPANSION) return SIGNAL_NONE;

   if(Tick.bidVelocityZ >=  InpMinZ && Tick.askVelocityZ >=  InpMinZ) return SIGNAL_UP;
   if(Tick.bidVelocityZ <= -InpMinZ && Tick.askVelocityZ <= -InpMinZ) return SIGNAL_DOWN;

   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Determine an entry price from the library's readings.              |
//|                                                                    |
//| Returns true and fills plan when an entry is available; returns    |
//| false with plan.reason set otherwise.                              |
//|                                                                    |
//| A buy is filled on the ASK and a sell on the BID, so each          |
//| direction uses that side's own fit. There is no mid price.         |
//|                                                                    |
//| Steps:                                                             |
//|  1. Direction comes from ReadSignal().                             |
//|  2. The chosen window projects that side forward by                |
//|     tau = InpHorizonFrac * span:  dx = v*tau + a*tau^2/2,          |
//|     with its standard error (KinState::Project).                   |
//|  3. No entry if the projection points the wrong way, if the fit    |
//|     expects velocity to reach zero inside the horizon, or if the   |
//|     projected move does not exceed InpMinEdge * spread.            |
//|  4. Entry price is the current quote on that side, or, when        |
//|     InpPullbackSE > 0, a limit that many standard errors behind    |
//|     it (below the ask for a buy, above the bid for a sell).        |
//|                                                                    |
//| A demonstration of reading the library, not a tested strategy.     |
//+------------------------------------------------------------------+
bool DetermineEntry(EntryPlan &plan)
{
   plan.direction  = SIGNAL_NONE;
   plan.price      = 0.0;
   plan.isLimit    = false;
   plan.projected  = 0.0;
   plan.band       = 0.0;
   plan.horizonSec = 0.0;
   plan.reason     = "";

   int dir = ReadSignal();
   if(dir == SIGNAL_NONE) { plan.reason = "no signal"; return false; }

   int r = InpEntryRung;
   if(r < 0) r = 0;
   if(r > NRUNG - 1) r = NRUNG - 1;

   //--- the side this direction trades on
   KinState k;
   double   quote;
   if(dir == SIGNAL_UP) { k = AskSide.kin[r]; quote = Tick.ask; }
   else                 { k = BidSide.kin[r]; quote = Tick.bid; }

   if(!k.valid || k.spanSec <= 0.0) { plan.reason = "entry window still warming"; return false; }

   double tau = InpHorizonFrac * k.spanSec;
   if(tau <= 0.0) { plan.reason = "horizon is zero"; return false; }

   double dx = 0.0, sedx = 0.0;          // points
   k.Project(tau, dx, sedx);

   if(dx * dir <= 0.0) { plan.reason = "projection points against the signal"; return false; }

   double turn = k.TurningTime();        // seconds, or -1 if not turning
   if(turn > 0.0 && turn < tau)
   {
      plan.reason = StringFormat("fit expects a turn in %.1f s, inside the %.1f s horizon", turn, tau);
      return false;
   }

   if(MathAbs(dx) < InpMinEdge * Tick.spreadPts)
   {
      plan.reason = StringFormat("projected %.1f pts does not cover %.1fx spread (%.1f pts)",
                                 MathAbs(dx), InpMinEdge, Tick.spreadPts);
      return false;
   }

   double price = quote;
   if(InpPullbackSE > 0.0 && sedx > 0.0)
   {
      price = quote - dir * InpPullbackSE * sedx * nwpoint;
      plan.isLimit = true;
   }

   plan.direction  = dir;
   plan.price      = NormalizePrice(price);
   plan.projected  = NormalizePrice(quote + dx * nwpoint);
   plan.band       = sedx * nwpoint;
   plan.horizonSec = tau;
   plan.reason     = StringFormat("n=%.0f window, v %+.2f pts/s z%+.1f, projected %+.1f +-%.1f pts",
                                  k.target, k.vel, k.zVel, dx, sedx);
   return true;
}

//+------------------------------------------------------------------+
//| Round a price to the symbol's tick size.                          |
//+------------------------------------------------------------------+
double NormalizePrice(const double p)
{
   double ts = SymbolInfoDouble(nwsymbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0.0) return NormalizeDouble(p, nwdigits);
   return NormalizeDouble(MathRound(p / ts) * ts, nwdigits);
}

string SignalName(const int s)
{
   if(s == SIGNAL_UP)   return "UP";
   if(s == SIGNAL_DOWN) return "DOWN";
   return "NONE";
}

//+------------------------------------------------------------------+
//| Called once each time the committed market phase changes.         |
//+------------------------------------------------------------------+
void OnPhaseChange(const int from, const int to)
{
   if(!InpLogSignals) return;
   PrintFormat("Deployment: phase %s -> %s",
               (from < 0 ? "START" : PhaseName(from)), PhaseName(to));
}
//+------------------------------------------------------------------+