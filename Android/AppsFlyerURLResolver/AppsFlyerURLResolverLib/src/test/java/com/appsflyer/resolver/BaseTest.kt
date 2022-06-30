package com.appsflyer.resolver

import android.os.Handler
import android.os.Message
import androidx.test.ext.junit.runners.AndroidJUnit4
import io.mockk.every
import io.mockk.mockk
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.runner.RunWith
import org.mockito.junit.MockitoJUnitRunner
import org.mockito.kotlin.any
import org.mockito.kotlin.doAnswer
import org.mockito.kotlin.mock
import org.robolectric.RobolectricTestRunner
import java.net.URL
import java.util.concurrent.CountDownLatch

@RunWith(AndroidJUnit4::class)
abstract class BaseTest {
    private val server = MockWebServer()
    lateinit var firstURL: String
    var res: String? = null
    val lock: CountDownLatch = CountDownLatch(1)
    val mockHandler = mock<Handler> {
        on {post(any()) } doAnswer {
            (it.arguments[0] as Runnable).run()
            true
        }
    }



    @Before
    fun before() {
        firstURL = 0.toDummyUrl()
    }

    @After
    fun tearDown() = server.shutdown()

    fun prepareRedirections(count: Int) {
        (1..count + 1).forEach {
            server.enqueue(MockResponse().apply {
                if (it == count + 1) {
                    setResponseCode(200)
                } else {
                    //set random redirect status code
                    setResponseCode((300..308).random())
                    addHeader("Location", it.toDummyUrl())
                }
            })
        }
    }

    fun prepareSuccessfulResponse(contentType: String = "text/html", body: String = "") =
        server.enqueue(MockResponse().apply {
            setResponseCode(200)
            setBody(body)
            setHeader("Content-Type", contentType)
        })

    fun prepareNotFoundResponse() = server.enqueue(MockResponse().apply {
        setResponseCode(404)
    })


    protected fun Int.toDummyUrl() =
        server.url(URL("https://af$this.appsflyer.com/$this/urlresolver?test=true").path).toString()
}