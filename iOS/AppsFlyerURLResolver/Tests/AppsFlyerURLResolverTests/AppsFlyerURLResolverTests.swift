//
//  AppsFlyerResolverTests.swift
//  AppsFlyerResolverTests
//
//  Created by Paz Lavi  on 23/09/2021.
//

import XCTest
@testable import AppsFlyerURLResolver

class AppsFlyerURLResolverTests: XCTestCase {
    
    var logger : AppsFlyerLogger!
    var jsResolver : JSRedirectionHandler!
    
    override func setUp() {
        super.setUp()
        logger = afLogger()
        jsResolver = JSRedirectionHandler(logger: logger) { link in
            print(">>Got link! \(link ?? "")")
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNullURL() throws {
        var res : String?
        let expectation = self.expectation(description: "Waiting for the resolve call to complete.")
        URLResolver(isDebug: true).resolve(url: nil){url in
            res = url
            expectation.fulfill()

        }
        waitForExpectations(timeout: 2){ error in
            XCTAssertNil(error)
            XCTAssertEqual(nil , res, "url is not nil")
        }
    }

    func testEmptyString() throws {
        var res : String?
        let expectation = self.expectation(description: "Waiting for the resolve call to complete.")
        URLResolver().resolve(url: ""){url in
            res = url
            expectation.fulfill()

          
        }
        waitForExpectations(timeout: 2){ error in
            XCTAssertNil(error)
            XCTAssertEqual("" , res, "url is not empty")
        }
    }
    
    func testNotaURL() throws {
        var res : String?
        let expectation = self.expectation(description: "Waiting for the resolve call to complete.")
        URLResolver().resolve(url: "adf") { url in
            res = url
            expectation.fulfill()

          
        }
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual("adf" , res, "url is not 'adf'")
        }
    }
    
    func testWhenURLisEncoded() throws {
        var res : String?
        let expectation = self.expectation(description: "Waiting for the resolve call to complete.")

        URLResolver().resolve(url: "https%3A%2F%2Fmi.gap.com%2Fp%2Fcp%2Fd46c31d50872e4b3%2Fc%3Fmi_u%3D51635872%26EV%3DGPUSCPATHTSTPC4048593PERST1_WMNNLPSPRP04162021%26DI%3D51635872%26CD%3DGPNC_GPR%26cvosrc%3Demail.exacttarget.GPUS04162021%26EV_Segment1%3DGPUSGWMET%26url%3Dhttps%253A%252F%252Fmi.gap.com%252Fp%252Frp%252F6d2aa0caedfe8322%252Furl%26mi_u%3D%25%25email_key%25%25%26EV%3D%25%25EV_value%25%25%26DI%3D%25%25DI_value%25%25%26CD%3D%25%25CD_value%25%25") { url in
            res = url
            expectation.fulfill()

          
        }
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual("https%3A%2F%2Fmi.gap.com%2Fp%2Fcp%2Fd46c31d50872e4b3%2Fc%3Fmi_u%3D51635872%26EV%3DGPUSCPATHTSTPC4048593PERST1_WMNNLPSPRP04162021%26DI%3D51635872%26CD%3DGPNC_GPR%26cvosrc%3Demail.exacttarget.GPUS04162021%26EV_Segment1%3DGPUSGWMET%26url%3Dhttps%253A%252F%252Fmi.gap.com%252Fp%252Frp%252F6d2aa0caedfe8322%252Furl%26mi_u%3D%25%25email_key%25%25%26EV%3D%25%25EV_value%25%25%26DI%3D%25%25DI_value%25%25%26CD%3D%25%25CD_value%25%25" , res, "https%3A%2F%2Fmi.gap.com%2Fp%2Fcp%2Fd46c31d50872e4b3%2Fc%3Fmi_u%3D51635872%26EV%3DGPUSCPATHTSTPC4048593PERST1_WMNNLPSPRP04162021%26DI%3D51635872%26CD%3DGPNC_GPR%26cvosrc%3Demail.exacttarget.GPUS04162021%26EV_Segment1%3DGPUSGWMET%26url%3Dhttps%253A%252F%252Fmi.gap.com%252Fp%252Frp%252F6d2aa0caedfe8322%252Furl%26mi_u%3D%25%25email_key%25%25%26EV%3D%25%25EV_value%25%25%26DI%3D%25%25DI_value%25%25%26CD%3D%25%25CD_value%25%25")

        }

    }
    
    func testResolveUsingBitly() throws {
        var res : String?
        let expectation = self.expectation(description: "Waiting for the resolve call to complete.")
        URLResolver().resolve(url: "https://bit.ly/38JtcFq") { url in
            res = url
            expectation.fulfill()

          
        }
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual("https://paz.onelink.me/waF3/paz" , res, "url is not 'https://paz.onelink.me/waF3/paz'")
        }
    }
    
    func testResolveMILink() throws {
        var res : String?
        let expectation = self.expectation(description: "Waiting for the resolve call to complete.")
        
        URLResolver().resolve(url: "https://mi.gap.com/p/cp/d46c31d50872e4b3/c?mi_u=51635872&EV=GPUSCPATHTSTPC4048593PERST1_WMNNLPSPRP04162021&DI=51635872&CD=GPNC_GPR&cvosrc=email.exacttarget.GPUS04162021&EV_Segment1=GPUSGWMET&url=https%3A%2F%2Fmi.gap.com%2Fp%2Frp%2F6d2aa0caedfe8322%2Furl&mi_u=%%email_key%%&EV=%%EV_value%%&DI=%%DI_value%%&CD=%%CD_value%%"){url in
            res = url
            expectation.fulfill()

          
        }
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual("https://www.gap.com/?mi_u=%25%25email_key%25%25&EV=%25%25EV_value%25%25&DI=%25%25DI_value%25%25&CD=%25%25CD_value%25%25&cvosrc=email.exacttarget.GPUS04162021&EV_Segment1=GPUSGWMET" , res, "url is not 'https://www.gap.com/?mi_u=%25%25email_key%25%25&EV=%25%25EV_value%25%25&DI=%25%25DI_value%25%25&CD=%25%25CD_value%25%25&cvosrc=email.exacttarget.GPUS04162021&EV_Segment1=GPUSGWMET'")
        }
    }
    
    func testExtractLastLinkFromJSCode() {
        let expectedLink = "https://press4.esp-integrations1.com/events/public/v1/encoded/track/tc/2M+113/d12tHd04/VVK-bf2f67cmN2fsLtxZYJZQW1xTZ7Q4DqyQKN15bQW15kh3GV3Zsc37CgSm4W2JScLr14y7M2VV3ngb3BrK4BW6nLdLT4St_jPW2qBVCl8SJjZxW3nhQxC5wW-3nN5wZSff2_8ypW8LFXLZ151NTvN3h9_tJTh2PRW9hY7jz8BbrhZW2kXwjg1Pwz3jW2wgFPd5HR6WYW4LcTKC2_wnv0V540B12Y94SjW7Yy3ZT6Kx1cBW3R5C7x6pkwgbW2R6D1C70NmS5W3_wCQQ4BQG4ZN36fyG1xFfTPW4RL9rT2zl_ZWW131LQL30lXpJW4VPyXL2FDkbZW7td7KS2wjHNYW6M8fdx8Mfn3mN6m0Yd76Y0tyW6_Xrx-1Qz2gGW3rxsBr752S-KN3xHDpHMgd4GW3LrpFv4CcBycW6t9QL85HKKsBW4FnRlc7SMDVdW78SRcQ8xKhbGW4dLrDk82QL9C37pQ1?_ud=4625877d-802e-4807-87fd-9a8f28adf082"
        
        let lastLink = jsResolver.extractLinkFrom(JSCode: Helpers.HubspotJSExample)
        print(">>Got link! \(lastLink ?? "")")
        XCTAssertEqual(lastLink, expectedLink)
    }
    
    func testRegexMatchesInText() {
        let str = "yala@lech@habaita@moti"
        let charactersArray = jsResolver.matches(for: "@", in: str)
        print(">> \(charactersArray)")
        XCTAssertEqual(charactersArray.count, 3)
    }
}
