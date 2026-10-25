//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_CRO |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/15041

#include "#C_AO.mqh"

enum E_ReactionType
{
  synthesis,
  interMolecularInefColl,
  decomposition,
  inefCollision
};

// Структура молекулы
struct S_CRO_Agent
{
    double structure [];
    int    NumHit;
    int    indMolecule_1;
    int    indMolecule_2;
    double KE;
    double f;
    E_ReactionType rType;


    // Метод инициализации
    void Init (int coords)
    {
      ArrayResize (structure, coords);
      NumHit        = 0;
      indMolecule_1 = 0;
      indMolecule_2 = 0;
      f             = -DBL_MAX;
      KE            = -DBL_MAX;
    }
};

//——————————————————————————————————————————————————————————————————————————————
class C_AO_CRO : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_CRO () { }
  C_AO_CRO ()
  {
    ao_name = "CRO";
    ao_desc = "Chemical Reaction Optimisation";
    ao_link = "https://www.mql5.com/ru/articles/15041";

    popSize      = 50;   //population size

    moleColl     = 0.9;
    alpha        = 200;
    beta         = 0.01;
    molecPerturb = 0.5;

    ArrayResize (params, 5);

    params [0].name = "popSize";      params [0].val = popSize;
    params [1].name = "moleColl";     params [1].val = moleColl;
    params [2].name = "alpha";        params [2].val = alpha;
    params [3].name = "beta";         params [3].val = beta;
    params [4].name = "molecPerturb"; params [4].val = molecPerturb;

  }

  void SetParams ()
  {
    popSize      = (int)params [0].val;

    moleColl     = params      [1].val;
    alpha        = (int)params [2].val;
    beta         = params      [3].val;
    molecPerturb = params      [4].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();

  S_CRO_Agent Mparent [];
  S_CRO_Agent Mfilial [];


  //----------------------------------------------------------------------------
  double moleColl;
  int    alpha;
  double beta;
  double molecPerturb;

  private: //-------------------------------------------------------------------
  bool Synthesis            (int index1, int index2, int &molCNT);
  bool InterMolInefColl     (int index1, int index2, int &molCNT);
  bool Decomposition        (int index,  int &molCNT);
  bool InefCollision        (int index,  int &molCNT);

  void PostSynthesis        (S_CRO_Agent &mol);
  void PostInterMolInefColl (S_CRO_Agent &mol);
  void PostDecomposition    (S_CRO_Agent &mol);
  void PostInefCollision    (S_CRO_Agent &mol);

  void N                    (double &coord, int coordPos);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_CRO::Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (Mparent, popSize);
  ArrayResize (Mfilial, popSize);

  for (int i = 0; i < popSize; i++)
  {
    Mparent [i].Init (coords);
    Mfilial [i].Init (coords);
  }

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CRO::Moving ()
{
  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        Mparent [i].structure [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]); // Случайная структура в диапазоне от rangeMin до rangeMax
        Mparent [i].structure [c] = u.SeInDiSp  (Mparent [i].structure [c], rangeMin [c], rangeMax [c], rangeStep [c]);

        a [i].c [c] = Mparent [i].structure [c];
      }
    }

    return;
  }

  //----------------------------------------------------------------------------
  double minKE = DBL_MAX;

  for (int i = 0; i < popSize; i++)
  {
    if (Mparent [i].f < minKE) minKE = Mparent [i].f;
  }
  for (int i = 0; i < popSize; i++)
  {
    Mparent [i].KE = u.Scale (Mparent [i].f, minKE, fB, 0.0, 1.0);
  }

  //----------------------------------------------------------------------------
  int molCNT = 0;

  while (!IsStopped ())
  {
    if (u.RNDprobab () < moleColl)
    {
      // Выбор двух случайных молекул M1 и M2
      int index1 = u.RNDminusOne (popSize);
      int index2 = u.RNDminusOne (popSize);

      // Если KE ≤ β:
      if (Mparent [index1].KE >= beta && Mparent [index2].KE >= beta)
      {
        // Выполнить Синтез
        if (!Synthesis (index1, index2, molCNT)) break;
      }
      else
      {
        // Выполнить Межмолекулярное Неэффективное Столкновение
        if (!InterMolInefColl (index1, index2, molCNT)) break;
      }
    }
    else
    {
      // Выбор случайной молекулы M
      int index = u.RNDminusOne (popSize);

      // Если NumHit > α:
      if (Mparent [index].NumHit > alpha)
      {
        // Выполнить Разложение
        if (!Decomposition (index, molCNT)) break;
      }
      else
      {
        // Выполнить Столкновение
        if (!InefCollision (index, molCNT)) break;
      }
    }
  }

  for (int i = 0; i < popSize; i++)
  {
    ArrayCopy (a [i].c, Mfilial [i].structure);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CRO::Revision ()
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
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        Mparent [i].f = a [i].f;
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
      Mfilial [i].f = a [i].f;
    }

    switch (Mfilial [i].rType)
    {
      case synthesis:
        PostSynthesis        (Mfilial [i]);
        break;
      case interMolecularInefColl:
        PostInterMolInefColl (Mfilial [i]);
        break;
      case decomposition:
        PostDecomposition    (Mfilial [i]);
        break;
      case inefCollision:
        PostInefCollision    (Mfilial [i]);
        break;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Синтез. Получение новой молекулы путём слияния двух родительских
bool C_AO_CRO::Synthesis (int index1, int index2, int &molCNT)
{
  if (molCNT >= popSize) return false;

  // Создание новой молекулы M_ω' из M_ω1 и M_ω2
  for (int i = 0; i < coords; i++)
  {
    if (u.RNDprobab () < 0.5) Mfilial [molCNT].structure [i] = Mparent [index1].structure [i];
    else                      Mfilial [molCNT].structure [i] = Mparent [index2].structure [i];
  }

  Mfilial [molCNT].indMolecule_1 = index1; //сохраним индекс первой родительской молекулы
  Mfilial [molCNT].indMolecule_2 = index2; //сохраним индекс второй родительской молекулы
  Mfilial [molCNT].rType         = synthesis;
  Mfilial [molCNT].NumHit        = 0;

  molCNT++;
  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Обработка результатов синтеза.
void C_AO_CRO::PostSynthesis (S_CRO_Agent &mol)
{
  int ind1 = mol.indMolecule_1;
  int ind2 = mol.indMolecule_2;

  if (mol.f > Mparent [ind1].f && mol.f > Mparent [ind2].f)
  {
    if (Mparent [ind1].f < Mparent [ind2].f)
    {
      ArrayCopy (Mparent [ind1].structure, mol.structure);
      Mparent [ind1].f = mol.f;
      Mparent [ind1].NumHit = 0;
    }
    else
    {
      ArrayCopy (Mparent [ind2].structure, mol.structure);
      Mparent [ind2].f = mol.f;
      Mparent [ind2].NumHit = 0;
    }
  }
  else
  {
    Mparent [ind1].NumHit++;
    Mparent [ind2].NumHit++;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Межмолекулярное неэффективное столкновение. Получение новых двух молекул путём изменения двух родительских
bool C_AO_CRO::InterMolInefColl (int index1, int index2, int &molCNT)
{
  if (molCNT >= popSize - 1) return false;

  int index1_ = molCNT;
  int index2_ = molCNT + 1;

  // Получение молекул
  ArrayCopy (Mfilial [index1_].structure, Mparent [index1].structure);
  ArrayCopy (Mfilial [index2_].structure, Mparent [index2].structure);

  // Генерация новых молекул ω'_1 = N(ω1) и ω'_2 = N(ω2) в окрестности ω1 и ω2
  for (int c = 0; c < coords; c++)
  {
    N (Mfilial [index1_].structure [c], c);
    N (Mfilial [index2_].structure [c], c);
  }

  for (int c = 0; c < coords; c++)
  {
    Mfilial [index1_].structure [c] = u.SeInDiSp  (Mfilial [index1_].structure [c], rangeMin [c], rangeMax [c], rangeStep [c]);
    Mfilial [index2_].structure [c] = u.SeInDiSp  (Mfilial [index2_].structure [c], rangeMin [c], rangeMax [c], rangeStep [c]);
  }

  Mfilial [index1_].indMolecule_1 = index1;                 //сохраним индекс первой родительской молекулы
  Mfilial [index1_].indMolecule_2 = index2_;                //сохраним индекс второй дочерней молекулы
  Mfilial [index1_].rType         = interMolecularInefColl;
  Mfilial [index1_].NumHit        = 0;

  Mfilial [index2_].indMolecule_1 = index2;                 //сохраним индекс второй родительской молекулы
  Mfilial [index2_].indMolecule_2 = -1;                     //пометим молекулу, чтобы не обрабатывать её дважды
  Mfilial [index2_].rType         = interMolecularInefColl;
  Mfilial [index2_].NumHit        = 0;

  molCNT += 2;
  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Обработка результатов межмолекулярного неэффективного столкновения.
void C_AO_CRO::PostInterMolInefColl (S_CRO_Agent &mol)
{
  if (mol.indMolecule_2 == -1) return;

  int ind1 = mol.indMolecule_1;
  int ind2 = Mfilial [mol.indMolecule_2].indMolecule_1;
  
  Mparent [ind1].NumHit++;
  Mparent [ind2].NumHit++;

  if (mol.f + Mfilial [mol.indMolecule_2].f > Mparent [ind1].f + Mparent [ind2].f)
  {
    ArrayCopy (Mparent [ind1].structure, mol.structure);
    Mparent [ind1].f = mol.f;

    ArrayCopy (Mparent [ind2].structure, Mfilial [mol.indMolecule_2].structure);
    Mparent [ind2].f = Mfilial [mol.indMolecule_2].f;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Разложение. Получение новых двух молекул путём разложения одной родительской.
bool C_AO_CRO::Decomposition (int index,  int &molCNT)
{
  if (molCNT >= popSize - 1) return false;

  // Создание двух новых молекул M_ω'_1 и M_ω'_2 из M_ω
  int index1_ = molCNT;
  int index2_ = molCNT + 1;

  ArrayCopy (Mfilial [index1_].structure, Mparent [index].structure);
  ArrayCopy (Mfilial [index2_].structure, Mparent [index].structure);

  for (int c = 0; c < coords / 2; c++)
  {
    N (Mfilial [index1_].structure [c], c);
    Mfilial [index1_].structure [c] = u.SeInDiSp  (Mfilial [index1_].structure [c], rangeMin [c], rangeMax [c], rangeStep [c]);
  }
  for (int c = coords / 2; c < coords; c++)
  {
    N (Mfilial [index2_].structure [c], c);
    Mfilial [index2_].structure [c] = u.SeInDiSp  (Mfilial [index2_].structure [c], rangeMin [c], rangeMax [c], rangeStep [c]);
  }

  Mfilial [index1_].indMolecule_1 = index;                 //сохраним индекс родительской молекулы
  Mfilial [index1_].indMolecule_2 = index2_;               //сохраним индекс второй дочерней молекулы
  Mfilial [index1_].rType         = decomposition;
  Mfilial [index1_].NumHit        = 0;

  Mfilial [index2_].indMolecule_1 = index1_;               //сохраним индекс первой дочерней молекулы
  Mfilial [index2_].indMolecule_2 = -1;                    //пометим молекулу, чтобы не обрабатывать её дважды
  Mfilial [index2_].rType         = decomposition;
  Mfilial [index2_].NumHit        = 0;

  molCNT += 2;
  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Обработка результатов разложения.
void C_AO_CRO::PostDecomposition (S_CRO_Agent &mol)
{
  if (mol.indMolecule_2 == -1) return;

  int ind = mol.indMolecule_1;

  int index2_ = mol.indMolecule_2;
  int index1_ = Mfilial [index2_].indMolecule_1;

  bool flag = false;

  if (Mfilial [index1_].f > Mfilial [index2_].f && Mfilial [index1_].f > Mparent [ind].f)
  {
    ArrayCopy (Mparent [ind].structure, Mfilial [index1_].structure);
    Mparent [ind].f = Mfilial [index1_].f;
    Mparent [ind].NumHit = 0;
    flag = true;
  }

  if (!flag)
  {
    if (Mfilial [index2_].f > Mfilial [index1_].f && Mfilial [index2_].f > Mparent [ind].f)
    {
      ArrayCopy (Mparent [ind].structure, Mfilial [index2_].structure);
      Mparent [ind].f = Mfilial [index2_].f;
      Mparent [ind].NumHit = 0;
      flag = true;
    }
  }

  if (!flag)
  {
    Mparent [ind].NumHit++;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Неэффективное столкновение. Получение новой молекулы путём смещения одной родительской.
bool C_AO_CRO::InefCollision (int index, int &molCNT)
{
  if (molCNT >= popSize) return false;

  int index1_ = molCNT;

  ArrayCopy (Mfilial [index1_].structure, Mparent [index].structure);

  for (int c = 0; c < coords; c++)
  {
    N (Mfilial [index1_].structure [c], c);
    Mfilial [index1_].structure [c] = u.SeInDiSp (Mfilial [index1_].structure [c], rangeMin [c], rangeMax [c], rangeStep [c]);
  }

  Mfilial [index1_].indMolecule_1 = index;                 //сохраним индекс родительской молекулы
  Mfilial [index1_].rType         = inefCollision;
  Mfilial [index1_].NumHit        = 0;

  molCNT++;
  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Обработка результатов неэффективного столкновения.
void C_AO_CRO::PostInefCollision (S_CRO_Agent &mol)
{
  int ind = mol.indMolecule_1;

  if (mol.f > Mparent [ind].f)
  {
    ArrayCopy (Mparent [ind].structure, mol.structure);
    Mparent [ind].f = mol.f;
    Mparent [ind].NumHit = 0;
  }
  else
  {
    Mparent [ind].NumHit++;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CRO::N (double &coord, int coordPos)
{
  double dist = (rangeMax [coordPos] - rangeMin [coordPos]) * molecPerturb;

  double min = coord - dist; if (min < rangeMin [coordPos]) min = rangeMin [coordPos];
  double max = coord + dist; if (max > rangeMax [coordPos]) max = rangeMax [coordPos];

  coord = u.GaussDistribution (coord, min, max, 8);
}
//——————————————————————————————————————————————————————————————————————————————
