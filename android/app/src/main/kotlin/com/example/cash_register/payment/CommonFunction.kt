package vizpay.CommonUtils

import android.app.Activity
import android.util.Log
import android.view.inputmethod.InputMethodManager
import java.text.SimpleDateFormat
import java.util.*


/**
 * Company Name:Vizpay
 * Developer Name:Nikita/Vaishnavi
 * Date:11/06/2022
 * Descriptions:CommonFunction is used for to get common functions & common strings
 */
class CommonFunction {

    companion object {
        const val UNIQUE_KEY = "123456"
        const val SALE = "SALE"
        const val VOID = "VOID"
        const val SETTLEMENT ="SETTLEMENT"
        const val BQR = "BQR"
        const val QR = "QR"
        const val CASHATPOS = "CASHATPOS"
        const val PREAUTH = "PREAUTH"
        const val AUTHCOMPLETION = "AUTHCOMPLETION"
        const val TRANSACTION_STATUS_CHECK ="TRANSACTION_STATUS_CHECK"
        const val ANYRECEIPT = "ANYRECEIPT"
        const val LASTRECEIPT = "LASTRECEIPT"
        const val DETAILREPORT ="DETAILREPORT"


        val SALE_CODE_RESULT_CODE = 101
        val VOID_CODE_RESULT_CODE = 102
        val QR_CODE_RESULT_CODE = 103
        val CASHATPOS_CODE_RESULT_CODE = 104
        val PREAUTH_CODE_RESULT_CODE = 105
        val AUTHCOMPLETION_CODE_RESULT_CODE = 106
        val SETTLMENT_CODE_REQUEST_CODE = 107
        val CHECKTXNSTATUS_CODE_REQUEST_CODE = 108
        val ANYRECEIPT_CODE_RESULT_CODE = 109
        val LASTRECEIPT_CODE_RESULT_CODE = 110
        val DETAILREPORT_CODE_RESULT_CODE =111


        val PACKAGE_NAME =  "com.icici.viz.verifone"//"com.icici.viz.pax"//"com.icici.viz.verifone"
       // val PACKAGE_NAME =  "com.vizpay.phonepe"
        val APP_NOT_INSTALLED = "Application not installed!!!"



        fun gerrateRandomNumber(): String? {

            var randomNumbr: String? = null
            val dt = getDateTime()
            // It will generate 6 digit random Number.
            // from 0 to 999999
            val rnd = Random()
            val number = rnd.nextInt(999999)
            // this will convert any number sequence into 6 character.
            // return String.format("%06d", number)
            randomNumbr = dt + String.format("%06d", number)
            Log.e("gerrateRandomNumber :: ", "randomNumbr : " + randomNumbr)

            return randomNumbr

        }



        fun getDateTime(): String? {
            var current: String? = null

            try {
                val time = Calendar.getInstance().time
                val formatter = SimpleDateFormat("yyyyMMddHHmmss")
                current = formatter.format(time)
                Log.e("getDateTime :: ", "current : " + current)

            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
            return current
        }

        @JvmStatic
        fun hideKeyboardDirect(mContext: Activity) {
            val inputMethodManager = mContext.getSystemService(
                Activity.INPUT_METHOD_SERVICE
            ) as InputMethodManager
            try {
                inputMethodManager.hideSoftInputFromWindow(
                    mContext.currentFocus!!.windowToken, 0
                )
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
        }

    }
}
