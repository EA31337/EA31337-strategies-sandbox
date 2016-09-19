//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict

#include  <Convert.mqh>


extern int MagicNumber=6290102;

extern int Slippage=3;
//----
extern double lTakeProfit=0;
extern double sTakeProfit=0;
extern double lStopLoss=0;
extern double sStopLoss=0;
extern double lTrailingStop=0;
extern double sTrailingStop=0;
//extern int mgod=2005;
extern int FrMarg=3000;
extern int porog=500;
extern int per=14;
extern int d=3;
extern int test=0;
extern int workb=-50;
extern int works=50;
extern int pred=100;
extern int sliv=-2000;
extern int mm=30;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   int               bloks,blokb,s,b;
   double            inul,ione,wpr,cci,zz,summa;

   void Update(int tf=PERIOD_M1)
     {

      inul=iCustom(NULL,0,"DayImpuls2",tf,d,0,0);
      ione=iCustom(NULL,0,"DayImpuls2",tf,d,0,1);
      wpr=iWPR(NULL,0,tf,0);
      cci=iCCI(NULL,0,tf,PRICE_CLOSE,0);
      zz=0; // ZZ2=iCustom(NULL,0,"ZigZag",depth,deviation,backstep,0,0);

      Print("period ",tf);

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      Update(Period());

      summa=summa+OrderProfit();


      if(inul>works && ione>inul && wpr>-15 && cci>150)
        {
         //Top=Bid;

         if(cmd==OP_SELL)
           {

            return(1);
           }

         if((summa<=-pred/2 || summa>=pred))
           {

            if(cmd==OP_BUY)
               return(1);
           }
        }

      if(inul<workb && ione<inul && wpr<-85 && cci<-150)
        {
         //Top=Ask;

         if(cmd==OP_BUY)
            return(1);

         if((summa<=-pred/2 || summa>=pred))
           {

            if(cmd==OP_SELL)
              {

               return(1);

              }
           }
        }



      return false;

     }

  };
//+------------------------------------------------------------------+
