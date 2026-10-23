//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_CLA |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/14878

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_CLA_Agent
{
    double f;    //fitness

    struct S_Lock
    {
        int lock [];
    };

    S_Lock code [];


    void Init (int coords, int lockDiscs)
    {
      f = -DBL_MAX;

      ArrayResize (code, coords);

      for (int i = 0; i < coords; i++)
      {
        ArrayResize (code [i].lock, lockDiscs);
      }
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_CLA : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_CLA () { }
  C_AO_CLA ()
  {
    ao_name = "CLA";
    ao_desc = "Code Lock Algorithm";
    ao_link = "https://www.mql5.com/ru/articles/14878";

    popSize     = 100;   //population size

    lockDiscs   = 8;     //lock discs
    copyProb    = 0.8;   //copying probability
    rotateProb  = 0.03;  //rotate disc probability

    ArrayResize (params, 4);

    params [0].name = "popSize";     params [0].val = popSize;

    params [1].name = "lockDiscs";   params [1].val = lockDiscs;
    params [2].name = "copyProb";    params [2].val = copyProb;
    params [3].name = "rotateProb";  params [3].val = rotateProb;
  }

  void SetParams ()
  {
    popSize    = (int)params [0].val;

    lockDiscs  = (int)params [1].val;
    copyProb   = params      [2].val;
    rotateProb = params      [3].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  int    lockDiscs;    //lock discs
  double copyProb;     //copying probability
  double rotateProb;   //rotate disc probability

  S_CLA_Agent agent [];

  private: //-------------------------------------------------------------------
  int maxLockNumber; //max lock number

  S_CLA_Agent parents [];
  S_CLA_Agent parTemp [];

  int    ArrayToNumber (int &arr []);
  double LockToDouble  (int lockNum, int coordPos);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_CLA::Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords, lockDiscs);

  ArrayResize (parents, popSize * 2);
  ArrayResize (parTemp, popSize * 2);

  for (int i = 0; i < popSize * 2; i++)
  {
    parents [i].Init (coords, lockDiscs);
    parTemp [i].Init (coords, lockDiscs);
  }

  maxLockNumber = 0;
  for (int i = 0; i < lockDiscs; i++)
  {
    maxLockNumber += 9 * (int)pow (10, i);
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CLA::Moving ()
{
  double val  = 0.0;
  int    code = 0;
  int    pos  = 0;

  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        for (int l = 0; l < lockDiscs; l++)
        {
          agent [i].code [c].lock [l] = u.RNDminusOne (10);
        }

        code = ArrayToNumber (agent [i].code [c].lock);
        val  = LockToDouble  (code, c);
        a [i].c [c] = u.SeInDiSp  (val, rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    for (int i = 0; i < popSize * 2; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        for (int l = 0; l < lockDiscs; l++)
        {
          parents [i].code [c].lock [l] = u.RNDminusOne (10);
        }
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
      if (u.RNDprobab () < copyProb)
      {
        int pos = u.RNDminusOne (popSize);
        ArrayCopy (agent [i].code [c].lock, parents [pos].code [c].lock, 0, 0, WHOLE_ARRAY);
      }
      else
      {
        for (int l = 0; l < lockDiscs; l++)
        {
          if (u.RNDprobab () < rotateProb)
          {
            //pos = u.RNDminusOne (popSize);
            //agent [i].code [c].lock [l] = (int)round (u.GaussDistribution (agent [i].codePrev [c].lock [l], 0, 9, 8));
            //agent [i].code [c].lock [l] = (int)round (u.PowerDistribution (agent [i].codePrev [c].lock [l], 0, 9, 20));
            agent [i].code [c].lock [l] = u.RNDminusOne (10);
          }
          else
          {
            pos = u.RNDminusOne (popSize);
            agent [i].code [c].lock [l] = parents [pos].code [c].lock [l];
          }
        }
      }

      code = ArrayToNumber (agent [i].code [c].lock);
      val  = LockToDouble  (code, c);
      a [i].c [c] = u.SeInDiSp  (val, rangeMin [c], rangeMax [c], rangeStep [c]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CLA::Revision ()
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
    agent [i].f = a [i].f;
  }

  for (int i = 0; i < popSize; i++)
  {
    parents [i + popSize] = agent [i];
  }

  u.Sorting (parents, parTemp, popSize * 2);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
int C_AO_CLA::ArrayToNumber (int &arr [])
{
  int result = 0;
  for (int i = 0; i < ArraySize (arr); i++)
  {
    result = result * 10 + arr [i];
  }
  return result;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
double C_AO_CLA::LockToDouble (int lockNum, int coordPos)
{
  return u.Scale (lockNum, 0, maxLockNumber, rangeMin [coordPos], rangeMax [coordPos]);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CLA::Injection (const int popPos, const int coordPos, const double value)
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