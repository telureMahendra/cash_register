package com.example.cash_register

import android.app.Instrumentation.ActivityResult
import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi
import com.example.cash_register.PaymentAppResult.PaymentAppResult
import com.example.cash_register.payment.Payment
import com.example.cash_register.print_reciept.PrintProductReceipt
import com.example.cash_register.print_reciept.PrintReciept
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import com.google.gson.Gson
import android.app.Activity
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultContracts
import androidx.activity.result.contract.ActivityResultContracts


class MainActivity: FlutterActivity() {


    val resultLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result: ActivityResult ->
        handlePaymentAppResult(result)
    }


    private fun handlePaymentAppResult(result: ActivityResult) {
        val bundleData: Bundle? = result.resultData?.extras
        val resultString = bundleData?.getString("RESULT")


        val parsedResult: PaymentAppResult? = try {
            Gson().fromJson(resultString, PaymentAppResult::class.java)
        } catch (_: Exception) {
            null
        }

        if (parsedResult?.statusCode == "00") {
//            showPaymentSuccessDialog() // TODO : Handle Here
//            clearCartData()
            Log.d(TAG, "handlePaymentAppResult: payment success")
        } else {
//            showPaymentFailureDialog(parsedResult?.statusMessage)
            Log.d(TAG, "handlePaymentAppResult: payment failed")
        }

    }

    fun iciciPayment(context: Context, saleRequest: JSONObject): String {

//        val intent = Intent()
//        intent.component = ComponentName(
//            "com.icici.viz.smartpeak",
//            "vizpay.launchermodule.VizLauncherActivity"
//        )
//
//
//        val jsonData = JSONObject()
//        jsonData.put("AMOUNT", "");
//
//
//
//        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK
//        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
//        intent.putExtra("REQUEST_TYPE", "SALE")
//        intent.putExtra("DATA", saleRequest.toString())
//        context.startActivity(intent)



//        CommonFunctions.printLog("json", saleRequest.toString())

        var launchIntent: Intent? = null
//        val gson = Gson()
//        val addToCardJsonData = gson.toJson(dao?.getAllCartItems())

//        CommonFunctions.printLog("asdfghj", addToCardJsonData.toString())
        val packageManager: PackageManager = context.packageManager
        launchIntent = packageManager.getLaunchIntentForPackage("com.icici.viz.smartpeak")
        launchIntent?.flags = 0;
        launchIntent?.putExtra("REQUEST_TYPE", "SALE");
        launchIntent?.putExtra("DATA", saleRequest.toString());
//        launchIntent?.putExtra("jsonData", addToCardJsonData);
        if (launchIntent != null) {
            resultLauncher.launch(launchIntent)
        }



        return try {

            saleRequest.toString()

        } catch (e: Exception) {
            e.printStackTrace()
            "Error occurred while initiating payment"
        }
    }
    
    
    private  val channelName = "printMethod";

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        var channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName);

        channel.setMethodCallHandler{call, result ->

            var args = call.arguments as Map<*, *>;


            var address = args["address"].toString();
            var shopEmail = args["shopEmail"].toString();
            var shopMobile = args["shopMobile"].toString();
            var shopName = args["shopName"].toString();
            var amount = args["amount"].toString();
            var gstNumber = args["gstNumber"].toString();
            var isPrintGST = args["isPrintGST"].toString();
            var image = args["image"].toString();
            var items = args["items"];
            var count = args["count"].toString();
            var method = args["method"].toString();


//            Toast.makeText(context, "count is : $count and method is $method", Toast.LENGTH_SHORT).show()


            if(call.method == "printCartReceipt"){
                val printReciept = PrintReciept();
                if (shopName != null && address != null && shopEmail != null && shopMobile != null) {
//                    printReciept.printImage(image)
                     printReciept.printCartReceipt(shopName,address, shopEmail, shopMobile, amount, gstNumber, isPrintGST, image, items, count, method);
                }else{
                    Toast.makeText(MainApplication.currentApplicationContext, "Details missing", Toast.LENGTH_SHORT).show()
                };
            }

            if(call.method == "printProductReceipt"){
                val printProductReceipt = PrintProductReceipt();
                if (shopName != null && address != null && shopEmail != null && shopMobile != null) {
//                    printReciept.printImage(image)
                    printProductReceipt.printProductReceipt(shopName,address, shopEmail, shopMobile, amount, gstNumber, isPrintGST, image, items, count, method);
                }else{
                    Toast.makeText(MainApplication.currentApplicationContext, "Details missing", Toast.LENGTH_SHORT).show()
                };
            }

            val payment = Payment();

            if(call.method == "paymentMethod"){
                val data = call.argument<Map<String, Any>>("data")
                data?.let {
                    val saleRequest = JSONObject(it)

                    // Call the method to start ICICI payment
//                    val paymentResult = payment.iciciPayment(this@MainActivity, saleRequest)

                    val paymentResult = iciciPayment(this@MainActivity, saleRequest)

                    // Send back the result to Flutter
                    result.success(paymentResult)
                } ?: run {
                    result.error("INVALID_ARGUMENTS", "Missing payment data", null)
                }
            }
        }





    }

}
