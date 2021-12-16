function ConvertTo-Hashtable {
    <#
        .Synopsis
            Converts objects to hashtables, loosing methods, etc.
        .Description
            A wrapper for: Update-Object -Input @{} $Object

            This is not a deep conversion: values in the hashtable will be the same as the values in the object.
        .Example
            $Object | ConvertTo-Hashtable

            Converts a PSObject to a Hashtable (note: this is not a deep conversion)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # This object to convert to a hashtable
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $InputObject
    )
    process {
        Update-Object -InputObject @{} -UpdateObject $InputObject
    }
}