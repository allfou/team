//
//  TeamUITests.m
//  TeamUITests
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TeamUITests : XCTestCase

@end

@implementation TeamUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMain {
    // Refresh Data
    [self testPullDownToRefreshMemberList];
    
    // Check member details
    [self testDisplayMemberDetails];
    
    // Test Settings View
    [self testDisplayAcknowledgementsInSettings];
}

- (void)testPullDownToRefreshMemberList {
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    
    // Pull down to refresh list
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *firstCell = [[app.cells elementBoundByIndex: 0] childrenMatchingType:XCUIElementTypeOther].element;
    XCUICoordinate *start = [firstCell coordinateWithNormalizedOffset:CGVectorMake(0.0, 0.0)];
    XCUICoordinate *finish = [firstCell coordinateWithNormalizedOffset:CGVectorMake(0.0, 6.0)];
    [start pressForDuration:0 thenDragToCoordinate:finish];
}

- (void)testDisplayMemberDetails {
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [[[app.cells elementBoundByIndex: 0] childrenMatchingType:XCUIElementTypeOther].element tap];
    [app.buttons[@"email active"] tap];
    [app.buttons[@"phone active"] tap];
    [app.buttons[@"skype active"] tap];
    [[[[app.navigationBars[@"MemberVC"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
}

- (void)testDisplayAcknowledgementsInSettings {
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tabBarsQuery = app.tabBars;
    [tabBarsQuery.buttons[@"Settings"] tap];
    [app.tables.staticTexts[@"Acknowledgements"] tap];
    [app.navigationBars[@"UITableView"].buttons[@"Settings"] tap];
    [tabBarsQuery.buttons[@"Team"] tap];
}

@end
