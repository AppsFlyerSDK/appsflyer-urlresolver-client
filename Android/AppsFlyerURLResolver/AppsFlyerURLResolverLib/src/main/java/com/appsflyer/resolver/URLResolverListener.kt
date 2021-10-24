package com.appsflyer.resolver

fun interface URLResolverListener {
    fun onComplete(url: String?)
}