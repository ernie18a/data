//——————————————————————————————————————————————————————————————————————————————
class C_Function
{
  public: //====================================================================
  double CalcFunc (double &args [], //function arguments
                   int     amount)  //amount of runs functions
  {
    double x, y;
    double sum = 0.0;
    for (int i = 0; i < amount; i++)
    {
      x = args [i * 2];
      y = args [i * 2 + 1];

      //double u = 0.5;
      //x = x * cos (u) - y * sin (u);
      //y = x * sin (u) + y * cos (u);

      if (x < GetMinRangeX ()) x = GetMinRangeX ();
      if (x > GetMaxRangeX ()) x = GetMaxRangeX ();

      if (y < GetMinRangeY ()) y = GetMinRangeY ();
      if (y > GetMaxRangeY ()) y = GetMaxRangeY ();

      sum += Core (x, y);
    }

    sum /= (double)amount;

    //if (MathClassify(sum) == -FP_NAN) Print ("F: ", sum, " -| ", amount);
    //if (MathClassify(sum) ==  FP_NAN) Print ("F: ", sum, " +| ", amount);

    return sum;
  }

  double GetMinRangeX   () { return xMinRange;}
  double GetMaxRangeX   () { return xMaxRange;}

  double GetMinRangeY   () { return yMinRange;}
  double GetMaxRangeY   () { return yMaxRange; }

  double GetMinFuncX    () { return xGlobalMin;}
  double GetMaxFuncX    () { return xGlobalMax;}

  double GetMinFuncY    () { return yGlobalMin;}
  double GetMaxFuncY    () { return yGlobalMax;}

  double GetMinFunValue () { return globalMinFunValue;}
  double GetMaxFunValue () { return globalMaxFunValue;}
  string GetFuncName    () { return fuName;}

  virtual double Core (double x, double y)
  {
    return 0.0;
  }
  virtual double Core (double &x [])
  {
    return 0.0;
  }

  double xMinRange;
  double xMaxRange;
  double yMinRange;
  double yMaxRange;

  double xGlobalMax;
  double yGlobalMax;
  double xGlobalMin;
  double yGlobalMin;

  double globalMinFunValue;
  double globalMaxFunValue;
  string fuName;

  public:
  double Scale (double In, double InMIN, double InMAX, double OutMIN, double OutMAX)
  {
    if (OutMIN == OutMAX) return (OutMIN);
    if (InMIN == InMAX) return ((OutMIN + OutMAX) / 2.0);
    else
    {
      if (In < InMIN) return (OutMIN);
      if (In > InMAX) return (OutMAX);
      return (((In - InMIN) * (OutMAX - OutMIN) / (InMAX - InMIN)) + OutMIN);
    }
  }

  double SeInDiSp (double In, double InMin, double InMax, double Step)
  {
    return (InMin + Step * (double)MathRound ((In - InMin) / Step));
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
enum EFunc
{
  NONE_Func,
  Skin,
  SkinDiscrete,
  Hilly,
  HillyDiscrete,
  Peaks,
  Parabola,
  Rastrigin,
  Forest,
  Megacity,
  Universe,
  Ackley,
  GoldsteinPrice,
  Shaffer
};

C_Function *SelectFunction (EFunc f)
{
  C_Function *func;
  switch (f)
  {
    case  Skin:
      func = new C_Skin ();
      return (GetPointer (func));
    case  SkinDiscrete:
      func = new C_SkinDiscrete ();
      return (GetPointer (func));
    case  Hilly:
      func = new C_Hilly ();
      return (GetPointer (func));
    case  HillyDiscrete:
      func = new C_HillyDiscrete ();
      return (GetPointer (func));
    case  Peaks:
      func = new C_Peaks ();
      return (GetPointer (func));
    case  Parabola:
      func = new C_Parabola ();
      return (GetPointer (func));
    case  Rastrigin:
      func = new C_Rastrigin ();
      return (GetPointer (func));
    case  Forest:
      func = new C_Forest ();
      return (GetPointer (func));
    case  Megacity:
      func = new C_Megacity ();
      return (GetPointer (func));
    case  Universe:
      func = new C_Universe ();
      return (GetPointer (func));
    case  Ackley:
      func = new C_Ackley ();
      return (GetPointer (func));
    case  GoldsteinPrice:
      func = new C_GoldsteinPrice ();
      return (GetPointer (func));
    case  Shaffer:
      func = new C_Shaffer ();
      return (GetPointer (func));

    default:
      func = NULL; return NULL;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Skin : public C_Function
{
  public: //====================================================================
  C_Skin ()
  {
    fuName = "Skin";

    //границы функции
    xMinRange = -6; xMaxRange = 6;
    yMinRange = -6; yMaxRange = 6;

    //координаты максимума
    globalMaxFunValue = 1.0; //14.060606995534872
    xGlobalMax        = -3.315699080744071;
    yGlobalMax        = -3.0724849592478254;

    //координаты минимума
    globalMinFunValue = 0.0; //-4.313787122075561
    xGlobalMin        = 3.070541082164328;
    yGlobalMin        = 2.8028056112224458;
  }

  double Core (double x, double y)
  {
    double a1 = 2 * x * x;
    double a2 = 2 * y * y;
    double b1 = MathCos (a1) - 1.1;
    b1 = b1 * b1;
    double c1 = MathSin (0.5 * x) - 1.2;
    c1 = c1 * c1;
    double d1 = MathCos (a2) - 1.1;
    d1 = d1 * d1;
    double e1 = MathSin (0.5 * y) - 1.2;
    e1 = e1 * e1;

    double res = b1 + c1 - d1 + e1;

    return Scale (res, -4.313787122075561,  14.060606995534872, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_SkinDiscrete : public C_Function
{
  public: //====================================================================
  C_SkinDiscrete ()
  {
    fuName = "Skin Discrete";

    //границы функции
    xMinRange = f.GetMinRangeX (); xMaxRange = f.GetMaxRangeX ();
    yMinRange = f.GetMinRangeY (); yMaxRange = f.GetMaxRangeY ();

    //координаты максимума
    globalMaxFunValue = f.GetMaxFunValue ();
    xGlobalMax        = f.GetMaxFuncX    ();
    yGlobalMax        = f.GetMaxFuncY    ();

    //координаты минимума
    globalMinFunValue = f.GetMinFunValue ();
    xGlobalMin        = f.GetMinFuncX    ();
    yGlobalMin        = f.GetMinFuncY    ();
  }

  C_Skin f;

  double Core (double x, double y)
  {
    double res = f.Core (x, y);
    return SeInDiSp (res, f.GetMinFunValue (), f.GetMaxFunValue (), 0.2);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Hilly : public C_Function
{
  public: //====================================================================
  C_Hilly ()
  {
    fuName = "Hilly";

    //границы функции
    xMinRange = -3; xMaxRange = 3;
    yMinRange = -3; yMaxRange = 3;

    //координаты максимума
    globalMaxFunValue = 1; //229.91931214214105
    xGlobalMax        = -1.4809053654574758;
    yGlobalMax        = 0.6254111843389699;

    //координаты минимума
    globalMinFunValue = 0.0; //-39.701816104859866
    xGlobalMin        = 1.3200361419666748;
    yGlobalMin        = 1.9993728393766546;
  }

  double Core (double x, double y)
  {
    double res = 20.0 + x * x + y * y - 10.0 * cos (2.0 * M_PI * x) - 10.0 * cos (2.0 * M_PI * y)
                 - 30.0  * exp (-(pow (x - 1.0,         2) + y * y) / 0.1)
                 + 200.0 * exp (-(pow (x + M_PI * 0.47, 2) + pow (y - M_PI * 0.2, 2)) / 0.1)  //global max
                 + 100.0 * exp (-(pow (x - 0.5,         2) + pow (y + 0.5,        2)) / 0.01)
                 - 60.0  * exp (-(pow (x - 1.33,        2) + pow (y - 2.0,        2)) / 0.02)               //global min
                 - 40.0  * exp (-(pow (x + 1.3,         2) + pow (y + 0.2,        2)) / 0.5)
                 + 60.0  * exp (-(pow (x - 1.5,         2) + pow (y + 1.5,        2)) / 0.1);

    return Scale (res, -39.701816104859866, 229.91931214214105, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_HillyDiscrete : public C_Function
{
  public: //====================================================================
  C_HillyDiscrete ()
  {
    fuName = "Hilly Discrete";

    //границы функции
    xMinRange = f.GetMinRangeX (); xMaxRange = f.GetMaxRangeX ();
    yMinRange = f.GetMinRangeY (); yMaxRange = f.GetMaxRangeY ();

    //координаты максимума
    globalMaxFunValue = f.GetMaxFunValue ();
    xGlobalMax        = f.GetMaxFuncX    ();
    yGlobalMax        = f.GetMaxFuncY    ();

    //координаты минимума
    globalMinFunValue = f.GetMinFunValue ();
    xGlobalMin        = f.GetMinFuncX    ();
    yGlobalMin        = f.GetMinFuncY    ();
  }

  C_Hilly f;

  double Core (double x, double y)
  {
    double res = f.Core (x, y);
    return SeInDiSp (res, f.GetMinFunValue (), f.GetMaxFunValue (), 0.05);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Peaks : public C_Function
{
  public: //===================================================================
  C_Peaks ()
  {
    fuName = "Peaks";

    //границы функции
    xMinRange = -10; xMaxRange = 10;
    yMinRange = -10; yMaxRange = 10;

    //координаты максимума
    globalMaxFunValue = 1.0; //33.252940767815666
    xGlobalMax        = 3.6172118548423646;
    yGlobalMax        = 4.911783359236607;

    //координаты минимума
    globalMinFunValue = 0.0; //-4.1530660577390766
    xGlobalMin        = 2.3467375713370155;
    yGlobalMin        = 5.6567339091158795;
  }

  double Core (double x, double y)
  {
    double k = 0.0;
    double X = 3.0 - x;
    double Y = 4.0 - y;

    if (x >= 0.0 && y >= 0.0)
    {
      k = 20.0;
    }

    double res = k * MathPow ((1 - X), 2) * MathExp (-X * X - (Y + 1) * (Y + 1)) - 10 * (0.2 * X - MathPow (X, 3) - MathPow (Y, 5)) * MathExp (-X * X - Y * Y) - 1 / 3 * MathExp (-(X + 1) * (X + 1) - Y * Y);

    return Scale (res, -4.1530660577390766, 33.252940767815666, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Parabola : public C_Function
{
  public: //===================================================================
  C_Parabola ()
  {
    fuName = "Parabola";

    //границы функции
    xMinRange = -10; xMaxRange = 10;
    yMinRange = -10; yMaxRange = 10;

    //координаты максимума
    globalMaxFunValue = 1;   //0
    xGlobalMax        = 0.0;
    yGlobalMax        = 0.0;

    //координаты минимума
    globalMinFunValue = 0.0; //200
    xGlobalMin        = 10;
    yGlobalMin        = 10;
  }

  double Core (double x, double y)
  {
    double res = -(x * x + y * y);
    return Scale (res, -200.0, 0.0, 0.0, 1.0);

  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Rastrigin : public C_Function
{
  public: //===================================================================
  C_Rastrigin ()
  {
    fuName = "Rastrigin";

    //границы функции
    xMinRange = -5; xMaxRange = 5;
    yMinRange = -5; yMaxRange = 5;

    //координаты максимума
    globalMaxFunValue = 1.0; //80.70658038767792
    xGlobalMax        = 4.522993657149848;
    yGlobalMax        = 4.522993657149848;

    //координаты минимума
    globalMinFunValue = 0.0; //1.2390563437933917e-14
    xGlobalMin        = 0.0;
    yGlobalMin        = 0.0;
  }

  double Core (double x, double y)
  {
    double res = 20.0 + x * x + y * y
                 - 10.0 * cos (2.0 * M_PI * x)
                 - 10.0 * cos (2.0 * M_PI * y);

    return Scale (res, 1.2390563437933917e-14, 80.70658038767792, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Forest : public C_Function
{
  public: //===================================================================
  C_Forest ()
  {
    fuName = "Forest";

    //границы функции
    xMinRange = -43.50; xMaxRange = -39;
    yMinRange = -47.35; yMaxRange = -40;

    //координаты максимума
    globalMaxFunValue = 1.0; //1.8779867959790217
    xGlobalMax        = -40.840704496667314;
    yGlobalMax        = -41.982297150257104;

    //координаты минимума
    globalMinFunValue = 0.0; //-0.26489289358875895
    xGlobalMin        = -42.2988573690385010;
    yGlobalMin        = -45.9956119113080675;
  }

  double Core (double x, double y)
  {
    double a = MathSin (MathSqrt (MathAbs (x - 1.13) + MathAbs (y - 2.0)));
    double b = MathCos (MathSqrt (MathAbs (MathSin (x))) + MathSqrt (MathAbs (MathSin (y - 2.0))));
    double f = a + b
               + 1.01 * exp (-(pow (x + 42, 2) + pow (y + 43.5, 2)) / 0.9)
               + 1.0  * exp (-(pow (x + 40.2, 2) + pow (y + 46, 2)) / 0.3);

    double res = MathPow (f, 4)
                 - 0.3  * exp (-(pow (x + 42.3, 2) + pow (y + 46.0, 2)) / 0.02);

    return Scale (res, -0.26489289358875895, 1.8779867959790217, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Megacity : public C_Function
{
  public: //===================================================================
  C_Megacity ()
  {
    fuName = "Megacity";

    //границы функции
    xMinRange = -10.0; xMaxRange = -2;
    yMinRange = -10.5; yMaxRange = 10;

    //координаты максимума
    globalMaxFunValue = 1.0; //12.0
    xGlobalMax        = -3.1357545740179393;
    yGlobalMax        = 2.006136371058429;

    //координаты минимума
    globalMinFunValue = 0.0; //-1
    xGlobalMin        = -9.5;
    yGlobalMin        = -7.5;
  }

  double Core (double x, double y)
  {
    double a = MathSin (MathSqrt (MathAbs (x - 1.13) + MathAbs (y - 2.0)));
    double b = MathCos (MathSqrt (MathAbs (MathSin (x))) + MathSqrt (MathAbs (MathSin (y - 2.0))));
    double f = a + b;

    double res = floor (MathPow (f, 4)) -
                 floor (2 * exp (-(pow (x + 9.5, 2) + pow (y + 7.5, 2)) / 0.4));

    return Scale (res, -1.0, 12.0, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Ackley : public C_Function
{
  public: //===================================================================
  C_Ackley ()
  {
    fuName = "Ackley";

    //границы функции
    xMinRange = -5; xMaxRange =  5;
    yMinRange = -5; yMaxRange =  5;

    //координаты максимума
    globalMaxFunValue = 1.0; //0.0;
    xGlobalMax        = 0.0;
    yGlobalMax        = 0.0;

    //координаты минимума
    globalMinFunValue = 0.0; //-14.302667500265278;
    xGlobalMin        = -4.597534757757757;
    yGlobalMin        = 4.597534757757757;
  }

  double Core (double x, double y)
  {
    double res1 = -20.0 * MathExp (-0.2 * MathSqrt (0.5 * (x * x + y * y)));
    double res2 = -MathExp (0.5 * (MathCos (2.0 * M_PI * x) + MathCos (2.0 * M_PI * y)));
    double res3 = -(res1 + res2 + M_E + 20.0);

    return Scale (res3, -14.302667500265278, 0.0, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_GoldsteinPrice : public C_Function
{
  public: //===================================================================
  C_GoldsteinPrice ()
  {
    fuName = "GoldsteinPrice";

    //границы функции
    xMinRange = -2;
    xMaxRange =  2;
    yMinRange = -2;
    yMaxRange =  2;

    //координаты максимума
    globalMaxFunValue = 1.0; //-3;
    xGlobalMax        = 0;
    yGlobalMax        = -1;


    //координаты минимума
    globalMinFunValue = 0.0; //-1015690.2717980597;
    xGlobalMin        = -1.7373725379666005;
    yGlobalMin        = 2;
  }

  double Core (double x, double y)
  {
    double part1 = 1 + MathPow ((x + y + 1), 2) * (19 - 14 * x + 3 * x * x - 14 * y + 6 * x * y + 3 * y * y);
    double part2 = 30 + MathPow ((2 * x - 3 * y), 2) * (18 - 32 * x + 12 * x * x + 48 * y - 36 * x * y + 27 * y * y);

    return Scale (-part1 * part2, -1015690.2717980597, -3.0, 0.0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————


//Минимум функции Шаффера N2 достигается при (x = 0) и (y = 0), и значение функции в этой точке равно 0.

//——————————————————————————————————————————————————————————————————————————————
class C_Shaffer : public C_Function
{
  public: //===================================================================
  C_Shaffer ()
  {
    fuName = "Shaffer";

    //границы функции
    xMinRange = -100;
    xMaxRange =  100;
    yMinRange = -100;
    yMaxRange =  100;

    //координаты максимума
    globalMaxFunValue = 1.0; //0.0;
    xGlobalMax        = 0.0;
    yGlobalMax        = 0.0;

    //координаты минимума
    globalMinFunValue = 0.0; //-0.9984331449753265
    xGlobalMin        = 1.253115070280703;
    yGlobalMin        = 0.0;
  }

  double Core (double x, double y)
  {
    double numerator   = MathPow (MathSin (x * x - y * y), 2) - 0.5;
    double denominator = MathPow (1 + 0.001 * (x * x + y * y), 2);

    return Scale (-(0.5 + numerator / denominator), -0.9984331449753265, 0, 0, 1.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Universe : public C_Function
{
  public: //===================================================================
  C_Universe ()
  {
    fuName = "Universe";

    //границы функции
    xMinRange = -100; xMaxRange = 100;
    yMinRange = -100; yMaxRange = 100;

    //координаты максимума
    globalMaxFunValue = 0.0;
    xGlobalMax        = 0.0;
    yGlobalMax        = 0.0;

    //координаты минимума
    globalMinFunValue = 0.0;
    xGlobalMin        = 0.0;
    yGlobalMin        = 0.0;
  }

  double Core (double x, double y)
  {
    return (0.0);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_Multiverse
{
  public: //===================================================================
  C_Multiverse ()
  {
  }
  
  C_Hilly    H;
  C_Forest   F;
  C_Megacity M;
  
  string GetFuncName ()
  {
    return ("Multiverse:" + H.GetFuncName () + ":" + F.GetFuncName () + ":" + M.GetFuncName ());
  }
  
  double hArg [2];
  double fArg [2];
  double mArg [2];

  void GetFuncRanges (double &rangeMin  [],
                      double &rangeMax  [],
                      int     amount)  //amount of runs functions, the number is a multiple of 6
  {
    ArrayResize (rangeMin, amount * 6);
    ArrayResize (rangeMax, amount * 6);

    for (int i = 0; i < amount; i++)
    {
      rangeMin [i * 6]     = H.GetMinRangeX ();
      rangeMin [i * 6 + 1] = F.GetMinRangeY ();
      rangeMin [i * 6 + 2] = M.GetMinRangeX ();
      rangeMin [i * 6 + 3] = H.GetMinRangeY ();
      rangeMin [i * 6 + 4] = F.GetMinRangeX ();
      rangeMin [i * 6 + 5] = M.GetMinRangeY ();

      rangeMax [i * 6]     = H.GetMaxRangeX ();
      rangeMax [i * 6 + 1] = F.GetMaxRangeY ();
      rangeMax [i * 6 + 2] = M.GetMaxRangeX ();
      rangeMax [i * 6 + 3] = H.GetMaxRangeY ();
      rangeMax [i * 6 + 4] = F.GetMaxRangeX ();
      rangeMax [i * 6 + 5] = M.GetMaxRangeY ();
    }
  }

  double CalcFunc (double &args [], //function arguments
                   int     amount)  //amount of runs functions
  {
    double result = 0.0;

    for (int i = 0; i < amount; i++)
    {
      hArg [0] = args [i * 6];
      hArg [1] = args [i * 6 + 3];
      
      fArg [0] = args [i * 6 + 1];
      fArg [1] = args [i * 6 + 4];
      
      mArg [0] = args [i * 6 + 2];
      mArg [1] = args [i * 6 + 5];
      
      result+= H.CalcFunc (hArg, 1);
      result+= F.CalcFunc (fArg, 1);
      result+= M.CalcFunc (mArg, 1);
    }

    return result / (3.0 * amount);
  }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//GenerateFunctionDataFixedSize
bool GenerateFunctionDataFixedSize (int x_size, int y_size, double &data [], double x_min, double x_max, double y_min, double y_max, C_Function &function)
{
  if (x_size < 2 || y_size < 2)
  {
    PrintFormat ("Error in data sizes: x_size=%d,y_size=%d", x_size, y_size);
    return (false);
  }

  double dx = (x_max - x_min) / (x_size - 1);
  double dy = (y_max - y_min) / (y_size - 1);

  ArrayResize (data, x_size * y_size);

  //---
  for (int j = 0; j < y_size; j++)
  {
    for (int i = 0; i < x_size; i++)
    {
      double x = x_min + i * dx;
      double y = y_min + j * dy;

      data [j * x_size + i] = function.Core (x, y);
    }
  }
  return (true);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
//GenerateDataFixedSize
bool GenerateDataFixedSize (int x_size, int y_size, C_Function &function, double &data [])
{
  if (x_size < 2 || y_size < 2)
  {
    PrintFormat ("Error in data sizes: x_size=%d,y_size=%d", x_size, y_size);
    return (false);
  }

  return GenerateFunctionDataFixedSize (x_size, y_size, data,
                                        function.GetMinRangeX (),
                                        function.GetMaxRangeX (),
                                        function.GetMinRangeY (),
                                        function.GetMaxRangeY (),
                                        function);
}
//——————————————————————————————————————————————————————————————————————————————
