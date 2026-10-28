//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_GWO |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/11785

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
class C_AO_GWO : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_GWO () { }
  C_AO_GWO ()
  {
    ao_name = "GWO";
    ao_desc = "Grey Wolf Optimizer";
    ao_link = "https://www.mql5.com/ru/articles/11785";

    popSize     = 50;   //population size
    alphaNumber = 10;    //Alpha beta delta number

    ArrayResize (params, 2);

    params [0].name = "popSize";      params [0].val = popSize;
    params [1].name = "alphaNumber";  params [1].val = alphaNumber;
  }

  void SetParams ()
  {
    popSize      = (int)params [0].val;
    alphaNumber  = (int)params [1].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving    ();
  void Revision  ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  int alphaNumber;     //Alpha beta delta number of all wolves

  private: //-------------------------------------------------------------------
  S_AO_Agent aT [];

  void   ReturnToRange (S_AO_Agent &wolf);
  int    epochCount;
  int    epochNow;
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_GWO::Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  epochCount   = epochsP;
  epochNow     = 0;

  ArrayResize (aT, popSize);
  for (int i = 0; i < popSize; i++)
  {
    ArrayResize (aT [i].c, coords);
    aT [i].f = -DBL_MAX;
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_GWO::Moving ()
{
  epochNow++;
  //----------------------------------------------------------------------------
  //space has not been explored yet, then send the wolf in a random direction
  if (!revision)
  {
    for (int w = 0; w < popSize; w++)
    {
      for (int c = 0; c < coords; c++)
      {
        a [w].c [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        a [w].c [c] = u.SeInDiSp  (a [w].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  double aKo  = sqrt (2.0 * (1.0 - (epochNow / epochCount)));
  double r1 = 0.0;
  double r2 = 0.0;

  double Ai = 0.0;
  double Ci = 0.0;
  double Xn = 0.0;

  double min = 0.0;
  double max = 1.0;

  //amega-----------------------------------------------------------------------
  for (int w = alphaNumber; w < popSize; w++)
  {
    Xn = 0.0;

    for (int c = 0; c < coords; c++)
    {
      for (int abd = 0; abd < alphaNumber; abd++)
      {
        r1 = u.RNDfromCI (min, max);
        r2 = u.RNDfromCI (min, max);
        Ai = 2.0 * aKo * r1 - aKo;
        Ci = 2.0 * r2;
        Xn += a [abd].c [c] - Ai * (Ci * a [abd].c [c] - a [w].c [c]);
      }

      a [w].c [c] = Xn /= (double)alphaNumber;
    }

    ReturnToRange (a [w]);
  }

  //alpha, beta, delta----------------------------------------------------------
  for (int w = 0; w < alphaNumber; w++)
  {
    for (int c = 0; c < coords; c++)
    {
      r1 = u.RNDfromCI (min, max);
      r2 = u.RNDfromCI (min, max);

      Ai = 2.0 * aKo * r1 - aKo;
      Ci = 2.0 * r2;

      a [w].c [c] = cB [c] - Ai * (Ci * cB [c] - a [w].c [c]);
    }

    ReturnToRange (a [w]);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_GWO::Revision ()
{
  u.Sorting (a, aT, popSize);

  if (a [0].f > fB)
  {
    fB = a [0].f;
    ArrayCopy (cB, a [0].c, 0, 0, WHOLE_ARRAY);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_GWO::ReturnToRange (S_AO_Agent &wolf)
{
  for (int c = 0; c < coords; c++)
  {
    if (wolf.c [c] < rangeMin [c]) wolf.c [c] = rangeMax [c] - (rangeMin [c] - wolf.c [c]);
    if (wolf.c [c] > rangeMax [c]) wolf.c [c] = rangeMin [c] + (wolf.c [c] - rangeMax [c]);

    wolf.c [c] = u.SeInDiSp (wolf.c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_GWO::Injection (const int popPos, const int coordPos, const double value)
{
  if (popPos   < 0 || popPos   >= popSize) return;
  if (coordPos < 0 || coordPos >= coords)  return;

  if (value < rangeMin [coordPos])
  {
    a [popPos].c [coordPos] = rangeMin [coordPos];
  }

  if (value > rangeMax [coordPos])
  {
    a [popPos].c [coordPos] = rangeMax [coordPos];
  }

  a [popPos].c [coordPos] = u.SeInDiSp (value, rangeMin [coordPos], rangeMax [coordPos], rangeStep [coordPos]);
}
//——————————————————————————————————————————————————————————————————————————————
