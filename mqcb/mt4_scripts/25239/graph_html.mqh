//+------------------------------------------------------------------+
//|                                                   Graph_HTML.mqh |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description "Display interactive HTML graph of the account balance inside the web browser."
#property strict
#include <Files/FileTxt.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string htm_file="<!DOCTYPE HTML>"
                "<html>"
                "<head>"
                "    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
                "    <title>Balance Report</title>"
                "    <style type=\"text/css\">"
                "        #container {min-width: 310px;	max-width: 800px;	height: 400px;	margin: 0 auto}"
                "    </style>"
                "</head>"
                "<body>"
                "    <script src=\"https://code.highcharts.com/highcharts.js\"></script>"
                "    <script src=\"https://code.highcharts.com/modules/series-label.js\"></script>"
                "    <script src=\"https://code.highcharts.com/modules/exporting.js\"></script>"
                "    <script src=\"https://code.highcharts.com/modules/export-data.js\"></script>"
                "    <div id=\"container\"></div>"
                "    <script src=\"exdat.txt\" type=\"text/javascript\"></script>"
                "    <script type=\"text/javascript\">"
                "        Highcharts.chart('container', {"
                "            chart: {"
                "                zoomType: 'x'"
                "            },"
                "            title: {"
                "                text: 'Balance Graph'"
                "            },"
                "            subtitle: {"
                "                text: document.ontouchstart === undefined ?"
                "                    'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'"
                "            },"
                "            tooltip: {"
                "                valueDecimals: 2"
                "            },"
                "            xAxis: {"
                "                type: 'datetime',"
                "                title: {"
                "                    text: 'Period from <b>' + Highcharts.dateFormat('%d %b %Y', T1) +"
                "                        '</b> through <b>' + Highcharts.dateFormat('%d %b %Y', T2) +"
                "                        '</b> inclusive. Total <b>' + nTrades + '</b> trades. Account balance: <b>' +"
                "                        Balance + '</b> ' + Currency"
                "                }"
                "            },"
                "            yAxis: {"
                "                title: {"
                "                    text: 'Balance ' + Currency"
                "                }"
                "            },"
                "            series: [{"
                "                name: 'Balance',"
                "                data: dat1"
                "            }]"
                "        });"
                "    </script>"
                "</body>"
                "</html>";
//+------------------------------------------------------------------+
//| Creates 'HighCharts' balance report on trades in .html format    |
//+------------------------------------------------------------------+
void CreateHighChartsBalanceReport(const string FileName="Graph.htm")
  {
   CFileTxt file;
//---
   file.Open(FileName, FILE_WRITE|FILE_COMMON);
   file.WriteString(htm_file);
//---
   file.Open("exdat.txt", FILE_WRITE|FILE_COMMON);
   file.WriteString("var dat1=[\n");
//---
//--- Sort history profits by close time
   double Profits[][2];
   int cnt=0;
   for(int i=0; i<OrdersHistoryTotal(); i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderType()<=OP_SELL || OrderType()>=6)
           {
            ArrayResize(Profits,++cnt,1000);
            Profits[cnt-1][0] = OrderCloseTime()*1.0;
            Profits[cnt-1][1] = OrderProfit()+OrderCommission()+OrderSwap();
           }
   ArraySort(Profits);
//---
   double Balance=0;
   for(int i=0; i<cnt; i++)
     {
      Balance+=Profits[i][1];
      file.WriteString("["+(string)(ulong)(Profits[i][0]*1000)+","+DoubleToString(Balance,2)+"],\n");
     }
   file.WriteString("];\n");
   file.WriteString("var T1=dat1[0][0];\n");
   file.WriteString("var T2=dat1[dat1.length-1][0];\n");
   file.WriteString("var nTrades=dat1.length;\n");
   file.WriteString("var Balance="+DoubleToString(Balance,2)+";\n");
   file.WriteString("var Currency=\""+AccountInfoString(ACCOUNT_CURRENCY)+"\";\n");
//---
   Exec(TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\Files\\"+FileName);
  }
//+------------------------------------------------------------------+
//| Execute Windows command/program or open a document/webpage       |
//+------------------------------------------------------------------+
#import "shell32.dll"
int ShellExecuteW(int hWnd,string Verb,string File,string Parameter,string Path,int ShowCommand);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Exec(const string command,const string parameters="")
  {
   Shell32::ShellExecuteW(0,"open",command,parameters,NULL,1);
  }
//+------------------------------------------------------------------+
