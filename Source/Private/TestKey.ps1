function TestKey {
    <#
        .Synopsis
            Check whether the input object has the specified key (if it's a dictionary) or property (otherwise)
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param($InputObject, $Key)
    [bool]$(
        if ($InputObject -is [System.Collections.IDictionary]) {
            $InputObject.ContainsKey($Key)
        } else {
            Get-Member -InputObject $InputObject -Name $Key
        }
    )
}