package com.appsflyer.resolver

import android.os.Handler
import android.util.Log
import java.net.HttpURLConnection
import java.net.URL

internal typealias ResolveJob = (url: String?) -> AFHttpResponse?
internal typealias LookForRedirect = (connection: HttpURLConnection) -> String?

internal val HttpURLConnection.isHtmlPage
    get() = this.getHeaderField("Content-Type").contains("text/html")

internal val HttpURLConnection.isSuccessful
    get() = this.responseCode == 200

internal val HttpURLConnection.isRedirected
    get() = this.responseCode in 300..308

internal val HttpURLConnection.redirectedTo: String?
    get() = this.getHeaderField("Location")

internal val HttpURLConnection.jsRedirected
    get() = this.inputStream.bufferedReader().readText().run {
        // 1. check for a redirection using `<meta http-equiv="refresh"`
        // 2. check for Hubspot redirection regex
        REFRESH_META_REGEX.find(this)?.destructured?.component1()
            ?: HUBSPOT_REGEX.find(this)?.destructured?.component1()
    }

internal val String.isValidURL
    get() = URL_REGEX.matches(this)

internal fun String.openHttpURLConnection() = URL(this).openConnection() as HttpURLConnection

/**
 * Helper method to invoke onComplete callback on the main thread
 * @param url - the result
 * @param handler - used to post the callback on the main thread. Should be `Handler(Looper.getMainLooper())` in production
 */
internal fun URLResolverListener.executeOnCompleteOnMainThread(url: String?, handler: Handler) {
    handler.post {
        Log.d(TAG, "executeOnCompleteOnMainThread: ")
        this.onComplete(url)
    }
}