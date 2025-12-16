/* Copyright 2023 ID R&D Inc. All Rights Reserved. */

/*!
 @header quality_check.h
 @brief Quality check engine header file.
 */

#import <Foundation/Foundation.h>

/*!
 @brief Enumeration representing short quality check description
 */
typedef NS_ENUM(NSInteger, QualityCheckShortDescription) {
    /*!
     @brief Too noisy audio.
     */
    QUALITY_SHORT_DESCRIPTION_TOO_NOISY = 0,

    /*!
     @brief Too small speech length in the audio.
     */
    QUALITY_SHORT_DESCRIPTION_TOO_SMALL_SPEECH_TOTAL_LENGTH = 1,

    /*!
     @brief Audio successfully passed quality check.
     */
    QUALITY_SHORT_DESCRIPTION_OK = 2,

    /*!
     @brief Too small speech relative length (speech length relative to the total audio length).
     */
    QUALITY_SHORT_DESCRIPTION_TOO_SMALL_SPEECH_RELATIVE_LENGTH = 3,

    /*!
     @brief Multiple speakers detected.
     */
    QUALITY_SHORT_DESCRIPTION_MULTIPLE_SPEAKERS_DETECTED = 4
};

__attribute__((visibility("default")))
/*!
 @interface QualityCheckMetricsThresholds
 @brief Represents quality checking thresholds
 */
@interface QualityCheckMetricsThresholds : NSObject

/*!
 @brief Minimum signal-to-noise ratio required to pass quality check in dB.
 */
@property(assign, nonatomic) float minimumSnrDb;

/*!
 @brief Minimum speech length required to pass quality check in milliseconds.
 */
@property(assign, nonatomic) float minimumSpeechLengthMs;

/*!
 @brief Minimum speech relative length (speech length relative to the total audio length) required to pass quality check.
 */
@property(assign, nonatomic) float minimumSpeechRelativeLength;

/*!
 @brief Maximum multiple speakers detector score allowed to pass quality check.
 */
@property(assign, nonatomic) float maximumMultipleSpeakersDetectorScore;

@end

__attribute__((visibility("default")))
/*!
 @interface QualityCheckEngineResult
 @brief Represents audio quality check result.
 */
@interface QualityCheckEngineResult : NSObject

/*!
 @brief SNR metric value obtained on quality check in Db.
 */
@property(assign, nonatomic) float snrDb;

/*!
 @brief Speech length metric value obtained on quality check in milliseconds.
 */
@property(assign, nonatomic) float speechLengthMs;

/*!
 @brief Speech relative length (speech length relative to the total audio length) metric value obtained on quality check.
 */
@property(assign, nonatomic) float speechRelativeLength;

/*!
 @brief Multiple speakers detector score value obtained on quality check.
 */
@property(assign, nonatomic) float multipleSpeakersDetectorScore;

/*!
 @brief Short description of the quality check results
 */
@property(assign, nonatomic) QualityCheckShortDescription qualityCheckShortDescription;

@end

/*!
 @brief Enumeration representing scenarios used to get recommended quality check thresholds
 */
typedef NS_ENUM(NSInteger, QualityCheckScenario) {
    /*!
     @brief Verification, TI enrollment step.
     */
    QUALITY_CHECK_SCENARIO_VERIFY_TI_ENROLLMENT = 0,

    /*!
     @brief Verification, TI verification step.
     */
    QUALITY_CHECK_SCENARIO_VERIFY_TI_VERIFICATION = 1,

    /*!
     @brief Verification, TD enrollment step.
     */
    QUALITY_CHECK_SCENARIO_VERIFY_TD_ENROLLMENT = 2,

    /*!
     @brief Verification, TD verification step.
     */
    QUALITY_CHECK_SCENARIO_VERIFY_TD_VERIFICATION = 3,

    /*!
     @brief Liveness check.
     */
    QUALITY_CHECK_SCENARIO_LIVENESS = 4
};

__attribute__((visibility("default")))
/*!
 @interface QualityCheckEngine
 @brief Class for audio quality checking.
 */
@interface QualityCheckEngine : NSObject

/*!
 @brief Creates QualityCheckEngine instance.
 @param initPath initialization data path
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)initPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Gets recommended quality checking thresholds for the specified scenario.
 @param scenario scenario for which recommended thresholds will be returned
 @param error pointer to NSError for error reporting
 @return Quality check thresholds that can be used on quality checking.
 */
- (QualityCheckMetricsThresholds* _Nullable)getRecommendedThresholds:(QualityCheckScenario)scenario
                                                               error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks whether audio buffer is suitable from the quality perspective, from the given PCM16 audio samples.
 @param PCM16Samples PCM16 audio data
 @param sampleRate audio sample rate
 @param thresholds quality checking thresholds that will be applied to the output quality check metrics
 @param error pointer to NSError for error reporting
 @return Quality check result.
 */
- (QualityCheckEngineResult* _Nullable)checkQuality:(NSData* _Nonnull)PCM16Samples
                                   sampleRate:(size_t)sampleRate
                                   thresholds:(QualityCheckMetricsThresholds* _Nonnull)thresholds
                                        error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief  Checks whether WAV file is suitable from the quality perspective, from the given audio file.
 @param wavPath path to WAV file
 @param thresholds quality checking thresholds that will be applied to the output quality check metrics
 @param error pointer to NSError for error reporting
 @return Quality check result.
 */
- (QualityCheckEngineResult* _Nullable)checkQuality:(NSString* _Nonnull)wavPath
                                   thresholds:(QualityCheckMetricsThresholds* _Nonnull)thresholds
                                        error:(NSError* _Nullable* _Nullable)error;

@end