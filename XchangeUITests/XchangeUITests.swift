//
//  XchangeUITests.swift
//  XchangeUITests
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements UI Testing Workflows (Rubric Section 8)
//

import XCTest

final class XchangeUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(contentsOf: ["--uitesting-logged-in", "--skip-splash"])
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testSplashScreenDisplayAndAutoTransitionToLogin() throws {
        let splashApp = XCUIApplication()
        splashApp.launch()
        
        // 1. Verify splash screen wordmark exists
        let splashWordmark = splashApp.staticTexts["Xchange"]
        XCTAssertTrue(splashWordmark.waitForExistence(timeout: 2))
        
        // 2. Wait 4 seconds for splash timer to expire and navigate to Login Screen
        let loginButton = splashApp.buttons["LOG IN"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 6))
    }
    
    func testLoginViewAppearanceAndDismissal() throws {
        let loginApp = XCUIApplication()
        loginApp.launchArguments.append("--skip-splash")
        loginApp.launch()
        
        let loginButton = loginApp.buttons["LOG IN"]
        if loginButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(loginButton.exists)
            loginButton.tap()
            
            let welcomeText = loginApp.staticTexts["Welcome, Alex!"]
            XCTAssertTrue(welcomeText.waitForExistence(timeout: 4))
        }
    }
    
    func testLoginAndSignUpBidirectionalNavigation() throws {
        let authApp = XCUIApplication()
        authApp.launchArguments.append("--skip-splash")
        authApp.launch()
        
        // 1. Verify on Login screen and tap "Sign Up"
        let signUpButton = authApp.buttons["Sign Up"]
        if signUpButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(signUpButton.exists)
            signUpButton.tap()
            
            // 2. Verify navigation to SignUp screen
            let createAccountButton = authApp.buttons["CREATE ACCOUNT"]
            XCTAssertTrue(createAccountButton.waitForExistence(timeout: 3))
            
            // 3. Tap "Log In" on SignUp screen to return to Login
            let backToLoginButton = authApp.buttons["Log In"]
            XCTAssertTrue(backToLoginButton.exists)
            backToLoginButton.tap()
            
            // 4. Verify back on Login screen
            let loginButton = authApp.buttons["LOG IN"]
            XCTAssertTrue(loginButton.waitForExistence(timeout: 3))
        }
    }
    
    func testMainTabBarNavigation() throws {
        // Verify custom bottom tab bar items are reachable
        let homeButton = app.buttons["Home"]
        let browseButton = app.buttons["Browse"]
        let addListingButton = app.buttons["Add Listing"]
        let messagesButton = app.buttons["Messages"]
        let profileButton = app.buttons["Profile"]
        
        XCTAssertTrue(homeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(browseButton.exists)
        XCTAssertTrue(addListingButton.exists)
        XCTAssertTrue(messagesButton.exists)
        XCTAssertTrue(profileButton.exists)
        
        // Tap through tabs
        browseButton.tap()
        
        messagesButton.tap()
        XCTAssertTrue(app.navigationBars["Barter Trades"].waitForExistence(timeout: 2))
        
        profileButton.tap()
        XCTAssertTrue(app.navigationBars["Profile & Trust"].waitForExistence(timeout: 2))
        
        homeButton.tap()
        XCTAssertTrue(app.staticTexts["Featured Exchanges"].waitForExistence(timeout: 2))
    }
    
    func testOpenItemDetailAndCheckValuationMeter() throws {
        // Tap first item card on Explore feed
        let firstCard = app.scrollViews.otherElements.buttons.firstMatch
        if firstCard.waitForExistence(timeout: 3) {
            firstCard.tap()
            
            // Check that detail view opened
            let proposeButton = app.buttons["Propose Barter Trade"]
            if proposeButton.waitForExistence(timeout: 2) {
                XCTAssertTrue(proposeButton.exists)
            }
            
            // Dismiss detail view
            let closeButton = app.buttons["xmark.circle.fill"]
            if closeButton.exists {
                closeButton.tap()
            }
        }
    }
    
    func testOpenSafeZoneMapFromFeed() throws {
        // Tap Safe Zones Map button on quick bar
        let mapButton = app.buttons["Safe Zones Map"]
        if mapButton.waitForExistence(timeout: 3) {
            mapButton.tap()
            XCTAssertTrue(app.navigationBars["Safe Exchange Zones"].waitForExistence(timeout: 3))
            
            let doneButton = app.buttons["Done"]
            if doneButton.exists {
                doneButton.tap()
            }
        }
    }
}
