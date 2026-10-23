//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_ACS |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/15004

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_D
{
    void Init (int coords)
    {
      ArrayResize (c, coords);
    }
    double c           [];
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
struct S_C
{
    void Init (int coords)
    {
      ArrayResize (c, coords);
    }
    char c             [];
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_ACS : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_ACS () { }
  C_AO_ACS ()
  {
    ao_name = "ACS";
    ao_desc = "Artificial Cooperative Search";
    ao_link = "https://www.mql5.com/ru/articles/15004";

    popSize   = 1;   //population size
    bioProbab = 0.9; //biological interaction probability

    ArrayResize (params, 2);

    params [0].name = "popSize";   params [0].val = popSize;
    params [1].name = "bioProbab"; params [1].val = bioProbab;
  }

  void SetParams ()
  {
    popSize   = (int)params [0].val;
    bioProbab = params      [1].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  double bioProbab; //biological interaction probability

  private: //-------------------------------------------------------------------
  S_D A              [];
  S_D B              [];
  S_D Predator       [];
  S_D Prey           [];

  S_C M              [];

  double YA          [];
  double YB          [];
  double Ypred       [];

  int Key;
  int phase;

  void ArrayShuffle (double &arr []);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_ACS::Init (const double &rangeMinP [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (A,         popSize);
  ArrayResize (B,         popSize);
  ArrayResize (Predator, popSize);
  ArrayResize (Prey,      popSize);

  ArrayResize (M,         popSize);

  for (int i = 0; i < popSize; i++)
  {
    A         [i].Init (coords);
    B         [i].Init (coords);
    Predator [i].Init (coords);
    Prey      [i].Init (coords);

    M         [i].Init (coords);
  }

  ArrayResize (YA,    popSize);
  ArrayResize (YB,    popSize);
  ArrayResize (Ypred, popSize);

  ArrayInitialize (YA,    -DBL_MAX);
  ArrayInitialize (YB,    -DBL_MAX);
  ArrayInitialize (Ypred, -DBL_MAX);

  // Initialization
  for (int i = 0; i < popSize; i++)
  {
    for (int j = 0; j < coords; j++)
    {
      A [i].c [j] = rangeMin [j] + (rangeMax [j] - rangeMin [j]) * u.RNDprobab();
      B [i].c [j] = rangeMin [j] + (rangeMax [j] - rangeMin [j]) * u.RNDprobab();
    }
  }

  phase = 0;

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ACS::Moving ()
{
  //----------------------------------------------------------------------------
  if (phase == 0)
  {
    for (int i = 0; i < popSize; i++) ArrayCopy (a [i].c, A [i].c);

    phase++;
    return;
  }

  //----------------------------------------------------------------------------
  if (phase == 1)
  {
    for (int i = 0; i < popSize; i++) YA [i] = a [i].f;
    for (int i = 0; i < popSize; i++) ArrayCopy (a [i].c, B [i].c);

    phase++;
    return;
  }

  //----------------------------------------------------------------------------
  if (phase == 2)
  {
    for (int i = 0; i < popSize; i++) YB [i] = a [i].f;

    phase++;
  }

  //----------------------------------------------------------------------------
  // Selection
  if (u.RNDprobab () < 0.5)
  {
    for (int i = 0; i < popSize; i++)
    {
      ArrayCopy (Predator [i].c, A [i].c);
    }

    ArrayCopy (Ypred, YA);
    Key = 1;
  }
  else
  {
    for (int i = 0; i < popSize; i++)
    {
      ArrayCopy (Predator [i].c, B [i].c);
    }

    ArrayCopy (Ypred, YB);
    Key = 2;
  }

  if (u.RNDprobab () < 0.5)
  {
    for (int i = 0; i < popSize; i++)
    {
      ArrayCopy (Prey [i].c, A [i].c);
    }
  }
  else
  {
    for (int i = 0; i < popSize; i++)
    {
      ArrayCopy (Prey [i].c, B [i].c);
    }
  }

  // Permutation of Prey
  for (int i = 0; i < popSize; i++)
  {
    ArrayShuffle (Prey [i].c);
  }

  double R;

  if (u.RNDprobab () < 0.5)
  {
    R = 4 * u.RNDprobab () * u.RNDfromCI (-1.0, 1.0);
  }
  else R = 1 / MathExp (4 * MathRand () / 32767.0);

  // Fill binary matrix M with 1s
  for (int i = 0; i < popSize; i++)
  {
    for (int j = 0; j < coords; j++)
    {
      M [i].c [j] = 1;
    }
  }

  // Additional operations with matrix M
  for (int i = 0; i < popSize; i++)
  {
    for (int j = 0; j < coords; j++)
    {
      if (u.RNDprobab () < bioProbab)
      {
        M [i].c [j] = 0;
      }
    }
  }

  for (int i = 0; i < popSize; i++)
  {
    for (int j = 0; j < coords; j++)
    {
      if (u.RNDprobab () < bioProbab)
      {
        M [i].c [j] = 1;
      }
      else
      {
        M [i].c [j] = 0;
      }
    }
  }

  for (int i = 0; i < popSize; i++)
  {
    int sum = 0;

    for (int c = 0; c < coords; c++) sum += M [i].c [c];

    if (sum == coords)
    {
      int j = MathRand () % coords;
      M [i].c [j] = 0;
    }
  }

  // Mutation
  for (int i = 0; i < popSize; i++)
  {
    for (int j = 0; j < coords; j++)
    {
      a [i].c [j] = Predator [i].c [j] + R * (Prey [i].c [j] - Predator [i].c [j]);

      // Crossover
      if (M [i].c [j] > 0)
      {
        a [i].c [j] = Predator [i].c [j];
      }

      // Boundary control
      if (a [i].c [j] < rangeMin [j] || a [i].c [j] > rangeMax [j])
      {
        a [i].c [j] = rangeMin [j] + (rangeMax [j] - rangeMin [j]) * u.RNDprobab ();
      }
    }
  }

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    for (int j = 0; j < coords; j++)
    {
      a [i].c [j] = u.SeInDiSp (a [i].c [j], rangeMin [j], rangeMax [j], rangeStep [j]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ACS::Revision ()
{
  if (phase < 3) return;

  // Selection update
  for (int i = 0; i < popSize; i++)
  {
    double d = a [i].f;

    if (d > Ypred [i])
    {
      ArrayCopy (Predator [i].c, a [i].c);
      Ypred [i] = d;
    }
  }

  if (Key == 1)
  {
    for (int i = 0; i < popSize; i++)
    {
      ArrayCopy (A [i].c, Predator [i].c);
    }

    ArrayCopy (YA, Ypred);
  }
  else
  {
    for (int i = 0; i < popSize; i++)
    {
      ArrayCopy (B [i].c, Predator [i].c);
    }

    ArrayCopy (YB, Ypred);
  }

  ArraySort (Ypred);
  ArrayReverse (Ypred, 0, WHOLE_ARRAY);
  double Ybest = Ypred [0];
  int Ibest = ArrayMaximum (Ypred);

  if (Ybest > fB)
  {
    fB = Ybest;
    ArrayCopy (a [Ibest].c, Predator [Ibest].c);
    ArrayCopy (cB, Predator [Ibest].c);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ACS::ArrayShuffle (double &arr [])
{
  int n = ArraySize (arr);
  for (int i = n - 1; i > 0; i--)
  {
    int j = MathRand () % (i + 1);
    double tmp = arr [i];
    arr [i] = arr [j];
    arr [j] = tmp;
  }
}
//——————————————————————————————————————————————————————————————————————————————
