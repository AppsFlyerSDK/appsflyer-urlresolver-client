package com.appsflyer.resolver

import java.net.HttpURLConnection
import java.net.URL

typealias ResolveJob = (url: String?) -> AFHttpResponse?
typealias LookForRedirect = (connection: HttpURLConnection) -> String?

val HttpURLConnection.isHtmlPage
    get() = this.getHeaderField("Content-Type").contains("text/html")

val HttpURLConnection.isSuccessful
    get() = this.responseCode == 200

val HttpURLConnection.isRedirected
    get() = this.responseCode in 300..308

val HttpURLConnection.redirectedTo: String?
    get() = this.getHeaderField("Location")

val HttpURLConnection.jsRedirected
    get() = this.inputStream.bufferedReader().readText().run {
        HUBSPOT_REGEX.find(this)?.destructured?.component1()
    }

val String.isValidURL
    get() = URL_REGEX.matches(this)

fun String.openHttpURLConnection() = URL(this).openConnection() as HttpURLConnection