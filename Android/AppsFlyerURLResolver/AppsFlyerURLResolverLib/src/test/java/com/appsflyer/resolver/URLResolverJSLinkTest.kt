package com.appsflyer.resolver

import com.google.common.io.Resources
import org.junit.Assert
import org.junit.Test
import java.net.URLEncoder
import java.nio.charset.StandardCharsets
import java.util.concurrent.TimeUnit

class URLResolverJSLinkTest : BaseTest() {

    @Test
    fun happyFlow() {
        prepareSuccessfulResponse(body = "valid_url.html".fileContent)
        URLResolver(true, mockHandler).resolveJSRedirection(
            firstURL
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertEquals("https://go.onelink.me/1235/abcd", res)
    }

    @Test
    fun testWhenBodyNotContainsLinkWithProperRegex() {
        prepareSuccessfulResponse(body = "regex_not_exist.html".fileContent)
        URLResolver(true, mockHandler).resolveJSRedirection(
            firstURL
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertNull(res)
    }

    @Test
    fun testWhenContentTypeIsNotHtml() {
        prepareSuccessfulResponse(
            body = "valid_url.html".fileContent,
            contentType = "application/json"
        )
        URLResolver(true, mockHandler).resolveJSRedirection(
            firstURL
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertNull(res)
    }

    @Test
    fun testWhenLinkReturn404() {
        prepareNotFoundResponse()
        URLResolver(true, mockHandler).resolveJSRedirection(
            firstURL
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertNull(res)
    }


    @Test
    fun testNullURL() {
        URLResolver(true, mockHandler).resolveJSRedirection(null) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertNull(res)

    }

    @Test
    fun testNotaURL() {
        URLResolver(true, mockHandler).resolveJSRedirection("abcd") {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertEquals("abcd", res)
    }

    @Test
    fun testEmptyString() {
        URLResolver(true, mockHandler).resolveJSRedirection("") {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertEquals("", res)
    }

    @Test
    fun testWhenURLisEncoded() {
        URLResolver(true, mockHandler).resolveJSRedirection(
            URLEncoder.encode(firstURL, "UTF-8")
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertEquals(
            URLEncoder.encode(firstURL, "UTF-8"), res
        )
    }

    private val String.fileContent: String
        get() = Resources.toString(Resources.getResource(this), StandardCharsets.UTF_8)


}