//+————————————————————————————————————————————————————————————————————————————+
//|                                                                  C_AO_ASBO |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/15329

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_ASBO_Agent
{
    double c     [];   //coordinates
    double cBest [];   //best coordinates
    double f;          //fitness
    double fBest;      //best fitness

    double Cg, Cs, Cn; //adaptive parameters
    C_AO_Utilities u;

    void Init (int coords, double &rangeMin [], double &rangeMax [])
    {
      ArrayResize (c,     coords);
      ArrayResize (cBest, coords);
      fBest = -DBL_MAX;
      Cg = u.RNDprobab ();
      Cs = u.RNDprobab ();
      Cn = u.RNDprobab ();

      for (int i = 0; i < coords; i++)
      {
        c     [i] = u.RNDfromCI (rangeMin [i], rangeMax [i]);
        cBest [i] = c [i];
      }

    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
struct S_ASBO_Population
{
    S_ASBO_Agent agent [];
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_ASBO : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_ASBO () { }
  C_AO_ASBO ()
  {
    ao_name = "ASBO";
    ao_desc = "Adaptive Social Behavior Optimization";
    ao_link = "https://www.mql5.com/ru/articles/15329";

    popSize       = 50;   //population size
    numPop        = 5;    //number of populations
    epochsForPop  = 10;   //number of epochs for each population

    ArrayResize (params, 3);

    params [0].name = "popSize";      params [0].val = popSize;
    params [1].name = "numPop";       params [1].val = numPop;
    params [2].name = "epochsForPop"; params [2].val = epochsForPop;
  }

  void SetParams ()
  {
    popSize      = (int)params [0].val;
    numPop       = (int)params [1].val;
    epochsForPop = (int)params [2].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  int numPop;       //number of populations
  int epochsForPop; //number of epochs for each population

  private: //-------------------------------------------------------------------
  int  epochs;
  int  epochNow;
  int  currPop;
  bool isPhase2;
  int  popEpochs;

  double tau;
  double tau_prime;

  S_ASBO_Agent      allAgentsForSortPhase2 [];
  S_ASBO_Agent      allAgentsTemp          [];
  S_ASBO_Agent      agentsPhase2           [];
  S_ASBO_Agent      agentsTemp             [];
  S_ASBO_Population pop                    []; //M populations

  void   AdaptiveMutation   (S_ASBO_Agent &agent);
  void   UpdatePosition     (int ind, S_ASBO_Agent &ag []);
  void   FindNeighborCenter (int ind, S_ASBO_Agent &ag [], double &center []);
  void   Sorting (S_ASBO_Agent &p [], S_ASBO_Agent &pTemp [], int size);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_ASBO::Init (const double &rangeMinP  [], //minimum search range
                      const double &rangeMaxP  [], //maximum search range
                      const double &rangeStepP [], //step search
                      const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  epochs    = epochsP;
  epochNow  = 0;
  currPop   = 0;
  isPhase2  = false;
  popEpochs = 0;

  tau       = 1.0 / MathSqrt (2.0 * coords);
  tau_prime = 1.0 / MathSqrt (2.0 * MathSqrt (coords));

  ArrayResize (pop, numPop);
  for (int i = 0; i < numPop; i++)
  {
    ArrayResize (pop [i].agent, popSize);

    for (int j = 0; j < popSize; j++) pop [i].agent [j].Init (coords, rangeMin, rangeMax);
  }

  ArrayResize (agentsPhase2, popSize);
  ArrayResize (agentsTemp,   popSize);
  for (int i = 0; i < popSize; i++) agentsPhase2 [i].Init (coords, rangeMin, rangeMax);

  ArrayResize (allAgentsForSortPhase2, popSize * numPop);
  ArrayResize (allAgentsTemp,          popSize * numPop);

  for (int i = 0; i < popSize * numPop; i++)
  {
    allAgentsForSortPhase2 [i].Init (coords, rangeMin, rangeMax);
    allAgentsTemp          [i].Init (coords, rangeMin, rangeMax);
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ASBO::Moving ()
{
  epochNow++;

  //Фаза 1----------------------------------------------------------------------
  if (!isPhase2)
  {
    if (popEpochs >= epochsForPop)
    {
      popEpochs = 0;
      currPop++;

      fB = -DBL_MAX;
    }

    if (currPop >= numPop)
    {
      isPhase2 = true;

      int cnt = 0;
      for (int i = 0; i < numPop; i++)
      {
        for (int j = 0; j < popSize; j++)
        {
          allAgentsForSortPhase2 [cnt] = pop [i].agent [j];
          cnt++;
        }
      }

      u.Sorting (allAgentsForSortPhase2, allAgentsTemp, popSize * numPop);

      for (int j = 0; j < popSize; j++) agentsPhase2 [j] = allAgentsForSortPhase2 [j];
    }
    else
    {
      for (int i = 1; i < popSize; i++)
      {
        AdaptiveMutation (pop [currPop].agent [i]);
        UpdatePosition   (i, pop [currPop].agent);

        ArrayCopy (a [i].c, pop [currPop].agent [i].c);
      }

      popEpochs++;
      return;
    }
  }

  //Фаза 2----------------------------------------------------------------------
  for (int i = 1; i < popSize; i++)
  {
    AdaptiveMutation (agentsPhase2 [i]);
    UpdatePosition   (i, agentsPhase2);

    ArrayCopy (a [i].c, agentsPhase2 [i].c);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ASBO::Revision ()
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
  //фаза 1
  if (currPop < numPop)
  {
    for (int i = 0; i < popSize; i++)
    {
      pop [currPop].agent [i].f = a [i].f;

      if (a [i].f > pop [currPop].agent [i].fBest)
      {
        pop [currPop].agent [i].fBest = a [i].f;
        ArrayCopy (pop [currPop].agent [i].cBest, a [i].c, 0, 0, WHOLE_ARRAY);
      }
    }

    u.Sorting (pop [currPop].agent, agentsTemp, popSize);
  }
  //фаза 2
  else
  {
    for (int i = 0; i < popSize; i++)
    {
      agentsPhase2 [i].f = a [i].f;

      if (a [i].f > agentsPhase2 [i].fBest)
      {
        agentsPhase2 [i].fBest = a [i].f;
        ArrayCopy (agentsPhase2 [i].cBest, a [i].c, 0, 0, WHOLE_ARRAY);
      }
    }

    u.Sorting (agentsPhase2, agentsTemp, popSize);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ASBO::AdaptiveMutation (S_ASBO_Agent &ag)
{
  ag.Cg *= MathExp (tau_prime * u.GaussDistribution (0, -1, 1, 1) + tau * u.GaussDistribution (0, -1, 1, 8));
  ag.Cs *= MathExp (tau_prime * u.GaussDistribution (0, -1, 1, 1) + tau * u.GaussDistribution (0, -1, 1, 8));
  ag.Cn *= MathExp (tau_prime * u.GaussDistribution (0, -1, 1, 1) + tau * u.GaussDistribution (0, -1, 1, 8));
}
//——————————————————————————————————————————————————————————————————————————————
/*
//——————————————————————————————————————————————————————————————————————————————
void C_AO_ASBO::AdaptiveMutation (S_ASBO_Agent &ag)
{
  ag.Cg *= MathExp (tau_prime * NormalRandom() + tau * NormalRandom());
  ag.Cs *= MathExp (tau_prime * NormalRandom() + tau * NormalRandom());
  ag.Cn *= MathExp (tau_prime * NormalRandom() + tau * NormalRandom());
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
double NormalRandom()
{
  double u1 = (double)MathRand() / 32767.0;
  double u2 = (double)MathRand() / 32767.0;
  return MathSqrt(-2 * MathLog(u1)) * MathCos(2 * M_PI * u2);
}
//——————————————————————————————————————————————————————————————————————————————
*/
//——————————————————————————————————————————————————————————————————————————————
void C_AO_ASBO::UpdatePosition (int ind, S_ASBO_Agent &ag [])
{
  double deltaX [];
  ArrayResize (deltaX, coords);

  FindNeighborCenter (ind, ag, deltaX);

  for (int j = 0; j < coords; j++)
  {
    /*
    //1)
    deltaX [j] = ag [ind].Cg * u.RNDfromCI (-1, 1) * (cB             [j] - ag [ind].c [j]) +
                 ag [ind].Cs * u.RNDfromCI (-1, 1) * (ag [ind].cBest [j] - ag [ind].c [j]) +
                 ag [ind].Cn * u.RNDfromCI (-1, 1) * (deltaX         [j] - ag [ind].c [j]);
    */
    
    //2)
    deltaX [j] = ag [ind].Cg * (cB             [j] - ag [ind].c [j]) +
                 ag [ind].Cs * (ag [ind].cBest [j] - ag [ind].c [j]) +
                 ag [ind].Cn * (deltaX         [j] - ag [ind].c [j]);


    /*
    //3)
    deltaX [j] = u.GaussDistribution (0, -1, 1, 8) * (cB             [j] - ag [ind].c [j]) +
                 u.GaussDistribution (0, -1, 1, 8) * (ag [ind].cBest [j] - ag [ind].c [j]) +
                 u.GaussDistribution (0, -1, 1, 8) * (deltaX         [j] - ag [ind].c [j]);
    */

    ag [ind].c [j] += deltaX [j];
    ag [ind].c [j] = u.SeInDiSp (ag [ind].c [j], rangeMin [j], rangeMax [j], rangeStep [j]);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ASBO::FindNeighborCenter (int ind, S_ASBO_Agent &ag [], double &center [])
{
  // Создаем массивы для индексов и разниц фитнеса
  int    indices     [];
  double differences [];
  ArrayResize (indices,     popSize - 1);
  ArrayResize (differences, popSize - 1);

  // Заполняем массивы
  int count = 0;
  for (int i = 0; i < popSize; i++)
  {
    if (i != ind)  // Исключаем текущего агента
    {
      indices     [count] = i;
      differences [count] = fabs (ag [ind].f - ag [i].f);
      count++;
    }
  }

  // Сортируем массивы по разнице фитнеса (пузырьковая сортировка)
  for (int i = 0; i < count - 1; i++)
  {
    for (int j = 0; j < count - i - 1; j++)
    {
      if (differences [j] > differences [j + 1])
      {
        // Обмен разниц
        double tempDiff     = differences [j];
        differences [j] = differences [j + 1];
        differences [j + 1] = tempDiff;

        // Обмен индексов
        int tempIndex   = indices [j];
        indices [j] = indices [j + 1];
        indices [j + 1] = tempIndex;
      }
    }
  }

  // Инициализируем центр
  ArrayInitialize (center, 0.0);

  // Вычисляем центр на основе трех ближайших соседей
  int neighborsCount = MathMin (3, count);  // Защита от случая, когда агентов меньше 3
  for (int j = 0; j < coords; j++)
  {
    for (int k = 0; k < neighborsCount; k++)
    {
      int nearestIndex = indices [k];
      center [j] += ag [nearestIndex].c [j];
    }

    if (neighborsCount > 0) center [j] /= neighborsCount;
  }
}
//——————————————————————————————————————————————————————————————————————————————