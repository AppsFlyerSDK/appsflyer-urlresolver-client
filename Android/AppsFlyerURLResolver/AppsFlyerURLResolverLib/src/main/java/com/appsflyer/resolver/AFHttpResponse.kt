package com.appsflyer.resolver

data class AFHttpResponse(var redirected: String?, var status: Int?, var error: String?) {
    constructor() : this(null, null, null)
}