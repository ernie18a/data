//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_BGA |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/14040

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_BinaryGene
{
    char   gene      [];
    char   geneMax   [];
    char   integPart [];
    char   fractPart [];

    uint   integGrayDigits;
    uint   fractGrayDigits;
    uint   length;

    double maxCodedDistance;
    double minPossibleFractPart;
    double digitsPowered;

    double rangeMin;
    double rangeMax;

    C_AO_Utilities u;

    //--------------------------------------------------------------------------
    void Init (double min, double max, int doubleDigitsInChromo)
    {
      rangeMin = min;
      rangeMax = max;

      minPossibleFractPart = pow (0.1, doubleDigitsInChromo);
      digitsPowered        = pow (10, doubleDigitsInChromo);

      ulong decInfr = 0;

      for (int i = 0; i < doubleDigitsInChromo; i++)
      {
        decInfr += 9 * (ulong)pow (10, i);
      }

      //----------------------------------------
      u.DecimalToGray (decInfr, fractPart);

      ulong  maxDecInFr = u.GetMaxDecimalFromGray (ArraySize (fractPart));
      double maxDoubFr  = maxDecInFr * minPossibleFractPart;


      //----------------------------------------
      u.DecimalToGray ((ulong)(rangeMax - rangeMin), integPart);

      ulong  maxDecInInteg = u.GetMaxDecimalFromGray (ArraySize (integPart));
      double maxDoubInteg  = (double)maxDecInInteg + maxDoubFr;

      maxCodedDistance = maxDoubInteg;

      ArrayResize (gene, 0, 1000);
      integGrayDigits = ArraySize (integPart);
      fractGrayDigits = ArraySize (fractPart);
      length          = integGrayDigits + fractGrayDigits;

      ArrayCopy (gene, integPart, 0,                0, WHOLE_ARRAY);
      ArrayCopy (gene, fractPart, ArraySize (gene), 0, WHOLE_ARRAY);

      ArrayCopy (geneMax, gene, 0, 0, WHOLE_ARRAY);
    }

    //--------------------------------------------------------------------------
    //chromo - бинарная строка
    //indChr - позиция в бинарной строке
    double ToDouble (const char &chromo [], const int indChr)
    {
      double d;
      if (integGrayDigits > 0) d = (double)u.GrayToDecimal (chromo, indChr, indChr + integGrayDigits - 1);
      else                     d = 0.0;

      d += (double)u.GrayToDecimal (chromo, indChr + integGrayDigits, indChr + integGrayDigits + fractGrayDigits - 1) * minPossibleFractPart;

      return u.Scale (d, 0.0, maxCodedDistance, rangeMin, rangeMax);
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
struct C_BGA_Agent
{
    S_BinaryGene   genes         []; //there are as many genes as there are coordinates
    char           chromosome    []; //chromosome
    C_AO_Utilities u;                //utilities
    double         f;                //agent's fitness
    double         c [];             //coordinates
    uint           genePosInChro []; //gene position in the chromosome

    void Init (const int coords, const double &min [], const double &max [], int doubleDigitsInChromo)
    {
      ArrayResize (c, coords);
      f = -DBL_MAX;

      ArrayResize (genes,         coords);
      ArrayResize (genePosInChro, coords);
      ArrayResize (chromosome, 0, 1000);

      for (int i = 0; i < coords; i++)
      {
        genes [i].Init (min [i], max [i], doubleDigitsInChromo);
        ArrayCopy (chromosome, genes [i].gene, ArraySize (chromosome), 0, WHOLE_ARRAY);
        if (i == 0) genePosInChro [i] = 0;
        else        genePosInChro [i] = genePosInChro [i - 1] + genes [i - 1].length;
      }
    }

    double ExtractGene (int geneIndex) //gene index (coord index)
    {
      return genes [geneIndex].ToDouble (chromosome, genePosInChro [geneIndex]);
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_BGA : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_BGA () { }
  C_AO_BGA ()
  {
    ao_name = "BGA";
    ao_desc = "Binary Genetic Algorithm";
    ao_link = "https://www.mql5.com/ru/articles/14040";

    popSize              = 50;    //population size

    parentPopSize        = 50;    //parent population size
    crossoverProbab      = 1.0;   //crossover probability
    crossoverPoints      = 3;     //crossover points
    mutationProbab       = 0.001; //mutation probability
    inversionProbab      = 0.7;   //inversion probability
    doubleDigitsInChromo = 3;     //number of decimal places in the gene

    ArrayResize (params, 7);

    params [0].name = "popSize";              params [0].val = popSize;

    params [1].name = "parentPopSize";        params [1].val = parentPopSize;
    params [2].name = "crossoverProbab";      params [2].val = crossoverProbab;
    params [3].name = "crossoverPoints";      params [3].val = crossoverPoints;
    params [4].name = "mutationProbab";       params [4].val = mutationProbab;
    params [5].name = "inversionProbab";      params [5].val = inversionProbab;
    params [6].name = "doubleDigitsInChromo"; params [6].val = doubleDigitsInChromo;
  }

  void SetParams ()
  {
    popSize              = (int)params [0].val;

    parentPopSize        = (int)params [1].val;
    crossoverProbab      = params      [2].val;
    crossoverPoints      = (int)params [3].val;
    mutationProbab       = params      [4].val;
    inversionProbab      = params      [5].val;
    doubleDigitsInChromo = (int)params [6].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  int    parentPopSize;        //parent population size
  double crossoverProbab;      //crossover probability
  int    crossoverPoints;      //crossover points
  double mutationProbab;       //mutation probability
  double inversionProbab;      //inversion probability
  int    doubleDigitsInChromo; //number of decimal places in the gene

  C_BGA_Agent  agent      [];

  private: //-------------------------------------------------------------------
  C_BGA_Agent  parents    [];  //parents
  C_BGA_Agent  pTemp      [];  //temporary array for sorting the population
  char         tempChrome [];  //temporary chromosome for inversion surgery
  uint         lengthChrome;   //length of the chromosome (the length of the string of characters according to the Gray code)
  int          pCount;         //indices of chromosome break points
  uint         poRND      [];  //temporal indices of chromosome break points
  uint         points     [];  //final indices of chromosome break points

  struct S_Roulette
  {
      double start;
      double end;
  };

  S_Roulette roulette   [];  //roulette

  void PreCalcRoulette ();
  int  SpinRoulette    ();

  /*
  //----------------------------------------------------------------------------
  void ExtractGenes ()
  {
    uint pos = 0;

    for (int i = 0; i < ArraySize (genes); i++)
    {
      c [i] = genes [i].ToDouble (chromosome, pos);
      pos  += genes [i].length;

    }
  }
  */

  /*
  //----------------------------------------------------------------------------
  void DoubleToGene (const double val, const int genePos)
  {
    double value = val;

    //--------------------------------------------------------------------------
    if (value < genes [genePos].rangeMin)
    {
      ArrayInitialize (genes [genePos].gene, 0);
      ArrayCopy (chromosome, genes [genePos].gene, genePos * genes [genePos].length, 0, WHOLE_ARRAY);
      return;
    }
    //--------------------------------------------------------------------------
    else
    {
      if (value > genes [genePos].rangeMax)
      {
        ArrayCopy (chromosome, genes [genePos].geneMax, genePos * genes [genePos].length, 0, WHOLE_ARRAY);
        return;
      }
    }

    //--------------------------------------------------------------------------
    value = u.Scale (value, genes [genePos].rangeMin, genes [genePos].rangeMax, 0.0, genes [genePos].maxCodedDistance);

    u.DecimalToGray ((ulong)value, genes [genePos].integPart);

    value = value - (int)value;

    value *= genes [genePos].digitsPowered;

    u.DecimalToGray ((ulong)value, genes [genePos].fractPart);

    ArrayInitialize (genes [genePos].gene, 0);

    uint   integGrayDigits = genes [genePos].integGrayDigits;
    uint   fractGrayDigits = genes [genePos].fractGrayDigits;
    uint   digits = ArraySize (genes [genePos].integPart);

    if (digits > 0) ArrayCopy (genes [genePos].gene, genes [genePos].integPart, integGrayDigits - digits, 0, WHOLE_ARRAY);

    digits = ArraySize (genes [genePos].fractPart);

    if (digits > 0) ArrayCopy (genes [genePos].gene, genes [genePos].fractPart, genes [genePos].length - digits, 0, WHOLE_ARRAY);

    ArrayCopy (chromosome, genes [genePos].gene, genePos * genes [genePos].length, 0, WHOLE_ARRAY);
  }
  */
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_BGA::Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);

  for (int i = 0; i < popSize; i++)
  {
    agent [i].Init (coords, rangeMin, rangeMax, doubleDigitsInChromo);
  }

  ArrayResize (parents,  parentPopSize + popSize);
  ArrayResize (pTemp,    parentPopSize + popSize);
  ArrayResize (roulette, parentPopSize);

  for (int i = 0; i < parentPopSize + popSize; i++)
  {
    parents [i].Init (coords, rangeMin, rangeMax, doubleDigitsInChromo);
    pTemp   [i].Init (coords, rangeMin, rangeMax, doubleDigitsInChromo);
  }

  lengthChrome = ArraySize (agent [0].chromosome);
  ArrayResize (tempChrome, lengthChrome);

  pCount = crossoverPoints;
  if (pCount < 1) pCount = 1;

  ArrayResize (poRND,  pCount);
  ArrayResize (points, pCount + 2);
  ArrayResize (u.roulette, parentPopSize);

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_BGA::Moving ()
{
  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (uint len = 0; len < lengthChrome; len++)
      {
        agent [i].chromosome [len] = u.RNDbool ();
      }

      for (int c = 0; c < coords; c++)
      {
        a [i].c [c] = agent [i].ExtractGene (c);
        a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
        agent [i].c [c] = a [i].c [c];
      }
    }

    for (int i = 0; i < parentPopSize + popSize; i++)
    {
      for (uint len = 0; len < lengthChrome; len++)
      {
        parents [i].chromosome [len] = u.RNDbool ();
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  int  pos = 0;
  uint p1  = 0;

  for (int i = 0; i < popSize; i++)
  {
    PreCalcRoulette ();

    //selection, select and copy the parent to the child------------------------
    pos = SpinRoulette ();

    ArrayCopy (agent [i].chromosome, parents [pos].chromosome, 0, 0, WHOLE_ARRAY);

    //crossover-----------------------------------------------------------------
    if (u.RNDprobab () < crossoverProbab)
    {
      //choose a second parent to breed with------------------------------------
      pos = SpinRoulette ();

      //determination of chromosome break points--------------------------------
      for (int p = 0; p < pCount; p++)
      {
        poRND [p] = u.RNDminusOne (lengthChrome);
      }

      ArraySort (poRND);
      ArrayCopy (points, poRND, 1, 0, WHOLE_ARRAY);
      points [0] = 0;
      points [pCount + 1] = lengthChrome - 1;

      int startPoint = u.RNDbool ();

      for (int p = startPoint; p < pCount + 2; p += 2)
      {
        if (p < pCount + 1)
        {
          for (uint len = points [p]; len < points [p + 1]; len++) agent [i].chromosome [len] = parents [pos].chromosome [len];
        }
      }
    }

    //perform an inversion------------------------------------------------------
    //(break the chromosome, swap the received parts, connect them together)
    if (u.RNDprobab () < inversionProbab)
    {
      p1 = u.RNDminusOne   (lengthChrome);

      //copying the second part to the beginning of the temporary array
      for (uint len = p1; len < lengthChrome; len++) tempChrome [len - p1] = agent [i].chromosome [len];

      //copying the first part to the end of the temporary array
      for (uint len = 0; len < p1; len++)            tempChrome [lengthChrome - p1 + len] = agent [i].chromosome [len];

      //copying a temporary array back
      for (uint len = 0; len < lengthChrome; len++) agent [i].chromosome [len] = tempChrome [len];
    }

    //выполнить мутацию---------------------------------------------------------
    for (uint len = 0; len < lengthChrome; len++)
    {
      if (u.RNDprobab () < mutationProbab) agent [i].chromosome [len] = agent [i].chromosome [len] == 1 ? 0 : 1;
    }

    for (int c = 0; c < coords; c++)
    {
      a [i].c [c] = agent [i].ExtractGene (c);
      a [i].c [c] = u.SeInDiSp (a [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      agent [i].c [c] = a [i].c [c];
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_BGA::Revision ()
{
  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    agent [i].f = a [i].f;
  }

  for (int i = parentPopSize; i < parentPopSize + popSize; i++)
  {
    parents [i] = agent [i - parentPopSize];
  }

  u.Sorting (parents, pTemp, parentPopSize + popSize);

  if (parents [0].f > fB)
  {
    fB = parents [0].f;
    ArrayCopy (cB, parents [0].c, 0, 0, WHOLE_ARRAY);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_BGA::PreCalcRoulette ()
{
  roulette [0].start = parents [0].f;
  roulette [0].end   = roulette [0].start + (parents [0].f - parents [parentPopSize - 1].f);

  for (int s = 1; s < parentPopSize; s++)
  {
    if (s != parentPopSize - 1)
    {
      roulette [s].start = roulette [s - 1].end;
      roulette [s].end   = roulette [s].start + (parents [s].f - parents [parentPopSize - 1].f);
    }
    else
    {
      roulette [s].start = roulette [s - 1].end;
      roulette [s].end   = roulette [s].start + (parents [s - 1].f - parents [s].f) * 0.1;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
int C_AO_BGA::SpinRoulette ()
{
  double r = u.RNDfromCI (roulette [0].start, roulette [parentPopSize - 1].end);

  for (int s = 0; s < parentPopSize; s++)
  {
    if (roulette [s].start <= r && r < roulette [s].end) return s;
  }

  return 0;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_BGA::Injection (const int popPos, const int coordPos, const double value)
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