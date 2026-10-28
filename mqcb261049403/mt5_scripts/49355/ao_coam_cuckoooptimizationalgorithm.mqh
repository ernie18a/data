//+————————————————————————————————————————————————————————————————————————————+
//|                                                                  C_AO_COAm |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/11786

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
class C_AO_COAm : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_COAm () { }
  C_AO_COAm ()
  {
    ao_name = "COAm";
    ao_desc = "Cuckoo Optimization Algorithm M";
    ao_link = "https://www.mql5.com/ru/articles/11786";

    popSize     = 100;   //population size

    nestsNumber  = 40;   //number of cuckoo nests
    koef_pa      = 0.6;  //probability of detection of cuckoo eggs
    koef_alpha   = 0.6;  //step control value
    changeProbab = 0.63; //probability of coordinate change

    ArrayResize (params, 5);

    params [0].name = "popSize";      params [0].val = popSize;

    params [1].name = "nestsNumber";  params [1].val = nestsNumber;
    params [2].name = "koef_pa";      params [2].val = koef_pa;
    params [3].name = "koef_alpha";   params [3].val = koef_alpha;
    params [4].name = "changeProbab"; params [4].val = changeProbab;
  }

  void SetParams ()
  {
    popSize     = (int)params  [0].val;

    nestsNumber  = (int)params [1].val;
    koef_pa      = params      [2].val;
    koef_alpha   = params      [3].val;
    changeProbab = params      [4].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  int    nestsNumber;    //number of cuckoo nests
  double koef_pa;        //probability of detection of cuckoo eggs
  double koef_alpha;     //step control value
  double changeProbab;   //probability of coordinate change

  private: //-------------------------------------------------------------------
  S_AO_Agent nests  []; //nests
  double     v      [];
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_COAm::Init (const double &rangeMinP  [], //minimum search range
                      const double &rangeMaxP  [], //maximum search range
                      const double &rangeStepP [], //step search
                      const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (nests,  nestsNumber);

  for (int i = 0; i < nestsNumber; i++) nests  [i].Init (coords);

  ArrayResize (v, coords);
  for (int i = 0; i < coords; i++) v [i] = (rangeMax [i] - rangeMin [i]) * koef_alpha;

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_COAm::Moving ()
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
  }
  else
  {
    double r1 = 0.0;
    double r2 = 0.0;

    for (int i = 0; i < popSize; i++)
    {
      if (u.RNDprobab () < changeProbab)
      {
        for (int c = 0; c < coords; c++)
        {
          r1 = u.RNDbool () ? 1.0 : -1.0;
          r2 = u.RNDfromCI (1.0, 20.0);

          a [i].c [c] = a [i].c [c] + r1 * v [c] * pow (r2, -2.0);
          a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
        }
      }
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_COAm::Revision ()
{
  int ind = 0;

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    ind = u.RNDminusOne (nestsNumber);

    if (a [i].f > nests [ind].f)
    {
      nests [ind] = a [i];

      if (a [i].f > fB)
      {
        fB = a [i].f;
        ArrayCopy (cB, a [i].c, 0, 0, WHOLE_ARRAY);
      }
    }
    else
    {
      ArrayCopy (a [i].c, nests [ind].c, 0, 0, WHOLE_ARRAY);
    }
  }

  //----------------------------------------------------------------------------
  for (int n = 0; n < nestsNumber; n++)
  {
    if (u.RNDprobab () < koef_pa)
    {
      nests [ind].f = -DBL_MAX;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————
