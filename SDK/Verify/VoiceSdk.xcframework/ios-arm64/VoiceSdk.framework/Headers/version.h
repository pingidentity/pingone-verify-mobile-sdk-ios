#pragma once

#include <iostream>
#include <string>

#include <voicesdk/core/config.h>

#define VOICESDK_PROJECT_VERSION "4.0.2"
#define VOICESDK_COMPONENTS      "core media verify liveness"
#define VOICESDK_GIT_INFO        "HEAD d6ca091e "

namespace voicesdk {

    /**
     * @brief Structure containing present VoiceSDK build info.
     */
    struct BuildInfo {
        /**
         * @brief VoiceSDK build version.
         */
        std::string version = VOICESDK_PROJECT_VERSION;

        /**
         * @brief VoiceSDK components present in build.
         */
        std::string components = VOICESDK_COMPONENTS;

        /**
         * @brief Git info dumped at the build stage.
         */
        std::string gitInfo = VOICESDK_GIT_INFO;

        /**
         * @brief Information (e.g. expiration date) about the installed license if available or
         * an empty string if no license is in use.
         * @deprecated Use @getLicenseInfo instead.
         */
        std::string licenseInfo;

        /*
         * @brief License expiration date in YYYY-MM-DD format. The returned date corresponds to
         * the SDK feature that expires first.
         * @deprecated Use @getLicenseInfo instead.
         */
        std::string licenseExpirationDate;

        friend std::ostream &operator<<(std::ostream& os, const BuildInfo& obj) {
            os << "BuildInfo["
               << "version: \""               << obj.version               << "\", "
               << "components: \""            << obj.components            << "\", "
               << "gitInfo: \""               << obj.gitInfo               << "\", "
               << "licenseInfo: \""           << obj.licenseInfo           << "\", "
               << "licenseExpirationDate: \"" << obj.licenseExpirationDate << "\"]";
            return os;
        }
    };

    /**
     * @brief Returns present VoiceSDK build info.
     * @return Present VoiceSDK present build info.
     */
    VOICE_SDK_API BuildInfo getBuildInfo() noexcept;
}
