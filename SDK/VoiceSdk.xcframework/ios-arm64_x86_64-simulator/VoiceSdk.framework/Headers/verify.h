/* Copyright 2018 ID R&D Inc. All Rights Reserved. */

/*!
 @header verify.h
 @brief Voice verification base header file.
 */

#import <Foundation/Foundation.h>

#import <VoiceSdk/common.h>

__attribute__((visibility("default")))
/*!
 @interface VerifyResult
 @brief Represents voice verification result.
 */
@interface VerifyResult : NSObject

/*!
 @brief Raw verification score, intended to be used for evaluation and data-wise calibration.
 */
@property(assign, nonatomic) float score;

/*!
 @brief Voice matching probability from 0 to 1, should be used for making a biometrics authentication decision.
 */
@property(assign, nonatomic) float probability;

@end


__attribute__((visibility("default")))
/*!
 @interface VerifyStreamResult
 @brief Represents verify stream result.
 */
@interface VerifyStreamResult : NSObject

/*!
 @brief Verification result.
 */
@property(strong, nonatomic, nonnull) VerifyResult* verifyResult;

/*!
 @brief Audio interval, which verify result refers to.
 */
@property(strong, nonatomic, nonnull) AudioInterval* audioInterval;

@end

/**
 * @brief Enumeration representing short quality description
 */
typedef NS_ENUM(NSInteger, QualityShortDescription) {
    /**
     * @brief Too noisy audio.
     */
    TOO_NOISY = 0,

    /**
     * @brief Too long reverberation.
     * @deprecated Won't appear as reverberation is no more checked.
     */
    TOO_LONG_REVERBERATION = 1,

    /**
     * @brief Too small total speech length in the audio.
     */
    TOO_SMALL_SPEECH_TOTAL_LENGTH = 2,

    /**
     * @brief Audio successfully passed quality check and can be used for voice template creation.
     */
    OK = 3
};

__attribute__((visibility("default")))
/*!
 @interface QualityCheckThresholds
 @brief Represents custom quality checking thresholds
 */
@interface QualityCheckThresholds : NSObject

/*!
 @brief Minimum signal-to-noise ratio required to pass quality check in dB.
 */
@property(assign, nonatomic) float minimumSnrDb;

/*!
 @brief Minimum speech length required to pass quality check in milliseconds.
 */
@property(assign, nonatomic) float minimumSpeechLengthMs;

@end

__attribute__((visibility("default")))
/*!
 @interface QualityCheckResult
 @brief Represents audio quality check result.
 */
@interface QualityCheckResult : NSObject

/**
 * @brief Map with keys representing names of the metrics used in quality check and values representing threshold values
 * for each metric
 */
@property(strong, nonatomic, nonnull) NSDictionary* thresholdValues;

/**
 * @brief Map with keys representing names of the metrics used in quality check and values representing actually
 * obtained values for each metric
 */
@property(strong, nonatomic, nonnull) NSDictionary* obtainedValues;

/**
 * @brief Short description of the quality check results
 */
@property(assign, nonatomic) QualityShortDescription qualityShortDescription;

@end

__attribute__((visibility("default")))
/*!
 @interface VoiceTemplateFactory
 @brief Class for creating and merging voice templates.
 */
@interface VoiceTemplateFactory : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
 @brief Creates VoiceTemplateFactory instance.
 @param path path to the init data folder
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Creates template from the given PCM16 audio samples.
 @param PCM16Samples PCM16 audio data
 @param sampleRate audio sample rate
 @param error pointer to NSError for error reporting
 @note Audio sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Created voice template.
 */
- (VoiceTemplate* _Nullable)createVoiceTemplate:(NSData* _Nonnull)PCM16Samples
                                     sampleRate:(size_t)sampleRate
                                          error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Creates template from the given PCM16 audio samples.
 @param PCM16Samples PCM16 audio data
 @param sampleRate audio sample rate
 @param channelType audio signal channel type
 @param error pointer to NSError for error reporting
 @note Audio sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Created voice template.
 */
- (VoiceTemplate* _Nullable)createVoiceTemplate:(NSData* _Nonnull)PCM16Samples
                                     sampleRate:(size_t)sampleRate
                                    channelType:(ChannelType)channelType
                                          error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Creates template with contents of the given WAV file.
 @param wavPath path to WAV file
 @param error pointer to NSError for error reporting
 @note WAV sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Created voice template.
 */
- (VoiceTemplate* _Nullable)createVoiceTemplate:(NSString* _Nonnull)wavPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Creates template with contents of the given WAV file.
 @param wavPath path to WAV file
 @param channelType audio signal channel type
 @param error pointer to NSError for error reporting
 @note WAV sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Created voice template.
 */
- (VoiceTemplate* _Nullable)createVoiceTemplate:(NSString* _Nonnull)wavPath
                                    channelType:(ChannelType)channelType
                                          error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Merges multiple voice templates of a single speaker to a union voice template.
 @param templates array of a single speaker voice templates
 @param error pointer to NSError for error reporting
 @return A union voice template.
 @note All the templates should have the same init data ID as the factory instance.
 */
- (VoiceTemplate* _Nullable)mergeVoiceTemplates:(NSArray* _Nonnull)templates error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Returns ID of the init data, which was used to create the factory.
 @param error pointer to NSError for error reporting
 @return A string containing init data ID.
 */
- (NSString* _Nullable)getInitDataId:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Returns minimum supported input audio sampling frequency in Hz.
 @param error pointer to NSError for error reporting
 @return A minimum sampling rate in Hz.
 */
- (NSNumber* _Nullable)getMinimumAudioSampleRate:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks whether audio buffer is suitable to use as voice enrollment entry from the quality perspective.
 @param PCM16Samples PCM16 audio data
 @param sampleRate audio sample rate
 @param error pointer to NSError for error reporting
 @note Audio sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Quality check result.
 */
- (QualityCheckResult* _Nullable)checkQuality:(NSData* _Nonnull)PCM16Samples
                                   sampleRate:(size_t)sampleRate
                                        error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief  Checks whether WAV file is suitable to use as voice enrollment entry from the quality perspective.
 @param wavPath path to WAV file
 @param error pointer to NSError for error reporting
 @note WAV sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Quality check result.
 */
- (QualityCheckResult* _Nullable)checkQuality:(NSString* _Nonnull)wavPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks whether audio buffer is suitable to use as voice enrollment entry from the quality perspective.
 @param PCM16Samples PCM16 audio data
 @param sampleRate audio sample rate
 @param thresholds Optional quality checking thresholds. If specified will be used instead of default thresholds
 defined by VoiceTemplateFactory initialization data
 @param error pointer to NSError for error reporting
 @note Audio sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Quality check result.
 */
- (QualityCheckResult* _Nullable)checkQuality:(NSData* _Nonnull)PCM16Samples
                                   sampleRate:(size_t)sampleRate
                                   thresholds:(QualityCheckThresholds* _Nullable)thresholds
                                        error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief  Checks whether WAV file is suitable to use as voice enrollment entry from the quality perspective.
 @param wavPath path to WAV file
 @param thresholds Optional quality checking thresholds. If specified will be used instead of default thresholds
 defined by VoiceTemplateFactory initialization data
 @param error pointer to NSError for error reporting
 @note WAV sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @return Quality check result.
 */
- (QualityCheckResult* _Nullable)checkQuality:(NSString* _Nonnull)wavPath
                                   thresholds:(QualityCheckThresholds* _Nullable)thresholds
                                        error:(NSError* _Nullable* _Nullable)error;

@end


__attribute__((visibility("default")))
/*!
 @interface VoiceTemplateMatcher
 @brief Class for matching voice templates.
 */
@interface VoiceTemplateMatcher : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
 @brief Creates VoiceTemplateMatcher instance.
 @param path path to the init data folder
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Matches two voice templates one-to-one.
 @param template1 Voice template #1
 @param template2 Voice template #2
 @param error pointer to NSError for error reporting
 @return Voice verification result.
 @note Both templates should have the same init data ID as the matcher instance
 */
- (VerifyResult* _Nullable)matchVoiceTemplates:(VoiceTemplate* _Nonnull)template1
                                     template2:(VoiceTemplate* _Nonnull)template2
                                         error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Returns ID of the init data, which was used to create the matcher.
 @param error pointer to NSError for error reporting
 @return A string containing init data ID.
 */
- (NSString* _Nullable)getInitDataId:(NSError* _Nullable* _Nullable)error;

@end


__attribute__((visibility("default")))
/*!
 @interface VoiceVerifyStream
 @brief Class for continuous voice verification using audio stream.
 */
@interface VoiceVerifyStream : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
 @brief Voice verify stream constructor.
 @param voiceTemplateFactory Voice template factory instance
 @param voiceTemplateMatcher Voice template matcher instance
 @param voiceTemplate        Reference voice template to match with
 @param sampleRate           Input audio stream sampling frequency in Hz
 @param windowLengthSeconds Length of audio context for voice verification in seconds,
 should be greater than 3 seconds
 @param error pointer to NSError for error reporting
 @note Sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @note Voice template matcher, voice template factory and voice template should have the same init data ID.
 */
- (instancetype _Nullable)initWithVoiceTemplateFactory:(VoiceTemplateFactory* _Nonnull)voiceTemplateFactory
                                  voiceTemplateMatcher:(VoiceTemplateMatcher* _Nonnull)voiceTemplateMatcher
                                         voiceTemplate:(VoiceTemplate* _Nonnull)voiceTemplate
                                            sampleRate:(size_t)sampleRate
                                   windowLengthSeconds:(size_t)windowLengthSeconds
                                                 error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Voice verify stream constructor.
 @param voiceTemplateFactory Voice template factory instance
 @param voiceTemplateMatcher Voice template matcher instance
 @param voiceTemplate        Reference voice template to match with
 @param sampleRate           Input audio stream sampling frequency in Hz
 @param error pointer to NSError for error reporting
 @note Sampling frequency should be equal to or greater than the value returned by
       @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @note Voice template matcher, voice template factory and voice template should have the same init data ID.
 */
- (instancetype _Nullable)initWithVoiceTemplateFactory:(VoiceTemplateFactory* _Nonnull)voiceTemplateFactory
                                  voiceTemplateMatcher:(VoiceTemplateMatcher* _Nonnull)voiceTemplateMatcher
                                         voiceTemplate:(VoiceTemplate* _Nonnull)voiceTemplate
                                            sampleRate:(size_t)sampleRate
                                                 error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Adds PCM16 audio samples to process.
 @param PCM16Samples audio samples in PCM16 format
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 @note If error has happened stream state is being reset except the accumulated results buffer.
 */
- (BOOL)addSamples:(NSData* _Nonnull)PCM16Samples error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Retrieves verification result from output queue. Use hasVerifyResult() to know if there are available results.
 @param error pointer to NSError for error reporting
 @return One verification result.
 @note This method will produce an error if the output results queue is empty.
 */
- (VerifyStreamResult* _Nullable)getVerifyResult:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks if there are available verification results in output queue.
 @param error pointer to NSError for error reporting
 @return Boolean flag (true is there are results available, else otherwise).
 */
- (VoiceSdkBool* _Nullable)hasVerifyResults:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Method for resetting stream state.
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 */
- (BOOL)reset:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Finalizes input audio stream to process remaining audio
 samples and produce result if it's possible.
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 */
- (BOOL)finalizeStream:(NSError* _Nullable* _Nullable)error;

@end
