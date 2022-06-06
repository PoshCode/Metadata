Feature: Serialize Hashtables or Custom Objects
    To allow users to configure module preferences without editing their profiles
    A PowerShell Module Author
    Needs to serialize a preferences object in a user-editable format we call metadata

    Background:
        Given the metadata module is imported

    @Serialization
    Scenario: Serialize a hashtable to string
        Given a hashtable
            """
            @{ UserName = "Joel"; BackgroundColor = "Black"}
            """
        When we convert the object to metadata
        Then the string version should be
            """
            @{
              UserName = 'Joel'
              BackgroundColor = 'Black'
            }
            """
    @Serialization
    Scenario: Serialize nested hashtables to string
        Given a hashtable
            """
            @{ UserName = "Joel"; Permission = [ordered]@{ Role = "Administrator"; Since = (Get-Date 2000/1/1)}}
            """
        When we convert the object to metadata
        Then the string version should be
            """
            @{
              UserName = 'Joel'
              Permission = @{
                Role = 'Administrator'
                Since = (DateTime '2000-01-01T00:00:00.0000000')
              }
            }
            """
    @Serialization @ConsoleColor
    Scenario: Serialize a ConsoleColor to string
        Given a hashtable
            """
            @{ UserName = "Joel"; BackgroundColor = [ConsoleColor]::Black }
            """
        When we convert the object to metadata
        Then the string version should be
            """
            @{
              UserName = 'Joel'
              BackgroundColor = (ConsoleColor Black)
            }
            """

    @Serialization
    Scenario: Should be able to serialize core types:
        Given a hashtable with a String in it
        When we convert the object to metadata
        Then the string version should match 'TestCase = ([''"])[^\1]+\1'

        Given a hashtable with a Boolean in it
        When we convert the object to metadata
        Then the string version should match 'TestCase = \`$(True|False)'

        Given a hashtable with a NULL in it
        When we convert the object to metadata
        Then the string version should match 'TestCase = ""'

        Given a hashtable with a Number in it
        When we convert the object to metadata
        Then the string version should match 'TestCase = \d+'

    @Deserialization
    Scenario: Should be able to deserialize core types:
        Given a hashtable with a String in it
        When we round-trip the object through metadata
        Then the object's TestCase should be of type String

        Given a hashtable with a Number in it
        When we round-trip the object through metadata
        Then the object's TestCase should be of type Int32

        Given a hashtable with a Boolean in it
        When we round-trip the object through metadata
        Then the object's TestCase should be of type Boolean
        Then the object's TestCase should be $True

    @Serialization
    Scenario: Should be able to serialize an array
        Given a hashtable with an Array in it
        When we convert the object to metadata
        Then the string version should match 'TestCase = ([^,]*,)+[^,]*'

    @Deserialization
    Scenario: Should be able to deserialize an array:
        Given a hashtable with an Array in it
        When we round-trip the object through metadata
        Then the object's TestCase should be an array
        Then the object's TestCase should be of type string

    @Serialization
    Scenario: Should be able to serialize nested hashtables
        Given a hashtable with a hashtable in it
        When we convert the object to metadata
        Then the string version should match 'TestCase = @{'


    @Serialization @SecureString @PSCredential @CRYPT32
    Scenario Outline: Should be able to serialize PSCredential
        Given a hashtable with a PSCredential in it
        When we convert the object to metadata
        Then the string version should match "TestCase = \(?PSCredential"

    @Serialization @SecureString @CRYPT32
    Scenario Outline: Should be able to serialize SecureStrings
        Given a hashtable with a SecureString in it
        When we convert the object to metadata
        Then the string version should match "TestCase = \(?ConvertTo-SecureString [a-z0-9]+"


    @Serialization @CRYPT32
    Scenario Outline: Should support a few additional types
        Given a hashtable with a <type> in it
        When we convert the object to metadata
        Then the string version should match "TestCase = \(?<type> "

        Examples:
            | type           |
            | DateTime       |
            | DateTimeOffset |
            | GUID           |
            | PSObject       |
            | PSCredential   |
            | ConsoleColor   |

    @Serialization
    Scenario: PSCustomObject preserves PSTypeNames
        Given a settings object
            """
            @{
                PSTypeName = 'Whatever.User'
                FirstName = 'Joel'
                LastName = 'Bennett'
                UserName = 'Jaykul'
                Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        When we export to a metadata file named Configuration.psd1
        And we import the file to an object
        Then the output object should have Whatever.User in the PSTypeNames

    @Serialization @Enum
    Scenario: Unsupported types should be serialized as strings
        Given a hashtable with an Enum in it
        Then we expect a warning in the Metadata module
        When we convert the object to metadata
        And the warning is logged

    @Serialization @Error @Converter
    Scenario: Invalid converters should write non-terminating errors
        Given we expect an error in the Metadata module
        When we add a converter that's not a scriptblock
        And we add a converter with a number as a key
        Then the error is logged exactly 2 times

    @Serialization @Uri @Converter
    Scenario: Developers should be able to add support for other types
        Given a hashtable with a Uri in it
        When we add a converter for Uri types
        And we convert the object to metadata
        Then the string version should match "TestCase = \(?Uri '.*'"


    @Serialization @File
    Scenario: Developers should be able to export straight to file
        Given a hashtable
            """
            @{
              UserName = 'Joel'
              Age = 42
            }
            """
        When we export to a metadata file named Configuration.psd1
        Then the metadata file should contain
            """
            @{
              UserName = 'Joel'
              Age = 42
            }
            """

    @Deserialization @Uri @Converter
    Scenario: I should be able to import serialized data
        Given a hashtable
            """
            @{
              UserName = 'Joel'
              Age = 42
              LastUpdated = (Get-Date).Date
              Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        Then the object's Homepage should be of type Uri
        And we add a converter for Uri types
        And we convert the object to metadata
        When we convert the metadata to an object
        Then the output object should be of type hashtable
        Then the object's UserName should be of type String
        Then the object's Age should be of type Int32
        Then the object's LastUpdated should be of type DateTime
        Then the object's Homepage should be of type Uri

    @DeSerialization @SecureString @PSCredential @CRYPT32
    Scenario Outline: I should be able to import serialized credentials and secure strings
        Given a hashtable
            """
            @{
              Credential = [PSCredential]::new("UserName",(ConvertTo-SecureString Password -AsPlainText -Force))
              Password = ConvertTo-SecureString Password -AsPlainText -Force
            }
            """
        When we convert the object to metadata
        Then the string version should match "Credential = \(?PSCredential"
        And the string version should match "Password = \(?ConvertTo-SecureString [\"a-z0-9]*"
        When we convert the metadata to an object
        Then the output object should be of type hashtable
        Then the object's Credential should be of type PSCredential
        Then the object's Password should be of type SecureString

    @Serialization @SecureString @CRYPT32
    Scenario Outline: Should be able to serialize SecureStrings
        Given a hashtable with a SecureString in it
        When we convert the object to metadata
        Then the string version should match "TestCase = \(?ConvertTo-SecureString [a-z0-9]+"

    @Deserialization @Uri @Converter
    Scenario: I should be able to import serialized data even in PowerShell 2
        Given a hashtable
            """
            @{
              UserName = New-Object PSObject -Property @{ FirstName = 'Joel'; LastName = 'Bennett' }
              Age = [Version]4.2
              LastUpdated = [DateTimeOffset](Get-Date).Date
              GUID = [GUID]::NewGuid()
              Color = [ConsoleColor]::Red
            }
            """
        And we fake version 2.0 in the Metadata module
        And we add a converter for Uri types
        And we convert the object to metadata
        When we convert the metadata to an object
        Then the output object should be of type hashtable
        And the object's UserName should be of type PSObject
        And the object's Age should be of type String
        And the object's LastUpdated should be of type DateTimeOffset
        And the object's GUID should be of type GUID
        And the object's Color should be of type ConsoleColor

    @Deserialization @Uri @Converter
    Scenario: I should be able to add converters at import time
        Given the metadata module is imported with a URL converter
        And a hashtable
            """
            @{
              UserName = 'Joel'
              Age = 42
              Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        Then the object's Homepage should be of type Uri
        And we convert the object to metadata
        Then the string version should match
            """
              Homepage = \(?Uri 'http://HuddledMasses.org/'
            """
        When we convert the metadata to an object
        Then the output object should be of type hashtable
        And the object's UserName should be of type String
        And the object's Age should be of type Int32
        And the object's Homepage should be of type Uri


    @Deserialization @File
    Scenario: I should be able to import serialized data from files even in PowerShell 2
        Given a module with the name 'TestModule1'
        Given a metadata file named Configuration.psd1
            """
            @{
              UserName = 'Joel'
              Age = 42
            }
            """
        And we fake version 2.0 in the Metadata module
        When we import the file to an object
        Then the output object should be of type hashtable
        And the object's UserName should be of type String
        And the object's Age should be of type Int32


    @Deserialization @File
    Scenario: I should be able to import serialized data regardless of file extension
        Given a module with the name 'TestModule1'
        Given a metadata file named Settings.data
            """
            @{
              UserName = 'Joel'
              Age = 42
            }
            """
        When we import the file to an object
        Then the output object should be of type hashtable
        Then the object's UserName should be of type String
        Then the object's Age should be of type Int32

    @Deserialization @File
    Scenario: Imported metadata files should be able to use PSScriptRoot
        Given a module with the name 'TestModule1'
        Given a metadata file named Configuration.psd1
            """
            @{
              MyPath = Join-Path $PSScriptRoot "Configuration.psd1"
            }
            """
        And we're using PowerShell 4 or higher in the Metadata module
        When we import the file to an object
        Then the output object should be of type hashtable
        And the object's MyPath should be of type String
        And the object's MyPath should match the file's path


    @Deserialization @File
    Scenario: Bad data should generate useful errors
        Given a module with the name 'TestModule1'
        Given a metadata file named Configuration.psd1
            """
            @{ UserName = }
            """
        Then trying to import the file to an object should throw
            """
            Missing statement after '=' in hash literal.
            """

    @Deserialization @File
    Scenario: Disallowed commands should generate useful errors
        Given a module with the name 'TestModule1'
        Given a metadata file named Configuration.psd1
            """
            @{
                UserName = New-Object PSObject -Property @{ First = "Joel" }
            }
            """
        Then trying to import the file to an object should throw
            """
            The command 'New-Object' is not allowed in restricted language mode or a Data section.
            """

    @Serialization @Deserialization @File
    Scenario: Handling the default module manifest
        Given a module with the name 'TestModule1'
        Given a metadata file named ModuleName/ModuleName.psd1
            """
            @{
              UserName = 'Joel'
              Age = 42
            }
            """
        When we import the folder path
        Then the output object should be of type hashtable
        Then the object's UserName should be of type String
        Then the object's Age should be of type Int32

    @Serialization @Deserialization @File
    Scenario: Errors when you import missing files
        Given the metadata file does not exist
        And we expect an error in the metadata module
        When we import the file to an object
        Then the error is logged


    @UpdateObject
    Scenario: Update A Hashtable
       Given a hashtable
            """
            @{
              UserName = 'Joel'
              Age = 41
              Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        When we update the object with
            """
            @{
              Age = 42
            }
            """
        Then the object's UserName should be Joel
         And the object's Age should be 42

    @UpdateObject
    Scenario: Update an Object with a hashtable
       Given a settings object
            """
            @{
               PSTypeName = 'User'
               FirstName = 'Joel'
               LastName = 'Bennett'
               UserName = 'Jaykul'
               Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        When we update the object with
            """
            @{
              Age = 42
            }
            """
        Then the output object should have User in the PSTypeNames
         And the object's UserName should be Jaykul
         And the object's Age should be 42

    @UpdateObject
    Scenario: Update an Object with an Object
       Given a settings object
            """
            @{
               PSTypeName = 'User'
               FirstName = 'Joel'
               LastName = 'Bennett'
               UserName = 'Jaykul'
               Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        When we update the object with
            """
            [PSCustomObject]@{
              Age = 42
            }
            """
        Then the output object should have User in the PSTypeNames
         And the object's UserName should be Jaykul
         And the object's Age should be 42

    @UpdateObject
    Scenario: Try to Update An Object With Nothing
        Given a hashtable
            """
            @{
              UserName = 'Joel'
              Age = 41
              Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        When we update the object with
            """
            """
        Then the object's UserName should be Joel
        And the object's Age should be 41

    @UpdateObject
    Scenario: Update a hashtable with important properties
       Given a settings object
            """
            @{
               PSTypeName = 'User'
               FirstName = 'Joel'
               LastName = 'Bennett'
               UserName = 'Jaykul'
               Age = 12
               Homepage = [Uri]"http://HuddledMasses.org"
            }
            """
        When we say UserName is important and update with
            """
            @{
                UserName = 'JBennett'
                Age = 42
            }
            """
        Then the object's UserName should be Jaykul
        And the object's Age should be 42
        And the output object should have User in the PSTypeNames


    @Serialization @Deserialization @File
    Scenario: I should be able to import a manifest in order
        Given a module with the name 'TestModule1'
        Given a metadata file named Configuration.psd1
            """
            @{
              UserName = 'Joel'
              Age = 42
              FullName = 'Joel Bennett'
            }
            """
        When we import the file with ordered
        Then the output object should be of type Collections.Specialized.OrderedDictionary
        And the object's UserName should be of type String
        And the object's Age should be of type Int32
        And Key 0 is UserName
        And Key 1 is Age
        And Key 2 is FullName


    @Serialization @Deserialization @File
    Scenario: The ordered hashtable should recurse
        Given a module with the name 'TestModule1'
        Given a metadata file named Configuration.psd1
            """
            @{
              Age = 42
              FullName = @{
                FirstName = 'Joel'
                LastName = 'Bennett'
              }
            }
            """
        When we import the file with ordered
        Then the output object should be of type Collections.Specialized.OrderedDictionary
        And the object's FullName should be of type Collections.Specialized.OrderedDictionary

    @Regression @Serialization
    Scenario: Arrays of custom types
        Given the Metadata module is imported with a URL converter
        And a hashtable
            """
            @{
              UserName = 'Joel'
              Domains = [Uri]"http://HuddledMasses.org", [Uri]"http://PoshCode.org", [Uri]"http://JoelBennett.net"
            }
            """
        When we convert the object to metadata
        Then the string version should match "Domains = @\(\(?\s*Uri"
        And the string version should match "Uri 'http://huddledmasses.org/'"
        And the string version should match "Uri 'http://poshcode.org'"

    @Serialization @ScriptBlock
    Scenario Outline: Should be able to serialize ScriptBlocks
        Given a hashtable with a ScriptBlock in it
        When we convert the object to metadata
        Then the string version should match "TestCase = \(?ScriptBlock '"

    @Serialization
    Scenario Outline: Should serialize Switch statements as booleans
        Given a hashtable with a SwitchParameter in it
        When we convert the object to metadata
        Then the string version should match "TestCase = \`$True"

    @Serialization
    Scenario: Has an IPsMetadataSerializable Interface
        Given the metadata module exports IPsMetadataSerializable
        And a TestClass that implements IPsMetadataSerializable
        And a metadata file named Configuration.psd1
            """
            FromPsMetadata TestClass "
                @{
                    Values = @{
                        User = 'Jaykul'
                    }
                    Name = 'Joel'
                }
            "
            """
        When we import the file to an object
        Then the output object should be of type TestClass
        And the object's User should be Jaykul
        And the object's Name should be Joel
        And the object's Keys should be User

    @Serialization
    Scenario: Allows specifying a list of allowed variables
        Given a metadata file named Configuration.psd1
            """
            @{
                UserName = "${Env:UserName}"
                Age = 42
                FullName = $FullName
            }
            """
        And we define FullName = Joel Bennett
        And we define Env:UserName = Jaykul
        When we import the file allowing variables FullName, Env:UserName
        Then the object's UserName should be Jaykul
        And the object's FullName should be Joel Bennett

    @Serialization
    Scenario: Supports the default built-in constants
        Given a metadata file named Configuration.psd1
            """
            @{
                True = $True
                False = $False
                PSCulture = $PSCulture
                PSUICulture = $PSUICulture
                Null = $null
            }
            """
        When we import the file to an object
        Then the object's True should be $true
        Then the object's True should be of type bool
        Then the object's False should be $false
        Then the object's False should be of type bool
        Then the object's PSCulture should be $PSCulture
        Then the object's PSUICulture should be $PSUICulture
        Then the object's Null should be null

    @Serialization @Regression
    Scenario: PSObjects should be serialized with 'PSObject'
        Given a settings object
            """
            @{
                UserName = 'Joel'
                Age = 42
                FullName = 'Joel Bennett'
            }
            """
        When we convert the object to metadata
        Then the string version should match "PSObject @{"
        And the string version should match "UserName = 'Joel'"
        And the string version should match "Age = 42"
        And the string version should match "FullName = 'Joel Bennett'"

    @Serialization @Regression
    Scenario: PSObjects should be allowed weird characters in properties
        Given a settings object
            """
            @{
                "O'Connor" = $true
                Age = 42
            }
            """
        When we convert the object to metadata
        Then the string version should match "PSObject @{"
        And the string version should match "'O''Connor' = \`$true"
        And the string version should match "Age = 42"