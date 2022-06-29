package com.appsflyer.resolver

internal const val TAG = "AppsFlyer_Resolver"
internal val HUBSPOT_REGEX = Regex("document\\.location = \"(https://.*)\";")
internal val URL_REGEX =
    Regex("^(http|https)://(\\w+:{0,1}\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@\\-/]))?")

