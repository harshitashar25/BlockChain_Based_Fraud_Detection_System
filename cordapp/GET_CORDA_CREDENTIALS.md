# How to Get Corda R3 Artifactory Credentials

## Step-by-Step Guide

### Step 1: Sign Up for Corda Open Source

1. **Visit R3's Website:**
   - Go to: https://www.corda.net/get-corda/
   - OR: https://www.r3.com/get-corda/
   - OR: https://corda.network/

2. **Sign Up Process:**
   - Click "Get Corda" or "Download" button
   - Fill out the registration form:
     - Name
     - Email address
     - Company/Organization
     - Use case/Interest
   - Accept terms and conditions
   - Submit the form

3. **Receive Credentials:**
   - You'll receive an email with:
     - Artifactory username
     - Artifactory password
     - Instructions for setup

### Step 2: Add Credentials to Gradle

Once you have your credentials, add them to your Gradle configuration:

**Option A: Global Configuration (Recommended)**

Create or edit `~/.gradle/gradle.properties`:

```bash
cd ~
nano .gradle/gradle.properties
# OR
open -e .gradle/gradle.properties
```

Add these lines:
```properties
cordaArtifactoryUsername=your-username-here
cordaArtifactoryPassword=your-password-here
```

**Option B: Project-Specific Configuration**

Create `cordapp/gradle.properties`:
```properties
cordaArtifactoryUsername=your-username-here
cordaArtifactoryPassword=your-password-here
```

**Option C: Environment Variables**

Add to your `~/.zshrc`:
```bash
export CORDA_ARTIFACTORY_USERNAME=your-username-here
export CORDA_ARTIFACTORY_PASSWORD=your-password-here
```

Then reload:
```bash
source ~/.zshrc
```

### Step 3: Verify Credentials Work

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp

# Test if credentials are loaded
gradle wrapper --gradle-version 7.6
```

If successful, you'll see the wrapper being generated without authentication errors.

## Alternative: Use Corda Template

If you can't get credentials immediately, you can use a Corda template project:

### Option 1: Clone Corda Template

```bash
cd /Users/harshita_shar25/Documents/corda

# Clone Kotlin template (recommended)
git clone https://github.com/corda/cordapp-template-kotlin.git corda-template

# Copy gradlew files
cp corda-template/gradlew FraudTraceSystem/cordapp/
cp corda-template/gradlew.bat FraudTraceSystem/cordapp/
cp -r corda-template/gradle FraudTraceSystem/cordapp/

# Copy build.gradle structure (adapt it)
# Then adapt the template's build.gradle to our project
```

### Option 2: Download Corda Distribution

1. Visit: https://www.corda.net/get-corda/
2. Download Corda Open Source distribution
3. Extract and use the included gradlew and configuration

## Quick Test Without Credentials

If you want to test the build structure without actually building:

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp

# Check if build.gradle syntax is correct
gradle tasks --dry-run 2>&1 | head -20
```

## Troubleshooting

### "401 Unauthorized" Error

- Verify credentials are correct
- Check if credentials are in the right file (`~/.gradle/gradle.properties`)
- Ensure no extra spaces in username/password
- Try using environment variables instead

### "Could not resolve plugin"

- Make sure R3 Artifactory URL is correct
- Verify credentials are being read
- Check network connectivity

### Still Having Issues?

1. Check R3's documentation: https://docs.corda.net/
2. Join Corda Community: https://discord.gg/corda
3. Check if you need to accept terms on R3's website first

## Next Steps After Getting Credentials

1. ✅ Add credentials to `~/.gradle/gradle.properties`
2. ✅ Generate Gradle wrapper: `gradle wrapper --gradle-version 7.6`
3. ✅ Build CorDapp: `./gradlew clean build`
4. ✅ Deploy nodes: `./gradlew deployNodes`
5. ✅ Start nodes: `cd build/nodes && ./runnodes.sh`

