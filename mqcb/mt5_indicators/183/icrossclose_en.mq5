//+------------------------------------------------------------------+
//|                                                  iCrossClose.mq5 |
//|                                              Copyright dmffx.com |
//|                                                 http://dmffx.com |
//+------------------------------------------------------------------+
#property copyright "dmffx.com"
#property link      "http://dmffx.com"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//---- plot MA
#property indicator_label1  "CrossClose";
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters

enum eAA
  {
   Add=1,
   Subtract=2,
   Multiply=3,
   Divide=4
  };

input string   S1_Symbol            =  "EURUSD";   /*S1_Symbol*/           // Symbol 1
input bool     S1_Invert            =  false;      /*S1_Invert*/           // Flag to invert the value of symbol 1 (value=1.0/value)
input double   S1_K                 =  1.0;        /*S1_K */               // Multiplication coefficient of the symbol 1 (value=K*value)
input double   S1_Plus              =  0;          /*S1_Plus*/             // Addition to the symbol 1 (value=Plus+value). The operations priority is the following: invert, multiplication, addition.
input string   S2_Symbol            =  "GBPUSD";   /*S2_Symbol*/           // Symbol 2
input bool     S2_Invert            =  false;      /*S2_Invert*/           // Flag to invert the value of symbol 2
input double   S2_K                 =  1.0;        /*S2_K*/                // Multiplication coefficient of the symbol 2
input double   S2_Plus              =  0;          /*S2_Plus*/             // Addition to the symbol 2
input eAA      R_ArithmeticAction   =  Divide;     /*R_ArithmeticAction*/  // Arithmetic Action
input bool     R_Invert             =  false;      /*R_Invert*/            // Flag to invert the result of Arithmetic Action result
input double   R_K                  =  1.0;        /*R_K*/                 // Multiplication coefficient for the resu;t
input double   R_Plus               =  0;          /*R_Plus*/              // Addition to the result

double         Buffer[];
int MAHand;

ENUM_TIMEFRAMES TF;
int TimeX=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   int limit;
   static bool err=false;
   double mav1[1];
   double mav2[1];
   datetime tm1[1];
   datetime tm2[1];

   if(prev_calculated<=0 || err)
     {
      if(!SymbolSelect(S1_Symbol,true))
        {
         Alert("No symbol "+S1_Symbol);
         Buffer[rates_total-1]=EMPTY_VALUE;
         err=true;
         return(0);
        }
      if(!SymbolSelect(S2_Symbol,true))
        {
         Alert("No symbol "+S2_Symbol);
         Buffer[rates_total-1]=EMPTY_VALUE;
         err=true;
         return(0);
        }
      limit=1;
      int b1=Bars(S1_Symbol,PERIOD_CURRENT);
      int b2=Bars(S2_Symbol,PERIOD_CURRENT);
      if(b1==0 || b2==0)
        {
         Comment(MQL5InfoString(MQL5_PROGRAM_NAME)+": Please wait...");
         Buffer[rates_total-1]=EMPTY_VALUE;
         err=true;
         return(0);
        }
      int cr1=CopyTime(S1_Symbol,PERIOD_CURRENT,b1-1,1,tm1);
      int cr2=CopyTime(S2_Symbol,PERIOD_CURRENT,b2-1,1,tm2);
      if(cr1==-1 || cr2==-1)
        {
         Buffer[rates_total-1]=EMPTY_VALUE;
         err=true;
         return(0);
        }
      for(int i=0;i<rates_total;i++)
        {
         if(time[i]>=tm1[0] && time[i]>=tm2[0])
           {
            limit=i+1;
            break;
           }
        }
      if(err)
        {
         Comment("");
         err=false;
        }
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,limit);
     }
   else
     {
      limit=prev_calculated-1;

     }

   for(int i=limit;i<rates_total;i++)
     {

      CopyClose(S1_Symbol,PERIOD_CURRENT,time[i],1,mav1);
      CopyClose(S2_Symbol,PERIOD_CURRENT,time[i],1,mav2);

      if(mav1[0]==0 || mav2[0]==0)
        {
         Buffer[i]=Buffer[i-1];
         continue;
        }
      if(S1_Invert)
        {
         mav1[0]=1.0/mav1[0];
        }
      if(S2_Invert)
        {
         mav2[0]=1.0/mav2[0];
        }

      mav1[0]*=S1_K;
      mav2[0]*=S2_K;

      mav1[0]+=S1_Plus;
      mav2[0]+=S1_Plus;

      switch(R_ArithmeticAction)
        {
         case 1:
            Buffer[i]=mav1[0]+mav2[0];
            break;
         case 2:
            Buffer[i]=mav1[0]-mav2[0];
            break;
         case 3:
            Buffer[i]=mav1[0]*mav2[0];
            break;
         case 4:
            if(mav2[0]==0)
              {
               Buffer[i]=Buffer[i-1];
              }
            else
              {
               Buffer[i]=mav1[0]/mav2[0];
              }
            break;
        }

      if(R_Invert)
        {
         if(Buffer[i]==0)
           {
            Buffer[i]=Buffer[i-1];
           }
         else
           {
            Buffer[i]=1.0/Buffer[i];
           }
        }

      Buffer[i]*=R_K;
      Buffer[i]+=R_Plus;

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
