/* Copyright 2023 ID R&D Inc. All Rights Reserved. */

/*!
 @header liveness.h
 @brief Voice liveness check base header file.
 */

#import <Foundation/Foundation.h>

#import <VoiceSdk/common.h>

/**
 * @brief Status code of validation preceding liveness check
 */
typedef NS_ENUM(NSInteger, LivenessResultValidationStatusCode) {
    /**
     * @brief Successful validation.
     */
    LIVENESS_RESULT_VALIDATION_STATUS_CODE_OK = 0,

    /**
     * @brief Speech length is too small for liveness check to be performed.
     */
    LIVENESS_RESULT_VALIDATION_STATUS_CODE_TOO_SMALL_SPEECH_LENGTH = 1
};

__attribute__((visibility("default")))
/*!
 @interface LivenessResultValue

 @brief The LivenessResultValue interface.
 An interface for a value of liveness check result.
 */
@interface LivenessResultValue : NSObject

/*!
 @brief Liveness raw score.
 */
@property(nonatomic, assign) float score;

/*!
 @brief Liveness probability from 0 to 1.
 */
@property(nonatomic, assign) float probability;

- (NSString* _Nonnull)description;

@end

__attribute__((visibility("default")))
/*!
 @interface LivenessResult

 @brief The LivenessResult interface.
 An interface for a liveness check result.
 */
@interface LivenessResult : NSObject

/*!
 @brief Returns flag indicating whether validation was successful and liveness result value is available
 @return true if validation was successful and value is available, otherwise false
 */
- (VoiceSdkBool* _Nullable)ok;

/*!
 @brief Gets validation result value. Available only if validation preceding liveness check was successful, @see ok.
 @param error pointer to NSError for error reporting if instance does not contain result value
 @return Liveness check result value
 */
- (LivenessResultValue* _Nullable)getValue:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Gets validation status code
 @return Validation status code.
 */
- (LivenessResultValidationStatusCode)getStatusCode;

- (NSString* _Nonnull)description;

@end

__attribute__((visibility("default")))
/*!
 @interface LivenessEngine
 @brief Liveness check engine class.
 */
@interface LivenessEngine : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
@brief Creates LivenessEngine instance.
@param path initialization data path
@param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error;

/*!
@brief Checks liveness from the given WAV file.
@param wavFile path to the WAV file
@param error pointer to NSError for error reporting
@return Liveness check result.
*/
- (LivenessResult* _Nullable)checkLiveness:(NSString* _Nonnull)wavFile error:(NSError* _Nullable* _Nullable)error;

/*!
@brief Checks liveness from the given PCM16 audio samples.
@param PCM16Samples audio samples in PCM16 format
@param sampleRate sampling rate of audio samples in Hz
@param error pointer to NSError for error reporting
@return Liveness check result.
 */
- (LivenessResult* _Nullable)checkLiveness:(NSData* _Nonnull)PCM16Samples
                                sampleRate:(size_t)sampleRate
                                     error:(NSError* _Nullable* _Nullable)error;

@end
