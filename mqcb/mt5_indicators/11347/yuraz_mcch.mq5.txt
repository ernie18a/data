//+------------------------------------------------------------------+
//|                                                          ttt.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// класс расчет CH% 
//
struct SymbolStruct
  {
   bool              work;
   string            sSymbol;
   int               y;
   int               x;
   double            CH;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CChmcYZ
  {
public:
   SymbolStruct      sSymb;
   color             lColorSym;
   color             lColorChPlus;
   color             lColorChMinus;
   color             lColorCH;

   int               indicatorWindow; // работаем в главном окне
   void CChmcYZ() 
     {
      indicatorWindow=0;
      lColorSym=Aqua;
      lColorCH=White;
      lColorChPlus  =LimeGreen;
      lColorChMinus =Red;
     } // конструктор
   void              RCH(string sSym,datetime db,datetime de);   // Полный расчт только одной пары без отображения
   void              RCHsay(string sSym,datetime db,datetime de,int X,int Y); // Полный расчт одной пары и отображение ее
private:
   color             lColor;
   double            dClose[7000];                    // массив для копирования максимальных цен
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CChmcYZ::RCH(string sSymbol,datetime DATEBEG,datetime DATEEND)
  {
   sSymb.CH=0;
   int CountBar;
   DATEBEG = StringToTime( TimeToString(DATEBEG,TIME_DATE));
   DATEEND = StringToTime( TimeToString(DATEEND,TIME_DATE));
   CountBar= CopyClose(sSymbol,PERIOD_D1,DATEEND,2,dClose);
   if(CountBar>=0)
     {
      if(NormalizeDouble(dClose[1],5)!=0.0 && NormalizeDouble(dClose[0],5)!=0.0)
        {
         sSymb.CH=(dClose[1]*100)/dClose[0]-100;
        }
     }
  }
//+------------------------------------------------------------------+
//| Расчет с выводом
//+------------------------------------------------------------------+
void CChmcYZ::RCHsay(string sSym,datetime db,datetime de,int XD,int YD) // Полный расчт только одной пары
  {
   RCH(sSym,db,de);
   if(ObjectFind(indicatorWindow,"oYZ"+sSym)==-1)
     {
      ObjectCreate(indicatorWindow,"oYZ"+sSym,OBJ_LABEL,indicatorWindow,0,0);
      ObjectSetInteger(indicatorWindow,"oYZ"+sSym,OBJPROP_XDISTANCE,XD);
      ObjectSetInteger(indicatorWindow,"oYZ"+sSym,OBJPROP_YDISTANCE,YD);
      ObjectSetInteger(indicatorWindow,"oYZ"+sSym,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(indicatorWindow,"oYZ"+sSym,OBJPROP_TEXT,sSym);
      ObjectSetString(indicatorWindow,"oYZ"+sSym,OBJPROP_FONT,"Arial");
      ObjectSetInteger(indicatorWindow,"oYZ"+sSym,OBJPROP_FONTSIZE,7);
      ObjectSetInteger(indicatorWindow,"oYZ"+sSym,OBJPROP_COLOR,lColorSym);
      ObjectSetInteger(indicatorWindow,"oYZ"+sSym,OBJPROP_SELECTABLE,true);
     }
   if(ObjectFind(indicatorWindow,"oYZ_"+sSym)==-1)
     {
      ObjectCreate(indicatorWindow,"oYZ_"+sSym,OBJ_LABEL,indicatorWindow,0,0);
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_XDISTANCE,XD+45);
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_YDISTANCE,YD);
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(indicatorWindow,"oYZ_"+sSym,OBJPROP_TEXT,sSym);
      ObjectSetString(indicatorWindow,"oYZ_"+sSym,OBJPROP_FONT,"Arial");
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_FONTSIZE,7);
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_COLOR,lColorCH);
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_SELECTABLE,true);
     }
   YD=YD+11;

   lColor=lColorCH;
   if(sSymb.CH>0)
     {
      lColor=lColorChPlus;
      ObjectSetString(indicatorWindow,"oYZ_"+sSym,OBJPROP_TEXT," "+DoubleToString(sSymb.CH,5));
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_XDISTANCE,XD+45);
     }
   if(sSymb.CH<0)
     {
      lColor=lColorChMinus;
      ObjectSetString(indicatorWindow,"oYZ_"+sSym,OBJPROP_TEXT,DoubleToString(sSymb.CH,5));
      ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_XDISTANCE,XD+46);
     }
   ObjectSetInteger(indicatorWindow,"oYZ_"+sSym,OBJPROP_COLOR,lColor);
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CChmcYZ chmc;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   chmc.RCHsay("EURUSD",TimeCurrent()-86400*5,TimeCurrent(),5,16); // расчитаем тек день CH%
   chmc.RCHsay("AUDUSD",TimeCurrent()-86400*5,TimeCurrent(),5,16+12   );
   chmc.RCHsay("GBPUSD",TimeCurrent()-86400*5,TimeCurrent(),5,16+12*2 );
   chmc.RCHsay("USDCHF",TimeCurrent()-86400*5,TimeCurrent(),5,16+12*3 );
   chmc.RCHsay("USDCAD",TimeCurrent()-86400*5,TimeCurrent(),5,16+12*4 );
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   chmc.RCHsay("EURUSD",TimeCurrent()-86400*5,TimeCurrent(),5,16); // расчитаем тек день CH%
   chmc.RCHsay("AUDUSD",TimeCurrent()-86400*5,TimeCurrent(),5,16+12   );
   chmc.RCHsay("GBPUSD",TimeCurrent()-86400*5,TimeCurrent(),5,16+12*2 );
   chmc.RCHsay("USDCHF",TimeCurrent()-86400*5,TimeCurrent(),5,16+12*3 );
   chmc.RCHsay("USDCAD",TimeCurrent()-86400*5,TimeCurrent(),5,16+12*4 );
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit()
  {
   int i=ObjectsTotal(0); // удалим свои объекты
   while(i>0)
     {
      if(StringSubstr(ObjectName(0,i),0,3)=="oYZ")
        {
         ObjectDelete(0,ObjectName(0,i));
        }
       i--;
     }
  }
//+------------------------------------------------------------------+
