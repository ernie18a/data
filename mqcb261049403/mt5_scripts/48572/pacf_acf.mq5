//+------------------------------------------------------------------+
//|                                                     PACF_ACF.mq5 |
//|                                                         vp999369 |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "vp999369"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs
#include <Math\Stat\Math.mqh>
#include <Graphics\Graphic.mqh>
//--- input parameters
input int N      =100;  // data window for calculation (bars)
input int K       =16;  // lags
input int start_pos=0;  // data window offset (bars)
input int duration=10;  // duration of graph display (sec)
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int i,j,M;
   double avg;
   double close_price[],acov[],acf[],pacf[],c[],se[],se2[],log_c[];
   vector x;
   matrix m3;

   CopyClose(Symbol(),PERIOD_CURRENT,start_pos,N+1,close_price);

   ArrayResize(log_c,N);
   for(i=0; i<N; i++)
     {
      log_c[i] = MathLog(close_price[i+1]/close_price[i]); // log return
     }

   avg = MathMean(log_c); // average of sample N

//////////////////////////  ACF calculation /////////////////////////////////////////
   ArrayResize(acov,K);
   ArrayResize(acf,K);
   ArrayResize(se,K);
   ArrayResize(se2,K);
   for(i=0; i<K; i++)
     {
      ArrayResize(c,N-i);
      for(j=0; j<N-i; j++)
        {
         c[j] = (log_c[j]-avg)*(log_c[j+i]-avg);
        }
      acov[i] = double(MathSum(c)/N);   // autocovariation
      acf [i] = acov[i]/acov [0];      // autocorrelation
      se[i] = 1.96/MathSqrt(N);       // 95% confidence intervals
      se2[i] = -1.96/MathSqrt(N);
     }
   Print("ACF");
   ArrayPrint(acf,3);
////////////////////////////////////////////////////////////////////////////////

   ArrayResize(pacf,K);
   pacf[0] = acf[0];  // PACF for zero lag(0) = 1 
   pacf[1] = acf[1];  // PACF for lag(1) = ACF(1)

///////////////////  PACF calculation ///////////////////////////////////////////////////
   for(M=3; M<=K; M++)
     {
      /*
       To calculate PACF you need to solve a system of linear equations,
        toeplitz * x = y;
        But to do this, we first need to create a symmetric Toeplitz matrix
        from the vector of the autocorrelation function.
        toeplitz - Toeplitz matrix composed of a vector ACF[0:M-2];
        y - is a known vector ACF[1:M-1];
        x - is an unknown vector to be determined [1:M-1],
         the last element of which will be the desired PACF value of order M-1
      */

      ////////////// Forming the Toeplitz matrix ////////////////////////////////////////////////////////
      double rr[];
      ArrayCopy(rr,acf,0,0,M-1);
      double rr1[];
      ArrayResize(rr1,M-2);
      for(i=0; i<M-2; i++)
        {
         rr1[i] = rr[M-2-i];
        }
      ArrayCopy(rr1,rr,M-2,0);
      vector v1 = vector::Zeros(M-1);
      vector v2 = vector::Zeros(M-1);
      for(i=0; i<M-1; i++)
        {
         v1[i] = i;
         v2[i] = M-1-i;
        }
      matrix m1 = matrix::Zeros(M-1,M-1);
      matrix m2 = matrix::Zeros(M-1,M-1);
      for(i=0; i<M-1; i++)
        {
         m1.Col(v1,i);
         m2.Row(v2,i);
        }

      m3 = m1+m2;
      matrix toeplitz = matrix::Zeros(M-1,M-1);
      for(i=0; i<M-1; i++)
        {
         for(j=0; j<M-1; j++)
           {
            toeplitz[i,j] = rr1[int(m3[i,j])-1];  // Toeplitz matrix
           }
        }

      ////////////////////////////////////////////////////////////////////////////////////////////////////
      vector y = vector::Zeros(M-1);
      for(i=0; i<M-1; i++)
        {
         y[i] = acf[i+1];  //  vector y
        }
      x=toeplitz.Solve(y); // Solve linear system of equations
      pacf[M-1] = x[M-2];  //write down the desired PACF value

     }
   Print("PACF");
   ArrayPrint(pacf,3);

/////////////////////////////////////////////////
//Plot  ACF,PACF                       //////////
/////////////////////////////////////////////////

   ChartSetInteger(0,CHART_SHOW,false);
   CGraphic graphic;
   CGraphic graphic1;

   if(ObjectFind(0,"Graphic")<0)
     {
      graphic.Create(0,"Graphic",0,0,0,550,550);
      graphic1.Create(0,"Graphic1",0,550,0,1050,550);
     }
   else
      graphic.Attach(0,"Graphic");
   graphic1.Attach(0,"Graphic1");

   CCurve *curve = graphic.CurveAdd(pacf,ColorToARGB(clrBlue,255),CURVE_HISTOGRAM,"PACF");
   CCurve *curve4 = graphic.CurveAdd(se,ColorToARGB(clrBlack,255),CURVE_LINES,"SE 95%");
   CCurve *curve5 = graphic.CurveAdd(se2,ColorToARGB(clrBlack,255),CURVE_LINES,"SE 95%");
   CCurve *curve1 = graphic1.CurveAdd(acf,ColorToARGB(clrRed,255),CURVE_HISTOGRAM,"ACF");
   CCurve *curve2 = graphic1.CurveAdd(se,ColorToARGB(clrBlack,255),CURVE_LINES,"SE 95%");
   CCurve *curve3 = graphic1.CurveAdd(se2,ColorToARGB(clrBlack,255),CURVE_LINES,"SE 95%");

   graphic.BackgroundColor(ColorToARGB(clrAzure,255));
   graphic.BackgroundMain("Sample PACF");
   graphic1.BackgroundMain("Sample ACF");
   graphic.BackgroundMainColor(ColorToARGB(clrBlack,255));
   graphic.BackgroundMainSize(25);
   graphic1.BackgroundMainSize(25);
   graphic.BackgroundSubColor(ColorToARGB(clrBlack,255));
   graphic.BackgroundSubSize(15);
   graphic1.BackgroundSubSize(15);
   graphic.XAxis().Name("Lags");
   graphic.XAxis().NameSize(15);
   graphic1.XAxis().Name("Lags");
   graphic1.XAxis().NameSize(15);
   graphic.YAxis().NameSize(15);

   curve.HistogramWidth(5);
   curve1.HistogramWidth(5);
   curve2.LinesStyle(STYLE_DOT);
   curve2.LinesWidth(2);
   curve3.LinesStyle(STYLE_DOT);
   curve3.LinesWidth(2);
   curve4.LinesStyle(STYLE_DOT);
   curve4.LinesWidth(2);
   curve5.LinesStyle(STYLE_DOT);
   curve5.LinesWidth(2);


   graphic.CurvePlotAll();
   graphic1.CurvePlotAll();
   graphic.Update();
   graphic1.Update();

   Sleep(duration*1000);
   ChartSetInteger(0,CHART_SHOW,true);
   graphic.Destroy();
   graphic1.Destroy();
   ChartRedraw(0);

  }
//+------------------------------------------------------------------+
