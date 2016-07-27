//
//  NSManagedObject+Skiathos.h
// 
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Skiathos)

- (instancetype)inContext:(NSManagedObjectContext *)otherContext;
+ (instancetype)createInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)numberOfEntitiesInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
- (void)deleteInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)allWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)allWhereAttribute:(NSString *)attribute
                                                  isEqualTo:(NSString *)value
                                                   sortedBy:(NSString *)sortTerm
                                                  ascending:(BOOL)ascending
                                                  inContext:(NSManagedObjectContext *)context;
+ (instancetype)firstInContext:(NSManagedObjectContext *)context;
+ (instancetype)firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value inContext:(NSManagedObjectContext *)context;
+ (instancetype)firstWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

@end