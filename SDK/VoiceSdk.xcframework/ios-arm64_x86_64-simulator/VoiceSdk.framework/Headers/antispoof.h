/* Copyright 2018 ID R&D Inc. All Rights Reserved. */

/*!
 @header antispoof.h
 @brief Voice anti-spoofing base header file.
 */

#import <Foundation/Foundation.h>

#import <VoiceSdk/antispoof_result.h>

__attribute__((visibility("default")))
/*!
 @deprecated Use LivenessEngine API instead.
 @interface AntispoofEngine
 @brief Class for antispoof engine.
 */
@interface AntispoofEngine : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
@deprecated Use LivenessEngine API instead.
@brief Creates AntispoofEngine instance.
@param path path to antispoof config file or directory containing default antispoof.json
@param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error;

/*!
@deprecated Use LivenessEngine API instead.
@brief Checks if given WAV file contains spoofed speech.
@param wavFile full path to the WAV file
@param error pointer to NSError for error reporting
@return Spoof check result.
*/
- (AntispoofResult* _Nullable)isSpoof:(NSString* _Nonnull)wavFile error:(NSError* _Nullable* _Nullable)error;

/*!
@deprecated Use LivenessEngine API instead.
@brief Checks if given PCM16 audio samples contain spoofed speech
@param PCM16Samples    audio samples in PCM16 format
@param sampleRate sampling rate of audio samples
@param error pointer to NSError for error reporting
@return Spoof check result.
 */
- (AntispoofResult* _Nullable)isSpoof:(NSData* _Nonnull)PCM16Samples
                           sampleRate:(int)sampleRate
                                error:(NSError* _Nullable* _Nullable)error;

@end
