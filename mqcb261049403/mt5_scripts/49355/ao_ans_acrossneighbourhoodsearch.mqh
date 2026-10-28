//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_ANS |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/15049

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_ANS_Agent
{
    double c     []; //coordinates
    double cBest []; //best coordinates
    double f;        //fitness
    double fBest;    //best fitness

    void Init (int coords)
    {
      ArrayResize (c,     coords);
      ArrayResize (cBest, coords);
      f     = -DBL_MAX;
      fBest = -DBL_MAX;
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
struct S_Collection
{
    double c []; //coordinates
    double f;    //fitness

    void Init (int coords)
    {
      ArrayResize (c, coords);
      f = -DBL_MAX;
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_ANS : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_ANS () { }
  C_AO_ANS ()
  {
    ao_name = "ANS";
    ao_desc = "Across Neighbourhood Search";
    ao_link = "https://www.mql5.com/ru/articles/15049";

    popSize          = 50;   //population size

    collectionSize   = 100;   //Best solutions collection
    sigma            = 8.0;  //Form of normal distribution
    range            = 1.0;  //Range of values dispersed
    collChoiceProbab = 0.6;  //Collection choice probab

    ArrayResize (params, 5);

    params [0].name = "popSize";          params [0].val = popSize;
    params [1].name = "collectionSize";   params [1].val = collectionSize;
    params [2].name = "sigma";            params [2].val = sigma;
    params [3].name = "range";            params [3].val = range;
    params [4].name = "collChoiceProbab"; params [4].val = collChoiceProbab;
  }

  void SetParams ()
  {
    popSize          = (int)params [0].val;
    collectionSize   = (int)params [1].val;
    sigma            = params      [2].val;
    range            = params      [3].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  int    collectionSize;    //Best solutions collection
  double sigma;             //Form of normal distribution
  double range;             //Range of values dispersed
  double collChoiceProbab;  //Collection choice probab

  S_ANS_Agent agent [];

  private: //-------------------------------------------------------------------
  S_Collection coll     [];
  S_Collection collTemp [];
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_ANS::Init (const double &rangeMinP [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  ArrayResize (coll,     collectionSize * 2);
  ArrayResize (collTemp, collectionSize * 2);
  for (int i = 0; i < collectionSize * 2; i++)
  {
    coll     [i].Init (coords);
    collTemp [i].Init (coords);
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ANS::Moving ()
{
  double val = 0.0;

  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        val = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        val = u.SeInDiSp  (val, rangeMin [c], rangeMax [c], rangeStep [c]);

        agent [i].c     [c] = val;
        agent [i].cBest [c] = val;

        a [i].c [c] = val;
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  double min  = 0.0;
  double max  = 0.0;
  double dist = 0.0;
  int    ind  = 0;
  double r    = 0.0;
  double p    = 0.0;

  for (int i = 0; i < popSize; i++)
  {
    for (int c = 0; c < coords; c++)
    {
      if (u.RNDprobab () < 0.005)
      {
        val = u.GaussDistribution (agent [i].cBest [c], rangeMin [c], rangeMax [c], sigma);
        val = u.SeInDiSp (val, rangeMin [c], rangeMax [c], rangeStep [c]);
      }
      else
      {
        if (u.RNDprobab () < collChoiceProbab)
        {
          do ind = u.RNDminusOne (collectionSize);
          while (coll [ind].f == -DBL_MAX);

          p = agent [i].c   [c];
          r = coll  [ind].c [c];
 
        }
        else
        {
          p = agent [i].c     [c];
          r = agent [i].cBest [c];
        }

        dist = fabs (p - r) * range;
        min  = r - dist;
        max  = r + dist;

        if (min < rangeMin [c]) min = rangeMin [c];
        if (max > rangeMax [c]) max = rangeMax [c];

        val = u.GaussDistribution (r, min, max, sigma);
        val = u.SeInDiSp (val, rangeMin [c], rangeMax [c], rangeStep [c]);
      }
      
      agent [i].c [c] = val;
      a     [i].c [c] = val;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ANS::Revision ()
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
    if (a [i].f > agent [i].fBest)
    {
      agent [i].fBest = a [i].f;
      ArrayCopy (agent [i].cBest, a [i].c, 0, 0, WHOLE_ARRAY);
    }
  }

  //----------------------------------------------------------------------------
  int cnt = 0;
  for (int i = collectionSize; i < collectionSize * 2; i++)
  {
    if (cnt < popSize)
    {
      coll [i].f = agent [cnt].fBest;
      ArrayCopy (coll [i].c, agent [cnt].cBest, 0, 0, WHOLE_ARRAY);
      cnt++;
    }
    else break;
  }

  u.Sorting (coll, collTemp, collectionSize * 2);
}
//——————————————————————————————————————————————————————————————————————————————