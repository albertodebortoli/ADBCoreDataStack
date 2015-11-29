//
//  ADBDALService.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBDALService.h"
#import <CoreData/CoreData.h>
#import <JustPromises/JustPromises.h>

@interface ADBDALService ()

@property (nonatomic, strong) id<ADBPersistenceProtocol> persistenceController;
@property (nonatomic, strong) NSManagedObjectContext *slave;

@end

@implementation ADBDALService

- (instancetype)initWithPersistenceController:(id<ADBPersistenceProtocol>)persistenceController
{
    NSParameterAssert(persistenceController);
    
    self = [super init];
    if (self)
    {
        _persistenceController = persistenceController;
        _slave = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_slave setParentContext:[_persistenceController managedObjectContext]];
    }
    return self;
}

#pragma mark - ADBDataAccessLayerProtocol

/**
 *  1. always use the main context
 *  2. call either performBlockAndWait: or performBlock: (the block will always be executed on the main theard/queue)
 *  3. execute the fetch request
 *  4. return the results if no error occurred
 */
- (JEFuture *)executeFetchRequest:(NSFetchRequest *)fetchRequest
{
    JEPromise *promise = [[JEPromise alloc] init];
    
    NSManagedObjectContext *main = [self.persistenceController managedObjectContext];
    
    [main performBlock:^{
        NSError *error;
        NSArray *results = [main executeFetchRequest:fetchRequest error:&error];
        
        if (error)
        {
            [promise setError:error];
        }
        else
        {
            [promise setResult:results];
        }
    }];
    
    return [promise future];
}

- (JEFuture *)countForFetchRequest:(NSFetchRequest *)request
{
    JEPromise *promise = [[JEPromise alloc] init];
    
    NSManagedObjectContext *main = [self.persistenceController managedObjectContext];
    
    [main performBlock:^{
        NSError *error;
        NSUInteger result = [main countForFetchRequest:request error:&error];
        
        if (error)
        {
            [promise setError:error];
        }
        else
        {
            [promise setResult:@(result)];
        }
    }];
    
    return [promise future];
}

/**
 *  1. use the slave context with a private queue concurrency type, with the main context as parent
 *  2. perform an async block (performBlockAndWait is reentrant) on the created context (it's on a bkg queue but will reuse the main queue if called from the main thread)
 *  3. in the block, execute the actions (changes parameter)
 *  4. save slave context
 *  5. if no saving errors save all the way down to the persistent store via the persistence controller
 *  6. the future is fulfilled after the save is applied to the persistent store.
 */
- (JEFuture *)writeBlock:(void(^)(NSManagedObjectContext *))changes
{
    NSParameterAssert(changes);
    
    JEPromise *promise = [[JEPromise alloc] init];
    
    [self.slave performBlock:^{
        
        changes(self.slave);
        
        NSError *error;
        [_slave save:&error];
        if (!error)
        {
            [self.persistenceController save:^(NSError *err) {
                if (err)
                {
                    [promise setError:error];
                }
                else
                {
                    [promise setResult:@YES];
                }
            }];
        }
        else
        {
            [promise setError:error];
        }
    }];
    
    return [promise future];
}

@end
