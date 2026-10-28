//+------------------------------------------------------------------+
//|                                       TestL1TrendFloatDouble.mq5 |
//|                             Copyright 2000-2026, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2026, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#include <Graphics\Graphic.mqh>

uint32_t ExtSeed=1;
//+------------------------------------------------------------------+
//| Generate Brown movement data                                     |
//+------------------------------------------------------------------+
template<typename T>
void BMData(vector<T> &data,uint64_t data_count)
  {
   MathSrand(ExtSeed);

   data.Resize(data_count);
   data[0] = 0.0;

   for(uint64_t i=1; i<data_count; i++)
      data[i] = data[i-1] + T(MathRand()/32767.0 - 0.5);
  }
//+------------------------------------------------------------------+
//| CopyValues                                                       |
//+------------------------------------------------------------------+
template<typename T>
bool CopyValues(double &data[],const vector<T> &data_v)
  {
   if(ArrayResize(data,data.Size())!=data.Size())
      return(false);
   for(uint64_t i=0; i<data.Size(); i++)
      data[i]=data_v[i];

   return(true);
  }
//+------------------------------------------------------------------+
//| L1TrendCalculate                                                 |
//+------------------------------------------------------------------+
template<typename T>
bool L1TrendCalculate(double &result[],uint64_t data_count,double lambda,bool lambda_is_relative)
  {
   vector<T> data_test;
   BMData(data_test,data_count);

   vector<T> vres;
   if(!data_test.L1TrendFilter((T)lambda,lambda_is_relative,vres))
      return(false);
   if(ArrayResize(result,(uint32_t)vres.Size())!=vres.Size())
      return(false);
   for(uint64_t n=0; n<result.Size(); n++)
      result[n]=vres[n];

   return(true);
  }
//+------------------------------------------------------------------+
//| TestRun                                                          |
//+------------------------------------------------------------------+
bool TestRun(uint32_t data_count,uint32_t mode)
  {
//--- create graph
   CGraphic graphic;
   long     chart=0;
   string   name="L1TrendTest";

   if(ObjectFind(chart,name)<0)
      graphic.Create(chart,name,0,0,0,1280,600);
   else
      graphic.Attach(chart,name);

   string mode_name="(";
   if((mode&1)==1)
      mode_name+="DOUBLE";
   if((mode&3)==3)
      mode_name+=" & ";
   if((mode&2)==2)
      mode_name+="FLOAT";
   mode_name+=")";

   graphic.BackgroundMain("L1Trend filtering (random walk) with different lambda "+mode_name);
   graphic.BackgroundMainSize(16);
   graphic.HistoryNameWidth(60);
   graphic.HistoryColor(ColorToARGB(clrGray,255));
   graphic.XAxis().AutoScale(false);
   graphic.XAxis().Min(0);
   graphic.XAxis().Max(data_count);
//--- prepare arrays
   double x[];
   double y[];

   if(ArrayResize(x,data_count)!=data_count)
      return(false);
  
   for(uint32_t i=0; i<data_count; i++)
      x[i]=i;

   vector<double> v;
   BMData(v,data_count);
   v.Swap(y);
   graphic.CurveAdd(x,y,CURVE_LINES,"Data").LinesWidth(1);
//--- calculate
   const double lambda_factors[]= {1.0,0.9,0.8,0.5,0.25,0.1,0.01,0.05,0.001,0.0005};
//--- double
   if((mode&1)==1)
     {
      for(uint64_t i=0; i<lambda_factors.Size(); i++)
        {
         if(L1TrendCalculate<double>(y,data_count,lambda_factors[i],true))
            graphic.CurveAdd(x,y,CURVE_LINES,"DBL="+DoubleToString(lambda_factors[i],4)).LinesWidth(4);
        }
     }
//--- float
   if((mode&2)==2)
     {
      for(uint64_t i=0; i<lambda_factors.Size(); i++)
        {
         if(L1TrendCalculate<float>(y,data_count,(float)lambda_factors[i],true))
            graphic.CurveAdd(x,y,CURVE_LINES,"FLT="+DoubleToString(lambda_factors[i],4)).LinesWidth(2);
        }
     }
//--- update
   graphic.CurvePlotAll();
   graphic.Update();
   return(true);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   for(uint32_t n=0; !IsStopped(); n++,Sleep(1000))
     {
      TestRun(1000,1+n%3);

      if((n%3)==2)
         ExtSeed++;
     }
  }
//+------------------------------------------------------------------+