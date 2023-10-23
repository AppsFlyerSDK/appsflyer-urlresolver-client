package com.appsflyer.resolver

import com.google.common.io.Resources
import org.junit.Assert
import org.junit.Test
import java.net.URLEncoder
import java.nio.charset.StandardCharsets
import java.util.concurrent.TimeUnit

class URLResolverJSLinkTest : BaseTest() {

    @Test
    fun happyFlowHubspot() =
        happyFlowTest("https://go.onelink.me/1235/abcd", "valid_url_hubspot.html")

    @Test
    fun happyFlowEmersys() = happyFlowTest(
        "https://yossiesp.onelink.me/Amo7?pid=yossiemarsys&amp;c=ESPTEST&amp;af_force_deeplink=true&amp;is_retargeting=true",
        "valid_url_emersys.html"
    )

    @Test
    fun `test Emersys return null when missing redirection link`() =
        regexNotFoundTest("not_valid_url_emersys.html")

    @Test
    fun testWhenBodyNotContainsLinkWithProperRegex() = regexNotFoundTest("regex_not_exist.html")

    @Test
    fun testWhenContentTypeIsNotHtml() {
        prepareSuccessfulResponse(
            body = "valid_url_hubspot.html".fileContent,
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

    private fun happyFlowTest(expectedUrl: String, html: String) {
        prepareSuccessfulResponse(body = html.fileContent)
        URLResolver(true, mockHandler).resolveJSRedirection(
            firstURL
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertEquals(expectedUrl, res)
    }

    private fun regexNotFoundTest(html: String) {
        prepareSuccessfulResponse(body = html.fileContent)
        URLResolver(true, mockHandler).resolveJSRedirection(
            firstURL
        ) {
            res = it
            lock.countDown()
        }
        Assert.assertTrue(lock.await(5, TimeUnit.SECONDS))
        Assert.assertNull(res)
    }

    private val String.fileContent: String
        get() = Resources.toString(Resources.getResource(this), StandardCharsets.UTF_8)


}