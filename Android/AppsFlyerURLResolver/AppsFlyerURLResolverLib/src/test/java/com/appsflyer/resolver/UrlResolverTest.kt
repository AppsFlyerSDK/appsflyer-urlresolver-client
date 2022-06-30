package com.appsflyer.resolver

import org.junit.Assert.*
import org.junit.Test
import java.net.URLEncoder
import java.util.concurrent.TimeUnit

class UrlResolverTest : BaseTest() {

    @Test
    fun testHappyFlow() {
        prepareRedirections(8)
        URLResolver(true, mockHandler).resolve(firstURL) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(120, TimeUnit.SECONDS))
        assertEquals(8.toDummyUrl(), res)
    }


    @Test
    fun testReachToMaximum() {
        prepareRedirections(8)
        URLResolver(true, mockHandler).resolve(firstURL, 6) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals(6.toDummyUrl(), res)
    }

    @Test
    fun testResolveUsingCallback() {
        prepareRedirections(5)
        URLResolver(true, mockHandler).resolve(firstURL, 10, object : URLResolverListener {
            override fun onComplete(url: String?) {
                res = url
                lock.countDown()
            }
        })
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals(5.toDummyUrl(), res)

    }

    @Test
    fun testResolveUsingCallbackObject() {
        prepareRedirections(5)
        val listener = object : URLResolverListener {
            override fun onComplete(url: String?) {
                res = url
                lock.countDown()
            }
        }
        URLResolver(true, mockHandler).resolve(firstURL, 10, listener)
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals(5.toDummyUrl(), res)

    }

    @Test
    fun testNullURL() {
        URLResolver(true, mockHandler).resolve(null, 5) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertNull(res)

    }

    @Test
    fun testNotaURL() {
        URLResolver(true, mockHandler).resolve("abcd", 5) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals("abcd", res)
    }

    @Test
    fun testEmptyString() {
        URLResolver(true, mockHandler).resolve("", 5) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals("", res)
    }

    @Test
    fun testWhenURLisEncoded() {
        URLResolver(true, mockHandler).resolve(
            URLEncoder.encode(firstURL, "UTF-8"),
            8
        ) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals(
            URLEncoder.encode(firstURL, "UTF-8"), res
        )
    }

    @Test
    fun testWhenLinkReturn200() {
        prepareSuccessfulResponse()
        URLResolver(true, mockHandler).resolve(firstURL) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals(firstURL, res)
    }

    @Test
    fun testWhenLinkReturn404() {
        prepareNotFoundResponse()
        URLResolver(true, mockHandler).resolve(firstURL) {
            res = it
            lock.countDown()
        }
        assertTrue(lock.await(5, TimeUnit.SECONDS))
        assertEquals(firstURL, res)
    }

}