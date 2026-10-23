//+————————————————————————————————————————————————————————————————————————————+
//|                                                                    C_AO_DE |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/13781

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_DE_Agent
{
  double cPrev []; //previous coordinates
  double fPrev;    //previous fitness

  void Init (int coords)
  {
    ArrayResize (cPrev, coords);
    fPrev = -DBL_MAX;
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_DE : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_DE () { }
  C_AO_DE ()
  {
    ao_name = "DE";
    ao_desc = "Differential Evolution";
    ao_link = "https://www.mql5.com/ru/articles/13781";

    popSize     = 50;   //population size

    diffWeight  = 0.2;  //differential weight
    crossProbab = 0.8;  //crossover robability

    ArrayResize (params, 3);

    params [0].name = "popSize";     params [0].val = popSize;

    params [1].name = "diffWeight";  params [1].val = diffWeight;
    params [2].name = "crossProbab"; params [2].val = crossProbab;
  }

  void SetParams ()
  {
    popSize     = (int)params [0].val;

    diffWeight  = params      [1].val;
    crossProbab = params      [2].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  double diffWeight;   //differential weight
  double crossProbab;  //crossover robability

  S_DE_Agent agent [];
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_DE::Init (const double &rangeMinP  [], //minimum search range
                    const double &rangeMaxP  [], //maximum search range
                    const double &rangeStepP [], //step search
                    const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_DE::Moving ()
{
  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        a [i].c [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        a [i].c [c] = u.SeInDiSp  (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  int    r1  = 0;
  int    r2  = 0;
  int    r3  = 0;

  for (int i = 0; i < popSize; i++)
  {
    do r1 = u.RNDminusOne (popSize);
    while (r1 == i);

    do r2 = u.RNDminusOne (popSize);
    while (r2 == i || r2 == r1);

    do r3 = u.RNDminusOne (popSize);
    while (r3 == i || r3 == r1 || r3 == r2);

    for (int c = 0; c < coords; c++)
    {
      if (u.RNDprobab () < crossProbab)
      {
        a [i].c [c] = agent [r1].cPrev [c] + diffWeight * (agent [r2].cPrev [c] - agent [r3].cPrev [c]);
        a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
      else
      {
        a [i].c [c] = agent [i].cPrev [c];
      }
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_DE::Revision ()
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

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > agent [i].fPrev)
    {
      agent [i].fPrev = a [i].f;
      ArrayCopy (agent [i].cPrev, a [i].c, 0, 0, WHOLE_ARRAY);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_DE::Injection (const int popPos, const int coordPos, const double value)
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