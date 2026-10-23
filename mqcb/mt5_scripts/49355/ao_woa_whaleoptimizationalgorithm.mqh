//+————————————————————————————————————————————————————————————————————————————+
//|                                                                  C_AO_WOAm |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/14414

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_WOA_Agent
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
class C_AO_WOAm : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_WOAm () { }
  C_AO_WOAm ()
  {
    ao_name = "WOAm";
    ao_desc = "Whale Optimization Algorithm M";
    ao_link = "https://www.mql5.com/ru/articles/14414";

    popSize     = 100;   //population size

    refProb     = 0.1;
    spiralCoeff = 0.5;
    spiralProb  = 0.8;

    ArrayResize (params, 4);

    params [0].name = "popSize";     params [0].val = popSize;
    params [1].name = "refProb";     params [1].val = refProb;
    params [2].name = "spiralCoeff"; params [2].val = spiralCoeff;
    params [3].name = "spiralProb";  params [3].val = spiralProb;
  }

  void SetParams ()
  {
    popSize     = (int)params [0].val;
    refProb     = params      [1].val;
    spiralCoeff = params      [2].val;
    spiralProb  = params      [3].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  double refProb;     //refinement probability
  double spiralCoeff; //spiral coefficient
  double spiralProb;  //spiral probability


  S_WOA_Agent agent []; //vector

  private: //-------------------------------------------------------------------
  int  epochs;
  int  epochNow;
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_WOAm::Init (const double &rangeMinP [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  epochs   = epochsP;
  epochNow = 0;

  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_WOAm::Moving ()
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
        a [i].c [c] = u.SeInDiSp  (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    for (int c = 0; c < coords; c++)
    {
      double aKo = 2.0 - epochNow * (2.0 / epochs);
      double r = u.RNDfromCI (-1, 1);
      double A = 2.0 * aKo * r - aKo;
      double C = 2.0 * r;
      double b = spiralCoeff;
      double l = u.RNDfromCI (-1, 1);
      double p = u.RNDprobab ();
      double x;

      if (p < refProb)
      {
        if (MathAbs (A) > 1.0)
        {
          x = cB [c] - A * MathAbs (cB [c] - agent [i].cPrev [c]);                                                      //Xbest - A * |Xbest - X|
        }
        else
        {
          int leaderInd = u.RNDminusOne (popSize);
          x = agent [leaderInd].cPrev [c] - A * MathAbs (agent [leaderInd].cPrev [c] - agent [i].cPrev [c]);            //Xlid - A * |Xlid - X|;
        }
      }
      else
      {
        if (u.RNDprobab () < spiralProb)
        {
          x = agent [i].cPrev [c] + MathAbs (agent [i].cPrev [c] - a [i].c [c]) * MathExp (b * l) * cos (2 * M_PI * l); //XbestPrev + |XbestPrev - X| * MathExp (b * l) * cos (2 * M_PI * l)
        }
        else
        {
          x = u.PowerDistribution (cB [c], rangeMin [c], rangeMin [c], 30);
        }
      }

      a [i].c [c] = u.SeInDiSp (x, rangeMin [c], rangeMax [c], rangeStep [c]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_WOAm::Revision ()
{
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
void C_AO_WOAm::Injection (const int popPos, const int coordPos, const double value)
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
