//+————————————————————————————————————————————————————————————————————————————+
//|                                                                C_AO_(PO)ES |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/13923

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
class C_AO_PO_ES : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_PO_ES () { }
  C_AO_PO_ES ()
  {
    ao_name = "(PO)ES)";
    ao_desc = "Evolution Strategies";
    ao_link = "https://www.mql5.com/ru/articles/13923";

    popSize       = 100;   //population size

    parentsNumb   = 10;    //number of parents
    mutationPower = 0.025; //mutation power
    sigmaM        = 8.0; //sigma

    ArrayResize (params, 4);

    params [0].name = "popSize";       params [0].val = popSize;

    params [1].name = "parentsNumb";   params [1].val = parentsNumb;
    params [2].name = "mutationPower"; params [2].val = mutationPower;
    params [3].name = "sigmaM";        params [3].val = sigmaM;
  }

  void SetParams ()
  {
    popSize       = (int)params [0].val;

    parentsNumb   = (int)params [1].val;
    if (parentsNumb > popSize) parentsNumb = popSize;
    mutationPower = params      [2].val;
    sigmaM        = params      [3].val;
  }

  bool Init (const double &rangeMinP  [],  //minimum search range
             const double &rangeMaxP  [],  //maximum search range
             const double &rangeStepP [],  //step search
             const int     epochsP = 0);   //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  int    parentsNumb;   //number of parents
  double mutationPower; //mutation power
  double sigmaM;

  private: //-------------------------------------------------------------------

  S_AO_Agent parents []; //parents
  S_AO_Agent pTemp   [];  //temp parents
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_PO_ES::Init (const double &rangeMinP  [],  //minimum search range
                       const double &rangeMaxP  [],  //maximum search range
                       const double &rangeStepP [],  //step search
                       const int     epochsP = 0)    //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (pTemp, popSize);
  ArrayResize (pTemp, popSize);
  ArrayResize (parents, parentsNumb);

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_PO_ES::Moving ()
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
  int    indx = 0;
  double min  = 0.0;
  double max  = 0.0;
  double dist = 0.0;

  for (int i = 0; i < popSize; i++)
  {
    for (int c = 0; c < coords; c++)
    {
      indx = u.RNDintInRange (0, parentsNumb - 1);

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
void C_AO_PO_ES::Revision ()
{
  //----------------------------------------------------------------------------
  int indx = -1;

  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > fB) indx = i;
  }

  if (indx != -1)
  {
    fB = a [indx].f;
    ArrayCopy (cB, a [indx].c, 0, 0, WHOLE_ARRAY);
  }

  //----------------------------------------------------------------------------
  u.Sorting (a, pTemp, popSize);

  for (int i = 0; i < parentsNumb; i++)
  {
    parents [i] = a [i];
  }
}
//——————————————————————————————————————————————————————————————————————————————