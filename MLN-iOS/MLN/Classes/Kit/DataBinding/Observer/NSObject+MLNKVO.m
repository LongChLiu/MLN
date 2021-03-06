//
//  NSObject+MLNKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import "NSObject+MLNKVO.h"
#import "KVOController.h"
#import "MLNKVOObserver.h"
#import "MLNExtScope.h"

@import ObjectiveC;

@implementation NSObject (MLNKVO)

- (NSString * _Nonnull (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_resueIdBlock {
    return objc_getAssociatedObject(self, @selector(mln_resueIdBlock));
}

- (void)setMln_resueIdBlock:(NSString * _Nonnull (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_resueIdBlock {
    objc_setAssociatedObject(self, @selector(mln_resueIdBlock), mln_resueIdBlock, OBJC_ASSOCIATION_COPY);
}

- (NSUInteger (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_heightBlock {
    return objc_getAssociatedObject(self, @selector(mln_heightBlock));
}

- (void)setMln_heightBlock:(NSUInteger (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_heightBlock {
    objc_setAssociatedObject(self, @selector(mln_heightBlock), mln_heightBlock, OBJC_ASSOCIATION_COPY);
}

- (CGSize (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_sizeBlock {
    return objc_getAssociatedObject(self, @selector(mln_sizeBlock));
}

- (void)setMln_sizeBlock:(CGSize (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_sizeBlock {
    objc_setAssociatedObject(self, @selector(mln_sizeBlock), mln_sizeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSObject * _Nonnull (^)(NSString * _Nonnull, MLNKVOBlock _Nonnull))mln_subscribe {
    @weakify(self);
    return ^(NSString *keyPath, MLNKVOBlock block){
        @strongify(self);
        if (self && block) {
//            [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//                id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//                id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//                block(oldValue, newValue);
//            }];
            
            MLNKVOObserver *ob = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
                id newValue = [change objectForKey:NSKeyValueChangeNewKey];
                block(oldValue, newValue);
            } keyPath:keyPath];
            
            [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                [ob mln_observeValueForKeyPath:keyPath ofObject:object change:change];
            }];

        }
        return self;
    };
}

@end

@implementation NSObject (MLNReflect)

+ (void)mln_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = self;
    BOOL stop = NO;

    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    if (properties == NULL) return;
    
    @onExit {
        free(properties);
    };

    for (unsigned i = 0; i < count; i++) {
        block(properties[i], &stop);
        if (stop) break;
    }
}

+ (NSArray <NSString *> *)mln_propertyKeys {
    return [self mln_propertyKeysWithBlock:nil];
}

+ (NSArray <NSString *> *)mln_propertyKeysWithBlock:(void(^)(NSString *key))block {
    NSArray *cachedKeys = objc_getAssociatedObject(self, @selector(mln_propertyKeys));
    if (cachedKeys != nil) {
        if (block) {
            [cachedKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                block(obj);
            }];
        }
        return cachedKeys;
    }
    
    NSMutableArray *keys = [NSMutableArray array];
    [self mln_enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        NSString *key = @(property_getName(property));
        [keys addObject:key];
        if (block) {
            block(key);
        }
    }];

    objc_setAssociatedObject(self, @selector(mln_propertyKeys), keys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return keys;
}

- (NSDictionary *)mln_toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self.class mln_propertyKeysWithBlock:^(NSString *key) {
        [dic setValue:[self valueForKey:key] forKey:key];
    }];
    return dic.copy;
}

@end
