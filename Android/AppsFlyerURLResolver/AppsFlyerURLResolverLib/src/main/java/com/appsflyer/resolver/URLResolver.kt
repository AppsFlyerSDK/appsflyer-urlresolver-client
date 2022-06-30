package com.appsflyer.resolver

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.VisibleForTesting
import java.net.CookieHandler
import java.net.CookieManager
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class URLResolver {
    private val debug: Boolean
    private val handler: Handler
    private val executors by lazy { Executors.newCachedThreadPool() }

    @VisibleForTesting
    constructor(debug: Boolean = false, handler: Handler) {
        this.debug = debug
        this.handler = handler
    }

    constructor(debug: Boolean = false) : this(debug, Handler(Looper.getMainLooper()))

    init {
        CookieHandler.setDefault(CookieManager())
    }

    fun resolve(url: String?, maxRedirections: Int = 10, urlResolverListener: URLResolverListener) {
        startResolvingJob(url, urlResolverListener) {
            it?.run {
                var redirect = this
                var res: AFHttpResponse? = null
                for (i in 0 until maxRedirections) {
                    // resolve current URL - check for redirection
                    res = resolveInternal(redirect) { con ->
                        if (con.isRedirected) {
                            // redirect
                            con.redirectedTo.also { l ->
                                afDebugLog("redirecting to $l")
                            }
                        } else {
                            // did not redirected
                            null
                        }
                    }
                    res.redirected?.let { r ->
                        redirect = r // if redirected to another URL - update last url
                    } ?: break // break will not work inside `also` block on `resolveInternal`
                }
                res?.apply {
                    // return the last link we found
                    redirected = redirect
                }
            }
        }
    }

    fun resolveJSRedirection(url: String?, urlResolverListener: URLResolverListener) {
        startResolvingJob(url, urlResolverListener) {
            it?.run {
                resolveInternal(this) { con ->
                    if (con.isSuccessful && con.isHtmlPage) {
                        con.jsRedirected
                    } else {
                        null
                    }
                }
            }
        }
    }

    private fun startResolvingJob(
        url: String?,
        urlResolverListener: URLResolverListener,
        job: ResolveJob
    ) {
        executors.submit {
            url?.let {
                afDebugLog("resolving $it")
                if (it.isValidURL) {
                    job(it)?.apply {
                        error?.let {
                            urlResolverListener.executeOnCompleteOnMainThread(null, handler)
                        } ?: redirected.run {
                            afDebugLog("found link: $this")
                            urlResolverListener.executeOnCompleteOnMainThread(this, handler)
                        }
                    } ?: urlResolverListener.executeOnCompleteOnMainThread(null, handler)
                } else {
                    urlResolverListener.executeOnCompleteOnMainThread(it, handler)
                }
            } ?: urlResolverListener.executeOnCompleteOnMainThread(null, handler)
        }
    }

    private fun resolveInternal(uri: String, logic: LookForRedirect): AFHttpResponse {
        val res = AFHttpResponse()
        try {
            uri.openHttpURLConnection().run {
                instanceFollowRedirects = false
                readTimeout = TimeUnit.SECONDS.toMillis(2).toInt()
                connectTimeout = TimeUnit.SECONDS.toMillis(2).toInt()
                val responseCode = responseCode
                res.apply {
                    status = responseCode
                    redirected = logic(this@run)
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
        if (debug) {
            Log.d(TAG, msg)
        }
    }

    private fun afErrorLog(msg: String?, e: Throwable) {
        if (msg != null) {
            Log.e(TAG, msg)
        }
        e.printStackTrace()
    }
}