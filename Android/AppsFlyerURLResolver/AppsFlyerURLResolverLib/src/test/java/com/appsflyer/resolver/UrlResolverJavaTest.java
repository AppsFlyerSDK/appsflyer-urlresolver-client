package com.appsflyer.resolver;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class UrlResolverJavaTest {
    @Test
    public void testResolveUsingBitlyAndLambda() {
        String res = new URLResolver(true)
                .resolve("https://bit.ly/38JtcFq", 5);
        assertEquals(res, "https://paz.onelink.me/waF3/paz");
    }

    @Test
    public void testResolveUsingBitlyAndCallback() {
        String res = new URLResolver()
                .resolve("https://bit.ly/38JtcFq", 5);
        assertEquals(res, "https://paz.onelink.me/waF3/paz");
    }
}