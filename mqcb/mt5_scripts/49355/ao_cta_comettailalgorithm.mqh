//+————————————————————————————————————————————————————————————————————————————+
//|                                                                   C_AO_CTA |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/14841

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
class C_AO_CTA : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_CTA () { }
  C_AO_CTA ()
  {
    ao_name = "CTA";
    ao_desc = "Comet Tail Algorithm";
    ao_link = "https://www.mql5.com/ru/articles/14841";

    popSize      = 80;   //population size

    cometsNumb   = 40;   //number of comets
    power        = 4;    //power probability
    dir          = -1;   //tail direction
    tailLengthKo = 0.2;  //tail length coefficient
    maxShiftCoef = 1.0;  //maximum shift coefficient
    minShiftCoef = 0.5;  //minimum shift coefficient
    maxSizeCoef  = 0.1;  //maximum size coefficient
    minSizeCoef  = 15.0; //minimum size coefficient

    ArrayResize (params, 9);

    params [0].name = "popSize";       params [0].val = popSize;

    params [1].name = "cometsNumb";    params [1].val = cometsNumb;
    params [2].name = "power";         params [2].val = power;
    params [3].name = "dir";           params [3].val = dir;
    params [4].name = "tailLengthKo";  params [4].val = tailLengthKo;
    params [5].name = "maxShiftCoef";  params [5].val = maxShiftCoef;
    params [6].name = "minShiftCoef";  params [6].val = minShiftCoef;
    params [7].name = "maxSizeCoef";   params [7].val = maxSizeCoef;
    params [8].name = "minSizeCoef";   params [8].val = minSizeCoef;
  }

  void SetParams ()
  {
    popSize      = (int)params [0].val;

    cometsNumb   = (int)params [1].val;
    power        = params      [2].val;
    dir          = (int)params [3].val;
    tailLengthKo = params      [4].val;
    maxShiftCoef = params      [5].val;
    minShiftCoef = params      [6].val;
    maxSizeCoef  = params      [7].val;
    minSizeCoef  = params      [8].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  int    cometsNumb;    //number of comets
  double power;         //power probability
  int    dir;           //tail direction
  double tailLengthKo;  //tail length coefficient
  double maxShiftCoef;  //maximum shift coefficient
  double minShiftCoef;  //minimum shift coefficient
  double maxSizeCoef;   //maximum size coefficient
  double minSizeCoef;   //minimum size coefficient

  S_AO_Agent comets [];

  private: //-------------------------------------------------------------------
  int    epochs;
  int    epochNow;
  double tailLength       [];
  double maxSpaceDistance []; //maximum distance in space
  int    partNumber; //number of particles
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_CTA::Init (const double &rangeMinP [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  epochs   = epochsP;
  epochNow = 0;

  ArrayResize (comets, cometsNumb);
  for (int i = 0; i < cometsNumb; i++)
  {
    ArrayResize (comets [i].c, coords);
    comets [i].f = -DBL_MAX;
  }

  ArrayResize (tailLength,       coords);
  ArrayResize (maxSpaceDistance, coords);

  for (int i = 0; i < coords; i++)
  {
    maxSpaceDistance [i] = rangeMax [i] - rangeMin [i];
    tailLength       [i] = maxSpaceDistance [i] * tailLengthKo;
  }

  partNumber = popSize / cometsNumb;

  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CTA::Moving ()
{
  epochNow++;
  int    cnt = 0;
  double min = 0.0;
  double max = 0.0;

  //----------------------------------------------------------------------------
  if (!revision)
  {
    for (int i = 0; i < cometsNumb; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        comets [i].c [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        comets [i].c [c] = u.SeInDiSp  (comets [i].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    for (int i = 0; i < cometsNumb; i++)
    {
      for (int p = 0; p < partNumber; p++)
      {
        for (int c = 0; c < coords; c++)
        {
          min = comets [i].c [c] - tailLength [c] * 0.5; if (min < rangeMin [c]) min = rangeMin [c];
          max = comets [i].c [c] + tailLength [c] * 0.5; if (max > rangeMax [c]) max = rangeMax [c];

          a [cnt].c [c] = u.GaussDistribution (comets [i].c [c], min, max, 1);
          a [cnt].c [c] = u.SeInDiSp  (a [cnt].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
        }

        cnt++;
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  cnt             = 0;
  double coefTail = 0.0;
  double coefSize = 0.0;

  for (int i = 0; i < cometsNumb; i++)
  {
    for (int p = 0; p < partNumber; p++)
    {
      for (int c = 0; c < coords; c++)
      {
        if (u.RNDprobab () < 0.6)
        {
          coefTail = fabs (comets [i].c [c] - cB [c]) / maxSpaceDistance [c];
          coefSize = coefTail;

          //(1-x)*0.9+x*0.5
          coefTail = (1 - coefTail) * maxShiftCoef + coefTail * minShiftCoef;

          //(1-x)*0.1+x*0.9
          coefSize = (1 - coefSize) * maxSizeCoef + coefSize * minSizeCoef;

          if (cB [c] * dir > comets [i].c [c] * dir)
          {
            min = comets [i].c [c] - tailLength [c] * coefTail         * coefSize;
            max = comets [i].c [c] + tailLength [c] * (1.0 - coefTail) * coefSize;
          }
          if (cB [c] * dir < comets [i].c [c] * dir)
          {
            min = comets [i].c [c] - tailLength [c] * (1.0 - coefTail) * coefSize;
            max = comets [i].c [c] + tailLength [c] * (coefTail)*coefSize;
          }
          if (cB [c] == comets [i].c [c])
          {
            min = comets [i].c [c] - tailLength [c] * 0.1;
            max = comets [i].c [c] + tailLength [c] * 0.1;
          }

          if (min < rangeMin [c]) min = rangeMin [c];
          if (max > rangeMax [c]) max = rangeMax [c];

          a [cnt].c [c] = u.GaussDistribution (comets [i].c [c], min, max, power);
          a [cnt].c [c] = u.SeInDiSp  (a [cnt].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
        }
        else
        {
          int    r   = 0;
          int    r1  = 0;
          int    r2  = 0;

          do
          {
            r = u.RNDminusOne (cometsNumb);
            r1 = r;
          }
          while (r1 == i);

          do
          {
            r = u.RNDminusOne (cometsNumb);
            r2 = r;
          }
          while (r2 == i || r2 == r1);

          a [cnt].c [c] = comets [r1].c [c] + 0.1 * (comets [r2].c [c] - comets [i].c [c]) * u.RNDprobab ();
          a [cnt].c [c] = u.SeInDiSp (a [cnt].c [c], rangeMin [c], rangeMax [c], rangeStep [c]);
        }
      }

      cnt++;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CTA::Revision ()
{
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

  //set a new kernel------------------------------------------------------------
  int cnt = 0;

  for (int i = 0; i < cometsNumb; i++)
  {
    ind = -1;

    for (int p = 0; p < partNumber;  p++)
    {
      if (a [cnt].f > comets [i].f)
      {
        comets [i].f = a [cnt].f;
        ind = cnt;
      }

      cnt++;
    }

    if (ind != -1) ArrayCopy (comets [i].c, a [ind].c, 0, 0, WHOLE_ARRAY);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_CTA::Injection (const int popPos, const int coordPos, const double value)
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
