package com.example.cash_register.payment;

import android.app.Activity;
import android.content.Intent;

import org.json.JSONObject;

import vizpay.CommonUtils.CommonFunction;

public class commonUtility {

     public void iciciPayment(Activity activity) {
        try {
            JSONObject saleRequest = new JSONObject();
            saleRequest.put("AMOUNT", "1.00");
//            saleRequest.put("TIP_AMOUNT", "1.00");
            saleRequest.put("TRAN_TYPE", "SALE");
            saleRequest.put("BILL_NUMBER ", "abc123");
            saleRequest.put("SOURCE_ID ", "abcd");
            saleRequest.put("PRINT_FLAG ", "1");

            Intent intent = activity.getPackageManager().getLaunchIntentForPackage("com.icici.viz.sunmi");
            intent.setFlags(0);
            intent.putExtra("REQUEST_TYPE", "SALE");
            intent.putExtra("DATA", saleRequest.toString());
           activity.startActivityForResult(intent, CommonFunction.Companion.getSALE_CODE_RESULT_CODE());

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
