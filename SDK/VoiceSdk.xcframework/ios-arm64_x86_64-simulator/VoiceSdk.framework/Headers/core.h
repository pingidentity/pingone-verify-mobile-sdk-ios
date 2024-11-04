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
 @deprecated Use @Settings::getLicenseInfo instead.
 */
@property(strong, nonatomic, nonnull) NSString* licenseInfo;

/*!
 @brief License expiration date in YYYY-MM-DD format. The returned date corresponds to the SDK feature that expires first.
 @deprecated Use @Settings::getLicenseInfo instead.
 */
@property(strong, nonatomic, nonnull) NSString* licenseExpirationDate;

- (NSString* _Nonnull)description;

@end

/**
 * @brief VoiceSDK licensed features
 */
typedef NS_ENUM(NSInteger, LicenseFeature) {
    /**
     * @brief Core functionality.
     */
    CORE = 7,

    /**
     * @brief Voice verification.
     */
    VERIFICATION = 2,

    /**
     * @brief Voice liveness (presentation/replay attack detection).
     */
    LIVENESS_PRESENTATION_ATTACK_DETECTION = 4,

    /**
     * @brief Voice liveness (voice clones detection).
     */
    LIVENESS_VOICE_CLONES_DETECTION = 31,

    /**
     * @brief Quality checking functionality (SNR, speech length etc.).
     */
    QUALITY_CHECKING = 6
};

__attribute__((visibility("default")))
/*!
 @interface LicenseFeatureInfo

 @brief The LicenseFeatureInfo interface.
 An interface for VoiceSDK feature information.
 */
@interface LicenseFeatureInfo : NSObject

/*!
 @brief License feature
 */
@property(assign, nonatomic) LicenseFeature feature;

/*!
 @brief Feature expiration date in YYYY-MM-DD format
 */
@property(strong, nonatomic, nonnull) NSString* expirationDate;

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

/*!
 * @brief Returns information (enabled features and expiration dates) about the installed license if available.
 *
 * @return Array of VoiceSDK features available with the installed license.
 */
+ (NSArray* _Nullable)getLicenseInfo:(NSError* _Nullable* _Nullable)error;

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
