//+------------------------------------------------------------------+
//|                                      cointegration_indicator.mq5 |
//|                                 Copyright 2017, Max Dmitrievskiy |
//|                        https://www.mql5.com/ru/users/dmitrievsky |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 30
#property indicator_plots   30
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMaroon
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkOrange
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMidnightBlue
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOlive
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlueViolet
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkMagenta
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrChartreuse
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrBlue
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrBlueViolet
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrBrown
#property indicator_type12   DRAW_LINE
#property indicator_color12  clrBurlyWood
#property indicator_type13   DRAW_LINE
#property indicator_color13  clrChartreuse
#property indicator_type14   DRAW_LINE
#property indicator_color14  clrChocolate
#property indicator_type15   DRAW_LINE
#property indicator_color15  clrCoral
#property indicator_type16   DRAW_LINE
#property indicator_color16  clrCornflowerBlue
#property indicator_type17   DRAW_LINE
#property indicator_color17  clrCornsilk
#property indicator_type18   DRAW_LINE
#property indicator_color18  clrCrimson
#property indicator_type19   DRAW_LINE
#property indicator_color19  clrCyan
#property indicator_type20   DRAW_LINE
#property indicator_color20  clrDarkBlue
#property indicator_type21   DRAW_LINE
#property indicator_color21  clrDarkBlue
#property indicator_type22   DRAW_LINE
#property indicator_color22  clrDarkBlue
#property indicator_type23   DRAW_LINE
#property indicator_color23  clrDarkBlue
#property indicator_type24   DRAW_LINE
#property indicator_color24  clrDarkBlue
#property indicator_type25   DRAW_LINE
#property indicator_color25  clrDarkBlue
#property indicator_type26   DRAW_LINE
#property indicator_color26  clrDarkBlue
#property indicator_type27   DRAW_LINE
#property indicator_color27  clrDarkBlue
#property indicator_type28   DRAW_LINE
#property indicator_color28  clrDarkBlue
#property indicator_type29   DRAW_LINE
#property indicator_color29  clrDarkBlue
#property indicator_type30   DRAW_LINE
#property indicator_color30  clrDarkBlue


#include <Math\Alglib\alglib.mqh>
#include <Math\Stat\Math.mqh>

CLinReg linear_regression;
CLinearModel linear_model;
CLRReport linear_report;
int retcode;

CMatrixDouble LRmatrix;

input int learning_depth = 500;
input string SymbolsList = "AUDUSD,GBPUSD,NZDUSD";

double mainsynthetic[], zscore[];
int splittedPairsNumber;
string splittedPairs[];

static datetime last_time = 0;

struct spreads
 {
  string symbol;
  double spreadBuffer[];
  double pricesBuffer[];
  double zscore[];
  double weights[];
 };
 
spreads allspreads[];
bool second_call=false;

int OnInit()
  {
//--- indicator buffers mapping
   string sep = ",";
   ushort u_sep;
   u_sep = StringGetCharacter(sep,0);
   splittedPairsNumber = StringSplit(SymbolsList, u_sep, splittedPairs);
   ArrayResize(allspreads, splittedPairsNumber);
    
   string smbls;
   if (splittedPairsNumber > 0)
    {
     for (int i=0; i < splittedPairsNumber; i++)
      {
       getSymbolByName(splittedPairs[i]);
       SetIndexBuffer(i,allspreads[i].zscore, INDICATOR_DATA);
       ArraySetAsSeries(allspreads[i].spreadBuffer, true);
       ArrayResize(allspreads[i].spreadBuffer, learning_depth);
       ArrayResize(allspreads[i].pricesBuffer,learning_depth);
       ArraySetAsSeries(allspreads[i].pricesBuffer,true);
       ArrayInitialize(allspreads[i].pricesBuffer,0);
       ArrayResize(allspreads[i].weights,splittedPairsNumber);
       ArraySetAsSeries(allspreads[i].zscore, true);
       ArrayInitialize(allspreads[i].zscore, 0);    
       allspreads[i].symbol = splittedPairs[i];
       PlotIndexSetString(i, PLOT_LABEL, allspreads[i].symbol); 
       PlotIndexSetInteger(i,PLOT_LINE_WIDTH, 2);
       smbls += (splittedPairs[i] + ", ") ;  
      }
    }
   SetIndexBuffer(splittedPairsNumber, zscore, INDICATOR_DATA);
   PlotIndexSetInteger(splittedPairsNumber, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(splittedPairsNumber, PLOT_LINE_STYLE, STYLE_DOT);
   
   PlotIndexSetInteger(splittedPairsNumber, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(splittedPairsNumber, PLOT_LINE_COLOR, clrSilver);
   PlotIndexSetString(splittedPairsNumber, PLOT_LABEL, "Z-SCORE");
     
   LRmatrix.Resize(learning_depth, splittedPairsNumber);
   ArrayResize(mainsynthetic, learning_depth);
   ArraySetAsSeries(mainsynthetic, true);
   ArrayResize(zscore, learning_depth);
   ArraySetAsSeries(zscore, true);
   ArrayInitialize(mainsynthetic,0);
   ArrayInitialize(zscore,0);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Z-score: " + smbls);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);  
   IndicatorSetInteger(INDICATOR_LEVELS, 6);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, -1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, 2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 3, -2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 4, 3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 5, -3);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      
                 const int prev_calculated,  
                 const int begin,            
                 const double& price[])       
  {
   bool first_call=(prev_calculated==0);
     
   if(first_call || second_call)
    {
     if(fillPricesToBuffers(learning_depth))
      {
       fillLRmatrixes(); 
       calculateSpreads(learning_depth);
       calculateMainSynthetic(learning_depth);
       second_call=false;
      } else second_call=true;
    }
    
   if(isNewBar())
    {
     if(fillPricesToBuffers(learning_depth))
      {
       fillLRmatrixes(); 
       calculateSpreads(learning_depth);
       calculateMainSynthetic(learning_depth);
       second_call=false;
      } else second_call=true;
    }
   
   if(!second_call)
    {
     fillPricesToBuffers(1);
     calculateSpreads(1); 
     calculateMainSynthetic(learning_depth);
    }
   return(rates_total);
  }
//+------------------------------------------------------------------+

bool fillPricesToBuffers(int depth)
 {
  for (int l = 0; l<ArraySize(allspreads); l++)
   {
    int copied = CopyClose(allspreads[l].symbol, PERIOD_CURRENT, 0, learning_depth, allspreads[l].pricesBuffer);
     Comment("");
    if (copied != learning_depth)
     {
      Comment("Update " + allspreads[l].symbol + ", waiting for quotes to be downloaded!");
      return (false);
     }
   }
  return(true);
 }

void fillLRmatrixes()
 {
  for (int k = 0; k<ArraySize(allspreads); k++)
   {
    int n=0;    
    for(int l = 0; l<ArraySize(allspreads); l++)
     {
      if(l==k) continue;
    
      for(int i=0;i<learning_depth;i++) 
       {     
        LRmatrix[i].Set(n,allspreads[l].pricesBuffer[i]); 
       }
      n++;
     }
   
    for(int i=0;i<learning_depth;i++) 
     {     
      LRmatrix[i].Set(splittedPairsNumber-1,allspreads[k].pricesBuffer[i]);
     }
     
    linear_regression.LRBuild(LRmatrix,learning_depth,splittedPairsNumber-1,retcode,linear_model,linear_report);
    //Print(linear_report.m_cvrmserror);
    int nvars; 
    linear_regression.LRUnpack(linear_model,allspreads[k].weights,nvars); 
   }      
 }

void calculateSpreads(int depth)
 {
  for (int k = 0; k<ArraySize(allspreads); k++)
   {
    double summKoeffForIndex=0;
    for(int i=depth-1;i>=0;i--) 
     {
      int n=0;  
      for(int l = 0; l < ArraySize(allspreads); l++)
       {
        if(l == k) continue; 
        summKoeffForIndex += allspreads[l].pricesBuffer[i] * allspreads[k].weights[n]; 
        n++;     
       }  
      allspreads[k].spreadBuffer[i]=allspreads[k].pricesBuffer[i]-(summKoeffForIndex+allspreads[k].weights[ArraySize(allspreads)-1]);
      summKoeffForIndex=0;
     }
    
   double std = MathStandardDeviation(allspreads[k].spreadBuffer);
   for(int i=depth-1;i>=0;i--)
    {
     allspreads[k].zscore[i]=allspreads[k].spreadBuffer[i]/std;
    } 
   }
 }
  
void calculateMainSynthetic(int depth)
 {
  ArrayInitialize(zscore,0);
  for(int i=depth-1;i>=0;i--)
   {
    for(int l = 0; l<ArraySize(allspreads); l++)
     {
      zscore[i]+=allspreads[l].zscore[i];
     }
   }
 }
 
bool isNewBar()
 {
  datetime lastbar_time=datetime(SeriesInfoInteger(Symbol(),_Period,SERIES_LASTBAR_DATE));
  if(last_time==0)
   {
    last_time=lastbar_time;
    return(false);
   }
  if(last_time!=lastbar_time)
   {
    last_time=lastbar_time;
    return(true);
   }
  return(false);
 }

string getSymbolByName(string symbol)
 {
  string symbol_name="";
  if(symbol=="")
     return("");
  for(int s=0; s<SymbolsTotal(false); s++)
   {
    symbol_name=SymbolName(s,false);
    if(symbol==symbol_name)
     {
      SymbolSelect(symbol,true);
      return(symbol);
     }
   }
  Alert("The symbol "+symbol+" is not present on the server, please change symbol name!");
  return("");
 }