//+------------------------------------------------------------------+
//|                                Consecutive Identical Candles.mq4 |
//|                                                    Jan Opocensky |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opocensky"
#property link      ""
#property version   "09052020"
#property strict
#property indicator_chart_window


int X_pozice_pocatek=100;
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

int RecstangleSize=TextSize+12; // RecstangleSize
int width=RecstangleSize;
int height=width;
int line_width=1;
bool back=true;//false; //
int back_clr_DOWN=clrBlack;
int back_clr_UP=clrWhite;
int border_color=clrBlack;
bool hidden=false; //true;//


int X_rectangle_space=width/2;
int Y_rectangle_space=1;
//----------------------------------------------------------------
//--------- ROZMĚRY BÁRŮ - KONEC ---------------------------
//----------------------------------------------------------------



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
//---
Draw_Consecutive_Identical_Candles();
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
void Draw_Consecutive_Identical_Candles()
//===========================================================================================================================
//===========================================================================================================================
//===========================================================================================================================
  {
//oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

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

//--------------------------------------------------------------------------


   for(int n=1; n<29; n++)
   {
//*************************************************************************************
//*************************************************************************************


//-------------------------------------------------------------
//------- SYMBOL - Label  -------------------------------------
//-------------------------------------------------------------
   X_label_position=X_pozice_pocatek-width-X_rectangle_space;
   Y_label_position=Y_pozice_pocatek+n*width+n*Y_rectangle_space;
//-------------------------------------------------------------
   string SymbolIndex=IndicatorSymbol[n]+IntegerToString(n);
   ObjectDelete("SYMBOL " + SymbolIndex);
   ObjectCreate("SYMBOL " + SymbolIndex,OBJ_LABEL,0,0,0,0,0);
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_XDISTANCE,X_label_position);
   ObjectSet("SYMBOL " + SymbolIndex,OBJPROP_YDISTANCE,Y_label_position);
   ObjectSetText("SYMBOL " + SymbolIndex,IndicatorSymbol[n],TextSize,"Arial",Black);
//-------------------------------------------------------------
//------- SYMBOL - Label  -------------------------------------
//-------------------------------------------------------------

//-------------------------------------------------------------
    for (int del=0;del<200;del++)
    {
    ObjectDelete( "BAR " +IndicatorSymbol[n] +IntegerToString(del) );
    }
//-------------------------------------------------------------




//-------------------------------------------------------------
    if(iOpen(IndicatorSymbol[n],0,0)<iClose(IndicatorSymbol[n],0,0))
    {
//-------------------------------------------------------------
    int NumberOfConsecutiveIdentical_UP=UpbarConsecutiveIdentical(0,IndicatorSymbol[n]);
    for (int iup=0;iup<NumberOfConsecutiveIdentical_UP;iup++)
    {
    X_rectangle_position=X_pozice_pocatek+iup*width+iup*X_rectangle_space;
    Y_rectangle_position=Y_pozice_pocatek+n*width+n*Y_rectangle_space;
//-------------------------------------------------------------
    //ObjectDelete( "BAR " +IndicatorSymbol[n] +IntegerToString(iup) );
    ObjectCreate( "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
    ObjectSet( "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER
    ObjectSet( "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_XDISTANCE,X_rectangle_position);
    ObjectSet( "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_YDISTANCE,Y_rectangle_position);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_XSIZE,width);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_XSIZE,height);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_WIDTH,line_width);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_BORDER_TYPE,BORDER_FLAT);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_BACK,back);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_COLOR,border_color);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_BGCOLOR,back_clr_UP);
    ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(iup) ,OBJPROP_HIDDEN,hidden);
    
   
    }
//-------------------------------------------------------------
    }
//-------------------------------------------------------------



//-------------------------------------------------------------
    if(iOpen(IndicatorSymbol[n],0,0)>iClose(IndicatorSymbol[n],0,0))
    {
    int NumberOfConsecutiveIdentical_DOWN=DownbarConsecutiveIdentical(0,IndicatorSymbol[n]);
    for (int idw=0;idw<NumberOfConsecutiveIdentical_DOWN;idw++)
    {
    X_rectangle_position=X_pozice_pocatek+idw*width+idw*X_rectangle_space;
    Y_rectangle_position=Y_pozice_pocatek+n*width+n*Y_rectangle_space;
//-------------------------------------------------------------
   //ObjectDelete( "BAR " +IndicatorSymbol[n] +IntegerToString(idw) );
   ObjectCreate( "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
   ObjectSet( "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_CORNER,CORNER_RIGHT_LOWER); // WINDOW CORNER
   ObjectSet( "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_XDISTANCE,X_rectangle_position);
   ObjectSet( "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_YDISTANCE,Y_rectangle_position);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_XSIZE,width);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_XSIZE,height);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_WIDTH,line_width);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_BACK,back);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_COLOR,border_color);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_BGCOLOR,back_clr_DOWN);
   ObjectSetInteger(0, "BAR " +IndicatorSymbol[n] +IntegerToString(idw) ,OBJPROP_HIDDEN,hidden);
   
  
   }
//-------------------------------------------------------------




        }
      //-------------------------------------------------------------

      //*************************************************************************************
      //*************************************************************************************
     }
//oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
  }






//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//===========================================================================================================================
//===========================================================================================================================
//===========================================================================================================================






//
//*************************************************************
//*** Počet SHODNÝCH - UPBARŮ následujících - ZAČÁTEK ***
int UpbarConsecutiveIdentical(int i_ucons_start,string IdenticalUpbarSymbol)
  {
   int upbar_counter_identical=0;
   int i_ucons_i;
//--------------------------------
   for(i_ucons_i=i_ucons_start; i_ucons_i<100; i_ucons_i++)
     {
      if(iClose(IdenticalUpbarSymbol,0,i_ucons_i)>iOpen(IdenticalUpbarSymbol,0,i_ucons_i))
        {upbar_counter_identical=upbar_counter_identical+1;}
      else
        {
         break;
        }
     }
//------------------------------------
//Print ("upbar_counter_identical = ", upbar_counter_identical);
   return (upbar_counter_identical);
  }
//*** Počet SHODNÝCH - UPBARŮ následujících - KONEC ***
//*************************************************************
//
//*************************************************************
//*** Počet SHODNÝCH - DOWNBARŮ následujících - ZAČÁTEK ***
int DownbarConsecutiveIdentical(int i_dcons_start, string IdenticalDownbarSymbol)
  {
   int downbar_counter_identical=0;
   int i_dcons_i;
//--------------------------------
   for(i_dcons_i=i_dcons_start; i_dcons_i<100; i_dcons_i++)
     {
      if(iClose(IdenticalDownbarSymbol,0,i_dcons_i)<iOpen(IdenticalDownbarSymbol,0,i_dcons_i))
        {downbar_counter_identical=downbar_counter_identical+1;}
      else
        {
         break;
        }
     }
//------------------------------------
//Print ("downbar_counter_identical = ", downbar_counter_identical);
   return (downbar_counter_identical);
  }
//*** Počet SHODNÝCH - DOWNBARŮ následujících - KONEC ***
//*************************************************************
//
