//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_SIA |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/13870
//

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_SIA_Agent
{
    void Init (int coords)
    {
      ArrayResize (cPrev, coords);
      fPrev = -DBL_MAX;
    }

    double cPrev []; //previous coordinates
    double fPrev;    //previous fitness
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_SIA : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_SIA () { }
  C_AO_SIA ()
  {
    ao_name = "SIA";
    ao_desc = "Simulated Isotropic Annealing";
    ao_link = "https://www.mql5.com/ru/articles/13870";

    popSize = 100;  //population size

    T       = 0.01; //Temperature
    d       = 0.1;  //Diffusion coefficient

    ArrayResize (params, 3);

    params [0].name = "popSize"; params [0].val  = popSize;

    params [1].name  = "T";      params [1].val  = T;
    params [2].name  = "d";      params [2].val  = d;
  }

  void SetParams ()
  {
    popSize = (int)params [0].val;

    T       = params [1].val;
    d       = params [2].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving    ();
  void Revision  ();

  //----------------------------------------------------------------------------
  double T; //Temperature
  double d; //Diffusion coefficient

  S_SIA_Agent agent [];

  private: //-------------------------------------------------------------------
  int    epochs;
  int    epoch;

  double Diffusion (const double value, const double rMin, const double rMax, const double step);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_SIA::Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  epochs = epochsP;
  epoch  = 0;

  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_SIA::Moving ()
{
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
  int    r   = 0;
  double rnd = 0.0;

  for (int i = 0; i < popSize; i++)
  {
    for (int c = 0; c < coords; c++)
    {
      r = u.RNDminusOne (popSize);

      if (agent [r].fPrev > agent [i].fPrev)
      {
        a [i].c [c] = agent [r].cPrev [c];
      }
      else
      {
        a [i].c [c] = agent [i].cPrev [c];
      }

      rnd = u.RNDfromCI (-0.1, 0.1);
      a [i].c [c] = a [i].c [c] + rnd * (rangeMax [c] - rangeMin [c]) * d;
      a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_SIA::Revision ()
{
  //----------------------------------------------------------------------------
  int ind = -1;

  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > fB)
    {
      fB = a [i].f;
      ind = i;
    }
  }

  if (ind != -1) ArrayCopy (cB, a [ind].c, 0, 0, WHOLE_ARRAY);

  epoch++;

  //----------------------------------------------------------------------------
  double maxD = -DBL_MAX;
  double minD =  DBL_MAX;

  double maxF = -DBL_MAX;
  double minF =  DBL_MAX;

  double ΔE;
  double P;

  for (int i = 0; i < popSize; i++)
  {
    ΔE = fabs (a [i].f - agent [i].fPrev);

    if (ΔE > maxD) maxD = ΔE;
    if (ΔE < minD) minD = ΔE;

    if (a [i].f < minF) minF = a [i].f;
  }

  for (int i = 0; i < popSize; i++)
  {
    ΔE = fabs (a [i].f - agent [i].fPrev);

    if (a [i].f > agent [i].fPrev)
    {
      agent [i].fPrev = a [i].f;
      ArrayCopy (agent [i].cPrev, a [i].c, 0, 0, WHOLE_ARRAY);
    }
    else
    {
      //(1-0.1)*(acosh(-(x^3-3)))/1,765

      double x = u.Scale (epoch, 1, epochs, 0, 1.3, false);

      P = T *(1.0 - (ΔE / maxD)) * (acosh (-(pow (x, 3.0) - 3.0))) / 1.765;

      if (u.RNDprobab () < P)
      {
        agent [i].fPrev = a [i].f;
        ArrayCopy (agent [i].cPrev, a [i].c, 0, 0, WHOLE_ARRAY);
      }
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————