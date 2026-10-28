//======================================================================================================
//    LibreConver Lite Interface_0 v1.007 MQL4/5 
//    Интерфейс настроек
//    Librecoin(c)2015-2017      
//======================================================================================================
#property strict
//======================================================================================================
//    INTERFACE
//======================================================================================================
input string   InFileName     =  "Economic Calendar - Investing.com.html"; //InFileName Investing html parsing
input string   TempFileName   =  "librenews.tmp";  //TmpFileName 
input string   OutFileName    =  "librenews.csv";  //OutFileName 
input bool     PrnFileWrite   =  false;               //PrnFileWrite вывод строк для контроля
