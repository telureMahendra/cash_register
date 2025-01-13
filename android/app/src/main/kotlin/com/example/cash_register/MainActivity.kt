package com.example.cash_register

import android.os.Build
import android.widget.Toast
import androidx.annotation.RequiresApi
import com.example.cash_register.print_reciept.PrintReciept
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private  val channelName = "printMethod";

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        var channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName);

        channel.setMethodCallHandler{call, result ->

            var args = call.arguments as Map< String, String>;


            var address = args["address"].toString();
            var shopEmail = args["shopEmail"].toString();
            var shopMobile = args["shopMobile"].toString();
            var shopName = args["shopName"].toString();
            var amount = args["amount"].toString();
            var gstNumber = args["gstNumber"].toString();
            var isPrintGST = args["isPrintGST"].toString();


            if(call.method == "printCartReceipt"){
                val printReciept = PrintReciept();
                if (shopName != null && address != null && shopEmail != null && shopMobile != null) {
                     printReciept.printCartReceipt(shopName,address, shopEmail, shopMobile, amount, gstNumber, isPrintGST);
                }else{
                    Toast.makeText(MainApplication.currentApplicationContext, "Details missing", Toast.LENGTH_SHORT).show()
                };
            }
        }


    }

}
