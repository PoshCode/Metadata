@{
    ModuleManifest           = "Source/Metadata.psd1"
    OutputDirectory          = "../"
    SourceDirectories        = @("Header", "Private", "Public")
    Suffix                   = "Footer/InitialMetadataConverters.ps1"
    VersionedOutputDirectory = $true
}