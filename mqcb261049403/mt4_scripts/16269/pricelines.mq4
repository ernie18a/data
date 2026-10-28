//+------------------------------------------------------------------+
//|                                             PriceLines.mq4 
//|                                             Alexey Volchanskiy 
//|                                             http://mql.gnomio.com 
//|  
//+------------------------------------------------------------------+
#property copyright "Alexey Volchanskiy 2016"
#property link      "http://mql.gnomio.com"
#property version "2.15"
#property description "The script Price Lines marks price levels on the chart"
#property description "It helps to recognize the currency fluctuation in one touch"

#property show_inputs
#property strict

extern bool     DeleteLines = false;
extern bool     AutoRange   = true;
extern double   BeginPrice  = 1.0;
extern double   EndPrice    = 1.7;
extern int      Step        = 25;
extern int      Step2       = 100;
extern string   LineName    = "PrLn";
extern color    LineColor1  = Yellow;
extern color    LineColor2  = Gold;
extern int      Width1      = 1;
extern int      Width2      = 2;

double step,begin,end;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
   begin=BeginPrice;
   end=EndPrice;
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
      if(BeginInt%Step2==0)
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
      bool res=ObjectCreate(name,OBJ_HLINE,0,0,pBegin);
      ObjectSet(name,OBJPROP_COLOR,clr);
      ObjectSet(name,OBJPROP_STYLE,STYLE_DASH);
      ObjectSet(name,OBJPROP_WIDTH,width);
      pBegin+=step;
      lnum++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteHLines()
  {
   int nL=ObjectsTotal();
   string name;
   for(int n=nL-1; n>=0; n--) // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! только по убыванию
     {
      name=ObjectName(n);
      if(ObjectType(name)!=OBJ_HLINE)
         continue;
      int nch= StringFind(name,LineName);
      if(nch == 0)
         ObjectDelete(name);
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
   Step2*=k1;
   if(!AutoRange) return;
   double min = WindowPriceMin();
   double max = WindowPriceMax();
   double range=(max-min)*3;
   max += range;
   min -= range;
   begin= StrToDouble(DoubleToStr(min,RoundBegin));
   end=max;
   return;
  }
//+------------------------------------------------------------------+
