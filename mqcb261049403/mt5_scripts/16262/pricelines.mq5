//+------------------------------------------------------------------+
//|                                         PriceLines.mq5 
//|                                         Alexey Volchanskiy 
//|                                         http://mql.gnomio.com
//|  
//+------------------------------------------------------------------+
#property copyright "Alexey Volchanskiy 2016"
#property link      "http://mql.gnomio.com"
#property version "2.15"
#property description "The script Price Lines marks price levels on the chart"
#property description "It helps to recognize the currency fluctuation in one touch"

#property script_show_inputs

input bool     DeleteLines = false;
input bool     AutoRange   = true;
input double   BeginPrice  = 1.0;
input double   EndPrice    = 1.7;
input int      Step        = 25;
input int      Step2       = 100;
input string   LineName    = "PrLn";
input color    LineColor1  = Yellow;
input color    LineColor2  = clrCornsilk;
input int      Width1      = 1;
input int      Width2      = 2;

double step,begin,end;
int step2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
   begin=BeginPrice;
   end=EndPrice;
   step2=Step2;
   CalculateRange();
   DeleteHLines();
   if(!DeleteLines)
      DrawHLines(begin,end);
   else
      DeleteHLines();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHLines(double pBegin,double pEnd)
  {
   int lnum=0;
   color clr;
   int width,BeginInt;
   while(pBegin<pEnd)
     {
      BeginInt=(int)MathRound(pBegin*MathPow(10,Digits()));
      if(BeginInt%step2==0)
        {
         clr=LineColor2;
         width=Width2;
        }
      else
        {
         clr=LineColor1;
         width=Width1;
        }
      string name=LineName+IntegerToString(lnum);
      bool res=ObjectCreate(0,name,OBJ_HLINE,0,0,pBegin);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
      pBegin+=step;
      lnum++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteHLines()
  {
   int nL=ObjectsTotal(0,0,OBJ_HLINE);
   string name;
   for(int n=nL-1; n>=0; n--) // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! только по убыванию
     {
      name=ObjectName(0,n,0,OBJ_HLINE);
      if(ObjectGetInteger(0,name,OBJPROP_TYPE)!=OBJ_HLINE)
         continue;
      int nch= StringFind(name,LineName);
      if(nch == 0)
         ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateRange()
  {
   int k1=1;   // коэффициент точности, для 4-хзнаковых ДЦ = 1, для 5-тизнака = 10
   int RoundBegin=_Digits-2;
   if(_Digits==5)
     {
      k1=10;
      RoundBegin-=1;
     }
   step=Step/MathPow(10,_Digits)*k1;
   step2*=k1;
   if(!AutoRange) return;
   double min = ChartGetDouble(0,CHART_PRICE_MIN);
   double max = ChartGetDouble(0,CHART_PRICE_MAX);
   double range=(max-min)*3;
   max += range;
   min -= range;
   begin= StringToDouble(DoubleToString(min,RoundBegin));
   end=max;
   return;
  }
//+------------------------------------------------------------------+
