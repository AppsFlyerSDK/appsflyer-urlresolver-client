package com.appsflyer.resolver

import java.net.CookieHandler
import java.net.CookieManager
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.TimeUnit
import java.util.logging.Level
import java.util.logging.Logger

class URLResolver(private val debug: Boolean = false) {
    private val logger = Logger.getLogger("AppsFlyer_Resolver")

    init {
        CookieHandler.setDefault(CookieManager())
    }

    fun resolveSync(url: String?, maxRedirections: Int = 10): String? {
        if (url == null) {
            return null
        }
        afDebugLog("resolving $url")
        return if (url.isValidURL()) {
            val redirects = ArrayList<String>().apply {
                add(url)
            }
            var res: AFHttpResponse? = null
            for (i in 0 until maxRedirections) {
                // resolve current URL - check for redirection
                res = resolveInternal(redirects.last())
                res.redirected?.let { // if redirected to another URL
                    redirects.add(it)
                } ?: break
            }

            if (res?.error == null) {
                afDebugLog("found link: ${redirects.last()}")
                redirects.last()
            } else null
        } else {
            url
        }
    }

    private fun resolveInternal(uri: String): AFHttpResponse {
        val res = AFHttpResponse()
        try {
            (URL(uri).openConnection() as HttpURLConnection).run {
                instanceFollowRedirects = false
                readTimeout = TimeUnit.SECONDS.toMillis(2).toInt()
                connectTimeout = TimeUnit.SECONDS.toMillis(2).toInt()
                val responseCode = responseCode
                res.status = responseCode
                if (responseCode in 300..308) {
                    // redirect
                    res.redirected = getHeaderField("Location")
                    afDebugLog("redirecting to ${res.redirected}")
                }
                disconnect()
            }
        } catch (e: Throwable) {
            res.error = e.localizedMessage
            afErrorLog(e.message, e)
        }
        return res
    }

    private fun afDebugLog(msg: String) {
        if (debug) logger.log(Level.FINE, msg)
    }

    private fun afErrorLog(msg: String?, e: Throwable) {
        if (msg != null) logger.log(Level.FINE, msg)
        e.printStackTrace()
    }

    private fun String.isValidURL(): Boolean {
        val regex =
            Regex("^(http|https)://(\\w+:{0,1}\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@\\-/]))?")
        return regex.matches(this)
    }
}