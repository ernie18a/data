//+------------------------------------------------------------------+
//|                                Equity-based Position Closure.mq5 |
//|                                       Copyright 2023, KISHORE K. |
//|                      https://www.mql5.com/en/users/kishorekiruba |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2023, KISHORE K"
#property link      "https://www.mql5.com/en/users/kishorekiruba"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double equity_percent_from_balances=1.1; // Equity Percent From Balances
input int buttonX = 100;  // X-coordinate of the button
input int buttonY = 100;  // Y-coordinate of the button
input int buttonWidth = 100;  // Width of the button
input int buttonHeight = 50;  // Height of the button

//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=50;                // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
   m_trade.SetDeviationInPoints(m_slippage);
    // Define the button size and position

// Create the button object
ObjectCreate(0, "BuyButton", OBJ_BUTTON, 0, 0, 0, 0, 0);

// Set button properties
ObjectSetString(0, "BuyButton", OBJPROP_TEXT, "CLOSE");  // Set the text of the button
ObjectSetInteger(0, "BuyButton", OBJPROP_XDISTANCE, buttonX);  // Set the X-distance of the button
ObjectSetInteger(0, "BuyButton", OBJPROP_YDISTANCE, buttonY);  // Set the Y-distance of the button
ObjectSetInteger(0, "BuyButton", OBJPROP_XSIZE, buttonWidth);  // Set the width of the button
ObjectSetInteger(0, "BuyButton", OBJPROP_YSIZE, buttonHeight);  // Set the height of the button

// Set button appearance
ObjectSetInteger(0, "BuyButton", OBJPROP_COLOR, clrRed);  // Set the button color
ObjectSetInteger(0, "BuyButton", OBJPROP_BGCOLOR, clrYellow);  // Set the button background color
ObjectSetInteger(0, "BuyButton", OBJPROP_BORDER_COLOR, clrBlack);  // Set the button border color
ObjectSetInteger(0, "BuyButton", OBJPROP_FONTSIZE, 16);  // Set the font size of the button text
//ObjectSetInteger(0, "BuyButton", OB, clrWhite);  // Set the font color of the button text
//---
   EventSetMillisecondTimer(1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }


void OnTick()
{
   
    
    if (m_account.Equity() >= m_account.Balance() * equity_percent_from_balances)
    {
       CloseAllOrders();
        
    }
}



void CloseAllOrders()
{
   m_trade.SetAsyncMode(true);
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY)
           {
            if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
               Print(__FILE__," ",__FUNCTION__,", ERROR: ","BUY PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
           }
         if(m_position.PositionType()==POSITION_TYPE_SELL)
           {
            if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
               Print(__FILE__," ",__FUNCTION__,", ERROR: ","SELL PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
           }
        }
}

void OnTimer()
{
   
    
    if (m_account.Equity() >= m_account.Balance() * equity_percent_from_balances)
    {
       CloseAllOrders();
        
    }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{

    // Check if the event is a mouse click event
    if (id == CHARTEVENT_OBJECT_CLICK)
    {
        // Check if the clicked object is the buy button
       if (sparam == "BuyButton")
        {
            // Call the trading logic function
            OnBuyButtonClicked();
        }
    }
}
void OnBuyButtonClicked()
{
    
    printf("CLOSE ALL");
    CloseAllOrders();
    
}