//+------------------------------------------------------------------+
//|                                                      MyPanel.mqh |
//|                                    Copyright © 2013, DeltaTrader |
//|                                    http://www.deltatrader.com.br | 
//+------------------------------------------------------------------+
#property copyright     "DeltaTrader © 2013"
#property link          "www.deltatrader.com.br"
#property version       "1.000"
#property description   "Test Panel"
#property indicator_plots 0
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Controls\Panel.mqh>
//+------------------------------------------------------------------+
//| Global parameters                                                |
//+------------------------------------------------------------------+
int      panelXX     =  20;
int      panelYY     =  20;
int      panelWidth  =  300;
int      panelHeight =  300;
//+------------------------------------------------------------------+
//| Global variabels                                                 |
//+------------------------------------------------------------------+
//--- Panel itself
CAppDialog m_panel;
//--- Bid objects
CPanel m_bidcolor;
CLabel m_bidlabel;
//--- Ask objects
CPanel m_askcolor;
CLabel m_asklabel;
//+------------------------------------------------------------------+
//| On Init                                                          |
//+------------------------------------------------------------------+
int OnInit() 
  {
//--- Panel create
   m_panel.Create(0,"TEST PANEL",0,panelXX,panelYY,panelWidth,panelHeight);
//--- Bid label and colors
   m_bidcolor.Create(0,"Bid Background Color",0,1,1,panelWidth-30,30);
   m_bidcolor.ColorBackground(clrYellow);
   m_panel.Add(m_bidcolor);
   m_bidlabel.Create(0,"Bid Text",0,5,5,0,0);
   m_bidlabel.Text("Bid "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits));
   m_bidlabel.Color(clrBlue);
   m_panel.Add(m_bidlabel);
//--- Ask label and colors
   m_askcolor.Create(0,"Ask Background Color",0,1,101,panelWidth-30,130);
   m_askcolor.ColorBackground(clrAqua);
   m_panel.Add(m_askcolor);
   m_asklabel.Create(0,"Ask Text",0,5,105,0,0);
   m_asklabel.Text("Ask "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits));
   m_asklabel.Color(clrRed);
   m_panel.Add(m_asklabel);
//--- Run panel
   m_panel.Run();
   return(0);
  }
//+------------------------------------------------------------------+
//| On DeInit                                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Destroy panel
   m_panel.Destroy(reason);
//--- Delete all objects
   ObjectsDeleteAll(0,0);
  }
//+------------------------------------------------------------------+
//| On Calculate                                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- A very simples bid label
   m_bidlabel.Text("Bid "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits));
//--- A very simples ask label
   m_asklabel.Text("Ask "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits));
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| On Chart Event                                                   |
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- Move the panel with the mouse
   m_panel.ChartEvent(id,lparam,dparam,sparam);
//--- 
  }
//+------------------------------------------------------------------+
