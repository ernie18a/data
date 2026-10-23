//+————————————————————————————————————————————————————————————————————————————+
//|                                                                  C_AO_ABHA |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/15347

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_ABHA_Agent
{
    enum BeeState
    {
      stateNovice      = 0,    // Состояние новичка
      stateExperienced = 1,    // Состояние опытной пчелы
      stateSearch      = 2,    // Состояние поиска
      stateSource      = 3     // Состояние нахождения источника
    };

    double position        []; // Текущая позиция пчелы
    double bestPosition    []; // Лучшая найденная позиция пчелы
    double direction       []; // Вектор направления движения пчелы
    double cost;               // Качество текущего источника пищи
    double prevCost;           // Качество предыдущего источника пищи
    double bestCost;           // Качество лучшего найденного источника пищи
    double stepSize;           // Коэффициент шагов по всем координатам при движении пчелы
    int    state;              // Текущее состояние пчелы
    int    searchCounter;      // Счетчик действий пчелы в состоянии поиска

    double pab;                // Вероятность оставаться у источника
    double p_si;               // Динамическая Вероятность выбора танца этой пчелы другими пчелами

    double p_srs;              // Вероятность случайного поиска
    double p_rul;              // Вероятность следования танцу
    double p_ab;               // Вероятность отказа от источника

    void Init (int coords, double initStepSize)
    {
      ArrayResize (position,        coords);
      ArrayResize (bestPosition,    coords);
      ArrayResize (direction,       coords);
      cost              = -DBL_MAX;
      prevCost          = -DBL_MAX;
      bestCost          = -DBL_MAX;
      state             = stateNovice;
      searchCounter     = 0;
      pab               = 0;
      p_si              = 0;
      p_srs             = 0;
      p_rul             = 0;
      p_ab              = 0;

      stepSize        = initStepSize;
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_ABHA : public C_AO
{
  public:
  C_AO_ABHA ()
  {
    ao_name = "ABHA";
    ao_desc = "Artificial Bee Hive Algorithm";
    ao_link = "https://www.mql5.com/ru/articles/15347";

    popSize                 = 10;

    maxSearchAttempts       = 10;
    abandonmentRate         = 0.1;
    randomSearchProbability = 0.1;
    stepSizeReductionFactor = 0.99;
    initialStepSize         = 0.5;

    ArrayResize (params, 6);
    params [0].name = "popSize";                 params [0].val = popSize;

    params [1].name = "maxSearchAttempts";       params [1].val = maxSearchAttempts;
    params [2].name = "abandonmentRate";         params [2].val = abandonmentRate;
    params [3].name = "randomSearchProbability"; params [3].val = randomSearchProbability;
    params [4].name = "stepSizeReductionFactor"; params [4].val = stepSizeReductionFactor;
    params [5].name = "initialStepSize";         params [5].val = initialStepSize;
  }

  void SetParams ()
  {
    popSize                 = (int)params [0].val;

    maxSearchAttempts       = (int)params [1].val;
    abandonmentRate         = params      [2].val;
    randomSearchProbability = params      [3].val;
    stepSizeReductionFactor = params      [4].val;
    initialStepSize         = params      [5].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  //----------------------------------------------------------------------------
  int    maxSearchAttempts;
  double abandonmentRate;
  double randomSearchProbability;
  double stepSizeReductionFactor;
  double initialStepSize;

  S_ABHA_Agent agents [];

  private: //-------------------------------------------------------------------
  double avgCost;

  //Типы действий пчел----------------------------------------------------------
  double ActionRandomSearch       (int coordInd);                      //1. Случайный поиск (случайное размещение в диапазоне координат)
  double ActionFollowingDance     (int coordInd, double val);          //2. Следование за танцем (двигаться в направлении танцора)
  double ActionMovingDirection    (S_ABHA_Agent &agent, int coordInd); //3. Перемещение в заданном направлении с шагом
  double ActionHiveVicinity       (int coordInd, double val);          //4. Двигаться в окрестностях источника пищи

  //Действия пчел в различных состояниях----------------------------------------
  void   StageActivityNovice      (S_ABHA_Agent &agent); //действия 1 или 2
  void   StageActivityExperienced (S_ABHA_Agent &agent); //действия 1 или 2 или 4
  void   StageActivitySearch      (S_ABHA_Agent &agent); //действия 3
  void   StageActivitySource      (S_ABHA_Agent &agent); //действия 4

  //Изменение состояния пчел----------------------------------------------------
  void ChangingStateForNovice      (S_ABHA_Agent &agent);
  void ChangingStateForExperienced (S_ABHA_Agent &agent);
  void ChangingStateForSearch      (S_ABHA_Agent &agent);
  void ChangingStateForSource      (S_ABHA_Agent &agent);

  void CalculateProbabilities ();
  void CalculateAverageCost   ();
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_ABHA::Init (const double &rangeMinP  [], //minimum search range
                      const double &rangeMaxP  [], //maximum search range
                      const double &rangeStepP [], //step search
                      const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  ArrayResize (agents, popSize);
  for (int i = 0; i < popSize; i++)
  {
    agents [i].Init (coords, initialStepSize);
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::Moving ()
{
  //----------------------------------------------------------------------------
  if (!revision)
  {
    double val = 0.0;

    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        val = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        val = u.SeInDiSp (val, rangeMin [c], rangeMax [c], rangeStep [c]);

        agents [i].position     [c] = val;
        agents [i].bestPosition [c] = val;
        agents [i].direction    [c] = u.RNDfromCI (-(rangeMax [c] - rangeMin [c]), (rangeMax [c] - rangeMin [c]));

        a [i].c [c] = val;
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    switch (agents [i].state)
    {
      //------------------------------------------------------------------------
      //Новичок
      case S_ABHA_Agent::stateNovice:
      {
        StageActivityNovice (agents [i]);
        break;
      }
        //------------------------------------------------------------------------
        //Опытный
      case S_ABHA_Agent::stateExperienced:
      {
        StageActivityExperienced (agents [i]);
        break;
      }
        //------------------------------------------------------------------------
        //Исследователь
      case S_ABHA_Agent::stateSearch:
      {
        StageActivitySearch (agents [i]);
        break;
      }
        //------------------------------------------------------------------------
        //Эксплуатирующий
      case S_ABHA_Agent::stateSource:
      {
        StageActivitySource (agents [i]);
        break;
      }
    }

    //--------------------------------------------------------------------------
    for (int c = 0; c < coords; c++)
    {
      agents [i].position [c] = u.SeInDiSp (agents [i].position [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      a      [i].c        [c] = agents [i].position [c];
    }
  }

  for (int i = 0; i < popSize; i++) for (int c = 0; c < coords; c++) a [i].c [c] = agents [i].position [c];
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::Revision ()
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
  for (int i = 0; i < popSize; i++) agents [i].cost = a [i].f;

  //----------------------------------------------------------------------------
  //Посчитать вероятности для пчел по текущей стоимости
  CalculateProbabilities ();

  //----------------------------------------------------------------------------
  //Посчитать среднюю стоимость
  CalculateAverageCost ();

  //----------------------------------------------------------------------------
  //обновить состояния пчел (новичок, опытный, исследователь, эксплуатирующий)
  for (int i = 0; i < popSize; i++)
  {
    switch (agents [i].state)
    {
      case S_ABHA_Agent::stateNovice:
      {
        ChangingStateForNovice (agents [i]);
        break;
      }
      case S_ABHA_Agent::stateExperienced:
      {
        ChangingStateForExperienced (agents [i]);
        break;
      }
      case S_ABHA_Agent::stateSearch:
      {
        ChangingStateForSearch (agents [i]);
        break;
      }
      case S_ABHA_Agent::stateSource:
      {
        ChangingStateForSource (agents [i]);
        break;
      }
    }
  }

  //----------------------------------------------------------------------------
  //Обновить стоимости для пчёл
  for (int i = 0; i < popSize; i++)
  {
    if (agents [i].cost > agents [i].bestCost)
    {
      agents [i].bestCost = agents [i].cost;

      ArrayCopy (agents [i].bestPosition, agents [i].position);
    }

    agents [i].prevCost = agents [i].cost;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//Действия 1 или 2
void C_AO_ABHA::StageActivityNovice (S_ABHA_Agent &agent)
{
  double val;

  for (int c = 0; c < coords; c++)
  {
    val = agent.position [c];

    if (u.RNDprobab () < randomSearchProbability) agent.position [c] = ActionRandomSearch   (c);
    else                                          agent.position [c] = ActionFollowingDance (c, val);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//действия 1 или 2 или 4
void C_AO_ABHA::StageActivityExperienced (S_ABHA_Agent &agent)
{
  double rnd = 0;

  for (int c = 0; c < coords; c++)
  {
    rnd = u.RNDprobab ();

    // вероятность случайного поиска
    if (rnd <= agent.p_srs)
    {
      agent.position [c] = ActionRandomSearch (c);
    }
    else
    {
      // Вероятность следования танцу
      if (agent.p_srs < rnd && rnd <= agent.p_rul)
      {
        agent.position [c] = ActionFollowingDance (c, agent.position [c]);
      }
      // Вероятность оставаться у источника
      else
      {
        agent.position [c] = ActionHiveVicinity (c, agent.bestPosition [c]);
      }
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//Действия 3
void C_AO_ABHA::StageActivitySearch (S_ABHA_Agent &agent)
{
  for (int c = 0; c < coords; c++)
  {
    agent.position [c] = ActionMovingDirection (agent, c);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//Действия 4
void C_AO_ABHA::StageActivitySource (S_ABHA_Agent &agent)
{
  double val = 0;

  for (int c = 0; c < coords; c++)
  {
    agent.position [c] = ActionHiveVicinity (c, agent.bestPosition [c]);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————
//1. Случайный поиск (случайное размещение в диапазоне координат)
double C_AO_ABHA::ActionRandomSearch (int coordInd)
{
  return u.RNDfromCI (rangeMin [coordInd], rangeMax [coordInd]);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//2. Следование за танцем (двигаться в направлении танцора)
double C_AO_ABHA::ActionFollowingDance (int coordInd, double val)
{
  //----------------------------------------------------------------------------
  double totalProbability = 0;

  for (int i = 0; i < popSize; i++)
  {
    if (agents [i].state == S_ABHA_Agent::stateExperienced)
    {
      totalProbability += agents [i].p_si;
    }
  }

  //----------------------------------------------------------------------------
  double randomValue = u.RNDprobab () * totalProbability;
  double cumulativeProbability = 0;
  int    ind = -1;

  for (int i = 0; i < popSize; i++)
  {
    if (agents [i].state == S_ABHA_Agent::stateExperienced)
    {
      cumulativeProbability += agents [i].p_si;

      if (cumulativeProbability >= randomValue)
      {
        ind = i;
        break;
      }
    }
  }

  //----------------------------------------------------------------------------
  if (ind == -1)
  {
    return ActionRandomSearch (coordInd);
  }

  double direction = agents [ind].bestPosition [coordInd] - val;
  double noise     = u.RNDfromCI (-1.0, 1.0);

  return val + direction * noise;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//3. Перемещение в заданном направлении с шагом
double C_AO_ABHA::ActionMovingDirection (S_ABHA_Agent &agent, int coordInd)
{
  agent.position [coordInd] += agent.stepSize * agent.direction [coordInd];
  agent.stepSize *= stepSizeReductionFactor;

  return agent.position [coordInd];
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//4. Двигаться в окрестностях источника пищи
double C_AO_ABHA::ActionHiveVicinity (int coordInd, double val)
{
  return u.PowerDistribution (val, rangeMin [coordInd], rangeMax [coordInd], 30);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::ChangingStateForNovice (S_ABHA_Agent &agent)
{
  //Текущая стоимость   : Используется для перехода в состояние либо Опытный либо Исследователь.
  //Предыдущая стоимость: Не используется.
  //Лучшая стоимость    : Не используется.

  //В Опытный. Если новичок получает информацию о высокоприбыльном источнике пищи (например, через танец от других пчел), он может перейти в состояние опытного.
  //В Исследователь. Если новичок не получает информации о источниках пищи, он может начать случайный поиск и перейти в состояние исследователя.

  if (agent.cost > avgCost) agent.state = S_ABHA_Agent::stateExperienced;
  else
  {
    agent.state = S_ABHA_Agent::stateSearch;

    for (int c = 0; c < coords; c++)
    {
      agent.direction [c] = u.RNDfromCI (-(rangeMax [c] - rangeMin [c]), (rangeMax [c] - rangeMin [c]));
    }

    agent.stepSize        = initialStepSize;
    agent.searchCounter   = 0;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::ChangingStateForExperienced (S_ABHA_Agent &agent)
{
  //Текущая стоимость   : Если текущее значение высокое и информация действительна, она может передавать эту информацию другим пчелам через танец.
  //Предыдущая стоимость: Пчела сравнивает текущее значение с предыдущим, чтобы определить, улучшилась ли ситуация. Если текущее значение лучше, это может повысить вероятность передачи информации.
  //Лучшая стоимость    : Пчела может использовать лучшее значение для оценки, стоит ли продолжать исследование данного источника пищи или искать новый.

  //В Исследователь. Если информация о текущем источнике пищи оказывается недостаточно хорошей (например, текущее значение приспособленности ниже порогового), пчела может перейти в состояние исследователя для поиска новых источников.
  //В Эксплуатирующий. Если информация о источнике пищи подтверждается (например, текущее значение приспособленности высокое и стабильное), пчела может перейти в состояние эксплуатирующего для более глубокого анализа источника.

  if (agent.cost < agent.prevCost)
  {
    agent.pab -= abandonmentRate;
    if (agent.pab < 0.0) agent.pab = 0.0;
  }

  if (agent.cost > agent.prevCost)
  {
    agent.pab += abandonmentRate;
    if (agent.pab > 1.0) agent.pab = 1.0;
  }

  if (agent.cost > agent.bestCost) agent.pab = 1.0;

  if (agent.cost > avgCost * 1.2)
  {
    agent.state = S_ABHA_Agent::stateSource;
    agent.pab = 1;
  }
  else
    if (agent.cost < avgCost)
    {
      agent.state = S_ABHA_Agent::stateSearch;

      for (int c = 0; c < coords; c++)
      {
        agent.direction [c] = u.RNDfromCI (-(rangeMax [c] - rangeMin [c]), (rangeMax [c] - rangeMin [c]));
      }

      agent.stepSize        = initialStepSize;
      agent.searchCounter   = 0;
    }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::ChangingStateForSearch (S_ABHA_Agent &agent)
{
  //Текущая стоимость  : Пчела использует текущее значение приспособленности для оценки своего текущего положения и для принятия решения о том, стоит ли продолжать поиск или изменять направление
  //Предыдущее значение: Пчела сравнивает текущее значение с предыдущим, чтобы определить, улучшилось ли положение.Если текущее значение лучше, она может продолжить в том же направлении.
  //Лучшее значение    : Пчела использует лучшее значение для определения, является ли текущий источник пищи более выгодным, чем предыдущие.Это помогает ей принимать решения о том, стоит ли оставаться на месте или продолжать поиск.

  //В Эксплуатирующий. Если исследователь находит источник пищи с хорошими характеристиками (например, текущее значение приспособленности лучше порогового), он может перейти в состояние эксплуатирующего для оценки прибыльности источника.
  //В Новичок. Если исследователь не находит никаких источников пищи или информация оказывается невыгодной, он может вернуться в состояние новичка.

  if (agent.cost < agent.prevCost)
  {
    for (int c = 0; c < coords; c++)
    {
      agent.direction [c] = u.RNDfromCI (-(rangeMax [c] - rangeMin [c]), (rangeMax [c] - rangeMin [c]));
    }

    agent.stepSize = initialStepSize;
    agent.searchCounter++;
  }

  if (agent.cost > agent.bestCost)
  {
    agent.stepSize *= stepSizeReductionFactor;
    agent.searchCounter = 0;
  }

  if (agent.searchCounter >= maxSearchAttempts)
  {
    agent.searchCounter = 0;
    agent.state = S_ABHA_Agent::stateNovice;
    return;
  }

  if (agent.cost > avgCost * 1.2)
  {
    agent.state = S_ABHA_Agent::stateSource;
    agent.pab = 1;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::ChangingStateForSource      (S_ABHA_Agent &agent)
{
  //Текущая стоимость  : Если текущее значение ниже порогового, она может решить, что источник недостаточно хорош и начать поиск нового.
  //Предыдущее значение: Пчела может использовать предыдущее значение для сравнения и определения, улучшилась ли ситуация. Если текущее значение хуже, это может сигнализировать о необходимости изменения стратегии.
  //Лучшее значение    : Пчела использует лучшее значение для принятия решения о том, стоит ли продолжать эксплуатацию текущего источника пищи или искать новый, более выгодный.

  //В Исследователь. Если текущий источник пищи оказывается невыгодным (например, текущее значение приспособленности хуже порогового), пчела может перейти в состояние исследователя для поиска новых источников.
  //В Опытный. Если эксплуататор находит источник пищи, который подтверждает свою прибыльность, он может перейти в состояние опытного для передачи информации другим пчелам.

  if (agent.cost < avgCost)
  {
    agent.pab -= abandonmentRate;

    if (u.RNDprobab () > agent.pab)
    {
      agent.state = S_ABHA_Agent::stateSearch;
      agent.pab = 0;

      for (int c = 0; c < coords; c++)
      {
        agent.direction [c] = u.RNDfromCI (-(rangeMax [c] - rangeMin [c]), (rangeMax [c] - rangeMin [c]));
      }

      agent.stepSize      = initialStepSize;
      agent.searchCounter = 0;
    }
  }

  if (agent.cost > agent.bestCost)
  {
    agent.state = S_ABHA_Agent::stateExperienced;
    agent.pab = 1;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::CalculateProbabilities ()
{
  double maxCost = -DBL_MAX;
  double minCost =  DBL_MAX;

  for (int i = 0; i < popSize; i++)
  {
    if (agents [i].cost > maxCost) maxCost = agents [i].cost;
    if (agents [i].cost < minCost) minCost = agents [i].cost;
  }

  double costRange = maxCost - minCost;

  for (int i = 0; i < popSize; i++)
  {
    agents [i].p_si = (maxCost - agents [i].cost) / costRange;

    agents [i].p_srs = randomSearchProbability; // вероятность случайного поиска
    agents [i].p_rul = 1.0 - agents [i].pab;    // Вероятность следования танцу
    agents [i].p_ab  = agents [i].pab;          // Вероятность оставаться у источника

    double sum = agents [i].p_srs + agents [i].p_rul + agents [i].p_ab;

    agents [i].p_srs /= sum;
    agents [i].p_rul /= sum;
    agents [i].p_ab  /= sum;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_ABHA::CalculateAverageCost ()
{
  double totalCost = 0;

  for (int i = 0; i < popSize; i++)
  {
    totalCost += agents [i].cost;
  }

  avgCost = totalCost / popSize;
}
//——————————————————————————————————————————————————————————————————————————————