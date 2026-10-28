//+------------------------------------------------------------------+
//|                                              @Buy_Sell_Close.mq4 |
//|                                           Copyright © 2024, xk5. |
//|                         https://www.mql5.com/en/users/xk5/seller |
//+------------------------------------------------------------------+
#property copyright "CopyRight@2010-2024, xk5"
#property version "1.22"
#property link      "https://www.mql5.com/en/users/xk5/seller"
#property strict

extern bool   MM        = true;                                // Auto MM
extern double Risk      = 0.2;                                 // Risk
extern double Lots      = 0.01;                                // Lots
extern int SL        = 250;                                    // StopLoss
extern int TP        = 500;                                    // TakeProfit
extern int Corner = 0;
extern int Move_X = 0;
extern int Move_Y = 0;
extern string B00001 = "====================";
extern int Button_Width = 200;
extern string Font_Type = "Arial Bold";
extern int Font_Size = 10;
extern color Font_Color = clrWhite;
extern color Font_Color2 = clrBlack;
extern color Lot_Button_Color = clrDodgerBlue;
extern color Buy_Button_Color = clrBlue;
extern color Sell_Button_Color = clrRed;
extern color Close_Buy_Button_Color = clrBlue;
extern color Close_Sell_Button_Color = clrRed;
extern color Close_All_Button_Color = clrLime;
extern color Modify_SL_TP_Button_Color = clrLime;
int OnInit()
  {
   CreateButtons();
   ToolTips_Text("Lot_00000_btn");
   ToolTips_Text("Buy_00000_btn");
   ToolTips_Text("Sell_0000_btn");
   ToolTips_Text("Close_Buy_btn");
   ToolTips_Text("Close_Sel_btn");
   ToolTips_Text("Close_All_btn");
   ToolTips_Text("Modify_ST_btn");
   ObjectCreate("Lot_Edit", OBJ_EDIT, 0, 0, 0);
   ObjectSet("Lot_Edit", OBJPROP_CORNER, Corner);
   ObjectSet("Lot_Edit", OBJPROP_XSIZE, Button_Width - 040);
   ObjectSet("Lot_Edit", OBJPROP_YSIZE, Font_Size*2.8);
   ObjectSet("Lot_Edit", OBJPROP_XDISTANCE, 170);
   ObjectSet("Lot_Edit", OBJPROP_YDISTANCE, 030);
   string lot_txt = DoubleToString(GetLotSize());
   ObjectSetText("Lot_Edit", lot_txt, 13, Font_Type, Font_Color);
   ObjectSet("Lot_Edit", OBJPROP_BACK, FALSE);

   ObjectCreate("SL_Edit", OBJ_EDIT, 0, 0, 0);
   ObjectSet("SL_Edit", OBJPROP_CORNER, Corner);
   ObjectSet("SL_Edit", OBJPROP_XSIZE, Button_Width - 040);
   ObjectSet("SL_Edit", OBJPROP_YSIZE, Font_Size*2.8);
   ObjectSet("SL_Edit", OBJPROP_XDISTANCE, 010);
   ObjectSet("SL_Edit", OBJPROP_YDISTANCE, 090);
   ObjectSetText("SL_Edit", IntegerToString(SL), 13, Font_Type, Font_Color);
   ObjectSet("SL_Edit", OBJPROP_BACK, FALSE);

   ObjectCreate("TP_Edit", OBJ_EDIT, 0, 0, 0);
   ObjectSet("TP_Edit", OBJPROP_CORNER, Corner);
   ObjectSet("TP_Edit", OBJPROP_XSIZE, Button_Width - 040);
   ObjectSet("TP_Edit", OBJPROP_YSIZE, Font_Size*2.8);
   ObjectSet("TP_Edit", OBJPROP_XDISTANCE, 170);
   ObjectSet("TP_Edit", OBJPROP_YDISTANCE, 090);
   ObjectSetText("TP_Edit", IntegerToString(TP), 13, Font_Type, Font_Color);
   ObjectSet("TP_Edit", OBJPROP_BACK, FALSE);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteButtons();
   ObjectDelete("Lot_Edit");
   ObjectDelete("SL_Edit");
   ObjectDelete("TP_Edit");
   ObjectDelete("Date");
   ObjectDelete("Balance");
   ObjectDelete("Equity");
   ObjectDelete("FreeMargin");
   ObjectDelete("ProfitB");
   ObjectDelete("ProfitS");
   ObjectDelete("Profit");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   ShowUITexts();
   if(IsTesting())
     {
      CheckButtonPress("Lot_00000_btn");
      CheckButtonPress("Buy_00000_btn");
      CheckButtonPress("Sell_0000_btn");
      CheckButtonPress("Modify_ST_btn");
      CheckButtonPress("Close_Buy_btn");
      CheckButtonPress("Close_Sel_btn");
      CheckButtonPress("Close_All_btn");
     }
   return 0;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckButtonPress(const string sparam)
  {

   if(bool(ObjectGetInteger(0, sparam, OBJPROP_STATE)))
     {

      ButtonPressed(0, sparam);
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   ResetLastError();
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(ObjectType(sparam) == OBJ_BUTTON)
        {
         ButtonPressed(0, sparam);
        }
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButtons()
  {
   int Button_Height = (int)(Font_Size*2.8);
   if(!ButtonCreate(0, "Lot_00000_btn", 0, 010 + 000 + Move_X, 020 + 010 + Move_Y, Button_Width - 040, Button_Height, Corner, "Lot   =", Font_Type, Font_Size, Font_Color, Lot_Button_Color, clrBlack))
      return;
   if(!ButtonCreate(0, "Buy_00000_btn", 0, 010 + 000 + Move_X, 020 + 040 + Move_Y, Button_Width - 040, Button_Height, Corner, "BUY", Font_Type, Font_Size, Font_Color, Buy_Button_Color, clrBlack))
      return;
   if(!ButtonCreate(0, "Sell_0000_btn", 0, 010 + 160 + Move_X, 020 + 040 + Move_Y, Button_Width - 040, Button_Height, Corner, "SELL", Font_Type, Font_Size, Font_Color, Sell_Button_Color, clrBlack))
      return;
   if(!ButtonCreate(0, "Modify_ST_btn", 0, 010 + 000 + Move_X, 020 + 100 + Move_Y, Button_Width + 120, Button_Height, Corner, " SL Modify TP ", Font_Type, Font_Size, Font_Color2, Modify_SL_TP_Button_Color, clrBlack))
      return;
   if(!ButtonCreate(0, "Close_Buy_btn", 0, 220 + 000 + Move_X, 020 + 010 + Move_Y, Button_Width + 025, Button_Height, CORNER_RIGHT_UPPER, "Close All Buy", Font_Type, Font_Size, Font_Color, Close_Buy_Button_Color, clrBlack))
      return;
   if(!ButtonCreate(0, "Close_Sel_btn", 0, 220 + 000 + Move_X, 020 + 040 + Move_Y, Button_Width + 025, Button_Height, CORNER_RIGHT_UPPER, "Close All Sell", Font_Type, Font_Size, Font_Color, Close_Sell_Button_Color, clrBlack))
      return;
   if(!ButtonCreate(0, "Close_All_btn", 0, 220 + 000 + Move_X, 020 + 070 + Move_Y, Button_Width + 025, Button_Height, CORNER_RIGHT_UPPER, "Close All Orders", Font_Type, Font_Size, Font_Color2, Close_All_Button_Color, clrBlack))
      return;

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteButtons()
  {
   ButtonDelete(0, "Lot_00000_btn");
   ButtonDelete(0, "Buy_00000_btn");
   ButtonDelete(0, "Sell_0000_btn");
   ButtonDelete(0, "Modify_ST_btn");
   ButtonDelete(0, "Close_Buy_btn");
   ButtonDelete(0, "Close_Sel_btn");
   ButtonDelete(0, "Close_All_btn");


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ButtonPressed(const long chartID, const string sparam)
  {
   if(sparam == "Lot_00000_btn")
      Lot_00000_Button(sparam);
   if(sparam == "Buy_00000_btn")
      Buy_00000_Button(sparam);
   if(sparam == "Sell_0000_btn")
      Sell_0000_Button(sparam);
   if(sparam == "Modify_ST_btn")
      Modify_ST_Button(sparam);
   if(sparam == "Close_Buy_btn")
      Close_Buy_Button(sparam);
   if(sparam == "Close_Sel_btn")
      Close_Sel_Button(sparam);
   if(sparam == "Close_All_btn")
      Close_All_Button(sparam);
   Sleep(10);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ToolTips_Text(const string sparam)
  {
   if(sparam == "Lot_00000_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Lot To Be Used");
     }
   if(sparam == "Buy_00000_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Open BUY Order");
     }
   if(sparam == "Sell_0000_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Open SELL Order");
     }
   if(sparam == "Modify_ST_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Modify All Orders StopLoss And TakeProfit");
     }
   if(sparam == "Close_Buy_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Close All BUY Orders");
     }
   if(sparam == "Close_Sel_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Close All SELL Orders");
     }
   if(sparam == "Close_All_btn")
     {
      ObjectSetString(0, sparam, OBJPROP_TOOLTIP, "Close All Open Orders");
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Modify_ST_Button(const string sparam)
  {
   int ticket;
   double SL_Extract = StrToDouble(ObjectGetString(0, "SL_Edit", OBJPROP_TEXT, 0)) * Point;
   double TP_Extract = StrToDouble(ObjectGetString(0, "TP_Edit", OBJPROP_TEXT, 0)) * Point;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == 0 && OrderSymbol() == Symbol())
           {

            ticket = OrderModify(OrderTicket(), OrderLots(), Bid - SL_Extract, Bid + TP_Extract, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ", GetLastError());
            if(ticket >   0)
               Print("StopLoss And TakeProfit ", OrderTicket()," Modifyed");
           }
         if(OrderType() == 1 && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), OrderLots(), Ask + SL_Extract, Ask - TP_Extract, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ",  GetLastError());
            if(ticket >   0)
               Print("StopLoss And TakeProfit ", OrderTicket()," Modifyed");
           }
        }
     }
   return(0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Lot_00000_Button(const string sparam)
  {
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Close_Buy_Button(const string sparam)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == 0 && OrderSymbol() == Symbol())
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ", GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Close_Sel_Button(const string sparam)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == 1 && OrderSymbol() == Symbol())
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Close_All_Button(const string sparam)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == 0 && OrderSymbol() == Symbol())
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ", GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
         if(OrderType() == 1 && OrderSymbol() == Symbol())
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Close_Everything_Button(const string sparam)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == 0)
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ", GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
         if(OrderType() == 1)
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE);
            if(ticket == -1)
               Print("Error: ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Buy_00000_Button(const string sparam)
  {
   double Lot_Extract = StrToDouble(ObjectGetString(0, "Lot_Edit", OBJPROP_TEXT, 0));
   int ticket = OrderSend(Symbol(), OP_BUY, Lot_Extract, Ask, 3, 0, 0, "BUY", 12345601, 0, clrNONE);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Sell_0000_Button(const string sparam)
  {
   double Lot_Extract = StrToDouble(ObjectGetString(0, "Lot_Edit", OBJPROP_TEXT, 0));
   int ticket = OrderSend(Symbol(), OP_SELL, Lot_Extract, Bid, 3, 0, 0, "SELL", 12345602, 0, clrNONE);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long chart_ID=0, const string name="Button", const int sub_window=0, const int x=0, const int y=0, const int width=500,
                  const int height=18, int corner=0, const string text="Button", const string font="Arial Bold",
                  const int font_size=10, const color clr=clrBlack, const color back_clr=C'170,170,170', const color border_clr=clrNONE,
                  const bool state=false, const bool back=false, const bool selection=false, const bool hidden=true, const long z_order=0)
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name, OBJ_BUTTON, sub_window, 0, 0))
     {
      Print(__FUNCTION__, ": failed to create the button! Error code = ", GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonDelete(const long chart_ID=0, const string name="Button")
  {
   ResetLastError();
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__, ": Failed to delete the button! Error code = ", GetLastError());
      return(false);
     }
   return(true);
  }



//------------------------------------------------------------------+
// Generic Money management code
//------------------------------------------------------------------+
double GetLotSize()
  {
   double minlot    = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot    = MarketInfo(Symbol(), MODE_MAXLOT);
   double leverage  = AccountLeverage();
   double lotsize   = MarketInfo(Symbol(), MODE_LOTSIZE);
   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double MinLots = 0.01;
   double MaximalLots = 100.0;
   double lots = Lots;

   if(MM)
     {
      lots = NormalizeDouble(AccountBalance() * Risk/10000.0, 2);
      if(AccountFreeMargin() < Ask * lots * lotsize / leverage)
        {
         Print("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
         Comment("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
        }
     }
   else
      lots=NormalizeDouble(Lots, Digits);
   if(lots < minlot)
      lots = minlot;
   if(lots > MaximalLots)
      lots = MaximalLots;
   return(lots);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowUITexts()
  {
   int Y_Distance = 120;
   int FontSize_10 = 10;

//Y_Distance = FontSize_10 + FontSize_10 / 2;
   ObjectCreate("Date", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("Date", OBJPROP_CORNER, 1.0);
   ObjectSet("Date", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("Date", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 2;
   ObjectCreate("Balance", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("Balance", OBJPROP_CORNER, 1.0);
   ObjectSet("Balance", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("Balance", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 2;
   ObjectCreate("Equity", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("Equity", OBJPROP_CORNER, 1.0);
   ObjectSet("Equity", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("Equity", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 2;
   ObjectCreate("FreeMargin", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("FreeMargin", OBJPROP_CORNER, 1.0);
   ObjectSet("FreeMargin", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("FreeMargin", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 2;
   ObjectCreate("ProfitB", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("ProfitB", OBJPROP_CORNER, 1.0);
   ObjectSet("ProfitB", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("ProfitB", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 2;
   ObjectCreate("ProfitS", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("ProfitS", OBJPROP_CORNER, 1.0);
   ObjectSet("ProfitS", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("ProfitS", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 2;
   ObjectCreate("Profit", OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
   ObjectSet("Profit", OBJPROP_CORNER, 1.0);
   ObjectSet("Profit", OBJPROP_XDISTANCE, 20.0);
   ObjectSet("Profit", OBJPROP_YDISTANCE, Y_Distance);
   Y_Distance = Y_Distance + FontSize_10 * 3;

   string date=TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   ObjectSetText("Date", StringConcatenate("Date: ", date), FontSize_10, "Arial", clrLime);
   ObjectSetText("Balance", StringConcatenate("Balance: ", DoubleToString(AccountBalance(), 2)), FontSize_10, "Arial", clrLime);
   ObjectSetText("Equity", StringConcatenate("Equity: ", DoubleToString(AccountEquity(), 2)), FontSize_10, "Arial", clrLime);
   ObjectSetText("FreeMargin", StringConcatenate("FreeMargin: ", DoubleToString(AccountFreeMargin(), 2)), FontSize_10, "Arial", clrLime);

   ObjectSetText("ProfitB", "", FontSize_10, "Arial", clrGray);
   ObjectSetText("ProfitS", "", FontSize_10, "Arial", clrGray);
   ObjectSetText("Profit", "", FontSize_10, "Arial", clrGray);

   int buy_orders,sell_orders;
   double all_profit,buy_profit,sell_profit;
   double buy_lots,sell_lots;
   color Color_Profit,Color_ProfitB,Color_ProfitS;

   buy_orders = CheckBuyOrders();
   sell_orders = CheckSellOrders();

   buy_profit = CheckBuyProfit();
   sell_profit = CheckSellProfit();

   buy_lots = CheckBuyLot();
   sell_lots = CheckSellLot();

   all_profit = buy_profit + sell_profit;
   if(buy_lots > 0.0)
     {
      if(buy_profit < 0.0)
        {
         Color_ProfitB = clrRed;
        }
      else
        {
         Color_ProfitB = clrLime;
        }
      ObjectSetText("ProfitB", StringConcatenate("Buy ", buy_orders, " Order, ", DoubleToString(buy_lots, 2), " Lot,  Profit: ", DoubleToString(buy_profit, 2)), FontSize_10, "Arial", Color_ProfitB);
     }
   else
     {
      ObjectSetText("ProfitB", "", FontSize_10, "Arial", clrGray);
     }
   if(sell_lots > 0.0)
     {
      if(sell_profit < 0.0)
        {
         Color_ProfitS = clrRed;
        }
      else
        {
         Color_ProfitS = clrLime;
        }
      ObjectSetText("ProfitS", StringConcatenate("Sell ", sell_orders, " Order, ", DoubleToString(sell_lots, 2), " Lot,  Profit: ", DoubleToString(sell_profit, 2)), FontSize_10, "Arial", Color_ProfitS);
     }
   else
     {
      ObjectSetText("ProfitS", "", FontSize_10, "Arial", clrGray);
     }
   if(sell_lots + buy_lots > 0.0)
     {
      if(all_profit < 0.0)
        {
         Color_Profit = clrRed;
        }
      else
        {
         Color_Profit = clrLime;
        }
      ObjectSetText("Profit", StringConcatenate("All Profit: ", DoubleToString(all_profit, 2)), FontSize_10, "Arial", Color_Profit);
     }
   else
     {
      ObjectSetText("Profit", "", FontSize_10, "Arial", clrWhite);
     }

  }


//+------------------------------------------------------------------+
//| Check buy orders                                                 |
//+------------------------------------------------------------------+
int CheckBuyOrders()
  {
   int order = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
            order = order + 1;
     }
   return (order);
  }


//+------------------------------------------------------------------+
//| Check sell orders                                                |
//+------------------------------------------------------------------+
int CheckSellOrders()
  {
   int order = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_SELL)
            order = order + 1;
     }
   return (order);
  }

//+------------------------------------------------------------------+
//| Check Symbol Points                                              |
//+------------------------------------------------------------------+
double point(string symbol=NULL)
  {
   string sym=symbol;
   if(symbol==NULL)
      sym=Symbol();
   double bid=(int)MarketInfo(sym,MODE_BID);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);

   if(digits<=1)
      return(1); //CFD & Indexes
   if(digits==4 || digits==5)
      return(0.0001);
   if((digits==2 || digits==3) && bid>1000)
      return(1);
   if((digits==2 || digits==3) && bid<1000)
      return(0.01);
   if(StringFind(sym,"XAU")>-1 || StringFind(sym,"xau")>-1 || StringFind(sym,"GOLD")>-1)
      return(0.1);//Gold
   return(0);
  }



//+------------------------------------------------------------------+
//| Check buy profit                                                 |
//+------------------------------------------------------------------+
double CheckBuyProfit()
  {
   double profit = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
            profit = profit + OrderProfit() + OrderSwap() + OrderCommission();
     }
   return (profit);
  }


//+------------------------------------------------------------------+
//| Check sell profit                                                |
//+------------------------------------------------------------------+
double CheckSellProfit()
  {
   double profit = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_SELL)
            profit = profit + OrderProfit() + OrderSwap() + OrderCommission();
     }
   return (profit);
  }

//+------------------------------------------------------------------+
//| Check buy lots                                                   |
//+------------------------------------------------------------------+
double CheckBuyLot()
  {
   double lot = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
            lot = lot + OrderLots();
     }
   return (lot);
  }


//+------------------------------------------------------------------+
//| Check sell lots                                                  |
//+------------------------------------------------------------------+
double CheckSellLot()
  {
   double lot = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_SELL)
            lot = lot + OrderLots();
     }
   return (lot);
  }
//+------------------------------------------------------------------+
