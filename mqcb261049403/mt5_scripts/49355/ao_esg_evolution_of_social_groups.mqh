//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_ESG |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                     Copyright 2007-2024, https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/14136

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
class C_AO_ESG  : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_ESG () { }
  C_AO_ESG ()
  {
    ao_name = "ESG";
    ao_desc = "Evolution of Social Groups";
    ao_link = "https://www.mql5.com/ru/articles/14136";

    popSize        = 200;   //population size

    groups         = 100;   //number of groups
    groupRadius    = 0.1;   //group radius
    expansionRatio = 2.0;   //expansion ratio
    power          = 10.0;  //power

    ArrayResize (params, 5);

    params [0].name = "popSize";        params [0].val  = popSize;

    params [1].name = "groups";         params [1].val = groups;
    params [2].name = "groupRadius";    params [2].val = groupRadius;
    params [3].name = "expansionRatio"; params [3].val = expansionRatio;
    params [4].name = "power";          params [4].val = power;
  }

  void SetParams ()
  {
    popSize        = (int)params [0].val;

    groups         = (int)params [1].val;
    groupRadius    = params      [2].val;
    expansionRatio = params      [3].val;
    power          = params      [4].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  int    groups;         //number of groups
  double groupRadius;    //group radius
  double expansionRatio; //expansion ratio
  double power;          //power

  private: //-------------------------------------------------------------------
  struct S_Group
  {
      void Init (int coords, int groupSize)
      {
        ArrayResize (cB, coords);
        fB          = -DBL_MAX;
        sSize       = groupSize;
      }

      double cB [];
      double fB;
      int    sSize;
      double sRadius;
  };

  S_Group gr []; //group
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_ESG::Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  int partInSwarms [];
  ArrayResize (partInSwarms, groups);

  int particles = popSize / groups;
  ArrayInitialize (partInSwarms, particles);

  int lost = popSize - particles * groups;

  if (lost > 0)
  {
    int pos = 0;

    while (true)
    {
      partInSwarms [pos]++;
      lost--;
      pos++;
      if (pos >= groups) pos = 0;
      if (lost == 0) break;
    }
  }

  //----------------------------------------------------------------------------
  ArrayResize (gr, groups);
  for (int s = 0; s < groups; s++) gr [s].Init (coords, partInSwarms [s]);

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ESG::Moving ()
{
  if (!revision)
  {
    int    cnt        = 0;
    double coordinate = 0.0;
    double radius     = 0.0;
    double min        = 0.0;
    double max        = 0.0;

    //сгенерировать центры------------------------------------------------------
    for (int s = 0; s < groups; s++)
    {
      gr [s].sRadius = groupRadius;

      for (int c = 0; c < coords; c++)
      {
        coordinate    = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        gr [s].cB [c] = u.SeInDiSp (coordinate, rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    //сгенерировать индивидумы групп--------------------------------------------
    for (int s = 0; s < groups; s++)
    {
      for (int p = 0; p < gr [s].sSize; p++)
      {
        for (int c = 0; c < coords; c++)
        {
          radius = (rangeMax [c] - rangeMin [c]) * gr [s].sRadius;
          min    = gr [s].cB [c] - radius;
          max    = gr [s].cB [c] + radius;

          if (min < rangeMin [c]) min = rangeMin [c];
          if (max > rangeMax [c]) max = rangeMax [c];

          coordinate    = u.PowerDistribution (gr [s].cB [c], min, max, power);
          a [cnt].c [c] = u.SeInDiSp (coordinate, rangeMin [c], rangeMax [c], rangeStep [c]);
        }

        cnt++;
      }
    }

    revision = true;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ESG::Revision ()
{
  //----------------------------------------------------------------------------
  //Обновить лучшее глобальное решение
  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > fB)
    {
      fB = a [i].f;
      ArrayCopy (cB, a [i].c, 0, 0, WHOLE_ARRAY);
    }
  }

  //----------------------------------------------------------------------------
  int cnt = 0;
  bool impr = false;

  for (int s = 0; s < groups; s++)
  {
    impr = false;

    for (int p = 0; p < gr [s].sSize; p++)
    {
      if (a [cnt].f > gr [s].fB)
      {
        gr [s].fB = a [cnt].f;
        ArrayCopy (gr [s].cB, a [cnt].c, 0, 0, WHOLE_ARRAY);
        impr = true;
      }

      cnt++;
    }

    if (!impr) gr [s].sRadius *= expansionRatio;
    else       gr [s].sRadius  = groupRadius;

    if (gr [s].sRadius > 0.5) gr [s].sRadius = 0.5;
  }

  //сгенерировать индивидумы групп----------------------------------------------
  double coordinate = 0.0;
  double radius     = 0.0;
  double min        = 0.0;
  double max        = 0.0;
  cnt = 0;

  for (int s = 0; s < groups; s++)
  {
    for (int p = 0; p < gr [s].sSize; p++)
    {
      for (int c = 0; c < coords; c++)
      {
        //if (u.RNDprobab () < 1.0)
        {
          radius = (rangeMax [c] - rangeMin [c]) * gr [s].sRadius;
          min    = gr [s].cB [c] - radius;
          max    = gr [s].cB [c] + radius;

          if (min < rangeMin [c]) min = rangeMin [c];
          if (max > rangeMax [c]) max = rangeMax [c];

          coordinate    = u.PowerDistribution (gr [s].cB [c], min, max, power);
          a [cnt].c [c] = u.SeInDiSp (coordinate, rangeMin [c], rangeMax [c], rangeStep [c]);
        }
      }

      cnt++;
    }
  }

  //обмен опытом----------------------------------------------------------------
  cnt = 0;

  for (int s = 0; s < groups; s++)
  {
    for (int c = 0; c < coords; c++)
    {
      int posSw = u.RNDintInRange(0, groups - 1);

      //if (sw [posSw].fB > sw [s].fB)
      {
        a [cnt].c [c] = gr [posSw].cB [c];
      }
    }

    cnt += gr [s].sSize;
  }
}
//——————————————————————————————————————————————————————————————————————————————