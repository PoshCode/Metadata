[![Build Status](https://dev.azure.com/poshcode/Configuration/_apis/build/status/Configuration?branchName=master)](https://dev.azure.com/poshcode/Configuration/_build/latest?definitionId=2&branchName=master)

# The Metadata Module

Long the core of my Configuration module, the Metadata module is now shipping on it's own.

## Metadata commands for working with PowerShell's metadata manifest content (.psd1 files):

- Manipulating metadata files
- Extensible serialization of types
- Built in support for DateTime, Version, Guid, SecureString, ScriptBlocks and more
- Lets you store almost anything in readable metadata (.psd1) files
- Serializing (`Export`) to metadata (.psd1) files
- Deserializing (`Import`) from metadata (.psd1) files

It supports WindowsPowerShell, as well as PowerShell Core on Windows, Linux and OS X.

## Installation

```posh
Install-Module Metadata
```

## Usage: Serialization

The main serialization commands (with the `Metadata` noun) are: ConvertFrom, ConvertTo, Import and Export. By default, the serializer can handle a variety of custom PSObjects, hashtables, and arrays recursively, and has specific handling for booleans, strings and numbers, as well as Versions, GUIDs, and DateTime, DateTimeOffset, and even ScriptBlocks and PSCredential objects.

**Important note:** PSCredentials are stored using ConvertTo-SecureString, and currently only work on Windows. They should be stored in the user scope, since they're serialized per-user, per-machine, using the Windows Data Protection API.

In other words, it handles everything you're likely to need in a configuration file. However, it also has support for adding additional type serializers via the `Add-MetadataConverter` command. If you want to store anything that doesn't work, please raise an issue :wink:.

In addition, there are `Get-Metadata` and `Update-Metadata` commands that read individual values from metadata files.

Finally, there is a `Update-Object` command that can update an object or hashtable with values from a second object or hashtable.