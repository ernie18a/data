//+------------------------------------------------------------------+
//|                                           Volatility Scanner.mq4 |
//|                                                    Jan Opocensky |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opocensky"
#property link      ""
#property version   "210520"
#property strict
#property indicator_chart_window
//-------------------------------------------------------------------------
int X_pozice_pocatek=200;
int Y_pozice_pocatek=10;
int X_rectangle_position;
int Y_rectangle_position;
int X_label_position;
int Y_label_position;
int index;
//----------------------------------------------------------------
//--------- ROZMĚRY BÁRŮ - ZAČÁTEK ---------------------------
//----------------------------------------------------------------
input int TextSize=8; // TextSize
input int NumberOfCandles=5;// NumberOfCandles
//---------------------------------------------------------------
int RecstangleSize=TextSize+12; // RecstangleSize
int width=RecstangleSize;
int height=width;
int line_width=1;
bool back=true;//false; //
int back_clr_DOWN=clrBlack;
int back_clr_UP=clrWhite;
int border_color=clrBlack;
bool hidden=false; //true;//
int X_rectangle_space=4*width;
int Y_rectangle_space=1;
//----------------------------------------------------------------
//--------- ROZMĚRY BÁRŮ - KONEC ---------------------------
//----------------------------------------------------------------
//
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Draw_Consecutive_Identical_Candles();
//---
   return(INIT_SUCCEEDED);
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

//----------------------------------------------------------------------
//----------------------------------------------------------------------
Draw_Consecutive_Identical_Candles();
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//
//
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********  MAIN SCANNER FUNCTIN - START *****************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
void Draw_Consecutive_Identical_Candles()
//oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
{
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
string IndicatorSymbol[29];
//------------------------------------------------------------------------------
IndicatorSymbol[1]="EURUSD";
IndicatorSymbol[2]="EURGBP";
IndicatorSymbol[3]="EURJPY";
IndicatorSymbol[4]="EURNZD";
IndicatorSymbol[5]="EURAUD"; 
IndicatorSymbol[6]="EURCHF"; 
IndicatorSymbol[7]="EURCAD"; 
//-------------------------
IndicatorSymbol[8]="GBPUSD";
IndicatorSymbol[9]="GBPAUD"; 
IndicatorSymbol[10]="GBPCAD"; 
IndicatorSymbol[11]="GBPCHF"; 
IndicatorSymbol[12]="GBPJPY";
IndicatorSymbol[13]="GBPNZD";
//-------------------------
IndicatorSymbol[14]="AUDUSD";
IndicatorSymbol[15]="AUDCAD";
IndicatorSymbol[16]="AUDNZD";
IndicatorSymbol[17]="AUDJPY";
IndicatorSymbol[18]="AUDCHF";
//-------------------------
IndicatorSymbol[19]="USDJPY"; 
IndicatorSymbol[20]="USDCAD"; 
IndicatorSymbol[21]="USDCHF"; 
//-------------------------
IndicatorSymbol[22]="NZDUSD";
IndicatorSymbol[23]="NZDCAD"; 
IndicatorSymbol[24]="NZDCHF"; 
IndicatorSymbol[25]="NZDJPY";
//-------------------------
IndicatorSymbol[26]="CADJPY";
IndicatorSymbol[27]="CADCHF";
//-------------------------
IndicatorSymbol[28]="CHFJPY"; 
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//
//
//
//
//--------------------------------------------------------------------------
 for(int n=1; n<29; n++)
 {
//*************************************************************************************
//*************************************************************************************
//
//
//-------------------------------------------------------------
//------- SYMBOL Label - Start --------------------------------
//-------------------------------------------------------------
   X_label_position=X_pozice_pocatek-width-X_rectangle_space;
   Y_label_position=Y_pozice_pocatek + n*width + n*Y_rectangle_space;
//-------------------------------------------------------------
   string SymbolIndex=IndicatorSymbol[n]+IntegerToString(n);
   ObjectDelete("SYMBOL " + SymbolIndex);
   ObjectCreate("SYMBOL " + SymbolIndex,OBJ_LABEL,0,0,0,0,0);
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_XDISTANCE,X_label_position);
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_YDISTANCE,Y_label_position);
   ObjectSetText("SYMBOL " + SymbolIndex,IndicatorSymbol[n],TextSize,"Arial",Black);
   //TextSetFont("SYMBOL " + SymbolIndex,IndicatorSymbol[n],TextSize,"ArialBlack",Black);  
//-------------------------------------------------------------
//------- SYMBOL Label - End ----------------------------------
//-------------------------------------------------------------


//-------------------------------------------------------------
    for (int del=0;del<200;del++)
    {
    string VolatilityIndex=IndicatorSymbol[n] + IntegerToString(del); 
    ObjectDelete( "VOLATILITY SYMBOL " + VolatilityIndex);
    }
//-------------------------------------------------------------





//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
   for (int ivol=0;ivol<NumberOfCandles;ivol++)
   {
//--------------------------------------   
   double b_volatility =
   100*(MathAbs(iOpen(IndicatorSymbol[n],0,ivol)-iClose(IndicatorSymbol[n],0,ivol)) / 
   b_avg(IndicatorSymbol[n],100))
   ;
   string stg_b_volatility=DoubleToString(b_volatility,0)+"%";
//--------------------------------------   
   double hilo_volatility =
   100*(MathAbs(iHigh(IndicatorSymbol[n],0,ivol)-iLow(IndicatorSymbol[n],0,ivol)) / 
   hilo_avg(IndicatorSymbol[n],100))
   ;
   string stg_hilo_volatility=DoubleToString(hilo_volatility,0)+"%";
   int volatility_color=clrBlack;
   if (b_volatility<50 && hilo_volatility<50) {volatility_color=clrRed;}
   if (b_volatility<50 && hilo_volatility>50) {volatility_color=clrBlue;}  
//--------------------------------------
   int X_volatility_symbol_position=X_pozice_pocatek  + ivol*width + ivol*X_rectangle_space;// - (X_rectangle_space);
   int Y_volatility_symbol_position=Y_pozice_pocatek + n*width + n*Y_rectangle_space;
//--------------------------------------
   string VolatilityIndex=IndicatorSymbol[n] + IntegerToString(ivol);      
   ObjectCreate( "VOLATILITY SYMBOL " + VolatilityIndex ,OBJ_LABEL,0,0,0,0,0); 
   ObjectSet(  "VOLATILITY SYMBOL " + VolatilityIndex ,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER 
   ObjectSet( "VOLATILITY SYMBOL " + VolatilityIndex ,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER); 
   ObjectSet( "VOLATILITY SYMBOL " + VolatilityIndex ,OBJPROP_XDISTANCE,X_volatility_symbol_position);
   ObjectSet( "VOLATILITY SYMBOL " + VolatilityIndex ,OBJPROP_YDISTANCE,Y_volatility_symbol_position);
   ObjectSetText( "VOLATILITY SYMBOL " + VolatilityIndex , stg_b_volatility + " / " +  stg_hilo_volatility,TextSize,"Arial",volatility_color);    
   }
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

//*************************************************************************************
//*************************************************************************************
 }


//oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
}
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********  MAIN SCANNER FUNCTION - END *****************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
//
//
//
//
//
//
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********  AUXILIARY SCANNER FUNCTION - START ***********************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
//
//
//
//
//*****počítá PRŮMĚR TĚL - ZAČÁTEK***************
double b_avg(string bavg_symbol,int b_an)
{
double v_b_avg=0;
double suma_b=0;
for(int ibg=1;ibg<b_an;ibg++)
{
suma_b=suma_b+MathAbs(iOpen(bavg_symbol,0,ibg)-iClose(bavg_symbol,0,ibg));
}
v_b_avg=suma_b/b_an;
return (v_b_avg);
}
//*****počítá PRŮMĚR TĚL - KONEC*****************
//
//
//
//
//*****počítá PRŮMĚR HIGH-LOW - ZAČÁTEK**********
double hilo_avg(string hiloavg_symbol,int hilo_an)
{
double v_hilo_avg=0;
double suma_hilo=0;
for(int ihilo=1;ihilo<hilo_an;ihilo++)
{
suma_hilo=suma_hilo+MathAbs(iHigh(hiloavg_symbol,0,ihilo)-iLow(hiloavg_symbol,0,ihilo));
}
v_hilo_avg=suma_hilo/hilo_an;
return (v_hilo_avg);
}
//*****počítá PRŮMĚR HIGH-LOW - KONEC*********
//
//
//
//
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********  AUXILIARY SCANNER FUNCTION - END *************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************