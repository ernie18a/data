//+————————————————————————————————————————————————————————————————————————————+
//|                                                                  C_AO_SDSm |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/13540

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_SDS_Agent
{
    int    raddr     []; //restaurant address
    int    raddrPrev []; //previous restaurant address
    double cPrev     []; //previous coordinates (dishes)
    double fPrev;        //previous fitness

    void Init (int coords)
    {
      ArrayResize (cPrev,     coords);
      ArrayResize (raddr,     coords);
      ArrayResize (raddrPrev, coords);
      fPrev    = -DBL_MAX;
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_SDSm : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_SDSm () { }
  C_AO_SDSm ()
  {
    ao_name = "SDSm";
    ao_desc = "Stochastic Diffusion Search M";
    ao_link = "https://www.mql5.com/ru/articles/13540";

    popSize    = 100; //population size

    restNumb   = 100;  //restaurants number
    probabRest = 0.05; //probability restaurant choosing

    ArrayResize (params, 3);

    params [0].name = "popSize";    params [0].val  = popSize;

    params [1].name = "restNumb";   params [1].val  = restNumb;
    params [2].name = "probabRest"; params [2].val  = probabRest;
  }

  void SetParams ()
  {
    popSize    = (int)params [0].val;

    restNumb   = (int)params [1].val;
    probabRest = params      [2].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving    ();
  void Revision  ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  int    restNumb;      //restaurants number
  double probabRest;    //probability restaurant choosing

  S_SDS_Agent agent []; //candidates

  private: //-------------------------------------------------------------------
  struct S_Riverbed //русло реки
  {
      double coordOnSector []; //coordinate on the sector (количество ячеек: количество секторов на координате, значение ячеек: конкретная координата на секторе)
  };

  double restSpace [];      //restaurants space
  S_Riverbed    rb [];      //riverbed

  void Research  (const double  ko,
                  const int     raddr,
                  const double  restSpace,
                  const double  rangeMin,
                  const double  rangeStep,
                  const double  pitOld,
                  double       &pitNew);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_SDSm::Init (const double &rangeMinP  [], //minimum search range
                      const double &rangeMaxP  [], //maximum search range
                      const double &rangeStepP [], //step search
                      const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);

  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  ArrayResize (restSpace, coords);
  ArrayResize (rb,        coords);
  for (int i = 0; i < coords; i++)
  {
    ArrayResize     (rb [i].coordOnSector, restNumb);
    ArrayInitialize (rb [i].coordOnSector, -DBL_MAX);
  }

  for (int i = 0; i < coords; i++)
  {
    restSpace [i] = (rangeMax [i] - rangeMin [i]) / restNumb;
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_SDSm::Moving ()
{
  //----------------------------------------------------------------------------
  if (!revision)
  {
    double min = 0.0;
    double max = 0.0;

    int    n   = 0;
    double dish = 0.0;

    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        n = u.RNDminusOne (restNumb);

        agent [i].raddr     [c] = n;
        agent [i].raddrPrev [c] = n;
        min = rangeMin [c] + restSpace [c] * n;
        max = min + restSpace [c];

        dish = u.RNDfromCI (min, max);

        a [i].c [c] = u.SeInDiSp (dish, min, max, rangeStep [c]);
        a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    revision = true;
  }

  //----------------------------------------------------------------------------
  double min = 0.0;
  double max = 0.0;
  double rnd = 0.0;
  int    n   = 0;

  for (int i = 0; i < popSize; i++)
  {
    for (int c = 0; c < coords; c++)
    {
      n = u.RNDminusOne (popSize);

      if (agent [n].fPrev > agent [i].fPrev)
      {
        agent [i].raddr [c] = agent [n].raddrPrev [c];

        Research (0.25,
                  agent     [i].raddr [c],
                  restSpace [c],
                  rangeMin  [c],
                  rangeStep [c],
                  agent     [n].cPrev [c],
                  a         [i].c     [c]);
      }
      else
      {
        if (u.RNDprobab () < probabRest)
        {
          n                   = u.RNDintInRange (0, restNumb - 1);
          agent [i].raddr [c] = n;

          Research (1.0,
                    agent     [i].raddr         [c],
                    restSpace [c],
                    rangeMin  [c],
                    rangeStep [c],
                    rb        [c].coordOnSector [n],
                    a         [i].c             [c]);
        }
        else
        {
          agent [i].raddr [c] = agent [i].raddrPrev [c];

          Research (0.25,
                    agent     [i].raddr [c],
                    restSpace [c],
                    rangeMin  [c],
                    rangeStep [c],
                    agent     [i].cPrev [c],
                    a         [i].c     [c]);
        }
      }
      
      a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_SDSm::Revision ()
{
  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > fB)
    {
      fB = a [i].f;
      ArrayCopy (cB, a [i].c, 0, 0, WHOLE_ARRAY);

      for (int c = 0; c < coords; c++)
      {
        rb [c].coordOnSector [agent [i].raddr [c]] = a [i].c [c];
      }
    }
  }

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > agent [i].fPrev)
    {
      agent [i].fPrev = a [i].f;
      ArrayCopy (agent [i].cPrev, a [i].c, 0, 0, WHOLE_ARRAY);
      ArrayCopy (agent [i].raddrPrev, agent [i].raddr, 0, 0, WHOLE_ARRAY);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_SDSm::Research (const double  ko,
                          const int     raddr,
                          const double  restSpaceI,
                          const double  rangeMinI,
                          const double  rangeStepI,
                          const double  pitOld,
                          double       &pitNew)
{
  double x = u.RNDfromCI (-1.0, 1.0);
  double y = x * x;
  double pit = pitOld;
  double min = 0.0;
  double max = 0.0;

  double dif = u.Scale (y, 0.0, 1.0, 0.0, restSpaceI * ko, false);

  pit += x > 0.0 ? dif : -dif;

  min = rangeMinI + restSpaceI * raddr;
  max = min + restSpaceI;

  pitNew = u.SeInDiSp (pit, min, max, rangeStepI);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_SDSm::Injection (const int popPos, const int coordPos, const double value)
{
  if (popPos   < 0 || popPos   >= popSize) return;
  if (coordPos < 0 || coordPos >= coords) return;

  if (value < rangeMin [coordPos])
  {
    a     [popPos].c     [coordPos] = rangeMin [coordPos];
    agent [popPos].raddr [coordPos] = 0;
  }

  if (value > rangeMax [coordPos])
  {
    a     [popPos].c     [coordPos] = rangeMax [coordPos];
    agent [popPos].raddr [coordPos] = restNumb - 1;
  }

  a     [popPos].c     [coordPos] = u.SeInDiSp (value, rangeMin [coordPos], rangeMax [coordPos], rangeStep [coordPos]);
  int pos = int((a [popPos].c [coordPos] - rangeMin [coordPos]) / restSpace [coordPos]);
  if (pos >= restNumb) pos = restNumb - 1;
  agent [popPos].raddr [coordPos] = pos;
}
//——————————————————————————————————————————————————————————————————————————————
