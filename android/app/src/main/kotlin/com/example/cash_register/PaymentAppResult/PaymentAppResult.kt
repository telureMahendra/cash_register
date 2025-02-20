package com.example.cash_register.PaymentAppResult

import com.google.gson.annotations.SerializedName

class PaymentAppResult {

    @SerializedName("RESPONSE_TYPE")
    var responseType : String? = null

    @SerializedName("STATUS_CODE")
    var statusCode : String? = null

    @SerializedName("STATUS_MSG")
    var statusMessage : String? = null


}