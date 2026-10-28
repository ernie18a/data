//+————————————————————————————————————————————————————————————————————————————+
//|                                                                  C_AO_AEFA |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/15162

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_AEFA_Agent
{
    double best_fitness;
    double best_position [];
    double velocity      [];
    double charge;
    double relative_charge;

    void Init (int coords)
    {
      ArrayResize (best_position, coords);
      ArrayResize (velocity,      coords);

      best_fitness    = -DBL_MAX;
      charge          = 0;
      relative_charge = 0;
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_AEFA : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_AEFA () { }
  C_AO_AEFA ()
  {
    ao_name = "AEFA";
    ao_desc = "Artificial Electric Field Algorithm";
    ao_link = ""; //"https://www.mql5.com/ru/articles/15162";

    popSize      = 20;
    K0           = 1000.0;
    alpha        = 10.0;
    particleMass = 100.0;

    ArrayResize (params, 4);

    params [0].name = "popSize";       params [0].val = popSize;
    params [1].name = "K0";            params [1].val = K0;
    params [2].name = "alpha";         params [2].val = alpha;
    params [3].name = "particleMass";  params [3].val = particleMass;
  }

  void SetParams ()
  {
    popSize      = (int)params [0].val;
    K0           = params      [1].val;
    alpha        = params      [2].val;
    particleMass = params      [3].val;
  }

  bool Init (const double &rangeMinP  [],
             const double &rangeMaxP  [],
             const double &rangeStepP [],
             const int     epochsP = 0);

  void Moving ();
  void Revision ();

  //----------------------------------------------------------------------------
  double K0;
  double alpha;
  double particleMass;
  double epsilon;

  S_AEFA_Agent agent [];

  private: //-------------------------------------------------------------------
  int    epochs;
  int    epochNow;
  double K;
  double CalculateK                (int t);
  void   UpdateCharges             (double best, double worst);
  void   CalculateForces           ();
  double CalculateDistance         (const double &x1 [], const double &x2 []);
  void   UpdateVelocityAndPosition (int i);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_AEFA::Init (const double &rangeMinP  [],
                      const double &rangeMaxP  [],
                      const double &rangeStepP [],
                      const int     epochsP = 0)
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  epochs   = epochsP;
  epochNow = 0;

  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  epsilon = 1e-10;

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_AEFA::Moving ()
{
  epochNow++;

  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        a [i].c [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  K            = CalculateK (epochNow);
  double best  = -DBL_MAX;
  double worst =  DBL_MAX;

  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > best)  best  = a [i].f;
    if (a [i].f < worst) worst = a [i].f;
  }

  UpdateCharges   (best, worst);
  CalculateForces ();

  for (int i = 0; i < popSize; i++)
  {
    UpdateVelocityAndPosition (i);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
double C_AO_AEFA::CalculateK (int t)
{
  return K0 * MathExp (-alpha * t / epochs);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_AEFA::UpdateCharges (double best, double worst)
{
  double sum_q = 0;

  for (int i = 0; i < popSize; i++)
  {
    agent [i].relative_charge = MathExp ((a [i].f - worst) / (best - worst));
    sum_q += agent [i].relative_charge;
  }
  for (int i = 0; i < popSize; i++)
  {
    agent [i].charge = agent [i].relative_charge / sum_q;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_AEFA::CalculateForces ()
{
  double force [];
  ArrayResize (force, coords);

  for (int i = 0; i < popSize; i++)
  {
    ArrayInitialize (force, 0);

    for (int j = 0; j < popSize; j++)
    {
      if (i != j)
      {
        double R = CalculateDistance (a [i].c, a [j].c);

        for (int d = 0; d < coords; d++)
        {
          force [d] += u.RNDprobab () * K *
                       (agent [i].charge * agent [j].charge * (agent [j].best_position [d] - a [i].c [d])) /
                       (R * R + epsilon);
        }
      }
    }

    for (int d = 0; d < coords; d++)
    {
      agent [i].velocity [d] = force [d] / agent [i].charge;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
double C_AO_AEFA::CalculateDistance (const double &x1 [], const double &x2 [])
{
  double sum = 0;
  for (int d = 0; d < coords; d++)
  {
    sum += (x1 [d] - x2 [d]) * (x1 [d] - x2 [d]);
  }
  return MathSqrt (sum);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_AEFA::UpdateVelocityAndPosition (int i)
{
  for (int d = 0; d < coords; d++)
  {
    double acceleration = (agent [i].charge * agent [i].velocity [d]) / particleMass;

    agent [i].velocity [d] = (u.RNDfromCI (0, 1)) * agent [i].velocity [d] + acceleration;

    a [i].c [d] += agent [i].velocity [d];
    a [i].c [d] = u.SeInDiSp (a [i].c [d], rangeMin [d], rangeMax [d], rangeStep [d]);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_AEFA::Revision ()
{
  int ind = -1;

  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > fB)
    {
      fB = a [i].f;
      ind = i;
    }

    if (a [i].f > agent [i].best_fitness)
    {
      agent [i].best_fitness = a [i].f;
      ArrayCopy (agent [i].best_position, a [i].c, 0, 0, WHOLE_ARRAY);
    }
  }

  if (ind != -1) ArrayCopy (cB, a [ind].c, 0, 0, WHOLE_ARRAY);
}
//——————————————————————————————————————————————————————————————————————————————