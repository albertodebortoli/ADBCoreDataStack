//
//  NSManagedObject_SkiathosTests.m
// 
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Skiathos.h"
#import "User.h"

#define kUnitTestTimeout (10.0)

@interface NSManagedObject_SkiathosTests : XCTestCase

@property (nonatomic, strong) Skiathos *skiathos;

@end

@implementation NSManagedObject_SkiathosTests

- (void)setUp
{
    [super setUp];
    self.skiathos = [Skiathos inMemoryCoreDataStackWithDataModelFileName:@"DataModel"];
}

- (void)tearDown
{
    self.skiathos = nil;
    [super tearDown];
}

- (void)test_CreateObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 0);
    }];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        [User createInContext:context];
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DeleteObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block User *user = nil;
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        user = [User createInContext:context];
        user = [user inContext:context];
        [User createInContext:context];
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 2);
    }];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *userInContext = [user inContext:context];
        [userInContext deleteInContext:context];
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DeleteObjectInSameTransactionalBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = nil;
        User *user1 = [User createInContext:context];
        [User createInContext:context];
        users = [User allInContext:context];
        XCTAssertEqual(users.count, 2);
        
        [user1 deleteInContext:context];
        users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DeleteAllObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = nil;
        
        [User createInContext:context];
        [User createInContext:context];
        users = [User allInContext:context];
        XCTAssertEqual(users.count, 2);
        
        [User deleteAllInContext:context];
        users = [User allInContext:context];
        XCTAssertEqual(users.count, 0);
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_numberOfEntities
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        [User createInContext:context];
        [User createInContext:context];
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSUInteger numberOfEntitities = [User numberOfEntitiesInContext:context];
        XCTAssertEqual(numberOfEntitities, 2);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_numberOfEntitiesWithPredicate
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u2.firstname = @"Jane";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"firstname", @"John"];
        NSUInteger numberOfEntitities = [User numberOfEntitiesWithPredicate:predicate inContext:context];
        XCTAssertEqual(numberOfEntitities, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_all
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        [User createInContext:context];
        [User createInContext:context];
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 2);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_allWithPredicate
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u2.firstname = @"Jane";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"firstname", @"John"];
        NSArray *users = [User allWithPredicate:predicate inContext:context];
        XCTAssertEqual(users.count, 1);
        User *user = [users firstObject];
        XCTAssertEqual(user.firstname, @"John");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_allWithPredicateSortedBy
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"lastname", @"Doe"];
        NSArray *users = [User allWithPredicate:predicate sortedBy:@"firstname" ascending:YES inContext:context];
        XCTAssertEqual(users.count, 2);
        User *user = [users firstObject];
        XCTAssertEqual(user.firstname, @"Jane");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_allWhereAttributeIsEqualToSortedBy
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allWhereAttribute:@"lastname" isEqualTo:@"Doe" sortedBy:@"firstname" ascending:NO inContext:context];
        XCTAssertEqual(users.count, 2);
        User *user = [users firstObject];
        XCTAssertEqual(user.firstname, @"John");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_first
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u2.firstname = @"Jane";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        User *user = [User firstInContext:context];
        XCTAssertNotNil(user);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_firstWithPredicate
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"lastname", @"Doe"];
        User *user = [User firstWithPredicate:predicate sortedBy:@"firstname" ascending:YES inContext:context];
        XCTAssertEqual(user.firstname, @"Jane");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_firstWhereAttribute
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User createInContext:context];
        User *u2 = [User createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        User *user1 = [User firstWhereAttribute:@"lastname" isEqualTo:@"Doe" inContext:context];
        XCTAssertNotNil(user1);
    
        User *user2 = [User firstWhereAttribute:@"lastname" isEqualTo:@"Smith" inContext:context];
        XCTAssertNil(user2);
    
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

@end
