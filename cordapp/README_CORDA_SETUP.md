# Corda Setup Instructions

## Issue: R3 Artifactory Authentication Required

The Corda build requires access to R3's Artifactory repository, which requires authentication for Corda 4.12.

## Solutions

### Option 1: Get R3 Artifactory Credentials (Recommended)

1. **Sign up for Corda Open Source:**
   - Visit: https://www.corda.net/get-corda/
   - Sign up for Corda Open Source
   - You'll receive Artifactory credentials

2. **Add credentials to Gradle:**
   
   Create `~/.gradle/gradle.properties`:
   ```properties
   cordaArtifactoryUsername=your-username
   cordaArtifactoryPassword=your-password
   ```

   Then update `build.gradle` to use credentials:
   ```gradle
   maven { 
       url "https://software.r3.com/artifactory/corda"
       credentials {
           username = project.findProperty('cordaArtifactoryUsername') ?: System.getenv('CORDA_ARTIFACTORY_USERNAME')
           password = project.findProperty('cordaArtifactoryPassword') ?: System.getenv('CORDA_ARTIFACTORY_PASSWORD')
       }
   }
   ```

### Option 2: Use Corda Sample Project

If you have a Corda sample project (from R3 tutorials), you can:
1. Copy the `build.gradle` from the sample
2. Copy the `gradlew` wrapper files
3. Adapt it to this project

### Option 3: Use Docker with Pre-configured Corda

Use a Docker image that has Corda pre-configured:
```bash
docker pull corda/corda-zulu-java1.8-4.12
```

### Option 4: Simplified Build (For Testing)

For now, you can test the other components (Bank API, AI Engine, LEA Backend/Frontend) without building the Corda CorDapp. The system can work with mock Corda responses for testing.

## Next Steps

1. **Get Artifactory credentials** from R3 (Option 1)
2. **OR** use an existing Corda sample project (Option 2)
3. **OR** proceed with testing other components first (Option 4)

Once you have credentials or a working Corda setup, the build should work.

