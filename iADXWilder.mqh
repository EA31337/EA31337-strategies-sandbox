//+------------------------------------------------------------------+
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property link      "kenorb"
#property version   "1.00"
#property strict

#include  <Convert.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ADX 
  {

public:

   double            ADXP,ADXC,ADXDIPP;
   double            ADXDIPC,ADXDIMP,ADXDIMC;
   
   
   void Update(int tf) 
   {
   
    int period=Convert::TfToIndex(tf);
   
         ADXP=iADX(NULL,tf,8,PRICE_CLOSE,MODE_MAIN,2);
      ADXC=iADX(NULL,tf,12,PRICE_CLOSE,MODE_MAIN,1);
      ADXDIPP = iADX(NULL,tf, 10, PRICE_CLOSE, MODE_PLUSDI, 2);
      ADXDIPC = iADX(NULL,tf, 8, PRICE_CLOSE, MODE_PLUSDI, 1);
      ADXDIMP = iADX(NULL,tf, 12, PRICE_CLOSE, MODE_MINUSDI, 2);
      ADXDIMC = iADX(NULL,tf, 14, PRICE_CLOSE, MODE_MINUSDI, 1);
   
   }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {


   Update(tf);

      if((ADXP<ADXC) && (ADXDIPP<ADXP) && (ADXDIPC>ADXC) && cmd==OP_BUY)
         return true;


      if((ADXP<ADXC) && (ADXDIMP<ADXP) && (ADXDIMC>ADXC) && cmd==OP_SELL)
         return true;


      return false;

     }

  };
//+------------------------------------------------------------------+
