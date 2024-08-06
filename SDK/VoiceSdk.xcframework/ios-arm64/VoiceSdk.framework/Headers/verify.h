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
 @param voiceTemplateFactory      Voice template factory instance
 @param voiceTemplateMatcher      Voice template matcher instance
 @param voiceTemplates            Reference voice templates to match with
 @param sampleRate                Input audio stream sampling frequency in Hz
 @param audioContextLengthSeconds Length of audio context for voice verification in seconds,
                                  must be at least windowLengthSeconds
 @param windowLengthSeconds       Length of audio window passed to the template creation during
                                  stream processing, must be at least 0.5 seconds
 @param error pointer to NSError for error reporting
 @note Sampling frequency should be equal to or greater than the value returned by
 @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @note Voice template matcher, voice template factory and voice template should have the same init data ID.
 */
- (instancetype _Nullable)initWithVoiceTemplateFactory:(VoiceTemplateFactory* _Nonnull)voiceTemplateFactory
                                  voiceTemplateMatcher:(VoiceTemplateMatcher* _Nonnull)voiceTemplateMatcher
                                         voiceTemplates:(NSArray* _Nonnull)voiceTemplates
                                            sampleRate:(size_t)sampleRate
                             audioContextLengthSeconds:(size_t)audioContextLengthSeconds
                                   windowLengthSeconds:(float)windowLengthSeconds
                                                 error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Voice verify stream constructor.
 @param voiceTemplateFactory      Voice template factory instance
 @param voiceTemplateMatcher      Voice template matcher instance
 @param voiceTemplates            Reference voice templates to match with
 @param sampleRate                Input audio stream sampling frequency in Hz
 @param audioContextLengthSeconds Length of audio context for voice verification in seconds,
                                  must be at least 3 seconds
 @param error pointer to NSError for error reporting
 @note Sampling frequency should be equal to or greater than the value returned by
 @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @note Voice template matcher, voice template factory and voice template should have the same init data ID.
 */
- (instancetype _Nullable)initWithVoiceTemplateFactory:(VoiceTemplateFactory* _Nonnull)voiceTemplateFactory
                                  voiceTemplateMatcher:(VoiceTemplateMatcher* _Nonnull)voiceTemplateMatcher
                                         voiceTemplates:(NSArray* _Nonnull)voiceTemplates
                                            sampleRate:(size_t)sampleRate
                             audioContextLengthSeconds:(size_t)audioContextLengthSeconds
                                                 error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Voice verify stream constructor.
 @param voiceTemplateFactory Voice template factory instance
 @param voiceTemplateMatcher Voice template matcher instance
 @param voiceTemplates       Reference voice templates to match with
 @param sampleRate           Input audio stream sampling frequency in Hz
 @param error pointer to NSError for error reporting
 @note Sampling frequency should be equal to or greater than the value returned by
 @ref VoiceTemplateFactory::getMinimumAudioSampleRate.
 @note Voice template matcher, voice template factory and voice template should have the same init data ID.
 */
- (instancetype _Nullable)initWithVoiceTemplateFactory:(VoiceTemplateFactory* _Nonnull)voiceTemplateFactory
                                  voiceTemplateMatcher:(VoiceTemplateMatcher* _Nonnull)voiceTemplateMatcher
                                        voiceTemplates:(NSArray* _Nonnull)voiceTemplates
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
 @brief Retrieves verification result from output queue containing one
        verify stream result for each reference template.
        Use hasVerifyResult() to know if there are available results
 @param error pointer to NSError for error reporting
 @return One verification result.
 @note This method will produce an error if the output results queue is empty.
 */
- (NSArray* _Nullable)getVerifyResult:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Retrieves verification result from output queue consisting of single verify
        stream result corresponding to the zeroth reference template.
        Suitable for the case when the only one reference template was specified.
        Use hasVerifyResult() to know if there are available results
 @param error pointer to NSError for error reporting
 @return One verification result for the zeroth reference template.
 @note This method will produce an error if the output results queue is empty.
       Behaves the same as getVerifyResult in IDVoice < 3.13, if only one reference template was set
 */
- (VerifyStreamResult* _Nullable)getVerifyResultForOneTemplate:(NSError* _Nullable* _Nullable)error;

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
