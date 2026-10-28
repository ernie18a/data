//+------------------------------------------------------------------+
//|                                    Actual Volatility Scanner.mq4 |
//|                                                    Jan Opocensky |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opocensky"
#property link      ""
#property version   "709.201"
#property strict
#property indicator_chart_window
//-------------------------------------------------------------------------

//----------------------------------------------------------------
//--------- ROZMĚRY BÁRŮ - ZAČÁTEK ---------------------------
//----------------------------------------------------------------
input int TextSize=8; // TextSize
input int ReferenceBody=30; // ReferenceBody
input int CandleAverageNumber=100; // CandleAverageNumber
input int TrackedCandleIndex=0; // TrackedCandleIndex
input int HorizonatalStartPosition=20;
//---------------------------------------------------------------
int X_pozice_pocatek=HorizonatalStartPosition;
int Y_pozice_pocatek=10;
int X_rectangle_position;
int Y_rectangle_position;
int X_label_position;
int Y_label_position;
int index;
double RelativeBody;
int RectangleSize=TextSize+8; // RecstangleSize
int width=RectangleSize;
int height=RectangleSize;
int line_width=1;
bool back=true;//false; //
int back_clr;
int back_clr_UP=clrWhite;
int border_color=clrBlack;
bool hidden=false; //true;//
int X_rectangle_space=4*width;
int Y_rectangle_space=height/3;

string IndicatorSymbol[33]; // DAX30, DJI30, SP500, NQ100
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
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//string IndicatorSymbol[33]; // DAX30, DJI30, SP500, NQ100
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
//-------------------------
IndicatorSymbol[29]="[DAX30]";
IndicatorSymbol[30]="[DJI30]";
IndicatorSymbol[31]="[SP500]";
IndicatorSymbol[32]="[NQ100]";
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
//ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo



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
//
//--------------------------------------------------------------------------
 for(int n=1; n<33; n++)
 {
//*************************************************************************************
//*************************************************************************************
   X_label_position=X_pozice_pocatek;//-X_rectangle_space;
   Y_label_position=Y_pozice_pocatek + n*height + n*Y_rectangle_space;
//-------------------------------------------------------------
//------- SYMBOL Label - Start --------------------------------
//-------------------------------------------------------------   
   string SymbolIndex=IndicatorSymbol[n];
   ObjectDelete   (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) );
   ObjectCreate   (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJ_LABEL,0,0,0,0,0);
   ObjectSet      (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER
   ObjectSet      (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSet      (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_XDISTANCE,X_label_position);
   ObjectSet      (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_YDISTANCE,Y_label_position);
   ObjectSetText  (  "SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,IndicatorSymbol[n],TextSize,"Arial",Black);
//-------------------------------------------------------------
//------- SYMBOL Label - End ----------------------------------
//-------------------------------------------------------------

//-------------------------------------------------------------
//------- RECTANGLE Label - Start --------------------------------
//-------------------------------------------------------------  
   if (iOpen(IndicatorSymbol[n],0,TrackedCandleIndex)<iClose(IndicatorSymbol[n],0,TrackedCandleIndex)) {back_clr=clrWhite;}
   if (iOpen(IndicatorSymbol[n],0,TrackedCandleIndex)>iClose(IndicatorSymbol[n],0,TrackedCandleIndex)) {back_clr=clrBlack;}
//******************** fix 7.9.2020 - start    
   if (b_avg(IndicatorSymbol[n],CandleAverageNumber)<0.0000001){break;}
   else {RelativeBody =  MathAbs(iOpen(IndicatorSymbol[n],0,TrackedCandleIndex)-iClose(IndicatorSymbol[n],0,TrackedCandleIndex))/ b_avg(IndicatorSymbol[n],CandleAverageNumber);}
//******************** fix 7.9.2020 - end 
   width = (int) NormalizeDouble(ReferenceBody * RelativeBody,0);
   ObjectDelete      (  "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) );
   ObjectCreate      (  "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
   ObjectSet         (  "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_CORNER,CORNER_RIGHT_LOWER); //
   ObjectSet         (  "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_XDISTANCE,width+X_label_position+100);
   ObjectSet         (  "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_YDISTANCE,Y_label_position);    
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_XSIZE,width);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_YSIZE,height);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_WIDTH,line_width);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_BACK,back);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_COLOR,border_color);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger  (0, "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_HIDDEN,hidden);
//-------------------------------------------------------------
//------- RECTANGLE Label - End ----------------------------------
//-------------------------------------------------------------

//-------------------------------------------------------------
//------- TEXT Label - Start --------------------------------
//------------------------------------------------------------- 
   int BodySize = (int) NormalizeDouble(100*RelativeBody,0);  
   ObjectDelete   ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) );
   ObjectCreate   ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJ_LABEL,0,0,0,0,0);
   ObjectSet      ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER
   ObjectSet      ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSet      ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_XDISTANCE,X_label_position+55);
   ObjectSet      ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,OBJPROP_YDISTANCE,Y_label_position);
   ObjectSetText  ( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ,IntegerToString(BodySize) + " %",TextSize,"Arial",Black);
//-------------------------------------------------------------
//------- TEXT Label - End ----------------------------------
//-------------------------------------------------------------
//
//*************************************************************************************
//*************************************************************************************
 }
//-------------------------------------------------------------

////oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
}
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********  MAIN SCANNER FUNCTION - END *****************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
    for(int n=1; n<33; n++)
 {
   string SymbolIndex=IndicatorSymbol[n];
   ObjectDelete("SYMBOL " + SymbolIndex + IntegerToString(TrackedCandleIndex));
   ObjectDelete( "CANDLE " + SymbolIndex + IntegerToString(TrackedCandleIndex) );
   ObjectDelete( "TEXT " + SymbolIndex + IntegerToString(TrackedCandleIndex) ); 
 }
//-------------------------------------------------------------   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
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
