//+————————————————————————————————————————————————————————————————————————————+
//|                                                               C_AO_(P_O)ES |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/13923

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_P_O_ES_Agent
{
    double c [];
    double f;
    int    yearsNumber;

    void Init (int coords)
    {
      ArrayResize (c, coords);
      //ArrayInitialize (c, 0);
      f           = -DBL_MAX;
      yearsNumber = 0;
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_P_O_ES : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_P_O_ES () { }
  C_AO_P_O_ES ()
  {
    ao_name = "(P_O)ES)";
    ao_desc = "Evolution Strategies";
    ao_link = "https://www.mql5.com/ru/articles/13923";

    popSize       = 100; //population size

    parentsNumb   = 150; //number of parents
    mutationPower = 0.02; //mutation power
    sigmaM        = 8.0; //sigma
    lifespan      = 200; //lifespan

    ArrayResize (params, 5);

    params [0].name = "popSize";       params [0].val  = popSize;

    params [1].name = "parentsNumb";   params [1].val = parentsNumb;
    params [2].name = "mutationPower"; params [2].val = mutationPower;
    params [3].name = "sigmaM";        params [3].val = sigmaM;
    params [4].name = "lifespan";      params [4].val = lifespan;
  }

  void SetParams ()
  {
    popSize       = (int)params [0].val;

    parentsNumb   = (int)params [1].val;
    mutationPower = params      [2].val;
    sigmaM        = params      [3].val;
    lifespan      = (int)params [4].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  int    parentsNumb;   //number of parents
  double mutationPower; //mutation power
  double sigmaM;
  int    lifespan;

  S_P_O_ES_Agent agent   []; //agent

  private: //-------------------------------------------------------------------
  S_P_O_ES_Agent  parents []; //parents
  S_P_O_ES_Agent  pTemp   []; //temp parents
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_P_O_ES::Init (const double &rangeMinP  [], //minimum search range
                        const double &rangeMaxP  [], //maximum search range
                        const double &rangeStepP [], //step search
                        const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  ArrayResize (parents, popSize + parentsNumb);
  ArrayResize (pTemp,   popSize + parentsNumb);

  for (int i = 0; i < popSize + parentsNumb; i++)
  {
    parents [i].Init (coords);
    pTemp   [i].Init (coords);
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_P_O_ES::Moving ()
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

      agent [i].yearsNumber = 1;
    }

    for (int i = 0; i < popSize + parentsNumb; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        parents [i].c [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        parents [i].c [c] = u.SeInDiSp (parents [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }

      parents [i].yearsNumber = 1;
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  int    indx = 0;
  double min  = 0.0;
  double max  = 0.0;
  double dist = 0.0;

  for (int i = 0; i < popSize; i++)
  {
    for (int c = 0; c < coords; c++)
    {
      while (true)
      {
        indx = u.RNDminusOne (parentsNumb);

        if (parents [indx].f != -DBL_MAX) break;
      }

      a [i].c [c] = parents [indx].c [c];

      dist = (rangeMax [c] - rangeMin [c]) * mutationPower;

      min = a [i].c [c] - dist; if (min < rangeMin [c]) min = rangeMin [c];
      max = a [i].c [c] + dist; if (max > rangeMax [c]) max = rangeMax [c];

      a [i].c [c] = u.GaussDistribution (a [i].c [c], min, max, sigmaM);
      a [i].c [c] = u.SeInDiSp  (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_P_O_ES::Revision ()
{
  //----------------------------------------------------------------------------
  int indx = -1;

  for (int i = 0; i < popSize; i++)
  {
    ArrayCopy (agent [i].c, a [i].c, 0, 0, WHOLE_ARRAY);
    agent [i].f = a [i].f;

    if (a [i].f > fB)
    {
      fB = a [i].f;
      indx = i;
    }
  }

  if (indx != -1) ArrayCopy (cB, a [indx].c, 0, 0, WHOLE_ARRAY);

  //----------------------------------------------------------------------------
  //for (int i = 0; i < parentsNumb; i++)
  for (int i = 0; i < parentsNumb + popSize; i++)
  {
    parents [i].yearsNumber++;

    if (parents [i].yearsNumber > lifespan)
    {
      parents [i].f = -DBL_MAX;
      parents [i].yearsNumber = 0;
    }
  }

  for (int i = parentsNumb; i < parentsNumb + popSize; i++)
  {
    parents [i] = agent [i - parentsNumb];
  }

  u.Sorting (parents, pTemp, parentsNumb + popSize);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_P_O_ES::Injection (const int popPos, const int coordPos, const double value)
{
  if (popPos   < 0 || popPos   >= popSize) return;
  if (coordPos < 0 || coordPos >= coords) return;

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
