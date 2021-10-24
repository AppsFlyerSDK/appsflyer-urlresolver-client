package com.appsflyer.resolver;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import androidx.annotation.Nullable;

import org.junit.Before;
import org.junit.Test;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class UrlResolverJavaTest {
    private final CountDownLatch lock = new CountDownLatch(1);
    String res = null;

    @Before
    public void init() {
        res = null;
    }

    @Test
    public void testResolveUsingBitlyAndLambda() throws InterruptedException {
        new URLResolver(true)
                .resolve("https://bit.ly/38JtcFq", 5, url -> {
                    res = url;
                    lock.countDown();
                });
        assertTrue(lock.await(5, TimeUnit.SECONDS));
        assertEquals(res, "https://paz.onelink.me/waF3/paz");
    }

    @Test
    public void testResolveUsingBitlyAndCallback() throws InterruptedException {
        new URLResolver()
                .resolve("https://bit.ly/38JtcFq", 5, new URLResolverListener() {
                    @Override
                    public void onComplete(@Nullable String url) {
                        res = url;
                        lock.countDown();
                    }
                });
        assertTrue(lock.await(5, TimeUnit.SECONDS));
        assertEquals(res, "https://paz.onelink.me/waF3/paz");
    }
}