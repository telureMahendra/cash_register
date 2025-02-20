package com.example.cash_register.payment





import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import org.json.JSONObject

class Payment {




    fun iciciPayment(context: Context,saleRequest: JSONObject): String {

        val intent = Intent()
        intent.component = ComponentName(
            "com.icici.viz.smartpeak",
            "vizpay.launchermodule.VizLauncherActivity"
        )
//
//
//        val jsonData = JSONObject()
//        jsonData.put("AMOUNT", "");
//
//

        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        intent.putExtra("REQUEST_TYPE", "SALE")
        intent.putExtra("DATA", saleRequest.toString())
        context.startActivity(intent)



//        CommonFunctions.printLog("json", saleRequest.toString())

//        var launchIntent: Intent? = null
//        val gson = Gson()
//        val addToCardJsonData = gson.toJson(dao?.getAllCartItems())

//        CommonFunctions.printLog("asdfghj", addToCardJsonData.toString())
//        val packageManager: PackageManager = context.packageManager
//        launchIntent = packageManager.getLaunchIntentForPackage("com.icici.viz.smartpeak")
//        launchIntent?.flags = 0;
//        launchIntent?.putExtra("REQUEST_TYPE", "SALE");
//        launchIntent?.putExtra("DATA", saleRequest.toString());
////        launchIntent?.putExtra("jsonData", addToCardJsonData);
//        if (launchIntent != null) {
////            resultLauncher.launch(launchIntent)
//        }



        return try {

            saleRequest.toString()

        } catch (e: Exception) {
            e.printStackTrace()
            "Error occurred while initiating payment"
        }
    }







}


