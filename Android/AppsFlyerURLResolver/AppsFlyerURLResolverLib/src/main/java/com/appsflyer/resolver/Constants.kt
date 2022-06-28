package com.appsflyer.resolver

const val TAG = "AppsFlyer_Resolver"
val HUBSPOT_REGEX = Regex("document\\.location = \"(https://.*)\";")
val URL_REGEX =
    Regex("^(http|https)://(\\w+:{0,1}\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@\\-/]))?")

