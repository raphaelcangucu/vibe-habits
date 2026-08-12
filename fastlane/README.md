fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run the unit test suite required by releases

### ios ui_tests

```sh
[bundle exec] fastlane ios ui_tests
```

Run the UI test suite separately

### ios bootstrap_signing

```sh
[bundle exec] fastlane ios bootstrap_signing
```

Create the initial App Store certificate and provisioning profile

### ios store_listing

```sh
[bundle exec] fastlane ios store_listing
```

Upload the reviewed App Store listing and screenshots without a binary

### ios release

```sh
[bundle exec] fastlane ios release
```

Test, archive, sign, and upload a tagged build to App Store Connect/TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
