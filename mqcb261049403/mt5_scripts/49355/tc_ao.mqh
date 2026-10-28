//+————————————————————————————————————————————————————————————————————————————+
//|                                                                       C_AO |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//#include "#C_AO_Utilities.mqh"
#include <Math\AOs\Utilities.mqh>


//——————————————————————————————————————————————————————————————————————————————
struct S_AlgoParam
{
    double val;
    string name;
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
struct S_AO_Agent
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
class C_AO
{
  public: //--------------------------------------------------------------------
  C_AO () { }
  ~C_AO () { }

  double      cB     []; //best coordinates
  double      fB;        //FF of the best coordinates
  S_AO_Agent  a      []; //agents
  S_AlgoParam params []; //algorithm parameters
  bool        revision;

  virtual void SetParams () { }
  virtual bool Init (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP [], //step search
                     const int     epochsP = 0)   //number of epochs
  { return false;}

  virtual void Moving    () { }
  virtual void Revision  () { }
  virtual void Injection (const int popPos, const int coordPos, const double value) { }

  string GetName   () { return ao_name;}
  string GetDesc   () { return ao_desc;}
  string GetLink   () { return ao_link;}
  string GetParams ()
  {
    string str = "";
    for (int i = 0; i < ArraySize (params); i++)
    {
      str += (string)params [i].val + "|";
    }
    return str;
  }


  protected: //-----------------------------------------------------------------
  string ao_name;      //ao name;
  string ao_desc;      //ao description
  string ao_link;      //ao link

  double rangeMin  []; //minimum search range
  double rangeMax  []; //maximum search range
  double rangeStep []; //step search

  int    coords;       //coordinates number
  int    popSize;      //population size

  C_AO_Utilities u;     //auxiliary functions

  bool StandardInit (const double &rangeMinP  [], //minimum search range
                     const double &rangeMaxP  [], //maximum search range
                     const double &rangeStepP []) //step search
  {
    int seed = (int)GetTickCount64 ();
    MathSrand (seed); //reset of the generator
    //Print (seed);

    fB       = -DBL_MAX;
    revision = false;

    coords  = ArraySize (rangeMinP);
    if (coords == 0 || coords != ArraySize (rangeMaxP) || coords != ArraySize (rangeStepP)) return false;

    ArrayResize     (rangeMin,  coords);
    ArrayResize     (rangeMax,  coords);
    ArrayResize     (rangeStep, coords);
    ArrayResize     (cB,        coords);

    ArrayResize (a, popSize);
    for (int i = 0; i < popSize; i++) a [i].Init (coords);

    ArrayCopy (rangeMin,  rangeMinP,  0, 0, WHOLE_ARRAY);
    ArrayCopy (rangeMax,  rangeMaxP,  0, 0, WHOLE_ARRAY);
    ArrayCopy (rangeStep, rangeStepP, 0, 0, WHOLE_ARRAY);

    return true;
  }
};
//——————————————————————————————————————————————————————————————————————————————