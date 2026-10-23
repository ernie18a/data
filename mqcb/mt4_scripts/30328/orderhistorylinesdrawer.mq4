//+------------------------------------------------------------------+
//|                                     OrdersHistoryLinesDrawer.mq4 |
//|                                    Copyright 2020, Salman Bakhsh |
//|                                                drsmath@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2020, BoMahdi"
#property link        "https://t.me/DrNetwork"

//----
#property strict
#property show_inputs


//inputs
input color           cUpCandle = clrBlue;        //Buy Color
input color           cDwnCandle = clrRed;        //Sell Color
input ENUM_LINE_STYLE eTLineStyle = STYLE_DOT;    //Line style
input int             iTLineWidth = 1;            //Line Width
input long            lOpenArrowCode = 1;         //Open Arrow Code (try 5)
input int             iOpenArrowWidth = 1;        //Open Arrow Width
input long            lCloseArrowCode = 3;        //Close Arrow Code (try 6)
input int             iCloseArrowWidth = 1;       //Close Arrow Width
input int             iFontSize = 10;             //Profit font size
input color           cProfit = clrYellow;        //Profit Color


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
   double dProfit = 0;
   datetime dLastCloseTime = 0;

   datetime dtArray[];
   datetime dtArray2[];
   int OrderTicketID[];

   ArrayResize(dtArray,OrdersHistoryTotal());
   ArrayResize(dtArray2,OrdersHistoryTotal());
   ArrayResize(OrderTicketID,OrdersHistoryTotal());

   int index = 0;
   for(int i=0; i<OrdersHistoryTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) break;
      if(OrderSymbol()==_Symbol && OrderCloseTime()!=0 && OrderCloseTime()>0) {
         dtArray[index] = OrderCloseTime();
         index++;
      }
   }

   ArraySort(dtArray);

   index = 0;
   for(int i=0; i<ArraySize(dtArray); i++) {
      if(i==0) dtArray2[i] = dtArray[i];
      else {
         if(dtArray[i]!=dtArray[i-1]) {
            index++;
            dtArray2[index] = dtArray[i];
         }
      }
   }

   index = 0;
   for(int i=0; i<ArraySize(dtArray2); i++) {
      for(int j=0; j<OrdersHistoryTotal(); j++) {
         if(OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)==false) break;
         if(OrderSymbol()==_Symbol && OrderCloseTime()!=0 && OrderCloseTime()>0) {
            if(OrderCloseTime()==dtArray2[i]) {
               OrderTicketID[index]=OrderTicket();
               index++;
            }
         }
      }
   }

   for(int i=0; i<ArraySize(OrderTicketID); i++) {
      if(OrderSelect(OrderTicketID[i],SELECT_BY_TICKET,MODE_HISTORY)==false) break;
      if(OrderSymbol()==_Symbol && OrderCloseTime()!=0 && OrderCloseTime()>0) {

         //Obj base name
         string orderName = (string)OrderTicket()+"_"+(string)OrderOpenTime()+"_"+(string)OrderCloseTime();

         //--- create Trend Line
         ObjectCreate(orderName+"_TLine",OBJ_TREND,0,OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice());
         if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
            ObjectSetInteger(0,orderName+"_TLine",OBJPROP_COLOR,cUpCandle);
         else
            ObjectSetInteger(0,orderName+"_TLine",OBJPROP_COLOR,cDwnCandle);
         ObjectSetInteger(0,orderName+"_TLine",OBJPROP_STYLE,eTLineStyle);
         ObjectSetInteger(0,orderName+"_TLine",OBJPROP_WIDTH,iTLineWidth);
         ObjectSetInteger(0,orderName+"_TLine",OBJPROP_RAY_RIGHT,false);
         ObjectSetInteger(0,orderName+"_TLine",OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,orderName+"_TLine",OBJPROP_SELECTED,false);

         //--- create open arrow
         ObjectCreate(orderName+"_Arrow_Open",OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
         if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
            ObjectSetInteger(0,orderName+"_Arrow_Open",OBJPROP_COLOR,cUpCandle);
         else
            ObjectSetInteger(0,orderName+"_Arrow_Open",OBJPROP_COLOR,cDwnCandle);
         ObjectSetInteger(0,orderName+"_Arrow_Open",OBJPROP_ARROWCODE,lOpenArrowCode);
         ObjectSetInteger(0,orderName+"_Arrow_Open",OBJPROP_WIDTH,iOpenArrowWidth);
         ObjectSetInteger(0,orderName+"_Arrow_Open",OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,orderName+"_Arrow_Open",OBJPROP_SELECTED,false);

         //--- create close arrow
         ObjectCreate(orderName+"_Arrow_Close",OBJ_ARROW,0,OrderCloseTime(),OrderClosePrice());
         if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
            ObjectSetInteger(0,orderName+"_Arrow_Close",OBJPROP_COLOR,cUpCandle);
         else
            ObjectSetInteger(0,orderName+"_Arrow_Close",OBJPROP_COLOR,cDwnCandle);
         ObjectSetInteger(0,orderName+"_Arrow_Close",OBJPROP_ARROWCODE,lCloseArrowCode);
         ObjectSetInteger(0,orderName+"_Arrow_Close",OBJPROP_WIDTH,iCloseArrowWidth);
         ObjectSetInteger(0,orderName+"_Arrow_Close",OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,orderName+"_Arrow_Close",OBJPROP_SELECTED,false);

         //--- Profit Text
         if(dLastCloseTime != OrderCloseTime()) dProfit = 0;
         dProfit = dProfit + OrderProfit() + OrderCommission() + OrderSwap();
         dLastCloseTime = OrderCloseTime();

         ObjectCreate("Profit_"+(string)OrderCloseTime(),OBJ_TEXT,0,OrderCloseTime(),OrderClosePrice());
         ObjectSet("Profit_"+(string)OrderCloseTime(),OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
         ObjectSetString(0,"Profit_"+(string)OrderCloseTime(),OBJPROP_FONT,"Arial");
         ObjectSetString(0,"Profit_"+(string)OrderCloseTime(),OBJPROP_TEXT,"$"+(string)NormalizeDouble(dProfit,2));
         ObjectSetInteger(0,"Profit_"+(string)OrderCloseTime(),OBJPROP_FONTSIZE,iFontSize);
         ObjectSetInteger(0,"Profit_"+(string)OrderCloseTime(),OBJPROP_COLOR,cProfit);
         ObjectSetInteger(0,"Profit_"+(string)OrderCloseTime(),OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,"Profit_"+(string)OrderCloseTime(),OBJPROP_SELECTED,false);

      }
   }
}

//+------------------------------------------------------------------+
