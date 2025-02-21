package com.example.cash_register

import android.app.Application
import android.content.Context

class MainApplication : Application() {



    init {
        _instance = this
    }

    companion object {
        private var _instance : MainApplication? = null
        val currentApplicationContext : Context get() = _instance!!.applicationContext
    }
}