/* Copyright 2019 ID R&D Inc. All Rights Reserved. */

/*!
 @header core.h
 @brief VoiceSDK core header file.
 */

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
/*!
 @interface BuildInfo
 @brief Class present VoiceSDK build info.
 To obtain an instance filled with data use the default constuctor.
 */
@interface BuildInfo : NSObject

/*!
 @brief VoiceSDK build version.
 */
@property(strong, nonatomic, nonnull) NSString* version;

/*!
 @brief VoiceSDK components presented in build.
 */
@property(strong, nonatomic, nonnull) NSString* components;

/*!
 @brief Git info dump at the build stage.
 */
@property(strong, nonatomic, nonnull) NSString* gitInfo;

/*!
 @brief Information (e.g. expiration date) about the installed license if available or
 an empty string if no license is in use.
 */
@property(strong, nonatomic, nonnull) NSString* licenseInfo;

- (NSString* _Nonnull)description;

@end

__attribute__((visibility("default")))
/*!
 @interface Settings
 @brief VoiceSDK settings.
 */
@interface Settings : NSObject

/*!
 * @brief Sets the maximum number of threads available for VoiceSDK.
 * If 0 passed, then the optimal number of threads is detected automatically
 * (the same effect is achieved if setNumThreads is not called).
 *
 * @param numThreads maximum number of threads available for VoiceSDK.
 */
+ (void)setNumThreads:(unsigned int)numThreads;

/*!
 * @brief Sets whether to compress voice templates serialization.
 * Voice template compression is not used by default.
 *
 * @param useVoiceTemplateCompression whether to compress voice templates serialization.
 */
+ (void)setUseVoiceTemplateCompression:(bool)useVoiceTemplateCompression;

@end

__attribute__((visibility("default")))
/*!
 @interface MobileLicense
 @brief VoiceSDK license.
 */
@interface MobileLicense : NSObject

/*!
 * @brief Sets the license.
 *
 * @param license (NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error
 */
+ (BOOL)setLicense:(NSString* _Nonnull)license error:(NSError* _Nullable* _Nullable)error;

@end
