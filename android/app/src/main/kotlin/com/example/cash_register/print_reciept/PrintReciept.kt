package com.example.cash_register.print_reciept

import android.graphics.BitmapFactory
import android.os.Build
import android.os.Message
import android.widget.Toast
import androidx.annotation.RequiresApi
import com.basewin.aidl.OnPrinterListener
import com.basewin.define.GlobalDef
import com.basewin.models.TextPrintLine
import com.basewin.packet8583.model.BitMap
import com.basewin.services.PrinterBinder
import com.basewin.services.ServiceManager
import com.example.cash_register.MainApplication
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter
//import java.util.Base64
import android.util.Base64

import android.graphics.Bitmap
import com.basewin.models.BitmapPrintLine
import com.basewin.models.PrintLine


class PrintReciept() {

    fun vizAddSpace(spaceLength: Int): String {
        var tempStr = ""
        for (i in 0 until spaceLength) {
            tempStr = "$tempStr "
        }
        return tempStr
    }

    fun decodeBase64ToBitmap(encodedImage: String): Bitmap? {
        val decodedBytes = Base64.decode(encodedImage, Base64.DEFAULT)
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun printImage(encodedImage: String){
        ServiceManager.getInstence().init(MainApplication.currentApplicationContext)
        val printer: PrinterBinder = ServiceManager.getInstence().printer
        printer.cleanCache()
        printer.printTypesettingType = GlobalDef.PRINTERLAYOUT_TYPESETTING
        printer.setPrintGray(Integer.valueOf(1000))
        printer.setPrintFontByAsserts("RobotoMono.ttf")
        printer.setLineSpace(0)
        val textPrintLine = TextPrintLine()


        val options = BitmapFactory.Options()
        options.inScaled = false
        var bitmap: Bitmap? = null

        try {
            bitmap= decodeBase64ToBitmap(encodedImage)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (bitmap != null) {
            val bitmapPrintLine = BitmapPrintLine()
            bitmapPrintLine.type = PrintLine.BITMAP
            bitmapPrintLine.position = PrintLine.CENTER
            bitmapPrintLine.bitmap = bitmap

            try {
                printer?.addPrintLine(bitmapPrintLine)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

//        textPrintLine.content = "\n\n"
//        printer.addPrintLine(textPrintLine)

        // start print here
        printer.beginPrint(object : OnPrinterListener {
            override fun onError(p0: Int, error: String?) {
                Toast.makeText(MainApplication.currentApplicationContext, "Error", Toast.LENGTH_SHORT).show()
                val msg = Message()
                msg.data.putString("msg", "print error,errno:$p0")

                printer.cleanCache()
            }

            override fun onFinish() {
//            TODO("Not yet implemented")
            }

            override fun onStart() {
//            TODO("Not yet implemented")
            }
        }
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun printCartReceipt( shopName:String, address: String, shopEmail:String, shopMobile:String , amount:String, gstNumber:String, isPrintGST: String, encodedImage: String) {

        ServiceManager.getInstence().init(MainApplication.currentApplicationContext)
        val printer: PrinterBinder = ServiceManager.getInstence().printer

//       if (!printer.queryIfHavePaper()){
//           return false;
//       }


        val note = "Note: Goods once sold will not be taken back or exchanged."

        printer.cleanCache()
        printer.printTypesettingType = GlobalDef.PRINTERLAYOUT_TYPESETTING
        printer.setPrintGray(Integer.valueOf(1000))
        printer.setPrintFontByAsserts("RobotoMono.ttf")



        val options = BitmapFactory.Options()
        options.inScaled = false
        var bitmap: Bitmap? = null

        try {
            bitmap= decodeBase64ToBitmap(encodedImage)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (bitmap != null) {
            val bitmapPrintLine = BitmapPrintLine()
            bitmapPrintLine.type = PrintLine.BITMAP
            bitmapPrintLine.position = PrintLine.CENTER
            bitmapPrintLine.bitmap = bitmap

            try {
                printer?.addPrintLine(bitmapPrintLine)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        printer.setLineSpace(0)
        val textPrintLine = TextPrintLine()
        textPrintLine.content = shopName
        textPrintLine.isBold = true
        textPrintLine.size = TextPrintLine.FONT_LARGE
        textPrintLine.position = TextPrintLine.CENTER
//        printer.setLineSpace(15)
        printer.addPrintLine(textPrintLine)


        printer.setLineSpace(0)
        textPrintLine.size = TextPrintLine.FONT_SMALL
        textPrintLine.content = address
        textPrintLine.isBold = false
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)

        printer.setLineSpace(-12  )
        textPrintLine.content = "\n"
        printer.addPrintLine(textPrintLine)

        printer.setLineSpace(0)
        textPrintLine.size = 19
        textPrintLine.content = "Email: ${shopEmail}"
        textPrintLine.isBold = false
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)



        textPrintLine.size = 19
        textPrintLine.content = "Mobile: ${shopMobile}"
        textPrintLine.isBold = false
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)

        printer.setLineSpace(10)
        if (isPrintGST == "true"){
            textPrintLine.size = TextPrintLine.FONT_NORMAL
            textPrintLine.content = "GST: $gstNumber"
            textPrintLine.isBold = false
            textPrintLine.position = TextPrintLine.CENTER
            printer.addPrintLine(textPrintLine)
        }


        val currentTime = LocalTime.now()
        val formatterTime = DateTimeFormatter.ofPattern("HH:mm:ss")
        val formattedTime = currentTime.format(formatterTime)

        val currentDate = LocalDate.now()
        val formatterDate = DateTimeFormatter.ofPattern("dd-MM-yyyy")
        val formattedDate = currentDate.format(formatterDate)


        printer.setLineSpace(10)
        textPrintLine.size = TextPrintLine.FONT_SMALL
        textPrintLine.isBold = true
        textPrintLine.content = "DATE: ${formattedDate}${vizAddSpace(25-formattedDate.length-formattedTime.length)}TIME: ${formattedTime}"
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)


        textPrintLine.size = TextPrintLine.FONT_SMALL
        printer.setLineSpace(0)
        textPrintLine.isBold = false
        textPrintLine.content = "--------------------------------------"
        printer.addPrintLine(textPrintLine)

        textPrintLine.size = TextPrintLine.FONT_NORMAL
        textPrintLine.content = "Item${vizAddSpace(17)}Amount"
        printer.addPrintLine(textPrintLine)

        textPrintLine.size = TextPrintLine.FONT_SMALL
        textPrintLine.content = "--------------------------------------"
        printer.addPrintLine(textPrintLine)

        printer.setLineSpace(10)
        textPrintLine.size=TextPrintLine.FONT_SMALL
        textPrintLine.isBold = true
        textPrintLine.content = "Goods${vizAddSpace(33-amount.length)}${amount}"
        printer.addPrintLine(textPrintLine)


        printer.setLineSpace(0)
        textPrintLine.isBold = false
        textPrintLine.content = "======================================"
        printer.addPrintLine(textPrintLine)

        textPrintLine.isBold= true
        textPrintLine.content = "Total${vizAddSpace(22-amount.length)}${amount}"
        textPrintLine.position = TextPrintLine.RIGHT
        textPrintLine.size = TextPrintLine.FONT_NORMAL
        printer.addPrintLine(textPrintLine)

        textPrintLine.isBold = false
        textPrintLine.size=TextPrintLine.FONT_SMALL
        textPrintLine.content = "======================================"
        printer.addPrintLine(textPrintLine)



        textPrintLine.size = TextPrintLine.FONT_NORMAL
        textPrintLine.content = "Thank You!"
        textPrintLine.isBold = true
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)

        textPrintLine.size = TextPrintLine.FONT_SMALL
        textPrintLine.content = note
        textPrintLine.isBold = false
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)

        printer.setLineSpace(10)
        textPrintLine.size = TextPrintLine.FONT_SMALL
        textPrintLine.content = "Powerd by: Vizpay Business Solutions Pvt. Ltd."
        textPrintLine.position = TextPrintLine.CENTER
        printer.addPrintLine(textPrintLine)



        textPrintLine.content = "\n\n"
        printer.addPrintLine(textPrintLine)

        // start print here
        printer.beginPrint(object : OnPrinterListener {
            override fun onError(p0: Int, error: String?) {
                Toast.makeText(MainApplication.currentApplicationContext, "Error", Toast.LENGTH_SHORT).show()
                val msg = Message()
                msg.data.putString("msg", "print error,errno:$p0")

                printer.cleanCache()
            }

            override fun onFinish() {
//            TODO("Not yet implemented")
            }

            override fun onStart() {
//            TODO("Not yet implemented")
            }


        }
        )


    }
}