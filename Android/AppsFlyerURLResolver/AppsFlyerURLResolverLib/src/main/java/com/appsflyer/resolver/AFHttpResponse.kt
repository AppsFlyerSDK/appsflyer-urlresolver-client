package com.appsflyer.resolver

internal data class AFHttpResponse(
    var redirected: String? = null,
    var status: Int? = null,
    var error: String? = null
)