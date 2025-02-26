package com.example.cash_register

import android.app.Instrumentation.ActivityResult
import android.content.ComponentName
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

//import androidx.activity.result.ActivityResult
//import androidx.activity.result.ActivityResult




class MainActivity: FlutterActivity() {


//    val resultLauncher = registerForActivityResult(
//        ActivityResultContracts.StartActivityForResult()
//    ) { result: ActivityResult ->
//        handlePaymentAppResult(result)
//    }

    private val REQUESTCODE = 101

    private var resultMethodChannel: MethodChannel.Result?  = null

    


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        Log.d(TAG, "onActivityResult: getting result from activity")



        var bundle: Bundle? = null
        try {
            bundle = data!!.extras
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }

        if (requestCode == REQUESTCODE){

            Log.d(TAG, "onActivityResult: Data received from payment app")
            Log.d(TAG, "onActivityResult: result codde is : $resultCode")



        val root: JSONObject = JSONObject(bundle!!.getString("RESULT"))

        val RESPONSE_TYPE = root.getString("RESPONSE_TYPE")
        val STATUS_CODE = root.getString("STATUS_CODE")
        var STATUS_MSG = root.getString("STATUS_MSG")
        Log.e(
            TAG,
            "onActivityResult: " + RESPONSE_TYPE + " " + STATUS_CODE + "STATUS_MSG" + STATUS_MSG
        )

        if (root.getString("STATUS_CODE").contentEquals("00")
        )
         {
            val result = data?.getStringExtra("RESULT")
            Log.d(TAG, "onActivityResult: Payment Completed")
            resultMethodChannel?.success(result)
        }else {
            Log.d(TAG, "onActivityResult: Payment failed")
            val result = data?.getStringExtra("RESULT")
            resultMethodChannel?.error("TRANSACTION_FAILED", result, null)
        }
        }
    }


//    private val resultLauncher = registerForActivityResult(
//        ActivityResultContracts.StartActivityForResult()
//    ) { result: ActivityResult ->
//        handlePaymentAppResult(result)
//    }

//    private fun handlePaymentAppResult(result: ActivityResult) {
//        val bundleData: Bundle? = result.resultData?.extras
//        val resultString = bundleData?.getString("RESULT")
//
//
//        val parsedResult: PaymentAppResult? = try {
//            Gson().fromJson(resultString, PaymentAppResult::class.java)
//        } catch (_: Exception) {
//            null
//        }
//
//        if (parsedResult?.statusCode == "00") {
////            showPaymentSuccessDialog() // TODO : Handle Here
////            clearCartData()
//            Log.d(TAG, "handlePaymentAppResult: payment success")
//        } else {
////            showPaymentFailureDialog(parsedResult?.statusMessage)
//            Log.d(TAG, "handlePaymentAppResult: payment failed")
//        }
//
//    }

    fun iciciPayment(context: Context, saleRequest: JSONObject, TRAN_TYPE:String) {

        val intent = Intent()
        intent.component = ComponentName(
            "com.icici.viz.smartpeak",
            "vizpay.launchermodule.VizLauncherActivity"
        )

        intent.putExtra("REQUEST_TYPE", TRAN_TYPE)
        intent.putExtra("DATA", saleRequest.toString())

        startActivityForResult(intent, REQUESTCODE)

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
            val TRAN_TYPE = args["TRAN_TYPE"].toString();


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
                    resultMethodChannel = result
                    // Call the method to start ICICI payment
//                    val paymentResult = payment.iciciPayment(this@MainActivity, saleRequest)

                    iciciPayment(this@MainActivity, saleRequest, TRAN_TYPE)

                } ?: run {
                    result.error("INVALID_ARGUMENTS", "Missing payment data", null)
                }
            }
        }





    }

}
