package com.appsflyer.resolver

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class UrlResolverTest {
    private val lock: CountDownLatch = CountDownLatch(1)

    @Test
    fun testResolveUsingBitlyAndLambda() {
        var res: String? = null
        URLResolver(true).resolve("https://bit.ly/38JtcFq", 5) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(res, "https://paz.onelink.me/waF3/paz")
    }

    @Test
    fun testResolveMILink() {
        var res: String? = null
        URLResolver(true).resolve(
            "https://mi.gap.com/p/cp/d46c31d50872e4b3/c?mi_u=51635872&EV=GPUSCPATHTSTPC40485" +
                    "93PERST1_WMNNLPSPRP04162021&DI=51635872&CD=GPNC_GPR&cvosrc=email.exacttarget" +
                    ".GPUS04162021&EV_Segment1=GPUSGWMET&url=https%3A%2F%2Fmi.gap.com%2Fp%2Frp%2F" +
                    "6d2aa0caedfe8322%2Furl&mi_u=%%email_key%%&EV=%%EV_value%%&DI=%%DI_value%%&CD" +
                    "=%%CD_value%%",
        ) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(
            res,
            "https://www.gap.com/?mi_u=%25%25email_key%25%25&EV=%25%25EV_value%25%25&DI=%2" +
                    "5%25DI_value%25%25&CD=%25%25CD_value%25%25&cvosrc=email.exacttarget.GPUS0416" +
                    "2021"
        )
    }

    @Test
    fun testReachToMaximum() {
        var res: String? = null
        URLResolver(true).resolve(
            "https://mi.gap.com/p/cp/d46c31d50872e4b3/c?mi_u=51635872&EV=GPUSCPATHTSTPC40485" +
                    "93PERST1_WMNNLPSPRP04162021&DI=51635872&CD=GPNC_GPR&cvosrc=email.exacttarget" +
                    ".GPUS04162021&EV_Segment1=GPUSGWMET&url=https%3A%2F%2Fmi.gap.com%2Fp%2Frp%2F" +
                    "6d2aa0caedfe8322%2Furl&mi_u=%%email_key%%&EV=%%EV_value%%&DI=%%DI_value%%&CD" +
                    "=%%CD_value%%",
            2
        ) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertNotEquals(
            res,
            "https://www.gap.com/?mi_u=%25%25email_key%25%25&EV=%25%25EV_value%25%25&DI=%2" +
                    "5%25DI_value%25%25&CD=%25%25CD_value%25%25&cvosrc=email.exacttarget.GPUS0416" +
                    "2021"
        )
    }

    @Test
    fun testResolveUsingBitlyAndCallback() {
        var res: String? = null
        URLResolver(true).resolve("https://bit.ly/38JtcFq", 5, object : URLResolverListener {
            override fun onComplete(url: String?) {
                res = url
            }
        })
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(res, "https://paz.onelink.me/waF3/paz")

    }

    @Test
    fun testResolveUsingBitlyAndCallbackObject() {
        var res: String? = null
        val listener = object : URLResolverListener {
            override fun onComplete(url: String?) {
                res = url
            }
        }
        URLResolver(true).resolve("https://bit.ly/38JtcFq", 5, listener)
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(res, "https://paz.onelink.me/waF3/paz")

    }

    @Test
    fun testNullURL() {
        var res: String? = null
        URLResolver(true).resolve(null, 5) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(res, null)

    }

    @Test
    fun testNotaURL() {
        var res: String? = null
        URLResolver(true).resolve("abcd", 5) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(res, "abcd")
    }

    @Test
    fun testEmptyString() {
        var res: String? = null
        URLResolver(true).resolve("", 5) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(res, "")
    }

    @Test
    fun testWhenURLisEncoded() {
        var res: String? = "12"
        URLResolver(true).resolve(
            "https%3A%2F%2Fmi.gap.com%2Fp%2Fcp%2Fd46c31d50872e4b3%2Fc%3Fmi_u%3D51635872%26EV" +
                    "%3DGPUSCPATHTSTPC4048593PERST1_WMNNLPSPRP04162021%26DI%3D51635872%26CD%3DGPN" +
                    "C_GPR%26cvosrc%3Demail.exacttarget.GPUS04162021%26EV_Segment1%3DGPUSGWMET%26" +
                    "url%3Dhttps%253A%252F%252Fmi.gap.com%252Fp%252Frp%252F6d2aa0caedfe8322%252Fu" +
                    "rl%26mi_u%3D%25%25email_key%25%25%26EV%3D%25%25EV_value%25%25%26DI%3D%25%25D" +
                    "I_value%25%25%26CD%3D%25%25CD_value%25%25",
            5
        ) {
            res = it
        }
        lock.await(5, TimeUnit.SECONDS)
        assertEquals(
            res,
            "https%3A%2F%2Fmi.gap.com%2Fp%2Fcp%2Fd46c31d50872e4b3%2Fc%3Fmi_u%3D51635872%26" +
                    "EV%3DGPUSCPATHTSTPC4048593PERST1_WMNNLPSPRP04162021%26DI%3D51635872%26CD%3DG" +
                    "PNC_GPR%26cvosrc%3Demail.exacttarget.GPUS04162021%26EV_Segment1%3DGPUSGWMET%" +
                    "26url%3Dhttps%253A%252F%252Fmi.gap.com%252Fp%252Frp%252F6d2aa0caedfe8322%252" +
                    "Furl%26mi_u%3D%25%25email_key%25%25%26EV%3D%25%25EV_value%25%25%26DI%3D%25%2" +
                    "5DI_value%25%25%26CD%3D%25%25CD_value%25%25"
        )
    }
}