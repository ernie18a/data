//+------------------------------------------------------------------+
//|                           SendClose(barabashkakvn's edition).mq5 |
//|                               Copyright © 2009, Vladimir Hlystov |
//|     v 1.00 Открывает или закрывает позиции при пересечении линий |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Vladimir Hlystov"
#property link      "cmillion@narod.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input bool   DRAW_SELL    = true;  // рисовать отрезки Sell
input bool   DRAW_BUY     = true;  // рисовать отрезки BUY
input bool   DRAW_CLOSE1  = true;  // рисовать отрезки Close1
input bool   DRAW_CLOSE2  = true;  // рисовать отрезки Close2
input int    MAX_POSITIONS= 1;     // максимальное колличество позиций
input double lot          = 0.10;  // лот
input color  resi         = clrBrown;
input color  supp         = clrMediumBlue;
input color  clos         = clrDarkViolet;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"LINES SELL");
   ObjectDelete(0,"LINES BUY");
   ObjectDelete(0,"LINES CLOSE1");
   ObjectDelete(0,"LINES CLOSE2");
   ObjectDelete(0,"LINES SELL n");
   ObjectDelete(0,"LINES BUY n");
   ObjectDelete(0,"LINES CLOSE1 n");
   ObjectDelete(0,"LINES CLOSE2 n");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int bar1=0,bar2=0,bar3=0;
   if(DRAW_SELL && ObjectFind(0,"LINES SELL")==-1)
     {
      bar3=searcFR(0,1);
      bar2=searcFR(bar3,-1);
      bar1=searcFR(bar2,1);
      DrawLine("LINES SELL",resi,iTime(m_symbol.Name(),Period(),bar1),iHigh(m_symbol.Name(),Period(),bar1),iTime(m_symbol.Name(),Period(),bar3),iHigh(m_symbol.Name(),Period(),bar3));
     }
   if(DRAW_CLOSE1 && ObjectFind(0,"LINES CLOSE1")==-1)
     {
      bar3=searcFR(0,1);
      bar2=searcFR(bar3,-1);
      bar1=searcFR(bar2,1);
      DrawLine("LINES CLOSE1",clos,iTime(m_symbol.Name(),Period(),bar1),iHigh(m_symbol.Name(),Period(),bar1)+15*Point(),iTime(m_symbol.Name(),Period(),bar3),iHigh(m_symbol.Name(),Period(),bar3)+15*Point());
     }
   if(DRAW_BUY && ObjectFind(0,"LINES BUY")==-1)
     {
      bar3=searcFR(0,-1);
      bar2=searcFR(bar3,1);
      bar1=searcFR(bar2,-1);
      DrawLine("LINES BUY",supp,iTime(m_symbol.Name(),Period(),bar1),iLow(m_symbol.Name(),Period(),bar1),iTime(m_symbol.Name(),Period(),bar3),iLow(m_symbol.Name(),Period(),bar3));
     }
   if(DRAW_CLOSE2 && ObjectFind(0,"LINES CLOSE2")==-1)
     {
      bar3=searcFR(0,-1);
      bar2=searcFR(bar3,1);
      bar1=searcFR(bar2,-1);
      DrawLine("LINES CLOSE2",clos,iTime(m_symbol.Name(),Period(),bar1),iLow(m_symbol.Name(),Period(),bar1)-15*Point(),iTime(m_symbol.Name(),Period(),bar3),iLow(m_symbol.Name(),Period(),bar3)-15*Point());
     }
   string pos=checkapp();
   if(pos=="LINES CLOSE1" || pos=="LINES CLOSE2")
      ClosePositions();
   if(PositionsTotal()<MAX_POSITIONS)
     {
      if(!RefreshRates())
         return;

      if(pos=="LINES SELL")
         m_trade.Sell(lot,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"LINES SELL");

      if(pos=="LINES BUY")
         m_trade.Buy(lot,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"LINES BUY ");
     }
   Comment(pos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         m_trade.PositionClose(m_position.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int searcFR(int bar,int UP_DN)
  {
   while(true)//ищем 1 фрактал после bar
     {
      bar++;
      if(Fractal(bar)==UP_DN)
         return(bar);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fractal(int br)
  {
   if(br<=2)
      return(0);
   if(iHigh(m_symbol.Name(),Period(),br)>=iHigh(m_symbol.Name(),Period(),br+1) && 
      iHigh(m_symbol.Name(),Period(),br)>iHigh(m_symbol.Name(),Period(),br+2) &&
      iHigh(m_symbol.Name(),Period(),br)>=iHigh(m_symbol.Name(),Period(),br-1) && 
      iHigh(m_symbol.Name(),Period(),br)>iHigh(m_symbol.Name(),Period(),br-2))
      return( 1);
   if(iLow(m_symbol.Name(),Period(),br)<=iLow(m_symbol.Name(),Period(),br+1) && 
      iLow(m_symbol.Name(),Period(),br)<iLow(m_symbol.Name(),Period(),br+2) &&
      iLow(m_symbol.Name(),Period(),br)<=iLow(m_symbol.Name(),Period(),br-1)
      && iLow(m_symbol.Name(),Period(),br)<iLow(m_symbol.Name(),Period(),br-2))
      return(-1);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string name,color clr,datetime X1,double Y1,datetime X2,double Y2)
  {
   if(ObjectFind(0,name)==0)
      return; //Если обьект существует
   datetime X1g=iTime(m_symbol.Name(),Period(),0);
   datetime X2g=iTime(m_symbol.Name(),Period(),0)+PeriodSeconds()*30;
   double Y1g=Y1+(Y2-Y1)*(X1g-X1)/(X2-X1);
   double Y2g=Y1+(Y2-Y1)*(X2g-X1)/(X2-X1);
   ObjectCreate(0,name,OBJ_TREND,0,X1g,Y1g,X2g,Y2g);
//--- установим цвет линии
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
//--- установим стиль отображения линии
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
//--- установим толщину линии
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
//--- включим (true) или отключим (false) режим перемещения линии мышью
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);
   return;
  }
//+------------------------------------------------------------------+
//| проверка всех линий "граница"                                    |
//+------------------------------------------------------------------+
string checkapp()
  {
   if(!RefreshRates())
      return("");

   datetime X_1=0,X_2=0,X_3=0;
   double Y_1=0.0,Y_2=0.0,Y_3=0.0;
   double shift_Y=(ChartGetDouble(0,CHART_PRICE_MAX)-ChartGetDouble(0,CHART_PRICE_MIN))/50;
   color clr;
   for(int n=ObjectsTotal(0,-1,OBJ_TREND)-1; n>=0; n--)
     {
      string Obj_N=ObjectName(0,n);
      if(StringFind(Obj_N,"LINES ",0)!=-1) // найден обьект-тренд к которому вычисляется приближение
        {
         X_1 = (datetime)ObjectGetInteger(0,Obj_N,OBJPROP_TIME,0);
         X_2 = (datetime)ObjectGetInteger(0,Obj_N,OBJPROP_TIME,1);
         ObjectDelete(0,Obj_N+" n");
         if(X_1>X_2 || X_2<iTime(m_symbol.Name(),Period(),0))
            continue;
         Y_1 = ObjectGetDouble(0,Obj_N, OBJPROP_PRICE,0);
         Y_2 = ObjectGetDouble(0,Obj_N, OBJPROP_PRICE,1);
         clr = (color)ObjectGetInteger(0,Obj_N,OBJPROP_COLOR);

         ObjectCreate(0,Obj_N+" n",OBJ_TEXT,0,X_1-PeriodSeconds()*6,Y_1+shift_Y);
         //--- установим текст
         ObjectSetString(0,Obj_N+" n",OBJPROP_TEXT,StringSubstr(Obj_N,6,5));
         //--- установим шрифт текста
         ObjectSetString(0,Obj_N+" n",OBJPROP_FONT,"Arial");
         //--- установим размер шрифта
         ObjectSetInteger(0,Obj_N+" n",OBJPROP_FONTSIZE,7);
         //--- установим цвет
         ObjectSetInteger(0,Obj_N+" n",OBJPROP_COLOR,clr);

         if(X_1<=iTime(m_symbol.Name(),Period(),0) && X_2>=iTime(m_symbol.Name(),Period(),0)) // попадает во временной диапазон
           {
            X_3=iTime(m_symbol.Name(),Period(),0);
            Y_3=Y_1+(Y_2-Y_1)*(X_3-X_1)/(X_2-X_1); // уравнение прямой
            if(Y_3>=m_symbol.Bid() && Y_3<=m_symbol.Ask())
              {
               return(Obj_N);
              }
           }
        }
     }
   return("");
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//------------------------------------------------------------------------------------------- 
