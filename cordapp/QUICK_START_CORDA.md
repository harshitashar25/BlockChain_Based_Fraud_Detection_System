# Quick Start: Get Corda Working

## 🎯 Goal: Get R3 Artifactory Credentials

The fastest way to get Corda working:

### Method 1: Sign Up (5 minutes)

1. **Go to:** https://www.corda.net/get-corda/
2. **Fill out the form** (name, email, company)
3. **Check your email** for Artifactory credentials
4. **Add credentials:**

```bash
# Create/edit the file
nano ~/.gradle/gradle.properties

# Add these lines (replace with your actual credentials):
cordaArtifactoryUsername=your-username
cordaArtifactoryPassword=your-password
```

5. **Test it:**

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp
gradle wrapper --gradle-version 7.6
```

### Method 2: Use Existing Corda Project

If you have a Corda sample/template project:

```bash
# Find your Corda project
# Copy gradlew files
cp /path/to/corda-project/gradlew /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp/
cp /path/to/corda-project/gradlew.bat /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp/
cp -r /path/to/corda-project/gradle /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp/

# Then try building
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp
./gradlew clean build
```

### Method 3: Check if You Already Have Credentials

```bash
# Check if credentials exist
cat ~/.gradle/gradle.properties | grep -i corda

# Or check environment variables
echo $CORDA_ARTIFACTORY_USERNAME
echo $CORDA_ARTIFACTORY_PASSWORD
```

## ✅ Once You Have Credentials

Run these commands in order:

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp

# 1. Generate wrapper (if not already done)
gradle wrapper --gradle-version 7.6

# 2. Build the project
./gradlew clean build

# 3. Deploy nodes
./gradlew deployNodes

# 4. Start nodes (keep running!)
cd build/nodes
./runnodes.sh
```

## 🚀 After Nodes Start

In a **new terminal**, start the Bank API:

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/bank-api
./gradlew bootRun
```

Then test the full flow!

## 📝 Current Status

- ✅ **Frontend working** - Dashboard shows alerts
- ✅ **LEA Backend working** - WebSocket broadcasting
- ✅ **AI Engine working** - Risk scoring functional
- ⏳ **Corda needed** - Requires R3 credentials
- ⏳ **Bank API** - Waiting for Corda nodes

**Next:** Get R3 Artifactory credentials → Build Corda → Start nodes → Full system operational!

