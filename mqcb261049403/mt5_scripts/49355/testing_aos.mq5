//+----------------------------------------------------------------------------+
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//+----------------------------------------------------------------------------+
#property copyright "Copyright 2007-2024, JQS aka Joo."
#property link      "https://www.mql5.com/ru/users/joo"
#property version   "1.00"
#property script_show_inputs

#include <Math\AOs\TestFunctions.mqh>
#include <Math\AOs\TestStandFunctions.mqh>
#include <Math\AOs\PopulationAO\#C_AO.mqh>
#include <Math\AOs\PopulationAO\#C_AO_enum.mqh>



//——————————————————————————————————————————————————————————————————————————————
input string AOparam            = "----------------"; //AO parameters-----------
input E_AO   AOexactly_P        = NONE_AO;

input string TestStand_1        = "----------------"; //Test stand--------------
input double ArgumentStep_P     = 0.0;   //Argument Step

input string TestStand_2        = "----------------"; //------------------------
input int    Test1FuncRuns_P    = 5;     //Test #1: Number of functions in the test
input int    Test2FuncRuns_P    = 25;    //Test #2: Number of functions in the test
input int    Test3FuncRuns_P    = 500;   //Test #3: Number of functions in the test

input string TestStand_3        = "----------------"; //------------------------
input EFunc  Function1          = Hilly;
input EFunc  Function2          = Forest;
input EFunc  Function3          = Megacity;

input string TestStand_4        = "----------------"; //------------------------
input int    NumbTestFuncRuns_P = 10000; //Number of test function runs
input int    NumberRepetTest_P  = 10;    //Test repets number

input string TestStand_5        = "----------------"; //------------------------
input bool   Video_P            = true;  //Show video
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void OnStart ()
{
  C_AO *AO = SelectAO (AOexactly_P);

  if (AO == NULL)
  {
    Print ("AO is not selected...");
    return;
  }

  Print (AO.GetName (), "|", AO.GetDesc (), "|", AO.GetParams ());

  //============================================================================
  C_TestStand ST; //stand
  ST.Init (750, 375);

  double allScore = 0.0;
  double allTests = 0.0;

  C_Function *F1 = SelectFunction (Function1);
  C_Function *F2 = SelectFunction (Function2);
  C_Function *F3 = SelectFunction (Function3);

  if (F1 != NULL)
  {
    Print ("=============================");
    ST.CanvasErase ();

    FuncTests (AO, ST, F1, Test1FuncRuns_P, clrLime,      allScore, allTests);
    FuncTests (AO, ST, F1, Test2FuncRuns_P, clrAqua,      allScore, allTests);
    FuncTests (AO, ST, F1, Test3FuncRuns_P, clrOrangeRed, allScore, allTests);
    delete F1;
  }

  if (F2 != NULL)
  {
    Print ("=============================");
    ST.CanvasErase ();
    FuncTests (AO, ST, F2, Test1FuncRuns_P, clrLime,      allScore, allTests);
    FuncTests (AO, ST, F2, Test2FuncRuns_P, clrAqua,      allScore, allTests);
    FuncTests (AO, ST, F2, Test3FuncRuns_P, clrOrangeRed, allScore, allTests);
    delete F2;
  }

  if (F3 != NULL)
  {
    Print ("=============================");
    ST.CanvasErase ();
    FuncTests (AO, ST, F3, Test1FuncRuns_P, clrLime,      allScore, allTests);
    FuncTests (AO, ST, F3, Test2FuncRuns_P, clrAqua,      allScore, allTests);
    FuncTests (AO, ST, F3, Test3FuncRuns_P, clrOrangeRed, allScore, allTests);
    delete F3;
  }

  Print ("=============================");
  if (allTests > 0.0) Print ("All score: ", DoubleToString (allScore, 5), " (", DoubleToString (allScore * 100 / allTests, 2), "%)");
  delete AO;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void FuncTests (C_AO          &ao,
                C_TestStand   &st,
                C_Function    &f,
                const  int     funcCount,
                const  color   clrConv,
                double        &allScore,
                double        &allTests)
{
  if (funcCount <= 0) return;

  allTests++;

  if (Video_P)
  {
    st.DrawFunctionGraph (f);
    st.SendGraphToCanvas ();
    st.MaxMinDr          (f);
    st.Update            ();
  }

  int    xConv      = 0.0;
  int    yConv      = 0.0;
  double aveResult  = 0.0;
  int    params     = funcCount * 2;
  int    epochCount = NumbTestFuncRuns_P / (int)ao.params [0].val;

  //----------------------------------------------------------------------------
  double rangeMin  [], rangeMax  [], rangeStep [];
  ArrayResize (rangeMin,  params);
  ArrayResize (rangeMax,  params);
  ArrayResize (rangeStep, params);

  for (int i = 0; i < funcCount; i++)
  {
    rangeMax  [i * 2] = f.GetMaxRangeX ();
    rangeMin  [i * 2] = f.GetMinRangeX ();
    rangeStep [i * 2] = ArgumentStep_P;

    rangeMax  [i * 2 + 1] = f.GetMaxRangeY ();
    rangeMin  [i * 2 + 1] = f.GetMinRangeY ();
    rangeStep [i * 2 + 1] = ArgumentStep_P;
  }

  for (int test = 0; test < NumberRepetTest_P; test++)
  {
    //--------------------------------------------------------------------------
    if (!ao.Init (rangeMin, rangeMax, rangeStep, epochCount)) break;

    // Optimization-------------------------------------------------------------
    for (int epochCNT = 1; epochCNT <= epochCount && !IsStopped (); epochCNT++)
    {
      ao.Moving ();

      for (int set = 0; set < ArraySize (ao.a); set++)
      {
        ao.a [set].f = f.CalcFunc (ao.a [set].c, funcCount);
      }

      ao.Revision  ();

      if (Video_P)
      {
        //drawing a population--------------------------------------------------
        st.SendGraphToCanvas  ();

        for (int i = 0; i < ArraySize (ao.a); i++)
        {
          st.PointDr (ao.a [i].c, f, 1, 1, funcCount, false);
        }
        st.PointDr (ao.cB, f, 1, 1, funcCount, true);

        st.MaxMinDr (f);

        //drawing a convergence graph---------------------------------------------
        xConv = (int)st.Scale (epochCNT, 1, epochCount, st.H + 2, st.W - 3, false);
        yConv = (int)st.Scale (ao.fB, f.GetMinFunValue (), f.GetMaxFunValue (), 2, st.H - 2, true);
        st.Canvas.FillCircle (xConv, yConv, 1, COLOR2RGB (clrConv));

        st.Update ();
      }
    }

    aveResult += ao.fB;
  }

  aveResult /= (double)NumberRepetTest_P;

  double score = aveResult;

  Print (funcCount, " ", f.GetFuncName (), "'s; Func runs: ", NumbTestFuncRuns_P, "; result: ", aveResult);
  allScore += score;
}
//——————————————————————————————————————————————————————————————————————————————